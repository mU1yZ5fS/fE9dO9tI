extends Control

## 单条激活修正展示。由概览.gd 实例化并 setup。

@onready var _icon: TextureRect = $图标
@onready var _title: Label = $名称
@onready var _body: Label = $效果


func setup(id: int, title: String, body: String, icon: Texture2D = null) -> void:
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
		_body.text = body
	tooltip_text = "%s\n%s" % [title, body]
	set_meta("modifier_id", id)
