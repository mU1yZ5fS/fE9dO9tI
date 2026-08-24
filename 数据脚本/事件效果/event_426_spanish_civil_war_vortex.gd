extends "res://数据脚本/event_script_base.gd"

## 原作 Event426.cs：西班牙内战的漩涡（六选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1389-1391 —— DATE_AFTER + resultOfEvents[424]==0 + event_done[424] + war30 进行。
## 差异：Gosstroy→government；SubGosstroy→sub_government；soc_stab→social_stability；stab→stability；
##  - Torg→对华贸易；AttackerInfluence/DefenderInfluence→infl1/infl2；TickTime 缺省 999。

const TXT_OPT0_EN := "event.script.event_426_spanish_civil_war_vortex.c0"
const TXT_WAR31 := "event.script.event_426_spanish_civil_war_vortex.c1"
const TXT_ATT31 := "event.script.event_426_spanish_civil_war_vortex.c2"
const TXT_DEF31 := "event.script.event_426_spanish_civil_war_vortex.c3"
const TXT_WAR32 := "event.script.event_426_spanish_civil_war_vortex.c4"
const TXT_ATT32 := "event.script.event_426_spanish_civil_war_vortex.c5"
const TXT_R0 := "event.script.event_426_spanish_civil_war_vortex.c6"
const TXT_R1 := "event.script.event_426_spanish_civil_war_vortex.c7"
const TXT_R2 := "event.script.event_426_spanish_civil_war_vortex.c8"
const TXT_R5 := "event.script.event_426_spanish_civil_war_vortex.c9"
const TXT_IDX_1402 := "event.script.event_426_spanish_civil_war_vortex.c10"
const TXT_IDX_1403 := "event.script.event_426_spanish_civil_war_vortex.c11"
const TXT_IDX_1404 := "event.script.event_426_spanish_civil_war_vortex.c12"
const TXT_IDX_1405 := "event.script.event_426_spanish_civil_war_vortex.c13"
const TXT_IDX_1406 := "event.script.event_426_spanish_civil_war_vortex.c14"
const TXT_IDX_1407 := "event.script.event_426_spanish_civil_war_vortex.c15"
const TXT_IDX_1408 := "event.script.event_426_spanish_civil_war_vortex.c16"
const TXT_IDX_1409 := "event.script.event_426_spanish_civil_war_vortex.c17"
const TXT_IDX_1410 := "event.script.event_426_spanish_civil_war_vortex.c18"
const TXT_IDX_1411 := "event.script.event_426_spanish_civil_war_vortex.c19"
const TXT_IDX_1412 := "event.script.event_426_spanish_civil_war_vortex.c20"
const TXT_IDX_1413 := "event.script.event_426_spanish_civil_war_vortex.c21"
const TXT_IDX_1414 := "event.script.event_426_spanish_civil_war_vortex.c22"
const TXT_IDX_1415 := "event.script.event_426_spanish_civil_war_vortex.c23"
const TXT_IDX_1416 := "event.script.event_426_spanish_civil_war_vortex.c24"
const TXT_OPT3_DIS := "event.script.event_426_spanish_civil_war_vortex.c25"
const TXT_OPT4_DIS := "event.script.event_426_spanish_civil_war_vortex.c26"
const TXT_R3 := "event.script.event_426_spanish_civil_war_vortex.c27"
const TXT_R4 := "event.script.event_426_spanish_civil_war_vortex.c28"
const TXT_R3_SIDE1 := "event.script.event_426_spanish_civil_war_vortex.c29"
const TXT_R4_SIDE1 := "event.script.event_426_spanish_civil_war_vortex.c30"
const TXT_R4_SIDE2 := "event.script.event_426_spanish_civil_war_vortex.c31"
const TXT_IDX_566 := "event.script.event_426_spanish_civil_war_vortex.c32"
const TXT_IDX_567 := "event.script.event_426_spanish_civil_war_vortex.c33"
const TXT_IDX_776 := "event.script.event_426_spanish_civil_war_vortex.c34"
const TXT_IDX_592 := "event.script.event_426_spanish_civil_war_vortex.c35"
const TXT_IDX_593 := "event.script.event_426_spanish_civil_war_vortex.c36"
const TXT_IDX_594 := "event.script.event_426_spanish_civil_war_vortex.c37"

## 地图归属：巴斯克四省 / 加泰罗尼亚四省（map_regions.json owner=230 的对应省）。
## 原作 Event426.cs:71-72 仅置 allcountries[86].parts[0/1]，由 MapChangesScript.ShowParts
## 切 country_basks.png / katalonia.png 覆盖层。Godot 地图无覆盖层，等价实现为
## 把对应地块转移到巴斯克国/加泰罗尼亚（9000+ 虚拟 gwcode，与 WorldFactory 偏移一致）。
const BASQUE_REGION_IDS := [625, 626, 2521, 3415]
const CATALONIA_REGION_IDS := [629, 637, 2500, 2501]



