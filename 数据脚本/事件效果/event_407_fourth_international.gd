extends "res://数据脚本/event_script_base.gd"

## 原作 Event407.cs：第四国际？（二选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1281 —— ExprNode 组合。
## 差异：ChineseSubGosstroy() 用中国 sub_government 原样；politic.loyality→loyalty。

const TXT_TITLE := [
	"第四国际？",
]

const TXT_DESC := [
	"今天，英国首相泰德·格兰特与“国际社会主义者趋势”领导人托尼·克里夫宣布将复兴第四国际（世界社会主义革命党），后者是成立于1938年的托洛茨基主义组织，并于20世纪60年代初解散为多个支部。而“国际社会主义者趋势”则自认为是它的合法继承者。他们将此举定义为“统合一切进步力量，从而实现实现世界范围的革命转型”的关键行动。当然，对于这样一支新兴势力，我们可以向他们提供来自中方的支持，甚至以此修改我们的指导思想，让马克思主义跟上现代社会的发展步伐。十月革命的精神与动力已经枯竭，我们必须尝试走入一场新的革命中！这次，革命将成为世界的革命！",
]

const TXT_OPT0 := [
	"与托洛茨基主义者建立联盟，并更改我党指导思想（需要30.0百万预算与30.0点特工网络）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT1 := [
	"不闻不问",
]

const TXT_R := [
	"“现在，我们能够很清楚的看到。托洛茨基与其追随者在理论上所做的补充，被马克思主义者完全低估了。而这简直是大错特错，现在，英国已经成为了革命热忱的中心。尽管工党的支持者试图在没有发生世界革命的情况下推动国内的革命转型。但显然，西方资产阶级民主的末日已经到来，而这最终取决于我们的行动！我们必须团结起来，为了世界革命，打倒帝国主义毒蛇”。这便是中国领导人对此事的声明。中国共产党召开的紧急代表大会则批准了指导思想的转变——中国的所有托洛茨基主义者（如王凡西、刘仁静、彭述之）均被平反，新的党纲则将“全党必须高举马克思主义、列宁主义、托洛茨基主义伟大红旗”写入其中。很难想象接下来将发生什么？......",
	"我想知道，他们单打独斗能否成事？",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1204 := "第四国际？"
const TXT_IDX_1205 := "今天，英国首相泰德·格兰特与“国际社会主义者趋势”领导人托尼·克里夫宣布将复兴第四国际（世界社会主义革命党），后者是成立于1938年的托洛茨基主义组织，并于20世纪60年代初解散为多个支部。而“国际社会主义者趋势”则自认为是它的合法继承者。他们将此举定义为“统合一切进步力量，从而实现实现世界范围的革命转型”的关键行动。当然，对于这样一支新兴势力，我们可以向他们提供来自中方的支持，甚至以此修改我们的指导思想，让马克思主义跟上现代社会的发展步伐。十月革命的精神与动力已经枯竭，我们必须尝试走入一场新的革命中！这次，革命将成为世界的革命！"
const TXT_IDX_1206 := "与托洛茨基主义者建立联盟，并更改我党指导思想（需要30.0百万{0}与30.0点{1}）"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_1207 := "不闻不问"
const TXT_IDX_1208 := "“现在，我们能够很清楚的看到。托洛茨基与其追随者在理论上所做的补充，被马克思主义者完全低估了。而这简直是大错特错，现在，英国已经成为了革命热忱的中心。尽管工党的支持者试图在没有发生世界革命的情况下推动国内的革命转型。但显然，西方资产阶级民主的末日已经到来，而这最终取决于我们的行动！我们必须团结起来，为了世界革命，打倒帝国主义毒蛇”。这便是中国领导人对此事的声明。中国共产党召开的紧急代表大会则批准了指导思想的转变——中国的所有托洛茨基主义者（如王凡西、刘仁静、彭述之）均被平反，新的党纲则将“全党必须高举马克思主义、列宁主义、托洛茨基主义伟大红旗”写入其中。很难想象接下来将发生什么？......"
const TXT_IDX_1209 := "我想知道，他们单打独斗能否成事？"

## 原文字符串附录（供自检）

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var d := world.数值表
	var opt := event_def.options
	if d[W.I_BUDGET] + (d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0) >= 300 and d[W.I_AGENTS] >= 300:
		_enable(opt[0], TXT_OPT0[0])
	elif d[W.I_BUDGET] + (d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0) < 300:
		_disable(opt[0], TXT_OPT0[1])
	else:
		_disable(opt[0], TXT_OPT0[2])
	_enable(opt[1], TXT_OPT1[0])

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		if uk != null:
			uk.set_tag("亲中", true)
			uk.set_tag("okb", true)
			uk.set_tag("econ", true)
			uk.set_tag("对华贸易", true)
		_add(W.I_BUDGET, -300)
		_add(W.I_AGENTS, -300)
		ws.influence_prc += 50
		_add_relation(EmpireData.USA, -250)
		_add_relation(EmpireData.USSR, -250)
		_add(W.I_PARTY_SUPPORT, -600)
		if 49 < ws.modifiers.size() and ws.modifiers[49] != null:
			ws.modifiers[49].is_active = true
		var us := ws.get_country_by_legacy_index(51)
		if us != null:
			us.set_tag("对华贸易", false)
		if china != null:
			china.sub_government = china.sub_government
		for c in ws.countries:
			if c != null and c.has_tag("okb") and c.sub_government != 18:
				c.set_tag("对华贸易", false)
				c.set_tag("econ", false)
				c.set_tag("okb", false)
				c.set_tag("亲中", false)
		for p in ws.politicians:
			if p != null:
				p.loyalty -= 500
		context["result_text"] = TXT_R[0]
	else:
		context["result_text"] = TXT_R[1]
