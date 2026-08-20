extends "res://数据脚本/event_script_base.gd"

## 原作 Event604.cs：十八岁的我只想活下去（南非人民邦特别军事行动，单选项）。
## 触发：ReqEventForDLC02.cs:874-876 —— c131.SubGosstroy==9 && !war54.is_going && DATE_AFTER 1984.1.1。
## 差异：描述按 c127.puppet_of<0 动态插入“、津巴布韦”；AmericanSupportAttacker→usa_side=0。

const TXT_DESC_A := "今天，素有“行走大洋国”之称的南非人民邦宣布将在非洲南部地区发起“德拉雷”维和特别军事行动。根据南非人民邦发言人的说法，该行动将“彻底解决侵犯南非领土主权”的敌对行动。全副武装的南非部队已开始向其边界邻国进军，并将炮口瞄准安哥拉、博茨瓦纳"
const TXT_DESC_MID := "、津巴布韦"
const TXT_DESC_B := "和莫桑比克境内的反对派。上述非洲国家在战争初便惨遭化学武器和白磷弹打击，沦陷区内尸横遍野。国际社会对南非部队的暴行空前震惊，并纷纷谴责南非纵容新纳粹主义，重走殖民主义老路。美苏两国已开始向非洲南部各国派发军事援助以抵御布尔人怒火，而坦桑尼亚等持泛非主义立场的政权更是号召组织非洲纵队全面援助抗击人民邦的战事。\n究竟谁能够胜利？“文明”还是良知？"
const TXT_R0 := "决定南部非洲的命运的战争已然打响……"
const TXT_WAR0_NAME := "南非-安哥拉之战"
const TXT_WAR0_SIDE1 := "安哥拉"
const TXT_WAR0_SIDE2 := "南非"
const TXT_WAR1_NAME := "南非-博茨瓦纳之战"
const TXT_WAR1_SIDE1 := "博茨瓦纳"
const TXT_WAR1_SIDE2 := "南非"
const TXT_WAR2_NAME := "南非-莫桑比克之战"
const TXT_WAR2_SIDE1 := "莫桑比克"
const TXT_WAR2_SIDE2 := "南非"
const TXT_WAR3_NAME := "南非-津巴布韦之战"
const TXT_WAR3_SIDE1 := "津巴布韦"
const TXT_WAR3_SIDE2 := "南非"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null:
		return
	var zimbabwe := world.get_country_by_legacy_index(127)
	var desc := TXT_DESC_A
	if zimbabwe != null and zimbabwe.puppet_of < 0:
		desc += TXT_DESC_MID
	desc += TXT_DESC_B
	event_def.description = desc



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var south_africa := _country(131)
	var zimbabwe := _country(127)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_start_war(56, TXT_WAR0_NAME, TXT_WAR0_SIDE1, TXT_WAR0_SIDE2, 300, 700, 0, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 2, true)
			_start_war(57, TXT_WAR1_NAME, TXT_WAR1_SIDE1, TXT_WAR1_SIDE2, 300, 700, 0, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 3, true)
			_start_war(58, TXT_WAR2_NAME, TXT_WAR2_SIDE1, TXT_WAR2_SIDE2, 300, 700, 0, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 4, true)
			_start_war(59, TXT_WAR3_NAME, TXT_WAR3_SIDE1, TXT_WAR3_SIDE2, 300, 700, 0, 0, 24)
			if zimbabwe != null:
				_set_part(zimbabwe, 0, true)






func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = -1

func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null

func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n

