extends "res://数据脚本/event_script_base.gd"

## 原作 Event369.cs：重蹈覆辙？。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



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
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var dv := world
	var budget_reserve := _budget_reserve(world)
	var agents := dv.agents if dv.size() > W.I_AGENTS else 0
	var army := dv.army if dv.size() > W.I_ARMY else 0
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
			# 原版 TickTime(10)，但 TimeScript.WorldWarsDone 对 war9 另有 fortnight_go>=12 门槛，
			# 有效超时 = max(10,12)=12。
			_start_war(9, TXT_WAR9_SIDE1, TXT_WAR9_SIDE2, 800 - num, 200 + num, 0, 1, TXT_WAR9_NAME, 12)
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




func _prev_result(world: WorldState, event_id: String) -> int:
	return int(world.completed_event_ids.get(event_id, 0))


func _budget_reserve(world: WorldState) -> int:
	var total := 0
	var dv := world
	if dv.size() > W.I_BUDGET:
		total += dv.budget
	if dv.size() > W.I_RESERVE:
		total += dv.reserve
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

