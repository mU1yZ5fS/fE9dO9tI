extends Control

## 战争界面：可滚动战争列表（无上限）+ 干预 + 调试开战。

const ENTRY := preload("res://场景/战争界面/战争条目.tscn")
const W = preload("res://数据脚本/world_state.gd")

var _selected_id: int = -1
var _list: VBoxContainer
var _action_box: GridContainer
var _debug_box: HBoxContainer
var _empty_label: Label


func _ready() -> void:
	_ensure_ui()
	if GameManager:
		if GameManager.has_signal("stats_changed") and not GameManager.stats_changed.is_connected(_refresh):
			GameManager.stats_changed.connect(_refresh)
		if not GameManager.date_changed.is_connected(_on_date):
			GameManager.date_changed.connect(_on_date)
		if not GameManager.world_state_loaded.is_connected(_refresh):
			GameManager.world_state_loaded.connect(_refresh)
	_refresh()


func _on_date(_d: GameDate) -> void:
	_refresh()


func _ensure_ui() -> void:
	# 列表滚动区
	var scroll := get_node_or_null("战争列表滚动") as ScrollContainer
	if scroll == null:
		scroll = ScrollContainer.new()
		scroll.name = "战争列表滚动"
		scroll.set_anchors_preset(Control.PRESET_TOP_LEFT)
		scroll.offset_left = 280.0
		scroll.offset_top = 200.0
		scroll.offset_right = 1400.0
		scroll.offset_bottom = 760.0
		add_child(scroll)
	_list = scroll.get_node_or_null("战争列表") as VBoxContainer
	if _list == null:
		_list = VBoxContainer.new()
		_list.name = "战争列表"
		_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(_list)
	# 干预按钮
	_action_box = get_node_or_null("干预面板") as GridContainer
	if _action_box == null:
		_action_box = GridContainer.new()
		_action_box.name = "干预面板"
		_action_box.columns = 4
		_action_box.offset_left = 280.0
		_action_box.offset_top = 780.0
		_action_box.offset_right = 1400.0
		_action_box.offset_bottom = 920.0
		add_child(_action_box)
		for act in WarActionCatalog.all_actions():
			var btn := Button.new()
			btn.text = "%s(%s)" % [act["label"], "左" if int(act["side"]) == 1 else "右"]
			btn.custom_minimum_size = Vector2(160, 40)
			var aid: int = int(act["id"])
			btn.pressed.connect(_on_intervene.bind(aid))
			btn.set_meta("action_id", aid)
			_action_box.add_child(btn)
	# 调试开战
	_debug_box = get_node_or_null("调试开战") as HBoxContainer
	if _debug_box == null:
		_debug_box = HBoxContainer.new()
		_debug_box.name = "调试开战"
		_debug_box.offset_left = 280.0
		_debug_box.offset_top = 940.0
		_debug_box.offset_right = 1800.0
		_debug_box.offset_bottom = 1000.0
		add_child(_debug_box)
		var tip := Label.new()
		tip.text = "调试开战:"
		_debug_box.add_child(tip)
		for id in WarCatalog.all_ids():
			var def := WarCatalog.get_def(id)
			var b := Button.new()
			b.text = def.name_zh if def else str(id)
			b.pressed.connect(_on_debug_start.bind(id))
			_debug_box.add_child(b)


func _refresh() -> void:
	_refresh_list()
	_refresh_actions()
	_refresh_intervention()


func _refresh_intervention() -> void:
	var lbl := find_child("军事介入点数值", true, false)
	if lbl is Label and GameManager:
		lbl.text = GameManager.get_mil_intervention_display()


func _refresh_list() -> void:
	if _list == null:
		return
	for c in _list.get_children():
		_list.remove_child(c)
		c.free()
	if GameManager == null or GameManager.world == null:
		return
	var wars := GameManager.get_active_wars()
	# 需要 war_id：按索引扫
	var any := false
	for i in GameManager.world.wars.size():
		var war: WarData = GameManager.world.wars[i]
		if war == null or not war.is_going:
			continue
		any = true
		var item := ENTRY.instantiate()
		_list.add_child(item)
		if item.has_method("setup"):
			item.setup(i, war, i == _selected_id)
		if item.has_signal("selected"):
			item.selected.connect(_on_war_selected)
	if not any:
		_empty_label = Label.new()
		_empty_label.text = "当前无进行中的代理战争（可用下方调试开战）"
		_list.add_child(_empty_label)
		_selected_id = -1


func _on_war_selected(war_id: int) -> void:
	音频总管.play_button_click_sound()
	_selected_id = war_id
	_refresh()


func _refresh_actions() -> void:
	if _action_box == null:
		return
	for child in _action_box.get_children():
		if child is Button and child.has_meta("action_id"):
			var aid: int = int(child.get_meta("action_id"))
			child.disabled = not GameManager.can_intervene(_selected_id, aid) if GameManager else true


func _on_intervene(action_id: int) -> void:
	音频总管.play_button_click_sound()
	if GameManager and GameManager.intervene_war(_selected_id, action_id):
		_refresh()


func _on_debug_start(war_id: int) -> void:
	音频总管.play_button_click_sound()
	if GameManager and GameManager.debug_start_war(war_id):
		_selected_id = war_id
		_refresh()
