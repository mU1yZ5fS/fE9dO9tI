extends "res://数据脚本/event_script_base.gd"

## 原作 Event367.cs：土耳其军事政变。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。

const TXT_TITLE := "土耳其军事政变"

const TXT_DESC := "主席同志！来自土耳其的最新消息！在9月12日，国家安全委员会在国家电视台前宣布发动军事政变。前者由该国武装部队司令凯南·埃夫伦领导，并解散了土耳其议会与苏莱曼·德米雷尔领导的政府。军官团宣布在国内禁止罢工与工会运动，同时暂停了该国大多数政党的获得，乃至正延续的凯末尔世俗化改革。在近期公布的相关文件中，新政府表示将遵守与土耳其有关的全部条约与政治联盟，其中也包括北约。\n议会内的所有政党均遭到了镇压。\n根据目前的处境，我们可以考虑采取以下措施。"

const TXT_OPT0 := "组织反军政府的民主派地下起义（需要25.0百万预算、15.0点特工网络与20.0点军事实力）"
const TXT_OPT0_DIS := "地下网络实力过于弱小！"
const TXT_OPT1 := "与军政府与极右翼势力建立联系（需要25.0百万预算与15.0点特工网络）"
const TXT_OPT1_DIS := "地下网络实力过于弱小！"
const TXT_OPT2 := "忽略"
const TXT_OPT3 := "承认军政府"
const TXT_OPT4 := "拒不承认军政府"
const TXT_OPT0_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有25百万才能干活......"
const TXT_OPT0_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有15支特工网络才能干活......"
const TXT_OPT0_DIS_ARMY := "军事实力必须强于20......"
const TXT_OPT0_DIS_INFLUENCE := "中国的国际影响力应高于20......"
const TXT_OPT0_DIS_OTHER := "地下网络实力过于弱小！"
const TXT_OPT1_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有25百万才能干活......"
const TXT_OPT1_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有15支特工网络才能干活......"
const TXT_OPT1_DIS_INFLUENCE := "中国的国际影响力应高于20......"
const TXT_OPT1_DIS_OTHER := "地下网络实力过于弱小！"
const TXT_WAR8_NAME := "土耳其内战"
const TXT_WAR8_SIDE1 := "军方"
const TXT_WAR8_SIDE2 := "地下网络"

