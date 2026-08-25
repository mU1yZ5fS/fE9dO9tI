extends "res://数据脚本/event_script_base.gd"

## 原作 Event429.cs：1982年西班牙选举（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1404-1406 —— c86.isNATO + DATE_AFTER。
## 差异：Gosstroy→government；SubGosstroy→sub_government；spec→special。

const TXT_RESULT := "event.script.event_429_spain_election_1982.c0"
const TXT_IDX_1435 := "event.script.event_429_spain_election_1982.c1"
const TXT_IDX_1436 := "event.script.event_429_spain_election_1982.c2"
const TXT_IDX_1154 := "event.script.event_429_spain_election_1982.c3"
const TXT_IDX_1437 := "event.script.event_429_spain_election_1982.c4"



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
		spain.government = GameConstants.Government.LIBERAL
		spain.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
	context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_429_spain_election_1982.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_429",
	"num": 429,
	"priority": 42900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_429_spain_election_1982.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "86"}, {"t": "DATE_AFTER", "key": "1982.11.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
