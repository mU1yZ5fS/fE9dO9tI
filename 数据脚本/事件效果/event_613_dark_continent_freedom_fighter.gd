extends "res://数据脚本/event_script_base.gd"

## 原作 Event613.cs：黑暗大陆的自由斗士（扎伊尔反对派，二选项）。
## 触发：ReqEventForDLC02.cs:909-911 —— c117.SubGosstroy==7 && c117.Torg && DATE_AFTER 1982.2.15。
## 差异：level_of_dev→level_of_development；Torg→对华贸易。

const TXT_TITLE := "黑暗大陆的自由斗士"
const TXT_DESC := "蒙博托也许不会预料到，自己最亲昵的战友会背叛自己。艾迪安·奇塞克蒂作为蒙博托长久以来的战友和忠实拥蹩，在被蒙博托因为政治洗牌中踢出了中央后竟然自立山头。他组建了民主与社会进步联盟，这是扎伊尔国内最大，也是唯一的一个反对派组织。主席同志，扎伊尔的领袖越发变得偏执而又狂热，也许我们及时的跳船是更好的选择？"
const TXT_OPT0 := "为该组织提供保障"
const TXT_OPT0_DIS := "我们不在乎这些费拉不堪的自由派"
const TXT_OPT1 := "维持现状最好"
const TXT_R0 := "扎伊尔军队在数次对外战争中的灾难性战果导致蒙博托的名声江河日下，MRP内部也因此出现了分裂，财政赤字与外债急剧飙升，罢工游行接连不断，加丹加和基伍省的叛乱层出不穷，为此，政府不得不出台紧急措施增收节支，然而这也只是杯水车薪，随着货币贬值，进口商品和生活必需品价格的大幅上涨，人民怨声载道。在这种情况下，反对派的声望水涨船高，其中更少不了我们的“改革换援助计划”大获成功。为了保证国家不至于崩溃，以及我们驻扎在扎伊尔的多支武装团体和工作队的压力下，蒙博托事实上向我们低头了。他接纳了这一支反对派作为御用狗哨。\n蒙博托迟早会滚蛋，只不过不是现在……"
const TXT_R1 := "蒙博托能稳坐钓鱼台自有他的艺术，我们只需要顺其自然即可。\n不出意外，蒙博托又一次网罗了罪名，把这位黑暗大陆的自由斗士投入了大牢之中。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line >= 3:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var zaire := _country(117)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if zaire != null:
				zaire.government = 2
				zaire.sub_government = 8
				zaire.level_of_development = 0
			_add_relation(EmpireData.USSR, -50)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 10)
			ws.influence_prc += 10
			_add(W.I_THOUGHT_FREEDOM, -20)
			_add(W.I_AGENTS, -20)
			_add(W.I_BUDGET, -20)
		1:
			context["result_text"] = TXT_R1



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

