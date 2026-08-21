extends "res://数据脚本/event_script_base.gd"

## 原作 Event408.cs：军事议题（五选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1286 —— allcountries[1].dev==1。
## 差异：dev→development；选项显隐 prepare 按 okb 数量动态生成。

const TXT_TITLE := [
	"军事议题",
]

const TXT_DESC := [
	"主席同志！军事委员会邀请您来，是要考虑实行一些增强我方联盟实力，并有效遏制其他超级大国的措施。首先，我们可以通过开展联合军事演习，从而增强本国军队的实力，并向全世界展示中方的实力与其立场的不容置疑。其次，我们可以通过改组各国的部队，从而将各成员国的军队都置于我方的直接控制下。以及，我们可以对超级大国施加军事压力，从而让他们明白，办事时必须考虑我们的意见。今年，我们该怎么做呢？",
]

const TXT_OPT0 := [
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
]

const TXT_OPT1 := [
	"中国的国际影响力应高于{0}......",
]

const TXT_OPT2 := [
	"可不能在前脚与苏联和好后，后脚就捅刀子......",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
]

const TXT_OPT3 := [
	"我们已经与美国建交......",
	"台湾问题已被解决......",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
]

const TXT_OPT4 := [
	"不闻不问",
]

const TXT_R := [
	"我们已经与联盟内的{1}国组织了联合军事演习。通过增强军事训练，协调各国从参谋部的行动，以及改进武器。我们的军事实力得以增长{2:F1}点。",
	"我们已经对联盟内各国的所有部队进行了改组。因此，我们得以增强对其他各国的国防军的控制力。我们的军事实力得以增长{1:F1}点。",
	"我们组织了联合军事演习，并在中苏边界附近增兵。这让我们在莫斯科的“同志”不得不为此打起警惕。苏联对国际局势的影响力因此被削弱。",
	"我们组织了联合军事演习，并在东海与南海附近增兵。这让美国人不得不为此打起警惕。美国对国际局势的影响力因此被削弱。",
	"我们将稍后再议。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1212 := "军事议题"
const TXT_IDX_1213 := "主席同志！军事委员会邀请您来，是要考虑实行一些增强我方联盟实力，并有效遏制其他超级大国的措施。首先，我们可以通过开展联合军事演习，从而增强本国军队的实力，并向全世界展示中方的实力与其立场的不容置疑。其次，我们可以通过改组各国的部队，从而将各成员国的军队都置于我方的直接控制下。以及，我们可以对超级大国施加军事压力，从而让他们明白，办事时必须考虑我们的意见。今年，我们该怎么做呢？"
const TXT_IDX_1215 := "组织联合军事演习（以{4:F1}点{0}交换{5:F1}点{2}）"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"
const TXT_IDX_1214 := "中国国际影响力"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_1216 := "改组军队（以{4:F1}点{3}交换{5:F1}点{2}）"
const TXT_IDX_1219 := "中国的国际影响力应高于{0}......"
const TXT_IDX_1217 := "对苏联施压（以{5:F1}点{0}交换苏联影响力下降{4:F1}点）"
const TXT_IDX_586 := "可不能在前脚与苏联和好后，后脚就捅刀子......"
const TXT_IDX_1218 := "对美国施压（以{5:F1}点{0}交换美国影响力下降{4:F1}点）"
const TXT_IDX_1220 := "我们已经与美国建交......"
const TXT_IDX_1221 := "台湾问题已被解决......"
const TXT_IDX_1207 := "不闻不问"
const TXT_IDX_1222 := "我们已经与联盟内的{1}国组织了联合军事演习。通过增强军事训练，协调各国从参谋部的行动，以及改进武器。我们的军事实力得以增长{2:F1}点。"
const TXT_IDX_1223 := "我们已经对联盟内各国的所有部队进行了改组。因此，我们得以增强对其他各国的国防军的控制力。我们的军事实力得以增长{1:F1}点。"
const TXT_IDX_1224 := "我们组织了联合军事演习，并在中苏边界附近增兵。这让我们在莫斯科的“同志”不得不为此打起警惕。苏联对国际局势的影响力因此被削弱。"
const TXT_IDX_1225 := "我们组织了联合军事演习，并在东海与南海附近增兵。这让美国人不得不为此打起警惕。美国对国际局势的影响力因此被削弱。"
const TXT_IDX_1226 := "我们将稍后再议。"

## 原文字符串附录（供自检）

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var opt := event_def.options
	var num := _okb_count()
	var num2 := 30
	var num3 := 100
	if num < 7:
		num2 = 30
		num3 = 100
	elif num < 14:
		num2 = 50
		num3 = 200
	else:
		num2 = 70
		num3 = 300
	var br := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	if br >= num:
		_enable(opt[0], _fmt(TXT_IDX_1215, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214, str(num), str(num * 15 / 10.0)]))
	else:
		_disable(opt[0], _fmt(TXT_IDX_566, [str(num / 10.0)]))
	if world.influence_prc >= num2:
		_enable(opt[1], _fmt(TXT_IDX_1216, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214, str(num2 / 10.0), str(num * 15 / 10.0)]))
	else:
		_disable(opt[1], _fmt(TXT_IDX_1219, [str(num2 / 10.0)]))
	if not world.get_flag("relres") and br >= num3:
		_enable(opt[2], _fmt(TXT_IDX_1217, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214, str(num2 / 10.0), str(num3 / 10.0)]))
	elif world.get_flag("relres"):
		_disable(opt[2], TXT_IDX_586)
	else:
		_disable(opt[2], _fmt(TXT_IDX_566, [str(num3 / 10.0)]))
	var us := world.get_country_by_legacy_index(51)
	if _raw(64) < 1 and us != null and not us.has_tag("对华贸易") and br >= num3:
		_enable(opt[3], _fmt(TXT_IDX_1218, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214, str(num2 / 10.0), str(num3 / 10.0)]))
	elif us != null and us.has_tag("对华贸易"):
		_disable(opt[3], TXT_IDX_1220)
	elif _raw(64) > 0:
		_disable(opt[3], TXT_IDX_1221)
	else:
		_disable(opt[3], _fmt(TXT_IDX_566, [str(num3 / 10.0)]))
	_enable(opt[4], TXT_IDX_1207)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var china := ws.get_country_by_legacy_index(1)
	var num := _okb_count()
	var num2 := 30
	var num3 := 100
	if num < 7:
		num2 = 30
		num3 = 100
	elif num < 14:
		num2 = 50
		num3 = 200
	else:
		num2 = 70
		num3 = 300
	if china != null:
		china.development = 0
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_BUDGET, -num * 10)
		_add(W.I_ARMY, num * 15)
		if china != null:
			china.influence_nato = 1
		context["result_text"] = _fmt(TXT_IDX_1222, [str(num), str(num * 15 / 10.0)])
	elif opt == 1:
		if china != null:
			china.influence_nato = 1
		_add(W.I_ARMY, num * 15)
		ws.influence_prc -= num2
		context["result_text"] = _fmt(TXT_IDX_1223, [str(num * 15 / 10.0)])
	elif opt == 2:
		if china != null:
			china.influence_nato = 1
		_add(W.I_BUDGET, -num3)
		_add_relation(EmpireData.USSR, -250)
		_add_power(EmpireData.USSR, -num2)
		context["result_text"] = TXT_IDX_1224
	elif opt == 3:
		if china != null:
			china.influence_nato = 1
		_add(W.I_BUDGET, -num3)
		_add_relation(EmpireData.USA, -250)
		_add_power(EmpireData.USA, -num2)
		context["result_text"] = TXT_IDX_1225
	else:
		context["result_text"] = TXT_IDX_1226

func _raw(i: int) -> int:
	if d.size() > i:
		return d.get_data_by_index(i)
	return 0

func _okb_count() -> int:
	var n := 0
	for c in ws.countries:
		if c != null and c.has_tag("okb"):
			n += 1
	return n
