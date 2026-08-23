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
	return darken_bright_colors(out)


# ============================================================================
# 亮色统一压暗：Godot 命名色 green=(0,1,0)、yellow=(1,1,0) 饱和度极高，在白底上
# 近乎看不见 / 刺眼；原版 Unity 文本还残留大量 #FFFF00/#008000/#00A80B 亮绿亮黄。
# 这里在统一出口把“绿→darkgreen(#006400)、黄→darkgoldenrod(#B8860B)”一次性归一。
# 提示：渲染字体（方正跃进简体）不显示空格字形（ASCII 空格 advance≈0、U+3000 无轮廓），
# 且 Godot 4.7 的 [indent] BBCode 标签不被解析（会原样显示字面量）；
# 需要“空两格/字间距”效果时用无色全角字形占位，参考 事件.gd 的 INDENT_MARK 方案。
# ============================================================================
const COLOR_DARKEN_MAP := {
	"green": "darkgreen",
	"lime": "darkgreen",
	"yellow": "#b8860b",
	"gold": "#b8860b",
	"#00ff00": "darkgreen",
	"#008000": "darkgreen",
	"#00a80b": "darkgreen",
	"#ffff00": "#b8860b",
}

static var _color_darken_re: RegEx = null


## 把所有 [color=X] 的亮色标签替换为暗色档。输入应为 [color=...] 形态（统一转换后）。
## 未匹配的颜色（红/蓝/橙/暗色系等）原样保留。
static func darken_bright_colors(text: String) -> String:
	if text.is_empty() or text.find("[color=") == -1:
		return text
	if _color_darken_re == null:
		_color_darken_re = RegEx.new()
		_color_darken_re.compile("\\[color=([^\\]]+)\\]")
	var out := text
	for m in _color_darken_re.search_all(out):
		var col := String(m.get_string(1)).to_lower()
		if COLOR_DARKEN_MAP.has(col):
			out = out.replace(m.get_string(0), "[color=" + COLOR_DARKEN_MAP[col] + "]")
	return out


# ============================================================================
# 事件文本色彩还原：原版 C# 文本中的 <color> 片段在移植到 .tres/.gd 时被剥掉。
# 这里用从逆向源码生成的 event_color_fragments.json，把纯文本里对应的
# 人名/专名/引文片段重新包上颜色，再交给 unity_color_to_bbcode() 转 BBCode。
# ============================================================================
const EVENT_COLOR_FRAGMENTS_PATH := "res://资产/数据/event_color_fragments.json"

static var _event_color_fragments: Dictionary = {}
static var _event_color_fragments_loaded: bool = false


static func _load_event_color_fragments() -> Dictionary:
	if _event_color_fragments_loaded:
		return _event_color_fragments
	_event_color_fragments_loaded = true
	if not FileAccess.file_exists(EVENT_COLOR_FRAGMENTS_PATH):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(EVENT_COLOR_FRAGMENTS_PATH))
	if parsed is Dictionary:
		_event_color_fragments = parsed
	return _event_color_fragments


const EVENT_COLOR_FRAGMENTS_CONTEXT_PATH := "res://资产/数据/event_color_fragments_context.json"

static var _event_color_fragments_context: Dictionary = {}
static var _event_color_fragments_context_loaded: bool = false


static func _load_event_color_fragments_context() -> Dictionary:
	if _event_color_fragments_context_loaded:
		return _event_color_fragments_context
	_event_color_fragments_context_loaded = true
	if not FileAccess.file_exists(EVENT_COLOR_FRAGMENTS_CONTEXT_PATH):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(EVENT_COLOR_FRAGMENTS_CONTEXT_PATH))
	if parsed is Dictionary:
		_event_color_fragments_context = parsed
	return _event_color_fragments_context


## 给一段事件文本按原版彩色片段补回 <color> 标签。
## event_key 传原版事件编号字符串（如 "36"），没有编号的可传空串。
## 注意：只使用当前事件的专属片段。JSON 里的 “global” 实际是全事件片段的并集
## （每个事件专属片段都能在其中找到），若把它当全局公共片段应用，会让无关事件
## 出现其他事件的人名/专名颜色，导致串色。
static func restore_event_colors(text: String, event_key: String = "") -> String:
	if text.is_empty():
		return text
	var frag_dict := _event_fragments_for(event_key)
	if frag_dict.is_empty():
		return text
	var by_plain := {}
	for f in frag_dict:
		var plain_e := String(f.get("plain", ""))
		if plain_e == "":
			continue
		if not by_plain.has(plain_e):
			by_plain[plain_e] = []
		by_plain[plain_e].append({
			"plain": plain_e,
			"color": String(f.get("color", "")),
			"before": String(f.get("before", "")),
			"after": String(f.get("after", "")),
		})
	if by_plain.is_empty():
		return text
	# 长片段优先占位，短片段不能拆开已经命中的长词。
	# 例如“民主社会党”先命中后，后面的“社会党”不能再在它内部二次上色。
	var plains := by_plain.keys()
	plains.sort_custom(func(a, b) -> bool:
		return String(a).length() > String(b).length()
	)
	var spans: Array = []
	for plain in plains:
		var idx := text.find(plain, 0)
		while idx != -1:
			var span_end := idx + String(plain).length()
			if not _span_overlaps(spans, idx, span_end):
				var chosen := _choose_fragment(by_plain[plain], text, idx, span_end)
				if chosen != null:
					spans.append({
						"start": idx,
						"end": span_end,
						"color": String(chosen.get("color", "")),
					})
					idx = text.find(plain, span_end)
					continue
			idx = text.find(plain, idx + 1)
	if spans.is_empty():
		return text
	spans.sort_custom(func(a, b) -> bool:
		return int(a.get("start", 0)) < int(b.get("start", 0))
	)
	var out := ""
	var cursor := 0
	for span in spans:
		var start := int(span.get("start", 0))
		var end := int(span.get("end", 0))
		if start > cursor:
			out += text.substr(cursor, start - cursor)
		out += "<color=%s>%s</color>" % [String(span.get("color", "")), text.substr(start, end - start)]
		cursor = end
	if cursor < text.length():
		out += text.substr(cursor)
	return out


