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

const TXT_IDX_1227 := "event.script.event_409_intelligence_agenda.c0"
const TXT_IDX_1228 := "event.script.event_409_intelligence_agenda.c1"
const TXT_IDX_1229 := "event.script.event_409_intelligence_agenda.c2"
const TXT_IDX_592 := "event.script.event_409_intelligence_agenda.c3"
const TXT_IDX_593 := "event.script.event_409_intelligence_agenda.c4"
const TXT_IDX_594 := "event.script.event_409_intelligence_agenda.c5"
const TXT_IDX_1214 := "event.script.event_409_intelligence_agenda.c6"
const TXT_IDX_566 := "event.script.event_409_intelligence_agenda.c7"
const TXT_IDX_1230 := "event.script.event_409_intelligence_agenda.c8"
const TXT_IDX_567 := "event.script.event_409_intelligence_agenda.c9"
const TXT_IDX_1231 := "event.script.event_409_intelligence_agenda.c10"
const TXT_IDX_586 := "event.script.event_409_intelligence_agenda.c11"
const TXT_IDX_1232 := "event.script.event_409_intelligence_agenda.c12"
const TXT_IDX_1220 := "event.script.event_409_intelligence_agenda.c13"
const TXT_IDX_1207 := "event.script.event_409_intelligence_agenda.c14"
const TXT_IDX_1212 := "event.script.event_409_intelligence_agenda.c15"
const TXT_IDX_1233 := "event.script.event_409_intelligence_agenda.c16"
const TXT_IDX_1234 := "event.script.event_409_intelligence_agenda.c17"
const TXT_IDX_1235 := "event.script.event_409_intelligence_agenda.c18"
const TXT_IDX_1236 := "event.script.event_409_intelligence_agenda.c19"
const TXT_IDX_1226 := "event.script.event_409_intelligence_agenda.c20"

## 原文字符串附录（供自检）
## ,

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
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
	var br := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	if br >= num:
		_enable(opt[0], _fmt(tr(TXT_IDX_1229), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214), str(num), str(num * 15 / 10.0)]))
	else:
		_disable(opt[0], _fmt(tr(TXT_IDX_566), [str(num / 10.0)]))
	if d.agents >= num2:
		_enable(opt[1], _fmt(tr(TXT_IDX_1230), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214), str(num2 / 10.0), str(num * 15 / 10.0)]))
	else:
		_disable(opt[1], _fmt(tr(TXT_IDX_567), [str(num2 / 10.0)]))
	if not world.get_flag("relres") and d.agents >= num3:
		_enable(opt[2], _fmt(tr(TXT_IDX_1231), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214), str(num2 / 10.0), str(num3 / 10.0)]))
	elif world.get_flag("relres"):
		_disable(opt[2], tr(TXT_IDX_586))
	else:
		_disable(opt[2], _fmt(tr(TXT_IDX_567), [str(num3 / 10.0)]))
	var us := world.get_country_by_legacy_index(51)
	if us != null and not us.has_tag("对华贸易") and d.agents >= num3:
		_enable(opt[3], _fmt(tr(TXT_IDX_1232), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594), tr(TXT_IDX_1214), str(num2 / 10.0), str(num3 / 10.0)]))
	elif us != null and us.has_tag("对华贸易"):
		_disable(opt[3], tr(TXT_IDX_1220))
	else:
		_disable(opt[3], _fmt(tr(TXT_IDX_567), [str(num3 / 10.0)]))
	_enable(opt[4], tr(TXT_IDX_1207))

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
		context["result_text"] = _fmt(tr(TXT_IDX_1233), [str(num), str(num * 15 / 10.0)])
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
		context["result_text"] = _fmt(tr(TXT_IDX_1234), [text2])
	elif opt == 2:
		if china != null:
			china.influence_china = 1
		_add(W.I_AGENTS, -num3)
		_add_relation(EmpireData.USSR, -100)
		_add(W.I_SCIENCE, 300)
		_add_power(EmpireData.USSR, -10)
		context["result_text"] = tr(TXT_IDX_1235)
	elif opt == 3:
		if china != null:
			china.influence_china = 1
		_add(W.I_AGENTS, -num3)
		_add_relation(EmpireData.USA, -100)
		_add(W.I_SCIENCE, 300)
		_add_power(EmpireData.USA, -10)
		context["result_text"] = tr(TXT_IDX_1236)
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

func _set_pro_china(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_409_intelligence_agenda.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_409",
	"num": 409,
	"priority": 40900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_409_intelligence_agenda.gd",
	"trigger": [{"t": "COUNTRY_FIELD_AT_LEAST", "key": "development", "v": 2, "target": "1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