const TXT_R0 := "多亏了我国情报网络对土耳其民主派和多个激进左翼组织的积极工作，这些反军政府的进步力量得以成立一个联合阵线。我们通过秘密渠道向他们输送武器，并支持他们在土耳其全国范围内发起起义——土耳其工人党联合“革命之路”和“革命青年”，利用工会、工人和学生的支持以及民众对经济形势的不满，同时在游击队的支持下在各个城市中发起了起义；部分进步军官和凯末尔主义的支持者倒向了共和人民党，宣称要“保卫国父的遗产”，加入了反军政府的战斗。尽管在民主运动存在各自为战与分裂的倾向，但反叛军依然是一支不可小视的势力，并对军政府的武装力量造成了沉重打击。\n然而，该国正逐渐滑向内战的深渊……"
const TXT_R1 := "多亏了我国情报网络对土耳其极右翼势力的积极工作，我们得以“纠正”民族行动党与“灰狼”组织行动方针内的所有疏漏之处。因此，他们得以将自己的代表安插进入政府，从而同军政府勾结一致。\n他们合力拓展了对该国共产主义者、民主派、左翼作家、持不同政见者与少数民族的迫害。“死亡集中营”开遍了全国，法外处决与“黑名单”制度已经成为了土耳其政治生活的常态。\n国际社会普遍谴责此次军事政变。"
const TXT_R2 := "国际社会普遍谴责此次军事政变，但我们选择对其视而不见。"
const TXT_R3 := "我们支持此次军事政变。中国外交部长宣称，此次事件是“维护国家主权与领土完整的唯一途径”。国际社会普遍谴责此次军事政变。"
const TXT_R4 := "我们反对此次军事政变。中国外交部长宣称，此次事件是“反动违宪政变”。国际社会普遍谴责此次军事政变。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	var dv := world.数值表
	var budget_reserve := _budget_reserve(world)
	var agents := dv[W.I_AGENTS] if dv.size() > W.I_AGENTS else 0
	var army := dv[W.I_ARMY] if dv.size() > W.I_ARMY else 0
	var r366 := _prev_result(world, "event_366")
	if r366 == 0 and budget_reserve >= 250 and agents >= 150 and world.influence_prc >= 200 and army >= 200:
		_enable(opt[0], TXT_OPT0)
	else:
		var dis0 := TXT_OPT0_DIS
		if budget_reserve < 250:
			dis0 = TXT_OPT0_DIS_BUDGET
		elif agents < 150:
			dis0 = TXT_OPT0_DIS_AGENTS
		elif army < 200:
			dis0 = TXT_OPT0_DIS_ARMY
		elif world.influence_prc < 200:
			dis0 = TXT_OPT0_DIS_INFLUENCE
		else:
			dis0 = TXT_OPT0_DIS_OTHER
		_disable(opt[0], dis0)
	if r366 == 1 and budget_reserve >= 250 and agents >= 150 and world.influence_prc >= 200:
		_enable(opt[1], TXT_OPT1)
	else:
		var dis1 := TXT_OPT1_DIS
		if budget_reserve < 250:
			dis1 = TXT_OPT1_DIS_BUDGET
		elif agents < 150:
			dis1 = TXT_OPT1_DIS_AGENTS
		elif world.influence_prc < 200:
			dis1 = TXT_OPT1_DIS_INFLUENCE
		else:
			dis1 = TXT_OPT1_DIS_OTHER
		_disable(opt[1], dis1)
	_enable(opt[2], TXT_OPT2)
	_enable(opt[3], TXT_OPT3)
	_enable(opt[4], TXT_OPT4)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey != null:
		turkey.government = 0
		turkey.sub_government = 7
	match opt:
		0:
			if _faction_leading_0_1_2():
				_add(W.I_PARTY_SUPPORT, 150)
			else:
				_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_MIL_INTERVENTION, 1000)
			_add_relation(EmpireData.USA, -200)
			_add_relation(EmpireData.USSR, 100)
			_add_power(EmpireData.USA, -20)
			_add(W.I_DIPLO, 20)
			_add(W.I_BUDGET, -250)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -200)
			_start_war(8, TXT_WAR8_SIDE1, TXT_WAR8_SIDE2, 800, 200, 0, 1, TXT_WAR8_NAME, 20)
			context["result_text"] = TXT_R0
		1:
			if turkey != null:
				turkey.sub_government = 9
				turkey.set_tag("对华贸易", true)
			var c87 := ws.get_country_by_legacy_index(87)
			if c87 != null:
				c87.special -= 5
			if _faction_leading_0_1_2():
				_add(W.I_PARTY_SUPPORT, 150)
			else:
				_add(W.I_PARTY_SUPPORT, -100)
			_add_relation(EmpireData.USA, -200)
			_add_relation(EmpireData.USSR, -200)
			_add_power(EmpireData.USA, -30)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -250)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -200)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PARTY_SUPPORT, -50)
			context["result_text"] = TXT_R2
		3:
			if _faction_leading_0_1_2():
				_add(W.I_PARTY_SUPPORT, -150)
			else:
				_add(W.I_PARTY_SUPPORT, 100)
			context["result_text"] = TXT_R3
		4:
			if _faction_leading_0_1_2():
				_add(W.I_PARTY_SUPPORT, 150)
			else:
				_add(W.I_PARTY_SUPPORT, -100)
			_add_relation(EmpireData.USA, -300)
			_add_relation(EmpireData.USSR, 200)
			_add_power(EmpireData.USA, 20)
			context["result_text"] = TXT_R4


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

