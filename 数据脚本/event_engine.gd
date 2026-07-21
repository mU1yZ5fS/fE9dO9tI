# ============================================================================
# EventEngine — 事件引擎 Autoload
# ============================================================================
# 负责事件系统的全部运行时逻辑。
#
# 触发机制（两种路径）：
#   【即时事件】mtth_base = 0
#     条件满足 → 发出 event_triggered 信号，由 GameManager 切场景。
#
#   【延时事件】mtth_base > 0
#     MTTH 计时到期 → 进入"待处理"状态：
#       1. 弹出通知提示（显示在 UI 上），给玩家 10 天缓冲期
#       2. 玩家可以点击通知立即进入事件
#       3. 10 天后若未点击，强制切场景
#
# 架构：
#     EventEngine (Autoload)
#       ├── _events: event_id → EventDef
#       ├── _mtth_timers: event_id → 累计月数
#       ├── pending_event_id + _pending_deadline: 待处理事件
#       └── 每 tick 由 GameManager 调用 check_and_fire()
#
# 依赖关系：
#   - EventEngine → GameManager.world（只读数据查询）
#   - EventEngine → event_triggered 信号 → GameManager 处理场景切换
#   - 打破了双向 Autoload 直接调用，改用信号解耦
# ============================================================================

extends Node

## 事件定义文件存放目录（仅在编辑器中由 GenerateEvents 工具使用）
@export_dir var scan_directory: String = "res://场景/事件界面/events/"

## 延时事件的缓冲天数（游戏内日期）
const PENDING_GRACE_DAYS: int = 10

## 每 tick 经过的游戏月数（1 天 ≈ 1/30 月）
const TICK_MONTHS: float = 1.0 / 30.0

## 事件触发信号（由 GameManager 连接处理场景切换）
signal event_triggered(event_id: String, is_timeout: bool)

## 事件通知：延时事件进入待处理状态时发出
signal event_notification(event_id: String, title: String)

## 通知消除
signal event_notification_dismissed()

## 事件定义注册表（event_id → EventDef）
var _events: Dictionary = {}

## MTTH 累计计时（event_id → 累计月数）
var _mtth_timers: Dictionary = {}

## 待处理的延时事件 ID（空串 = 无）
var pending_event_id: String = ""

## 待处理事件的截止日期（GameDate.to_int() 格式）
var _pending_deadline: int = -1

## 文本库引用（可选，设置后优先使用文本库的本地化文本）
var text_library: Node = null

## 事件链队列（FIFO）。当某事件的选项触发 triggers_on_complete 时，
## 被链式触发的 event_id 进入此队列。check_and_fire 在没有进行中事件时
## 依次立即触发队首事件。这让"事件A完成→立即弹事件B"成为可能。
var _event_queue: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_scan_events()


