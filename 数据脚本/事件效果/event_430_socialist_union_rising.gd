extends "res://数据脚本/event_script_base.gd"

## 原作 Event430.cs：社会主义联盟的勃兴（三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1179-1181 —— ExprNode 组合。
## 差异：cw→内战中；perevorot→政变中；isNATO/isSocEU/isEU/isSEV/okb/econ→标签；
##  - LeaveAlliances→_leave_alliances；Torg→对华贸易；empires[1].leaders[6]→leaders[6]；
##  - 原版 num/flag/flag2 死代码跳过；result_num 2 无额外效果。

const TXT_IDX_1438 := "event.script.event_430_socialist_union_rising.c0"
const TXT_IDX_1440 := "event.script.event_430_socialist_union_rising.c1"
const TXT_IDX_1441 := "event.script.event_430_socialist_union_rising.c2"
const TXT_IDX_1442 := "event.script.event_430_socialist_union_rising.c3"
const TXT_IDX_1446 := "event.script.event_430_socialist_union_rising.c4"
const TXT_IDX_1447 := "event.script.event_430_socialist_union_rising.c5"
const TXT_IDX_1448 := "event.script.event_430_socialist_union_rising.c6"
const TXT_IDX_1449 := "event.script.event_430_socialist_union_rising.c7"
const TXT_APPEND_PT := "event.script.event_430_socialist_union_rising.c8"
const TXT_APPEND_UK := "event.script.event_430_socialist_union_rising.c9"



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

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var italy := ws.get_country_by_legacy_index(85)
	var france := ws.get_country_by_legacy_index(21)
	var spain := ws.get_country_by_legacy_index(86)
	var portugal := ws.get_country_by_legacy_index(87)
	var turkey := ws.get_country_by_legacy_index(84)
	var uk := ws.get_country_by_legacy_index(92)
	if italy != null:
		italy.内战中 = false
		italy.政变中 = false
	# 原版 flag/flag2 恒为 false，num 恒为 0，1443-1445 死代码，跳过。
	var flag3 := (france != null and france.has_tag("nato")) \
			or (spain != null and spain.has_tag("nato")) \
			or (italy != null and italy.has_tag("nato"))
	# 原作 Event430.cs:56：iron_and_blood → achievements.Set(127)
	Achievements.set_achievement(127)
	if france != null:
		_leave_alliances(france)
	if spain != null:
		_leave_alliances(spain)
	if italy != null:
		_leave_alliances(italy)
	if italy != null:
		italy.set_tag("soc_eu", true)
	if france != null:
		france.set_tag("soc_eu", true)
	if spain != null:
		spain.set_tag("soc_eu", true)
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
			and ws.empires[EmpireData.USSR].leaders.size() > 6:
		ws.empires[EmpireData.USSR].leaders[6].support += 999
	if portugal != null and portugal.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST and not portugal.has_tag("econ") \
			and not portugal.has_tag("eu") and not portugal.has_tag("okb") and not portugal.has_tag("sev"):
		_leave_alliances(portugal)
		portugal.set_tag("soc_eu", true)
	if turkey != null and turkey.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST and not turkey.has_tag("econ") \
			and not turkey.has_tag("eu") and not turkey.has_tag("okb") and not turkey.has_tag("sev"):
		_leave_alliances(turkey)
		turkey.set_tag("soc_eu", true)
	_add_power(EmpireData.USA, -100)
	var base := ""
	if opt == 0:
		base = tr(TXT_IDX_1447)
	elif opt == 1:
		base = tr(TXT_IDX_1448)
	else:
		base = tr(TXT_IDX_1449)
	var text := base.replace("{1}", "").replace("{2}", tr(TXT_IDX_1446) if flag3 else "")
	if portugal != null and portugal.has_tag("soc_eu"):
		text += tr(TXT_APPEND_PT)
	if italy != null and italy.has_tag("soc_eu") and _raw(147) == 3:
		text += "\n" + tr(TXT_APPEND_UK)
		if uk != null:
			uk.set_tag("soc_eu", true)
			uk.set_tag("nato", false)
	context["result_text"] = text
	if opt == 0:
		_add_relation(EmpireData.USA, -500)
		for c in ws.countries:
			if c != null and c.has_tag("soc_eu"):
				c.set_tag("对华贸易", true)
		return
	if opt == 1:
		_add_relation(EmpireData.USA, 300)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_430_socialist_union_rising.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_430",
	"num": 430,
	"priority": 43000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_430_socialist_union_rising.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 3, "target": "86"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 14, "target": "85"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 14, "target": "21"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_556"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_396"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 20, "target": "85"}, {"t": "DATE_AFTER", "key": "1983.5.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
