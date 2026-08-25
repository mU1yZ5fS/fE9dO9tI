extends Control

## 事件场景逻辑。三页状态机。
## 仅使用 EventDef + EventEngine 新系统。

enum Page { INTRO, OPTIONS, RESULT }

## 事件无专属配图时的默认插画目录。
const EVENT_ILLUST_DIR := "res://资产/事件插画"

## 当前展示的事件定义。由 GameManager.current_event_id 定位，
## 再从 EventEngine 的注册表中取出。
var _event_def: EventDef

## 当前页面状态：简介 -> 选项 -> 结果。
var _page: int = Page.INTRO

## 当前选中的选项下标；-1 表示没有可提交的选择。
var _selected_option: int = -1

## 事件选项的文字和按钮是分开的节点。这里按场景树顺序收集后用同一下标配对。
var _option_buttons: Array[TextureButton] = []
var _option_labels: Array[Label] = []

## 同一事件只能选中一个选项，ButtonGroup 负责互斥。
var _button_group: ButtonGroup

@onready var _title: Label = $事件标题
@onready var _desc: RichTextLabel = $事件描述
@onready var _image: TextureRect = $事件图片
@onready var _options_root: Control = $事件选项
@onready var _result_root: Control = $事件结果
@onready var _result_desc: RichTextLabel = $事件结果/事件结果描述
@onready var _unread_hint: Label = $事件内容未读完提示
@onready var _next_button: TextureButton = $事件切换页面按钮
@onready var _back_button: TextureButton = $事件切换页面按钮2


