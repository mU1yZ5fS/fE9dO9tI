extends RefCounted

## 原作 Event8.cs：中苏外交危机。逐字中文 + 完整效果复刻。
## 差异：
##  - 触发：TimeScript.cs:10083 自动触发（empires[1].relations<=0 && !event_done[8] &&
##    !event_done[473]），每半年(1月/7月1日)重置可重复（TimeScript.cs:3029）。端口 008 的
##    trigger_conditions = EMPIRE_RELATION_AT_MOST(1,0) + PREV_EVENT_NOT_DONE(event_473)，
##    473 未移植前视为恒真。
##  - dlc[3]（DLC 购买标志）：端口无 DLC 体系 → 视为恒真（同 game_manager.gd:2225 先例）。
##  - opt3 的 data[111]++：反编译为死代码（ptr 局部变量自增未写回 data），跳过。
##  - button_text[5]=""（空按钮占位）：无实际内容，跳过。
const W = preload("res://数据脚本/world_state.gd")


func execute(context: Dictionary) -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	var d := ws.数值表
	var opt := int(context.get("option_index", -1))

	match opt:
		0:
			_opt_detente(ws, d, context)
		2:
			_opt_nuke(context)
		3:
			_opt_indifferent(ws, d, context)
		4:
			_opt_embargo(ws, context)


# 选项0：我们出资缓和关系（Event8.cs result 0，diplo 扣 /20）
func _opt_detente(ws: WorldState, d: Array, context: Dictionary) -> void:
	if ws.empires.size() > 1 and ws.empires[1] != null:
		ws.empires[1].relations = 400
	@warning_ignore("integer_division")
	if d.size() > W.I_DIPLO and d[W.I_DIPLO] > 600:
		d[W.I_DIPLO] -= d[W.I_DIPLO] / 20
	if d.size() > W.I_BUDGET:
		d[W.I_BUDGET] -= 100
	context["result_text"] = "我们紧急组织了一次中国外交部长和苏联外长的盛大会谈，我们邀请苏维埃代表团进行了一次豪华的中国之旅，在那里我们准备了各种节日和活动来表达我们和平的愿望。缓和成功了，紧张局势得到了缓和。"


# 选项2：向修正主义者发射核武器！（Event8.cs result 2：load_scene_after_click → 结局）
func _opt_nuke(context: Dictionary) -> void:
	context["result_text"] = "紧张度提升"
	GameManager.queue_ending_after_event(3)


# 选项3：一点都不在乎（Event8.cs result 3：激活修正16「苏联禁运」+ 经互会分支）
func _opt_indifferent(ws: WorldState, d: Array, context: Dictionary) -> void:
	var mod16 := _get_mod16(ws)
	if mod16 == null or not mod16.is_active:
		if d.size() > W.I_ARMY:
			d[W.I_ARMY] -= 50
		if d.size() > W.I_AGENTS:
			d[W.I_AGENTS] -= 50
		if mod16 != null:
			mod16.is_active = true
			_set_mod16_text("苏联禁运", "我们将减少与苏联关系差额10%的收入|失去相当于与苏联关系差额5%的特工网络")
		# 差异：原 data[111]++ 为反编译死代码（ptr 局部自增未写回），跳过。
	if mod16 != null and mod16.is_active and _usa_in_sev(ws) and d.size() > 139 and d[139] <= 0:
		d[139] = 5   # 原 data[139]（无端口命名键，数字索引直访）
	context["result_text"] = "紧张度提升"


# 选项4：让我们给修正主义者一点颜色瞧瞧！（Event8.cs result 4：激活修正16「禁运苏联」）
func _opt_embargo(ws: WorldState, context: Dictionary) -> void:
	var mod16 := _get_mod16(ws)
	if mod16 != null:
		mod16.is_active = true
		_set_mod16_text("禁运苏联", "我们将增加与苏联影响差额10%的特工网络|获得相当于与苏联影响差额5%的预算|苏联将减少与中国影响差额10%的影响力|失去相当于与中国影响差额5%的收入")
	context["result_text"] = "很快，我们就发动了联盟内的国家对苏联实施了禁运，苏方对此十分震惊，谴责中国的“帝国主义行为”，但他们之前威胁我们的时候为什么不想想可能的后果呢？总而言之，苏联佬会有一段“难忘”的时光了！"


func _get_mod16(ws: WorldState) -> ModifierSlot:
	if ws.modifiers.size() > 16:
		return ws.modifiers[16]
	return null


## 原 old_modify_texts[16]/old_modify_desc[16]：运行时改 ModifierDef 展示文案（与 UI 读取路径一致）
func _set_mod16_text(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(16)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect


func _usa_in_sev(ws: WorldState) -> bool:
	var usa := ws.get_country_by_legacy_index(1)
	return usa != null and usa.has_tag("sev")
