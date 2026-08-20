extends "res://数据脚本/event_script_base.gd"

## 原作 Event618.cs：众神之战车（喀麦隆政变，四选项）。
## 触发：ReqEventForDLC02.cs:924-926 —— !event_done[617] && c66.SubGosstroy==7 && DATE_AFTER 1984.4.5。
## 差异：OilProd 已建模（ws.oil_prod），result0成功线/1/2 各 +100；IsSocialism(true,61)→ws.is_socialism(c61,true)；proprc→亲中。

const TXT_OPT0_DIS := "我们不能支持阴谋小帮派集团"
const TXT_OPT1_DIS := "我们为什么要在两个亲法分子里选一个？"
const TXT_OPT2_DIS := "我们为什么要帮那个亲法分子？"
const TXT_R0_SUC := "一切按计划进行。在我方的支持下，JOSE很快发动其旗下的部队行动，政变军队很快突袭了总统府、总参谋部、国家广播电台、机场以及其他的重要设施，UPC也很快利用其地下网络，动员工人发起罢工，组建工人民兵，并调动人民解放阵线的力量配合行动。最终，在雅温得经过几天的激烈战斗后，政变方取得了胜利，比亚、阿希乔统治集团被公审，喀麦隆民族联盟被取缔。姆巴拉·盖兰迪被任命为新总统，JOSE与UPC的成员都进入了新的政府。仿照布基纳法索的模式，全国革命委员会以及各地的保卫革命委员会成立了，并开始仿照他们的模式进行改革。|"
const TXT_R0_SOC := "新政府很快开始进行土地改革、国有化、建设基础设施以及推广社会保障政策，宣扬爱国主义和社会主义，并打击部族主义和腐败，推进自力更生，废除封建酋长权力和封建习俗，对各级政府和部队进行审查和更新。政变期间的民兵被保留且制度化，同各级保卫革命委员会一起成为保卫国家和社会主义的群众武装和监督力量。在人事上，勒内·旺利-马萨加和保罗-伯纳德·科马尤等UPC激进派成员被重用，而西奥多·马伊·马蒂普和亚伯拉罕·恩根坎等UPC温和派则被边缘化。在外交上，喀麦隆宣布脱离法非关系，走激进的反帝反殖路线，并开始同我国及布基纳法索等反帝革命国家结盟的同时建立经济合作机制，达成了合作协定。不过，JOSE与UPC二者在合作、权力分配、革命方针乃至于最终的组织合并上仍存在一定分歧，依托于军事政变进行的革命将走向何处，我们走着瞧。"
const TXT_R0_NON := "新政府很快开始进行土地改革、国有化、建设基础设施以及推广社会保障政策，推行混合经济，宣扬爱国主义和发展主义，并打击部族主义和腐败，引入旨在规范和稳固公务员群体的干部门册与薪资等级制。在人事上，勒内·旺利-马萨加和保罗-伯纳德·科马尤等UPC激进派成员被边缘化，而西奥多·马伊·马蒂普和亚伯拉罕·恩根坎等UPC温和派被重用。外交上，喀麦隆并未转向过于激进的立场，只是在强调主权的立场上继续同法国以及非洲亲法政权和平共处，甚至为促进经济发展开设了经济特区，吸纳邻国投资与鼓励国内经济作物出口，事实上承认原法非体系下的旧有国际分工关系。如今的喀麦隆已然在我们的指导下走上和平巩固爱国、主权与社会主义之路，并能在站稳脚跟的基础上充分保存其革命成就——尽管并不是所有人都对这样的革命成果满意。"
const TXT_R0_LEAK := "尽管我们向JOSE提供了支持，但是结果并不是很成功。4月5日15点，政变的消息泄露，涉及政变的部分部队被比亚下令调走，原本支持政变的空降部队临阵倒戈，而与其他政变部队的联络也因沟通不畅，未能有效配合政变目标，政变者只成功占领了国家广播电台，将政变消息播往全国，按照预定计划，政变不顺利后，JOSE很快打散了政变部队，转入地下，进行城市游击战，转向在城市中配合UPC的行动。最终，在雅温得经过几天的激烈战斗后，政变无果而终。不久之后，比亚发起了白色恐怖，2000多名被指控的异见人士被捕，其中100人立即被判处死刑并处决。除了政变者外，部分北方人也顺势在此次事件被打击，甚至有指挥抵抗政变的军官被捕。政府宣布雅温得及周边地区进入为期六个月的紧急状态。|因为政府封锁消息，JOSE主导的政变并不为人所知，人们普遍认为这是阿希乔在流亡期间策划的政变。经此一役，比亚彻底清洗了不忠于他的北方势力，将内阁、地方官员和国企负责人都换成了自己的人，全面巩固了权力，并将喀麦隆民族联盟改组为喀麦隆人民民主联盟。"
const TXT_R0_FAIL := "尽管我们向JOSE提供了支持，但是结果并不成功。4月5日15点，政变的消息泄露，涉及政变的部分部队被比亚下令调走，原本支持政变的空降部队临阵倒戈，而与其他政变部队的联络也因沟通不畅，未能有效配合政变目标，政变者只成功占领了国家广播电台，但也未能将政变消息播往全国，计划的城市游击战线也未能建立。最终，在雅温得经过几天的激烈战斗后，比亚的效忠者击败了叛军。据估计，死亡人数从71人（此为政府宣称的人数）到大约1000人不等。不久之后，比亚发起了大清算，1000多名被指控的异见人士被捕，其中35人立即被判处死刑并处决。除了政变者外，部分北方人也顺势在此次事件被打击，甚至有指挥抵抗政变的军官被捕。政府宣布雅温得及周边地区进入为期六个月的紧急状态。盖兰迪作为为数不多的逃脱者，前往布基纳法索获得庇护。|因为政府封锁消息，JOSE主导的政变并不为人所知，人们普遍认为这是阿希乔在流亡期间策划的政变。经此一役，比亚彻底清洗了不忠于他的北方势力，将内阁、地方官员和国企负责人都换成了自己的人，全面巩固了权力。1985年，喀麦隆民族联盟被比亚改组为喀麦隆人民民主联盟。"
const TXT_R1 := "我们的人联系上了流亡海外的阿希乔，经过谈判，他同意与我们进行合作。在我方的运作下，一方面，我们成功联系上了支持阿希乔的北方官员和军队成员；另一方面，我们破坏了JOSE的行动。4月6日，阿希乔派的政变部队开始行动，突袭了总统府和总参谋部，并占领了国家广播电台。最终，在雅温得经过几天的激烈战斗后，比亚被迫投降，宣布辞去总统和喀麦隆民族联盟的主席职务。阿希乔乘坐专机回国，并在效忠派的簇拥下宣誓就任新总统和喀麦隆民族联盟主席。阿希乔没有忘记比亚是怎么对待他的，随即开始进行大清算，比亚被判处死刑（尽管为了不彻底与南方撕破脸皮而很快改为无期徒刑），1000多名被指控的异见人士被捕，其中35人立即被判处死刑并处决，部分南方人也顺势在此次事件被打击。|因为政府封锁消息，JOSE及其计划的政变并不为人所知，阿希乔也对他们展开了清洗。阿希乔感谢我们的帮助，并与我们签订合作协议作为回报，协议将允许我国在喀麦隆输出外资并提供石油和相应的政策优惠。"
const TXT_R2 := "我们将政变的消息告诉了比亚总统，他感谢我们的帮助，很快开始行动，并与我们签订合作协议作为回报，协议将允许我国在喀麦隆输出外资并提供石油和相应的政策优惠。在比亚的命令下，涉及政变的部分部队被调走，原本支持政变的空降部队临阵倒戈，而与其他政变部队的联络也因沟通不畅，未能有效配合政变目标，政变者只成功占领了国家广播电台，但也未能将政变消息播往全国，计划的城市游击战线也未能建立。最终，在雅温得经过几天的激烈战斗后，比亚的效忠者击败了叛军。据估计，死亡人数从71人（此为政府宣称的人数）到大约1000人不等。不久之后，比亚发起了大清算，1000多名被指控的异见人士被捕，其中35人立即被判处死刑并处决。除了政变者外，部分北方人也顺势在此次事件被打击，甚至有指挥抵抗政变的军官被捕。政府宣布雅温得及周边地区进入为期六个月的紧急状态。盖兰迪作为为数不多的逃脱者，前往布基纳法索获得庇护。|因为政府封锁消息，JOSE主导的政变并不为人所知，人们普遍认为这是阿希乔在流亡期间策划的政变。经此一役，比亚彻底清洗了不忠于他的北方势力，将内阁、地方官员和国企负责人都换成了自己的人，全面巩固了权力。1985年，喀麦隆民族联盟被比亚改组为喀麦隆人民民主联盟。"
const TXT_R3 := "4月5日15点，政变的消息泄露，涉及政变的部分部队被比亚下令调走，原本支持政变的空降部队临阵倒戈，而与其他政变部队的联络也因沟通不畅，未能有效配合政变目标，政变者只成功占领了国家广播电台，但也未能将政变消息播往全国，计划的城市游击战线也未能建立。最终，在雅温得经过几天的激烈战斗后，比亚的效忠者击败了叛军。据估计，死亡人数从71人（此为政府宣称的人数）到大约1000人不等。不久之后，比亚发起了大清算，1000多名被指控的异见人士被捕，其中35人立即被判处死刑并处决。除了政变者外，部分北方人也顺势在此次事件被打击，甚至有指挥抵抗政变的军官被捕。政府宣布雅温得及周边地区进入为期六个月的紧急状态。盖兰迪作为为数不多的逃脱者，前往布基纳法索获得庇护。|因为政府封锁消息，JOSE主导的政变并不为人所知，人们普遍认为这是阿希乔在流亡期间策划的政变。经此一役，比亚彻底清洗了不忠于他的北方势力，将内阁、地方官员和国企负责人都换成了自己的人，全面巩固了权力。1985年，喀麦隆民族联盟被比亚改组为喀麦隆人民民主联盟。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line <= 2 and ws.influence_prc >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var cameroon := _country(66)
	var burkina := _country(61)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			if burkina != null and (burkina.sub_government == GameConstants.SubGovernment.LEFT_RADICAL or burkina.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST or burkina.sub_government == GameConstants.SubGovernment.PRAGMATIST) \
					and _done("event_680") and _res_ev("event_680") == 1:
				if cameroon != null:
					_leave_alliances(cameroon)
					cameroon.set_tag("亲中", true)
					cameroon.set_tag("对华贸易", true)
				ws.influence_prc += 20
				_add_relation(EmpireData.USA, -50)
				_add_power(EmpireData.USA, -20)
				ws.oil_prod += 100.0  # Event618.cs result0 成功线：喀麦隆石油合作
				var text := TXT_R0_SUC
				if burkina != null and ws.is_socialism(burkina, true):
					text += TXT_R0_SOC
					if cameroon != null:
						cameroon.government = GameConstants.Government.SOCIALIST
						cameroon.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				else:
					text += TXT_R0_NON
					if cameroon != null:
						cameroon.government = GameConstants.Government.REFORMIST
						cameroon.sub_government = GameConstants.SubGovernment.PRAGMATIST
				context["result_text"] = text
			elif _done("event_680") and _res_ev("event_680") == 0 and not _done("event_617"):
				context["result_text"] = TXT_R0_LEAK
				if cameroon != null:
					cameroon.level_of_instability += 10
				_add_relation(EmpireData.USA, -25)
			else:
				context["result_text"] = TXT_R0_FAIL
				_add_relation(EmpireData.USA, -25)
		1:
			context["result_text"] = TXT_R1
			if cameroon != null:
				cameroon.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_ARMY, -100)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -5)
			ws.oil_prod += 100.0  # Event618.cs result1：阿希乔石油协议
		2:
			context["result_text"] = TXT_R2
			if cameroon != null:
				cameroon.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_AGENTS, -30)
			ws.oil_prod += 100.0  # Event618.cs result2：比亚石油协议
		3:
			context["result_text"] = TXT_R3






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
			c.puppet_of = GameConstants.LegacySlot.NONE


