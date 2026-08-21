extends "res://数据脚本/event_script_base.gd"

## 原作 Event404.cs：工党阵营的分裂（四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1266 —— DATE_AFTER 1982.1.1。
## 差异：old_modify_texts[57] 为展示文案跳过；politic.traits[0]→trait_personality；based→有驻军基地。

const TXT_TITLE := [
	"工党阵营的分裂",
]

const TXT_DESC := [
	"1979年之后，工党发现自己被玛格丽特·撒切尔领导的强硬保守党政府所压制，她基本上否定了自20世纪50年代以来就获得工党与保守党支持的战后经济和社会政策共识。输掉1979年选举后，工党开始更加左倾，党内左翼力量逐步壮大，其中最具代表性的是以托尼·本恩为首的“硬左派”和以迈克尔·富特为首的“软左派”。本恩等硬左派秉持强烈的社会主义与共和主义主张，且同情马克思主义——他曾在1976年尝试竞选工党领袖，但未能成功。富特等软左派则在一些议题上更具妥协性，以更好进行竞选和换取党内的团结。党内右翼对左翼的崛起深感不满，工党逐渐陷入派系倾轧的困境。这种内部矛盾导致1980年詹姆斯·卡拉汉辞职后，工党推选出了一位妥协性领导人（托尼·本恩未参与此次领导人选举）——迈克尔·富特，工党希望通过此举维系党内团结。然而，党内右派显然对他也极为不满，他们认为富特坚持英国实行单方面核裁军、退出欧洲经济共同体（EEC）的立场过于激进且带有极左色彩。事与愿违，党内团结终究未能实现。工党内部一部分有影响力的右翼党员选择出走，其中就包括罗伊·詹金斯、戴维·欧文、比尔·罗杰斯与雪莉·威廉姆斯组成的“工党四人帮”，以及罗伯特·麦克伦南，他们随后共同组建了社会民主党。尽管启用了新的党名，但该党实际上推行中间派政策，并且开始与自由党建立联系，这一举措或将吸引部分中间派选民的支持。与此同时，工党内的左派和右派围绕副领袖职位展开了争夺。右派成员团结在党的副领袖丹尼斯·希利周围，尝试抵制左派势力的进一步壮大；而“硬左派”领袖托尼·本恩计划在不久后挑战希利的副领导人之位，竞选工党副领袖，以此推动工党的进一步左倾。此外，工党内部存在过数个持打入主义的策略的托洛茨基主义团体，其中最成功的是泰德·格兰特领导的“战斗”派。七十年代以来，该团体的影响力不断扩大，他们在利物浦市议会拥有强大影响力，并且已经控制了工党的青年翼“工党青年社会主义者”。他们试图扩大工党的群众基础，并推动其革命化。对“战斗”派的处置方针也是党内左派与右派的争议焦点，党内右翼主张将该团体驱逐出党，而左翼则拒绝这种“麦卡锡主义”的猎巫政策。主席同志，或许这正是我们插手英国事务的绝佳时机？",
]

const TXT_OPT0 := [
	"接下来将发生什么？",
]

const TXT_OPT1 := [
	"支持丹尼斯·希利（需要5.0百万预算与10.0点特工网络）",
]

const TXT_OPT2 := [
	"支持托尼·本恩（需要5.0百万预算与10.0点特工网络）",
]

