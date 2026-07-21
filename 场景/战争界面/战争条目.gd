extends Control

## 单场战争列表条目。

signal selected(war_id: int)

var war_id: int = -1

@onready var _name: Label = $战名
@onready var _s1: Label = $side1
@onready var _s2: Label = $side2
@onready var _i1: Label = $infl1
@onready var _i2: Label = $infl2
@onready var _stance: Label = $站队
@onready var _btn: Button = $选中


func _ready() -> void:
	if _btn and not _btn.pressed.is_connected(_on_pressed):
		_btn.pressed.connect(_on_pressed)


func setup(p_war_id: int, war: WarData, is_selected: bool) -> void:
	war_id = p_war_id
	if _name == null:
		_name = find_child("战名", true, false) as Label
		_s1 = find_child("side1", true, false) as Label
		_s2 = find_child("side2", true, false) as Label
		_i1 = find_child("infl1", true, false) as Label
		_i2 = find_child("infl2", true, false) as Label
		_stance = find_child("站队", true, false) as Label
		_btn = find_child("选中", true, false) as Button
		if _btn and not _btn.pressed.is_connected(_on_pressed):
			_btn.pressed.connect(_on_pressed)
	if war == null:
		return
	var n := find_child("战名", true, false)
	if n is Label:
		n.text = war.name_war
	var s1 := find_child("side1", true, false)
	if s1 is Label:
		s1.text = war.side1
	var s2 := find_child("side2", true, false)
	if s2 is Label:
		s2.text = war.side2
	var i1 := find_child("infl1", true, false)
	if i1 is Label:
		i1.text = "%.1f" % (float(war.infl1) / 10.0)
	var i2 := find_child("infl2", true, false)
	if i2 is Label:
		i2.text = "%.1f" % (float(war.infl2) / 10.0)
	var st := find_child("站队", true, false)
	if st is Label:
		var u := "美→%s" % (war.side1 if war.usa_side == 0 else war.side2)
		var s := "苏→%s" % (war.side1 if war.ussr_side == 0 else war.side2)
		st.text = "%s  %s" % [u, s]
	var btn := find_child("选中", true, false)
	if btn is Button:
		if not btn.pressed.is_connected(_on_pressed):
			btn.pressed.connect(_on_pressed)
		btn.text = "已选" if is_selected else "选择"
	modulate = Color(1.1, 1.05, 0.9, 1) if is_selected else Color.WHITE


func _on_pressed() -> void:
	selected.emit(war_id)