func _scan_events() -> void:
	# 从磁盘加载 .tres 事件文件（这些文件应由 GenerateEvents 工具在编辑器中预生成）
	var dir := DirAccess.open(scan_directory)
	if dir == null:
		push_warning("EventEngine: 事件目录不存在 %s —— 请在编辑器中运行 GenerateEvents 工具" % scan_directory)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res := load(scan_directory + file_name)
			if res is EventDef:
				_events[res.event_id] = res
				print("EventEngine: 已加载事件 %s" % res.event_id)
			else:
				push_warning("EventEngine: 跳过非 EventDef 文件 %s" % file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	print("EventEngine: 扫描完成，共 %d 个事件" % _events.size())


## 重新加载所有事件定义（热重载用）
func reload_events() -> void:
	_events.clear()
	_mtth_timers.clear()
	_event_queue.clear()
	pending_event_id = ""
	_pending_deadline = -1
	_scan_events()


# ========================================================================
# 每 tick 检查（由 GameManager.tick() 调用）
# ========================================================================

## 是否有事件正在展示。GameManager.current_event_id 在事件场景激活期间非空。
func _is_event_in_progress() -> bool:
	return GameManager != null and GameManager.current_event_id != ""


## 将事件ID加入事件链队列（去重，避免同一事件重复入队）
func enqueue_chain(event_ids: Array[String]) -> void:
	for eid in event_ids:
		if eid != "" and not _event_queue.has(eid):
			_event_queue.append(eid)


func check_and_fire() -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return

	# 优先处理事件链队列：既无待处理事件、也无正在展示的事件时，
	# 立即触发队首事件（事件A完成 → 立即弹事件B）。
	if _event_queue.size() > 0 and pending_event_id == "" and not _is_event_in_progress():
		var next_id: String = _event_queue.pop_front()
		var chained := _events.get(next_id) as EventDef
		if chained != null:
			_fire_immediate(chained)
		else:
			push_warning("EventEngine: 事件链引用了不存在的事件 %s" % next_id)
		return

	# 检查待处理事件是否超时
	if pending_event_id != "" and _pending_deadline > 0:
		if ws.date.to_int() >= _pending_deadline:
			_force_fire_pending()
			return

	# 已有待处理事件时不检查新事件（同一时间只弹一个）
	if pending_event_id != "":
		return

	# 扫描所有事件
	for ev in _events.values():
		var event_def := ev as EventDef
		if not _evaluate_trigger(event_def):
			continue
		if event_def.mtth_base <= 0.0:
			_fire_immediate(event_def)
			return
		_tick_mtth(event_def)


func _fire_immediate(event_def: EventDef) -> void:
	print("EventEngine: 即时触发 %s" % event_def.event_id)
	event_triggered.emit(event_def.event_id, false)


func _tick_mtth(event_def: EventDef) -> void:
	var effective_mtth := _calc_effective_mtth(event_def)
	if not _mtth_timers.has(event_def.event_id):
		_mtth_timers[event_def.event_id] = 0.0
	_mtth_timers[event_def.event_id] += TICK_MONTHS / effective_mtth
	if _mtth_timers[event_def.event_id] >= 1.0:
		_mtth_timers[event_def.event_id] = 0.0
		_enter_pending(event_def)


func _calc_effective_mtth(event_def: EventDef) -> float:
	var mtth := maxf(event_def.mtth_base, 0.1)
	for mod in event_def.mtth_modifiers:
		var m := mod as MTTHModifier
		# null condition 表示"始终生效"，短路求值避免调用 evaluate(null)
		if m.condition == null or evaluate(m.condition):
			mtth *= m.factor
	return maxf(mtth, 0.05)


func _enter_pending(event_def: EventDef) -> void:
	pending_event_id = event_def.event_id
	var ws: WorldState = GameManager.world
	_pending_deadline = ws.date.to_int() + PENDING_GRACE_DAYS if ws else -1
	print("EventEngine: 延时事件待处理 %s (截止 %d)" % [event_def.event_id, _pending_deadline])
	event_notification.emit(event_def.event_id, event_def.title)


## 手动将事件加入待处理队列（供外部系统如 Decision / 战争结束 使用）。
## 若已有待处理：战争结算优先覆盖；其它事件入链队列避免丢失。
func queue_pending(event_id: String) -> void:
	var event_def := _events.get(event_id) as EventDef
	if event_def == null:
		return
	if pending_event_id != "":
		if event_id == "war_is_over" and pending_event_id != "war_is_over":
			# 把原待处理事件压回链，优先展示战争结束
			if not _event_queue.has(pending_event_id):
				_event_queue.push_front(pending_event_id)
			_clear_pending()
			_enter_pending(event_def)
			return
		if not _event_queue.has(event_id):
			_event_queue.append(event_id)
		return
	_enter_pending(event_def)


## 玩家点击通知：立即触发
func accept_pending() -> void:
	if pending_event_id == "":
		return
	var event_id := pending_event_id
	_clear_pending()
	var event_def := _events.get(event_id) as EventDef
	if event_def:
		print("EventEngine: 玩家接受 %s" % event_id)
		event_triggered.emit(event_id, false)


## 超时强制触发
func _force_fire_pending() -> void:
	if pending_event_id == "":
		return
	var event_id := pending_event_id
	_clear_pending()
	var event_def := _events.get(event_id) as EventDef
	if event_def:
		print("EventEngine: 超时强制触发 %s" % event_id)
		event_triggered.emit(event_id, true)


func _clear_pending() -> void:
	pending_event_id = ""
	_pending_deadline = -1
	event_notification_dismissed.emit()


# ========================================================================
# 条件求值
# ========================================================================

func _evaluate_trigger(event_def: EventDef) -> bool:
	# 空触发条件 = 不通过自动扫描触发，必须由外部系统（Decision / queue_pending 等）手动触发
	if event_def.trigger_conditions.is_empty():
		return false

	# fire_only_once 检查：通过 completed_event_ids 字典追踪
	if event_def.fire_only_once and _is_event_already_done(event_def):
		return false

	# AND 逻辑：所有条件必须满足
	for cond in event_def.trigger_conditions:
		if not evaluate(cond):
			return false
	return true


## 检查事件是否已完成
func _is_event_already_done(event_def: EventDef) -> bool:
	var ws: WorldState = GameManager.world
	if ws == null:
		return false
	return ws.completed_event_ids.has(event_def.event_id)


func _mark_done(event_def: EventDef, option_index: int = 0) -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	ws.completed_event_ids[event_def.event_id] = option_index


func evaluate(node: ExprNode) -> bool:
	if node == null:
		return false
	var ws: WorldState = GameManager.world
	match node.type:
		ExprNode.Type.RESOURCE_AT_LEAST: return _get_resource(node.key) >= node.value
		ExprNode.Type.RESOURCE_AT_MOST: return _get_resource(node.key) <= node.value
		ExprNode.Type.RESOURCE_AT_LEAST_FOR: return _get_resource_for(node.target, node.key) >= node.value
		ExprNode.Type.MODIFIER_ACTIVE: return _is_modifier_active(node.key)
		ExprNode.Type.MODIFIER_INACTIVE: return not _is_modifier_active(node.key)
		ExprNode.Type.PREV_EVENT_RESULT_IS:
			return ws != null and ws.completed_event_ids.get(node.ref_event_id, -1) == int(node.value)
		ExprNode.Type.PREV_EVENT_DONE:
			return ws != null and ws.completed_event_ids.has(node.ref_event_id)
		ExprNode.Type.PREV_EVENT_NOT_DONE:
			return ws == null or not ws.completed_event_ids.has(node.ref_event_id)
		ExprNode.Type.IS_FACTION_LEADER: return _is_faction_leading(int(node.value))
		ExprNode.Type.EMPIRE_RELATION_AT_LEAST: return _get_empire_relation(int(node.key)) >= node.value
		ExprNode.Type.EMPIRE_RELATION_AT_MOST: return _get_empire_relation(int(node.key)) <= node.value
		ExprNode.Type.COUNTRY_HAS_TAG: return _player_has_tag(node.key)
		ExprNode.Type.COUNTRY_IS_SUBJECT_OF:
			# overlord_tag（新字段）优先，回退到 key（旧字段兼容）
			var overlord: String = node.overlord_tag if node.overlord_tag != "" else node.key
			return _country_is_subject_of(node.target, overlord)
		ExprNode.Type.DATE_AFTER: return _date_compare(node.key, false)
		ExprNode.Type.DATE_BEFORE: return _date_compare(node.key, true)
		ExprNode.Type.HAS_FLAG: return ws != null and ws.get_flag(node.key)
		ExprNode.Type.NOT_HAS_FLAG: return ws == null or not ws.get_flag(node.key)
		ExprNode.Type.COUNTRY_EXISTS: return _resolve_country(node.key) != null
		ExprNode.Type.ALL:
			for child in node.children:
				if not evaluate(child): return false
			return true
		ExprNode.Type.ANY:
			for child in node.children:
				if evaluate(child): return true
			return false
		ExprNode.Type.NOT:
			return node.children.size() > 0 and not evaluate(node.children[0])
	return false


# ========================================================================
# 效果执行
# ========================================================================

func execute(effects: Array[EffectNode], context: Dictionary = {}) -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	for fx in effects:
		if fx == null:
			continue
		match fx.type:
			EffectNode.Type.ADD_RESOURCE: _add_resource(fx.key, int(fx.value))
			EffectNode.Type.SET_RESOURCE: _set_resource(fx.key, int(fx.value))
			EffectNode.Type.JOIN_ALLIANCE: _set_alliance(fx.target, fx.key, true)
			EffectNode.Type.LEAVE_ALLIANCE: _set_alliance(fx.target, fx.key, false)
			EffectNode.Type.JOIN_ALL_ALLIANCES: _join_all_alliances(fx.target)
			EffectNode.Type.JOIN_ECONOMIC_ALLIANCE: _join_economic_alliance(fx.target)
			EffectNode.Type.SET_COUNTRY_VAR: _set_country_var(fx.target, fx.key, int(fx.value))
			EffectNode.Type.ADD_COUNTRY_VAR: _add_country_var(fx.target, fx.key, int(fx.value))
			EffectNode.Type.ADD_EMPIRE_RELATION: _add_empire_relation(int(fx.key), int(fx.value))
			EffectNode.Type.SET_EMPIRE_RELATION: _set_empire_relation(int(fx.key), int(fx.value))
			EffectNode.Type.ADD_EMPIRE_POWER: _add_empire_power(int(fx.key), int(fx.value))
			EffectNode.Type.ADD_FACTION_SUPPORT: _add_faction_support(int(fx.key), int(fx.value))
			EffectNode.Type.SET_WAR_STATE: _set_resource("war", int(fx.value))
			EffectNode.Type.START_WAR: _start_war_from_effect(fx)
			EffectNode.Type.SET_MODIFIER_ACTIVE: _set_modifier(fx.key, fx.value >= 0.5)
			EffectNode.Type.SET_MODIFIER_AVAILABLE: _set_modifier_available(fx.key, fx.value >= 0.5)
			EffectNode.Type.SET_FLAG: ws.set_flag(fx.key, true)
			EffectNode.Type.CLEAR_FLAG: ws.set_flag(fx.key, false)
			EffectNode.Type.TRIGGER_EVENT:
				if _events.has(fx.key):
					_fire_immediate(_events[fx.key])
			EffectNode.Type.CUSTOM_SCRIPT:
				_run_custom_script(fx, context)


# ========================================================================
# 事件 UI API
# ========================================================================

## START_WAR 效果：value=war_id；key="infl1,infl2,usa_side,ussr_side"；target="side1|side2"
func _start_war_from_effect(fx: EffectNode) -> void:
	if GameManager == null or not GameManager.has_method("start_war"):
		push_warning("EventEngine: START_WAR 时 GameManager.start_war 不可用")
		return
	var war_id := int(fx.value)
	var infl1 := -1
	var infl2 := -1
	var usa_side := -1
	var ussr_side := -1
	if fx.key != "":
		var parts := fx.key.split(",")
		if parts.size() > 0 and parts[0].is_valid_int():
			infl1 = int(parts[0])
		if parts.size() > 1 and parts[1].is_valid_int():
			infl2 = int(parts[1])
		if parts.size() > 2 and parts[2].is_valid_int():
			usa_side = int(parts[2])
		if parts.size() > 3 and parts[3].is_valid_int():
			ussr_side = int(parts[3])
	var side1 := ""
	var side2 := ""
	if fx.target != "" and fx.target != "ROOT":
		var sides := fx.target.split("|")
		if sides.size() > 0:
			side1 = sides[0]
		if sides.size() > 1:
			side2 = sides[1]
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)


