extends Control

## 战争界面主逻辑。
## 布局以 战争.tscn 为准；列表滚动容器运行时补齐。
## 刷新列表时用 queue_free + call_deferred，避免按钮回调里 free 触发 locked object。

const ENTRY := preload("res://场景/战争界面/战争条目.tscn")

var _list: VBoxContainer
var _refresh_list_queued: bool = false


func _ready() -> void:
	_ensure_list_host()
	if GameManager:
		UISettings.apply_font_scale(self, GameManager.ui_font_scale)
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
		# 条目宽约 1186：用中心锚点水平居中于视口，适配任意宽度
		const ENTRY_W := 1186.0
		scroll.anchor_left = 0.5
		scroll.anchor_right = 0.5
		scroll.offset_left = -ENTRY_W * 0.5
		scroll.offset_right = ENTRY_W * 0.5
		scroll.offset_top = 176.0
		scroll.offset_bottom = 760.0
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		add_child(scroll)
	else:
		# 已存在时也强制中心锚点居中，避免旧 offset 偏左
		const ENTRY_W2 := 1186.0
		scroll.anchor_left = 0.5
		scroll.anchor_right = 0.5
		scroll.offset_left = -ENTRY_W2 * 0.5
		scroll.offset_right = ENTRY_W2 * 0.5
	_list = scroll.get_node_or_null("战争列表") as VBoxContainer
	if _list == null:
		_list = VBoxContainer.new()
		_list.name = "战争列表"
		_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_list.alignment = BoxContainer.ALIGNMENT_CENTER
		_list.add_theme_constant_override("separation", 8)
		scroll.add_child(_list)
	else:
		_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_list.alignment = BoxContainer.ALIGNMENT_CENTER



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
		# 条目视觉宽 1186；取消宽锚点，避免在列表里被拉偏
		item.set_anchors_preset(Control.PRESET_TOP_LEFT)
		item.anchor_right = 0.0
		item.anchor_bottom = 0.0
		item.offset_left = 0.0
		item.offset_top = 0.0
		item.offset_right = 1186.0
		item.offset_bottom = 110.0
		item.custom_minimum_size = Vector2(1186, 110)
		item.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_list.add_child(item)
		if item.has_method("setup"):
			item.setup(i, war)
		if item.has_signal("action_pressed"):
			item.action_pressed.connect(_on_entry_action)
	if not any:
		var empty := Label.new()
		empty.text = "当前无进行中的代理战争（可用下方调试开战）"
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_list.add_child(empty)


func _on_entry_action(war_id: int, action_id: int) -> void:
	if GameManager == null:
		return
	# 只改数据；列表在 stats_changed → deferred rebuild
	GameManager.intervene_war(war_id, action_id)


func _on_debug_start(war_id: int) -> void:
	if GameManager:
		GameManager.debug_start_war(war_id)
