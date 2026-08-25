extends "res://数据脚本/event_script_base.gd"

## 原作 Event368.cs：一千零一夜。
## 触发：见 evaluate()（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "event.script.event_368_syria_1001_nights.c0"
const TXT_OPT0_DIS := "event.script.event_368_syria_1001_nights.c1"
const TXT_OPT1 := "event.script.event_368_syria_1001_nights.c2"
const TXT_OPT1_DIS := "event.script.event_368_syria_1001_nights.c3"
const TXT_OPT2 := "event.script.event_368_syria_1001_nights.c4"
const TXT_OPT0_DIS_BUDGET := "event.script.event_368_syria_1001_nights.c5"
const TXT_OPT0_DIS_AGENTS := "event.script.event_368_syria_1001_nights.c6"
const TXT_OPT0_DIS_INFLUENCE := "event.script.event_368_syria_1001_nights.c7"
const TXT_OPT1_DIS_BUDGET := "event.script.event_368_syria_1001_nights.c8"
const TXT_OPT1_DIS_AGENTS := "event.script.event_368_syria_1001_nights.c9"
const TXT_OPT1_DIS_OTHER := "event.script.event_368_syria_1001_nights.c10"

const TXT_R0 := "event.script.event_368_syria_1001_nights.c11"
const TXT_R1 := "event.script.event_368_syria_1001_nights.c12"
const TXT_R2 := "event.script.event_368_syria_1001_nights.c13"
const TXT_R1_OK := "event.script.event_368_syria_1001_nights.c14"
const TXT_R1_FAIL := "event.script.event_368_syria_1001_nights.c15"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var syria := world.get_country_by_legacy_index(35)
	var date := world.date
	if date == null:
		return false
	if world.completed_event_ids.has("event_707"):
		return false
	if world.get_flag("oar"):
		return false
	if syria == null:
		return false
	if syria.has_tag("sev"):
		return false
	if syria.government == GameConstants.Government.SOCIALIST:
		return false
	if syria.has_tag("econ"):
		return false
	if int(world.completed_event_ids.get("event_564", 0)) == 1:
		return false
	var branch := false
	if world.completed_event_ids.has("event_564") and date.year == 1983 and date.day > 14 and date.month >= 11 \
			and syria.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST:
		branch = true
	if world.wars.size() > 3 and world.wars[3] != null and world.wars[3].is_going \
			and date.year == 1983 and date.day > 14 and date.month >= 11:
		branch = true
	if world.wars.size() > 28 and world.wars[28] != null and world.wars[28].is_going and date.year >= 1981:
		branch = true
	return branch


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var dv := world
	var budget_reserve := _budget_reserve(world)
	var agents := dv.agents if dv.size() > W.I_AGENTS else 0
	var usa := world.get_country_by_legacy_index(51)
	var usa_dev := usa.development if usa != null else 0
	if budget_reserve >= 100 and agents >= 50:
		_enable(opt[0], tr(TXT_OPT0))
	else:
		var dis0 := tr(TXT_OPT0_DIS)
		if budget_reserve < 100:
			dis0 = tr(TXT_OPT0_DIS_BUDGET)
		elif agents < 50:
			dis0 = tr(TXT_OPT0_DIS_AGENTS)
		else:
			dis0 = tr(TXT_OPT0_DIS_INFLUENCE)
		_disable(opt[0], dis0)
	if budget_reserve >= 50 and agents >= 150 and (world.influence_prc >= 350 or usa_dev > 0):
		_enable(opt[1], tr(TXT_OPT1))
	else:
		var dis1 := tr(TXT_OPT1_DIS)
		if budget_reserve < 50:
			dis1 = tr(TXT_OPT1_DIS_BUDGET)
		elif agents < 150:
			dis1 = tr(TXT_OPT1_DIS_AGENTS)
		else:
			dis1 = tr(TXT_OPT1_DIS_OTHER)
		_disable(opt[1], dis1)
	_enable(opt[2], tr(TXT_OPT2))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var syria := ws.get_country_by_legacy_index(35)
	match opt:
		0:
			if syria != null:
				_establish_prochina(syria)
				syria.set_tag("对华贸易", true)
				syria.government = GameConstants.Government.AUTHORITARIAN
				syria.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_add_power(EmpireData.USSR, -20)
			ws.influence_prc += 20
			_add(W.I_DIPLO, 10)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_PARTY_SUPPORT, 100)
			context["result_text"] = tr(TXT_R0)
		1:
			if ws.influence_prc >= ws.empires[1].power:
				if syria != null:
					_establish_proamerican(syria)
					syria.set_tag("对华贸易", true)
					syria.government = GameConstants.Government.LIBERAL
					syria.sub_government = GameConstants.SubGovernment.MODERATE
				_add_power(EmpireData.USSR, -20)
				_add_power(EmpireData.USA, 20)
				_add(W.I_DIPLO, -10)
				_add(W.I_BUDGET, -50)
				_add(W.I_AGENTS, -150)
				_add(W.I_PARTY_SUPPORT, 50)
				context["result_text"] = tr(TXT_R1_OK)
			else:
				if syria != null:
					syria.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_add(W.I_DIPLO, -10)
				_add(W.I_BUDGET, -50)
				_add(W.I_AGENTS, -150)
				_add_power(EmpireData.USSR, 20)
				_add(W.I_PARTY_SUPPORT, -300)
				context["result_text"] = tr(TXT_R1_FAIL)
		2:
			if syria != null:
				syria.government = GameConstants.Government.REFORMIST
				syria.sub_government = GameConstants.SubGovernment.PRAGMATIST
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_368_syria_1001_nights.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_368",
	"num": 368,
	"priority": 36800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_368_syria_1001_nights.gd",
	"trigger_script": "res://数据脚本/事件效果/event_368_syria_1001_nights.gd",
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
