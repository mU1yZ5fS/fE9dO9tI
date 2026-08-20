extends "res://数据脚本/event_script_base.gd"

## 原作 Event377.cs：苏联“老大哥”教训“小弟”（苏联干预东欧，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 描述按 c9.proprc/okb、data[132]、c6.proprc 三态动态改写；
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（见 event_435 约定）；
##  - 成就 Set(142) 已接 Achievements；
##  - ingamewars[22].usa_place → WarData.usa_side（c51 对华贸易时置 0）；
##  - war 22 覆盖 name_war/fortnight_max。

const TXT_DESC_FMT := "主席阁下！不可思议的事情发生了！苏联领导人格里戈里·罗曼诺夫宣称“反革命势力沉渣泛起，再度威胁到了友爱团结的社会主义阵营”，且它们“正准备在华沙条约组织成员国内组织反共反苏政变”。因此，格里戈里·罗曼诺夫将以“将社会主义兄弟从帝国主义分子手中解放”为由，向下述各国派出军队，对其进行政府改组：{1}\n苏联事实上已有派兵干涉苏东集团各国内政的先例，但如此大规模的军事行动还是闻所未闻！介于目前的局势，我们必须对此做些什么，但欧洲距离中国太遥远，我们又能怎么做呢？"
const TXT_LIST_5 := "波兰、罗马尼亚、匈牙利与蒙古"
const TXT_LIST_5B := "波兰、罗马尼亚、匈牙利、保加利亚与蒙古"
const TXT_LIST_4 := "波兰、罗马尼亚与匈牙利"
const TXT_LIST_4B := "波兰、罗马尼亚、匈牙利与保加利亚"
const TXT_OPT2_RELRES := "与苏联断交，并让他们尝尝“第二次珍宝岛冲突”！（需要75.0点{2}）"
const TXT_OPT2_NORELRES := "让他们尝尝“第二次珍宝岛冲突”！（需要75.0点{2}）"
const TXT_DIS_INFLUENCE := "中国的国际影响力应高于{0}......"
const TXT_DIS_ARMY := "军事实力必须高于{0}点......"
const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"
const TXT_DIS_WAR := "战争已经爆发！"
const TXT_DIS_ISLANDS := "银龙岛与黑瞎子岛已经属于我国！"
const TXT_DIS_FACTION := "极左派并不是党内的主要派系......"
const TXT_R0A_FMT := "苏军从民主德国、保加利亚与捷克斯洛伐克的领土出发，并向“不听话的社会主义各国”派遣部队。尽管那些国家的领导人试图组织抵抗，但他们还是因自己不得人心的政策而无能为力。尽管各国市民对苏联的入侵已有模糊的印象（毕竟有1956年事件与1968年事件的先例），但他们还是认为苏军坦克上的新政权，还是不可能和当地政权那样威权且糟糕。\n在各国政府均被推翻后，上述国家的共产党与社会党均被解散，并被二度改组。然而，前党员并没有被自动加入到新组织中，这导致他们需要重新入党。\n因此，新的共产党成为了温和派主导的组织，而温和派又仅在党内的主要职位上任职。从而打破了党员在议会与政府内均任最高领导人的旧有传统。\n苏联领导人认为，这一改组足以让各国回归“集体领导”原则。\n罗马尼亚共产党的领导人伊利耶·维尔德茨，匈牙利共产党的领导人，前匈牙利驻苏联大使蒂尔默·久洛与波兰共产党领导人卡奇米日·巴尔奇科夫斯基纷纷就位，领导各自的祖国。\n新政府开始以苏联社会主义为样板推行国内政策。\n{1}"
const TXT_R0B := "苏军从民主德国与捷克斯洛伐克的领土出发，并向“不听话的社会主义各国”派遣部队。尽管那些国家的领导人试图组织抵抗，但他们还是因自己不得人心的政策而无能为力。尽管各国市民对苏联的入侵已有模糊的印象（毕竟有1956年事件与1968年事件的先例），但他们还是认为苏军坦克上的新政权，还是不可能和当地政权那样威权且糟糕。\n在各国政府均被推翻后，上述国家的共产党与社会党均被解散，并被二度改组。然而，前党员并没有被自动加入到新组织中，这导致他们需要重新入党。\n因此，新的共产党成为了温和派主导的组织，而温和派又仅在党内的主要职位上任职。从而打破了党员在议会与政府内均任最高领导人的旧有传统。\n苏联领导人认为，这一改组足以让各国回归“集体领导”原则。\n罗马尼亚共产党的领导人伊利耶·维尔德茨，匈牙利共产党的领导人，前匈牙利驻苏联大使蒂尔默·久洛、波兰共产党领导人卡奇米日·巴尔奇科夫斯基与保加利亚共产党的领导人格里沙·菲利波夫纷纷就位，领导各自的祖国。\n新政府开始以苏联社会主义为样板推行国内政策。\n{1}"
const TXT_R1A_FMT := "中国外交部长对此发出严厉指责：“苏联正积极推行社会帝国主义政策，从而使冷战局势再度升级，威胁世纪和平发展。用武力推动主权国家政权更迭的方式来解决问题是万万不行的。”\n苏军从民主德国、保加利亚与捷克斯洛伐克的领土出发，并向“不听话的社会主义各国”派遣部队。尽管那些国家的领导人试图组织抵抗，但他们还是因自己不得人心的政策而无能为力。尽管各国市民对苏联的入侵已有模糊的印象（毕竟有1956年事件与1968年事件的先例），但他们还是认为苏军坦克上的新政权，还是不可能和当地政权那样威权且糟糕。\n在各国政府均被推翻后，上述国家的共产党与社会党均被解散，并被二度改组。然而，前党员并没有被自动加入到新组织中，这导致他们需要重新入党。\n因此，新的共产党成为了温和派主导的组织，而温和派又仅在党内的主要职位上任职。从而打破了党员在议会与政府内均任最高领导人的旧有传统。\n苏联领导人认为，这一改组足以让各国回归“集体领导”原则。\n罗马尼亚共产党的领导人伊利耶·维尔德茨，匈牙利共产党的领导人，前匈牙利驻苏联大使蒂尔默·久洛与波兰共产党领导人卡奇米日·巴尔奇科夫斯基纷纷就位，领导各自的祖国。\n新政府开始以苏联社会主义为样板推行国内政策。\n{1}"
const TXT_R1B := "中国外交部长对此发出严厉指责：“苏联正积极推行社会帝国主义政策，从而使冷战局势再度升级，威胁世纪和平发展。用武力推动主权国家政权更迭的方式来解决问题是万万不行的。”\n苏军从民主德国与捷克斯洛伐克的领土出发，并向“不听话的社会主义各国”派遣部队。尽管那些国家的领导人试图组织抵抗，但他们还是因自己不得人心的政策而无能为力。尽管各国市民对苏联的入侵已有模糊的印象（毕竟有1956年事件与1968年事件的先例），但他们还是认为苏军坦克上的新政权，还是不可能和当地政权那样威权且糟糕。\n在各国政府均被推翻后，上述国家的共产党与社会党均被解散，并被二度改组。然而，前党员并没有被自动加入到新组织中，这导致他们需要重新入党。\n因此，新的共产党成为了温和派主导的组织，而温和派又仅在党内的主要职位上任职。从而打破了党员在议会与政府内均任最高领导人的旧有传统。\n苏联领导人认为，这一改组足以让各国回归“集体领导”原则。\n罗马尼亚共产党的领导人伊利耶·维尔德茨，匈牙利共产党的领导人，前匈牙利驻苏联大使蒂尔默·久洛、波兰共产党领导人卡奇米日·巴尔奇科夫斯基与保加利亚共产党的领导人格里沙·菲利波夫纷纷就位，领导各自的祖国。\n新政府开始以苏联社会主义为样板推行国内政策。\n{1}"
const TXT_R2_FMT := "中国部队穿过乌苏里江，并登陆银龙岛与黑瞎子岛屿。对岸的苏联边界部队以重机枪与狙击枪回应，随后便是步兵战车赶来。苏军也开始准备登岛作战。\n苏联领导人格里戈里·罗曼诺夫威胁中国称：“倘若中国军队敢跨过乌苏里江，就给中国人迎头痛击”。同时他还声称：“不妨让我们上堂历史课，过去俄罗斯对中国领土的宣称确实少不了。比如伊犁地区啊、黄俄罗斯计划啊。也许是时候让我们把这些扩张计划落地了？”\n{1}"
const TXT_RELRES := "苏联与中华人民共和国之间的外交关系急剧恶化。"
const TXT_MONGOLIA := "隶属外贝加尔军区的苏联部队开入乌兰巴托。在苏联代表的压力下，尤睦佳·泽登巴尔同意加强对亲中政治家的镇压。此后，蒙古领导人则“因健康原因”辞职，党主席和大人民呼拉尔会议主席团主席的职位则由前政府主席姜巴·巴特蒙赫兼任。"
const TXT_WAR_NAME := "第二次珍宝岛冲突"
const TXT_WAR_ATT := "中国"
const TXT_WAR_DEF := "苏联"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var mongolia := world.get_country_by_legacy_index(9)
	var bulgaria := world.get_country_by_legacy_index(6)
	var opt := event_def.options
	var cond5: bool = mongolia != null and mongolia.has_tag("亲中") and not mongolia.has_tag("okb") 			and _d(132) <= 0 and bulgaria != null and bulgaria.has_tag("亲中")  # 原版 data[132]
	var cond4: bool = mongolia != null and mongolia.has_tag("亲中") and not mongolia.has_tag("okb") and _d(132) <= 0  # 原版 data[132]
	if cond5:
		event_def.description = TXT_DESC_FMT.format(["\n", TXT_LIST_5B])
	elif cond4:
		event_def.description = TXT_DESC_FMT.format(["\n", TXT_LIST_5])
	elif bulgaria != null and bulgaria.has_tag("亲中"):
		event_def.description = TXT_DESC_FMT.format(["\n", TXT_LIST_4B])
	else:
		event_def.description = TXT_DESC_FMT.format(["\n", TXT_LIST_4])
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	var relres: bool = world.get_flag("relres")
	var war22 := world.wars[22] if world.wars.size() > 22 else null
	if relres and world.influence_prc >= 750 and _d(W.I_ARMY) >= 750 			and GameManager.is_faction_leading(0) 			and (war22 == null or not war22.is_going) and _d(133) == 0:  # 原版 data[133]
		_enable(opt[2], TXT_OPT2_RELRES.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif not relres and world.influence_prc >= 950 and _d(W.I_ARMY) >= 750:
		_enable(opt[2], TXT_OPT2_NORELRES.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif world.influence_prc < 750:
		_disable(opt[2], TXT_DIS_INFLUENCE.format([95]))
	elif _d(W.I_ARMY) < 750:
		_disable(opt[2], TXT_DIS_ARMY.format([75]))
	elif war22 != null and war22.is_going:
		_disable(opt[2], TXT_DIS_WAR)
	elif _d(133) != 0:  # 原版 data[133]
		_disable(opt[2], TXT_DIS_ISLANDS)
	else:
		_disable(opt[2], TXT_DIS_FACTION)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var mongolia := ws.get_country_by_legacy_index(9)
	var bulgaria := ws.get_country_by_legacy_index(6)
	var poland := ws.get_country_by_legacy_index(2)
	var hungary := ws.get_country_by_legacy_index(4)
	var romania := ws.get_country_by_legacy_index(5)
	var ussr := ws.get_country_by_legacy_index(7)
	var opt := int(context.get("option_index", -1))
	var cond5: bool = mongolia != null and mongolia.has_tag("亲中") and not mongolia.has_tag("okb") 			and _d(132) <= 0 and bulgaria != null and bulgaria.has_tag("亲中")  # 原版 data[132]
	if opt == 0:
		if bulgaria == null or not bulgaria.has_tag("亲中"):
			context["result_text"] = TXT_R0A_FMT.format(["\n", TXT_MONGOLIA if cond5 else ""])
			_add(W.I_PARTY_SUPPORT, -550)
		else:
			context["result_text"] = TXT_R0B
			_add(W.I_PARTY_SUPPORT, -600)
	elif opt == 1:
		if bulgaria == null or not bulgaria.has_tag("亲中"):
			context["result_text"] = TXT_R1A_FMT.format(["\n", TXT_MONGOLIA if cond5 else ""])
			_add(W.I_PARTY_SUPPORT, -250)
			_add_relation(EmpireData.USSR, -500)
			_add_relation(EmpireData.USA, 100)
			_add(W.I_DIPLO, -50)
		else:
			context["result_text"] = TXT_R1B
			_add(W.I_PARTY_SUPPORT, -250)
			_add_relation(EmpireData.USSR, -500)
			_add_relation(EmpireData.USA, 100)
			_add(W.I_DIPLO, -50)
	else:
		context["result_text"] = TXT_R2_FMT.format(["\n", TXT_RELRES if ws.get_flag("relres") else ""])
		ws.empires[EmpireData.USSR].relations = 0
		# 原作 Event377.cs:121：iron_and_blood → achievements.Set(142)
		Achievements.set_achievement(142)
		_start_war_377()
		var usa377 := ws.get_country_by_legacy_index(51)
		if ws.wars.size() > 22 and ws.wars[22] != null and usa377 != null and usa377.has_tag("对华贸易"):
			ws.wars[22].usa_side = 0
		if bulgaria != null:
			bulgaria.set_tag("对华贸易", false)
		_add(W.I_PARTY_SUPPORT, 300)
		_add(W.I_ARMY, -750)
	# 公共尾部（原版 ResultsOfEvents 在所有分支后执行）
	if poland != null:
		_leave_alliances(poland)
		_establish_government(poland, "prosov")
	if hungary != null:
		_leave_alliances(hungary)
		_establish_government(hungary, "prosov")
	if romania != null:
		_leave_alliances(romania)
		_establish_government(romania, "prosov")
	if bulgaria != null:
		_leave_alliances(bulgaria)
		_establish_government(bulgaria, "prosov")
		bulgaria.set_tag("sev", true)
		bulgaria.set_tag("ovd", true)
	if cond5 and mongolia != null and ussr != null:
		mongolia.government = ussr.government
		_establish_government(mongolia, "prosov")
		mongolia.sub_government = 16
		mongolia.puppet_of = 7
		ws.influence_prc -= 50
		mongolia.set_tag("对华贸易", false)
	if ussr != null:
		for c in [poland, hungary, romania, bulgaria]:
			if c != null:
				c.government = ussr.government
				c.sub_government = 16
				c.set_tag("对华贸易", false)
				c.puppet_of = 7
	ws.influence_prc -= 150
	_add_power(EmpireData.USSR, 200)


func _start_war_377() -> void:
	GameManager.start_war(22, TXT_WAR_ATT, TXT_WAR_DEF, 250, 750, -1, -1)
	if ws.wars.size() > 22 and ws.wars[22] != null:
		ws.wars[22].name_war = TXT_WAR_NAME
		ws.wars[22].fortnight_max = 500



func _establish_government(c: CountryData, kind: String) -> void:
	if kind == "prosov":
		c.set_tag("亲中", false)
		c.set_tag("亲苏", true)
		c.set_tag("亲美", false)




func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0







