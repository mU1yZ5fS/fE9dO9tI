extends GameUIBase

## 政治界面 — 政治家卡片网格 + 左栏详情 + 人事操作。
## 布局在 政治.tscn，本脚本只做数据绑定与交互。

const W = preload("res://数据脚本/world_state.gd")
const WF = preload("res://数据脚本/world_factory.gd")

const 外交场景 := "uid://vq6jexkk5tru"
const 派系场景 := "uid://dly5fmobnogab"
const 经济场景 := "uid://btldk7ul11cqn"
const 科研场景 := "uid://d2qkifpx3o8pl"

const CARD_W := 220.0
const CARD_H := 150.0

var _selected: int = -1
var _card_nodes: Array = []
var _list_buttons: Array = []


func _ready() -> void:
	if GameManager:
		if GameManager.has_signal("stats_changed"):
			GameManager.stats_changed.connect(_refresh_all)
		GameManager.date_changed.connect(func(_d): _refresh_all())
		GameManager.world_state_loaded.connect(_refresh_all)
	_wire_actions()
	_wire_scroll()
	if GameManager and GameManager.world:
		_rebuild_cards()
		_refresh_all()
		var leader_idx := _leader_index()
		if leader_idx >= 0:
			_select_politician(leader_idx)
		elif GameManager.world.politicians.size() > 0:
			_select_politician(0)


func _leader_index() -> int:
	var w := GameManager.world
	if w == null or w.leader == null:
		return -1
	for i in w.politicians.size():
		if w.politicians[i] == w.leader:
			return i
	return -1


func _wire_actions() -> void:
	var names := [
		"送去再教育", "指定为派系负责人",
		"调往南方", "调往西方", "调往首都", "调往北方",
		"调往外交部", "调往东方", "调往国务院", "调往中央军委",
		"支持", "打压", "自动支持", "自动打压",
		"开始调查", "监视",
	]
	for n in names:
		var btn := _find(n)
		if btn is BaseButton:
			if not btn.pressed.is_connected(_on_action_pressed):
				btn.pressed.connect(_on_action_pressed.bind(n))


func _wire_scroll() -> void:
	var up := _find("向上滚动")
	if up is BaseButton and not up.pressed.is_connected(_on_scroll_up):
		up.pressed.connect(_on_scroll_up)
	var down := _find("向下滚动")
	if down is BaseButton and not down.pressed.is_connected(_on_scroll_down):
		down.pressed.connect(_on_scroll_down)


func _on_scroll_up() -> void:
	var sc := _find("卡片滚动") as ScrollContainer
	if sc:
		sc.scroll_vertical = maxi(sc.scroll_vertical - 180, 0)


func _on_scroll_down() -> void:
	var sc := _find("卡片滚动") as ScrollContainer
	if sc:
		sc.scroll_vertical = sc.scroll_vertical + 180


func _rebuild_cards() -> void:
	var grid := _find("卡片网格") as GridContainer
	var list := _find("名单列表") as VBoxContainer
	if grid == null:
		return
	for c in grid.get_children():
		c.queue_free()
	if list:
		for c in list.get_children():
			c.queue_free()
	_card_nodes.clear()
	_list_buttons.clear()

	var w := GameManager.world
	if w == null:
		return

	var order: Array[int] = []
	for i in w.politicians.size():
		order.append(i)
	var leader_i := _leader_index()
	order.sort_custom(func(a: int, b: int) -> bool:
		if a == leader_i:
			return true
		if b == leader_i:
			return false
		return w.politicians[a].power > w.politicians[b].power
	)

	for i in order:
		var p: PoliticianData = w.politicians[i]
		if list:
			var lb := Button.new()
			lb.name = "名单_%d" % i
			lb.text = p.name_display
			lb.custom_minimum_size = Vector2(180, 36)
			lb.alignment = HORIZONTAL_ALIGNMENT_LEFT
			lb.pressed.connect(_select_politician.bind(i))
			list.add_child(lb)
			_list_buttons.append(lb)
		var card := _make_card(i, p)
		grid.add_child(card)
		_card_nodes.append(card)


