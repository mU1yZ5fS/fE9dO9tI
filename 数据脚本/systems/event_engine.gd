# ============================================================================
# EventEngine — 事件引擎 Autoload
# ============================================================================
# 负责事件系统的全部运行时逻辑。
#
# 触发机制（忠实复刻原版，2026-08-14 移除 MTTH 自造机制）：
#   【确定性触发】条件满足（trigger_conditions 全真）→ 立即触发。
#     原版 TimeScript.cs:10020-10724 为 else-if 条件链 + EventScript 地图标记；
#     本引擎按 trigger_priority/编号顺序扫描，同一 tick 只触发第一个满足条件的事件。
#
# 待处理（pending）：原 EventScript 地图标记的移植——事件触发后进入待处理，
#   给玩家 notification_days（原 104 单位/8 = 13 天）缓冲，超时扣
#   timeout_agents_penalty/timeout_budget_penalty（原 data.agents-=20/data.budget-=5）。
#   当前 83 个 .tres 均 show_notification=false（直接切事件），缓冲未启用。
#
# 架构：
#     EventEngine (Autoload)
#       ├── _events: event_id → EventDef
#       ├── pending_event_id + _pending_deadline: 待处理事件
#       └── 每 tick 由 GameManager 调用 check_and_fire()
#
# 依赖关系：
#   - EventEngine → world（只读数据查询）
#   - EventEngine → event_triggered 信号 → GameManager 处理场景切换
#   - 打破了双向 Autoload 直接调用，改用信号解耦
# ============================================================================

extends Node

## 事件定义文件存放目录（仅在编辑器中由 GenerateEvents 工具使用）
@export_dir var scan_directory: String = "res://场景/事件界面/events/"

## 当前 WorldState。由 GameManager 在 new_game/load_game 后注入，避免直接依赖 GameManager.world。
var world: WorldState = null

## GameManager 引用。由 GameManager._ready 注入，用于 start_war / notify / is_faction_leading 等编排调用。
var gm: Node = null

## 旧事件资源没有指定时的原版缓冲天数。
const PENDING_GRACE_DAYS: int = 13

## 事件触发信号（由 GameManager 连接处理场景切换）
signal event_triggered(event_id: String, is_timeout: bool)

## 事件通知：延时事件进入待处理状态时发出
signal event_notification(event_id: String, title: String)

## 通知消除
signal event_notification_dismissed()

## 事件定义注册表（event_id → EventDef）
var _events: Dictionary = {}

## 原版数字事件编号索引（source_event_number → EventDef）
var _events_by_number: Dictionary = {}

## 按原版 else-if 链稳定排序的自动扫描序列。
var _event_order: Array[EventDef] = []

## 活跃扫描序列：已完成的一次性事件会从该列表移除，减少每 tick 全量扫描。
var _active_event_order: Array[EventDef] = []

## 待处理的延时事件 ID（空串 = 无）
var pending_event_id: String = ""

## 待处理事件的截止 tick_count（跨月/跨年仍是精确天数）
var _pending_deadline: int = -1

## 文本库引用（可选，设置后优先使用文本库的本地化文本）
var text_library: Node = null

## 事件链队列（FIFO）。当某事件的选项触发 triggers_on_complete 时，
## 被链式触发的 event_id 进入此队列。check_and_fire 在没有进行中事件时
## 依次立即触发队首事件。这让"事件A完成→立即弹事件B"成为可能。
var _event_queue: Array[String] = []

## 待处理通知队列：当已有 pending 事件时，后续 queue_pending 的请求先排到这里；
## 当前 pending 清掉后逐个 _enter_pending，保证自动/拉美事件也会出现提示图标，
## 而不是被当成事件链直接切场景。
var _pending_queue: Array[String] = []

# ── 事件目录异步加载（启动加载屏调用；autoload _ready 只列目录不 load）──
## 事件注册表是否已可用（同步或异步扫描完成后置 true）
var events_ready := false

var _scan_paths: PackedStringArray = []
var _scan_cursor := 0
var _scan_done := 0
var _scan_total := 0
var _scan_pending: Array[String] = []
var _scan_running := false
var _scan_finished := false
var _scan_order: Dictionary = {}

## 同时挂在 ResourceLoader 后台队列里的最大 .tres 数；防止一次排 500+ 请求。
const ASYNC_BATCH_SIZE := 64

## 每帧最多从后台队列收尾多少个文件；让进度条持续推进而不是再次一次性硬卡。
const ASYNC_FINALIZE_PER_FRAME := 12

