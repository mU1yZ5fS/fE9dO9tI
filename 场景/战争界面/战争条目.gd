extends Control

## 单场战争条目（对齐用户重制的 战争条目.tscn）。
## 左方 = side1，右方 = side2。
## 图标根据 usa_side / ussr_side 动态显示美国或苏联图标。
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

## 美苏图标：左方参战势力图标.png = 苏联，右方参战势力图标.png = 美国。
## 根据 war.usa_side / war.ussr_side 动态决定哪方显示哪个图标（不固定左=苏联右=美国）。
## WarDef 中 icon_side1/icon_side2 可手动覆盖特殊战争。
const ICON_USSR := preload("res://资产/UI/战争/左方参战势力图标.png")
const ICON_USA := preload("res://资产/UI/战争/右方参战势力图标.png")


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
	@warning_ignore("integer_division")
	_set_label("左方参战势力数值", str(war.infl1 / 10))
	@warning_ignore("integer_division")
	_set_label("右方参战势力数值", str(war.infl2 / 10))
	_apply_side_icons(p_war_id, war)
	_refresh_button_states()


## 根据 usa_side / ussr_side 动态决定左右图标显示美国还是苏联；
## -1 = 中立（不显示图标）；双方都支持同一方时，装饰圆圈替换为另一个图标。
## WarDef 中 icon_side1/icon_side2 可手动覆盖特殊战争。
func _apply_side_icons(p_war_id: int, war: WarData) -> void:
	var def := WarCatalog.get_def(p_war_id)
	# 优先使用 WarDef 中显式指定的图标（特殊战争手动覆盖）。
	if def != null and (def.icon_side1 != null or def.icon_side2 != null):
		_set_icon("左方参战势力图标", def.icon_side1 if def.icon_side1 != null else ICON_USSR)
		_set_icon("右方参战势力图标", def.icon_side2 if def.icon_side2 != null else ICON_USA)
		return
	# 默认不显示图标（中立/无超级大国支持）。
	var left_icon: Texture2D = null
	var right_icon: Texture2D = null
	var left_extra: Texture2D = null  # 左方装饰圆圈替换
	var right_extra: Texture2D = null  # 右方装饰圆圈替换
	if war != null:
		# 左方 (side1)：谁支持 side1？
		if war.usa_side == GameConstants.WarSide.SIDE1:
			left_icon = ICON_USA
		elif war.ussr_side == GameConstants.WarSide.SIDE1:
			left_icon = ICON_USSR
		# 右方 (side2)：谁支持 side2？
		if war.usa_side == GameConstants.WarSide.SIDE2:
			right_icon = ICON_USA
		elif war.ussr_side == GameConstants.WarSide.SIDE2:
			right_icon = ICON_USSR
		# 双方都支持同一方时，装饰圆圈替换为另一个图标
		if war.usa_side == GameConstants.WarSide.SIDE1 and war.ussr_side == GameConstants.WarSide.SIDE1:
			left_icon = ICON_USA
			left_extra = ICON_USSR
		elif war.usa_side == GameConstants.WarSide.SIDE2 and war.ussr_side == GameConstants.WarSide.SIDE2:
			right_icon = ICON_USA
			right_extra = ICON_USSR
	_set_icon("左方参战势力图标", left_icon)
	_set_icon("右方参战势力图标", right_icon)
	# 装饰圆圈：只有需要替换时才改，否则保持原样（圆圈.png）
	if left_extra != null:
		_set_icon("左方装饰圆圈", left_extra)
	if right_extra != null:
		_set_icon("右方装饰圆圈", right_extra)


func _set_icon(node_name: String, tex: Texture2D) -> void:
	var n := find_child(node_name, true, false)
	if n is TextureRect:
		if tex == null:
			n.texture = null
			return
		# 图标来源可能是任意比例的图片：强制按占位矩形缩放并保持原图比例，
		# 避免巨大/压扁/错位。
		n.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		n.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
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
