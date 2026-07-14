extends Control

## 事件场景逻辑。三页状态机。
## 仅使用 EventDef + EventEngine 新系统。

enum Page { INTRO, OPTIONS, RESULT }

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
@onready var _desc: Label = $事件描述
@onready var _image: TextureRect = $事件图片
@onready var _options_root: Control = $事件选项
@onready var _result_root: Control = $事件结果
@onready var _result_desc: Label = $事件结果/事件结果描述
@onready var _next_button: TextureButton = $事件切换页面按钮
@onready var _back_button: TextureButton = $事件切换页面按钮2


func _ready() -> void:
	# 事件场景会在 GameManager 暂停时间后打开；设为 ALWAYS 保证按钮仍响应。
	process_mode = Node.PROCESS_MODE_ALWAYS
	_collect_option_nodes()

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
	_load_event()


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

	_title.text = _event_def.title
	_desc.text = _event_def.description
	# 事件配图是可选资源；没有图时隐藏 TextureRect，避免显示空框。
	if _event_def.image:
		_image.texture = _event_def.image
	else:
		_image.hide()
	_setup_options()


func _setup_options() -> void:
	var count := _event_def.options.size()
	# UI 固定预留 6 个选项槽。事件少于 6 个时隐藏多余槽位。
	for i in 6:
		var has_option := i < count
		if i < _option_labels.size():
			_option_labels[i].visible = has_option
		if i < _option_buttons.size():
			var btn: TextureButton = _option_buttons[i]
			btn.visible = has_option
			if has_option:
				var opt: EventOption = _event_def.options[i]
				var can_select := true
				# enable_condition 为 null 表示选项无门槛；否则交给 EventEngine 统一求值。
				if opt.enable_condition != null and EventEngine:
					can_select = EventEngine.evaluate(opt.enable_condition)
				_option_labels[i].text = opt.text if can_select else (opt.disabled_text if opt.disabled_text != "" else opt.text)
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
				_result_desc.text = _event_def.description
				_result_root.show()
				_page = Page.RESULT
				return
			_title.hide()
			_desc.hide()
			_options_root.show()
			_back_button.show()   # 选项页可以返回
			_page = Page.OPTIONS

		Page.OPTIONS:
			if _selected_option < 0 or _event_def == null or EventEngine == null:
				return
			# 选项效果在这里一次性落到 WorldState，随后转入不可返回的结果页。
			var result: Dictionary = EventEngine.apply_event_option(_event_def, _selected_option)
			_options_root.hide()
			_back_button.hide()   # 结果页不能返回
			_title.show()
			_title.text = result.get("name", "")
			_result_desc.text = result.get("text", "")
			_result_root.show()
			_page = Page.RESULT

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


func _clear_option_selection() -> void:
	_selected_option = -1
	for btn in _option_buttons:
		btn.set_pressed_no_signal(false)


func _return_to_diplomacy() -> void:
	GameManager.clear_event()
	get_tree().change_scene_to_file("uid://vq6jexkk5tru")
