extends "res://数据脚本/event_script_base.gd"

## 原作 Event376.cs：欧加登战争（埃塞俄比亚/索马里三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（data[30]，见 event_435 约定）；
##  - 描述/选项显隐 prepare 按 c41.Gosstroy / c41.proprc 动态改写；
##  - war 15 按模板覆盖 name_war/fortnight_max。

const TXT_DESC_GOS := "索马里自宣布独立后，便向周边邻国提出了一系列领土要求。新政府主张建立所谓的“大索马里国”，按照计划，该国将吞并全部索马里人聚居地，其中包括一部分原属埃塞俄比亚、肯尼亚与吉布提的领土。在1969年革命后，穆罕默德·西亚德·巴雷得以掌权。他宣布将在索马里建设社会主义，并同苏联与社会主义阵营发展经贸往来。然而，巴雷并没有放弃对周边国家的领土野心。\n在反政变之后，双方关系有所改善，但这并不妨碍巴雷推行自己的大索马里理念。索马里试图利用埃塞俄比亚的混乱局势，并开始支持西索马里解放阵线。也就在20世纪70年代中期，解放阵线发动了一场旨在将欧加登地区从埃塞俄比亚地区分离，并让其并入索马里的武装斗争。\n最近，索马里军队则已开入了欧加登。为了打击背叛自己的埃塞俄比亚，苏联在冲突中支持西亚德·巴雷。因此，埃塞俄比亚不得不同我们和美国站在一起。\n抉择的时候到了，同志。也许我们应当支持埃塞俄比亚人民，作为阻止苏联在东非扩张影响力的前线，并为我们在当地寻求一位真正的盟友？又或者，我们应当支持索马里，从而恢复我们与社会主义阵营之间的关系？"
const TXT_DESC_PROPRC := "索马里自宣布独立后，便向周边邻国提出了一系列领土要求。新政府主张建立所谓的“大索马里国”，按照计划，该国将吞并全部索马里人聚居地，其中包括一部分原属埃塞俄比亚、肯尼亚与吉布提的领土。在1969年革命后，穆罕默德·西亚德·巴雷得以掌权。他宣布将在索马里建设社会主义，并同苏联与社会主义阵营发展经贸往来。然而，巴雷并没有放弃对周边国家的领土野心。\n门格斯图的我行我素和“红色恐怖”极大的打击了埃塞俄比亚的稳定，依托于我们的援助他才不至于崩溃。索马里试图利用埃塞俄比亚的混乱局势，并开始支持西索马里解放阵线。也就在20世纪70年代中期，解放阵线发动了一场旨在将欧加登地区从埃塞俄比亚地区分离，并让其并入索马里的武装斗争。\n最近，索马里军队则已开入了欧加登。为了打击背叛自己的埃塞俄比亚，苏联在冲突中支持西亚德·巴雷。因此，埃塞俄比亚不得不同我们和美国站在一起。\n抉择的时候到了，同志。也许我们应当支持埃塞俄比亚人民，作为阻止苏联在东非扩张影响力的前线，并为我们在当地寻求一位真正的盟友？"
const TXT_OPT0_GOS := "让我们支持埃塞俄比亚人反抗苏联马前卒（需要3.0百万{0}与5.0点{2}）"
const TXT_OPT1_GOS := "与埃塞政权断交并支持索马里（需要3.0百万{0}与5.0点{2}）"
const TXT_OPT1_DIS_ELSE := "别忘了我们要做的……"
const TXT_OPT0_NEUTRAL := "与巴雷政权断交并支持埃塞俄比亚（需要3.0百万{0}与5.0点{2}）"
const TXT_OPT1_NEUTRAL := "让我们支持索马里人的民族统一大业（需要3.0百万{0}与5.0点{2}）"
const TXT_R0_GOS := "我们选择在日益激化的区域冲突内支持埃塞俄比亚，并向他们送去了武器与相关设备。因此，他对我们表示相当感激。在击退了侵略者后，埃塞俄比亚宣布发起一场反攻。然而，随着苏联军事援助和志愿军的到来，战争进程开始放缓，并开始具有明显的阵地战特征。苏联和索马里谴责我们在冲突中支持社会主义的敌人埃塞俄比亚，但我们与美国的关系则有所改善。"
const TXT_R1_GOS := "就和在社会主义阵营内的绝大多数国家一样，我们派出了志愿军用来反抗埃塞俄比亚人。因此，索马里得以开始一场解放战争，对埃塞俄比亚军队发动全面进攻。\n索马里和苏联对我们的立场表示满意，而继续向埃塞俄比亚提供支持的美国，却在区域争街内再度落入劣势。"
const TXT_R2_GOS := "在苏联专家与多国志愿者抵达后，巴雷的局面便扶摇直上。战争的态势极大利好索马里，他们的胜利已经是板上钉钉的事情了。"
const TXT_R1_PROPRC := "我们选择在日益激化的区域冲突内支持索马里领导人巴雷，并向索马里送去了武器与相关设备。因此，他对我们表示相当感激。在占领占领吉吉加与哈勒尔后，索马里巩固了自己的初胜战果。然而，随着苏联军事援助和志愿军的到来，战争进程开始放缓，并开始具有明显的阵地战特征。苏联和埃塞俄比亚谴责我们在冲突中支持索马里侵略者，但我们与美国的关系则有所改善。"
const TXT_R0_NEUTRAL := "就和在社会主义阵营内的绝大多数国家一样，我们派出了支持埃塞俄比亚反抗索马里入侵的的志愿军，因此，埃塞俄比亚军队得以结束持续败退的局面，开始对侵略者发动全面进攻。埃塞俄比亚和苏联对我们的立场表示满意，而继续向巴雷政权提供支持的美国，却在区域争霸内再度落入劣势。"
const TXT_R2_NEUTRAL := "在苏联专家与多只志愿者抵达后，巴雷的局面便急转直下。战争的态势也被根本扭转，埃塞俄比亚方的胜利不过是时间问题。"
const TXT_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_DIS_ARMY := "军事实力必须高于{0}点......"
const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"
const TXT_WAR_NAME := "欧加登战争"
const TXT_WAR_ATT := "索马里"
const TXT_WAR_DEF := "埃塞俄比亚"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var ethiopia := world.get_country_by_legacy_index(41)
	var opt := event_def.options
	if ethiopia != null and ethiopia.government == 1:
		event_def.description = TXT_DESC_GOS
		_prepare_opt0(opt[0], TXT_OPT0_GOS)
		_prepare_opt1(opt[1], TXT_OPT1_GOS)
	elif ethiopia != null and ethiopia.has_tag("亲中"):
		event_def.description = TXT_DESC_PROPRC
		_prepare_opt0(opt[0], TXT_OPT0_GOS)
		_disable(opt[1], "")
	else:
		_prepare_opt0(opt[0], TXT_OPT0_NEUTRAL)
		_prepare_opt1(opt[1], TXT_OPT1_NEUTRAL)
	_enable(opt[2], event_def.options[2].text)


