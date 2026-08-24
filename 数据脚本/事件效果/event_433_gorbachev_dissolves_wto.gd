extends "res://数据脚本/event_script_base.gd"

## 原作 Event433.cs：戈尔巴乔夫解散华沙条约组织（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1424-1426 —— ExprNode 组合。
## 差异：now_leader→current_leader（ExprNode EMPIRE_LEADER_IS）；isOVD→标签 ovd；influencePRC→influence_prc。

const TXT_RESULT := "event.script.event_433_gorbachev_dissolves_wto.c0"
const TXT_IDX_1492 := "event.script.event_433_gorbachev_dissolves_wto.c1"
const TXT_IDX_1493 := "event.script.event_433_gorbachev_dissolves_wto.c2"
const TXT_IDX_1494 := "event.script.event_433_gorbachev_dissolves_wto.c3"
const TXT_IDX_1495 := "event.script.event_433_gorbachev_dissolves_wto.c4"



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
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
			and ws.empires[EmpireData.USSR].leaders.size() > 6:
		ws.empires[EmpireData.USSR].leaders[6].support -= 1
	for c in ws.countries:
		if c != null and c.has_tag("ovd"):
			c.set_tag("ovd", false)
	_add_power(EmpireData.USSR, -350)
	_add_power(EmpireData.USA, 100)
	ws.influence_prc += 100
	context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_433_gorbachev_dissolves_wto.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_433",
	"num": 433,
	"priority": 43300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_433_gorbachev_dissolves_wto.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "EMPIRE_LEADER_IS", "key": "1", "v": 6}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "2"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "5"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "4"}]}, {"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "51"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "development", "v": 2, "target": "17"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 3, "target": "17"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "v": 19, "target": "4"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