## 执行 CUSTOM_SCRIPT 效果。
## custom_script 必须继承 RefCounted（而非 Node），否则 new() 创建的实例会
## 泄漏到场景树之外无法回收。脚本需实现 execute(context: Dictionary) 方法。
func _run_custom_script(fx: EffectNode, context: Dictionary) -> void:
	if fx.custom_script == null:
		push_warning("EventEngine: CUSTOM_SCRIPT 效果缺少 custom_script")
		return
	var executor = fx.custom_script.new()
	if not (executor is RefCounted):
		push_error("EventEngine: CUSTOM_SCRIPT 必须继承 RefCounted，实际 %s" % fx.custom_script.resource_path)
		if executor is Node:
			(executor as Node).queue_free()
		return
	if not executor.has_method("execute"):
		push_error("EventEngine: CUSTOM_SCRIPT 缺少 execute(context) 方法：%s" % fx.custom_script.resource_path)
		return
	executor.execute(context)


func get_event(event_id: String) -> EventDef:
	return _events.get(event_id)


## 获取事件的本地化文本。
## 如果设置了 text_library 且其中存在对应 key，返回本地化文本；
## 否则返回 EventDef 中存储的内联文本。
func get_event_title(event_def: EventDef) -> String:
	if text_library and text_library.has_method("get_text"):
		var key := "event.%s.title" % event_def.event_id
		if text_library.has_text(key):
			return text_library.get_text(key)
	return event_def.title