func _ready() -> void:
	# 事件场景会在 GameManager 暂停时间后打开；设为 ALWAYS 保证按钮仍响应。
	process_mode = Node.PROCESS_MODE_ALWAYS
	_collect_option_nodes()
	_apply_event_ui_settings()

	_button_group = ButtonGroup.new()
	for i in _option_buttons.size():
		var btn: TextureButton = _option_buttons[i]
		btn.button_group = _button_group
		btn.toggled.connect(_on_option_toggled.bind(i))

	_next_button.pressed.connect(_on_next_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	_back_button.hide()   # INTRO 页不需要返回按钮
	_options_root.hide()
	_result_root.hide()
	# 事件内容未读完提示：文案滚动 / 布局变化时刷新显示状态。
	if _unread_hint:
		_unread_hint.hide()
	if _desc:
		_desc.get_v_scroll_bar().value_changed.connect(func(_v: float): _update_unread_hint())
		_desc.resized.connect(_update_unread_hint)
	if _result_desc:
		_result_desc.get_v_scroll_bar().value_changed.connect(func(_v: float): _update_unread_hint())
		_result_desc.resized.connect(_update_unread_hint)
	_load_event()


## 按设置应用事件界面字体大小与对齐方式。
func _apply_event_ui_settings() -> void:
	if GameManager == null:
		return
	var align: int = GameManager.event_text_alignment
	var align_enum := HORIZONTAL_ALIGNMENT_LEFT
	if align == 1:
		align_enum = HORIZONTAL_ALIGNMENT_CENTER
	elif align == 2:
		align_enum = HORIZONTAL_ALIGNMENT_RIGHT
	if _title:
		_title.add_theme_font_size_override("font_size", clampi(GameManager.event_title_font_size, 12, 96))
	# 事件文案对齐只作用于正文/结果，不影响事件标题和选项。
	if _desc:
		_desc.horizontal_alignment = align_enum
		_desc.add_theme_font_size_override("normal_font_size", clampi(GameManager.event_desc_font_size, 12, 72))
		_setup_style_fonts(_desc)
	if _result_desc:
		_result_desc.horizontal_alignment = align_enum
		_result_desc.add_theme_font_size_override("normal_font_size", clampi(GameManager.event_result_font_size, 12, 72))
		_setup_style_fonts(_result_desc)
	for lbl in _option_labels:
		if lbl is Label:
			lbl.add_theme_font_size_override("font_size", clampi(GameManager.event_option_font_size, 12, 72))
	_update_unread_hint.call_deferred()


## 为 RichTextLabel 配置 [b]/[i] 样式字体。
## 中文整字字体通常没有粗体/斜体变体文件，这里用 FontVariation 合成：
##   粗体 = embolden 笔画加粗；斜体 = transform 水平剪切（右倾）。
## 若日后引入真实粗体/斜体字体文件，改为 add_theme_font_override 直接指定即可。
func _setup_style_fonts(rtl: RichTextLabel) -> void:
	if rtl == null:
		return
	var base := rtl.get_theme_font("normal_font")
	if base == null:
		return
	var bold := FontVariation.new()
	bold.base_font = base
	bold.variation_embolden = 0.6
	var italic := FontVariation.new()
	italic.base_font = base
	italic.variation_transform = Transform2D(Vector2(1, 0), Vector2(-0.22, 1), Vector2())
	var bold_italic := FontVariation.new()
	bold_italic.base_font = base
	bold_italic.variation_embolden = 0.6
	bold_italic.variation_transform = italic.variation_transform
	rtl.add_theme_font_override("bold_font", bold)
	rtl.add_theme_font_override("italics_font", italic)
	rtl.add_theme_font_override("bold_italics_font", bold_italic)


## 事件内容未读完提示：当前可见的事件文本（简介或结果页）未滚动到底部时显示，
## 文本可完整显示（无需滚动）或已滚到底部时隐藏。
func _update_unread_hint() -> void:
	if _unread_hint == null:
		return
	var rtl: RichTextLabel = null
	if _page == Page.INTRO and _desc != null and _desc.visible:
		rtl = _desc
	elif _page == Page.RESULT and _result_root != null and _result_root.visible and _result_desc != null:
		rtl = _result_desc
	if rtl == null:
		_unread_hint.hide()
		return
	var bar := rtl.get_v_scroll_bar()
	# 内容高度 > 可视高度时才可滚动；value 未达到 max - page 即未读完。
	var scrollable: bool = bar.max_value > bar.page + 1.0
	var at_bottom: bool = bar.value >= bar.max_value - bar.page - 1.0
	_unread_hint.visible = scrollable and not at_bottom


## 事件文本显示前处理：段首空两格、段落之间留空隙（由设置开关控制）。
## 注意：渲染字体（方正跃进简体）不显示空格字形（ASCII 空格 advance≈0、U+3000 无轮廓），
## 且 Godot 4.7 的 RichTextLabel 不解析 [indent=2]（会原样显示字面量）。
## 因此首行缩进用两个“无色全角字形”占位：[color=#00000000]中中[/color] 排版照常占两字宽、
## 像素完全透明，不依赖任何空格/空白处理；段间距统一由段落拼接控制（开=空一行，关=不空）。
const INDENT_MARK := "[color=#00000000]中中[/color]"

## 原样块标记：[原样]…[/原样] 之间的文本按作者写的换行结构原样渲染——
## 不加首行缩进、行间不产生段落间距、不受玩家排版设置影响。
## 适用诗歌/信件/清单等需要固定分行样式的文本。标记本身在任何设置下都会被剥除，
## 未闭合时视为延伸到文末。文案里直接写即可（CSV 单元格内换行）。
const NOFMT_OPEN := "[原样]"
const NOFMT_CLOSE := "[/原样]"

func _format_event_text(text: String) -> String:
	if text.is_empty() or GameManager == null:
		return text
	# 诗行分隔符惯例：| 即换行（原版 Part 文本约定，如"翱翔！翱翔！|欢唱！欢唱！"）
	text = text.replace("|", "\n")
	var indent_on: bool = GameManager.paragraph_indent_enabled
	var spacing_on: bool = GameManager.paragraph_spacing_enabled
	# 标记必须始终剥除（否则设置全关时会原样漏显），所以含标记时不走快速返回。
	if not indent_on and not spacing_on and not text.contains(NOFMT_OPEN):
		return text
	return _apply_layout(text, indent_on, spacing_on)


## 纯函数：按缩进/间距设置排版文本；[原样]…[/原样] 块保持原样。
static func _apply_layout(text: String, indent_on: bool, spacing_on: bool) -> String:
	# 统一换行符：\r\n / \r 一律归一为 \n。
	text = text.replace("\r\n", "\n").replace("\r", "\n")

	# 切成 普通段 / 原样块 交替的片段，分别渲染后再用段落间距拼回。
	var segments: Array[String] = []
	var cursor := 0
	while cursor <= text.length():
		var open_at := text.find(NOFMT_OPEN, cursor)
		var plain_end := open_at if open_at >= 0 else text.length()
		segments.append(_layout_plain(text.substr(cursor, plain_end - cursor), indent_on, spacing_on))
		if open_at < 0:
			break
		var body_start := open_at + NOFMT_OPEN.length()
		var close_at := text.find(NOFMT_CLOSE, body_start)
		var body_end := close_at if close_at >= 0 else text.length()
		segments.append(_layout_verbatim(text.substr(body_start, body_end - body_start)))
		if close_at < 0:
			break
		cursor = close_at + NOFMT_CLOSE.length()

	# 过滤空片段后按“玩家设置的段间距”拼接：块与块之间仍是正常段落边界。
	var sep := "\n\n" if spacing_on else "\n"
	var out := ""
	for seg in segments:
		if seg.is_empty():
			continue
		out = seg if out == "" else out + sep + seg
	return out


## 普通文本段：非空行加首行缩进占位，空行丢弃（原逻辑）。
static func _layout_plain(block: String, indent_on: bool, spacing_on: bool) -> String:
	var paragraphs: Array[String] = []
	for raw_line in block.split("\n"):
		if raw_line.strip_edges() == "":
			continue
		var line := raw_line
		if indent_on:
			line = INDENT_MARK + line
		paragraphs.append(line)
	return "\n\n".join(paragraphs) if spacing_on else "\n".join(paragraphs)


## 原样块：剥掉首尾各一个换行（边界段距由外层拼接提供），内部逐行保留、不加缩进。
static func _layout_verbatim(block: String) -> String:
	if block.begins_with("\n"):
		block = block.substr(1)
	if block.ends_with("\n"):
		block = block.substr(0, block.length() - 1)
	return block


func _collect_option_nodes() -> void:
	_option_buttons.clear()
	_option_labels.clear()
	if _options_root == null:
		return
	# 当前 tscn 中节点顺序为：选项1文本、选项1按钮、选项2文本、选项2按钮...
	# 分别收集后，两个数组的同一下标仍对应同一个选项。
	for child in _options_root.get_children():
		if child is Label:
			_option_labels.append(child)
		elif child is TextureButton:
			_option_buttons.append(child)


func _load_event() -> void:
	var event_id: String = GameManager.current_event_id
	if event_id == "" or EventEngine == null:
		_title.text = "错误"
		_desc.text = "事件系统未正确初始化。"
		return

	_event_def = EventEngine.get_event(event_id)
	if _event_def == null:
		_title.text = "未找到事件"
		_desc.text = "事件 '%s' 不存在。" % event_id
		return

	_title.text = EventText.t(_event_def.title)
	_desc.text = _format_event_text(BbcTooltip.event_text_to_bbcode(EventText.t(_event_def.description), str(_event_def.source_event_number)))
	_update_unread_hint.call_deferred()
	# 事件配图规则：
	#   1. 资源文件（EventDef.image）设置了图片 → 优先使用；
	#   2. 否则按 source_event_number 找 资产/事件插画/<编号>.png；
	#   3. 仍没有 → 从 资产/事件插画 目录随机选一张（暂为均匀随机，无权重数据）。
	if _event_def.image:
		_image.texture = _event_def.image
		_image.show()
	else:
		var fallback := _load_fallback_image(_event_def)
		if fallback:
			_image.texture = fallback
			_image.show()
		else:
			_image.hide()
	_setup_options()


## 事件没有显式配图时，按编号优先，其次随机从插画目录取一张。
func _load_fallback_image(ev: EventDef) -> Texture2D:
	if ev.source_event_number >= 0:
		var numbered_path := "%s/%d.png" % [EVENT_ILLUST_DIR, ev.source_event_number]
		if ResourceLoader.exists(numbered_path):
			var numbered := load(numbered_path) as Texture2D
			if numbered:
				return numbered
	var files := _list_illustrations()
	if files.is_empty():
		return null
	var chosen := files[randi() % files.size()]
	var chosen_path := "%s/%s" % [EVENT_ILLUST_DIR, chosen]
	if not ResourceLoader.exists(chosen_path):
		return null
	return load(chosen_path) as Texture2D


## 列出插画目录下的 PNG 文件名（不含子目录）。
func _list_illustrations() -> Array[String]:
	var dir := DirAccess.open(EVENT_ILLUST_DIR)
	if dir == null:
		return []
	var out: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			out.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	return out


func _setup_options() -> void:
	var count := _event_def.options.size()
	# UI 固定预留 6 个选项槽。事件少于 6 个时隐藏多余槽位。
	for i in 6:
		var has_option := i < count
		if i < _option_labels.size():
			_option_labels[i].visible = has_option
			_option_labels[i].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if i < _option_buttons.size():
			var btn: TextureButton = _option_buttons[i]
			btn.visible = false
			if has_option:
				var opt: EventOption = _event_def.options[i]
				var can_select := true
				# enable_condition 为 null 表示选项无门槛；否则交给 EventEngine 统一求值。
				if opt.enable_condition != null and EventEngine:
					can_select = EventEngine.evaluate(opt.enable_condition)
				# _disable 不再覆盖 opt.text（保留原模板供后续 _enable 恢复），
				# 因此禁用且没有单独禁用文案的选项要显式置空，避免把隐藏项原文显示出来。
				_option_labels[i].text = EventText.t(opt.text) if can_select else (EventText.t(opt.disabled_text) if opt.disabled_text != "" else "")
				# 玩家选不了的选项不显示选框（只保留灰字提示，避免误导可点）。
				btn.visible = can_select
				btn.disabled = not can_select
				btn.modulate = Color(0.55, 0.55, 0.55) if not can_select else Color.WHITE
				btn.set_pressed_no_signal(false)
	_selected_option = -1


func _on_option_toggled(button_pressed: bool, index: int) -> void:
	if button_pressed:
		_selected_option = index
	elif _selected_option == index:
		_selected_option = -1


func _on_next_pressed() -> void:
	match _page:
		Page.INTRO:
			if _event_def == null:
				return
			if _event_def.options.is_empty():
				_title.show()
				_desc.hide()
				_options_root.hide()
				_back_button.hide()
				_result_desc.text = _format_event_text(BbcTooltip.event_text_to_bbcode(EventText.t(_event_def.description), str(_event_def.source_event_number)))
				_result_root.show()
				_page = Page.RESULT
				_update_unread_hint.call_deferred()
				return
			_title.hide()
			_desc.hide()
			_options_root.show()
			_back_button.show()   # 选项页可以返回
			_page = Page.OPTIONS
			_update_unread_hint.call_deferred()

		Page.OPTIONS:
			if _selected_option < 0 or _event_def == null or EventEngine == null:
				return
			# 选项效果在这里一次性落到 WorldState，随后转入不可返回的结果页。
			var result: Dictionary = EventEngine.apply_event_option(_event_def, _selected_option)
			_options_root.hide()
			_back_button.hide()   # 结果页不能返回
			_title.show()
			_title.text = result.get("name", "")
			_result_desc.text = _format_event_text(BbcTooltip.event_text_to_bbcode(String(result.get("text", "")), str(_event_def.source_event_number)))
			_result_root.show()
			_page = Page.RESULT
			_update_unread_hint.call_deferred()

		Page.RESULT:
			_return_to_diplomacy()


## 返回按钮：从 OPTIONS 页回到 INTRO 页重新阅读事件描述
func _on_back_pressed() -> void:
	if _page != Page.OPTIONS:
		return
	_options_root.hide()
	_back_button.hide()
	_title.show()
	_desc.show()
	_clear_option_selection()
	_page = Page.INTRO
	_update_unread_hint.call_deferred()


func _clear_option_selection() -> void:
	_selected_option = -1
	for btn in _option_buttons:
		btn.set_pressed_no_signal(false)


func _return_to_diplomacy() -> void:
	GameManager.clear_event()
	if GameManager.current_ending_id >= 0:
		return
	get_tree().change_scene_to_file("uid://vq6jexkk5tru")
