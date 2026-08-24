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

const TXT_IDX_1212 := "event.script.event_408_military_agenda.c0"
const TXT_IDX_1213 := "event.script.event_408_military_agenda.c1"
const TXT_IDX_1215 := "event.script.event_408_military_agenda.c2"
const TXT_IDX_592 := "event.script.event_408_military_agenda.c3"
const TXT_IDX_593 := "event.script.event_408_military_agenda.c4"
const TXT_IDX_594 := "event.script.event_408_military_agenda.c5"
const TXT_IDX_1214 := "event.script.event_408_military_agenda.c6"
const TXT_IDX_566 := "event.script.event_408_military_agenda.c7"
const TXT_IDX_1216 := "event.script.event_408_military_agenda.c8"
const TXT_IDX_1219 := "event.script.event_408_military_agenda.c9"
const TXT_IDX_1217 := "event.script.event_408_military_agenda.c10"
const TXT_IDX_586 := "event.script.event_408_military_agenda.c11"
const TXT_IDX_1218 := "event.script.event_408_military_agenda.c12"
const TXT_IDX_1220 := "event.script.event_408_military_agenda.c13"
const TXT_IDX_1221 := "event.script.event_408_military_agenda.c14"
const TXT_IDX_1207 := "event.script.event_408_military_agenda.c15"
const TXT_IDX_1222 := "event.script.event_408_military_agenda.c16"
const TXT_IDX_1223 := "event.script.event_408_military_agenda.c17"
const TXT_IDX_1224 := "event.script.event_408_military_agenda.c18"
const TXT_IDX_1225 := "event.script.event_408_military_agenda.c19"
const TXT_IDX_1226 := "event.script.event_408_military_agenda.c20"

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
		_enable(opt[0], _fmt(tr(TXT_IDX_1215), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214), str(num), str(num * 15 / 10.0)]))
	else:
		_disable(opt[0], _fmt(tr(TXT_IDX_566), [str(num / 10.0)]))
	if world.influence_prc >= num2:
		_enable(opt[1], _fmt(tr(TXT_IDX_1216), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214), str(num2 / 10.0), str(num * 15 / 10.0)]))
	else:
		_disable(opt[1], _fmt(tr(TXT_IDX_1219), [str(num2 / 10.0)]))
	if not world.get_flag("relres") and br >= num3:
		_enable(opt[2], _fmt(tr(TXT_IDX_1217), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214), str(num2 / 10.0), str(num3 / 10.0)]))
	elif world.get_flag("relres"):
		_disable(opt[2], tr(TXT_IDX_586))
	else:
		_disable(opt[2], _fmt(tr(TXT_IDX_566), [str(num3 / 10.0)]))
	var us := world.get_country_by_legacy_index(51)
	if _raw(64) < 1 and us != null and not us.has_tag("对华贸易") and br >= num3:
		_enable(opt[3], _fmt(tr(TXT_IDX_1218), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214), str(num2 / 10.0), str(num3 / 10.0)]))
	elif us != null and us.has_tag("对华贸易"):
		_disable(opt[3], tr(TXT_IDX_1220))
	elif _raw(64) > 0:
		_disable(opt[3], tr(TXT_IDX_1221))
	else:
		_disable(opt[3], _fmt(tr(TXT_IDX_566), [str(num3 / 10.0)]))
	_enable(opt[4], tr(TXT_IDX_1207))

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
		context["result_text"] = _fmt(tr(TXT_IDX_1222), [str(num), str(num * 15 / 10.0)])
	elif opt == 1:
		if china != null:
			china.influence_nato = 1
		_add(W.I_ARMY, num * 15)
		ws.influence_prc -= num2
		context["result_text"] = _fmt(tr(TXT_IDX_1223), [str(num * 15 / 10.0)])
	elif opt == 2:
		if china != null:
			china.influence_nato = 1
		_add(W.I_BUDGET, -num3)
		_add_relation(EmpireData.USSR, -250)
		_add_power(EmpireData.USSR, -num2)
		context["result_text"] = tr(TXT_IDX_1224)
	elif opt == 3:
		if china != null:
			china.influence_nato = 1
		_add(W.I_BUDGET, -num3)
		_add_relation(EmpireData.USA, -250)
		_add_power(EmpireData.USA, -num2)
		context["result_text"] = tr(TXT_IDX_1225)
	else:
		context["result_text"] = tr(TXT_IDX_1226)

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



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_408_military_agenda.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_408",
	"num": 408,
	"priority": 40800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_408_military_agenda.gd",
	"trigger": [{"t": "COUNTRY_FIELD_AT_LEAST", "key": "development", "v": 1, "target": "1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
