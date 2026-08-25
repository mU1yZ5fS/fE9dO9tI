extends "res://数据脚本/event_script_base.gd"

const T_660_0 := "event.script.event_660_uganda_new_dictator.c0"
const T_660_1 := "event.script.event_660_uganda_new_dictator.c1"
const T_660_2 := "event.script.event_660_uganda_new_dictator.c2"
const T_660_3 := "event.script.event_660_uganda_new_dictator.c3"
const T_660_4 := "event.script.event_660_uganda_new_dictator.c4"
const T_660_6 := "event.script.event_660_uganda_new_dictator.c5"
const T_660_7 := "event.script.event_660_uganda_new_dictator.c6"
const T_660_8 := "event.script.event_660_uganda_new_dictator.c7"
const T_660_9 := "event.script.event_660_uganda_new_dictator.c8"
const T_660_10 := "event.script.event_660_uganda_new_dictator.c9"
const T_660_11 := "event.script.event_660_uganda_new_dictator.c10"
const T_660_12 := "event.script.event_660_uganda_new_dictator.c11"
const T_660_13 := "event.script.event_660_uganda_new_dictator.c12"
const T_660_14 := "event.script.event_660_uganda_new_dictator.c13"


## 原作 Event660.cs：七丘之城的新狄克推多（乌干达，两选项）。 ## 触发：TimeScript.cs:11100-11105 —— 日期(>=1985.7.30)&&resultOfEvents[659]<3 ## (乌干达 inflCh>800 && !event_done[661])。 ## 差异： ##  - inflCh 字段（原版 Country.inflCh → CountryData.influence_china）ExprNode 暂不支持， ##    触发条件走 EventDef.trigger_script（本脚本 evaluate）。 ##  - 死代码 result_num==5 跳过。

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world
	if data.size() <= W.I_YEAR:
		return false
	var date_ok := (data.year >= 1985 and data.month >= 7 and data.day >= 30) \
			or (data.year >= 1985 and data.month >= 8) \
			or data.year >= 1986
	var r659 := int(world.completed_event_ids.get("event_659", 0))
	if date_ok and r659 < 3:
		return true
	var uganda := world.get_country_by_legacy_index(118)
	if uganda != null and uganda.influence_china > 800 and not world.completed_event_ids.has("event_661"):
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	event_def.title = tr(T_660_0)
	event_def.description = tr(T_660_1)
	var r659 := int(world.completed_event_ids.get("event_659", 0))
	var opt := event_def.options
	_enable(opt[0], tr(T_660_2))
	if r659 == 2:
		_enable(opt[1], tr(T_660_3))
	else:
		_disable(opt[1], tr(T_660_4))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uganda := ws.get_country_by_legacy_index(118)
	_set_part(uganda, 0, true)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_start_war(81, tr(T_660_8), tr(T_660_9), 700, 300, 0, 0, tr(T_660_7))
			context["result_text"] = tr(T_660_10)
		1:
			_start_war(81, tr(T_660_12), tr(T_660_13), 800, 200, 0, 0, tr(T_660_11))
			context["result_text"] = tr(T_660_14)




func _set_part(country: CountryData, index: int, value: bool) -> void:
	if country == null:
		return
	while country.parts.size() <= index:
		country.parts.append(false)
	country.parts[index] = value


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, fortnight: int = -1) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		if fortnight >= 0:
			ws.wars[war_id].fortnight_max = fortnight



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_660_uganda_new_dictator.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_660",
	"num": 660,
	"priority": 66000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_660_uganda_new_dictator.gd",
	"trigger_script": "res://数据脚本/事件效果/event_660_uganda_new_dictator.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
