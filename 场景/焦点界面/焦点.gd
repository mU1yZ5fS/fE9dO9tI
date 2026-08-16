extends Control

## 焦点界面 — 原版 FocusScene.unity 的 Godot 等价（只读查看）。
## 颜色语义对齐 FocusButtoNScript.ChangeCondition；图标按原版倒序编号加载。
## 布局规范：滚动容器/网格/状态/切换按钮均在 焦点.tscn；
## 条目为 焦点条目.tscn 场景实例、行尾空位为 焦点占位.tscn（对齐战争条目模式）。
## 原版有 Exit(0) 美国 / Exit(1) 苏联切换；美国 active_tree 原版未设置，
## Godot 显示空态提示（原版切过去会 KeyNotFound，本项目不做崩溃复刻）。

const DIPLOMACY_SCENE := "uid://vq6jexkk5tru"
const ENTRY := preload("res://场景/焦点界面/焦点条目.tscn")
const PAD := preload("res://场景/焦点界面/焦点占位.tscn")

const COLUMNS := 4

var _view_country: int = 1
var _refresh_queued: bool = false


func _ready() -> void:
	if GameManager:
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_on_stats):
			GameManager.stats_changed.connect(_on_stats)
		if not GameManager.world_state_loaded.is_connected(_on_world_loaded):
			GameManager.world_state_loaded.connect(_on_world_loaded)
	_rebuild()


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
	var grid := get_node_or_null("焦点滚动/焦点网格") as GridContainer
	if grid == null or not is_instance_valid(grid):
		return
	for c in grid.get_children():
		grid.remove_child(c)
		c.queue_free()
	var status := get_node_or_null("状态") as Label
	if GameManager == null or GameManager.world == null:
		return
	FocusSystem.repaint_blocked()
	var ws: WorldState = GameManager.world
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
	var cumulative := 0
	for layer: Array in tree.layers:
		for j in layer.size():
			var foc: FocusDef = layer[j]
			if foc != null:
				# 原版 FocusesScript.CreateCountryFocuses 的图标编号：
				# num = focuses.Length - 1 - j（每层倒序填入全局数组）
				var num := cumulative + layer.size() - 1 - j
				var item := ENTRY.instantiate() as Button
				grid.add_child(item)
				if item.has_method("setup"):
					item.setup(foc, num)
		cumulative += layer.size()
		for i in range(COLUMNS - layer.size()):
			grid.add_child(PAD.instantiate())


func _on_返回_pressed() -> void:
	音频总管.play_button_click_sound()
	get_tree().change_scene_to_file(DIPLOMACY_SCENE)


func _on_美国_pressed() -> void:
	_view_country = 0
	_rebuild()


func _on_苏联_pressed() -> void:
	_view_country = 1
	_rebuild()