func _raw(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s





func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	var army := d.army if d.size() > W.I_ARMY else 0
	if budget_reserve >= 100 and agents >= 50 and army >= 150:
		_enable(event_def.options[0], _fmt(tr(TXT_OPT0_EN), [tr(TXT_IDX_592), tr(TXT_IDX_593), tr(TXT_IDX_594)]))
	elif budget_reserve < 100:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_566), [10]))
	elif agents < 50:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_567), [5]))
	else:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_776), [15]))
	_enable(event_def.options[1], event_def.options[1].text)
	_enable(event_def.options[2], event_def.options[2].text)
	var political_line := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	if political_line <= 1 and army >= 150 and budget_reserve >= 100 and agents >= 150:
		_enable(event_def.options[3], event_def.options[3].text)
	else:
		_disable(event_def.options[3], tr(TXT_OPT3_DIS))
	var mod3_active := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	if political_line != 0 and not mod3_active and army >= 150 and budget_reserve >= 100 and agents >= 150:
		_enable(event_def.options[4], event_def.options[4].text)
	else:
		_disable(event_def.options[4], tr(TXT_OPT4_DIS))
	_enable(event_def.options[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var spain := ws.get_country_by_legacy_index(86)
	var basque := ws.get_country_by_legacy_index(109)
	var catalonia := ws.get_country_by_legacy_index(110)
	if opt != 3 and opt != 4:
		if basque != null:
			basque.government = GameConstants.Government.AUTHORITARIAN
			basque.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
		if spain != null:
			if spain.parts.size() < 2:
				spain.parts.resize(2)
			spain.parts[0] = true
			spain.parts[1] = true
		if catalonia != null:
			catalonia.government = GameConstants.Government.REFORMIST
			catalonia.sub_government = GameConstants.SubGovernment.PRAGMATIST
		if basque != null:
			basque.social_stability = 1000
			basque.stability = 1000
		if catalonia != null:
			catalonia.stability = 1000
			catalonia.social_stability = 1000
		# 地图上让巴斯克/加泰罗尼亚四省从西班牙(230)转移出去。
		game.set_map_region_owner(BASQUE_REGION_IDS, basque.gwcode if basque != null and basque.gwcode > 0 else 9109)
		game.set_map_region_owner(CATALONIA_REGION_IDS, catalonia.gwcode if catalonia != null and catalonia.gwcode > 0 else 9110)
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -50)
		_add(W.I_ARMY, -200)
		_add_relation(EmpireData.USA, -250)
		_add_relation(EmpireData.USSR, -250)
		if basque != null:
			basque.set_tag("对华贸易", true)
		if catalonia != null:
			catalonia.set_tag("对华贸易", true)
		_start_war(31, tr(TXT_ATT31), tr(TXT_DEF31), 500, 500, -1, -1, tr(TXT_WAR31), 999)
		_start_war(32, tr(TXT_ATT32), tr(TXT_DEF31), 500, 500, -1, -1, tr(TXT_WAR32), 999)
		context["result_text"] = tr(TXT_R0)
		return
	if opt == 1:
		_add_relation(EmpireData.USA, -150)
		_add_relation(EmpireData.USSR, -150)
		_start_war(31, tr(TXT_ATT31), tr(TXT_DEF31), 300, 700, -1, -1, tr(TXT_WAR31), 999)
		_start_war(32, tr(TXT_ATT32), tr(TXT_DEF31), 300, 700, -1, -1, tr(TXT_WAR32), 999)
		context["result_text"] = tr(TXT_R1)
		return
	if opt == 2:
		_add_relation(EmpireData.USA, 150)
		_add_relation(EmpireData.USSR, 150)
		_start_war(31, tr(TXT_ATT31), tr(TXT_DEF31), 300, 700, -1, -1, tr(TXT_WAR31), 999)
		_start_war(32, tr(TXT_ATT32), tr(TXT_DEF31), 300, 700, -1, -1, tr(TXT_WAR32), 999)
		context["result_text"] = tr(TXT_R2)
		return
	if opt == 3:
		if ws.wars.size() > 30 and ws.wars[30] != null:
			ws.wars[30].side1 = tr(TXT_R3_SIDE1)
			ws.wars[30].infl1 += 150
			ws.wars[30].infl2 -= 150
		_add(W.I_ARMY, -150)
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		context["result_text"] = tr(TXT_R3)
		return
	if opt == 4:
		if ws.wars.size() > 30 and ws.wars[30] != null:
			ws.wars[30].side1 = tr(TXT_R4_SIDE1)
			ws.wars[30].side2 = tr(TXT_R4_SIDE2)
			ws.wars[30].infl1 = 50
			ws.wars[30].infl2 = 950
		_add(W.I_ARMY, -150)
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		context["result_text"] = tr(TXT_R4)
		return
	_start_war(31, tr(TXT_ATT31), tr(TXT_DEF31), 300, 700, -1, -1, tr(TXT_WAR31), 999)
	_start_war(32, tr(TXT_ATT32), tr(TXT_DEF31), 300, 700, -1, -1, tr(TXT_WAR32), 999)
	context["result_text"] = tr(TXT_R5)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_426_spanish_civil_war_vortex.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_426",
	"num": 426,
	"priority": 42600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_426_spanish_civil_war_vortex.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1979.2.2"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_424"}, {"t": "PREV_EVENT_DONE", "ref": "event_424"}, {"t": "WAR_ACTIVE", "v": 30}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
