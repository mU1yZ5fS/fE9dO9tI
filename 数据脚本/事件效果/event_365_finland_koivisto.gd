extends "res://数据脚本/event_script_base.gd"

## 原作 Event365.cs：亲苏反共派的离任。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "我们选择支持芬兰社会民主党与毛诺·科伊维斯托"
const TXT_OPT0_DIS := "中国并不是经济互助委员会的成员......"
const TXT_OPT1 := "让我们帮助右翼民主党人"
const TXT_OPT1_DIS := "中国的国际影响力应高于15.0......"
const TXT_OPT2 := "不闻不问"
const TXT_OPT0_DIS_NOT_SEV := "中国并不是经济互助委员会的成员......"
const TXT_OPT0_DIS_IDEOLOGY := "我们可不能支持修正主义者......"
const TXT_OPT0_DIS_INFLUENCE := "中国的国际影响力应高于30.0......"
const TXT_OPT0_DIS_AGENTS := "就位的特工网络必须多于10.0支......"
const TXT_OPT0_DIS_BUDGET := "手头的资金必须多于10.0百万......"
const TXT_OPT1_DIS_INFLUENCE := "中国的国际影响力应高于15.0......"
const TXT_OPT1_DIS_RELRES := "可不能在前脚与苏联和好后，后脚就捅刀子......"
const TXT_OPT1_DIS_AGENTS := "就位的特工网络必须多于10.0支......"
const TXT_OPT1_DIS_BUDGET := "手头的资金必须多于10.0百万......"

const TXT_R0 := "在芬兰总统选举时，我们对芬兰社会民主党提供了全方面支持，比如对该党的财政援助（当然，不只限于财政支持）。现在，科伊维斯托与社会民主党人的竞选海报遍及芬兰各地，在电视上，对国民联盟的大规模攻击也同步开始。该党的领导人哈里·霍尔克里则被指控其在任职芬兰银行董事时期，便参与了大规模腐败。在民众愤怒的压力面前，他不得不退出竞选。\n在选举中，毛伊·科伊维斯托轻易击败了来自中间派的前总理约翰内斯·维罗莱宁，并拿下71%的选票。\n新总统上任伊始，便解散了右翼自由派议会，并组织了新一轮选举。在我们的财政资助与囊括社会民主党、共产党与环保主义者的三方统一战线的合力下，左翼得以拿下67%的选票，获得制宪多数。\n作为对我们赞助其获得胜利的感谢，新任议会做出的第一项决定，便是让芬兰加入经济互助委员会。"
const TXT_R1 := "通过一系列明枪暗箭，我们终于得以将不受欢迎的民族民主派候选人哈里·霍尔克里给艰难推上芬兰总统宝座。多亏了我们特工的出色工作，来自芬兰人民民主联盟的共产党候选人被发现死于家中，根据专家鉴定，死因为服毒自杀。中间派领导人兼前首相约翰内斯·维罗莱宁则在奥卢做演讲时被狙击手暗杀，袭击者不知所踪。上述事件大大增强了“民族联盟”的势力，前者借机开始向社会民主党泼脏水，并称他们为试图摧毁芬兰国家认同的克里姆林傀儡，试图建立“芬兰人民的监狱”。\n在选举中，哈里·霍尔克里以4%的微弱优势超越社会民主党，并获得38%的支持率。新政府上任之初便实行亲西政策，并宣称苏联对芬兰有着帝国主义野心，企图将该国再度奴役并建立“共产主义殖民地”。当然，他们不会忘记我们的帮助，我们因此得到了一份非常有利可图的合同。"
const TXT_R2 := "芬兰社会民主党与毛诺·科伊维斯托取得了压倒性胜利，赢得了43%的选票，与之最接近的对手才获得18%的选票、新政府宣布深化社会经济改革，并支持社会上的弱势群体。它同时宣布继续实行同苏联与社会主义阵营合作的政策。然而，我们对此并不关心。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var dv := world.数值表
	var china := world.get_country_by_legacy_index(1)
	var usa := world.get_country_by_legacy_index(51)
	var budget_reserve := _budget_reserve(world)
	var ideology := dv[W.I_IDEOLOGY] if dv.size() > W.I_IDEOLOGY else 0
	var agents := dv[W.I_AGENTS] if dv.size() > W.I_AGENTS else 0
	var china_sev := china != null and china.has_tag("sev")
	if china_sev and world.influence_prc >= 300 and ideology > 1 and budget_reserve >= 100 and agents >= 100:
		_enable(opt[0], TXT_OPT0)
	else:
		var dis0 := TXT_OPT0_DIS
		if not china_sev:
			dis0 = TXT_OPT0_DIS_NOT_SEV
		elif ideology <= 1:
			dis0 = TXT_OPT0_DIS_IDEOLOGY
		elif world.influence_prc < 300:
			dis0 = TXT_OPT0_DIS_INFLUENCE
		elif agents < 100:
			dis0 = TXT_OPT0_DIS_AGENTS
		else:
			dis0 = TXT_OPT0_DIS_BUDGET
		_disable(opt[0], dis0)
	var usa_dev := usa.development if usa != null else 0
	if budget_reserve >= 100 and agents >= 100 and not world.get_flag("relres") \
			and (world.influence_prc >= 150 or usa_dev > 0):
		_enable(opt[1], TXT_OPT1)
	else:
		var dis1 := TXT_OPT1_DIS
		if world.influence_prc < 150 and usa_dev <= 0:
			dis1 = TXT_OPT1_DIS_INFLUENCE
		elif world.get_flag("relres"):
			dis1 = TXT_OPT1_DIS_RELRES
		elif agents < 100:
			dis1 = TXT_OPT1_DIS_AGENTS
		else:
			dis1 = TXT_OPT1_DIS_BUDGET
		_disable(opt[1], dis1)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var finland := ws.get_country_by_legacy_index(26)
	match opt:
		0:
			if finland != null:
				finland.sub_government = 3
				finland.set_tag("sev", true)
			ws.influence_prc += 10
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, -30)
			_add_power(EmpireData.USSR, 10)
			if d.size() > W.I_ECON_DISPLAY and d[W.I_ECON_DISPLAY] < 35:
				_add(W.I_PARTY_SUPPORT, -100)
			else:
				_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = TXT_R0
		1:
			if finland != null:
				finland.government = 3
				finland.sub_government = 6
				finland.set_tag("亲苏", false)
				finland.set_tag("对华贸易", true)
			ws.influence_prc += 20
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, -60)
			if d.size() > W.I_ECON_DISPLAY and d[W.I_ECON_DISPLAY] < 36:
				_add(W.I_PARTY_SUPPORT, -100)
			else:
				_add(W.I_PARTY_SUPPORT, 50)
			_add_power(EmpireData.USSR, -20)
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2




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

