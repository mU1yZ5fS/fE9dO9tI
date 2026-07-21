extends Control

## 战争界面主逻辑。
## 布局以 战争.tscn 为准；列表滚动容器运行时补齐。
## 刷新列表时用 queue_free + call_deferred，避免按钮回调里 free 触发 locked object。

const ENTRY := preload("res://场景/战争界面/战争条目.tscn")

var _list: VBoxContainer
var _debug_box: HBoxContainer
var _refresh_list_queued: bool = false


func _ready() -> void:
	_ensure_list_host()
	_ensure_debug_bar()
	if GameManager:
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_on_stats):
			GameManager.stats_changed.connect(_on_stats)
		if not GameManager.date_changed.is_connected(_on_date):
			GameManager.date_changed.connect(_on_date)
		if not GameManager.world_state_loaded.is_connected(_on_world_loaded):
			GameManager.world_state_loaded.connect(_on_world_loaded)
	_refresh_intervention()
	_rebuild_list()


func _on_date(_d: GameDate) -> void:
	_request_full_refresh()


func _on_stats() -> void:
	_request_full_refresh()


func _on_world_loaded() -> void:
	_request_full_refresh()


func _request_full_refresh() -> void:
	_refresh_intervention()
	# 列表重建推迟到帧末，避免从条目按钮信号栈里 free 自身
	if _refresh_list_queued:
		return
	_refresh_list_queued = true
	call_deferred("_rebuild_list")


func _ensure_list_host() -> void:
	var scroll := get_node_or_null("战争列表滚动") as ScrollContainer
	if scroll == null:
		scroll = ScrollContainer.new()
		scroll.name = "战争列表滚动"
		scroll.offset_left = 48.0
		scroll.offset_top = 176.0
		scroll.offset_right = 1872.0
		scroll.offset_bottom = 760.0
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		add_child(scroll)
	_list = scroll.get_node_or_null("战争列表") as VBoxContainer
	if _list == null:
		_list = VBoxContainer.new()
		_list.name = "战争列表"
		_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_list.add_theme_constant_override("separation", 8)
		scroll.add_child(_list)


func _ensure_debug_bar() -> void:
	_debug_box = get_node_or_null("调试开战") as HBoxContainer
	if _debug_box != null:
		return
	_debug_box = HBoxContainer.new()
	_debug_box.name = "调试开战"
	_debug_box.offset_left = 280.0
	_debug_box.offset_top = 980.0
	_debug_box.offset_right = 1800.0
	_debug_box.offset_bottom = 1040.0
	_debug_box.add_theme_constant_override("separation", 6)
	add_child(_debug_box)
	var tip := Label.new()
	tip.text = "调试开战:"
	_debug_box.add_child(tip)
	for id in WarCatalog.all_ids():
		var def := WarCatalog.get_def(id)
		var b := Button.new()
		b.text = def.name_zh if def else str(id)
		b.pressed.connect(_on_debug_start.bind(id))
		_debug_box.add_child(b)


func _refresh_intervention() -> void:
	var lbl := find_child("军事介入点数值", true, false)
	if lbl is Label and GameManager:
		lbl.text = GameManager.get_mil_intervention_display()


func _rebuild_list() -> void:
	_refresh_list_queued = false
	if _list == null or not is_instance_valid(_list):
		return
	for c in _list.get_children():
		_list.remove_child(c)
		c.queue_free()
	if GameManager == null or GameManager.world == null:
		return
	var any := false
	for i in GameManager.world.wars.size():
		var war: WarData = GameManager.world.wars[i]
		if war == null or not war.is_going:
			continue
		any = true
		var item := ENTRY.instantiate() as Control
		item.custom_minimum_size = Vector2(1186, 110)
		_list.add_child(item)
		if item.has_method("setup"):
			item.setup(i, war)
		if item.has_signal("action_pressed"):
			item.action_pressed.connect(_on_entry_action)
	if not any:
		var empty := Label.new()
		empty.text = "当前无进行中的代理战争（可用下方调试开战）"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_list.add_child(empty)


func _on_entry_action(war_id: int, action_id: int) -> void:
	if GameManager == null:
		return
	# 只改数据；列表在 stats_changed → deferred rebuild
	GameManager.intervene_war(war_id, action_id)


func _on_debug_start(war_id: int) -> void:
	音频总管.play_button_click_sound()
	if GameManager:
		GameManager.debug_start_war(war_id)
