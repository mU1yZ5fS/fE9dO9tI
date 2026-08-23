class_name UISettings
extends RefCounted

## 全局 UI 字体缩放工具。
## 运行时把指定 Control 子树里各控件的主题字号按倍率重新覆盖，
## 并使用 meta 记住原始大小，因此重复应用不会叠加放大。

## 各控件类型对应的字号主题项。
const FONT_SIZE_ITEMS := {
	"Label": ["font_size"],
	"Button": ["font_size"],
	"CheckButton": ["font_size"],
	"LineEdit": ["font_size"],
	"SpinBox": ["font_size"],
	"RichTextLabel": ["normal_font_size", "bold_font_size", "italics_font_size", "mono_font_size"],
}


static func apply_font_scale(root: Node, scale: float) -> void:
	if root == null:
		return
	if scale <= 0.0:
		scale = 1.0
	if root is Control:
		_apply_control(root, scale)
	for child in root.find_children("*", "Control", true, false):
		_apply_control(child, scale)


static func _apply_control(ctrl: Control, scale: float) -> void:
	var items: Array = FONT_SIZE_ITEMS.get(ctrl.get_class(), ["font_size"])
	for item in items:
		var meta_key: String = "_ui_orig_size_" + String(item)
		var orig := -1
		if ctrl.has_meta(meta_key):
			orig = int(ctrl.get_meta(meta_key))
		else:
			orig = ctrl.get_theme_font_size(item)
			if orig <= 0:
				continue
			ctrl.set_meta(meta_key, orig)
		var new_size := maxi(1, roundi(float(orig) * scale))
		ctrl.add_theme_font_size_override(item, new_size)
