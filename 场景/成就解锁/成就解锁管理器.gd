extends Node

## 成就解锁弹窗全局管理器（Autoload）。
## 监听 Achievements.achievement_unlocked，在右下角弹出 成就解锁弹窗.tscn。
## 弹窗复用 资产/UI/成就 的现有贴图；最多同时保留 3 条，防止刷屏。

const TOAST_SCENE := preload("res://场景/成就解锁/成就解锁弹窗.tscn")

var _layer: CanvasLayer = null
var _box: VBoxContainer = null


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.name = "成就解锁弹窗层"
	_layer.layer = 100
	add_child(_layer)

	var root := Control.new()
	root.name = "成就解锁弹窗根"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(root)

	_box = VBoxContainer.new()
	_box.name = "成就解锁队列"
	_box.anchor_left = 1.0
	_box.anchor_top = 1.0
	_box.anchor_right = 1.0
	_box.anchor_bottom = 1.0
	_box.offset_left = -484.0
	_box.offset_top = -420.0
	_box.offset_right = -24.0
	_box.offset_bottom = -24.0
	_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_box.alignment = BoxContainer.ALIGNMENT_END
	_box.add_theme_constant_override("separation", 12)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_box)

	if Achievements:
		Achievements.achievement_unlocked.connect(_on_achievement_unlocked)


func _on_achievement_unlocked(number: int) -> void:
	var item := AchievementCatalog.find(number)
	var title: String = str(item.get("title", "ACH_%d" % number))
	var desc: String = str(item.get("desc", ""))
	var toast := TOAST_SCENE.instantiate()
	_box.add_child(toast)
	toast.show_toast(number, title, desc)

	# 最多保留 3 条，避免连续解锁时堆满屏幕。
	while _box.get_child_count() > 3:
		var oldest := _box.get_child(0)
		_box.remove_child(oldest)
		oldest.queue_free()
