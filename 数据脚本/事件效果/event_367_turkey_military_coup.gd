extends "res://数据脚本/event_script_base.gd"

## 原作 Event367.cs：土耳其军事政变。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "event.script.event_367_turkey_military_coup.c0"
const TXT_OPT0_DIS := "event.script.event_367_turkey_military_coup.c1"
const TXT_OPT1 := "event.script.event_367_turkey_military_coup.c2"
const TXT_OPT1_DIS := "event.script.event_367_turkey_military_coup.c3"
const TXT_OPT2 := "event.script.event_367_turkey_military_coup.c4"
const TXT_OPT3 := "event.script.event_367_turkey_military_coup.c5"
const TXT_OPT4 := "event.script.event_367_turkey_military_coup.c6"
const TXT_OPT0_DIS_BUDGET := "event.script.event_367_turkey_military_coup.c7"
const TXT_OPT0_DIS_AGENTS := "event.script.event_367_turkey_military_coup.c8"
const TXT_OPT0_DIS_ARMY := "event.script.event_367_turkey_military_coup.c9"
const TXT_OPT0_DIS_INFLUENCE := "event.script.event_367_turkey_military_coup.c10"
const TXT_OPT0_DIS_OTHER := "event.script.event_367_turkey_military_coup.c11"
const TXT_OPT1_DIS_BUDGET := "event.script.event_367_turkey_military_coup.c12"
const TXT_OPT1_DIS_AGENTS := "event.script.event_367_turkey_military_coup.c13"
const TXT_OPT1_DIS_INFLUENCE := "event.script.event_367_turkey_military_coup.c14"
const TXT_OPT1_DIS_OTHER := "event.script.event_367_turkey_military_coup.c15"
const TXT_WAR8_NAME := "event.script.event_367_turkey_military_coup.c16"
const TXT_WAR8_SIDE1 := "event.script.event_367_turkey_military_coup.c17"
const TXT_WAR8_SIDE2 := "event.script.event_367_turkey_military_coup.c18"

const TXT_R0 := "event.script.event_367_turkey_military_coup.c19"
const TXT_R1 := "event.script.event_367_turkey_military_coup.c20"
const TXT_R2 := "event.script.event_367_turkey_military_coup.c21"
const TXT_R3 := "event.script.event_367_turkey_military_coup.c22"
const TXT_R4 := "event.script.event_367_turkey_military_coup.c23"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	var dv := world
	var budget_reserve := _budget_reserve(world)
	var agents := dv.agents if dv.size() > W.I_AGENTS else 0
	var army := dv.army if dv.size() > W.I_ARMY else 0
	var r366 := _prev_result(world, "event_366")
	if r366 == 0 and budget_reserve >= 250 and agents >= 150 and world.influence_prc >= 200 and army >= 200:
		_enable(opt[0], tr(TXT_OPT0))
	else:
		var dis0 := tr(TXT_OPT0_DIS)
		if budget_reserve < 250:
			dis0 = tr(TXT_OPT0_DIS_BUDGET)
		elif agents < 150:
			dis0 = tr(TXT_OPT0_DIS_AGENTS)
		elif army < 200:
			dis0 = tr(TXT_OPT0_DIS_ARMY)
		elif world.influence_prc < 200:
			dis0 = tr(TXT_OPT0_DIS_INFLUENCE)
		else:
			dis0 = tr(TXT_OPT0_DIS_OTHER)
		_disable(opt[0], dis0)
	if r366 == 1 and budget_reserve >= 250 and agents >= 150 and world.influence_prc >= 200:
		_enable(opt[1], tr(TXT_OPT1))
	else:
		var dis1 := tr(TXT_OPT1_DIS)
		if budget_reserve < 250:
			dis1 = tr(TXT_OPT1_DIS_BUDGET)
		elif agents < 150:
			dis1 = tr(TXT_OPT1_DIS_AGENTS)
		elif world.influence_prc < 200:
			dis1 = tr(TXT_OPT1_DIS_INFLUENCE)
		else:
			dis1 = tr(TXT_OPT1_DIS_OTHER)
		_disable(opt[1], dis1)
	_enable(opt[2], tr(TXT_OPT2))
	_enable(opt[3], tr(TXT_OPT3))
	_enable(opt[4], tr(TXT_OPT4))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey != null:
		turkey.government = GameConstants.Government.AUTHORITARIAN
		turkey.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
	match opt:
		0:
			if _faction_leading_0_1_2():
				_add(W.I_PARTY_SUPPORT, 150)
			else:
				_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_MIL_INTERVENTION, 1000)
			_add_relation(EmpireData.USA, -200)
			_add_relation(EmpireData.USSR, 100)
			_add_power(EmpireData.USA, -20)
			_add(W.I_DIPLO, 20)
			_add(W.I_BUDGET, -250)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -200)
			_start_war(8, tr(TXT_WAR8_SIDE1), tr(TXT_WAR8_SIDE2), 800, 200, 0, 1, tr(TXT_WAR8_NAME), 20)
			context["result_text"] = tr(TXT_R0)
		1:
			if turkey != null:
				turkey.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				turkey.set_tag("对华贸易", true)
			var c87 := ws.get_country_by_legacy_index(87)
			if c87 != null:
				c87.special -= 5
			if _faction_leading_0_1_2():
				_add(W.I_PARTY_SUPPORT, 150)
			else:
				_add(W.I_PARTY_SUPPORT, -100)
			_add_relation(EmpireData.USA, -200)
			_add_relation(EmpireData.USSR, -200)
			_add_power(EmpireData.USA, -30)
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -250)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -200)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PARTY_SUPPORT, -50)
			context["result_text"] = tr(TXT_R2)
		3:
			if _faction_leading_0_1_2():
				_add(W.I_PARTY_SUPPORT, -150)
			else:
				_add(W.I_PARTY_SUPPORT, 100)
			context["result_text"] = tr(TXT_R3)
		4:
			if _faction_leading_0_1_2():
				_add(W.I_PARTY_SUPPORT, 150)
			else:
				_add(W.I_PARTY_SUPPORT, -100)
			_add_relation(EmpireData.USA, -300)
			_add_relation(EmpireData.USSR, 200)
			_add_power(EmpireData.USA, 20)
			context["result_text"] = tr(TXT_R4)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_367_turkey_military_coup.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_367",
	"num": 367,
	"priority": 36700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_367_turkey_military_coup.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1980.9.12"}],
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
