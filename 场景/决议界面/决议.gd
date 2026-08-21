extends Control

## 决议界面 — 原版 Decisions.unity（FocusesScript.notFocuses=1 分支）的 Godot 等价。
## 列表语义对齐 FocusesScript.CreateDecisions：
##   ready → unready → done 排序；dlc[version]==false 不显示；
## 条目点击对齐 DecisionButtonScript.OnMouseDown：条件满足才执行。
## 布局规范：滚动容器/列表/空提示均在 决议.tscn；本脚本只做数据绑定，
## 条目为 决议条目.tscn 场景实例（对齐战争条目模式）。

const DIPLOMACY_SCENE := "uid://vq6jexkk5tru"
const ENTRY := preload("res://场景/决议界面/决议条目.tscn")
const ENTRY_W := 1068.0
const ENTRY_H := 236.0

var _refresh_queued: bool = false


func _ready() -> void:
	if GameManager:
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_on_stats):
			GameManager.stats_changed.connect(_on_stats)
		if not GameManager.world_state_loaded.is_connected(_on_world_loaded):
			GameManager.world_state_loaded.connect(_on_world_loaded)
	_rebuild_list()


func _on_stats() -> void:
	_request_refresh()


func _on_world_loaded() -> void:
	_request_refresh()


func _request_refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_rebuild_list")


func _rebuild_list() -> void:
	_refresh_queued = false
	var list := get_node_or_null("决议滚动/决议列表") as VBoxContainer
	var empty := get_node_or_null("决议滚动/空提示") as Label
	if list == null or not is_instance_valid(list):
		return
	list.alignment = BoxContainer.ALIGNMENT_CENTER
	for c in list.get_children():
		list.remove_child(c)
		c.queue_free()
	if GameManager == null or GameManager.world == null:
		return
	var defs := DecisionSystem.ordered_defs()
	if empty != null:
		empty.visible = defs.is_empty()
	for def: DecisionDef in defs:
		var item := ENTRY.instantiate() as Control
		# 条目视觉宽 1068 高 236；取消宽锚点，避免在 VBox 里被拉偏
		item.set_anchors_preset(Control.PRESET_TOP_LEFT)
		item.anchor_right = 0.0
		item.anchor_bottom = 0.0
		item.offset_left = 0.0
		item.offset_top = 0.0
		item.offset_right = ENTRY_W
		item.offset_bottom = ENTRY_H
		item.custom_minimum_size = Vector2(ENTRY_W, ENTRY_H)
		item.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		list.add_child(item)
		if item.has_method("setup"):
			item.setup(def)
		if item.has_signal("exec_requested"):
			item.exec_requested.connect(_on_entry_exec)


func _on_entry_exec(decision_id: int) -> void:
	DecisionSystem.execute(decision_id)
	# stats_changed → deferred rebuild；这里主动排一次刷新兜底
	_request_refresh()


func _on_返回_pressed() -> void:
	get_tree().change_scene_to_file(DIPLOMACY_SCENE)
