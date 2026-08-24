extends "res://数据脚本/event_script_base.gd"

## 原作 Event553.cs：新意属东非？（意大利-索马里，2选项）。 ## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1549-1551 —— ##   event_done[434] && IsAuthoritarianism(42) && c42.SubGosstroy==7 && c42.Vyshi ##   && (resultOfEvents[481]==1 resultOfEvents[481]==2)。 ## 差异：描述/选项按 c85.SubGosstroy==22 动态改写。

const TXT_DESC_22 := "event.script.event_553_new_italian_east_africa.c0"
const TXT_DESC_OTHER := "event.script.event_553_new_italian_east_africa.c1"
const TXT_OPT0_22 := "event.script.event_553_new_italian_east_africa.c2"
const TXT_OPT1_22 := "event.script.event_553_new_italian_east_africa.c3"
const TXT_OPT0 := "event.script.event_553_new_italian_east_africa.c4"
const TXT_OPT1 := "event.script.event_553_new_italian_east_africa.c5"
const TXT_R0_22 := "event.script.new_italian_east_africa.txt_r0_22"
const TXT_R1_22 := "event.script.event_553_new_italian_east_africa.c6"
const TXT_R0 := "event.script.event_553_new_italian_east_africa.c7"
const TXT_R1 := "event.script.event_553_new_italian_east_africa.c8"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var c85 := world.get_country_by_legacy_index(85)
	var is_22 := c85 != null and c85.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
	event_def.description = tr(TXT_DESC_22) if is_22 else tr(TXT_DESC_OTHER)
	if event_def.options.size() < 2:
		return
	var opt := event_def.options
	if is_22:
		_enable(opt[0], tr(TXT_OPT0_22))
		_enable(opt[1], tr(TXT_OPT1_22))
	else:
		_enable(opt[0], tr(TXT_OPT0))
		_enable(opt[1], tr(TXT_OPT1))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c42 := ws.get_country_by_legacy_index(42)
	var c85 := ws.get_country_by_legacy_index(85)
	var is_22 := c85 != null and c85.sub_government == GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST
	if c42 != null:
		c42.puppet_of = GameConstants.LegacySlot.SPAIN
		c42.sub_government = GameConstants.SubGovernment.REVOLUTIONARY_NATIONALIST if is_22 else 9
		c42.set_tag("亲美", false)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USSR, 25)
			_add_relation(EmpireData.USA, 25)
			context["result_text"] = tr(TXT_R0_22) if is_22 else tr(TXT_R0)
		1:
			_add(W.I_BUDGET, 5)
			_add_relation(EmpireData.USSR, -25)
			_add_relation(EmpireData.USA, -25)
			if c42 != null:
				c42.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R1_22) if is_22 else tr(TXT_R1)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_553_new_italian_east_africa.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_553",
	"num": 553,
	"priority": 55300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_553_new_italian_east_africa.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_434"}, {"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "42"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "target": "42"}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 7, "target": "42"}, {"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "42"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "event_481"}, {"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_481"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