signal events_scan_progress(done: int, total: int)
signal events_scan_finished()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 启动期不再同步 load 531 个事件 .tres（曾是启动黑屏/硬控主因）。
	# 只列目录，真正的加载交给 启动加载.gd 调 start_async_scan() 与地图预热并行。
	_scan_paths = ResScan.list_files(scan_directory, [".tres"])


## 同步扫描：热重载与“不经过启动屏直接跑场景”的兜底路径。
## 正常启动路径请走 start_async_scan()，避免主线程一次性卡住。
func _scan_events() -> void:
	var paths := ResScan.list_files(scan_directory, [".tres"])
	if paths.is_empty() and DirAccess.open(scan_directory) == null:
		push_warning("EventEngine: 事件目录不存在 %s —— 请在编辑器中运行 GenerateEvents 工具" % scan_directory)
		_finish_scan()
		return
	_clear_registries()
	for path in paths:
		var res := load(path)
		if res is EventDef:
			_register_event(res)
		else:
			push_warning("EventEngine: 跳过非 EventDef 文件 %s" % path)
	_finish_scan()


## 启动屏调用：把事件 .tres 批量交给 ResourceLoader 后台线程，与地图解码并行。
func start_async_scan() -> void:
	if _scan_running or _scan_finished:
		return
	if _scan_paths.is_empty():
		_scan_paths = ResScan.list_files(scan_directory, [".tres"])
	if _scan_paths.is_empty() and DirAccess.open(scan_directory) == null:
		push_warning("EventEngine: 事件目录不存在 %s —— 请在编辑器中运行 GenerateEvents 工具" % scan_directory)
	_clear_registries()
	_scan_cursor = 0
	_scan_done = 0
	_scan_total = _scan_paths.size()
	_scan_pending.clear()
	_scan_running = true
	_scan_finished = false
	events_ready = false
	_refill_async_requests()
	if _scan_total == 0 or _scan_done >= _scan_total:
		_finish_scan()


## 每帧由启动加载屏调用：只做状态轮询与限量收尾，不阻塞主线程。
func poll_async_scan() -> void:
	if not _scan_running:
		return
	var finalized := 0
	var remaining: Array[String] = []
	for p in _scan_pending:
		if finalized >= ASYNC_FINALIZE_PER_FRAME:
			remaining.append(p)
			continue
		var pr: Array = []
		var st := ResourceLoader.load_threaded_get_status(p, pr)
		if st == ResourceLoader.THREAD_LOAD_LOADED:
			var res := ResourceLoader.load_threaded_get(p)
			_finalize_async_path(p, res)
			finalized += 1
		elif st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			# 后台失败时主线程同步重试一次；单个坏文件不会卡死整批。
			_finalize_async_path(p, load(p))
			finalized += 1
		else:
			remaining.append(p)
	_scan_pending = remaining
	_refill_async_requests()
	if _scan_done >= _scan_total:
		_finish_scan()


func _refill_async_requests() -> void:
	while _scan_pending.size() < ASYNC_BATCH_SIZE and _scan_cursor < _scan_paths.size():
		var p := _scan_paths[_scan_cursor]
		var err := ResourceLoader.load_threaded_request(p)
		if err != OK:
			_finalize_async_path(p, null)
		else:
			_scan_pending.append(p)
		_scan_cursor += 1


func _finalize_async_path(p: String, res: Resource) -> void:
	_scan_done += 1
	if res is EventDef:
		_register_event(res)
	elif res == null:
		push_warning("EventEngine: 加载失败 %s" % p)
	else:
		push_warning("EventEngine: 跳过非 EventDef 文件 %s" % p)
	events_scan_progress.emit(_scan_done, _scan_total)


func _register_event(res: EventDef) -> void:
	_events[res.event_id] = res
	if res.source_event_number >= 0:
		_events_by_number[res.source_event_number] = res
	_scan_order[res.event_id] = _event_order.size() * 10
	_event_order.append(res)
	_active_event_order.append(res)
	print("EventEngine: 已加载事件 %s" % res.event_id)


func _clear_registries() -> void:
	_events.clear()
	_events_by_number.clear()
	_event_order.clear()
	_active_event_order.clear()
	_scan_order.clear()
	_pending_queue.clear()


func _finish_scan() -> void:
	_event_order.sort_custom(func(a: EventDef, b: EventDef) -> bool:
		var pa: int = a.trigger_priority if a.trigger_priority >= 0 else int(_scan_order.get(a.event_id, 100000))
		var pb: int = b.trigger_priority if b.trigger_priority >= 0 else int(_scan_order.get(b.event_id, 100000))
		if pa == pb:
			return a.event_id < b.event_id
		return pa < pb
	)
	_rebuild_active_events()
	_scan_running = false
	_scan_finished = true
	events_ready = true
	_scan_pending.clear()
	print("EventEngine: 扫描完成，共 %d 个事件" % _events.size())
	events_scan_finished.emit()


