extends "res://数据脚本/event_script_base.gd"

## 原作 Event364.cs：太空飞机计划。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "event.script.event_364_spaceplane_program.c0"
const TXT_OPT0_DIS := "event.script.event_364_spaceplane_program.c1"
const TXT_OPT1 := "event.script.event_364_spaceplane_program.c2"
const TXT_OPT1_DIS := "event.script.event_364_spaceplane_program.c3"
const TXT_OPT2 := "event.script.event_364_spaceplane_program.c4"

const TXT_R0 := "event.script.event_364_spaceplane_program.c5"
const TXT_R1 := "event.script.event_364_spaceplane_program.c6"
const TXT_R2 := "event.script.event_364_spaceplane_program.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _budget_reserve(world) >= 50:
		_enable(opt[0], tr(TXT_OPT0))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if _budget_reserve(world) >= 100:
		_enable(opt[1], tr(TXT_OPT1))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], tr(TXT_OPT2))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_SCIENCE, 25)
			_add(W.I_BUDGET, -50)
			if d.size() > 143:
				d.oil_price += 5  # 原 data.oil_price（无 I_ 常量）
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_SCIENCE, 100)
			_add(W.I_BUDGET, -100)
			_add(W.I_DIPLO, 50)
			context["result_text"] = tr(TXT_R1)
		2:
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_364_spaceplane_program.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_364",
	"num": 364,
	"priority": 36400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_364_spaceplane_program.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1985.10.1"}, {"t": "TECH_UNLOCKED", "v": 33}, {"t": "PREV_EVENT_DONE", "ref": "event_363"}],
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
