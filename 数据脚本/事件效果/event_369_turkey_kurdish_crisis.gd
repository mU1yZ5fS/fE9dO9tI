extends "res://数据脚本/event_script_base.gd"

## 原作 Event369.cs：重蹈覆辙？。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。

const TXT_TITLE := "重蹈覆辙？"

const TXT_DESC := "由军政府官员与亲法西斯主义组织民族运动党联合执政的土耳其，已经走上了一条压迫少数民族的道路、自20世纪70年代末期，库尔德斯坦工人党便已开始为实现民族独立而战。但在土耳其军事政变后，该党的准军事组织便不得不躲藏在山区之中，并撤往土耳其与叙利亚和伊拉克之间的边界。\n近日，军政府批准了土耳其的新宪法，其中包含了民族主义色彩极其明显的条款。例如，土耳其国的领土与民族是不可分割的有机整体，且除去国语以外的其他语言均被禁止。政府同时还对库尔德人实施了歧视性政策：新生儿不得取库尔德人名字、位于边界的民族社群不得拥有自己的牲口。\n出于遏制库尔德民族主义的需要，军政府向库尔德人聚居区增派了部队，并对当地人口组织大屠杀。当局的这一行动被许多国家视为种族灭绝。上述事件甚至还引起了移民危机——难民纷纷逃往伊拉克与叙利亚。土耳其军方则使用各种各样的反人道战术，甚至将当地居民掠为人质以逼迫部分游击队投降。\n显然，一场区域危机即将愈演愈烈，它甚至可能激化全世界的紧张局势。对此，我们该怎么做？"

const TXT_OPT0 := "与苏联一道施压联合国，将土耳其民族主义认定为法西斯主义变种"
const TXT_OPT0_DIS := "与苏联的关系还未实现正常化......"
const TXT_OPT1 := "武装库尔德人，并为其输送军事援助（需要25.0百万预算、15.0点特工网络与30.0点军事实力）"
const TXT_OPT1_DIS := "我们对库尔德地区鞭长莫及......"
const TXT_OPT2 := "我们支持一个民族，一个国家原则......"
const TXT_OPT3 := "对土耳其实施经济制裁"
const TXT_OPT1_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有20百万才能干活......"
const TXT_OPT1_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有15支特工网络才能干活......"
const TXT_OPT1_DIS_ARMY := "军事实力必须强于30......"
const TXT_OPT1_DIS_OTHER := "我们对库尔德地区鞭长莫及......"
const TXT_WAR9_NAME := "土耳其-库尔德之战"
const TXT_WAR9_SIDE1 := "政府军"
const TXT_WAR9_SIDE2 := "库尔德人"