## 兜底：任何入口在事件表未就绪时确保完成加载。
## 若启动屏已开始异步扫描，则立即返回不阻塞，由启动屏负责等它完成。
func ensure_events_ready() -> void:
	if events_ready or _scan_running:
		return
	_scan_events()


# ========================================================================
# 原版数字事件编号查询（外交按钮等老系统入口使用 event_done[N]）
# ========================================================================

## 按原版 source_event_number 查事件定义；找不到返回 null。
func get_event_by_number(num: int) -> EventDef:
	ensure_events_ready()
	return _events_by_number.get(num) as EventDef


## 原版 event_done[N]：事件已完成（无论选择哪项）。
func event_done_by_number(num: int) -> bool:
	var ev := get_event_by_number(num)
	if ev == null:
		return false
	return world != null and world.completed_event_ids.has(ev.event_id)


## 原版 resultOfEvents[N]：已完成事件的选项编号；未完成=0（原版 int 默认值）。
func result_of_event_by_number(num: int) -> int:
	var ev := get_event_by_number(num)
	if ev == null:
		return 0
	if world == null:
		return 0
	return int(world.completed_event_ids.get(ev.event_id, 0))


## 重新加载所有事件定义（热重载用）
func reload_events() -> void:
	_scan_running = false
	_scan_finished = false
	events_ready = false
	_scan_pending.clear()
	_events.clear()
	_events_by_number.clear()
	_event_order.clear()
	_active_event_order.clear()
	_event_queue.clear()
	pending_event_id = ""
	_pending_deadline = -1
	_scan_events()


# ========================================================================
# 每 tick 检查（由 GameManager.tick() 调用）
# ========================================================================

## 是否有事件正在展示。GameManager.current_event_id 在事件场景激活期间非空。
func _is_event_in_progress() -> bool:
	return gm != null and gm.current_event_id != ""


## 将事件ID加入事件链队列（去重，避免同一事件重复入队）
func enqueue_chain(event_ids: Array[String]) -> void:
	for eid in event_ids:
		if eid != "" and not _event_queue.has(eid):
			_event_queue.append(eid)


func check_and_fire() -> void:
	ensure_events_ready()
	var ws: WorldState = world
	if ws == null:
		return
	if _is_event_in_progress():
		return

	# 优先处理待处理通知队列：这些是曾被 pending 挡住、需要显示提示图标的请求。
	if _pending_queue.size() > 0 and pending_event_id == "" and not _is_event_in_progress():
		var next_pending_id: String = _pending_queue.pop_front()
		var next_pending_def := _events.get(next_pending_id) as EventDef
		if next_pending_def != null:
			_enter_pending(next_pending_def)
		else:
			push_warning("EventEngine: 待处理通知引用了不存在的事件 %s" % next_pending_id)
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
		if ws.date.tick_count >= _pending_deadline:
			_force_fire_pending()
			return

	# 已有待处理事件时不检查新事件（同一时间只弹一个）
	if pending_event_id != "":
		return

	# 扫描活跃事件：忠实复刻原版 else-if 链（同 tick 只触发第一个满足条件的事件）
	for ev in _active_event_order:
		var event_def := ev as EventDef
		if not _evaluate_trigger(event_def):
			continue
		_dispatch_trigger(event_def)
		return


func _fire_immediate(event_def: EventDef) -> void:
	print("EventEngine: 即时触发 %s" % event_def.event_id)
	event_triggered.emit(event_def.event_id, false)


func _dispatch_trigger(event_def: EventDef) -> void:
	# 原版 TimeScript 自动触发链全部走 events[0] 地图标记（EventScript.Reset → 104 单位缓冲），
	# 因此自动扫描命中一律先进 pending 显示提示图标，而不是直接切事件场景。
	# 手动事件（start_event / queue_pending / 事件链）不走本函数，仍按各自语义执行。
	_enter_pending(event_def)


func _enter_pending(event_def: EventDef) -> void:
	pending_event_id = event_def.event_id
	var ws: WorldState = world
	var grace_days := event_def.notification_days if event_def.notification_days > 0 else PENDING_GRACE_DAYS
	_pending_deadline = ws.date.tick_count + grace_days if ws else -1
	print("EventEngine: 延时事件待处理 %s (截止 %d)" % [event_def.event_id, _pending_deadline])
	event_notification.emit(event_def.event_id, event_def.title)


