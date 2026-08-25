extends "res://数据脚本/event_script_base.gd"

## 原作 Event373.cs：祖先，祖父。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "event.script.event_373_cyprus_second_invasion.c0"
const TXT_OPT1 := "event.script.event_373_cyprus_second_invasion.c1"
const TXT_OPT2 := "event.script.event_373_cyprus_second_invasion.c2"
const TXT_WAR14_NAME := "event.script.event_373_cyprus_second_invasion.c3"
const TXT_WAR14_SIDE1 := "event.script.event_373_cyprus_second_invasion.c4"
const TXT_WAR14_SIDE2 := "event.script.event_373_cyprus_second_invasion.c5"

const TXT_R0 := "event.script.event_373_cyprus_second_invasion.c6"
const TXT_R1 := "event.script.event_373_cyprus_second_invasion.c7"
const TXT_R2 := "event.script.event_373_cyprus_second_invasion.c8"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], tr(TXT_OPT0))
	_enable(opt[1], tr(TXT_OPT1))
	_enable(opt[2], tr(TXT_OPT2))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_start_war(14, tr(TXT_WAR14_SIDE1), tr(TXT_WAR14_SIDE2), 700, 300, 1, 1, tr(TXT_WAR14_NAME), 10)
			_add(W.I_PARTY_SUPPORT, -250)
			_add_relation(EmpireData.USA, -200)
			_add_relation(EmpireData.USSR, -200)
			context["result_text"] = tr(TXT_R0)
		1:
			_start_war(14, tr(TXT_WAR14_SIDE1), tr(TXT_WAR14_SIDE2), 700, 300, 1, 1, tr(TXT_WAR14_NAME), 10)
			_add_relation(EmpireData.USA, 200)
			_add_relation(EmpireData.USSR, 200)
			context["result_text"] = tr(TXT_R1)
		2:
			_start_war(14, tr(TXT_WAR14_SIDE1), tr(TXT_WAR14_SIDE2), 700, 300, 1, 1, tr(TXT_WAR14_NAME), 10)
			context["result_text"] = tr(TXT_R2)




func _prev_result(world: WorldState, event_id: String) -> int:
	return int(world.completed_event_ids.get(event_id, 0))


func _budget_reserve(world: WorldState) -> int:
	var total := 0
	var dv := world
	if dv.size() > W.I_BUDGET:
		total += dv.budget
	if dv.size() > W.I_RESERVE:
		total += dv.reserve
	return total


func _faction_leading(i: int) -> bool:
	return GameManager != null and game.is_faction_leading(i)


func _faction_leading_0_1_2() -> bool:
	return _faction_leading(0) or _faction_leading(1) or _faction_leading(2)


func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _establish_proamerican(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", false)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", true)


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, tick_time: int) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = tick_time




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_373_cyprus_second_invasion.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_373",
	"num": 373,
	"priority": 37300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_373_cyprus_second_invasion.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 9, "target": "84"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 84, "target": "14"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 84, "target": "8"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 84, "target": "35"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "84"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "84"}]}, {"t": "DATE_AFTER", "key": "1985.6.1"}],
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
