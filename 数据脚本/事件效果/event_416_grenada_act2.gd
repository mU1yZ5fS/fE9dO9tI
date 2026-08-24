extends "res://数据脚本/event_script_base.gd"

## 原作 Event416.cs：我的格林纳达？第二幕（四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1326 —— ExprNode 组合。
## 差异：EstablishGovernment 仅改倾向标签；dev→development。

const TXT_TITLE := [
	"我的格林纳达？第二幕",
]

const TXT_DESC := [
	"尽管格林纳达的社会主义革命在社会改革方面取得了一系列成就，但还是未能解决该国的经济问题。在美国宣布对其进行制裁后，局势便进一步恶化。莫里斯·毕晓普政府决定向美国与国际货币基金组织妥协让步，以此换取后者对该国的制裁放松，但美国拒绝为格林纳达提供贷款。因此，执政党内的派系斗争加剧了。以代总理伯纳德·科尔德和格林纳达军队总司令赫德森·奥斯汀将军为首的激进左派对莫里斯·毕晓普总统的温和派方案相当反感。现在，格林纳达武装部队正计划逮捕莫里斯·毕晓普，并建立反美军事独裁政权。同时，格林纳达民主同盟在邻国巴巴多斯宣布建立。其成员均反对格林纳达现行的马克思主义政府。问题不只在于资助谁，还有要不要资助的问题，毕竟格林纳达不过是个偏远小岛而已。这样的小国在世界上怎么也掀不起波澜。",
]

const TXT_OPT0 := [
	"支持格林纳达激进左派，并让它们加入我方势力范围（需要15.0百万预算与15.0点特工网络）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT1 := [
	"支持毕晓普领导的温和共产主义者（需要5.0百万预算与10.0点特工网络）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT2 := [
	"格林纳达在哪？不关我事",
]

const TXT_OPT3 := [
	"加入美国的干涉行动并支持自由派",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
	"我们还没有实现与美国中央情报局的合作......",
]

