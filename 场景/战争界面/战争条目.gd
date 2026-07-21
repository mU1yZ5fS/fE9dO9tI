extends Control

## 单场战争条目（对齐用户重制的 战争条目.tscn）。
## 左方 = side1，右方 = side2。
## 按钮映射原作 WarButtonScript action_id：
##   左 人力增援=0 人道 | 特战支援=1 专家 | 军武援助=2 武器 | 外交声援=3
##   右 人力增援=5 | 特战支援=4 | 军武援助=6 | 外交声援=7

signal action_pressed(war_id: int, action_id: int)

var war_id: int = -1

const _LEFT_BTNS := {
	"人力增援左方参战势力": 0,
	"特战支援左方参战势力": 1,
	"军武援助左方参战势力": 2,
	"外交声援左方参战势力": 3,
}
const _RIGHT_BTNS := {
	"特战支援右方参战势力": 4,
	"人力增援右方参战势力": 5,
	"军武援助右方参战势力": 6,
	"外交声援右方参战势力": 7,
}


func _ready() -> void:
	_wire_buttons()


func _wire_buttons() -> void:
	for n in _LEFT_BTNS.keys():
		_connect_btn(n, int(_LEFT_BTNS[n]))
	for n in _RIGHT_BTNS.keys():
		_connect_btn(n, int(_RIGHT_BTNS[n]))


func _connect_btn(node_name: String, action_id: int) -> void:
	var btn := find_child(node_name, true, false)
	if btn is Button:
		if not btn.pressed.is_connected(_on_action):
			btn.pressed.connect(_on_action.bind(action_id))


func setup(p_war_id: int, war: WarData) -> void:
	war_id = p_war_id
	if war == null:
		return
	_set_label("条目战争名称", war.name_war)
	_set_label("左方参战势力名称", war.side1)
	_set_label("右方参战势力名称", war.side2)
	# 原作 UI 常显示整数档；内部仍是 0–1000，这里显示 ÷10 取整更贴近美术圆圈
	_set_label("左方参战势力数值", str(war.infl1 / 10))
	_set_label("右方参战势力数值", str(war.infl2 / 10))
	_refresh_button_states()


func _set_label(node_name: String, text: String) -> void:
	var n := find_child(node_name, true, false)
	if n is Label:
		n.text = text


func _refresh_button_states() -> void:
	if GameManager == null:
		return
	for n in _LEFT_BTNS.keys():
		var btn := find_child(n, true, false)
		if btn is Button:
			btn.disabled = not GameManager.can_intervene(war_id, int(_LEFT_BTNS[n]))
	for n in _RIGHT_BTNS.keys():
		var btn := find_child(n, true, false)
		if btn is Button:
			btn.disabled = not GameManager.can_intervene(war_id, int(_RIGHT_BTNS[n]))


func _on_action(action_id: int) -> void:
	音频总管.play_button_click_sound()
	action_pressed.emit(war_id, action_id)
