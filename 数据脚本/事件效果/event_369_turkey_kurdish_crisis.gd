extends "res://数据脚本/event_script_base.gd"

## 原作 Event369.cs：重蹈覆辙？。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "event.script.event_369_turkey_kurdish_crisis.c0"
const TXT_OPT0_DIS := "event.script.event_369_turkey_kurdish_crisis.c1"
const TXT_OPT1 := "event.script.event_369_turkey_kurdish_crisis.c2"
const TXT_OPT1_DIS := "event.script.event_369_turkey_kurdish_crisis.c3"
const TXT_OPT2 := "event.script.event_369_turkey_kurdish_crisis.c4"
const TXT_OPT3 := "event.script.event_369_turkey_kurdish_crisis.c5"
const TXT_OPT1_DIS_BUDGET := "event.script.event_369_turkey_kurdish_crisis.c6"
const TXT_OPT1_DIS_AGENTS := "event.script.event_369_turkey_kurdish_crisis.c7"
const TXT_OPT1_DIS_ARMY := "event.script.event_369_turkey_kurdish_crisis.c8"
const TXT_OPT1_DIS_OTHER := "event.script.event_369_turkey_kurdish_crisis.c9"
const TXT_WAR9_NAME := "event.script.event_369_turkey_kurdish_crisis.c10"
const TXT_WAR9_SIDE1 := "event.script.event_369_turkey_kurdish_crisis.c11"
const TXT_WAR9_SIDE2 := "event.script.event_369_turkey_kurdish_crisis.c12"

const TXT_R0 := "event.script.event_369_turkey_kurdish_crisis.c13"
const TXT_R1 := "event.script.event_369_turkey_kurdish_crisis.c14"
const TXT_R2 := "event.script.event_369_turkey_kurdish_crisis.c15"
const TXT_R3 := "event.script.event_369_turkey_kurdish_crisis.c16"
const TXT_R0_OK := "event.script.event_369_turkey_kurdish_crisis.c17"
const TXT_R0_FAIL := "event.script.event_369_turkey_kurdish_crisis.c18"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var dv := world
	var budget_reserve := _budget_reserve(world)
	var agents := dv.agents if dv.size() > W.I_AGENTS else 0
	var army := dv.army if dv.size() > W.I_ARMY else 0
	if world.get_flag("relres"):
		_enable(opt[0], tr(TXT_OPT0))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	var syria := world.get_country_by_legacy_index(35)
	var iraq := world.get_country_by_legacy_index(14)
	var iran := world.get_country_by_legacy_index(8)
	var any_pro := (syria != null and syria.has_tag("亲中")) \
			or (iraq != null and iraq.has_tag("亲中")) \
			or (iran != null and (iran.has_tag("亲中") or iran.has_tag("okb")))
	if budget_reserve >= 250 and agents >= 150 and army >= 300 and any_pro:
		_enable(opt[1], tr(TXT_OPT1))
	else:
		var dis1 := tr(TXT_OPT1_DIS)
		if budget_reserve < 200:
			dis1 = tr(TXT_OPT1_DIS_BUDGET)
		elif agents < 150:
			dis1 = tr(TXT_OPT1_DIS_AGENTS)
		elif army < 300:
			dis1 = tr(TXT_OPT1_DIS_ARMY)
		else:
			dis1 = tr(TXT_OPT1_DIS_OTHER)
		_disable(opt[1], dis1)
	_enable(opt[2], tr(TXT_OPT2))
	_enable(opt[3], tr(TXT_OPT3))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var turkey := ws.get_country_by_legacy_index(84)
	match opt:
		0:
			if ws.empires[1].power + ws.influence_prc <= ws.empires[0].power:
				_add_power(EmpireData.USA, 10)
				_add(W.I_PARTY_SUPPORT, -50)
				_add(W.I_THOUGHT_FREEDOM, 50)
				context["result_text"] = tr(TXT_R0_FAIL)
			else:
				_add_power(EmpireData.USSR, 10)
				ws.influence_prc += 10
				_add_power(EmpireData.USA, -20)
				_add(W.I_DIPLO, -20)
				_add(W.I_THOUGHT_FREEDOM, -50)
				_add_relation(EmpireData.USA, -100)
				_add_relation(EmpireData.USSR, 100)
				if _faction_leading_0_1_2():
					_add(W.I_PARTY_SUPPORT, 50)
				else:
					_add(W.I_PARTY_SUPPORT, -50)
				context["result_text"] = tr(TXT_R0_OK)
		1:
			var syria := ws.get_country_by_legacy_index(35)
			var iraq := ws.get_country_by_legacy_index(14)
			var iran := ws.get_country_by_legacy_index(8)
			var num := 0
			if syria != null and syria.has_tag("亲中"):
				num += 5
			elif iraq != null and iraq.has_tag("亲中"):
				num += 5
			elif iran != null and (iran.has_tag("亲中") or iran.has_tag("okb")):
				num += 5
			if turkey != null:
				turkey.set_tag("对华贸易", false)
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -200)
			# 原版 TickTime(10)，但 TimeScript.WorldWarsDone 对 war9 另有 fortnight_go>=12 门槛，
			# 有效超时 = max(10,12)=12。
			_start_war(9, tr(TXT_WAR9_SIDE1), tr(TXT_WAR9_SIDE2), 800 - num, 200 + num, 0, 1, tr(TXT_WAR9_NAME), 12)
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)
		3:
			if turkey != null:
				turkey.set_tag("对华贸易", false)
			_add(W.I_DIPLO, -50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -100)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_369_turkey_kurdish_crisis.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_369",
	"num": 369,
	"priority": 36900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_369_turkey_kurdish_crisis.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 9, "target": "84"}, {"t": "DATE_AFTER", "key": "1984.2.2"}, {"t": "DATE_BEFORE", "key": "1984.12.31"}],
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