const TXT_R := [
	"10月13日，以科尔德·奥斯汀为首的激进左翼分子掀起了一场反对莫里斯·毕晓普的军事政变，后者因蓄谋发动亲美政变而被逮捕。随后，该国左翼激进派宣布将和中国同志们团结一致。而我们在联合国的代表公开了美国与其加勒比盟友计划入侵格林纳达的阴谋。在联合国聚焦我方声明的情况下，格利纳达政变很快就被忘记了。",
	"我们向莫里斯·毕晓普送去了警告。他在得到军中效忠派的支持后，便以发动蓄谋军事政变为由，逮捕了科尔德·奥斯汀领导的左翼激进派。从而巩固了自己在格利纳达的权力。",
	"10月13日，以科尔德·奥斯汀为首的激进左翼分子掀起了一场反对莫里斯·毕晓普的军事政变，后者因蓄谋发动亲美政变而被逮捕。政变军人们以临时的革命军事委员会取代了原政府，前者由奥斯汀将军坐镇。革命军事委员会引入了为期4天的戒严令。而支持者营救前总理的计划失败了，于10月19日被枪决。东加勒比国家组织、巴巴多斯和牙买加借机向美国寻求帮助。最终在10月25日，位于巴巴多斯的美国国家与区域安全体系联合部队入侵格林纳达。三天后，新政府便被击溃。联合国的绝大多数成员谴责入侵行动，并认为其违反了国际法。",
	"10月13日，以科尔德·奥斯汀为首的激进左翼分子掀起了一场反对莫里斯·毕晓普的军事政变，后者因蓄谋发动亲美政变而被逮捕。政变军人们以临时的革命军事委员会取代了原政府，前者由奥斯汀将军坐镇。革命军事委员会引入了为期4天的戒严令。而支持者营救前总理的计划失败了，于10月19日被枪决。东加勒比国家组织、巴巴多斯和牙买加借机向美国寻求帮助。最终在10月25日，位于巴巴多斯的美国国家与区域安全体系联合部队入侵格林纳达。三天后，新政府便被击溃。联合国的绝大多数成员谴责入侵行动，并认为其违反了国际法。格林纳达民主联盟则在战后顺势夺权，并宣布将和中国开展合作。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1299 := "我的格林纳达？第二幕"
const TXT_IDX_1300 := "尽管格林纳达的社会主义革命在社会改革方面取得了一系列成就，但还是未能解决该国的经济问题。在美国宣布对其进行制裁后，局势便进一步恶化。莫里斯·毕晓普政府决定向美国与国际货币基金组织妥协让步，以此换取后者对该国的制裁放松，但美国拒绝为格林纳达提供贷款。因此，执政党内的派系斗争加剧了。以代总理伯纳德·科尔德和格林纳达军队总司令赫德森·奥斯汀将军为首的激进左派对莫里斯·毕晓普总统的温和派方案相当反感。现在，格林纳达武装部队正计划逮捕莫里斯·毕晓普，并建立反美军事独裁政权。同时，格林纳达民主同盟在邻国巴巴多斯宣布建立。其成员均反对格林纳达现行的马克思主义政府。问题不只在于资助谁，还有要不要资助的问题，毕竟格林纳达不过是个偏远小岛而已。这样的小国在世界上怎么也掀不起波澜。"
const TXT_IDX_1301 := "支持格林纳达激进左派，并让它们加入我方势力范围（需要15.0百万{0}与15.0点{1}）"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_1302 := "支持毕晓普领导的温和共产主义者（需要5.0百万{0}与10.0点{1}）"
const TXT_IDX_1295 := "格林纳达在哪？不关我事"
const TXT_IDX_1303 := "加入美国的干涉行动并支持自由派"
const TXT_IDX_659 := "我们还没有实现与美国中央情报局的合作......"
const TXT_IDX_1304 := "10月13日，以科尔德·奥斯汀为首的激进左翼分子掀起了一场反对莫里斯·毕晓普的军事政变，后者因蓄谋发动亲美政变而被逮捕。随后，该国左翼激进派宣布将和中国同志们团结一致。而我们在联合国的代表公开了美国与其加勒比盟友计划入侵格林纳达的阴谋。在联合国聚焦我方声明的情况下，格利纳达政变很快就被忘记了。"
const TXT_IDX_1305 := "我们向莫里斯·毕晓普送去了警告。他在得到军中效忠派的支持后，便以发动蓄谋军事政变为由，逮捕了科尔德·奥斯汀领导的左翼激进派。从而巩固了自己在格利纳达的权力。"
const TXT_IDX_1306 := "10月13日，以科尔德·奥斯汀为首的激进左翼分子掀起了一场反对莫里斯·毕晓普的军事政变，后者因蓄谋发动亲美政变而被逮捕。政变军人们以临时的革命军事委员会取代了原政府，前者由奥斯汀将军坐镇。革命军事委员会引入了为期4天的戒严令。而支持者营救前总理的计划失败了，于10月19日被枪决。东加勒比国家组织、巴巴多斯和牙买加借机向美国寻求帮助。最终在10月25日，位于巴巴多斯的美国国家与区域安全体系联合部队入侵格林纳达。三天后，新政府便被击溃。联合国的绝大多数成员谴责入侵行动，并认为其违反了国际法。"
const TXT_IDX_1307 := "10月13日，以科尔德·奥斯汀为首的激进左翼分子掀起了一场反对莫里斯·毕晓普的军事政变，后者因蓄谋发动亲美政变而被逮捕。政变军人们以临时的革命军事委员会取代了原政府，前者由奥斯汀将军坐镇。革命军事委员会引入了为期4天的戒严令。而支持者营救前总理的计划失败了，于10月19日被枪决。东加勒比国家组织、巴巴多斯和牙买加借机向美国寻求帮助。最终在10月25日，位于巴巴多斯的美国国家与区域安全体系联合部队入侵格林纳达。三天后，新政府便被击溃。联合国的绝大多数成员谴责入侵行动，并认为其违反了国际法。格林纳达民主联盟则在战后顺势夺权，并宣布将和中国开展合作。"

## 原文字符串附录（供自检）

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.completed_event_ids.has("event_416"):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_YEAR:
		return false
	if not ((d.year == 1983 and d.month >= 3 and d.day >= 10) or (d.year == 1983 and d.month >= 4) or d.year >= 1984):
		return false
	var c48 := world.get_country_by_legacy_index(48)
	if c48 != null and c48.has_tag("sev"):
		return false
	if world.empires.size() <= 0 or world.empires[0] == null:
		return false
	return world.empires[0].current_leader == 0

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var opt := event_def.options
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	if budget_reserve >= 100 and d.agents >= 150:
		_enable(opt[0], TXT_OPT0[0])
	elif budget_reserve < 100:
		_disable(opt[0], _fmt(TXT_OPT0[1], [15]))
	else:
		_disable(opt[0], _fmt(TXT_OPT0[2], [15]))
	if budget_reserve >= 50 and d.agents >= 100:
		_enable(opt[1], TXT_OPT1[0])
	elif budget_reserve < 50:
		_disable(opt[1], _fmt(TXT_OPT1[1], [5]))
	else:
		_disable(opt[1], _fmt(TXT_OPT1[2], [10]))
	_enable(opt[2], TXT_OPT2[0])
	var us := world.get_country_by_legacy_index(51)
	if budget_reserve >= 100 and d.agents >= 150 and us != null and us.development > 0:
		_enable(opt[3], TXT_OPT3[0])
	elif budget_reserve < 100:
		_disable(opt[3], _fmt(TXT_OPT3[1], [15]))
	elif d.agents < 150:
		_disable(opt[3], _fmt(TXT_OPT3[2], [15]))
	else:
		_disable(opt[3], TXT_OPT3[3])

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var grenada := ws.get_country_by_legacy_index(48)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		if grenada != null:
			grenada.government = GameConstants.Government.AUTHORITARIAN
			grenada.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
			_set_pro_china(grenada)
			grenada.set_tag("对华贸易", true)
		_add_power(EmpireData.USSR, -10)
		ws.influence_prc += 20
		_add_relation(EmpireData.USSR, -100)
		_add_relation(EmpireData.USA, -100)
		for p in ws.politicians:
			if p == null:
				continue
			if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
				p.loyalty += 300
			elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
				p.loyalty += 10
			else:
				p.loyalty -= 50
		context["result_text"] = TXT_R[0]
	elif opt == 1:
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -100)
		_add_power(EmpireData.USSR, 10)
		_add_relation(EmpireData.USSR, -150)
		_add_relation(EmpireData.USA, 100)
		if grenada != null:
			grenada.set_tag("对华贸易", true)
		for p in ws.politicians:
			if p == null:
				continue
			if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
				p.loyalty -= 200
			elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
				p.loyalty += 100
			else:
				p.loyalty -= 50
		context["result_text"] = TXT_R[1]
	elif opt == 2:
		if grenada != null:
			grenada.set_tag("对华贸易", false)
			grenada.government = GameConstants.Government.LIBERAL
			grenada.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			_set_pro_american(grenada)
		_add_power(EmpireData.USSR, -10)
		_add_power(EmpireData.USA, 20)
		context["result_text"] = TXT_R[2]
	else:
		_add_power(EmpireData.USSR, -20)
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		_add_relation(EmpireData.USSR, -250)
		if ws.influence_prc > ws.empires[0].power:
			if grenada != null:
				_set_pro_china(grenada)
				grenada.set_tag("对华贸易", true)
				grenada.government = china.government if china != null else 0
				grenada.sub_government = china.sub_government if china != null else 0
			ws.influence_prc += 20
		else:
			if grenada != null:
				_set_pro_american(grenada)
				grenada.set_tag("对华贸易", true)
				grenada.government = GameConstants.Government.LIBERAL
				grenada.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			ws.influence_prc += 20
		for p in ws.politicians:
			if p == null:
				continue
			if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
				p.loyalty -= 300
			elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
				p.loyalty -= 100
			else:
				p.loyalty += 300
		context["result_text"] = TXT_R[3]

func _raw(i: int) -> int:
	if d.size() > i:
		return d.get_data_by_index(i)
	return 0

func _set_pro_china(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _set_pro_american(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", false)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", true)
