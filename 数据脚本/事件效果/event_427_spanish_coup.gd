extends "res://数据脚本/event_script_base.gd"

## 原作 Event427.cs：西班牙的政变？（四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1394-1396 —— DATE_AFTER + resultOfEvents[425]==1 + event_done[425]。
## 差异：Gosstroy→government；SubGosstroy→sub_government；spec→special。

const TXT_OPT0_EN := "event.script.event_427_spanish_coup.c0"
const TXT_OPT1_EN := "event.script.event_427_spanish_coup.c1"
const TXT_OPT2_EN := "event.script.event_427_spanish_coup.c2"
const TXT_R0 := "event.script.event_427_spanish_coup.c3"
const TXT_R1 := "event.script.event_427_spanish_coup.c4"
const TXT_R2 := "event.script.event_427_spanish_coup.c5"
const TXT_R3 := "event.script.event_427_spanish_coup.c6"
const TXT_IDX_1421 := "event.script.event_427_spanish_coup.c7"
const TXT_IDX_1422 := "event.script.event_427_spanish_coup.c8"
const TXT_IDX_1423 := "event.script.event_427_spanish_coup.c9"
const TXT_IDX_1424 := "event.script.event_427_spanish_coup.c10"
const TXT_IDX_1425 := "event.script.event_427_spanish_coup.c11"
const TXT_IDX_1426 := "event.script.event_427_spanish_coup.c12"
const TXT_IDX_1427 := "event.script.event_427_spanish_coup.c13"
const TXT_IDX_1428 := "event.script.event_427_spanish_coup.c14"
const TXT_IDX_1429 := "event.script.event_427_spanish_coup.c15"
const TXT_IDX_1430 := "event.script.event_427_spanish_coup.c16"
const TXT_IDX_566 := "event.script.event_427_spanish_coup.c17"
const TXT_IDX_567 := "event.script.event_427_spanish_coup.c18"
const TXT_IDX_776 := "event.script.event_427_spanish_coup.c19"
const TXT_IDX_592 := "event.script.event_427_spanish_coup.c20"
const TXT_IDX_593 := "event.script.event_427_spanish_coup.c21"
const TXT_IDX_594 := "event.script.event_427_spanish_coup.c22"



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
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	if budget_reserve >= 100 and agents >= 250:
		_enable(event_def.options[0], _fmt(tr(TXT_OPT0_EN), [tr(TXT_IDX_592), tr(TXT_IDX_593)]))
		_enable(event_def.options[1], _fmt(tr(TXT_OPT1_EN), [tr(TXT_IDX_592), tr(TXT_IDX_593)]))
		_enable(event_def.options[2], _fmt(tr(TXT_OPT2_EN), [tr(TXT_IDX_592), tr(TXT_IDX_593)]))
	elif budget_reserve < 100:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_566), [10]))
		_disable(event_def.options[1], _fmt(tr(TXT_IDX_566), [10]))
		_disable(event_def.options[2], _fmt(tr(TXT_IDX_566), [10]))
	else:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_567), [25]))
		_disable(event_def.options[1], _fmt(tr(TXT_IDX_567), [25]))
		_disable(event_def.options[2], _fmt(tr(TXT_IDX_567), [25]))
	_enable(event_def.options[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var spain := ws.get_country_by_legacy_index(86)
	var portugal := ws.get_country_by_legacy_index(87)
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		if spain != null:
			spain.government = GameConstants.Government.AUTHORITARIAN
			spain.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		if portugal != null:
			portugal.special -= 5
		context["result_text"] = tr(TXT_R0)
		return
	if opt == 1:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		if spain != null:
			spain.government = GameConstants.Government.AUTHORITARIAN
			spain.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		if portugal != null:
			portugal.special -= 5
		context["result_text"] = tr(TXT_R1)
		return
	if opt == 2:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		if spain != null:
			spain.government = GameConstants.Government.REFORMIST
			spain.sub_government = GameConstants.SubGovernment.PRAGMATIST
		if portugal != null:
			portugal.special -= 5
		context["result_text"] = tr(TXT_R2)
		return
	if portugal != null:
		portugal.special += 5
	context["result_text"] = tr(TXT_R3)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_427_spanish_coup.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_427",
	"num": 427,
	"priority": 42700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_427_spanish_coup.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1981.2.17"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "event_425"}, {"t": "PREV_EVENT_DONE", "ref": "event_425"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
