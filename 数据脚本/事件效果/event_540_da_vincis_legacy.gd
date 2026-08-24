extends "res://数据脚本/event_script_base.gd"

## 原作 Event540.cs：达芬奇的遗产（直升机研发，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:197-199 —— event_done[518]。
## 差异：old_modify_desc[50] → ModifierCatalog.get_def(50) 展示文案。

const TXT_OPT0_DIS := "event.script.event_540_da_vincis_legacy.c0"
const TXT_OPT1_DIS_TRADE := "event.script.event_540_da_vincis_legacy.c1"
const TXT_OPT1_DIS_MONEY := "event.script.event_540_da_vincis_legacy.c2"
const TXT_R0 := "event.script.event_540_da_vincis_legacy.c3"
const TXT_R1 := "event.script.event_540_da_vincis_legacy.c4"
const TXT_R2 := "event.script.event_540_da_vincis_legacy.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var money := d.budget + d.reserve
	var c21 := world.get_country_by_legacy_index(21)
	if money >= 80:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if c21 != null and c21.has_tag("对华贸易"):
		if money >= 30:
			_enable(opt[1], event_def.options[1].text)
		else:
			_disable(opt[1], tr(TXT_OPT1_DIS_MONEY))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_TRADE))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			_add(W.I_ARMY, 80)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			ws.influence_prc += 20
			_set_mod50("自研直升机：", "军力+0.4，干涉点数+0.2")
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_ARMY, 50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_DIPLO, -20)
			ws.influence_prc += 20
			_set_mod50("法式直升机：", "军力+0.2，干涉点数+0.1")
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)


func _set_mod50(title: String, effect: String) -> void:
	var def := ModifierCatalog.get_def(50)
	if def != null:
		def.name_zh = title
		def.effect_zh = effect



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_540_da_vincis_legacy.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_540",
	"num": 540,
	"priority": 54000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_540_da_vincis_legacy.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_518"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
