extends "res://数据脚本/event_script_base.gd"

## 原作 Event606.cs：La Patrie ou la Mort（尼日尔革命，单选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:4364-4366（this_type 外交按钮）手动 number_event=606。
## 差异：描述按 c21.Gosstroy==3 动态插入“法国和”句；proprc→亲中、Torg→对华贸易。

const TXT_TITLE := "La\u00a0Patrie\u00a0ou\u00a0la\u00a0Mort"
const TXT_DESC := "尼日尔，一个命运多舛的西非国家。在独立后的前14年里，由哈马尼·迪奥里总统领导的一党文人政权统治。在他的统治下，尼日尔初步建立成了一个国家而非大部落，经济发展和工业化进程有所放缓。借助铀矿和在阿尔及利亚独立战争中支持法国，该国得到了法兰西的善意。除了和达荷美（也就是贝宁）的边界争端外，该国其他非洲国家的关系大多“积极”。在此期间，尼日尔一直是一党制国家，迪奥里躲过了1963年的预谋政变和1965年的暗杀企图，但一手造成的腐败，专制主义，饥荒和暴动葬送了他的王朝。最终以赛义尼·孔切上校和他的最高军事委员会接过了烂摊子随着铀价暴跌，经济繁荣结束，国际货币基金组织牵头的紧缩政策和私有化措施引起一些尼日尔人的反对。\n现在，随着孔切的战友一个接着一个都被送去见了戴高乐。马里，布基纳法索和贝宁正在准备中一场彻底推翻孔切政权的行动。"
const TXT_OPT0 := "Eux\u00a0vaincrons！"
const TXT_R0_A := "三国组建了一支统一调度的武装部队，代号“尼日尔河”的行动一触即发。在得到尼亚美的信息之后，三军从北，西和南方攻入了该国。布基纳法索人民军迅速开入了尼亚美，在尼日尔国内的萨瓦巴的帮助下顺利攻占了首都总统府和广播电台，号召全体人民起义，夺权，彻底革命。而"
const TXT_R0_MID := "法国和"
const TXT_R0_B := "美国拒绝武装介入这一问题。仅仅是谴责了三国的暴力行为，提供了除干涉外的一切帮助。\n随后，孔切被宣判有蓄意谋杀罪，叛国罪，种族灭绝罪而被判处死刑。非洲社会主义运动-萨瓦巴党正式成为了该国的领导力量。不久以后该党便出台了执政纲领“尼日尔的共产主义道路”。宣布要以马克思列宁主义的理论为指导，毛泽东思想为武器，建立巩固和保卫社会主义新尼日尔。"
const TXT_R0_TAIL := "法国大使被列为最不受欢迎的人和特务从而驱逐出境，法国掌握的铀矿也被完全国有化，是尼日尔人的国有化。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var france := _country(21)
	var niger := _country(56)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0_A
			if france != null and france.government == 3:
				text += TXT_R0_MID
			text += TXT_R0_B
			if france != null and france.government == 3:
				text += TXT_R0_TAIL
			context["result_text"] = text
			if niger != null:
				niger.government = 1
				niger.sub_government = 17
				_leave_alliances(niger)
				niger.set_tag("亲中", true)
				niger.set_tag("对华贸易", true)
			if france != null and france.government == 3:
				france.set_tag("对华贸易", false)
			_add(W.I_DIPLO, 30)
			_add(W.I_ARMY, -100)
			ws.influence_prc += 30
			_add_relation(EmpireData.USA, -150)
			_add_power(EmpireData.USA, -30)



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

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

