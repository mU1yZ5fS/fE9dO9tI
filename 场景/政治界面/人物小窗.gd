extends Control
## 人物小窗 —— 纯视图层。
## 所有冻结公式（资格/费用/文案）由宿主界面（政治局.gd）计算后注入，
## 本脚本只负责填充与转发，便于在编辑器中单独调试布局。

signal closed
signal action_pressed(action_id: String)
signal appoint_requested(position_id: int)

const ACTION_NODE_IDS := {
	"支持": "support",
	"打压": "suppress",
	"监视": "surveil",
	"隔离审查": "investigate",
	"自动支持": "auto_support",
	"自动打压": "auto_hound",
	"再教育": "reeducate",
	"指定为派系负责人": "faction_leader",
	"任命领袖军委": "leader_cmc",
}

@onready var _portrait: TextureRect = $窗体/边距/主列/头部/肖像框
@onready var _name_label: Label = $窗体/边距/主列/头部/信息列/姓名
@onready var _sub_label: Label = $窗体/边距/主列/头部/信息列/副行
@onready var _trait_label: Label = $窗体/边距/主列/头部/信息列/特质行
@onready var _close_btn: Button = $窗体/边距/主列/头部/关闭
@onready var _post_list: VBoxContainer = $窗体/边距/主列/任职滚动/职位列表
@onready var _special_zone: GridContainer = $窗体/边距/主列/特殊区


func _ready() -> void:
	visible = false
	_close_btn.pressed.connect(close)
	for node_name in ACTION_NODE_IDS:
		var btn := find_child(node_name, true, false) as Button
		if btn:
			btn.pressed.connect(_emit_action.bind(node_name))


func _emit_action(node_name: String) -> void:
	action_pressed.emit(ACTION_NODE_IDS[node_name])


## info: {name, sub, traits, portrait}
## posts: [{id:int, text:String, disabled:bool, tip:String}]
## actions: {action_id: {visible:bool, disabled:bool, tip:String}}
func open(info: Dictionary, posts: Array, actions: Dictionary) -> void:
	_name_label.text = str(info.get("name", ""))
	_sub_label.text = str(info.get("sub", ""))
	_trait_label.text = str(info.get("traits", ""))
	_portrait.texture = info.get("portrait")
	for row in _post_list.get_children():
		row.queue_free()
	for post in posts:
		var btn := Button.new()
		btn.text = str(post.get("text", ""))
		btn.disabled = bool(post.get("disabled", false))
		btn.tooltip_text = str(post.get("tip", ""))
		btn.icon = preload("res://资产/UI/政治/操作按钮背景.png")
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.add_theme_font_size_override("font_size", 17)
		btn.custom_minimum_size = Vector2(0, 44)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.set_meta("position_id", int(post.get("id", -1)))
		btn.pressed.connect(_on_post_pressed.bind(btn))
		_post_list.add_child(btn)
	for action_id in actions.keys():
		var btn := _find_action_button(action_id)
		if btn == null:
			continue
		var st: Dictionary = actions[action_id]
		btn.visible = bool(st.get("visible", true))
		btn.disabled = bool(st.get("disabled", false))
		btn.tooltip_text = str(st.get("tip", ""))
		if st.has("text"):
			btn.text = str(st.get("text"))
	_special_zone.visible = actions.has("faction_leader") or actions.has("leader_cmc")
	show()


func close() -> void:
	hide()
	closed.emit()


func is_open() -> bool:
	return visible


func refresh_posts(posts: Array) -> void:
	for row in _post_list.get_children():
		row.queue_free()
	for post in posts:
		var btn := Button.new()
		btn.text = str(post.get("text", ""))
		btn.disabled = bool(post.get("disabled", false))
		btn.tooltip_text = str(post.get("tip", ""))
		btn.icon = preload("res://资产/UI/政治/操作按钮背景.png")
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.add_theme_font_size_override("font_size", 17)
		btn.custom_minimum_size = Vector2(0, 44)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.set_meta("position_id", int(post.get("id", -1)))
		btn.pressed.connect(_on_post_pressed.bind(btn))
		_post_list.add_child(btn)


func _find_action_button(action_id: String) -> Button:
	for node_name in ACTION_NODE_IDS:
		if ACTION_NODE_IDS[node_name] != action_id:
			continue
		return find_child(node_name, true, false) as Button
	return null


func _on_post_pressed(btn: Button) -> void:
	appoint_requested.emit(int(btn.get_meta("position_id", -1)))
