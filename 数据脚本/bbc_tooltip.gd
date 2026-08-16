## 悬浮提示容器：把 Unity TextMesh 的 <color=...> 标签转换为 Godot BBCode [color=...]。
## 文档出处：本地 Godot 4.7 文档
##   gdd_0413_BBCode_in_RichTextLabel.md —— RichTextLabel 仅识别方括号标签、支持命名颜色
##   gdd_0565_Control.md:1311 —— tooltip_text / _make_custom_tooltip
##   gdd_0719_RichTextLabel.md:29-45 —— autowrap_mode / bbcode_enabled / fit_content / scroll_active
class_name BbcTooltip
extends Control

## 全游戏统一字体（经济界面各 Label/Button 均使用 方正跃进简体.ttf，悬浮提示必须一致）
const 统一字体: Font = preload("res://资产/字体/方正跃进简体.ttf")


static func unity_color_to_bbcode(text: String) -> String:
	var out := text.replace("</color>", "[/color]")
	# 原版 <color=green> 需要把结尾的 > 一并转成 ]，否则会生成非法的 [color=green>，
	# BBCode 解析器会吞掉整段彩色文字（正是“只显示零散白字”的原因）。
	while out.find("<color=") != -1:
		var start: int = out.find("<color=")
		var end: int = out.find(">", start)
		if end == -1:
			break
		var color_name: String = out.substr(start + 7, end - start - 7)
		out = out.substr(0, start) + "[color=" + color_name + "]" + out.substr(end + 1)
	return out


## 给任意无脚本的 Control 挂上本提示脚本（一次性，重复调用无副作用）。
## Label 默认 mouse_filter = MOUSE_FILTER_IGNORE（gdd_0638_Label.md 属性表），
## 按 tooltip_text 文档要求必须不是 IGNORE 才会显示悬浮提示，这里统一改成 STOP。
static func attach(ctrl: Control) -> void:
	if ctrl == null or ctrl.get_script() != null:
		return
	if ctrl.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		ctrl.mouse_filter = Control.MOUSE_FILTER_STOP
	ctrl.set_script(load("res://数据脚本/bbc_tooltip.gd"))


## 主人要求：提示文案不要空格。显示时直接去掉所有空格（保留换行），
## 只影响悬浮提示的显示，不改动经济.gd 里保存的原版文案。
func _strip_all_spaces(text: String) -> String:
	return text.replace(" ", "")


## 去掉 BBCode 标签，再按 26 个字形/行估算（460px 宽、18 号字下的近似折行）。
func _strip_bbcode_tags(text: String) -> String:
	var out := text
	while out.find("[") != -1:
		var start: int = out.find("[")
		var end: int = out.find("]", start)
		if end == -1:
			break
		out = out.substr(0, start) + out.substr(end + 1)
	return out


## 按内容估算最小高度，保证弹窗前就给足高度，不靠 fit_content 事后测量（避免只显示前半段）。
func _estimate_min_height(display_text: String) -> float:
	var plain := _strip_bbcode_tags(display_text)
	var newline_count: int = plain.count("\n")
	var units: int = plain.length() - newline_count
	var wrapped_lines: int = int(ceilf(float(units) / 26.0))
	var total_lines: int = wrapped_lines + newline_count
	return maxf(60.0, float(total_lines) * 24.0 + 16.0)


## 静态工厂：给「自身已有脚本」的控件复用本提示样式（条目类 Button 等）。
## 用法：在控件脚本里实现
##   func _make_custom_tooltip(for_text: String) -> Control:
##       return BbcTooltip.build_tooltip(for_text)
## attach() 只适用于无脚本控件（set_script 会覆盖现有脚本，不可用于条目）。
static func build_tooltip(for_text: String) -> Control:
	var inst := BbcTooltip.new()
	return inst._make_custom_tooltip(for_text)


func _make_custom_tooltip(for_text: String) -> Control:
	if for_text.is_empty():
		return null
	var display_text := _strip_all_spaces(unity_color_to_bbcode(for_text))
	var min_height: float = _estimate_min_height(display_text)
	var panel := PanelContainer.new()
	# 自绘深灰底：不依赖项目 TooltipPanel 主题颜色，白字永远有对比度
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.07, 0.97)
	style.set_corner_radius_all(4)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(240, min_height)
	var rtl := RichTextLabel.new()
	rtl.bbcode_enabled = true
	rtl.fit_content = true
	rtl.scroll_active = false
	# RichTextLabel 默认 clip_contents=true，尺寸没算对时会把字裁掉；关掉兜底
	rtl.clip_contents = false
	rtl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rtl.custom_maximum_size = Vector2(460, -1)  # y=-1 表示高度无上限（0 会把高度压成 0）
	# 弹窗前就按内容给足最小尺寸，避免默认 PopupPanel 缩成小条或只显示一半
	rtl.custom_minimum_size = Vector2(240, min_height)
	# RichTextLabel 字体主题项 normal_font（gdd_0719_RichTextLabel.md:169/1395）
	rtl.add_theme_font_override("normal_font", 统一字体)
	rtl.add_theme_font_size_override("normal_font_size", 18)
	# 深灰底上显式用白字
	rtl.add_theme_color_override("default_color", Color(1, 1, 1))
	rtl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_child(rtl)
	rtl.text = display_text
	return panel
