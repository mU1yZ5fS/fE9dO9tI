extends PanelContainer

## 成就解锁右下角弹窗（子场景，由 成就解锁管理器 动态实例化）。
## 复用 资产/UI/成就/ui_icon_frame.png 作为长方形底板。
## 展示后淡入+回弹，停留几秒再淡出并自动释放。

const DEFAULT_ICON := preload("res://资产/UI/战争/圆圈.png")
const COLOR_TITLE_GREEN := Color(0.1, 0.55, 0.2, 1)

@onready var _icon: TextureRect = $布局/图标
@onready var _title: Label = $布局/文本/标题
@onready var _desc: Label = $布局/文本/描述


func _ready() -> void:
	visible = false
	modulate = Color(1, 1, 1, 0)
	_title.add_theme_color_override("font_color", COLOR_TITLE_GREEN)


func show_toast(number: int, title: String, desc: String) -> void:
	_title.text = "成就解锁：%s" % title
	_desc.text = desc
	var tex: Texture2D = load(AchievementCatalog.icon_path(number)) as Texture2D
	_icon.texture = tex if tex != null else DEFAULT_ICON

	visible = true
	modulate = Color(1, 1, 1, 0)
	scale = Vector2(0.92, 0.92)

	# 等一帧让布局算出 size 后再设置缩放中心
	await get_tree().process_frame
	pivot_offset = size / 2.0

	var tw := create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.28) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2.ONE, 0.34) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(2.8)
	tw.tween_property(self, "modulate:a", 0.0, 0.45) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void: queue_free())
