extends "res://数据脚本/event_script_base.gd"

## 原作 Event425.cs：1979年西班牙选举（二选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1384-1386 —— DATE_AFTER + resultOfEvents[424]==1。
## 差异：Gosstroy→government；SubGosstroy→sub_government。

const TXT_OPT0_EN := "event.script.event_425_spain_election_1979.c0"
const TXT_R0 := "event.script.event_425_spain_election_1979.c1"
const TXT_R1 := "event.script.event_425_spain_election_1979.c2"
const TXT_IDX_1397 := "event.script.event_425_spain_election_1979.c3"
const TXT_IDX_1398 := "event.script.event_425_spain_election_1979.c4"
const TXT_IDX_1399 := "event.script.event_425_spain_election_1979.c5"
const TXT_IDX_1380 := "event.script.event_425_spain_election_1979.c6"
const TXT_IDX_1400 := "event.script.event_425_spain_election_1979.c7"
const TXT_IDX_1401 := "event.script.event_425_spain_election_1979.c8"
const TXT_IDX_566 := "event.script.event_425_spain_election_1979.c9"
const TXT_IDX_567 := "event.script.event_425_spain_election_1979.c10"
const TXT_IDX_776 := "event.script.event_425_spain_election_1979.c11"
const TXT_IDX_592 := "event.script.event_425_spain_election_1979.c12"
const TXT_IDX_593 := "event.script.event_425_spain_election_1979.c13"
const TXT_IDX_594 := "event.script.event_425_spain_election_1979.c14"



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
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	if budget_reserve >= 50 and agents >= 100:
		_enable(event_def.options[0], _fmt(tr(TXT_OPT0_EN), [tr(TXT_IDX_592), tr(TXT_IDX_593)]))
	elif budget_reserve < 50:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_566), [5]))
	else:
		_disable(event_def.options[0], _fmt(tr(TXT_IDX_567), [10]))
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -100)
		var spain := ws.get_country_by_legacy_index(86)
		if spain != null:
			spain.government = GameConstants.Government.REFORMIST
			spain.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		context["result_text"] = tr(TXT_R0)
		return
	context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_425_spain_election_1979.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_425",
	"num": 425,
	"priority": 42500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_425_spain_election_1979.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1979.2.2"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "event_424"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