## 手动将事件加入待处理队列（供外部系统如 Decision / 战争结束 使用）。
## 全局去重：同一事件不能同时出现在当前 pending 或通知队列中，避免重复触发。
func queue_pending(event_id: String) -> void:
	ensure_events_ready()
	var event_def := _events.get(event_id) as EventDef
	if event_def == null:
		return
	if event_id == pending_event_id or _pending_queue.has(event_id):
		return
	if pending_event_id != "":
		if event_id == "war_is_over" and pending_event_id != "war_is_over":
			# 把原待处理事件压回通知队列，优先展示战争结束
			if not _pending_queue.has(pending_event_id):
				_pending_queue.push_front(pending_event_id)
			_clear_pending()
			_enter_pending(event_def)
			return
		_pending_queue.append(event_id)
		return
	_enter_pending(event_def)


## 玩家点击通知：立即触发
func accept_pending() -> void:
	ensure_events_ready()
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
	ensure_events_ready()
	if pending_event_id == "":
		return
	var event_id := pending_event_id
	var event_def := _events.get(event_id) as EventDef
	if event_def:
		var ws: WorldState = world
		if ws != null:
			ws.add_data_value("agents", -event_def.timeout_agents_penalty)
			ws.add_data_value("budget", -event_def.timeout_budget_penalty)
	_clear_pending()
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
	# fire_only_once 检查：通过 completed_event_ids 字典追踪
	if event_def.fire_only_once and _is_event_already_done(event_def):
		return false

	# 复杂触发钩子优先（尾追加字段）：trigger_script.evaluate(world) -> bool。
	# 仅当 ExprNode 无法表达的原版复合条件才挂钩子（如 Event713 的 flag/num 循环）。
	if event_def.trigger_script != null:
		var trigger_inst: RefCounted = event_def.trigger_script.new()
		if trigger_inst != null and trigger_inst.has_method("evaluate"):
			return bool(trigger_inst.evaluate(world))
		push_warning("EventEngine: %s 的 trigger_script 缺少 evaluate(world) 方法" % event_def.event_id)
		return false

	# 空触发条件 = 不通过自动扫描触发，必须由外部系统（Decision / queue_pending 等）手动触发
	if event_def.trigger_conditions.is_empty():
		return false

	# AND 逻辑：所有条件必须满足
	for cond in event_def.trigger_conditions:
		if not evaluate(cond):
			return false
	return true


## 手动按钮触发前的公开包装：评估事件自动触发条件（无触发条件的事件视为可手动触发）。
func can_trigger(event_id: String) -> bool:
	ensure_events_ready()
	var def := get_event(event_id)
	if def == null:
		return false
	if def.trigger_conditions.is_empty() and def.trigger_script == null:
		return true
	return _evaluate_trigger(def)


## 检查事件是否已完成
func _is_event_already_done(event_def: EventDef) -> bool:
	var ws: WorldState = world
	if ws == null:
		return false
	return ws.completed_event_ids.has(event_def.event_id)


func _mark_done(event_def: EventDef, option_index: int = 0) -> void:
	var ws: WorldState = world
	if ws == null:
		return
	ws.completed_event_ids[event_def.event_id] = option_index
	# 一次性事件完成后从活跃扫描序列移除，避免后续 tick 重复 evaluate。
	if event_def.fire_only_once:
		_active_event_order.erase(event_def)


## 根据当前 world 的完成记录重建活跃扫描序列（读档后调用）。
func _rebuild_active_events() -> void:
	_active_event_order.clear()
	for ev in _event_order:
		if ev.fire_only_once and world != null and world.completed_event_ids.has(ev.event_id):
			continue
		_active_event_order.append(ev)


