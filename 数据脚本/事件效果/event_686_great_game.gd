extends "res://数据脚本/event_script_base.gd"

## 原作 Event686.cs：大博弈（西欧影响力机制激活，三选项）。
## 触发：ReqEventsDLC02.cs:1369-1371 —— !c0.eu && !c51.nato
##   && ((c7.sev && c7.ovd) || is_gkchp) && !c85.soc_eu && !c21.fxseu && !c21.nazimao
##   && !ev713 && (!ev548 || china.rim) → trigger_script evaluate。
## 差异：sovpower/prcpower→sov_power/prc_power；spec→special；based→有驻军基地；
##   isSEV→sev、isOVD→ovd、Torg→对华贸易、prosov→亲苏、isRIM→rim；
##   politics_dolshnost[2]<100 用外长姓名，否则用领袖姓名；relres→get_flag("relres")。

const TXT_TITLE := "大博弈"
const TXT_DESC := "大西洋主义与欧洲一体化的破产导致西欧地区已退回20世纪初的碎片化格局。而当地举足轻重的大国基本上选择倒向域外强权，并对西欧内部事务采取相对消极立场的行为更是使得西欧地区有发展为大国后花园的潜质。而长期图谋建立欧洲安全体系的苏联必然不会错过这点……由于北大西洋组织安全机构的撤离，欧洲其他地区亲苏派共产党与左翼组织得以获得活动便利，并愈加倾向于直接从莫斯科方面获取支持。与此同时，苏联外交部长葛罗米柯也适时提出了所谓“葛罗米柯计划”：苏东集团将为西欧多国的经济发展提供便利，以廉价物资、优惠贷款与市场准入三招协助其稳定欧洲共同体崩溃后陷入困顿的经济——当然，上述内容自然是以接受援助的国家实行社会主义改革，允许共产党员参与政府，逐渐转向类似战后初期的东欧“人民民主体制”为交换。最后的目标自然是加入经济互助委员会与华沙条约……芬兰共产党主导的伞形竞选组织芬兰人民民主联盟已开始借着这一势头快速崛起，并试图顺水推舟终结芬兰化。虽说其他国家仍对此保持谨慎态度，并试图在接受苏联援助恢复经济的同时尽可能保障主权。可在缺乏新玩家入局的情况下，这些孤立主义壁垒并入苏维埃体系不过是时间问题。对冷战遗产的瓜分已经开始，考虑到中国也是目前少有的“负责大国”。我们有必要在其中展示自己的立场。\n[color=red]提示：影响力机制已激活，域外大国将利用此争取西欧中立国家加入自身集团。若某大国对该国的影响力达到100.0，该国的政体将与前者同步，并可在此后加入大国所属阵营！[/color]"
const TXT_OPT0_FMT := "实际上，我们也有我们自己的{0}{1}计划。是时候对遏制政策故事重提了！"
const TXT_OPT0_DIS_A := "干涉主义可不是我们的政策"
const TXT_OPT0_DIS_B := "欧洲太过遥远，我们鞭长莫及"
const TXT_OPT1 := "我们将竭尽所能支持苏联建设新欧洲的努力！"
const TXT_OPT1_DIS_A := "苏联可不会任我国与东欧诸国眉来眼去！"
const TXT_OPT1_DIS_B := "我们与苏联的关系还不足以如此"
const TXT_OPT2 := "欧洲对我们来说太过遥远，还是眼前的事更为重要"
const TXT_R0_FM_FMT := "作为冷战牌局内不可忽视的玩家，我们可不会将好不容易得来的胜利成果拱手相让。不久后，得到我国外交部长{2}{3}同志亲自指导的《对苏联共产党的第十评》与作为参考文件的的乔治·凯南“长电报”便出现在您的桌前：苏联扩张主义的发展，欧洲作为冷战前线的战略价值，以及有必要开辟“第二战场”缓解中国国防压力的现实需要共同促使{0}{1}下定决心实行新时代的遏制政策。也就在苏联大肆宣扬其“葛罗米柯计划”并鼓励欧洲诸国安心接受“更公正合理的和平共存新关系”同时。我国公安部以中央人民广播电台名义建立了旨在向欧洲国家广播事实，促使其向东方之东看齐的“明灯”分部，并依托自己的西欧盟国建立其欧洲框架。它很快便会成为庇护欧洲亲中政治团体的主要赞助商与我们在欧洲的主要宣传阵地（讽刺的事情是，“明灯”内确实有颇多成员是从早已垮台的“自由欧洲”内转正，显然是为了饭碗）。与其同步推进的则是所谓“{2}{3}计划”——我们将通过输送投资金及廉价产品，提供基础设施建设与技术援助方案支持认可我国价值观的西欧政权，并在这一基础上培育亲近我国的本土政客与资产阶级。通过鼓励亲近我国的西欧盟友放开贸易壁垒，扮演中欧互动间桥梁，以及同奥地利、瑞典等中立政权达成部分领域内多边合作的方式。我们得以在控制成本的同时尽可能稳健而有效地拓展自身的影响力。对冷战中间地带的争夺就此开始，而这将决定欧洲的命运……"
const TXT_R0_LEADER_FMT := "作为冷战牌局内不可忽视的玩家，我们可不会将好不容易得来的胜利成果拱手相让。不久后，《对苏联共产党的第十评》与作为参考文件的的乔治·凯南“长电报”便出现在您的桌前：苏联扩张主义的发展，欧洲作为冷战前线的战略价值，以及有必要开辟“第二战场”缓解中国国防压力的现实需要共同促使{0}{1}下定决心实行新时代的遏制政策。也就在苏联大肆宣扬其“葛罗米柯计划”并鼓励欧洲诸国安心接受“更公正合理的和平共存新关系”同时。我国公安部以中央人民广播电台名义建立了旨在向欧洲国家广播事实，促使其向东方之东看齐的“明灯”分部，并依托自己的西欧盟国建立其欧洲框架。它很快便会成为庇护欧洲亲中政治团体的主要赞助商与我们在欧洲的主要宣传阵地（讽刺的事情是，“明灯”内确实有颇多成员是从早已垮台的“自由欧洲”内转正，显然是为了饭碗）。与其同步推进的则是所谓“{0}{1}计划”——我们将通过输送投资金及廉价产品，提供基础设施建设与技术援助方案支持认可我国价值观的西欧政权，并在这一基础上培育亲近我国的本土政客与资产阶级。通过鼓励亲近我国的西欧盟友放开贸易壁垒，扮演中欧互动间桥梁，以及同奥地利、瑞典等中立政权达成部分领域内多边合作的方式。我们得以在控制成本的同时尽可能稳健而有效地拓展自身的影响力。对冷战中间地带的争夺就此开始，而这将决定欧洲的命运……"
const TXT_R1 := "中国的一边倒立场事实上让苏联成为了欧洲棋盘的唯一玩家，并让后者的扩张如虎添翼。本就在欧洲地区享有绝对优势的苏联自然能轻易拿捏这些西欧政权，中国的加入则解决了上述政权“和平长入社会主义”所需的时间问题。背靠苏联支持的政党很快便参照40年代捷克斯洛伐克共产党的经验在西欧各地成功夺权，建立起以共产主义者为核心的人民民主政府。国家警察与武装工人民兵驱散了试图捍卫旧秩序的队伍，并开始指导那些试图同苏联合作的政治家将各类社会团体与政党组织转化为东德模式——前者作为国家机器与执政党的派生，后者则代表特定的社会阶层实施“参政”。接下来则是建立社会化经济并筹建国家计划委员会。新秩序就这样到来了……"
const TXT_R2 := "中国的孤立主义立场事实上让苏联成为了欧洲棋盘的唯一玩家，并让后者的扩张畅通无阻。考虑到苏联在欧洲地区的绝对优势，这些西欧政权的倒戈不过是时间问题……"

