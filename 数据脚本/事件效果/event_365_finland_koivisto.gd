extends "res://数据脚本/event_script_base.gd"

## 原作 Event365.cs：亲苏反共派的离任。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "event.script.event_365_finland_koivisto.c0"
const TXT_OPT0_DIS := "event.script.event_365_finland_koivisto.c1"
const TXT_OPT1 := "event.script.event_365_finland_koivisto.c2"
const TXT_OPT1_DIS := "event.script.event_365_finland_koivisto.c3"
const TXT_OPT2 := "event.script.event_365_finland_koivisto.c4"
const TXT_OPT0_DIS_NOT_SEV := "event.script.event_365_finland_koivisto.c5"
const TXT_OPT0_DIS_IDEOLOGY := "event.script.event_365_finland_koivisto.c6"
const TXT_OPT0_DIS_INFLUENCE := "event.script.event_365_finland_koivisto.c7"
const TXT_OPT0_DIS_AGENTS := "event.script.event_365_finland_koivisto.c8"
const TXT_OPT0_DIS_BUDGET := "event.script.event_365_finland_koivisto.c9"
const TXT_OPT1_DIS_INFLUENCE := "event.script.event_365_finland_koivisto.c10"
const TXT_OPT1_DIS_RELRES := "event.script.event_365_finland_koivisto.c11"
const TXT_OPT1_DIS_AGENTS := "event.script.event_365_finland_koivisto.c12"
const TXT_OPT1_DIS_BUDGET := "event.script.event_365_finland_koivisto.c13"

const TXT_R0 := "event.script.event_365_finland_koivisto.c14"
const TXT_R1 := "event.script.event_365_finland_koivisto.c15"
const TXT_R2 := "event.script.event_365_finland_koivisto.c16"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var dv := world
	var china := world.get_country_by_legacy_index(1)
	var usa := world.get_country_by_legacy_index(51)
	var budget_reserve := _budget_reserve(world)
	var ideology := dv.ideology if dv.size() > W.I_IDEOLOGY else 0
	var agents := dv.agents if dv.size() > W.I_AGENTS else 0
	var china_sev := china != null and china.has_tag("sev")
	if china_sev and world.influence_prc >= 300 and ideology > 1 and budget_reserve >= 100 and agents >= 100:
		_enable(opt[0], tr(TXT_OPT0))
	else:
		var dis0 := tr(TXT_OPT0_DIS)
		if not china_sev:
			dis0 = tr(TXT_OPT0_DIS_NOT_SEV)
		elif ideology <= 1:
			dis0 = tr(TXT_OPT0_DIS_IDEOLOGY)
		elif world.influence_prc < 300:
			dis0 = tr(TXT_OPT0_DIS_INFLUENCE)
		elif agents < 100:
			dis0 = tr(TXT_OPT0_DIS_AGENTS)
		else:
			dis0 = tr(TXT_OPT0_DIS_BUDGET)
		_disable(opt[0], dis0)
	var usa_dev := usa.development if usa != null else 0
	if budget_reserve >= 100 and agents >= 100 and not world.get_flag("relres") \
			and (world.influence_prc >= 150 or usa_dev > 0):
		_enable(opt[1], tr(TXT_OPT1))
	else:
		var dis1 := tr(TXT_OPT1_DIS)
		if world.influence_prc < 150 and usa_dev <= 0:
			dis1 = tr(TXT_OPT1_DIS_INFLUENCE)
		elif world.get_flag("relres"):
			dis1 = tr(TXT_OPT1_DIS_RELRES)
		elif agents < 100:
			dis1 = tr(TXT_OPT1_DIS_AGENTS)
		else:
			dis1 = tr(TXT_OPT1_DIS_BUDGET)
		_disable(opt[1], dis1)
	_enable(opt[2], tr(TXT_OPT2))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var finland := ws.get_country_by_legacy_index(26)
	match opt:
		0:
			if finland != null:
				finland.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				finland.set_tag("sev", true)
			ws.influence_prc += 10
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, -30)
			_add_power(EmpireData.USSR, 10)
			if d.size() > W.I_ECON_DISPLAY and d.econ_display < 35:
				_add(W.I_PARTY_SUPPORT, -100)
			else:
				_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			if finland != null:
				finland.government = GameConstants.Government.LIBERAL
				finland.sub_government = GameConstants.SubGovernment.LIBERAL
				finland.set_tag("亲苏", false)
				finland.set_tag("对华贸易", true)
			ws.influence_prc += 20
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_DIPLO, -60)
			if d.size() > W.I_ECON_DISPLAY and d.econ_display < 36:
				_add(W.I_PARTY_SUPPORT, -100)
			else:
				_add(W.I_PARTY_SUPPORT, 50)
			_add_power(EmpireData.USSR, -20)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_365_finland_koivisto.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_365",
	"num": 365,
	"priority": 36500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_365_finland_koivisto.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.10.1"}],
	"options": [{"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"notext": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
