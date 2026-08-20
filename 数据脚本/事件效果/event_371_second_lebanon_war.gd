extends "res://数据脚本/event_script_base.gd"

## 原作 Event371.cs：复仇战争？。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "战争即地狱"
const TXT_WAR4_NAME := "第二次黎巴嫩战争"
const TXT_WAR4_SIDE1 := "以色列"
const TXT_WAR4_SIDE2 := "黎巴嫩"

const TXT_R0 := "希望这一切都将在不久后结束......"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 1:
		return
	_enable(event_def.options[0], TXT_OPT0)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.set_flag("israellost", false)
			# 原版 TickTime(12)，但 TimeScript.WorldWarsDone 对 war4 直接按 fortnight_go>=24 判定，
			# 有效超时=24。
			_start_war(4, TXT_WAR4_SIDE1, TXT_WAR4_SIDE2, 600, 400, 0, 1, TXT_WAR4_NAME, 24)
			context["result_text"] = TXT_R0




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
	return GameManager != null and GameManager.is_faction_leading(i)


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
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = tick_time