const TXT_R0 := "联合国以多数投票通过了苏联与中国提出的决议案，并承认土耳其民族主义是一类种族主义与种族歧视。所有的社会主义国家与阿拉伯国家均对此表示“赞成”，而西方国家则选择“反对”。\n因此，土耳其民族主义将被同种族隔离制度与锡安主义等量齐观，许多中东与东欧国家选择与侵略者断绝外交关系。"
const TXT_R1 := "位于土耳其边界的库尔德民族解放力量走上战场，并对土耳其属库尔德斯坦发起了进攻。他们成功的击败了政府部队。然而，土耳其方的增援将如期而至。目前还不清楚库尔德人游击队能够在冲突中支撑多久。"
const TXT_R2 := "尽管国际社会已经对土耳其施加了各类压力。然而，军政府仍在实行其驱逐少数民族出境与种族灭绝政策。政府领导人凯南·埃夫伦声称：“直到最后一个库尔德恐怖分子人头落地，我们才会收手。”"
const TXT_R3 := "我们已经单方面切断了与军政府的贸易与外交关系。\n尽管国际社会已经对土耳其施加了各类压力。然而，军政府仍在实行其驱逐少数民族出境与种族灭绝政策。政府领导人凯南·埃夫伦声称：“直到最后一个库尔德恐怖分子人头落地，我们才会收手。”"
const TXT_R0_OK := "联合国以多数投票通过了苏联与中国提出的决议案，并承认土耳其民族主义是一类种族主义与种族歧视。所有的社会主义国家与阿拉伯国家均对此表示“赞成”，而西方国家则选择“反对”。\n因此，土耳其民族主义将被同种族隔离制度与锡安主义等量齐观，许多中东与东欧国家选择与侵略者断绝外交关系。"
const TXT_R0_FAIL := "联合国以多数投票否决了苏联与中国提出的决议案，不承认土耳其民族主义是一类种族主义与种族歧视。尽管苏东集团的所有国家均投票“支持”该议案，但阿拉伯世界决定弃权。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var dv := world.数值表
	var budget_reserve := _budget_reserve(world)
	var agents := dv[W.I_AGENTS] if dv.size() > W.I_AGENTS else 0
	var army := dv[W.I_ARMY] if dv.size() > W.I_ARMY else 0
	if world.get_flag("relres"):
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	var syria := world.get_country_by_legacy_index(35)
	var iraq := world.get_country_by_legacy_index(14)
	var iran := world.get_country_by_legacy_index(8)
	var any_pro := (syria != null and syria.has_tag("亲中")) \
			or (iraq != null and iraq.has_tag("亲中")) \
			or (iran != null and (iran.has_tag("亲中") or iran.has_tag("okb")))
	if budget_reserve >= 250 and agents >= 150 and army >= 300 and any_pro:
		_enable(opt[1], TXT_OPT1)
	else:
		var dis1 := TXT_OPT1_DIS
		if budget_reserve < 200:
			dis1 = TXT_OPT1_DIS_BUDGET
		elif agents < 150:
			dis1 = TXT_OPT1_DIS_AGENTS
		elif army < 300:
			dis1 = TXT_OPT1_DIS_ARMY
		else:
			dis1 = TXT_OPT1_DIS_OTHER
		_disable(opt[1], dis1)
	_enable(opt[2], TXT_OPT2)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var turkey := ws.get_country_by_legacy_index(84)
	match opt:
		0:
			if ws.empires[1].power + ws.influence_prc <= ws.empires[0].power:
				_add_power(EmpireData.USA, 10)
				_add(W.I_PARTY_SUPPORT, -50)
				_add(W.I_THOUGHT_FREEDOM, 50)
				context["result_text"] = TXT_R0_FAIL
			else:
				_add_power(EmpireData.USSR, 10)
				ws.influence_prc += 10
				_add_power(EmpireData.USA, -20)
				_add(W.I_DIPLO, -20)
				_add(W.I_THOUGHT_FREEDOM, -50)
				_add_relation(EmpireData.USA, -100)
				_add_relation(EmpireData.USSR, 100)
				if _faction_leading_0_1_2():
					_add(W.I_PARTY_SUPPORT, 50)
				else:
					_add(W.I_PARTY_SUPPORT, -50)
				context["result_text"] = TXT_R0_OK
		1:
			var syria := ws.get_country_by_legacy_index(35)
			var iraq := ws.get_country_by_legacy_index(14)
			var iran := ws.get_country_by_legacy_index(8)
			var num := 0
			if syria != null and syria.has_tag("亲中"):
				num += 5
			elif iraq != null and iraq.has_tag("亲中"):
				num += 5
			elif iran != null and (iran.has_tag("亲中") or iran.has_tag("okb")):
				num += 5
			if turkey != null:
				turkey.set_tag("对华贸易", false)
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -200)
			_start_war(9, TXT_WAR9_SIDE1, TXT_WAR9_SIDE2, 800 - num, 200 + num, 0, 1, TXT_WAR9_NAME, 10)
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2
		3:
			if turkey != null:
				turkey.set_tag("对华贸易", false)
			_add(W.I_DIPLO, -50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -100)
			context["result_text"] = TXT_R3


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _prev_result(world: WorldState, event_id: String) -> int:
	return int(world.completed_event_ids.get(event_id, 0))


func _budget_reserve(world: WorldState) -> int:
	var total := 0
	var dv := world.数值表
	if dv.size() > W.I_BUDGET:
		total += dv[W.I_BUDGET]
	if dv.size() > W.I_RESERVE:
		total += dv[W.I_RESERVE]
	return total


func _faction_leading(i: int) -> bool:
	return GameManager != null and GameManager.is_faction_leading(i)


func _faction_leading_0_1_2() -> bool:
	return _faction_leading(0) or _faction_leading(1) or _faction_leading(2)


func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _establish_proamerican(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", false)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", true)


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = tick_time

