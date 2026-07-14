extends Label

@export var tooltip_image: Texture2D
func _make_custom_tooltip(for_text):
	var root = PanelContainer.new()   # 垂直自动排列
	var hbox = VBoxContainer.new()
	var tex_rect = TextureRect.new()
	tex_rect.texture = tooltip_image
	tex_rect.size = tooltip_image.get_size()
	var label = Label.new()
	label.text = for_text
	hbox.add_child(tex_rect)
	hbox.add_child(label)
	root.add_child(hbox)
	return root
