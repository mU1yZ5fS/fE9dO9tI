extends "res://数据脚本/event_script_base.gd"

## 原作 Event624.cs：不让暴君再蹂躏你（莫桑比克路线，五选项）。
## 触发：ReqEventForDLC02.cs:944-946 —— c126.parts[0] && DATE_AFTER 1983.4.1；parts ExprNode 不支持 → trigger_script。
## 差异：modifies[7].active→modifiers[7]；proprc→亲中、prosov→亲苏、Torg→对华贸易、isSEV→sev。

const TXT_TITLE := "不让暴君再蹂躏你"
const TXT_DESC := "自1976年3月莫桑比克为制裁罗得西亚，支持津巴布韦人民斗争而主动关闭莫罗边界后，罗得西亚白人政权便不断向莫桑比克发动武装进攻，使莫桑比克受到的直接破坏和损失达3亿美元。莫桑比克因受南非的武装侵略和袭击而遭受的损失重大，仅独立后的8年中就达3.32亿美元，有900家农村商店、495所小学、80个卫生所和140个村庄被破坏，10万农民流离失所，生活无着。与此同时，反政府武装“抵运”在南非和罗得西亚白人政权的支持下，经常袭击村庄、商店、地方政府机构以至向灾区运送食品和救赈物资的车队，炸毁铁路、桥梁、电站和工厂等重要设施，给莫桑比克造成严重破坏。此外，80年代初发生的持续旱灾和世界资本主义经济危机的冲击，更造成莫桑比克严重的经济困难。1981年，莫桑比克大部分工农业减产，出口下降，市场供应紧张，外汇储备几乎枯竭，外债由独立时的7亿美元增加到1982年的10亿美元。1982年的人均国民生产总值只有152美元，比独立前的1973年下降一半左右。有观察家认为，莫桑比克经济已经“濒临崩溃”，国家“正在水中下沉”。因此，莫解阵领导层不得不进行一定程度的解冻。萨莫拉·马谢尔在一次会议上说：“我们对私人企业产生了一种敌视的态度，这是错误的，必须改变。”同时，他强调要对国营企业进行整顿，要求国营企业“提高产量和增加利润”。\n近期召开的莫解阵四大进一步提出要在经济结构中进行实质性改革，要利用价格政策和合同制鼓励集体和私人经济成份的生产，实行权力和责任下放，在外交上，莫解阵也开始让步和转向，同西方交好以争取外资和援助。和大部分非洲的社会主义政权一样，莫桑比克面临着巨大的经济负担，社会主义模式难以稳定地继续下去；而在其中，莫解阵党内部的某些改革的支持者希望进行更大的让步。\n我们是否要做些什么？"
const TXT_OPT0 := "我们将为莫桑比克提供同志般的帮助！"
const TXT_OPT0_DIS := "你吃饱了撑的？"
const TXT_OPT1 := "同苏东阵营合作支援，并邀请其加入社会主义国际分工体系"
const TXT_OPT1_DIS := "为什么要便宜了苏联？"
const TXT_OPT2 := "步子太小了，我们将用他们拒绝不了的条件换取真正的思想解放……"
const TXT_OPT2_DIS := "我们不能支持朋友走下坡路……"
const TXT_OPT3 := "趁机加大对抵运的援助"
const TXT_OPT3_DIS := "我们不能支持白人种族主义政权的走狗！"
const TXT_OPT4 := "我们无能为力"
const TXT_R0 := "我们很快联系到马谢尔同志，向他表示我们愿意为老朋友提供最大的帮助，他十分感动，并表示将限制并减少资产阶级法权在莫桑比克的扩张。很快，粮食、农机、武器、机床、图纸和资金等大量物资被送往莫桑比克，在我们的动员下，坦桑尼亚也开始向莫桑比克派遣志愿小组帮助打击抵运。以帮助我们的同志们加强社会主义建设并打击抵运。获得帮助的马谢尔总统很快在经济能承受的范围内削去了不必要的危险改革，并和我们加强了联系。"
const TXT_R1 := "我们决定利用与苏联的良好关系来帮助莫桑比克减轻经济问题。在我们的直接动员下，意识到莫桑比克有滑向资本主义风险的苏东阵营很快敲定了援助方案。我们和他们一起向莫桑比克提供了一批低息贷款，并开始帮助加大开发该国丰富的矿产和天然气资源，古巴军队和更多来自东欧的专家也出现在了莫桑比克，帮助打击抵运和建设国家。作为交换，莫桑比克加入了经济互助委员会，同苏联和我们加强了关系。"
const TXT_R2 := "莫桑比克之所以经济不行，是因为体制僵化，缺少灵活性和思想解放，超过生产力的生产关系难以为这个落后的非洲国家提供较好的发展和进步。我们为莫解阵党内以若阿金·阿尔贝托·希萨诺为首的改革派提供了支持，我们在看到我们改革开放的成就和可观的援助后，马谢尔不得不在党内的压力和现实情况下做出妥协，退居二线。他推举希萨诺为新总统，自己保留莫解阵党总书记的职位。很快，希萨诺总统就推出了住房私有化、鼓励建立小型私营企业和开展家庭承包制合作社改革、鼓励家庭式的个体经营户和同IMF和世界银行接触并放开物价以及进行部分市场化尝试等政策，我们也继续为他们提供援助和军事训练。"
const TXT_R3 := "莫桑比克经济陷入了困境，当然要为抵运添一把柴。我们向莫抵运提供了更多援助，并将一批莫解阵的情报送到了他们手中。如此大的动作（又或者是抵运对我们两头吃的不满？）还是让莫解阵当局察觉到我们的出卖，他们当即断绝了同我方的联系，并加强了同苏联的关系，还开始转向与西方友好。1983年10月，萨莫拉总统出访比利时、荷兰、葡萄牙、南斯拉夫、法国和英国等西欧六国及欧洲经济共同体，争取更多的经济、技术和军事援助，特别是与葡萄牙签订了《友好合作条约》，大大改善了两国关系。1984年9月，莫桑比克加入了国际货币基金组织和世界银行，后又加入了第三个《洛美协定》，成为欧洲共同体与非洲、加勒比和太平洋地区国家经济合作组织的第65个发展中国家成员国。不过这些都已经不重要了。"
const TXT_R4 := "1983年10月，萨莫拉总统出访比利时、荷兰、葡萄牙、南斯拉夫、法国和英国等西欧六国及欧洲经济共同体，争取更多的经济、技术和军事援助，特别是与葡萄牙签订了《友好合作条约》，大大改善了两国关系。1984年9月，莫桑比克加入了国际货币基金组织和世界银行，后又加入了第三个《洛美协定》，成为欧洲共同体与非洲、加勒比和太平洋地区国家经济合作组织的第65个发展中国家成员国。萨莫拉执政后期又开始与南非改善了关系。1984年3月，在美国斡旋下，萨莫拉总统与南非总理彼得·博塔在两国交界处的恩科马蒂河畔签署了《瓦不侵犯和睦邻条约》，亦称《恩科马蒂条约》，规定双方相互尊重主权和独立，互不干涉内政，互不支持对方的反政府力量，这对消除莫桑比克的外患和遏制南非对“抵运”的支持都具有一定的积极作用。1984年10月，颁布了《莫桑比克人民共和国投资法》，欢迎和鼓励外国投资。1985年5月，莫桑比克总统府经济事务部长维洛佐主持召开了有近百名国营和私营企业主参加的会议，听取他们对国民经济问题的意见和建议。会后，莫桑比克政府对这些建议和意见进行了“认真讨论，并立即作出反应”，提出了“关于重新活跃生产和商业的15条措施”……"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 5:
		return
	_bind_world()
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if china != null and china.has_tag("sev") and world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 600:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line > 1 and line != 4 and _mod_active(7):
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if _res_ev("event_623") == 1 and d[W.I_WAR_SUPPORT] >= 700:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], TXT_OPT4)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var mozambique := _country(126)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if mozambique != null:
				mozambique.level_of_instability += 50
				_leave_alliances(mozambique)
				mozambique.set_tag("对华贸易", true)
				mozambique.set_tag("亲中", true)
			ws.influence_prc += 25
			_add(W.I_ARMY, -100)
			_add(W.I_BUDGET, -200)
		1:
			context["result_text"] = TXT_R1
			if mozambique != null:
				mozambique.level_of_instability += 70
				mozambique.set_tag("sev", true)
			_add(W.I_BUDGET, -50)
			ws.influence_prc += 5
			_add_power(EmpireData.USSR, 20)
		2:
			context["result_text"] = TXT_R2
			if mozambique != null:
				mozambique.government = 2
				mozambique.sub_government = 21
				_leave_alliances(mozambique)
				mozambique.set_tag("对华贸易", true)
				mozambique.set_tag("亲中", true)
			ws.influence_prc += 15
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -150)
		3:
			context["result_text"] = TXT_R3
			if mozambique != null:
				mozambique.level_of_instability -= 50
				_leave_alliances(mozambique)
				mozambique.set_tag("对华贸易", true)
				mozambique.set_tag("亲苏", true)
			ws.influence_prc += 25
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -100)
		4:
			context["result_text"] = TXT_R4
			if mozambique != null:
				mozambique.level_of_instability += 20



func evaluate(world: WorldState) -> bool:

	if world == null:
		return false
	var mozambique := world.get_country_by_legacy_index(126)
	if mozambique == null or not (mozambique.parts.size() > 0 and mozambique.parts[0]):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	if d.size() <= W.I_YEAR or d.size() <= W.I_MONTH:
		return false
	return d[W.I_YEAR] >= 1984 or (d[W.I_YEAR] == 1983 and d[W.I_MONTH] >= 4)



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

