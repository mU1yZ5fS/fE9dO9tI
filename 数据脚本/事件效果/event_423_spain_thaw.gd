extends "res://数据脚本/event_script_base.gd"

## 原作 Event423.cs：西班牙解冻（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1374-1376 —— DATE_AFTER。
## 差异：Gosstroy→government；SubGosstroy→sub_government。

const TXT_RESULT := "event.script.event_423_spain_thaw.c0"
const TXT_IDX_1372 := "event.script.event_423_spain_thaw.c1"
const TXT_IDX_1373 := "event.script.event_423_spain_thaw.c2"
const TXT_IDX_1374 := "event.script.event_423_spain_thaw.c3"
const TXT_IDX_1375 := "event.script.event_423_spain_thaw.c4"



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
	if spain != null:
		spain.government = GameConstants.Government.LIBERAL
		spain.sub_government = GameConstants.SubGovernment.LIBERAL
	context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_423_spain_thaw.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_423",
	"num": 423,
	"priority": 42300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_423_spain_thaw.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.6.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
