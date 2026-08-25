extends "res://数据脚本/event_script_base.gd"

## 原作 Event390.cs：向红看齐？（法国政治危机，两选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - YugAgree → ws.get_flag("YugAgree")；
##  - data.france_socialist_vote/data.france_communist_vote 随机值用 randi_range 复现；
##  - 原版 Debug.Log 跳过；empires[1].leaders[4].support 直访判空。

const TXT_DESC_YUG_FMT := "event.script.event_390_france_turn_red.c0"
const TXT_DESC_FMT := "event.script.event_390_france_turn_red.c1"
const TXT_1052 := "event.script.event_390_france_turn_red.c2"
const TXT_1053 := "event.script.event_390_france_turn_red.c3"
const TXT_1054 := "event.script.event_390_france_turn_red.c4"
const TXT_OPT0_DEFAULT := "event.script.event_390_france_turn_red.c5"
const TXT_OPT0_YUG := "event.script.event_390_france_turn_red.c6"
const TXT_DIS_INFLUENCE := "event.script.event_390_france_turn_red.c7"
const TXT_DIS_BUDGET := "event.script.event_390_france_turn_red.c8"
const TXT_DIS_AGENTS := "event.script.event_390_france_turn_red.c9"
const TXT_DIS_SEV := "event.script.event_390_france_turn_red.c10"
const TXT_R0_DEFAULT := "event.script.event_390_france_turn_red.c11"
const TXT_R0_YUG := "event.script.event_390_france_turn_red.c12"
const TXT_R1_DEFAULT := "event.script.event_390_france_turn_red.c13"
const TXT_R1_YUG := "event.script.event_390_france_turn_red.c14"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	if world.get_flag("YugAgree"):
		event_def.description = tr(TXT_DESC_YUG_FMT).format(["\n", randi_range(31, 39), randi_range(20, 24), _ussr_leader_text(world)])
	else:
		event_def.description = tr(TXT_DESC_FMT).format(["\n", randi_range(31, 39), randi_range(20, 24), _ussr_leader_text(world)])
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if world.get_flag("YugAgree"):
		if china != null and china.has_tag("sev") and _d(W.I_AGENTS) >= 150 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 150:
			_enable(opt[0], tr(TXT_OPT0_YUG))
		else:
			_disable(opt[0], tr(TXT_DIS_SEV))
	else:
		if world.influence_prc >= 500 and _d(W.I_AGENTS) >= 150 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 100 				and (game.is_faction_leading(0) or game.is_faction_leading(1) or game.is_faction_leading(2)):
			_enable(opt[0], tr(TXT_OPT0_DEFAULT))
		elif world.influence_prc < 500:
			_disable(opt[0], tr(TXT_DIS_INFLUENCE).format([50]))
		elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 100:
			_disable(opt[0], tr(TXT_DIS_BUDGET).format([35]))
		elif _d(W.I_AGENTS) < 150:
			_disable(opt[0], tr(TXT_DIS_AGENTS).format([15]))
		else:
			_disable(opt[0], tr(TXT_1054))
	_enable(opt[1], event_def.options[1].text)


func _ussr_leader_text(world: WorldState) -> String:
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null:
		if world.empires[EmpireData.USSR].current_leader == 1:
			return tr(TXT_1052)
		elif world.empires[EmpireData.USSR].current_leader == 2:
			return tr(TXT_1053)
	return tr(TXT_1054)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var _num := _calc_num(ws)
	var france := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	if not ws.get_flag("YugAgree"):
		if opt == 0:
			_add(W.I_AGENTS, -150)
			_add(W.I_BUDGET, -100)
			context["result_text"] = tr(TXT_R0_DEFAULT)
			if france != null:
				france.set_tag("eu", false)
			_add_power(EmpireData.USA, -50)
			_add_power(EmpireData.USSR, 30)
		else:
			context["result_text"] = tr(TXT_R1_DEFAULT)
			if france != null:
				france.government = GameConstants.Government.LIBERAL
				france.sub_government = GameConstants.SubGovernment.MODERATE
			_add_power(EmpireData.USA, 50)
	else:
		if opt == 0:
			_add(W.I_AGENTS, -150)
			_add(W.I_BUDGET, -150)
			context["result_text"] = tr(TXT_R0_YUG)
			if france != null:
				france.set_tag("eu", false)
				france.set_tag("nato", false)
				france.government = GameConstants.Government.SOCIALIST
				france.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				france.set_tag("亲苏", true)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null 					and ws.empires[EmpireData.USSR].leaders.size() > 4:
				ws.empires[EmpireData.USSR].leaders[4].support += 1
			_add_power(EmpireData.USA, -80)
			_add_power(EmpireData.USSR, 80)
		else:
			context["result_text"] = tr(TXT_R1_YUG)
			if france != null:
				france.government = GameConstants.Government.AUTHORITARIAN
				france.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				france.set_tag("eu", false)
				france.set_tag("nato", false)
			if ws.modifiers.size() > 44 and ws.modifiers[44] != null:
				ws.modifiers[44].is_active = false
			_add_power(EmpireData.USA, 50)


func _calc_num(world: WorldState) -> int:
	var num := 0
	var spain := world.get_country_by_legacy_index(86)
	var italy := world.get_country_by_legacy_index(85)
	var portugal := world.get_country_by_legacy_index(87)
	var greece := world.get_country_by_legacy_index(45)
	var usa := world.get_country_by_legacy_index(51)
	if spain != null and spain.government == GameConstants.Government.REFORMIST:
		num += 1
	if italy == null or not italy.has_tag("eu"):
		num += 1
	if spain == null or not spain.has_tag("eu"):
		num += 1
	if portugal == null or not portugal.has_tag("eu"):
		num += 1
	if greece == null or not greece.has_tag("eu"):
		num += 1
	if usa != null and usa.has_tag("对华贸易"):
		num -= 1
	if usa != null and usa.development > 0:
		num -= 1
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null 			and world.empires[EmpireData.USA].current_leader == 1:
		num += 1
	else:
		num -= 1
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null 			and world.empires[EmpireData.USSR].current_leader == 3:
		num += 1
	var num2 := 0
	var china := world.get_country_by_legacy_index(1)
	for c in world.countries:
		if c != null and (c.has_tag("econ") or (china != null and china.has_tag("sev") and c.has_tag("sev"))):
			num2 += 1
	if num2 > 4:
		num += 1
	elif num2 > 9:
		num += 2
	elif num2 > 14:
		num += 3
	if _d(W.I_INFLUENCE) > world.empires[EmpireData.USA].power:
		num += 1
	else:
		num -= 1
	return num




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0








# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_390_france_turn_red.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_390",
	"num": 390,
	"priority": 39000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_390_france_turn_red.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