func evaluate(node: ExprNode) -> bool:
	if node == null:
		return false
	var ws: WorldState = world
	match node.type:
		ExprNode.Type.RESOURCE_AT_LEAST: return _get_resource(node.key) >= node.value
		ExprNode.Type.RESOURCE_AT_MOST: return _get_resource(node.key) <= node.value
		ExprNode.Type.RESOURCE_AT_LEAST_FOR: return _get_resource_for(node.target, node.key) >= node.value
		ExprNode.Type.RESOURCE_AT_MOST_FOR: return _get_resource_for(node.target, node.key) <= node.value
		ExprNode.Type.RESOURCE_EQUALS: return _get_resource(node.key) == node.value
		ExprNode.Type.RESOURCE_NOT_EQUALS: return _get_resource(node.key) != node.value
		ExprNode.Type.RESOURCE_SUM_AT_LEAST: return _get_resource_sum(node.keys) >= node.value
		ExprNode.Type.RESOURCE_SUM_AT_MOST: return _get_resource_sum(node.keys) <= node.value
		ExprNode.Type.RESOURCE_DIFFERENCE_AT_MOST:
			return _get_resource(node.key) - _get_resource(node.target) <= node.value
		ExprNode.Type.POLITICIAN_POWER_DIFFERENCE_AT_LEAST:
			return _politician_power_sum(int(node.key)) - _politician_power_sum(int(node.target)) >= node.value
		ExprNode.Type.POLITICIAN_GROUP_POWER_DIFFERENCE_AT_LEAST:
			return _politician_group_power_sum(node.key) - _politician_group_power_sum(node.target) >= node.value
		ExprNode.Type.WAR_FIELD_EQUALS:
			return _get_war_field(int(node.target), node.key) == node.value
		ExprNode.Type.COALITION_SUPPORT_AT_LEAST:
			return _coalition_support_percent() >= node.value
		ExprNode.Type.EMPIRE_POWER_DIFFERENCE_AT_LEAST:
			if ws == null or ws.empires.size() <= int(node.key) or ws.empires[int(node.key)] == null:
				return false
			return ws.influence_prc - ws.empires[int(node.key)].power >= node.value
		ExprNode.Type.DECISION_DONE:
			if ws == null or ws.decisions == null or not node.key.is_valid_int():
				return false
			var di := int(node.key)
			return di >= 0 and di < ws.decisions.completed.size() and ws.decisions.completed[di]
		ExprNode.Type.EMPIRE_LEADER_IS:
			# 领导人继任系统：key=帝国编号 value=领导人索引（modify_choose 显示分支的 now_leader）
			if ws == null or not node.key.is_valid_int():
				return false
			var ei := int(node.key)
			if ei < 0 or ei >= ws.empires.size() or ws.empires[ei] == null:
				return false
			return ws.empires[ei].current_leader == int(node.value)
		ExprNode.Type.SOCIALIST_COUNT_AT_LEAST:
			return _socialist_count(node.keys) >= int(node.value)
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
		ExprNode.Type.COUNTRY_HAS_TAG: return _country_has_tag(node.target, node.key)
		ExprNode.Type.COUNTRY_IS_SUBJECT_OF:
			# overlord_tag（新字段）优先，回退到 key（旧字段兼容）
			var overlord: String = node.overlord_tag if node.overlord_tag != "" else node.key
			return _country_is_subject_of(node.target, overlord)
		ExprNode.Type.DATE_AFTER: return _date_compare(node.key, false)
		ExprNode.Type.DATE_BEFORE: return _date_compare(node.key, true)
		ExprNode.Type.HAS_FLAG: return ws != null and ws.get_flag(node.key)
		ExprNode.Type.NOT_HAS_FLAG: return ws == null or not ws.get_flag(node.key)
		ExprNode.Type.COUNTRY_EXISTS: return _resolve_country(node.key) != null
		ExprNode.Type.COUNTRY_FIELD_EQUALS: return _get_country_field(node.target, node.key) == node.value
		ExprNode.Type.COUNTRY_FIELD_NOT_EQUALS: return _get_country_field(node.target, node.key) != node.value
		ExprNode.Type.COUNTRY_FIELD_AT_LEAST: return _get_country_field(node.target, node.key) >= node.value
		ExprNode.Type.COUNTRY_FIELD_AT_MOST: return _get_country_field(node.target, node.key) <= node.value
		ExprNode.Type.TECH_UNLOCKED: return _is_tech_unlocked(int(node.value))
		ExprNode.Type.WAR_ACTIVE: return _is_war_active(int(node.value))
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
	var ws: WorldState = world
	if ws == null:
		return
	for fx in effects:
		if fx == null:
			continue
		if fx.condition != null and not evaluate(fx.condition):
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
			EffectNode.Type.ADD_ALL_POLITICIAN_LOYALTY:
				_add_politician_loyalty([], int(fx.value))
			EffectNode.Type.ADD_POLITICIAN_LOYALTY_BY_PERSONALITY:
				var personalities: Array[int] = []
				for part in fx.key.split(",", false):
					if part.is_valid_int():
						personalities.append(int(part))
				_add_politician_loyalty(personalities, int(fx.value))
			EffectNode.Type.SET_MODIFIER_ACTIVE: _set_modifier(fx.key, fx.value >= 0.5)
			EffectNode.Type.SET_MODIFIER_AVAILABLE: _set_modifier_available(fx.key, fx.value >= 0.5)
			EffectNode.Type.SET_FLAG: ws.set_flag(fx.key, true)
			EffectNode.Type.CLEAR_FLAG: ws.set_flag(fx.key, false)
			EffectNode.Type.TRIGGER_EVENT:
				if _events.has(fx.key):
					var chain_ids: Array[String] = [fx.key]
					enqueue_chain(chain_ids)
			EffectNode.Type.CUSTOM_SCRIPT:
				_run_custom_script(fx, context)


