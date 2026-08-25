extends "res://数据脚本/event_script_base.gd"

## 原作 Event432.cs：共和派阵营的崩溃？（四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1419-1421 —— ExprNode 组合。
## 差异：Gosstroy→government；SubGosstroy→sub_government；spec→special；prosov→亲苏；
##  - data.world_political_balance raw；resultOfEvents[424] 缺省 0 语义由 .tres 的 ANY(not_done, result==0) 表达。

const TXT_OPT0_EN := "event.script.event_432_republican_camp_collapse.c0"
const TXT_OPT1_EN := "event.script.event_432_republican_camp_collapse.c1"
const TXT_OPT2_EN := "event.script.event_432_republican_camp_collapse.c2"
const TXT_R1 := "event.script.event_432_republican_camp_collapse.c3"
const TXT_R2 := "event.script.event_432_republican_camp_collapse.c4"
const TXT_R3 := "event.script.event_432_republican_camp_collapse.c5"
const TXT_NAME_PEOPLE_SPAIN := "event.script.event_432_republican_camp_collapse.c6"
const TXT_IDX_1454 := "event.script.event_432_republican_camp_collapse.c7"
const TXT_IDX_1455 := "event.script.event_432_republican_camp_collapse.c8"
const TXT_IDX_1456 := "event.script.event_432_republican_camp_collapse.c9"
const TXT_IDX_1457 := "event.script.event_432_republican_camp_collapse.c10"
const TXT_IDX_1458 := "event.script.event_432_republican_camp_collapse.c11"
const TXT_IDX_1459 := "event.script.event_432_republican_camp_collapse.c12"
const TXT_IDX_1460 := "event.script.event_432_republican_camp_collapse.c13"
const TXT_IDX_1461 := "event.script.event_432_republican_camp_collapse.c14"
const TXT_IDX_1462 := "event.script.event_432_republican_camp_collapse.c15"
const TXT_IDX_1463 := "event.script.event_432_republican_camp_collapse.c16"
const TXT_IDX_566 := "event.script.event_432_republican_camp_collapse.c17"
const TXT_IDX_567 := "event.script.event_432_republican_camp_collapse.c18"
const TXT_IDX_776 := "event.script.event_432_republican_camp_collapse.c19"
const TXT_IDX_592 := "event.script.event_432_republican_camp_collapse.c20"
const TXT_IDX_593 := "event.script.event_432_republican_camp_collapse.c21"
const TXT_IDX_594 := "event.script.event_432_republican_camp_collapse.c22"



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
	var num := 0
	var num2 := 0
	var num3 := 0
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		num3 += 2
	elif opt == 1:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		if spain != null:
			spain.government = GameConstants.Government.AUTHORITARIAN
			spain.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		if portugal != null:
			portugal.special -= 5
		num2 += 2
	elif opt == 2:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		num += 2
	if spain != null:
		if spain.government == GameConstants.Government.SOCIALIST:
			num3 += 2
			num2 += 1
		elif spain.government == GameConstants.Government.LIBERAL:
			num += 2
	if _raw(131) == 2:
		num3 += 1
		num2 += 1
	elif _raw(131) == 1:
		num2 += 1
	else:
		num += 2
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null:
		if greece.government == GameConstants.Government.REFORMIST:
			num2 += 2
			num3 += 1
		elif greece.government == GameConstants.Government.SOCIALIST:
			num3 += 2
			num2 += 1
		else:
			num += 1
	else:
		num += 1
	var uk := ws.get_country_by_legacy_index(92)
	if uk != null:
		if uk.government == GameConstants.Government.SOCIALIST:
			num3 += 1
		elif uk.government == GameConstants.Government.REFORMIST:
			num2 += 1
		else:
			num += 1
	else:
		num += 1
	var italy := ws.get_country_by_legacy_index(85)
	if italy != null:
		if italy.government == GameConstants.Government.LIBERAL:
			num += 1
		elif italy.government == GameConstants.Government.REFORMIST:
			num2 += 1
		elif italy.government == GameConstants.Government.SOCIALIST:
			num3 += 1
	var num4 := 1 if (num2 >= num3 and num2 >= num) else (2 if (num3 >= num2 and num3 >= num) else 3)
	if spain != null:
		if num4 == 1:
			spain.government = GameConstants.Government.REFORMIST
			spain.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		elif num4 == 2:
			spain.government = GameConstants.Government.SOCIALIST
			spain.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
			spain.name = tr(TXT_NAME_PEOPLE_SPAIN)
			spain.set_tag("亲苏", true)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].leaders.size() > 4:
				ws.empires[EmpireData.USSR].leaders[4].support += 1
		else:
			spain.government = GameConstants.Government.LIBERAL
			spain.sub_government = GameConstants.SubGovernment.MODERATE
	if num4 == 1:
		context["result_text"] = tr(TXT_R1)
	elif num4 == 2:
		context["result_text"] = tr(TXT_R2)
	else:
		context["result_text"] = tr(TXT_R3)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_432_republican_camp_collapse.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_432",
	"num": 432,
	"priority": 43200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_432_republican_camp_collapse.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1983.8.1"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_NOT_DONE", "ref": "event_424"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_424"}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 6, "target": "86"}, {"t": "NOT", "c": [{"t": "WAR_ACTIVE", "v": 30}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
