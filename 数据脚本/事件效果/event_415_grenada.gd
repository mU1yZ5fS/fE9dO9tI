extends "res://数据脚本/event_script_base.gd"

## 原作 Event415.cs：我的格林纳达？（三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1321 —— DATE_AFTER 1979.3.14。
## 差异：EstablishGovernment(ProNeuthral) 仅改倾向标签。

const TXT_TITLE := [
	"我的格林纳达？",
]

const TXT_DESC := [
	"近日，加勒比海上的小岛国格林纳达爆发了一场政变。奉行威权民粹主义的格林纳达联合工党被推翻。在莫里斯·毕晓普的领导下，来自新宝石运动的左翼分子夺取了该国政权。新政府立即开始同古巴和苏联进行合作。但仍选择仍留在英联邦内。",
]

const TXT_OPT0 := [
	"提供援助并与该国发展贸易（需要5.0百万预算）",
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
]

const TXT_OPT1 := [
	"谴责政变",
]

const TXT_OPT2 := [
	"格林纳达在哪？不关我事",
]

const TXT_R := [
	"莫里斯·毕晓普对我们的援助表示感谢。格林纳达与中国间也签署了一份贸易协定。苏联也赞许我们对社会主义事业做出的贡献。但显然，美国并不满意“共产主义麻风病”的扩散，毕竟加勒比地区是其传统势力范围。另一个问题是，新政府能够解决国内的社会与经济问题吗？答案尚不清楚。",
	"中华人民共和国外交部外交部选择谴责此次政变，认为其既“违宪”又“反民主”。美国对我们反对苏联在美国传统势力范围内扩张的举动感到满意，而苏联则对我们的举动表示遗憾。另一个问题是，新政府能够解决国内的社会与经济问题吗？答案尚不清楚。",
	"我们对格林纳达政变不予置评。但显然，美国并不满意“共产主义麻风病”的扩散，毕竟加勒比地区是其传统势力范围。另一个问题是，新政府能够解决国内的社会与经济问题吗？答案尚不清楚。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1291 := "event.script.event_415_grenada.c0"
const TXT_IDX_1292 := "event.script.event_415_grenada.c1"
const TXT_IDX_1293 := "event.script.event_415_grenada.c2"
const TXT_IDX_592 := "event.script.event_415_grenada.c3"
const TXT_IDX_593 := "event.script.event_415_grenada.c4"
const TXT_IDX_594 := "event.script.event_415_grenada.c5"
const TXT_IDX_566 := "event.script.event_415_grenada.c6"
const TXT_IDX_1294 := "event.script.event_415_grenada.c7"
const TXT_IDX_1295 := "event.script.event_415_grenada.c8"
const TXT_IDX_1296 := "event.script.event_415_grenada.c9"
const TXT_IDX_1297 := "event.script.event_415_grenada.c10"
const TXT_IDX_1298 := "event.script.event_415_grenada.c11"

## 原文字符串附录（供自检）

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var opt := event_def.options
	if d.budget + (d.reserve if d.size() > W.I_RESERVE else 0) >= 50:
		_enable(opt[0], TXT_OPT0[0])
	else:
		_disable(opt[0], _fmt(TXT_OPT0[1], [5]))
	_enable(opt[1], TXT_OPT1[0])
	_enable(opt[2], TXT_OPT2[0])

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var grenada := ws.get_country_by_legacy_index(48)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_BUDGET, -50)
		if grenada != null:
			grenada.government = GameConstants.Government.SOCIALIST
			grenada.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			_set_pro_neutral(grenada)
			grenada.set_tag("对华贸易", true)
		_add_power(EmpireData.USSR, 20)
		_add_relation(EmpireData.USSR, 150)
		_add_relation(EmpireData.USA, -100)
		context["result_text"] = TXT_R[0]
	elif opt == 1:
		if grenada != null:
			grenada.government = GameConstants.Government.SOCIALIST
			grenada.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			_set_pro_neutral(grenada)
			grenada.set_tag("对华贸易", false)
		_add_power(EmpireData.USSR, 20)
		_add_relation(EmpireData.USSR, -150)
		_add_relation(EmpireData.USA, 100)
		context["result_text"] = TXT_R[1]
	else:
		if grenada != null:
			grenada.government = GameConstants.Government.SOCIALIST
			grenada.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			_set_pro_neutral(grenada)
		_add_power(EmpireData.USSR, 20)
		context["result_text"] = TXT_R[2]

func _set_pro_neutral(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", false)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_415_grenada.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_415",
	"num": 415,
	"priority": 41500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_415_grenada.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.3.14"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
