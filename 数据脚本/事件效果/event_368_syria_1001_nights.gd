extends "res://数据脚本/event_script_base.gd"

## 原作 Event368.cs：一千零一夜。
## 触发：见 evaluate()（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "支持哈菲兹·阿萨德，并向叙利亚输送援助（需要10.0百万预算与5.0点特工网络）"
const TXT_OPT0_DIS := "中国的国际影响力应高于25......"
const TXT_OPT1 := "支持里法特·阿萨德组织政变（需要5.0百万预算与15.0点特工网络）"
const TXT_OPT1_DIS := "中国的国际影响力应高于35.0或我国正与中情局合作"
const TXT_OPT2 := "忽略"
const TXT_OPT0_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有10百万才能干活......"
const TXT_OPT0_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有5支特工网络才能干活......"
const TXT_OPT0_DIS_INFLUENCE := "中国的国际影响力应高于25......"
const TXT_OPT1_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有5百万才能干活......"
const TXT_OPT1_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有15支特工网络才能干活......"
const TXT_OPT1_DIS_OTHER := "中国的国际影响力应高于35.0或我国正与中情局合作"

const TXT_R0 := "我们向叙利亚输送了大量经济援助，这足以让我们在叙利亚的最高层权力精英中组织亲中派政治势力。\n在此之前，因苏联提供优惠贷款而对其效忠的哈菲兹·阿萨德，也开始更密切地关注中国。\n于此相对应的是，阿萨德王朝内的冲突被严厉且毫不留情的方式给解决了：亲总统的共和国卫队解除了“国防旅”的武装。作为总统之弟的里法特·阿萨德也被公众看作是“腐败象征”，并因叛乱未遂而受审。"
const TXT_R1 := "我们成功组织了对叙利亚现任总统哈菲兹·阿萨德的政变。\n里法特·阿萨德在得到不满于哈菲兹政策的政治精英们的忠诚后，便宣布有人在总统生病期间，试图策动政治阴谋。因此，他借机调动了自己的“国防旅”。不忠于里法特的势力被纷纷逮捕。尽管哈菲兹·阿萨德拒绝任命他的弟弟为代理总统，但大局已定。\n在新领导人的施政纲领中，里法特·阿萨德选择了亲美亲西的外交路线，并在国内实施自由化改革。"
const TXT_R2 := "里法特·阿萨德的政变尝试失败了。在短暂的政治冲突与借总统生病而实行的舆论攻势后，里法特·阿萨德不得不抛下所有政府职位并离开叙利亚。\n作为回应，哈菲兹·阿萨德撤出了驻扎在黎巴嫩的叙利亚部队，并开始实施旨在实现自由化与经济复苏的改革。"
const TXT_R1_OK := "我们成功组织了对叙利亚现任总统哈菲兹·阿萨德的政变。\n里法特·阿萨德在得到不满于哈菲兹政策的政治精英们的忠诚后，便宣布有人在总统生病期间，试图策动政治阴谋。因此，他借机调动了自己的“国防旅”。不忠于里法特的势力被纷纷逮捕。尽管哈菲兹·阿萨德拒绝任命他的弟弟为代理总统，但大局已定。\n在新领导人的施政纲领中，里法特·阿萨德选择了亲美亲西的外交路线，并在国内实施自由化改革。"
const TXT_R1_FAIL := "政变失败了！有人（可能是苏联顾问）将里法特·阿萨德试图组织政变阴谋的消息传给了哈菲兹·阿萨德总统。这导致里法特迅速被捕，并被驱逐出境。“国防旅”也被解散。\n此前在外交上行动谨慎的哈菲兹·阿萨德，则越加向苏联靠拢。"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var syria := world.get_country_by_legacy_index(35)
	var date := world.date
	if date == null:
		return false
	if world.completed_event_ids.has("event_707"):
		return false
	if world.get_flag("oar"):
		return false
	if syria == null:
		return false
	if syria.has_tag("sev"):
		return false
	if syria.government == 1:
		return false
	if syria.has_tag("econ"):
		return false
	if int(world.completed_event_ids.get("event_564", 0)) == 1:
		return false
	var branch := false
	if world.completed_event_ids.has("event_564") and date.year == 1983 and date.day > 14 and date.month >= 11 \
			and syria.sub_government == 10:
		branch = true
	if world.wars.size() > 3 and world.wars[3] != null and world.wars[3].is_going \
			and date.year == 1983 and date.day > 14 and date.month >= 11:
		branch = true
	if world.wars.size() > 28 and world.wars[28] != null and world.wars[28].is_going and date.year >= 1981:
		branch = true
	return branch


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var dv := world.数值表
	var budget_reserve := _budget_reserve(world)
	var agents := dv[W.I_AGENTS] if dv.size() > W.I_AGENTS else 0
	var usa := world.get_country_by_legacy_index(51)
	var usa_dev := usa.development if usa != null else 0
	if budget_reserve >= 100 and agents >= 50:
		_enable(opt[0], TXT_OPT0)
	else:
		var dis0 := TXT_OPT0_DIS
		if budget_reserve < 100:
			dis0 = TXT_OPT0_DIS_BUDGET
		elif agents < 50:
			dis0 = TXT_OPT0_DIS_AGENTS
		else:
			dis0 = TXT_OPT0_DIS_INFLUENCE
		_disable(opt[0], dis0)
	if budget_reserve >= 50 and agents >= 150 and (world.influence_prc >= 350 or usa_dev > 0):
		_enable(opt[1], TXT_OPT1)
	else:
		var dis1 := TXT_OPT1_DIS
		if budget_reserve < 50:
			dis1 = TXT_OPT1_DIS_BUDGET
		elif agents < 150:
			dis1 = TXT_OPT1_DIS_AGENTS
		else:
			dis1 = TXT_OPT1_DIS_OTHER
		_disable(opt[1], dis1)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var syria := ws.get_country_by_legacy_index(35)
	match opt:
		0:
			if syria != null:
				_establish_prochina(syria)
				syria.set_tag("对华贸易", true)
				syria.government = 0
				syria.sub_government = 10
			_add_power(EmpireData.USSR, -20)
			ws.influence_prc += 20
			_add(W.I_DIPLO, 10)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_PARTY_SUPPORT, 100)
			context["result_text"] = TXT_R0
		1:
			if ws.influence_prc >= ws.empires[1].power:
				if syria != null:
					_establish_proamerican(syria)
					syria.set_tag("对华贸易", true)
					syria.government = 3
					syria.sub_government = 5
				_add_power(EmpireData.USSR, -20)
				_add_power(EmpireData.USA, 20)
				_add(W.I_DIPLO, -10)
				_add(W.I_BUDGET, -50)
				_add(W.I_AGENTS, -150)
				_add(W.I_PARTY_SUPPORT, 50)
				context["result_text"] = TXT_R1_OK
			else:
				if syria != null:
					syria.sub_government = 15
				_add(W.I_DIPLO, -10)
				_add(W.I_BUDGET, -50)
				_add(W.I_AGENTS, -150)
				_add_power(EmpireData.USSR, 20)
				_add(W.I_PARTY_SUPPORT, -300)
				context["result_text"] = TXT_R1_FAIL
		2:
			if syria != null:
				syria.government = 2
				syria.sub_government = 15
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