# ========================================================================
# 事件 UI API
# ========================================================================

## START_WAR 效果：value=war_id；key="infl1,infl2,usa_side,ussr_side"；target="side1|side2"
func _start_war_from_effect(fx: EffectNode) -> void:
	if gm == null or not gm.has_method("start_war"):
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
	gm.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)


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
	context["effect"] = fx
	if world != null:
		context["world"] = world
	if not context.has("game") and gm != null:
		context["game"] = GameService.new(gm)
	if executor.has_method("_bind_world"):
		executor.exec_context = context
	executor.execute(context)


func get_event(event_id: String) -> EventDef:
	ensure_events_ready()
	return _events.get(event_id)


## 返回全部已注册事件 id，供调试控制台/开发者工具列出。
func get_all_event_ids() -> Array[String]:
	ensure_events_ready()
	var ids: Array[String] = []
	for key in _events.keys():
		ids.append(String(key))
	ids.sort()
	return ids


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
	var execution_context: Dictionary = {
		"event_id": event_def.event_id,
		"option_index": option_index,
		"game": GameService.new(gm) if gm != null else null,
	}
	execute(opt.effects, execution_context)
	# Event638/644 选项"再想想"复刻原版 event_done[n]=false：脚本置 skip_mark_done 时跳过完成标记。
	# Event648 复刻原版 resultOfEvents[648]=2：脚本可置 result_index_override 覆盖记录结果号。
	if not execution_context.get("skip_mark_done", false):
		var mark_index: int = option_index
		if execution_context.has("result_index_override"):
			mark_index = int(execution_context.get("result_index_override", option_index))
		_mark_done(event_def, mark_index)
	# 事件改数后同步显示视图并通知状态栏
	if gm != null and gm.has_method("_notify_stats"):
		gm._notify_stats()
	elif gm != null and world:
		world.sync_economy()
	# 事件链：把 triggers_on_complete 列表加入队列，待玩家返回外交界面后依次触发
	if not event_def.triggers_on_complete.is_empty():
		enqueue_chain(event_def.triggers_on_complete)
	return {
		"name": execution_context.get("result_title", _resolve_option_title(event_def, opt)),
		"text": execution_context.get("result_text", _resolve_option_result(event_def, opt, option_index)),
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
	var ws: WorldState = world
	if ws != null:
		return ws.get_data_value(key)
	return 0


func _get_resource_sum(keys: Array[String]) -> int:
	var total := 0
	for resource_key in keys:
		total += _get_resource(resource_key)
	return total


func _politician_power_sum(personality: int) -> int:
	var ws: WorldState = world
	if ws == null:
		return 0
	var total := 0
	for politician in ws.politicians:
		if politician != null and politician.trait_personality == personality:
			total += politician.power
	return total


func _politician_group_power_sum(personalities_csv: String) -> int:
	var total := 0
	for part in personalities_csv.split(",", false):
		if part.is_valid_int():
			total += _politician_power_sum(int(part))
	return total


func _get_war_field(war_index: int, field_name: String) -> int:
	var ws: WorldState = world
	if ws == null or war_index < 0 or war_index >= ws.wars.size() or ws.wars[war_index] == null:
		return 0
	var war: WarData = ws.wars[war_index]
	match field_name.to_lower():
		"infl1": return war.infl1
		"infl2": return war.infl2
		"usa_side", "usa_place": return war.usa_side
		"ussr_side", "ussr_place": return war.ussr_side
		"fortnight_elapsed", "fortnight_go": return war.fortnight_elapsed
		_:
			push_warning("EventEngine: 不支持的战争字段 %s" % field_name)
			return 0


## 获取指定国家的资源值（用于 RESOURCE_AT_LEAST_FOR 条件）
func _get_resource_for(target_tag: String, key: String) -> int:
	var ws: WorldState = world
	if ws != null:
		return ws.get_data_value_for_country(target_tag, key)
	return 0


func _is_modifier_active(key: String) -> bool:
	var idx := int(key) if key.is_valid_int() else -1
	var ws: WorldState = world
	if ws == null:
		return false
	if idx >= 0 and idx < ws.modifiers.size():
		return ws.modifiers[idx].is_active
	return false


func _get_empire_relation(empire_index: int) -> int:
	var ws: WorldState = world
	if ws == null:
		return 0
	if empire_index < 0 or empire_index >= ws.empires.size(): return 0
	return ws.empires[empire_index].relations


## 执政联盟支持率（原版 doneventscript/Event7 等 Awake 的 summa_3_2）。
## 仅 party_system>7（data.party_system>7）时计算：执政党(1)+盟友席位数 ×100 / 五党总席位数；否则 0。
func _coalition_support_percent() -> int:
	var ws: WorldState = world
	if ws == null or ws.factions.size() < 5:
		return 0
	if ws.size() <= 15 or ws.party_system <= 7:
		return 0
	var num := ws.factions[1].support
	for i in ws.factions.size():
		if i != 1 and ws.factions[i].is_ally and ws.factions[i].is_enabled:
			num += ws.factions[i].support
	var total := 0
	for i in 5:
		total += ws.factions[i].support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total


func _is_faction_leading(faction_index: int) -> bool:
	# 与 GameManager.is_faction_leading 共用（FAC-03）
	return gm != null and gm.is_faction_leading(faction_index)


func _country_has_tag(target: String, tag: String) -> bool:
	var country := _resolve_country(target)
	return country != null and country.has_tag(tag)


## Event697.cs:26-33 的 num 计数：统计原版序号列表中 IsSocialism(true) 的国家数。
func _socialist_count(legacy_indices: Array[String]) -> int:
	var ws: WorldState = world
	if ws == null:
		return 0
	var count := 0
	for token in legacy_indices:
		if not token.is_valid_int():
			continue
		var country := ws.get_country_by_legacy_index(int(token))
		if country != null and ws.is_socialism(country, true):
			count += 1
	return count


func _get_country_field(target: String, field_name: String) -> int:
	var country := _resolve_country(target)
	if country == null:
		return 0
	match field_name.to_lower():
		"government", "gosstroy": return country.government
		"sub_government", "subgosstroy": return country.sub_government
		"stability": return country.stability
		"social_stability": return country.social_stability
		"development": return country.development
		"level_of_development": return country.level_of_development
		"level_of_instability": return country.level_of_instability
		"special": return country.special
		"special_ending": return country.special_ending
		"sov_power": return country.sov_power
		"usa_power": return country.usa_power
		"prc_power": return country.prc_power
		"fre_power": return country.fre_power
		"puppet_of": return country.puppet_of
		"cw", "civil_war": return 1 if country.内战中 else 0
		"econ": return 1 if country.has_tag("econ") else 0
		"perevorot": return 1 if country.政变中 else 0
		"based": return 1 if country.有驻军基地 else 0
		"stab": return country.stab
		_:
			push_warning("EventEngine: 不支持的国家字段 %s" % field_name)
			return 0


func _is_tech_unlocked(tech_index: int) -> bool:
	var ws: WorldState = world
	return (ws != null and ws.techs != null and tech_index >= 0
			and tech_index < ws.techs.unlocked.size() and ws.techs.unlocked[tech_index])


func _is_war_active(war_id: int) -> bool:
	var ws: WorldState = world
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return false
	var war := ws.wars[war_id]
	return war != null and war.is_going


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
	var ty := int(parts[0])
	var tm := int(parts[1])
	var td := int(parts[2]) if parts.size() >= 3 else 1
	var cur: GameDate = world.date
	var target_value := ty * 10000 + tm * 100 + td
	var current_value := cur.to_int()
	return current_value <= target_value if before else current_value >= target_value


## 按标签解析国家。通过 WorldState.get_country_by_tag() 动态查找。
func _resolve_country(tag: String) -> CountryData:
	var ws: WorldState = world
	if ws == null: return null
	if tag == "ROOT" or tag == "":
		return ws.get_player_country()
	if tag.is_valid_int():
		return ws.get_country_by_legacy_index(int(tag))
	return ws.get_country_by_tag(tag)


# ========================================================================
# 内部辅助 — 效果执行
# ========================================================================

func _add_resource(key: String, delta: int) -> void:
	var ws: WorldState = world
	if ws != null:
		ws.add_data_value(key, delta)

func _set_resource(key: String, value: int) -> void:
	var ws: WorldState = world
	if ws != null:
		ws.set_data_value(key, value)

func _set_alliance(target_tag: String, alliance: String, join: bool) -> void:
	var country: CountryData = _resolve_country(target_tag)
	if country == null: return
	country.set_tag(alliance.to_lower(), join)

func _join_all_alliances(target_tag: String) -> void:
	var target: CountryData = _resolve_country(target_tag)
	var player: CountryData = world.get_player_country()
	if target == null or player == null: return
	for tag_key in player.tags:
		if player.tags[tag_key]:
			target.set_tag(tag_key, true)

const ECONOMIC_TAGS: Array[String] = ["sev", "econ", "asean", "fez", "eu", "soc_eu", "oil"]

func _join_economic_alliance(target_tag: String) -> void:
	var target: CountryData = _resolve_country(target_tag)
	var player: CountryData = world.get_player_country()
	if target == null or player == null: return
	for etag in ECONOMIC_TAGS:
		if player.has_tag(etag):
			target.set_tag(etag, true)

func _set_country_var(target_tag: String, var_name: String, var_value: int) -> void:
	var country: CountryData = _resolve_country(target_tag)
	if country == null: return
	match var_name:
		"government", "gosstroy": country.government = var_value
		"sub_government", "subgosstroy": country.sub_government = var_value
		"stability": country.stability = var_value
		"social_stability": country.social_stability = var_value
		"development": country.development = var_value
		"special": country.special = var_value
		"special_ending": country.special_ending = var_value
		"cw", "civil_war": country.内战中 = var_value != 0
		"perevorot": country.政变中 = var_value != 0
		"based": country.有驻军基地 = var_value != 0

func _add_country_var(target_tag: String, var_name: String, delta: int) -> void:
	var country: CountryData = _resolve_country(target_tag)
	if country == null: return
	match var_name:
		"stability": country.stability += delta
		"social_stability": country.social_stability += delta
		"development": country.development += delta
		"special": country.special += delta
		"special_ending": country.special_ending += delta


func _add_politician_loyalty(personalities: Array[int], delta: int) -> void:
	var ws: WorldState = world
	if ws == null:
		return
	for politician in ws.politicians:
		if politician == null:
			continue
		if personalities.is_empty() or personalities.has(politician.trait_personality):
			politician.loyalty += delta

func _add_empire_relation(empire_index: int, delta: int) -> void:
	var ws: WorldState = world
	if empire_index < 0 or empire_index >= ws.empires.size(): return
	ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _set_empire_relation(empire_index: int, value: int) -> void:
	var ws: WorldState = world
	if empire_index < 0 or empire_index >= ws.empires.size(): return
	ws.empires[empire_index].relations = clampi(value, 0, 1000)

func _add_empire_power(empire_index: int, delta: int) -> void:
	var ws: WorldState = world
	if empire_index < 0 or empire_index >= ws.empires.size(): return
	ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)