## 取某个事件的颜色片段：优先用带上下文的新数据；旧 JSON 作为兜底。
static func _event_fragments_for(event_key: String) -> Array:
	var ctx := _load_event_color_fragments_context()
	if event_key != "" and ctx.has(event_key):
		return ctx[event_key]
	var old := _load_event_color_fragments()
	if event_key != "" and old.has(event_key):
		return old[event_key]
	return []


## 同一 plain 可能有多个颜色（不同结果分支/上下文）。优先用上下文匹配；
## 匹配不到且有唯一候选时使用唯一候选；仍有多候选时取第一个，避免漏色。
static func _choose_fragment(candidates: Array, text: String, start: int, end: int) -> Dictionary:
	if candidates.is_empty():
		return {}
	if candidates.size() == 1:
		return candidates[0]
	var best: Dictionary = {}
	var best_ctx_len := -1
	for c in candidates:
		var before := String(c.get("before", ""))
		var after := String(c.get("after", ""))
		var before_ok := before.is_empty() or text.substr(maxi(0, start - before.length()), before.length()) == before
		var after_ok := after.is_empty() or text.substr(end, after.length()) == after
		if before_ok and after_ok:
			var ctx_len := before.length() + after.length()
			if ctx_len > best_ctx_len:
				best = c
				best_ctx_len = ctx_len
	if not best.is_empty():
		return best
	return candidates[0]


static func _span_overlaps(spans: Array, start: int, end: int) -> bool:
	for s in spans:
		var s_start := int(s.get("start", 0))
		var s_end := int(s.get("end", 0))
		if start < s_end and end > s_start:
			return true
	return false


## 事件文本统一入口：先补原版色彩片段，再转 Godot BBCode。
static func event_text_to_bbcode(text: String, event_key: String = "") -> String:
	return unity_color_to_bbcode(restore_event_colors(text, event_key))


## 给任意无脚本的 Control 挂上本提示脚本（一次性，重复调用无副作用）。
## Label 默认 mouse_filter = MOUSE_FILTER_IGNORE（gdd_0638_Label.md 属性表），
## 按 tooltip_text 文档要求必须不是 IGNORE 才会显示悬浮提示，这里统一改成 STOP。
static func attach(ctrl: Control) -> void:
	if ctrl == null or ctrl.get_script() != null:
		return
	if ctrl.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		ctrl.mouse_filter = Control.MOUSE_FILTER_STOP
	ctrl.set_script(load("res://数据脚本/bbc_tooltip.gd"))


## 通用设置入口：任意 Control 都能用它设置统一 Tooltip。
## 无脚本控件会自动挂上 BbcTooltip 以支持 BBCode；已有脚本的控件保持其
## _make_custom_tooltip / tooltip_text 行为不变。
static func set_tooltip(ctrl: Control, text: String) -> void:
	if ctrl == null:
		return
	ctrl.tooltip_text = text
	if ctrl.get_script() == null:
		attach(ctrl)


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


## 从项目全局 Theme 取 TooltipPanel 样式；没有则返回 null 由调用方回退。
func _tooltip_style() -> StyleBox:
	var project_theme := ThemeDB.get_project_theme()
	if project_theme != null and project_theme.has_stylebox("panel", "TooltipPanel"):
		return project_theme.get_stylebox("panel", "TooltipPanel")
	return null


func _make_custom_tooltip(for_text: String) -> Control:
	if for_text.is_empty():
		return null
	var display_text := _strip_all_spaces(unity_color_to_bbcode(for_text))
	var min_height: float = _estimate_min_height(display_text)
	var panel := PanelContainer.new()
	# 优先使用全局 Theme 的 TooltipPanel 样式，保证所有悬浮提示风格统一；
	# 没有全局样式时回退到自绘深灰底，白字永远有对比度。
	var style := _tooltip_style()
	if style == null:
		style = StyleBoxFlat.new()
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