func get_event_description(event_def: EventDef) -> String:
	if text_library and text_library.has_method("get_text"):
		var key := "event.%s.desc" % event_def.event_id
		if text_library.has_text(key):
			return text_library.get_text(key)
	return event_def.description


func apply_event_option(event_def: EventDef, option_index: int) -> Dictionary:
	if option_index < 0 or option_index >= event_def.options.size():
		return {"name": "", "text": "选项无效"}
	var opt := event_def.options[option_index] as EventOption
	execute(opt.effects)
	_mark_done(event_def, option_index)
	# 事件改数后同步显示视图并通知状态栏
	if GameManager and GameManager.has_method("_notify_stats"):
		GameManager._notify_stats()
	elif GameManager and GameManager.world:
		GameManager.world.sync_economy()
	# 事件链：把 triggers_on_complete 列表加入队列，待玩家返回外交界面后依次触发
	if not event_def.triggers_on_complete.is_empty():
		enqueue_chain(event_def.triggers_on_complete)
	return {
		"name": _resolve_option_title(event_def, opt),
		"text": _resolve_option_result(event_def, opt, option_index),
	}


func _resolve_option_title(event_def: EventDef, opt: EventOption) -> String:
	if opt.result_title != "":
		return opt.result_title
	if text_library and text_library.has_method("get_text"):
		var key := "event.%s.title" % event_def.event_id
		if text_library.has_text(key):
			return text_library.get_text(key)
	return event_def.title


