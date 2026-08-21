extends "res://数据脚本/event_script_base.gd"

## 原作 Event432.cs：共和派阵营的崩溃？（四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1419-1421 —— ExprNode 组合。
## 差异：Gosstroy→government；SubGosstroy→sub_government；spec→special；prosov→亲苏；
##  - data.world_political_balance raw；resultOfEvents[424] 缺省 0 语义由 .tres 的 ANY(not_done, result==0) 表达。

const TXT_OPT0_EN := "支持共产党人（需要10.0百万{0}与25.0点{1}）"
const TXT_OPT1_EN := "支持社会党人（需要10.0百万{0}与25.0点{1}）"
const TXT_OPT2_EN := "支持民主党人（需要10.0百万{0}与25.0点{1}）"
const TXT_R1 := "选举结果表明，西班牙工人社会党赢得多数选票。弗朗西斯科·布斯特洛被推上领导人之位，宣布西班牙将开始彻底去殖民化（比如将修达、梅梅利亚和加那利群岛归还给摩洛哥）、落实西班牙的联邦化、确定中立的外交政策，并开始进行社会主义改革。"
const TXT_R2 := "选举结果表明，西班牙共产党赢得多数选票。伊格纳西奥·加列戈被推上领导人之位，宣布西班牙将开始彻底去殖民化（比如将修达、梅梅利亚和加那利群岛归还给摩洛哥）、落实各民族真正的平等和自治、加强与苏东阵营的合作，并开始向社会主义过渡。"
const TXT_R3 := "选举结果表明，苏亚雷斯的党再度赢得多数选票。苏亚雷斯宣布，西班牙有必要继续推动共和国民主化与自由化转型。"
const TXT_NAME_PEOPLE_SPAIN := "人民西班牙"
const TXT_IDX_1454 := "共和派阵营的崩溃？"
const TXT_IDX_1455 := "第二次内战时期的团结与政治合作的时期已经结束。自1977年以来，西班牙就没有举行过选举。因此，该国议会的构成基本上延续了那时的模样，右翼与极右翼政党纷纷被驱逐出局。现在，每股政治势力对西班牙公众的影响力几乎相等，社会因为清理了一切右翼分子和恢复了共和国的记忆而显得相当左倾。其中，苏亚雷斯的党并不希望举行选举，毕竟他们害怕丢掉自己的议会多数与执政地位。然而在右派失败后，相当数量的资产阶级转而成为了他那中间派政党的支持者。西班牙工人社会党的社会主义左翼崛起了，费利佩·冈萨雷斯在一次大会上被谴责“个人主义、实用主义、放弃社会主义和大搞个人崇拜”而被轰下了台，左翼领袖弗朗西斯科·布斯特洛当选为新的总书记，帕布勒·卡斯蒂利亚和路易斯·戈麦斯·洛伦特则成为了他的副手。修正马克思主义和自我管理社会主义成为了社会党的主流意识形态。西班牙共产党则谴责了圣地亚哥·卡里略的“右倾、同君主制妥协”，导致他被迫辞职。党的大会选举正统派的领袖伊格纳西奥·加列戈作为新总书记。新领导层与过去因反对欧洲共产主义路线而分裂出去的正统派西班牙统一共产党达成了和解，两党重新合并。同时，西共加强了党在工人阶级内的影响力，并控制了工会，在社会上获得了广泛支持。|在左翼政党的压力下，政府不得不做出妥协并宣布举行新选举的日期。然而，尚不清楚谁将成为赢家。但可以推断，选举结果将取决于目前的外交局势。因此，我们得以在西班牙见缝插针。"
const TXT_IDX_1456 := "支持共产党人（需要10.0百万{0}与25.0点{1}）"
const TXT_IDX_1457 := "支持社会党人（需要10.0百万{0}与25.0点{1}）"
const TXT_IDX_1458 := "支持民主党人（需要10.0百万{0}与25.0点{1}）"
const TXT_IDX_1459 := "不闻不问"
const TXT_IDX_1460 := "选举结果表明，西班牙工人社会党赢得多数选票。弗朗西斯科·布斯特洛被推上领导人之位，宣布西班牙将开始彻底去殖民化（比如将修达、梅梅利亚和加那利群岛归还给摩洛哥）、落实西班牙的联邦化、确定中立的外交政策，并开始进行社会主义改革。"
const TXT_IDX_1461 := "选举结果表明，西班牙共产党赢得多数选票。伊格纳西奥·加列戈被推上领导人之位，宣布西班牙将开始彻底去殖民化（比如将修达、梅梅利亚和加那利群岛归还给摩洛哥）、落实各民族真正的平等和自治、加强与苏东阵营的合作，并开始向社会主义过渡。"
const TXT_IDX_1462 := "选举结果表明，苏亚雷斯的党再度赢得多数选票。苏亚雷斯宣布，西班牙有必要继续推动共和国民主化与自由化转型。"
const TXT_IDX_1463 := "人民西班牙"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_776 := "军事实力必须高于{0}点......"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"



