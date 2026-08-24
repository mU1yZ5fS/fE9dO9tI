extends "res://数据脚本/event_script_base.gd"

## 原作 Event428.cs：西班牙加入北约（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1399-1401 —— c86.Gosstroy==3 + resultOfEvents[424]==1 + DATE_AFTER。
## 差异：spec→special；isNATO→标签 nato；Vyshi→亲美。

const TXT_RESULT := "event.script.event_428_spain_joins_nato.c0"
const TXT_IDX_1431 := "event.script.event_428_spain_joins_nato.c1"
const TXT_IDX_1432 := "event.script.event_428_spain_joins_nato.c2"
const TXT_IDX_1433 := "event.script.event_428_spain_joins_nato.c3"
const TXT_IDX_1434 := "event.script.event_428_spain_joins_nato.c4"



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
	var spain := ws.get_country_by_legacy_index(86)
	var portugal := ws.get_country_by_legacy_index(87)
	if portugal != null:
		portugal.special += 5
	if spain != null:
		spain.set_tag("nato", true)
		spain.set_tag("亲美", true)
	_add_power(EmpireData.USA, 70)
	context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_428_spain_joins_nato.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_428",
	"num": 428,
	"priority": 42800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_428_spain_joins_nato.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 3, "target": "86"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "event_424"}, {"t": "DATE_AFTER", "key": "1982.6.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
