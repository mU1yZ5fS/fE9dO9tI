extends Control
## 政治家卡片。对齐原版 Politic_Script：
## name + traits[0..3] 四行（Politic_Script.cs:56-69）+ 忠诚条（RepaintShkal）
## 悬停提示对齐 OkoshkoScript other_text[350]（other_text_en.txt:350-355）。

signal card_hovered(pol_index: int)
signal card_unhovered()
signal card_clicked(pol_index: int)

## other_text_en.txt:351-355 的意向职位文案
const WANTED_POSITION_LABELS := [
	" 国 务 院 总 理", " 军 委 主 席", " 外 交 部 长", " 地 方 长 官", " 第 四 国 际",
]

var _pol_index: int = -1
var _politician: PoliticianData

@onready var _name_label: Label = $姓名
@onready var _trait0_label: Label = $派系  # 原版 T1 = traits[0]
@onready var _trait1_label: Label = $特质1
@onready var _trait2_label: Label = $特质2
@onready var _trait3_label: Label = get_node_or_null("特质3") as Label
@onready var _loyalty_bar: ProgressBar = $忠诚度
@onready var _portrait_container: Control = $人像

var _portrait_rect: TextureRect
var _no_portrait_label: Label


func _ready() -> void:
	_portrait_rect = TextureRect.new()
	_portrait_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_portrait_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_container.add_child(_portrait_rect)
	_no_portrait_label = Label.new()
	_no_portrait_label.text = "无肖像"
	_no_portrait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_no_portrait_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_no_portrait_label.add_theme_font_size_override("font_size", 18)
	_no_portrait_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4, 1))
	_no_portrait_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_no_portrait_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait_container.add_child(_no_portrait_label)
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
	# 原版 Politic_Script.cs:58-61：T1..T4 = traits[0..3]；
	# 项目字段映射：trait_personality=traits[0]、trait_alignment=traits[1]、
	# trait_special=traits[2]、trait_background=traits[3]。
	# 显示顺序按用户确认：T1=派系、T2=traits[3] 出身、T3=traits[1] 性格、T4=traits[2] 特殊。
	_trait0_label.text = WorldFactory.PARTY_LABELS_ZH.get(_politician.party_index(), "未知")
	_trait1_label.text = _politician.background_label()
	_trait2_label.text = WorldFactory.TRAIT_LABELS_ZH.get(_politician.trait_alignment, "未知")
	if _trait3_label:
		_trait3_label.text = WorldFactory.TRAIT_LABELS_ZH.get(_politician.trait_special, "未知")
	if _portrait_rect:
		var has_portrait := _politician.has_real_portrait()
		_portrait_rect.visible = has_portrait
		_portrait_rect.texture = _politician.portrait if has_portrait else null
		if _no_portrait_label:
			_no_portrait_label.visible = not has_portrait
	_refresh_tooltip()
	update_loyalty_bar(-1)


## other_text_en.txt:350：意向职位 / 对领导人忠诚 / 年龄（OkoshkoScript 弹出提示）
func _refresh_tooltip() -> void:
	if _politician == null:
		tooltip_text = ""
		return
	var wanted := " 地 方 长 官"
	if _politician.wanted_position >= 0 and _politician.wanted_position < WANTED_POSITION_LABELS.size():
		wanted = WANTED_POSITION_LABELS[_politician.wanted_position]
	tooltip_text = "意 向 职 位 为 ：%s\n对 我 国 领 导 人 的 忠 诚 度 为 ：%s\n年 龄 ：%d 岁" % [
		wanted, float(_politician.loyalty) / 10.0, _politician.age
	]


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
