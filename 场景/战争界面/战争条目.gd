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

## 战争号 → 参战国原版序号（a=左方/攻击方，b=右方/防守方）。
const ANCHORS_PATH := "res://资产/地图/war_icon_anchors.json"

## 子意识形态图标（与 国家面板.gd 的 SUB_ICONS 一致）。
const SUB_ICONS := {
	0: preload("res://资产/UI/外交/子意识形态图标/sub_00.png"),
	1: preload("res://资产/UI/外交/子意识形态图标/sub_01.png"),
	2: preload("res://资产/UI/外交/子意识形态图标/sub_02.png"),
	3: preload("res://资产/UI/外交/子意识形态图标/sub_03.png"),
	4: preload("res://资产/UI/外交/子意识形态图标/sub_04.png"),
	5: preload("res://资产/UI/外交/子意识形态图标/sub_05.png"),
	6: preload("res://资产/UI/外交/子意识形态图标/sub_06.png"),
	7: preload("res://资产/UI/外交/子意识形态图标/sub_07.png"),
	8: preload("res://资产/UI/外交/子意识形态图标/sub_08.png"),
	9: preload("res://资产/UI/外交/子意识形态图标/sub_09.png"),
	10: preload("res://资产/UI/外交/子意识形态图标/sub_10.png"),
	11: preload("res://资产/UI/外交/子意识形态图标/sub_11.png"),
	12: preload("res://资产/UI/外交/子意识形态图标/sub_12.png"),
	13: preload("res://资产/UI/外交/子意识形态图标/sub_13.png"),
	14: preload("res://资产/UI/外交/子意识形态图标/sub_14.png"),
	15: preload("res://资产/UI/外交/子意识形态图标/sub_15.png"),
	16: preload("res://资产/UI/外交/子意识形态图标/sub_16.png"),
	17: preload("res://资产/UI/外交/子意识形态图标/sub_17.png"),
	18: preload("res://资产/UI/外交/子意识形态图标/sub_18.png"),
	19: preload("res://资产/UI/外交/子意识形态图标/sub_19.png"),
	20: preload("res://资产/UI/外交/子意识形态图标/sub_20.png"),
	21: preload("res://资产/UI/外交/子意识形态图标/sub_21.png"),
	22: preload("res://资产/UI/外交/子意识形态图标/sub_22.png"),
}

const GENERIC_LEFT_ICON := preload("res://资产/UI/战争/左方参战势力图标.png")
const GENERIC_RIGHT_ICON := preload("res://资产/UI/战争/右方参战势力图标.png")

var _anchors: Dictionary = {}


func _ready() -> void:
	_load_anchors()
	_wire_buttons()


func _load_anchors() -> void:
	if not FileAccess.file_exists(ANCHORS_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ANCHORS_PATH))
	if parsed is Dictionary:
		_anchors = parsed


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
	@warning_ignore("integer_division")
	_set_label("左方参战势力数值", str(war.infl1 / 10))
	@warning_ignore("integer_division")
	_set_label("右方参战势力数值", str(war.infl2 / 10))
	_apply_side_icons(p_war_id, war)
	_refresh_button_states()


## 按 war_icon_anchors.json 的参战国动态替换左右图标；
## 找不到锚点/国家时保留场景里的通用图标。
func _apply_side_icons(p_war_id: int, war: WarData) -> void:
	var w: WorldState = GameManager.world if GameManager else null
	if w == null or _anchors.is_empty():
		return
	var anchor: Dictionary = _anchors.get(str(p_war_id), {})
	var a_idx := int(anchor.get("a", -1))
	var b_idx := int(anchor.get("b", -1))
	var left_name := war.side1 if war != null else ""
	var right_name := war.side2 if war != null else ""
	_set_icon("左方参战势力图标", _icon_for_country(_country_for_anchor_or_name(w, a_idx, left_name), GENERIC_LEFT_ICON))
	_set_icon("右方参战势力图标", _icon_for_country(_country_for_anchor_or_name(w, b_idx, right_name), GENERIC_RIGHT_ICON))


func _country_for_anchor_or_name(w: WorldState, legacy_idx: int, side_name: String) -> CountryData:
	# 优先用锚点里的原版序号；Region 模式/缺 b 时回退按 side 名称找国家。
	if legacy_idx >= 0 and legacy_idx < 9000:
		var c := w.get_country_by_legacy_index(legacy_idx)
		if c != null:
			return c
	if side_name == "":
		return null
	var q := side_name.strip_edges()
	var c2 := w.resolve_country(q)
	if c2 != null:
		return c2
	for cd in w.countries:
		if cd == null:
			continue
		if cd.chinese_name == q or cd.name == q or cd.display_name() == q:
			return cd
		if cd.chinese_name.contains(q) or cd.name.contains(q) or cd.display_name().contains(q):
			return cd
	return null


func _icon_for_legacy(w: WorldState, legacy_idx: int, fallback: Texture2D) -> Texture2D:
	if legacy_idx < 0:
		return fallback
	var c: CountryData = w.get_country_by_legacy_index(legacy_idx)
	if c == null:
		return fallback
	return SUB_ICONS.get(c.sub_government, fallback)


func _icon_for_country(c: CountryData, fallback: Texture2D) -> Texture2D:
	if c == null:
		return fallback
	return SUB_ICONS.get(c.sub_government, fallback)


func _set_icon(node_name: String, tex: Texture2D) -> void:
	var n := find_child(node_name, true, false)
	if n is TextureRect:
		# 子意识形态图标是 120x120，必须强制按 46x43 的占位矩形缩放，
		# 否则会按原始尺寸显示，导致战争条目里图标巨大且错位。
		n.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		n.stretch_mode = TextureRect.STRETCH_SCALE
		n.custom_minimum_size = Vector2.ZERO
		n.texture = tex


func _set_label(node_name: String, text: String) -> void:
	var n := find_child(node_name, true, false)
	if n is Label:
		n.text = text


func _refresh_button_states() -> void:
	for n in _LEFT_BTNS.keys():
		var btn := find_child(n, true, false)
		if btn is Button:
			btn.disabled = not WarSystem.can_intervene(war_id, int(_LEFT_BTNS[n]))
	for n in _RIGHT_BTNS.keys():
		var btn := find_child(n, true, false)
		if btn is Button:
			btn.disabled = not WarSystem.can_intervene(war_id, int(_RIGHT_BTNS[n]))


func _on_action(action_id: int) -> void:
	action_pressed.emit(war_id, action_id)
