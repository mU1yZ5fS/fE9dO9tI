extends "res://数据脚本/event_script_base.gd"

## 原作 Event646.cs：济世悬壶，着手成春（医疗体制路线，三选项）。
## 触发：ReqEventsDLC02.cs:99-101 —— data.year>=1979，即 DATE_AFTER 1979.1.1。
## 差异：原版结果页后续重写 old_modify_desc[2]（服务业修正说明）；Godot ModifierCatalog
##   静态维护 modifier_catalog.gd，沿用 event_668 既有约定不在此处改写。

const TXT_OPT0_DIS := "event.script.event_646_healthcare_reform.c0"
const TXT_OPT1_DIS := "event.script.event_646_healthcare_reform.c1"
const TXT_OPT2_DIS := "event.script.event_646_healthcare_reform.c2"
const TXT_R0 := "event.script.event_646_healthcare_reform.c3"
const TXT_R1 := "event.script.event_646_healthcare_reform.c4"
const TXT_R2 := "event.script.event_646_healthcare_reform.c5"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 3:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line <= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line == 4:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, 200)
			_add(W.I_THOUGHT_FREEDOM, -150)
			_add(W.I_LIVING, 50)
			_add(W.I_BUDGET, -50)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 50)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, -50)
			_add(W.I_THOUGHT_FREEDOM, 50)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_646_healthcare_reform.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_646",
	"num": 646,
	"priority": 64600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_646_healthcare_reform.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.1.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