func _make_card(idx: int, p: PoliticianData) -> Control:
	var root := PanelContainer.new()
	root.name = "卡片_%d" % idx
	root.custom_minimum_size = Vector2(CARD_W, CARD_H)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	root.gui_input.connect(_on_card_gui.bind(idx))

	var style := StyleBoxTexture.new()
	var tex: Texture2D = load("res://资产/UI/政治/角色卡片背景.png")
	if tex:
		style.texture = tex
	root.add_theme_stylebox_override("panel", style)

	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	root.add_child(h)

	var face := TextureRect.new()
	face.name = "头像"
	face.custom_minimum_size = Vector2(72, 96)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	face.texture = load("res://资产/UI/政治/头像模板%d.png" % (p.face_type % 2))
	h.add_child(face)

	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(v)

	var name_l := Label.new()
	name_l.name = "姓名"
	name_l.text = p.name_display
	name_l.add_theme_font_size_override("font_size", 16)
	name_l.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	v.add_child(name_l)

	for trait_text in _trait_texts(p):
		var tl := Label.new()
		tl.text = trait_text
		tl.add_theme_font_size_override("font_size", 13)
		tl.add_theme_color_override("font_color", Color(0.15, 0.15, 0.15))
		v.add_child(tl)

	var bar := ProgressBar.new()
	bar.name = "忠诚条"
	bar.min_value = 0
	bar.max_value = 1000
	bar.value = p.loyalty
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 10)
	v.add_child(bar)
	return root


func _trait_texts(p: PoliticianData) -> Array[String]:
	var out: Array[String] = []
	var labels: Dictionary = WF.TRAIT_LABELS_ZH
	out.append(String(labels.get(p.trait_personality, p.ideology_label())))
	out.append(String(labels.get(p.trait_alignment, p.alignment_label())))
	var t2: String = String(labels.get(p.trait_special, ""))
	if t2 != "":
		out.append(t2)
	return out


