extends Control

signal card_hovered(pol_index: int)
signal card_unhovered()
signal card_clicked(pol_index: int)

var _pol_index: int = -1
var _politician: PoliticianData

@onready var _name_label: Label = $姓名
@onready var _faction_label: Label = $派系
@onready var _trait1_label: Label = $特质1
@onready var _trait2_label: Label = $特质2
@onready var _loyalty_bar: ProgressBar = $忠诚度
@onready var _portrait_container: Control = $人像

var _portrait_rect: TextureRect


func _ready() -> void:
	_portrait_rect = TextureRect.new()
	_portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_portrait_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_container.add_child(_portrait_rect)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)


func setup(politician: PoliticianData, pol_index: int) -> void:
	_politician = politician
	_pol_index = pol_index
	refresh()


func refresh() -> void:
	if _politician == null:
		return
	_name_label.text = _politician.name_display
	_faction_label.text = _politician.ideology_label()
	_trait1_label.text = _politician.alignment_label()
	_trait2_label.text = WorldFactory.TRAIT_LABELS_ZH.get(_politician.trait_special, "未知")
	if _portrait_rect:
		_portrait_rect.texture = _politician.portrait
	update_loyalty_bar(-1)


## hover_target: -1=显示对领袖忠诚；>=0=显示本卡政客对 hover_target 的忠诚
## 对应原版 Politic_Script.RepaintShkal：
## politics[this].loyality_to_other[display] / 1000
func update_loyalty_bar(hover_target: int) -> void:
	if _politician == null or _loyalty_bar == null:
		return
	var value: int
	if hover_target < 0:
		value = _politician.loyalty
	elif hover_target == _pol_index:
		value = 1000
	else:
		if hover_target < _politician.loyalty_matrix.size():
			value = _politician.loyalty_matrix[hover_target]
		else:
			value = 0
	# 条宽按 0~1000 归一；超额（开局 10000 硬编码）夹到满格
	var display := clampi(value, 0, 1000)
	_loyalty_bar.max_value = 1000.0
	_loyalty_bar.value = display
	var ratio := clampf(float(display) / 1000.0, 0.0, 1.0)
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(1.0 - ratio, ratio, 0.0)
	_loyalty_bar.add_theme_stylebox_override("fill", fill_style)


func get_pol_index() -> int:
	return _pol_index


func _on_mouse_entered() -> void:
	if _pol_index >= 0:
		card_hovered.emit(_pol_index)


func _on_mouse_exited() -> void:
	card_unhovered.emit()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _pol_index >= 0:
			card_clicked.emit(_pol_index)
			accept_event()
