extends "res://数据脚本/event_script_base.gd"

## 原作 Event390.cs：向红看齐？（法国政治危机，两选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - YugAgree → ws.get_flag("YugAgree")；
##  - data.france_socialist_vote/data.france_communist_vote 随机值用 randi_range 复现；
##  - 原版 Debug.Log 跳过；empires[1].leaders[4].support 直访判空。

const TXT_DESC_YUG_FMT := "1981年举行的上届法国议会选举中，左翼联盟以巨大优势获胜。其中，社会党获得了{1}%的选票，而共产党收获{2}%的支持。因此，罗兰·勒罗伊总统不得不在多党联合政府框架下执政，该国政府由共产党人古斯塔夫·安萨尔领导。\n过去的两年内，法国社会主义政府引入了一系列的激进改革：该国已经准备了一部新教育法，关键部门与经济领域已被国有化，左翼控制的工会权力已经大大扩展；选举上，改革也开始倾向下层阶级，资产阶级的媒体权限限制被限制，并被课以重税。然而，改革者遭遇到了来自欧洲一体化结构的障碍，后者完全是基于自由主义经济原则运行的组织，并积极阻碍法兰西银行的工作。\n在内部，共产党和社会党的右翼开始反对政府的激进政策，他们以激进改革导致的形势恶化为由，积极阻碍改革。\n需要注意的是，右翼政党绝不会轻易接受自己的失败，他们试图通过动员选民并发起罢工和抗议来对抗政府的激进主义政策。而对产业与银行部门的国有化导致了资本外流与税源减少的问题，并引起了通货膨胀。右翼已经团结起来，开始阻止左翼政府的行动。现在，法国比以往任何时候都要更接近政治危机。\n目前，还很难对罗兰·勒罗伊的选举承诺以及其呼吁在法国建设社会主义的理念下定论。但各种情况已经表面，权力关系的演变正朝着不利于他的局势而发展。"
const TXT_DESC_FMT := "1981年举行的上届法国议会选举中，左翼联盟以巨大优势获胜。其中，社会党获得了{1}%的选票，而共产党收获{2}%的支持。因此，乔治·马歇总统不得不在多党联合政府框架下执政，他所属的政党也只能占据财政、教育、工业三大部长的席位，以及一系列的次要议席。该国政府由社会党人皮埃尔·莫鲁瓦领导。\n过去的两年内，法国社会主义政府引入了一系列的激进改革：该国已经准备了一部新教育法，关键部门与经济领域已被国有化，社会改革则在凯恩斯主义的指导下推进。然而，改革者遭遇到了来自欧洲一体化结构的障碍，后者完全是基于自由主义经济原则运行的组织，并积极阻碍法兰西银行的工作。\n需要注意的是，右翼绝不会轻易接受自己的失败，他们试图通过动员选民与抗议来对抗政府的激进主义政策，对产业与银行部门的国有化导致了资本外流与税源减少。\n目前，还很难对乔治·马歇的选举承诺，以及其呼吁在法国建设民主社会主义的理念下定论。但各种情况已经表面，权力关系的演变正朝着不利于他的局势而发展。"
const TXT_1052 := "为法国共产党提供财政与特工支持，以交换该党回归无产阶级专政原则，并带领法国退出北约与欧共体"
const TXT_1053 := "建议马歇与经济互助委员会深化联系"
const TXT_1054 := "党内的改革派与自由派不会允许我们这么做的......"
const TXT_OPT0_DEFAULT := "为法国渡过困难提供援助"
const TXT_OPT0_YUG := "动员苏东阵营向法国政府共同提供援助并邀请其成为经济互助委员会观察员国"
const TXT_DIS_INFLUENCE := "中国的国际影响力应高于{0}......"
const TXT_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_DIS_SEV := "中国并不是经济互助委员会的成员......"
const TXT_R0_DEFAULT := "乔治·马歇总统宣布将启动第二轮改革——法国宣布减少本国对欧洲货币体系与欧洲经济共同体的活动，并称后者的政策“触及原则底线问题，并与国家的社会经济发展方向背道而驰”。同时，法国领导人宣布将通过新法案，加强与第三世界国家和苏东国家的经贸关系。在非洲政策上，法国将进行彻底去殖民化，结束与非洲国家的“新殖民主义关系”，并资助非洲左翼。\n部分由社会党人与右翼分子认为，这项政策标志着法国对欧洲-大西洋一体化路线的拒绝。然而，一部分来自社会党的左派成员支持政府的新政。因此，左翼联盟得以在国民议会内保持多数。"
const TXT_R0_YUG := "在此之后，罗兰·勒罗伊总统宣布将启动第二轮改革——法国宣布减少本国对欧洲货币体系与欧洲经济共同体的活动，并称后者的政策“触及原则底线问题，并与国家的社会经济发展方向背道而驰”。同时，法国领导人宣布将通过新法案，退出北大西洋公约组织的军事一体化部门。新政府通过了组织工人赤卫队的法律，政府被允许利用赤卫队保护社会主义，并对右翼进行反击。苏联和东德的顾问团也被邀请驻法以巩固政府。更加深入的经济改革也正在开展，法国正在进行合作社运动和更多的国有化。在非洲政策上，法国将进行彻底去殖民化，结束与非洲国家的“新殖民主义关系”，并资助非洲左翼。\n很快，法国领导人宣布将通过新法案，加强与第三世界国家的经贸关系，并成为经互会观察员国。社会党右派与右翼分子认为，这项政策标志着法国对欧洲-大西洋一体化路线的拒绝。然而，社会党左派的成员支持政府的新政。因此，左翼联盟得以在国民议会内保持多数。"
const TXT_R1_DEFAULT := "在抗议的压力面前，总统不得不在国民议会内举行新一轮选举，右派在其中取得大胜，并建立了由戴高乐主义者雅克·希拉克领导的新一届政府。后者宣布将启动再私有化政策，并强调了对第五共和国的政治部门进行改革的必要性。左翼总统与右翼总理的“共治期”就这样开始了......"
const TXT_R1_YUG := "在罢工、抗议和政府内部的不和的巨大压力之下，总统和政府不得不双双选择辞职。极右翼政党国民阵线利用了群众对左翼的失望和对苏联的情绪，以及右翼选民对中右翼两党的失望，勒庞得益于他的民粹主义言论，在选举中取得以微弱优势胜利。让-玛丽·勒庞当选为新一届总统，而在议会选举中，国民阵线也得以组成勒庞-戴高乐主义政府。勒庞总统宣布将启动再私有化政策，并强调了对第五共和国的政治进行改革的必要性。法国社会就这样迎来了一个右转时期……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	if world.get_flag("YugAgree"):
		event_def.description = TXT_DESC_YUG_FMT.format(["\n", randi_range(31, 39), randi_range(20, 24), _ussr_leader_text(world)])
	else:
		event_def.description = TXT_DESC_FMT.format(["\n", randi_range(31, 39), randi_range(20, 24), _ussr_leader_text(world)])
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if world.get_flag("YugAgree"):
		if china != null and china.has_tag("sev") and _d(W.I_AGENTS) >= 150 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 150:
			_enable(opt[0], TXT_OPT0_YUG)
		else:
			_disable(opt[0], TXT_DIS_SEV)
	else:
		if world.influence_prc >= 500 and _d(W.I_AGENTS) >= 150 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 100 				and (game.is_faction_leading(0) or game.is_faction_leading(1) or game.is_faction_leading(2)):
			_enable(opt[0], TXT_OPT0_DEFAULT)
		elif world.influence_prc < 500:
			_disable(opt[0], TXT_DIS_INFLUENCE.format([50]))
		elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 100:
			_disable(opt[0], TXT_DIS_BUDGET.format([35]))
		elif _d(W.I_AGENTS) < 150:
			_disable(opt[0], TXT_DIS_AGENTS.format([15]))
		else:
			_disable(opt[0], TXT_1054)
	_enable(opt[1], event_def.options[1].text)