func _on_card_gui(event: InputEvent, idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_select_politician(idx)


func _select_politician(idx: int) -> void:
	var w := GameManager.world
	if w == null or idx < 0 or idx >= w.politicians.size():
		return
	_selected = idx
	_refresh_left_panel()
	_highlight_selection()
	音频总管.play_button_click_sound()


func _highlight_selection() -> void:
	var sel_tex: Texture2D = load("res://资产/UI/政治/选中角色卡片背景.png")
	var normal_tex: Texture2D = load("res://资产/UI/政治/角色卡片背景.png")
	for card in _card_nodes:
		if card == null or not is_instance_valid(card):
			continue
		var idx := int(String(card.name).get_slice("_", 1))
		var style := StyleBoxTexture.new()
		style.texture = sel_tex if idx == _selected else normal_tex
		if card is PanelContainer:
			(card as PanelContainer).add_theme_stylebox_override("panel", style)
	for lb in _list_buttons:
		if lb is Button:
			var b := lb as Button
			var idx2 := int(String(b.name).get_slice("_", 1))
			b.modulate = Color(1.0, 0.95, 0.6) if idx2 == _selected else Color.WHITE


func _refresh_left_panel() -> void:
	var w := GameManager.world
	if w == null or _selected < 0 or _selected >= w.politicians.size():
		return
	var p: PoliticianData = w.politicians[_selected]
	_label("选中姓名", "%s[%d]" % [p.name_display, p.age])
	var traits := _trait_texts(p)
	_label("特质1", traits[0] if traits.size() > 0 else "")
	_label("特质2", traits[1] if traits.size() > 1 else "")
	_label("特质3", traits[2] if traits.size() > 2 else "")
	_label("详情文本", _detail_text(p, _selected))
	if w.数值表.size() > W.I_BUDGET:
		_label("预算显示", "%.1f" % (float(w.数值表[W.I_BUDGET]) / 10.0))
		_label("特工显示", "%.1f" % (float(w.数值表[W.I_AGENTS]) / 10.0))


func _detail_text(p: PoliticianData, idx: int) -> String:
	var w := GameManager.world
	var lines: PackedStringArray = []
	var posts: PackedStringArray = []
	if w.leader == p:
		posts.append("国家领导人")
	for fi in w.factions.size():
		if w.factions[fi].leader_index == idx:
			var fname := ["极左派", "保守派", "温和派", "改革派", "自由派"]
			var n: String = fname[fi] if fi < fname.size() else "派系"
			posts.append("%s领袖" % n)
	if posts.is_empty():
		lines.append("职务：无")
	else:
		lines.append("职务：%s" % "；".join(posts))
	lines.append("主管：—")
	if p.is_under_investigation:
		lines.append("正在接受纪律审查")
	else:
		lines.append("尚未被纪律审查")
	if p.is_under_surveillance:
		lines.append("监视中（%d 月）" % p.days_surveillance)
	else:
		lines.append("尚未被监察调查")
	lines.append("留置后的影响未知")
	var infl: float = float(p.power) * 10.0 + float(p.loyalty) / 10.0
	lines.append("影响力：%.1f" % infl)
	if p.power <= 25:
		lines.append("无名之辈")
	elif p.power <= 50:
		lines.append("小有名气")
	elif p.power <= 70:
		lines.append("有影响力")
	else:
		lines.append("强影响力")
	if p.is_conspiracy:
		lines.append("阴谋威胁！")
	return "\n".join(lines)


func _refresh_all() -> void:
	if GameManager and GameManager.world:
		GameManager.world.sync_economy()
	if _card_nodes.is_empty() and GameManager and GameManager.world:
		_rebuild_cards()
	_refresh_left_panel()
	var w := GameManager.world
	if w == null:
		return
	for card in _card_nodes:
		if card == null or not is_instance_valid(card):
			continue
		var idx := int(String(card.name).get_slice("_", 1))
		if idx < 0 or idx >= w.politicians.size():
			continue
		var bar := card.find_child("忠诚条", true, false)
		if bar is ProgressBar:
			(bar as ProgressBar).value = w.politicians[idx].loyalty
			var ratio: float = clampf(float(w.politicians[idx].loyalty) / 1000.0, 0.0, 1.0)
			(bar as ProgressBar).modulate = Color(1.0 - ratio, ratio, 0.0)


func _on_action_pressed(action: String) -> void:
	if _selected < 0 or GameManager.world == null:
		return
	var w := GameManager.world
	var p: PoliticianData = w.politicians[_selected]
	var d := w.数值表
	match action:
		"支持":
			p.loyalty = mini(p.loyalty + 40, 1000)
			if d.size() > W.I_BUDGET:
				d[W.I_BUDGET] = maxi(d[W.I_BUDGET] - 5, -9999)
		"打压":
			p.loyalty = maxi(p.loyalty - 50, 0)
			if d.size() > W.I_AGENTS:
				d[W.I_AGENTS] = maxi(d[W.I_AGENTS] - 20, -9999)
		"自动支持":
			p.auto_support = 1
			p.auto_hound = 0
		"自动打压":
			p.auto_hound = 1
			p.auto_support = 0
		"监视":
			if not p.is_under_surveillance and d.size() > W.I_AGENTS and d[W.I_AGENTS] >= 30:
				p.is_under_surveillance = true
				p.days_surveillance = 6
				d[W.I_AGENTS] -= 30
		"开始调查":
			if not p.is_under_investigation and d.size() > W.I_AGENTS and d[W.I_AGENTS] >= 20:
				p.is_under_investigation = true
				p.investigator_index = 0
				d[W.I_AGENTS] -= 20
		"送去再教育":
			if d.size() > W.I_BUDGET and d[W.I_BUDGET] >= 5 and d[W.I_AGENTS] >= 5:
				d[W.I_BUDGET] -= 5
				d[W.I_AGENTS] -= 5
				p.loyalty = mini(p.loyalty + 20, 1000)
				p.power = maxi(p.power - 5, 0)
		"指定为派系负责人":
			if p.faction >= 0 and p.faction < w.factions.size():
				w.factions[p.faction].leader_index = _selected
		_:
			if action.begins_with("调往"):
				if d.size() > W.I_BUDGET:
					d[W.I_BUDGET] = maxi(d[W.I_BUDGET] - 10, -9999)
				p.wanted_position = absi(action.hash()) % 8
	if GameManager.has_method("_notify_stats"):
		GameManager._notify_stats()
	_refresh_all()
	音频总管.play_button_click_sound()
