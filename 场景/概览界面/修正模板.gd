extends Control

## 单条修正展示（激活/未激活均可）。由概览.gd 实例化并 setup。

@onready var _icon: TextureRect = $图标
@onready var _title: Label = $名称
@onready var _body: RichTextLabel = $效果


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
		_body = find_child("效果", true, false) as RichTextLabel
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
		_body.bbcode_enabled = true
		_body.scroll_active = false
		_body.fit_content = true
		# ModifierCatalog 底稿沿用原版 <color=...>，RichTextLabel 只认 [color=...]；
		# 统一经 BbcTooltip.unity_color_to_bbcode 转换后再 parse_bbcode。
		_body.parse_bbcode(BbcTooltip.unity_color_to_bbcode(body) if is_active else "未生效")
	if is_active:
		tooltip_text = "%s\n%s" % [title, _strip_bbcode(body)]
	else:
		# 原版 ModifyButtonScript.cs:629：未激活只显示 new_texts[229]「未生效」。
		tooltip_text = "未生效"
	set_meta("modifier_id", id)
	set_meta("is_active", is_active)
	# 无专用 off 图时用整体变暗区分
	modulate = Color(1, 1, 1, 1) if is_active else Color(0.75, 0.75, 0.75, 0.85)
	_fit_body()
	call_deferred("_fit_body")


## 内置 tooltip 不解析 BBCode；显示前去掉 <...> 标签，避免出现原始标记。
func _strip_bbcode(s: String) -> String:
	var re := RegEx.new()
	re.compile("</?color(=[^>]*)?>")
	return re.sub(s, "", true)


## 效果文本可能多行；让条目高度随 RichTextLabel 最小高度增长，避免 VBox 裁剪。
func _fit_body() -> void:
	if _body == null:
		return
	var needed := int(_body.get_minimum_size().y) + 44
	custom_minimum_size.y = maxi(100, needed)