func _resolve_option_result(event_def: EventDef, opt: EventOption, option_index: int) -> String:
	if text_library and text_library.has_method("get_text"):
		var key := "event.%s.option_%d.result" % [event_def.event_id, option_index]
		if text_library.has_text(key):
			return text_library.get_text(key)
	return opt.result_text


# ========================================================================
# 内部辅助 — 数据访问
# ========================================================================

func _get_resource(key: String) -> int:
	var ws: WorldState = GameManager.world
	if ws != null:
		return ws.get_data_value(key)
	return 0


## 获取指定国家的资源值（用于 RESOURCE_AT_LEAST_FOR 条件）
func _get_resource_for(target_tag: String, key: String) -> int:
	var ws: WorldState = GameManager.world
	if ws != null:
		return ws.get_data_value_for_country(target_tag, key)
	return 0


func _is_modifier_active(key: String) -> bool:
	var idx := int(key) if key.is_valid_int() else -1
	var ws: WorldState = GameManager.world
	if ws == null:
		return false
	if idx >= 0 and idx < ws.modifiers.size():
		return ws.modifiers[idx].is_active
	return false


func _get_empire_relation(empire_index: int) -> int:
	var ws: WorldState = GameManager.world
	if ws == null:
		return 0
	if empire_index < 0 or empire_index >= ws.empires.size(): return 0
	return ws.empires[empire_index].relations


func _is_faction_leading(faction_index: int) -> bool:
	# 与 GameManager.is_faction_leading 共用（FAC-03）
	return GameManager != null and GameManager.is_faction_leading(faction_index)


func _player_has_tag(tag: String) -> bool:
	var player: CountryData = GameManager.world.get_player_country()
	if player == null: return false
	return player.has_tag(tag)


func _country_is_subject_of(subject_tag: String, overlord_tag: String) -> bool:
	# subject_tag: 待检查的附庸国标签（如 "KOR"），对应 ExprNode.target
	# overlord_tag: 宗主国标签（如 "CHN"），对应 ExprNode.key
	var subject: CountryData = _resolve_country(subject_tag)
	var overlord: CountryData = _resolve_country(overlord_tag)
	if subject == null or overlord == null:
		return false
	return subject.puppet_of == overlord.原版序号 or subject.puppet_of == overlord.slot


func _date_compare(date_str: String, before: bool) -> bool:
	var parts := date_str.split(".")
	if parts.size() < 2: return false
	var ty := int(parts[0]); var tm := int(parts[1])
	var cur: GameDate = GameManager.world.date
	if before:
		if cur.year < ty: return true
		if cur.year > ty: return false
		return cur.month <= tm
	else:
		if cur.year > ty: return true
		if cur.year < ty: return false
		return cur.month >= tm


## 按标签解析国家。通过 WorldState.get_country_by_tag() 动态查找。
func _resolve_country(tag: String) -> CountryData:
	var ws: WorldState = GameManager.world
	if ws == null: return null
	if tag == "ROOT" or tag == "":
		return ws.get_player_country()
	return ws.get_country_by_tag(tag)


