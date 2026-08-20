extends "res://数据脚本/event_script_base.gd"

## 原作 Event379.cs：苏修美帝，狼狈为奸（北约东扩，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（见 event_435 约定）；
##  - 原版 result2 num7 五项条件逐项移植；Debug.Log 跳过。

const TXT_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_DIS_ARMY := "军事实力必须高于{0}点......"
const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"
const TXT_R0 := "作为北约东扩计划的一部分，前华沙条约国家最终全体加入北大西洋公约组织。在布鲁塞尔举行的记者招待会上，苏联外交部长安德烈·葛罗米柯如是说道：“资本主义与社会主义间拼个你死我活的时代已经过去了。和平与发展才是我们需要关注的母题，对此，我们必须摈弃意识形态领域的一切矛盾。从而加速实现人类命运共同体，实现共存共荣共享发展。并对那些意图威胁这来之不易和平的邪恶轴心坚决说不。”\n随后，北约组织通过了一份新宪章，宣布其目的是“确保世界范围内的普遍和平”。两大军事集团已经开始撤出其部署在铁幕两端的军事基地。华约也将在一年后被彻底解散。\n可与之相对的是，苏联已经在中亚五国地区增兵，同美国在阿拉伯半岛日益频繁的军事部署形成夹击之势。"
const TXT_R1 := "中国外交部发言人对此表示强烈谴责：“北约东扩无疑将加深国家间的不信任与危机感”。对此美国与苏联外交部长一齐回应称：“新北约只针对国际上威胁和平的邪恶帝国，难道北京当局自认为自己也是那样的战争贩子？”，并要求中华人民共和国“摒弃陈旧的冷战思维”。\n作为北约东扩计划的一部分，前华沙条约国家最终全体加入北大西洋公约组织。在布鲁塞尔举行的记者招待会上，苏联外交部长安德烈·葛罗米柯如是说道：“资本主义与社会主义间拼个你死我活的时代已经过去了。和平与发展才是我们需要关注的母题，对此，我们必须摈弃意识形态领域的一切矛盾。从而加速实现人类命运共同体，实现共存共荣共享发展。并对那些意图威胁这来之不易和平的邪恶轴心坚决说不。”\n随后，北约组织通过了一份新宪章，宣布其目的是“确保世界范围内的普遍和平”。两大军事集团已经开始撤出其部署在铁幕两端的军事基地。华约也将在一年后被彻底解散。\n可与之相对的是，苏联已经在中亚五国地区增兵，同美国在阿拉伯半岛日益频繁的军事部署形成夹击之势。"
const TXT_R2 := "作为北约东扩计划的一部分，前华沙条约国家最终将全体加入北大西洋公约组织。然而，前华约内还是存在些许不和谐的声音——比如部分成员拒绝加入“帝国主义本性不改”的北约组织。\n尽管苏联外交部长安德烈·葛罗米柯已竭力呼吁其摒弃冷战思维，汇入求和平谋发展的大流。但华约依然有着它自己的钉子户。\n前华约中一共有{1}个这样的“刺头”\n{2}对此，苏联、民主德国与保加利亚已经开始向上述“深陷反革命反人民阴谋”的国家派兵。\n阿拉伯联合共和国则同意向我国开放苏伊士航道，让武器源源不断地流入起义者处。南斯拉夫军政府也宣布“苏联背叛了社会主义理想，在国际阶级斗争中投靠资产阶级”，并转而支持华沙条约。"
const TXT_R2_FAIL := "我们试图动员东欧进步势力对抗帝修反统一战线的努力失败了。作为北约东扩计划的一部分，前华沙条约国家最终将全体加入北大西洋公约组织。然而，前华约内还是存在些许不和谐的声音——比如部分成员拒绝加入“帝国主义本性不改”的北约组织。\n尽管苏联外交部长安德烈·葛罗米柯已竭力呼吁其摒弃冷战思维，汇入求和平谋发展的大流。但华约依然有着它自己的钉子户。对此，安德罗波夫再度发挥了自己多年在克格勃内工作的本行，在他们甚至还未来得及发动反政变前，便抢先一步夺下了这些国家的政权。{2}随后，苏联与美国怒斥我国威胁世界和平，并断绝了与我国的外交关系。\n随后，北约组织通过了一份新宪章，宣布其目的是“确保世界范围内的普遍和平”。两大军事集团已经开始撤出其部署在铁幕两端的军事基地。华约也将在一年后被彻底解散。\n可与之相对的是，苏联已经在中亚五国地区增兵，同美国在阿拉伯半岛日益频繁的军事部署形成夹击之势。\n已满足起义成功所需5项条件中的{4}项。"
const TXT_WAR_NAME := "苏联遗产战争"
const TXT_WAR_ATT := "华沙组织"
const TXT_WAR_DEF := "北约组织"
const TXT_POLAND := "波兰人民共和国领导层宣布将坚持与华约共存亡，并拒绝退出该组织。"
const TXT_HUNGARY := "匈牙利人民共和国领导层宣布将坚持与华约共存亡，并拒绝退出该组织。"
const TXT_ROMANIA := "罗马尼亚社会主义共和国领导层宣布将坚持与华约共存亡，并拒绝退出该组织。"
const TXT_CZECH := "经表决，斯洛伐克共产党领导层决定坚持与华约共存亡，但捷克斯洛伐克共产党代表大会却通过了加入北约的决议。因此，斯洛伐克民族主义者决定脱离捷克斯洛伐克。刚刚组建的民兵组织设法囚禁了驻斯洛伐克苏军大将。"
const TXT_POLAND_NATO := "波兰人民共和国新任领导层宣布遵从苏联指示，决定加入北约。"
const TXT_HUNGARY_NATO := "匈牙利人民共和国新任领导层宣布遵从苏联指示，决定加入北约。"
const TXT_ROMANIA_NATO := "罗马尼亚社会主义共和国新任领导层宣布遵从苏联指示，决定加入北约。"
const TXT_CZECH_NAME := "捷克"
const TXT_YUGO := "南斯拉夫军政府宣布“苏联背叛了社会主义理想，在国际阶级斗争中投靠资产阶级”，并决定向我们靠拢。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	# 原作 Event379.cs:19-22：TextOfEvents 显示时 iron_and_blood → achievements.Set(138)
	Achievements.set_achievement(138)
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	var poland := world.get_country_by_legacy_index(2)
	var hungary := world.get_country_by_legacy_index(4)
	var romania := world.get_country_by_legacy_index(5)
	var czech := world.get_country_by_legacy_index(3)
	if (poland != null and poland.has_tag("亲中")) or (hungary != null and not hungary.has_tag("亲苏")) 			or (romania != null and romania.has_tag("亲中")) or (czech != null and czech.development > 0) 			and _d(W.I_ARMY) >= 400 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 200 and _d(W.I_AGENTS) >= 150:
		_enable(opt[2], event_def.options[2].text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt[2], TXT_DIS_BUDGET.format([20]))
	elif _d(W.I_AGENTS) < 150:
		_disable(opt[2], TXT_DIS_AGENTS.format([15]))
	else:
		_disable(opt[2], TXT_DIS_ARMY.format([40]))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_add(W.I_PARTY_SUPPORT, -600)
	var mongolia := ws.get_country_by_legacy_index(9)
	if mongolia != null and mongolia.has_tag("亲中"):
		mongolia.set_tag("亲中", false)
		mongolia.set_tag("nato", true)
		mongolia.set_tag("okb", false)
		mongolia.set_tag("econ", false)
	var yugo := ws.get_country_by_legacy_index(15)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	var yugo_txt: String = TXT_YUGO if (yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 			and (china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL))) else ""
	if opt == 0:
		context["result_text"] = TXT_R0.format(["\n", yugo_txt])
		_apply_wp_to_nato()
		_add_power(EmpireData.USA, 150)
		_add_power(EmpireData.USSR, 150)
		_add_relation(EmpireData.USA, -600)
		_add_relation(EmpireData.USSR, -600)
		if yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 				and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			yugo.set_tag("亲中", true)
	elif opt == 1:
		context["result_text"] = TXT_R1.format(["\n", yugo_txt])
		_apply_wp_to_nato()
		_add_power(EmpireData.USA, 150)
		_add_power(EmpireData.USSR, 150)
		_add_relation(EmpireData.USA, -700)
		_add_relation(EmpireData.USSR, -700)
		if yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 				and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			yugo.set_tag("亲中", true)
	else:
		var num := 0
		for c in ws.countries:
			if c != null and c.has_tag("okb"):
				num += 1
		ws.set_flag("relres", false)
		var usa := ws.get_country_by_legacy_index(51)
		if usa != null:
			usa.set_tag("对华贸易", false)
			usa.development = 0
		var num2 := 0
		var num3 := 0
		var num4 := 0
		var num5 := 0
		var num6 := 0
		if poland_c() != null and poland_c().has_tag("亲中"):
			num2 += 1
			num3 += 1
			num4 = 1
		if hungary_c() != null and not hungary_c().has_tag("亲苏"):
			num2 += 1
			num3 += 1
			num6 = 1
		if romania_c() != null and romania_c().has_tag("亲中"):
			num2 += 1
			num3 += 1
			num5 = 1
		if albania_c() != null and albania_c().has_tag("亲中"):
			num2 += 1
		if czech_c() != null and czech_c().development > 0:
			num2 += 1
			num3 += 1
		_add_relation(EmpireData.USA, -700)
		_add_relation(EmpireData.USSR, -700)
		var text2 := ""
		var num7 := 0
		var egypt := ws.get_country_by_legacy_index(30)
		if num2 == 5 and num > 10 and egypt != null and egypt.has_tag("oar") and not egypt.has_tag("亲苏") 				and yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 				and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			_start_war_379(60 * num2, 1000 - 60 * num2)
			for i in range(18):
				var cc := ws.get_country_by_legacy_index(i)
				if cc != null and cc.has_tag("ovd") and (i != 2 or num4 <= 0) and (i != 5 or num5 <= 0) and (i != 4 or num6 <= 0):
					_leave_wp(cc)
					_establish_government(cc, "prosov")
					cc.set_tag("nato", true)
					if ussr_c() != null:
						cc.government = ussr_c().government
						cc.sub_government = ussr_c().sub_government
			for c in ws.countries:
				if c != null and (c.has_tag("亲美") or c.has_tag("nato")):
					c.set_tag("对华贸易", false)
			if poland_c() != null and poland_c().has_tag("亲中"):
				_leave_nato(poland_c())
				poland_c().set_tag("sev", false)
				poland_c().set_tag("对华贸易", true)
				text2 += TXT_POLAND + "\n"
			if hungary_c() != null and not hungary_c().has_tag("亲苏"):
				_leave_nato(hungary_c())
				hungary_c().set_tag("sev", false)
				hungary_c().set_tag("对华贸易", true)
				text2 += TXT_HUNGARY + "\n"
			if romania_c() != null and romania_c().has_tag("亲中"):
				_leave_nato(romania_c())
				romania_c().set_tag("对华贸易", true)
				romania_c().set_tag("sev", false)
				text2 += TXT_ROMANIA + "\n"
			if czech_c() != null and czech_c().development > 0:
				if czech_c().parts.size() < 1:
					czech_c().parts.resize(1)
				czech_c().parts[0] = true
				var slovakia := ws.get_country_by_legacy_index(98)
				if slovakia != null:
					slovakia.set_tag("对华贸易", true)
				czech_c().name = TXT_CZECH_NAME
				czech_c().chinese_name = TXT_CZECH_NAME
				if slovakia != null:
					slovakia.set_tag("ovd", true)
				text2 += TXT_CZECH + "\n"
			if yugo != null:
				yugo.set_tag("亲中", true)
			context["result_text"] = TXT_R2.format(["\n", num3, text2])
			return
		if num2 >= 5:
			num7 += 1
		if num > 10:
			num7 += 1
		if egypt != null and egypt.has_tag("oar") and not egypt.has_tag("亲苏"):
			num7 += 1
		if yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev"):
			num7 += 1
		if china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			num7 += 1
		if poland_c() != null and poland_c().has_tag("亲中"):
			text2 += TXT_POLAND_NATO + "\n"
		ws.set_flag("relres", false)
		if usa != null:
			usa.set_tag("对华贸易", false)
			usa.development = 0
		if hungary_c() != null and not hungary_c().has_tag("亲苏"):
			text2 += TXT_HUNGARY_NATO + "\n"
		if romania_c() != null and romania_c().has_tag("亲中"):
			text2 += TXT_ROMANIA_NATO + "\n"
		for i in range(18):
			var cc := ws.get_country_by_legacy_index(i)
			if cc != null and cc.has_tag("亲中"):
				_add(W.I_INFLUENCE, -80)
			if cc != null and cc.has_tag("ovd"):
				_leave_wp(cc)
				_establish_government(cc, "prosov")
				cc.set_tag("nato", true)
				if ussr_c() != null:
					cc.government = ussr_c().government
					cc.sub_government = ussr_c().sub_government
		for c in ws.countries:
			if c != null and (c.has_tag("亲美") or c.has_tag("nato")):
				c.set_tag("对华贸易", false)
		if yugo != null and yugo.sub_government == GameConstants.SubGovernment.LEFT_RADICAL and not yugo.has_tag("sev") 				and china != null and (china.government == GameConstants.Government.SOCIALIST or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			yugo.set_tag("亲中", true)
		context["result_text"] = TXT_R2_FAIL.format(["\n", num3, text2, yugo_txt, num7])


func _apply_wp_to_nato() -> void:
	for i in range(18):
		var cc := ws.get_country_by_legacy_index(i)
		if cc != null and cc.has_tag("亲中"):
			_add(W.I_INFLUENCE, -80)
		if cc != null and cc.has_tag("ovd"):
			_leave_wp(cc)
			_establish_government(cc, "prosov")
			cc.set_tag("nato", true)
			if ussr_c() != null:
				cc.government = ussr_c().government
				cc.sub_government = ussr_c().sub_government
	for c in ws.countries:
		if c != null and (c.has_tag("亲美") or c.has_tag("nato")):
			c.set_tag("对华贸易", false)


func _start_war_379(infl1: int, infl2: int) -> void:
	game.start_war(17, TXT_WAR_ATT, TXT_WAR_DEF, infl1, infl2, 1, 1)
	if ws.wars.size() > 17 and ws.wars[17] != null:
		ws.wars[17].name_war = TXT_WAR_NAME
		ws.wars[17].fortnight_max = 20


func poland_c() -> CountryData: return ws.get_country_by_legacy_index(2)
func hungary_c() -> CountryData: return ws.get_country_by_legacy_index(4)
func romania_c() -> CountryData: return ws.get_country_by_legacy_index(5)
func czech_c() -> CountryData: return ws.get_country_by_legacy_index(3)
func albania_c() -> CountryData: return ws.get_country_by_legacy_index(20)
func ussr_c() -> CountryData: return ws.get_country_by_legacy_index(7)


func _leave_wp(c: CountryData) -> void:
	c.set_tag("ovd", false)


func _leave_nato(c: CountryData) -> void:
	c.set_tag("nato", false)


func _establish_government(c: CountryData, kind: String) -> void:
	if kind == "prosov":
		c.set_tag("亲中", false)
		c.set_tag("亲苏", true)
		c.set_tag("亲美", false)




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0







