class_name EventScriptBase
extends RefCounted

## 事件效果脚本统一基类（2026-08 架构收敛）。
## 收敛逐脚本重复的样板：
##   const W = preload(world_state)  → 基类常量 W（子类直接使用）
##   var ws = GameManager.world; if null return; var d := ws
##                                     → execute 开头调 _bind_world()，直接用成员 ws / d
##
## 使用方式：
##   extends EventScriptBase
##   func execute(context: Dictionary) -> void:
##       if not _bind_world():
##           return
##       d.people_support -= 20   # 直接读写成员
##
## 入口契约（与 EventEngine / GameManager 的调用点对应）：
##   - execute(context)：CUSTOM_SCRIPT 效果执行（EventEngine._run_custom_script）
##   - prepare(event_def, ws)：显示前动态文案钩子（GameManager 对 display_script 调用）
##   基类提供空实现，任何脚本被两种入口调用都安全。

const W = preload("res://数据脚本/world_state.gd")

## 当前 WorldState（_bind_world() 成功后可用）
var ws: WorldState = null

## 数值表快捷引用（= ws，引用语义，修改即写回）
var d: WorldState = null

## 事件脚本可用的 GameService 门面；优先取 context 注入，缺省回退到 GameManager。
var _game_service: GameService = null
var game: GameService:
	get:
		if _game_service == null:
			if exec_context.has("game") and exec_context["game"] is GameService:
				_game_service = exec_context["game"] as GameService
			elif GameManager != null:
				_game_service = GameService.new(GameManager)
		return _game_service
	set(value):
		_game_service = value

## 最近一次 execute(context) 的上下文。EventEngine 执行 CUSTOM_SCRIPT 前会注入。
## 用于让事件脚本通过 context["world"] 拿到 WorldState，避免直接依赖 GameManager。
var exec_context: Dictionary = {}


## execute 开头调用：绑定 ws / d。WorldState 未就绪返回 false，调用方直接 return。
## 优先使用 EventEngine 注入的 context["world"]；旧调用点没有 context 时回退到 GameManager.world。
func _bind_world() -> bool:
	if exec_context.has("world") and exec_context["world"] is WorldState:
		ws = exec_context["world"] as WorldState
	else:
		ws = GameManager.world
	if ws == null:
		return false
	d = ws
	if exec_context.has("game") and exec_context["game"] is GameService:
		_game_service = exec_context["game"] as GameService
	return true


## 显示前动态文案钩子（game_manager 对 display_script 调用；无钩子的脚本用基类空实现）
func prepare(_event_def: EventDef, _p_ws: WorldState) -> void:
	pass


## 效果入口（event_engine 的 CUSTOM_SCRIPT 效果调用；子类实现）
func execute(_context: Dictionary) -> void:
	pass


# ============================================================================
# 共享小助手（2026-08 集中到基类，消除各事件脚本重复定义/漏定义的 Parse Error）。
# 子类可继续定义同名同签名方法覆盖；签名必须与此处一致。
# ============================================================================

## 选项启用（动态选项 prepare 用）
func _enable(opt: EventOption, text: String) -> void:
	if opt == null:
		return
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


## 选项禁用（RESOURCE_AT_LEAST party_system=99999 恒不满足）
func _disable(opt: EventOption, text: String) -> void:
	if opt == null:
		return
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


## 数值表加值
func _add(index: int, delta: int) -> void:
	if d != null and d.size() > index:
		d.add_data_by_index(index, delta)


## 数值表赋值（原 _set，改名避开 Object._set 虚方法签名冲突）
func _set_data(index: int, value: int) -> void:
	if d != null and d.size() > index:
		d.set_data_by_index(index, value)


## 数值表读取
func _res(index: int) -> int:
	if d != null and d.size() > index:
		return d.get_data_by_index(index)
	return 0


## 帝国关系加减（0~1000 钳制）
func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


## 帝国力量加减
func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


## Country.LeaveAlliances() 逐项映射
func _leave_alliances(c: CountryData) -> void:
	if c == null:
		return
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = GameConstants.LegacySlot.NONE


## JoinAllOurAlliances(true) 简化映射（id 属 flag 组时仅加入经济联盟）
func _join_alliances(c: CountryData) -> void:
	if c == null:
		return
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)


## 领导人与指定政治家双向互换身份（Event44/80/94 共用）。
## 第二个参数为兼容现有调用点保留；互换本身不需要额外修改派系领袖索引。
func _swap_leader_with_politician(slot: int, _faction_index: int = -1) -> void:
	if ws == null or ws.leader == null:
		return
	if slot < 0 or slot >= ws.politicians.size():
		return
	var other: PoliticianData = ws.politicians[slot]
	if other == null:
		return
	PoliticianSystem.swap_leader_profile(ws.leader, other)