func _raw(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s





func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	if budget_reserve >= 100 and agents >= 250:
		_enable(event_def.options[0], _fmt(TXT_OPT0_EN, [TXT_IDX_592, TXT_IDX_593]))
		_enable(event_def.options[1], _fmt(TXT_OPT1_EN, [TXT_IDX_592, TXT_IDX_593]))
		_enable(event_def.options[2], _fmt(TXT_OPT2_EN, [TXT_IDX_592, TXT_IDX_593]))
	elif budget_reserve < 100:
		_disable(event_def.options[0], _fmt(TXT_IDX_566, [10]))
		_disable(event_def.options[1], _fmt(TXT_IDX_566, [10]))
		_disable(event_def.options[2], _fmt(TXT_IDX_566, [10]))
	else:
		_disable(event_def.options[0], _fmt(TXT_IDX_567, [25]))
		_disable(event_def.options[1], _fmt(TXT_IDX_567, [25]))
		_disable(event_def.options[2], _fmt(TXT_IDX_567, [25]))
	_enable(event_def.options[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var spain := ws.get_country_by_legacy_index(86)
	var portugal := ws.get_country_by_legacy_index(87)
	var num := 0
	var num2 := 0
	var num3 := 0
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		num3 += 2
	elif opt == 1:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		if spain != null:
			spain.government = GameConstants.Government.AUTHORITARIAN
			spain.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		if portugal != null:
			portugal.special -= 5
		num2 += 2
	elif opt == 2:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		num += 2
	if spain != null:
		if spain.government == GameConstants.Government.SOCIALIST:
			num3 += 2
			num2 += 1
		elif spain.government == GameConstants.Government.LIBERAL:
			num += 2
	if _raw(131) == 2:
		num3 += 1
		num2 += 1
	elif _raw(131) == 1:
		num2 += 1
	else:
		num += 2
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null:
		if greece.government == GameConstants.Government.REFORMIST:
			num2 += 2
			num3 += 1
		elif greece.government == GameConstants.Government.SOCIALIST:
			num3 += 2
			num2 += 1
		else:
			num += 1
	else:
		num += 1
	var uk := ws.get_country_by_legacy_index(92)
	if uk != null:
		if uk.government == GameConstants.Government.SOCIALIST:
			num3 += 1
		elif uk.government == GameConstants.Government.REFORMIST:
			num2 += 1
		else:
			num += 1
	else:
		num += 1
	var italy := ws.get_country_by_legacy_index(85)
	if italy != null:
		if italy.government == GameConstants.Government.LIBERAL:
			num += 1
		elif italy.government == GameConstants.Government.REFORMIST:
			num2 += 1
		elif italy.government == GameConstants.Government.SOCIALIST:
			num3 += 1
	var num4 := 1 if (num2 >= num3 and num2 >= num) else (2 if (num3 >= num2 and num3 >= num) else 3)
	if spain != null:
		if num4 == 1:
			spain.government = GameConstants.Government.REFORMIST
			spain.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		elif num4 == 2:
			spain.government = GameConstants.Government.SOCIALIST
			spain.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
			spain.name = TXT_NAME_PEOPLE_SPAIN
			spain.set_tag("亲苏", true)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].leaders.size() > 4:
				ws.empires[EmpireData.USSR].leaders[4].support += 1
		else:
			spain.government = GameConstants.Government.LIBERAL
			spain.sub_government = GameConstants.SubGovernment.MODERATE
	if num4 == 1:
		context["result_text"] = TXT_R1
	elif num4 == 2:
		context["result_text"] = TXT_R2
	else:
		context["result_text"] = TXT_R3
