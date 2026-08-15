extends "res://数据脚本/event_script_base.gd"

## 原作 Event409.cs：特勤议题（五选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1291 —— allcountries[1].dev==2。
## 差异：dev→development；soc_stab→social_stability；EstablishGovernment(ProChina) 仅改倾向标签。

const TXT_TITLE := [
	"特勤议题",
]

const TXT_DESC := [
	"主席同志！我们的情报部门建议您，应当考虑实行一些增强我国联盟实力的措施。首先，我们可以通过改组各国的情报部门，从而将各成员国的情报组织都置于我方的直接控制下。其次，我们可以通过利用我国的情报部门。击溃那些未在我方势力范围内国家的反对派，并让他们完全回归我们的怀抱。以及，我们的特工可以从超级大国处窃取技术蓝图，从而增强我们的科学研发能力。今年，我们该怎么做呢？",
]

const TXT_OPT0 := [
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
]

const TXT_OPT1 := [
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT2 := [
	"可不能在前脚与苏联和好后，后脚就捅刀子......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT3 := [
	"我们已经与美国建交......",
	"巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......",
]

const TXT_OPT4 := [
	"不闻不问",
]

const TXT_R := [
	"我们已经对联盟内各国的情报组织进行了改组。因此，我们得以增强对其他各国情报网的控。我们的特勤实力得以增长{2}点。",
	"我国情报机构击溃了下述国家的反对派：{1}。现在，他们再度成为了中国的忠实盟友。",
	"我们的特工成功潜入苏联的密闭城市，并成功从那带走了一些独特的技术蓝图。这让我们的科研点数增加了300点。",
	"我们的特工成功潜入硅谷，并成功从那带走了一些独特的技术蓝图。这让我们的科研点数增加了300点。",
	"我们将稍后再议。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1227 := "特勤议题"
const TXT_IDX_1228 := "主席同志！我们的情报部门建议您，应当考虑实行一些增强我国联盟实力的措施。首先，我们可以通过改组各国的情报部门，从而将各成员国的情报组织都置于我方的直接控制下。其次，我们可以通过利用我国的情报部门。击溃那些未在我方势力范围内国家的反对派，并让他们完全回归我们的怀抱。以及，我们的特工可以从超级大国处窃取技术蓝图，从而增强我们的科学研发能力。今年，我们该怎么做呢？"
const TXT_IDX_1229 := "改组情报网络（以{4:F1}点{0}交换{5:F1}点{1}）"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"
const TXT_IDX_1214 := "中国国际影响力"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_1230 := "组织清剿反对派的行动（需要{4:F1}点{1}）"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_1231 := "组织针对苏联的间谍行动（以{4:F1}点{1}交换苏联影响力下降1.0与300点科研点数）"
const TXT_IDX_586 := "可不能在前脚与苏联和好后，后脚就捅刀子......"
const TXT_IDX_1232 := "组织针对美国的间谍行动（以{4:F1}点{1}交换美国影响力下降1.0与300点科研点数）"
const TXT_IDX_1220 := "我们已经与美国建交......"
const TXT_IDX_1207 := "不闻不问"
const TXT_IDX_1212 := "军事议题"
const TXT_IDX_1233 := "我们已经对联盟内各国的情报组织进行了改组。因此，我们得以增强对其他各国情报网的控。我们的特勤实力得以增长{2}点。"
const TXT_IDX_1234 := "我国情报机构击溃了下述国家的反对派：{1}。现在，他们再度成为了中国的忠实盟友。"
const TXT_IDX_1235 := "我们的特工成功潜入苏联的密闭城市，并成功从那带走了一些独特的技术蓝图。这让我们的科研点数增加了300点。"
const TXT_IDX_1236 := "我们的特工成功潜入硅谷，并成功从那带走了一些独特的技术蓝图。这让我们的科研点数增加了300点。"
const TXT_IDX_1226 := "我们将稍后再议。"

## 原文字符串附录（供自检）
## ,

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var d := world.数值表
	var opt := event_def.options
	var num := _okb_count()
	var num2 := 30
	var num3 := 120
	if num < 7:
		num2 = 30
		num3 = 120
	elif num < 14:
		num2 = 50
		num3 = 70
	else:
		num2 = 70
		num3 = 50
	var br := d[W.I_BUDGET] + (d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0)
	if br >= num:
		_enable(opt[0], _fmt(TXT_IDX_1229, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214, str(num), str(num * 15 / 10.0)]))
	else:
		_disable(opt[0], _fmt(TXT_IDX_566, [str(num / 10.0)]))
	if d[W.I_AGENTS] >= num2:
		_enable(opt[1], _fmt(TXT_IDX_1230, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214, str(num2 / 10.0), str(num * 15 / 10.0)]))
	else:
		_disable(opt[1], _fmt(TXT_IDX_567, [str(num2 / 10.0)]))
	if not world.get_flag("relres") and d[W.I_AGENTS] >= num3:
		_enable(opt[2], _fmt(TXT_IDX_1231, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214, str(num2 / 10.0), str(num3 / 10.0)]))
	elif world.get_flag("relres"):
		_disable(opt[2], TXT_IDX_586)
	else:
		_disable(opt[2], _fmt(TXT_IDX_567, [str(num3 / 10.0)]))
	var us := world.get_country_by_legacy_index(51)
	if us != null and not us.has_tag("对华贸易") and d[W.I_AGENTS] >= num3:
		_enable(opt[3], _fmt(TXT_IDX_1232, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214, str(num2 / 10.0), str(num3 / 10.0)]))
	elif us != null and us.has_tag("对华贸易"):
		_disable(opt[3], TXT_IDX_1220)
	else:
		_disable(opt[3], _fmt(TXT_IDX_567, [str(num3 / 10.0)]))
	_enable(opt[4], TXT_IDX_1207)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var china := ws.get_country_by_legacy_index(1)
	var num := _okb_count()
	var num2 := 30
	var num3 := 120
	if num < 7:
		num2 = 30
		num3 = 120
	elif num < 14:
		num2 = 50
		num3 = 70
	else:
		num2 = 70
		num3 = 50
	if china != null:
		china.development = 0
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_BUDGET, -num * 10)
		_add(W.I_AGENTS, num * 15)
		if china != null:
			china.influence_china = 1
		context["result_text"] = _fmt(TXT_IDX_1233, [str(num), str(num * 15 / 10.0)])
	elif opt == 1:
		var text2 := ""
		for c in ws.countries:
			if c != null and c.has_tag("okb") and c.social_stability < 800:
				c.social_stability = 1000
				text2 += c.name + ","
				_set_pro_china(c)
		if china != null:
			china.influence_china = 1
		_add(W.I_AGENTS, -num2)
		context["result_text"] = _fmt(TXT_IDX_1234, [text2])
	elif opt == 2:
		if china != null:
			china.influence_china = 1
		_add(W.I_AGENTS, -num3)
		_add_relation(EmpireData.USSR, -100)
		_add(W.I_SCIENCE, 300)
		_add_power(EmpireData.USSR, -10)
		context["result_text"] = TXT_IDX_1235
	elif opt == 3:
		if china != null:
			china.influence_china = 1
		_add(W.I_AGENTS, -num3)
		_add_relation(EmpireData.USA, -100)
		_add(W.I_SCIENCE, 300)
		_add_power(EmpireData.USA, -10)
		context["result_text"] = TXT_IDX_1236
	else:
		context["result_text"] = TXT_IDX_1226

func _raw(i: int) -> int:
	if d.size() > i:
		return d[i]
	return 0

func _okb_count() -> int:
	var n := 0
	for c in ws.countries:
		if c != null and c.has_tag("okb"):
			n += 1
	return n

func _set_pro_china(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)