func _prepare_opt0(opt: EventOption, text: String) -> void:
	if _d(W.I_ARMY) >= 50 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 30:
		_enable(opt, text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt, TXT_DIS_BUDGET.format([3]))
	else:
		_disable(opt, TXT_DIS_ARMY.format([5]))


func _prepare_opt1(opt: EventOption, text: String) -> void:
	if _d(W.I_ARMY) >= 50 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 30 			and int(ws.completed_event_ids.get("event_585", 0)) != 2:
		_enable(opt, text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt, TXT_DIS_BUDGET.format([3]))
	elif _d(W.I_AGENTS) < 150:
		_disable(opt, TXT_DIS_AGENTS.format([15]))
	elif _d(W.I_ARMY) < 50:
		_disable(opt, TXT_DIS_ARMY.format([5]))
	else:
		_disable(opt, TXT_OPT1_DIS_ELSE)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var ethiopia := ws.get_country_by_legacy_index(41)
	var somalia := ws.get_country_by_legacy_index(42)
	var num := 0
	if int(ws.completed_event_ids.get("event_587", 0)) == 2:
		num = 100
	var opt := int(context.get("option_index", -1))
	if ethiopia != null and ethiopia.government == 1:
		match opt:
			0:
				context["result_text"] = TXT_R0_GOS
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USA, 10)
				_add_relation(EmpireData.USA, 120)
				_add_relation(EmpireData.USSR, -150)
				d[W.I_COMMUNICATIONS] -= 20
				_add(W.I_PARTY_SUPPORT, 100)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", true)
				_start_war_376(400, 600, 0, 1)
			1:
				context["result_text"] = TXT_R1_GOS
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USSR, 10)
				_add_relation(EmpireData.USSR, 120)
				_add_relation(EmpireData.USA, -150)
				d[W.I_COMMUNICATIONS] += 20
				_add(W.I_PARTY_SUPPORT, 100)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", false)
				if somalia != null:
					somalia.set_tag("对华贸易", true)
				_start_war_376(600, 400, 0, 1)
			2:
				context["result_text"] = TXT_R2_GOS
				_start_war_376(550, 450, 0, 1)
	elif ethiopia != null and ethiopia.has_tag("亲中"):
		match opt:
			0:
				context["result_text"] = TXT_R0_GOS
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USA, 10)
				_add_relation(EmpireData.USA, 120)
				_add_relation(EmpireData.USSR, -150)
				d[W.I_COMMUNICATIONS] -= 20
				_add(W.I_PARTY_SUPPORT, 100)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", true)
				_start_war_376(400, 600, 0, 1)
			1:
				context["result_text"] = TXT_R1_PROPRC
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USSR, 10)
				_add_relation(EmpireData.USSR, 120)
				_add_relation(EmpireData.USA, -150)
				d[W.I_COMMUNICATIONS] += 20
				_add(W.I_PARTY_SUPPORT, 100)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", false)
				if somalia != null:
					somalia.set_tag("对华贸易", true)
				_start_war_376(550, 450, 1, 0)
			2:
				context["result_text"] = TXT_R2_GOS
				_start_war_376(550, 450, 0, 1)
	else:
		if somalia != null:
			somalia.set_tag("亲苏", false)
		match opt:
			0:
				context["result_text"] = TXT_R0_NEUTRAL
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USSR, 10)
				_add_relation(EmpireData.USSR, 120)
				_add_relation(EmpireData.USA, -150)
				d[W.I_COMMUNICATIONS] += 20
				_add(W.I_PARTY_SUPPORT, 100)
				if somalia != null:
					somalia.set_tag("对华贸易", false)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", true)
				_start_war_376(300 + num, 700 - num, 1, 0)
			1:
				context["result_text"] = TXT_R1_PROPRC
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USA, 10)
				_add_relation(EmpireData.USA, 120)
				_add_relation(EmpireData.USSR, -150)
				d[W.I_COMMUNICATIONS] -= 20
				_add(W.I_PARTY_SUPPORT, 100)
				if somalia != null:
					somalia.set_tag("对华贸易", true)
				_start_war_376(550 + num, 450 - num, 1, 0)
			2:
				context["result_text"] = TXT_R2_NEUTRAL
				_start_war_376(400 + num, 600 - num, 1, 0)


func _start_war_376(infl1: int, infl2: int, usa_side: int, ussr_side: int) -> void:
	GameManager.start_war(15, TXT_WAR_ATT, TXT_WAR_DEF, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > 15 and ws.wars[15] != null:
		ws.wars[15].name_war = TXT_WAR_NAME
		ws.wars[15].fortnight_max = 16




func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0






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