const PROPRC_LIST := [92, 21, 85, 86, 87, 29, 17]
const NEUTRAL_LIST := [0, 27, 28, 88, 89, 90, 91]


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var china := ws.get_country_by_legacy_index(1)
	var opt := event_def.options
	var proprc_count := _count_proprc()
	var can_contain := china != null and china.has_tag("econ") and china.has_tag("okb") \
		and ws.influence_prc >= 1000 and _res(W.I_RESERVE) >= 250 and proprc_count >= 3
	if can_contain:
		_enable(opt[0], TXT_OPT0_FMT.replace("{0}{1}", _plan_author_name()))
	elif china == null or not china.has_tag("econ") or not china.has_tag("okb"):
		_disable(opt[0], TXT_OPT0_DIS_A)
	else:
		_disable(opt[0], TXT_OPT0_DIS_B)
	if china != null and china.government != 3 and ws.get_flag("relres") \
			and china.has_tag("sev"):
		_enable(opt[1], TXT_OPT1)
	elif china != null and china.government == 3:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	# 公共前奏：所有结果先重置中立国势力并处理 c26（奥地利? 按原版序号 26）。
	for idx in NEUTRAL_LIST:
		var c := ws.get_country_by_legacy_index(idx)
		if c == null:
			continue
		c.stab = 0
		c.special = 0
		c.sov_power = 300
		c.prc_power = 0
	var finland := ws.get_country_by_legacy_index(26)
	if finland != null and finland.has_tag("亲苏"):
		for idx in [28, 90, 91]:
			var c := ws.get_country_by_legacy_index(idx)
			if c != null:
				c.sov_power += 100
	else:
		if finland != null:
			finland.set_tag("亲苏", true)
			finland.government = 2
			finland.sub_government = 3
	if opt == 0:
		var leader := _leader_name()
		var plan_author := _plan_author_name()
		if _has_foreign_minister():
			context["result_text"] = TXT_R0_FM_FMT.replace("{0}{1}", leader) \
				.replace("{2}{3}", plan_author)
		else:
			context["result_text"] = TXT_R0_LEADER_FMT.replace("{0}{1}", leader)
		_add(W.I_BUDGET, -250)
		_add(W.I_AGENTS, -250)
		_add(W.I_ARMY, -50)
		_add(W.I_DIPLO, 50)
		_add_relation(EmpireData.USA, -250)
		_add_relation(EmpireData.USSR, -250)
		var proprc_count := _count_proprc()
		for idx in NEUTRAL_LIST:
			var c := ws.get_country_by_legacy_index(idx)
			if c != null:
				c.prc_power = 250 + 50 * proprc_count
		return
	if opt == 1:
		context["result_text"] = TXT_R1
		_add(W.I_BUDGET, -100)
		_add_relation(EmpireData.USA, 500)
		_add_relation(EmpireData.USSR, -250)
		_add_power(EmpireData.USSR, 50)
		ws.influence_prc += 25
		var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
		for idx in NEUTRAL_LIST:
			var c := ws.get_country_by_legacy_index(idx)
			if c == null:
				continue
			_apply_soviet_turn(c, ussr)
		if finland != null:
			# 原版 c26 单独块：只改政体/标签/based，不动 sovpower/prcpower。
			_apply_finland_turn(finland, ussr)
		return
	if opt == 2:
		context["result_text"] = TXT_R2


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var eu_holder := world.get_country_by_legacy_index(0)
	var usa_country := world.get_country_by_legacy_index(51)
	var gdr := world.get_country_by_legacy_index(7)
	var spain := world.get_country_by_legacy_index(85)
	var france := world.get_country_by_legacy_index(21)
	var china := world.get_country_by_legacy_index(1)
	if eu_holder != null and eu_holder.has_tag("eu"):
		return false
	if usa_country != null and usa_country.has_tag("nato"):
		return false
	var both_blocks := gdr != null and gdr.has_tag("sev") and gdr.has_tag("ovd")
	if not both_blocks and not world.get_flag("is_gkchp"):
		return false
	if spain != null and spain.has_tag("soc_eu"):
		return false
	if france != null and (france.has_tag("fxseu") or france.has_tag("nazimao")):
		return false
	if world.event_done_num(713):
		return false
	if not world.event_done_num(548) and (china == null or not china.has_tag("rim")):
		return false
	return true


