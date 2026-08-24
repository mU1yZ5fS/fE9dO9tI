extends "res://数据脚本/event_script_base.gd"

## 原作 Event422.cs：欧洲日落（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1364-1366 —— ExprNode 组合。
## 差异：isEU→标签 eu；power 直接。

const TXT_RESULT := "event.script.event_422_europe_sunset.c0"
const TXT_IDX_1368 := "event.script.event_422_europe_sunset.c1"
const TXT_IDX_1369 := "event.script.event_422_europe_sunset.c2"
const TXT_IDX_1370 := "event.script.event_422_europe_sunset.c3"
const TXT_IDX_1371 := "event.script.event_422_europe_sunset.c4"



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

## 原作 Event422.cs:18-21：TextOfEvents 显示时 event_done[421] && iron_and_blood → Set(141)
func prepare(_event_def: EventDef, world: WorldState) -> void:
	if world != null and world.completed_event_ids.has("event_421"):
		Achievements.set_achievement(141)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	if usa != null and usa.power > 0:
		usa.power = 0
	for c in ws.countries:
		if c != null:
			c.set_tag("eu", false)
	context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_422_europe_sunset.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_422",
	"num": 422,
	"priority": 42200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_422_europe_sunset.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "eu", "target": "21"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "eu", "target": "85"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "eu", "target": "86"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "eu", "target": "92"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "eu", "target": "45"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
