extends "res://数据脚本/event_script_base.gd"

## 原作 Event549.cs：铲除杂草（蒙古泽登巴尔，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:47-49 —— 复杂条件见 evaluate()。
## 差异：ingamewars[22]→ws.wars[22]；IndOpp/is_gkchp→global_flags；
##   data.soviet_reorganization_war_state/data.mongolia_china_route raw index 直接读 数值表。

const TXT_OPT0_DIS := "event.script.event_549_weeding_out.c0"
const TXT_R0 := "event.script.event_549_weeding_out.c1"
const TXT_R1 := "event.script.event_549_weeding_out.c2"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world
	if dd.size() <= W.I_DAY:
		return false
	if world.wars.size() > 22 and world.wars[22] != null and world.wars[22].is_going:
		return false
	if dd.soviet_reorganization_war_state == 1 or dd.mongolia_china_route == 1 or dd.soviet_reorganization_war_state == 3:
		return false
	if world.get_flag("IndOpp") or world.get_flag("is_gkchp"):
		return false
	var c7 := world.get_country_by_legacy_index(7)
	var c9 := world.get_country_by_legacy_index(9)
	if c7 == null or c9 == null:
		return false
	if c7.has_tag("nato") or c9.has_tag("ovd"):
		return false
	var y := dd.year
	var mo := dd.month
	var day := dd.day
	if (y >= 1983 and mo >= 7 and day >= 1) or (y >= 1983 and mo >= 8) or y >= 1984:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var c9 := world.get_country_by_legacy_index(9)
	var r62 := int(ws.completed_event_ids.get("event_62", 0))
	if c9 != null and c9.内战中 and ws.influence_prc >= 300 and r62 != 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_549_weeding_out.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_549",
	"num": 549,
	"priority": 54900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_549_weeding_out.gd",
	"trigger_script": "res://数据脚本/事件效果/event_549_weeding_out.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
