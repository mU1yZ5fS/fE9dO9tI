extends Control

## 单条修正展示（激活/未激活均可）。由概览.gd 实例化并 setup。

@onready var _icon: TextureRect = $图标
@onready var _title: Label = $名称
@onready var _body: Label = $效果


func setup(
	id: int,
	title: String,
	body: String,
	icon: Texture2D = null,
	is_active: bool = true
) -> void:
	if _icon == null:
		_icon = find_child("图标", true, false) as TextureRect
	if _title == null:
		_title = find_child("名称", true, false) as Label
	if _body == null:
		_body = find_child("效果", true, false) as Label
	if _icon:
		if icon != null:
			_icon.texture = icon
			_icon.visible = true
		else:
			_icon.texture = null
			_icon.visible = false
	if _title:
		_title.text = title
	if _body:
		# 未激活时效果区标明状态，避免与激活条混淆
		if is_active:
			_body.text = body
		else:
			_body.text = "未激活\n" + body
	var state := "激活" if is_active else "未激活"
	tooltip_text = "[%s] %s\n%s" % [state, title, body]
	set_meta("modifier_id", id)
	set_meta("is_active", is_active)
	# 无专用 off 图时用整体变暗区分
	modulate = Color(1, 1, 1, 1) if is_active else Color(0.75, 0.75, 0.75, 0.85)