func _count_proprc() -> int:
	var count := 0
	for idx in PROPRC_LIST:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null and c.has_tag("亲中"):
			count += 1
	var belgium := ws.get_country_by_legacy_index(16)
	if belgium != null and belgium.parts.size() > 0 and belgium.parts[0] \
			and belgium.has_tag("亲中"):
		count += 1
	return count


## 原版 politics_dolshnost[2]<100 用外长，否则领袖（哨兵 150/200 走领袖）。
func _plan_author_name() -> String:
	if ws.politics_positions.size() > 2:
		var idx := ws.politics_positions[2]
		if idx >= 0 and idx < 100 and idx < ws.politicians.size() \
				and ws.politicians[idx] != null and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return _leader_name()


func _has_foreign_minister() -> bool:
	if ws.politics_positions.size() <= 2:
		return false
	var idx := ws.politics_positions[2]
	return idx >= 0 and idx < 100 and idx < ws.politicians.size() \
		and ws.politicians[idx] != null and ws.politicians[idx].name_display != ""


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


## 原版 result1 对中立国/芬兰的苏维埃转向：戈尔巴乔夫在位走 gov2/sub14，否则 gov1/sub1。
func _apply_soviet_turn(c: CountryData, ussr: EmpireData) -> void:
	c.有驻军基地 = true
	c.prc_power = 0
	c.sov_power = 1000
	if ussr != null and ussr.current_leader == 6:
		c.government = 2
		c.sub_government = 14
	else:
		c.government = 1
		c.sub_government = 1
	c.set_tag("亲苏", true)
	c.set_tag("对华贸易", true)
	c.set_tag("sev", true)
	c.set_tag("ovd", true)


## 原版 result1 的 c26 单独块（不动势力值）。
func _apply_finland_turn(c: CountryData, ussr: EmpireData) -> void:
	if ussr != null and ussr.current_leader == 6:
		c.government = 2
		c.sub_government = 14
	else:
		c.government = 1
		c.sub_government = 1
	c.set_tag("亲苏", true)
	c.set_tag("对华贸易", true)
	c.set_tag("sev", true)
	c.set_tag("ovd", true)
	c.有驻军基地 = true
