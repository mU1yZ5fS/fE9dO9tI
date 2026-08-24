extends "res://数据脚本/event_script_base.gd"

## 原作 Event371.cs：复仇战争？。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "event.script.event_371_second_lebanon_war.c0"
const TXT_WAR4_NAME := "event.script.event_371_second_lebanon_war.c1"
const TXT_WAR4_SIDE1 := "event.script.event_371_second_lebanon_war.c2"
const TXT_WAR4_SIDE2 := "event.script.event_371_second_lebanon_war.c3"

const TXT_R0 := "event.script.event_371_second_lebanon_war.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 1:
		return
	_enable(event_def.options[0], tr(TXT_OPT0))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.set_flag("israellost", false)
			# 原版 TickTime(12)，但 TimeScript.WorldWarsDone 对 war4 直接按 fortnight_go>=24 判定，
			# 有效超时=24。
			_start_war(4, tr(TXT_WAR4_SIDE1), tr(TXT_WAR4_SIDE2), 600, 400, 0, 1, tr(TXT_WAR4_NAME), 24)
			context["result_text"] = tr(TXT_R0)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_371_second_lebanon_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_371",
	"num": 371,
	"priority": 37100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_371_second_lebanon_war.gd",
	"trigger": [{"t": "HAS_FLAG", "key": "israellost"}, {"t": "WAR_ACTIVE", "v": 10}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 3, "target": "37"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "37"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "35"}]}, {"t": "COUNTRY_FIELD_AT_MOST", "key": "development", "target": "37"}],
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
