extends "res://数据脚本/event_script_base.gd"

## 原作 Event678.cs：你正在进入自由德里（北爱尔兰动乱，单选项）。
## 触发：ReqEventsDLC02.cs:1461-1464 —— !ev673 && !c29.parts[0] && !c166.parts[0]
##   && (d162/163/164/166 任一>=100) && DATE_AFTER 1979.8.27 → trigger_script evaluate。
## 差异：data.get_data_by_index(162-166) raw index；BritLost→get_flag；ingamewars[86] 兜底创建后补名。

const TXT_DESC_A := "event.script.event_678_free_derry.c0"
const TXT_DESC_B_PRE := "event.script.event_678_free_derry.c1"
const TXT_DESC_THATCHER := "event.script.event_678_free_derry.c2"
const TXT_DESC_LABOUR := "event.script.event_678_free_derry.c3"
const TXT_DESC_OTHER := "event.script.event_678_free_derry.c4"
const TXT_DESC_B_TAIL := "event.script.event_678_free_derry.c5"
const TXT_R0 := "event.script.event_678_free_derry.c6"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	if int(ws.completed_event_ids.get("event_677", 0)) != 4:
		event_def.description = tr(TXT_DESC_A)
		return
	var branch := tr(TXT_DESC_OTHER)
	var data147 := d.britain_political_route if d.size() > 147 else 0
	if data147 == 5:
		branch = tr(TXT_DESC_THATCHER)
	elif data147 == 3 or data147 == 6 or data147 == 8:
		branch = tr(TXT_DESC_LABOUR)
	event_def.description = tr(TXT_DESC_B_PRE) + branch + tr(TXT_DESC_B_TAIL)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	var num := 100 if ws.get_flag("BritLost") else 0
	for idx in [162, 163, 164, 166]:
		if d.size() > idx and d.get_data_by_index(idx) >= 100:
			d.set_data_by_index(idx, 100)
	context["result_text"] = tr(TXT_R0)
	# 原版 ingamewars[86]：北爱尔兰冲突，爱尔兰武装(400-num) vs 英国(600+num)，AmericanSupportDefender
	game.start_war(86, "爱尔兰武装", "英国", 400 - num, 600 + num, 2, -1)
	if ws.wars.size() > 86 and ws.wars[86] != null:
		ws.wars[86].name_war = "北爱尔兰冲突"
	var ireland := ws.get_country_by_legacy_index(29)
	if ireland != null:
		_set_part(ireland, 1, true)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19790827:
		return false
	if world.completed_event_ids.has("event_673"):
		return false
	var ireland := world.get_country_by_legacy_index(29)
	if ireland != null and ireland.parts.size() > 0 and ireland.parts[0]:
		return false
	var northern := world.get_country_by_legacy_index(166)
	if northern != null and northern.parts.size() > 0 and northern.parts[0]:
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	for idx in [162, 163, 164, 166]:
		if d.size() > idx and d.get_data_by_index(idx) >= 100:
			return true
	return false


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_678_free_derry.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_678",
	"nodesc": true,
	"num": 678,
	"priority": 67800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_678_free_derry.gd",
	"trigger_script": "res://数据脚本/事件效果/event_678_free_derry.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
