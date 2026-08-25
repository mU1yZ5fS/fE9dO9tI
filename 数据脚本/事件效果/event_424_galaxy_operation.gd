extends "res://数据脚本/event_script_base.gd"

## 原作 Event424.cs：银河行动（二选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1379-1381 —— DATE_AFTER。
## 差异：based→有驻军基地；TickTime 缺省 999→fortnight_max=999；
##  - AttackerInfluence(300).DefenderInfluence(700)→infl1=300,infl2=700。

const TXT_DESC_BASE := "event.script.event_424_galaxy_operation.c0"
const TXT_OPT0_EN := "event.script.event_424_galaxy_operation.c1"
const TXT_OPT0_NO_CONTACT := "event.script.event_424_galaxy_operation.c2"
const TXT_R0 := "event.script.event_424_galaxy_operation.c3"
const TXT_R1 := "event.script.event_424_galaxy_operation.c4"
const TXT_WAR_NAME := "event.script.event_424_galaxy_operation.c5"
const TXT_WAR_ATT := "event.script.event_424_galaxy_operation.c6"
const TXT_WAR_DEF := "event.script.event_424_galaxy_operation.c7"
const TXT_BASED_1 := "event.script.event_424_galaxy_operation.c8"
const TXT_BASED_2 := "event.script.event_424_galaxy_operation.c9"
const TXT_IDX_1376 := "event.script.event_424_galaxy_operation.c10"
const TXT_IDX_1377 := "event.script.event_424_galaxy_operation.c11"
const TXT_IDX_1378 := "event.script.event_424_galaxy_operation.c12"
const TXT_IDX_1379 := "event.script.event_424_galaxy_operation.c13"
const TXT_IDX_1380 := "event.script.event_424_galaxy_operation.c14"
const TXT_IDX_1381 := "event.script.event_424_galaxy_operation.c15"
const TXT_IDX_1382 := "event.script.event_424_galaxy_operation.c16"
const TXT_IDX_1383 := "event.script.event_424_galaxy_operation.c17"
const TXT_IDX_1384 := "event.script.event_424_galaxy_operation.c18"
const TXT_IDX_1385 := "event.script.event_424_galaxy_operation.c19"
const TXT_IDX_1386 := "event.script.event_424_galaxy_operation.c20"
const TXT_IDX_1387 := "event.script.event_424_galaxy_operation.c21"
const TXT_IDX_566 := "event.script.event_424_galaxy_operation.c22"
const TXT_IDX_567 := "event.script.event_424_galaxy_operation.c23"
const TXT_IDX_776 := "event.script.event_424_galaxy_operation.c24"
const TXT_IDX_592 := "event.script.event_424_galaxy_operation.c25"
const TXT_IDX_593 := "event.script.event_424_galaxy_operation.c26"
const TXT_IDX_594 := "event.script.event_424_galaxy_operation.c27"



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
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var spain := world.get_country_by_legacy_index(86)
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	var based := spain != null and spain.有驻军基地
	if based:
		event_def.description = tr(TXT_DESC_BASE).replace("{1}", tr(TXT_BASED_1)).replace("{2}", tr(TXT_BASED_2))
	else:
		event_def.description = tr(TXT_DESC_BASE).replace("{1}", "").replace("{2}", "")
	if budget_reserve >= 100 and agents >= 150 and based:
		_enable(event_def.options[0], _fmt(tr(TXT_OPT0_EN), [tr(TXT_IDX_592), tr(TXT_IDX_593)]))
	elif not based:
		_disable(event_def.options[0], tr(TXT_OPT0_NO_CONTACT))
	elif budget_reserve < 100:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_566), [10]))
	else:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_567), [15]))
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var _spain := ws.get_country_by_legacy_index(86)
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		_start_war(30, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), 300, 700, -1, -1, tr(TXT_WAR_NAME), 999)
		var portugal := ws.get_country_by_legacy_index(87)
		if portugal != null:
			portugal.special -= 10
		context["result_text"] = tr(TXT_R0)
		return
	context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_424_galaxy_operation.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_424",
	"num": 424,
	"priority": 42400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_424_galaxy_operation.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.11.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
