extends Control

## 焦点界面 — 原版 FocusScene.unity 的 Godot 等价（只读查看）。
## 对齐 FocusButtoNScript.ChangeCondition 的颜色语义：
##   blocked → 灰；overtime>=time → 红（原版 country==1 苏联完成色）；
##   overtime>0 → 黄（进行中）；其余白。
## 原版有 Exit(0) 美国 / Exit(1) 苏联切换；美国 active_tree 原版未设置，
## Godot 显示空态提示（原版切过去会 KeyNotFound，本项目不做崩溃复刻）。

const DIPLOMACY_SCENE := "uid://vq6jexkk5tru"

const COLUMNS := 4

var _grid: GridContainer
var _view_country: int = 1
var _refresh_queued: bool = false


func _ready() -> void:
	_ensure_grid_host()
	if GameManager:
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_on_stats):
			GameManager.stats_changed.connect(_on_stats)
		if not GameManager.world_state_loaded.is_connected(_on_world_loaded):
			GameManager.world_state_loaded.connect(_on_world_loaded)
	_rebuild()


func _ensure_grid_host() -> void:
	var scroll := get_node_or_null("焦点滚动") as ScrollContainer
	if scroll == null:
		scroll = ScrollContainer.new()
		scroll.name = "焦点滚动"
		scroll.anchor_left = 0.5
		scroll.anchor_right = 0.5
		scroll.offset_left = -460.0
		scroll.offset_right = 460.0
		scroll.offset_top = 150.0
		scroll.offset_bottom = 1040.0
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		add_child(scroll)
	_grid = scroll.get_node_or_null("焦点网格") as GridContainer
	if _grid == null:
		_grid = GridContainer.new()
		_grid.name = "焦点网格"
		_grid.columns = COLUMNS
		_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_grid.add_theme_constant_override("h_separation", 10)
		_grid.add_theme_constant_override("v_separation", 10)
		scroll.add_child(_grid)


func _on_stats() -> void:
	_request_refresh()


func _on_world_loaded() -> void:
	_request_refresh()


func _request_refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_rebuild")


func _rebuild() -> void:
	_refresh_queued = false
	if _grid == null or not is_instance_valid(_grid):
		return
	for c in _grid.get_children():
		_grid.remove_child(c)
		c.queue_free()
	var status := get_node_or_null("状态") as Label
	if GameManager == null or GameManager.world == null:
		return
	FocusSystem.repaint_blocked()
	var ws := GameManager.world
	if _view_country != 1:
		if status != null:
			status.text = "美国没有焦点树（原版 active_tree 未设置，只有苏联树）"
		return
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var empire: EmpireData = ws.empires[EmpireData.USSR]
	var tree := FocusCatalog.tree_for_empire(empire)
	if tree == null:
		return
	if status != null:
		var cur := "无"
		if empire.current_layer >= 0 and empire.current_layer < tree.layer_count() \
				and empire.current_focus >= 0 and empire.current_focus < tree.get_layer(empire.current_layer).size():
			var foc: FocusDef = tree.get_layer(empire.current_layer)[empire.current_focus]
			cur = "%s（第 %d/%d tick）" % [foc.title, foc.overtime, foc.time]
		status.text = "第 %d/%d 层 · 正在研究：%s" % [empire.current_layer + 1, tree.layer_count(), cur]
	for layer: Array in tree.layers:
		for foc: FocusDef in layer:
			if foc != null:
				_grid.add_child(_make_cell(foc))
		# 行尾补占位，保证每层独立成行
		for i in range(COLUMNS - layer.size()):
			var pad := Control.new()
			pad.custom_minimum_size = Vector2(210, 130)
			_grid.add_child(pad)


func _make_cell(foc: FocusDef) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(210, 130)
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.tooltip_text = foc.desc if foc.desc != "" else foc.title
	b.text = foc.title
	if foc.blocked:
		b.modulate = Color(0.42, 0.42, 0.42, 1)
	elif foc.overtime >= foc.time:
		b.modulate = Color(1.0, 0.51, 0.51, 1)   # 原版 country==1 完成红
	elif foc.overtime > 0:
		b.modulate = Color(0.95, 1.0, 0.41, 1)   # 原版进行中黄
	else:
		b.modulate = Color(1, 1, 1, 1)
	b.disabled = true  # 只读（原版焦点按钮点击仅用于 num<0 切换，非苏联树无需）
	return b


func _on_返回_pressed() -> void:
	音频总管.play_button_click_sound()
	get_tree().change_scene_to_file(DIPLOMACY_SCENE)


func _on_美国_pressed() -> void:
	_view_country = 0
	_rebuild()


func _on_苏联_pressed() -> void:
	_view_country = 1
	_rebuild()