func _ussr_leader_text(world: WorldState) -> String:
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null:
		if world.empires[EmpireData.USSR].current_leader == 1:
			return TXT_1052
		elif world.empires[EmpireData.USSR].current_leader == 2:
			return TXT_1053
	return TXT_1054


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var _num := _calc_num(ws)
	var france := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	if not ws.get_flag("YugAgree"):
		if opt == 0:
			_add(W.I_AGENTS, -150)
			_add(W.I_BUDGET, -100)
			context["result_text"] = TXT_R0_DEFAULT
			if france != null:
				france.set_tag("eu", false)
			_add_power(EmpireData.USA, -50)
			_add_power(EmpireData.USSR, 30)
		else:
			context["result_text"] = TXT_R1_DEFAULT
			if france != null:
				france.government = GameConstants.Government.LIBERAL
				france.sub_government = GameConstants.SubGovernment.MODERATE
			_add_power(EmpireData.USA, 50)
	else:
		if opt == 0:
			_add(W.I_AGENTS, -150)
			_add(W.I_BUDGET, -150)
			context["result_text"] = TXT_R0_YUG
			if france != null:
				france.set_tag("eu", false)
				france.set_tag("nato", false)
				france.government = GameConstants.Government.SOCIALIST
				france.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				france.set_tag("亲苏", true)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null 					and ws.empires[EmpireData.USSR].leaders.size() > 4:
				ws.empires[EmpireData.USSR].leaders[4].support += 1
			_add_power(EmpireData.USA, -80)
			_add_power(EmpireData.USSR, 80)
		else:
			context["result_text"] = TXT_R1_YUG
			if france != null:
				france.government = GameConstants.Government.AUTHORITARIAN
				france.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				france.set_tag("eu", false)
				france.set_tag("nato", false)
			if ws.modifiers.size() > 44 and ws.modifiers[44] != null:
				ws.modifiers[44].is_active = false
			_add_power(EmpireData.USA, 50)


func _calc_num(world: WorldState) -> int:
	var num := 0
	var spain := world.get_country_by_legacy_index(86)
	var italy := world.get_country_by_legacy_index(85)
	var portugal := world.get_country_by_legacy_index(87)
	var greece := world.get_country_by_legacy_index(45)
	var usa := world.get_country_by_legacy_index(51)
	if spain != null and spain.government == GameConstants.Government.REFORMIST:
		num += 1
	if italy == null or not italy.has_tag("eu"):
		num += 1
	if spain == null or not spain.has_tag("eu"):
		num += 1
	if portugal == null or not portugal.has_tag("eu"):
		num += 1
	if greece == null or not greece.has_tag("eu"):
		num += 1
	if usa != null and usa.has_tag("对华贸易"):
		num -= 1
	if usa != null and usa.development > 0:
		num -= 1
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null 			and world.empires[EmpireData.USA].current_leader == 1:
		num += 1
	else:
		num -= 1
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null 			and world.empires[EmpireData.USSR].current_leader == 3:
		num += 1
	var num2 := 0
	var china := world.get_country_by_legacy_index(1)
	for c in world.countries:
		if c != null and (c.has_tag("econ") or (china != null and china.has_tag("sev") and c.has_tag("sev"))):
			num2 += 1
	if num2 > 4:
		num += 1
	elif num2 > 9:
		num += 2
	elif num2 > 14:
		num += 3
	if _d(W.I_INFLUENCE) > world.empires[EmpireData.USA].power:
		num += 1
	else:
		num -= 1
	return num




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0