func _add_faction_support(faction_index: int, delta: int) -> void:
	var ws: WorldState = world
	if faction_index < 0 or faction_index >= ws.factions.size(): return
	ws.factions[faction_index].support += delta

func _set_modifier(key: String, active: bool) -> void:
	var ws: WorldState = world
	var idx := int(key) if key.is_valid_int() else -1
	if idx >= 0 and idx < ws.modifiers.size():
		ws.modifiers[idx].is_active = active

func _set_modifier_available(key: String, available: bool) -> void:
	var ws: WorldState = world
	var idx := int(key) if key.is_valid_int() else -1
	if idx >= 0 and idx < ws.modifiers.size():
		ws.modifiers[idx].is_available = available


## 写入 WorldState，供存档
func export_runtime_to_world(ws: WorldState) -> void:
	if ws == null:
		return
	ws.event_pending_id = pending_event_id
	ws.event_pending_deadline = _pending_deadline
	ws.event_chain_queue = _event_queue.duplicate()
	ws.event_pending_queue = _pending_queue.duplicate()


## 从存档恢复 pending / 链队列
func import_runtime_from_world(ws: WorldState) -> void:
	if ws == null:
		return
	world = ws
	_rebuild_active_events()
	pending_event_id = ws.event_pending_id
	_pending_deadline = ws.event_pending_deadline
	_event_queue.clear()
	for eid in ws.event_chain_queue:
		if str(eid) != "":
			_event_queue.append(str(eid))
	_pending_queue.clear()
	for eid in ws.event_pending_queue:
		if str(eid) != "":
			_pending_queue.append(str(eid))
	if pending_event_id != "":
		var edef := _events.get(pending_event_id) as EventDef
		# 0.1.x 旧存档把截止值写成 YYYYMMDD，且跨月加法可能产生非法日期。
		# 无法精确还原剩余天数时，从读档日重建一个完整通知期。
		if _pending_deadline >= 10000000:
			var grace_days := edef.notification_days if edef != null else PENDING_GRACE_DAYS
			_pending_deadline = ws.date.tick_count + grace_days
		var title := edef.title if edef else pending_event_id
		event_notification.emit(pending_event_id, title)

