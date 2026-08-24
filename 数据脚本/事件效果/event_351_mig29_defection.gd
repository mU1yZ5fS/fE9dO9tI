extends "res://数据脚本/event_script_base.gd"

## 原作 Event351.cs：机群革新。
## 原版无自动条件（决策/其他事件链手动触发）
## 触发：见 evaluate()（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "event.script.event_351_mig29_defection.c0"
const TXT_OPT0_DIS := "event.script.event_351_mig29_defection.c1"
const TXT_OPT1 := "event.script.event_351_mig29_defection.c2"
const TXT_OPT1_DIS := "event.script.event_351_mig29_defection.c3"
const TXT_OPT2 := "event.script.event_351_mig29_defection.c4"
const TXT_OPT2_DIS := "event.script.event_351_mig29_defection.c5"
const TXT_OPT3 := "event.script.event_351_mig29_defection.c6"

const TXT_R0 := "event.script.event_351_mig29_defection.c7"
const TXT_R1 := "event.script.event_351_mig29_defection.c8"
const TXT_R2 := "event.script.event_351_mig29_defection.c9"
const TXT_R3 := "event.script.event_351_mig29_defection.c10"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var dv := world
	var opt := event_def.options
	if dv.size() > W.I_AGENTS and dv.agents >= 20:
		_enable(opt[0], tr(TXT_OPT0))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if dv.size() > W.I_AGENTS and dv.agents >= 30:
		_enable(opt[1], tr(TXT_OPT1))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if world.empires.size() > 1 and world.empires[1] != null and world.empires[1].relations >= 400 \
			and _budget_reserve(world) >= 20:
		_enable(opt[2], tr(TXT_OPT2))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], tr(TXT_OPT3))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(EmpireData.USSR, -70)
			_add(W.I_ARMY, 100)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_ARMY, 100)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_relation(EmpireData.USSR, 70)
			_add(W.I_ARMY, 100)
			_add(W.I_BUDGET, -10)
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_351_mig29_defection.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_351",
	"num": 351,
	"priority": 35100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_351_mig29_defection.gd",
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
