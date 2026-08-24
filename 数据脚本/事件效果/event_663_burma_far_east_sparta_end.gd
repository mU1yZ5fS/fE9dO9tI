extends "res://数据脚本/event_script_base.gd"

const T_663_0 := "event.script.event_663_burma_far_east_sparta_end.c0"
const T_663_1 := "event.script.event_663_burma_far_east_sparta_end.c1"
const T_663_2 := "event.script.event_663_burma_far_east_sparta_end.c2"
const T_663_4 := "event.script.event_663_burma_far_east_sparta_end.c3"
const T_663_5 := "event.script.event_663_burma_far_east_sparta_end.c4"
const T_663_6 := "event.script.event_663_burma_far_east_sparta_end.c5"
const T_663_7 := "event.script.event_663_burma_far_east_sparta_end.c6"
const T_663_8 := "event.script.event_663_burma_far_east_sparta_end.c7"
const T_663_9 := "event.script.event_663_burma_far_east_sparta_end.c8"
const T_663_10 := "event.script.event_663_burma_far_east_sparta_end.c9"
const T_663_11 := "event.script.event_663_burma_far_east_sparta_end.c10"
const T_663_12 := "event.script.event_663_burma_far_east_sparta_end.c11"
const T_663_13 := "event.script.event_663_burma_far_east_sparta_end.c12"
const T_663_14 := "event.script.event_663_burma_far_east_sparta_end.c13"


## 原作 Event663.cs：远东斯巴达的终结（缅甸，一选项）。
## 触发：TimeScript.cs:11114-11118 —— allcountries[33].inflCh>=100。
## 差异：
##  - inflCh → CountryData.influence_china；ExprNode 暂不支持，触发走 trigger_script（本脚本 evaluate）。
##  - 死代码 result_num==5 跳过。

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var burma := world.get_country_by_legacy_index(33)
	if burma == null:
		return false
	return burma.influence_china >= 100


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 1:
		return
	event_def.title = tr(T_663_0)
	event_def.description = tr(T_663_1)
	_enable(event_def.options[0], tr(T_663_2))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var r662 := int(ws.completed_event_ids.get("event_662", 0))
	if r662 == 2:
		_start_war(82, tr(T_663_6), tr(T_663_7), 600, 400, 1, 0, tr(T_663_5))
	elif r662 == 4:
		_start_war(82, tr(T_663_9), tr(T_663_10), 700, 300, 0, 0, tr(T_663_8))
	else:
		_start_war(82, tr(T_663_12), tr(T_663_13), 600, 400, 0, 0, tr(T_663_11))
	context["result_text"] = tr(T_663_14)



func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, fortnight: int = -1) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		if fortnight >= 0:
			ws.wars[war_id].fortnight_max = fortnight



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_663_burma_far_east_sparta_end.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_663",
	"num": 663,
	"priority": 66300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_663_burma_far_east_sparta_end.gd",
	"trigger_script": "res://数据脚本/事件效果/event_663_burma_far_east_sparta_end.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