# ========================================================================
# 内部辅助 — 效果执行
# ========================================================================

func _add_resource(key: String, delta: int) -> void:
	var ws: WorldState = GameManager.world
	if ws != null:
		ws.add_data_value(key, delta)

func _set_resource(key: String, value: int) -> void:
	var ws: WorldState = GameManager.world
	if ws != null:
		ws.set_data_value(key, value)

func _set_alliance(target_tag: String, alliance: String, join: bool) -> void:
	var country: CountryData = _resolve_country(target_tag)
	if country == null: return
	country.set_tag(alliance.to_lower(), join)

func _join_all_alliances(target_tag: String) -> void:
	var target: CountryData = _resolve_country(target_tag)
	var player: CountryData = GameManager.world.get_player_country()
	if target == null or player == null: return
	for tag_key in player.tags:
		if player.tags[tag_key]:
			target.set_tag(tag_key, true)

const ECONOMIC_TAGS: Array[String] = ["sev", "econ", "asean", "fez", "eu", "soc_eu", "oil"]

func _join_economic_alliance(target_tag: String) -> void:
	var target: CountryData = _resolve_country(target_tag)
	var player: CountryData = GameManager.world.get_player_country()
	if target == null or player == null: return
	for etag in ECONOMIC_TAGS:
		if player.has_tag(etag):
			target.set_tag(etag, true)

func _set_country_var(target_tag: String, var_name: String, var_value: int) -> void:
	var country: CountryData = _resolve_country(target_tag)
	if country == null: return
	match var_name:
		"special_ending": country.special_ending = var_value

func _add_country_var(target_tag: String, var_name: String, delta: int) -> void:
	var country: CountryData = _resolve_country(target_tag)
	if country == null: return
	match var_name:
		"special_ending": country.special_ending += delta

func _add_empire_relation(empire_index: int, delta: int) -> void:
	var ws: WorldState = GameManager.world
	if empire_index < 0 or empire_index >= ws.empires.size(): return
	ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _set_empire_relation(empire_index: int, value: int) -> void:
	var ws: WorldState = GameManager.world
	if empire_index < 0 or empire_index >= ws.empires.size(): return
	ws.empires[empire_index].relations = clampi(value, 0, 1000)

func _add_empire_power(empire_index: int, delta: int) -> void:
	var ws: WorldState = GameManager.world
	if empire_index < 0 or empire_index >= ws.empires.size(): return
	ws.empires[empire_index].power += delta

func _add_faction_support(faction_index: int, delta: int) -> void:
	var ws: WorldState = GameManager.world
	if faction_index < 0 or faction_index >= ws.factions.size(): return
	ws.factions[faction_index].support += delta

func _set_modifier(key: String, active: bool) -> void:
	var ws: WorldState = GameManager.world
	var idx := int(key) if key.is_valid_int() else -1
	if idx >= 0 and idx < ws.modifiers.size():
		ws.modifiers[idx].is_active = active

func _set_modifier_available(key: String, available: bool) -> void:
	var ws: WorldState = GameManager.world
	var idx := int(key) if key.is_valid_int() else -1
	if idx >= 0 and idx < ws.modifiers.size():
		ws.modifiers[idx].is_available = available


## 写入 WorldState，供存档
func export_runtime_to_world(ws: WorldState) -> void:
	if ws == null:
		return
	ws.event_pending_id = pending_event_id
	ws.event_pending_deadline = _pending_deadline
	ws.event_mtth_timers = _mtth_timers.duplicate(true)
	ws.event_chain_queue = _event_queue.duplicate()


## 从存档恢复 pending / MTTH / 链队列
func import_runtime_from_world(ws: WorldState) -> void:
	if ws == null:
		return
	pending_event_id = ws.event_pending_id
	_pending_deadline = ws.event_pending_deadline
	_mtth_timers = ws.event_mtth_timers.duplicate(true) if ws.event_mtth_timers else {}
	_event_queue.clear()
	for eid in ws.event_chain_queue:
		if str(eid) != "":
			_event_queue.append(str(eid))
	if pending_event_id != "":
		var edef := _events.get(pending_event_id) as EventDef
		var title := edef.title if edef else pending_event_id
		event_notification.emit(pending_event_id, title)