const TXT_OPT3 := [
	"支持工党内的“战斗”派发动政变（需要10.0百万预算与15.0点特工网络）",
	"该派系的影响力太低了......",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_R := [
	"在工党举行的特别代表大会上，近期得势的“战斗”派指控领导层优柔寡断，因此，作为该派系理论家之一的泰德·格兰特，指控党内右翼背叛了劳工运动，并开始将他们从党内系数清除。工党中一部分具有影响力的党员（例如罗伊·詹金斯、戴维·欧文、比尔·罗杰斯与雪莉·威廉构成的“工党四人帮”，以及罗伯特·麦克伦南）选择出走，并转而建立社会民主党。尽管采用了新名字，但该党开始实施事实上的中间派政策，并开始与自由党建立联系。因此，托洛茨基主义派成为了工党内的多数，并对党的全国委员会进行了改选。来自托派与党内左翼的代表纷纷填充了空缺，例如塔菲、格兰特、迪克森、沃尔什与道伊尔。该党本身由泰德·格兰特领导。",
	"希利设法获得了党内右派支持并让部分软左派在选举时保持中立，最终以不到百分之一的优势保住了自己的位置，右派得以阻止党的继续左倾。尽管迈克尔·富特并不希望对“战斗”派采取任何行动，但是党内右翼的压力下，工党最终开始打压“战斗”派，他们逐渐被边缘化了。",
	"本恩设法在工会和党员中获得了大部分的支持，最终赢得了副领导人的位置。在大会上，本恩指控党内右翼背叛了劳工运动，批评他们“是社会民主主义者，而不是社会主义者”，背叛了工党的建立初衷，并开始提拔“硬左派”和马克思主义者，这显著加强了他的影响力，他开始对工党进行改革，要求工党融入工会和工人阶级，并加强党内民主。在富特和本恩的努力下，右翼对“战斗”派的打压并未成功，他们依旧在工党内部活动。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1197 := "工党阵营的分裂"
const TXT_IDX_1192 := "接下来将发生什么？"
const TXT_IDX_1193 := "支持工党内的“战斗”派发动政变（需要10.0百万{0}与15.0点{1}）"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"
const TXT_IDX_1194 := "该派系的影响力太低了......"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_1196 := "在工党举行的特别代表大会上，近期得势的“战斗”派指控领导层优柔寡断，因此，作为该派系理论家之一的泰德·格兰特，指控党内右翼背叛了劳工运动，并开始将他们从党内系数清除。工党中一部分具有影响力的党员（例如罗伊·詹金斯、戴维·欧文、比尔·罗杰斯与雪莉·威廉构成的“工党四人帮”，以及罗伯特·麦克伦南）选择出走，并转而建立社会民主党。尽管采用了新名字，但该党开始实施事实上的中间派政策，并开始与自由党建立联系。因此，托洛茨基主义派成为了工党内的多数，并对党的全国委员会进行了改选。来自托派与党内左翼的代表纷纷填充了空缺，例如塔菲、格兰特、迪克森、沃尔什与道伊尔。该党本身由泰德·格兰特领导。"

## 原文字符串附录（供自检）
## 1979年之后，工党发现自己被玛格丽特·撒切尔领导的强硬保守党政府所压制，她基本上否定了自20世纪50年代以来就获得工党与保守党支持的战后经济和社会政策共识。输掉1979年选举后，工党开始更加左倾，党内左翼力量逐步壮大，其中最具代表性的是以托尼·本恩为首的“硬左派”和以迈克尔·富特为首的“软左派”。本恩等硬左派秉持强烈的社会主义与共和主义主张，且同情马克思主义——他曾在1976年尝试竞选工党领袖，但未能成功。富特等软左派则在一些议题上更具妥协性，以更好进行竞选和换取党内的团结。党内右翼对左翼的崛起深感不满，工党逐渐陷入派系倾轧的困境。这种内部矛盾导致1980年詹姆斯·卡拉汉辞职后，工党推选出了一位妥协性领导人（托尼·本恩未参与此次领导人选举）——迈克尔·富特，工党希望通过此举维系党内团结。然而，党内右派显然对他也极为不满，他们认为富特坚持英国实行单方面核裁军、退出欧洲经济共同体（EEC）的立场过于激进且带有极左色彩。事与愿违，党内团结终究未能实现。工党内部一部分有影响力的右翼党员选择出走，其中就包括罗伊·詹金斯、戴维·欧文、比尔·罗杰斯与雪莉·威廉姆斯组成的“工党四人帮”，以及罗伯特·麦克伦南，他们随后共同组建了社会民主党。尽管启用了新的党名，但该党实际上推行中间派政策，并且开始与自由党建立联系，这一举措或将吸引部分中间派选民的支持。与此同时，工党内的左派和右派围绕副领袖职位展开了争夺。右派成员团结在党的副领袖丹尼斯·希利周围，尝试抵制左派势力的进一步壮大；而“硬左派”领袖托尼·本恩计划在不久后挑战希利的副领导人之位，竞选工党副领袖，以此推动工党的进一步左倾。此外，工党内部存在过数个持打入主义的策略的托洛茨基主义团体，其中最成功的是泰德·格兰特领导的“战斗”派。七十年代以来，该团体的影响力不断扩大，他们在利物浦市议会拥有强大影响力，并且已经控制了工党的青年翼“工党青年社会主义者”。他们试图扩大工党的群众基础，并推动其革命化。对“战斗”派的处置方针也是党内左派与右派的争议焦点，党内右翼主张将该团体驱逐出党，而左翼则拒绝这种“麦卡锡主义”的猎巫政策。主席同志，或许这正是我们插手英国事务的绝佳时机？
## 支持丹尼斯·希利（需要5.0百万预算与10.0点特工网络）
## 支持托尼·本恩（需要5.0百万预算与10.0点特工网络）
## 英国1983大选结果预测
## 希利设法获得了党内右派支持并让部分软左派在选举时保持中立，最终以不到百分之一的优势保住了自己的位置，右派得以阻止党的继续左倾。尽管迈克尔·富特并不希望对“战斗”派采取任何行动，但是党内右翼的压力下，工党最终开始打压“战斗”派，他们逐渐被边缘化了。
## 本恩设法在工会和党员中获得了大部分的支持，最终赢得了副领导人的位置。在大会上，本恩指控党内右翼背叛了劳工运动，批评他们“是社会民主主义者，而不是社会主义者”，背叛了工党的建立初衷，并开始提拔“硬左派”和马克思主义者，这显著加强了他的影响力，他开始对工党进行改革，要求工党融入工会和工人阶级，并加强党内民主。在富特和本恩的努力下，右翼对“战斗”派的打压并未成功，他们依旧在工党内部活动。

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0[0])
	_enable(opt[1], TXT_OPT1[0])
	_enable(opt[2], TXT_OPT2[0])
	var uk := world.get_country_by_legacy_index(92)
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	if budget_reserve >= 100 and d.agents >= 150 and uk != null and uk.influence_nato >= 50:
		_enable(opt[3], TXT_OPT3[0])
	elif uk != null and uk.influence_nato < 50:
		_disable(opt[3], TXT_OPT3[1])
	elif budget_reserve < 100:
		_disable(opt[3], TXT_OPT3[2])
	else:
		_disable(opt[3], TXT_OPT3[3])

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	if opt == 1:
		num += 1
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -100)
	var c4 := ws.get_country_by_legacy_index(4)
	if c4 != null and c4.government == GameConstants.Government.REFORMIST:
		num += 1
	var c2 := ws.get_country_by_legacy_index(2)
	if c2 != null and c2.has_tag("亲苏"):
		num += 1
	var c86 := ws.get_country_by_legacy_index(86)
	if c86 != null and c86.government == GameConstants.Government.REFORMIST:
		num += 1
	var c85 := ws.get_country_by_legacy_index(85)
	if c85 != null and c85.government == GameConstants.Government.REFORMIST:
		num += 1
	if ws.wars.size() > 5 and ws.wars[5] != null and ws.wars[5].is_going:
		num += 1
	var c8 := ws.get_country_by_legacy_index(8)
	if c8 != null and c8.government == GameConstants.Government.LIBERAL:
		num += 1
	if c8 != null and c8.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
		num += 2
	if ws.empires.size() > 1 and ws.empires[0] != null and ws.empires[1] != null and ws.empires[0].power > ws.empires[1].power:
		num += 1
	var c30 := ws.get_country_by_legacy_index(30)
	if c30 != null and c30.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
		num += 1
	if opt == 2:
		num2 += 1
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -100)
	var c45 := ws.get_country_by_legacy_index(45)
	if c45 != null and c45.government == GameConstants.Government.REFORMIST:
		num2 += 1
	var c84 := ws.get_country_by_legacy_index(84)
	if c84 != null and c84.government == GameConstants.Government.REFORMIST:
		num2 += 1
	if c2 != null and c2.government == GameConstants.Government.REFORMIST:
		num2 += 1
	if c4 != null and c4.government == GameConstants.Government.SOCIALIST:
		num2 += 1
	var c166 := ws.get_country_by_legacy_index(166)
	if c166 != null and c166.parts.size() > 0 and c166.parts[0]:
		num2 += 2
	if c2 != null and c2.puppet_of == 7:
		num2 -= 1
	if c4 != null and c4.puppet_of == 7:
		num2 -= 1
	if ws.wars.size() > 5 and ws.wars[5] != null and ws.wars[5].is_going:
		num2 -= 1
	if ws.empires.size() > 1 and ws.empires[1] != null and ws.empires[0] != null and ws.empires[1].power >= ws.empires[0].power:
		num2 += 1
	if ws.empires.size() > 0 and ws.empires[0] != null and ws.empires[0].current_leader == 0:
		num2 -= 1
	if opt == 3:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		_add(W.I_PARTY_SUPPORT, -600)
		if uk != null:
			uk.influence_nato = 10
			uk.有驻军基地 = true
		for p in ws.politicians:
			if p == null:
				continue
			if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT or p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
				p.loyalty -= 300
			else:
				p.loyalty -= 100
		context["result_text"] = TXT_R[0]
		return
	if num > num2:
		context["result_text"] = TXT_R[1]
	elif num <= num2:
		if uk != null:
			uk.内战中 = true
		context["result_text"] = TXT_R[2]
