extends "res://数据脚本/event_script_base.gd"

## 原作 Event679.cs：26+6=1（爱尔兰统一战争，单选项）。 ## 触发：ReqEventsDLC02.cs:1466-1469 —— c166.parts[0] && (c166.sub!=1 !c166.亲中) ##   && IsSocialism(false,29) && (d167==0 DATE_AFTER 1985.6.1) → trigger_script evaluate。 ## 差异：ingamewars[87] 兜底创建后补名；AmericanSupportDefender → usa_side=2。

const TXT_DESC_A := "event.script.event_679_ireland_unity_war.c0"
const TXT_DESC_B := "event.script.event_679_ireland_unity_war.c1"
const TXT_R0 := "event.script.event_679_ireland_unity_war.c2"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	if int(ws.completed_event_ids.get("event_677", 0)) != 4:
		event_def.description = tr(TXT_DESC_A)
	else:
		event_def.description = tr(TXT_DESC_B)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt != 0:
		return
	context["result_text"] = tr(TXT_R0)
	game.start_war(87, "北爱尔兰", "爱尔兰", 500, 500, 2, -1)
	if ws.wars.size() > 87 and ws.wars[87] != null:
		ws.wars[87].name_war = "爱尔兰统一战争"
	var northern := ws.get_country_by_legacy_index(166)
	if northern != null:
		_set_part(northern, 1, true)


func evaluate(world: WorldState) -> bool:
	if world == null or world.completed_event_ids.has("event_673"):
		return false
	var northern := world.get_country_by_legacy_index(166)
	if northern == null or northern.parts.size() == 0 or not northern.parts[0]:
		return false
	if northern.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST and northern.has_tag("亲中"):
		return false
	var ireland := world.get_country_by_legacy_index(29)
	if ireland == null or not world.is_socialism(ireland, false):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() > 167 and d.data_167 == 0:
		return true
	return world.date != null and world.date.to_int() >= 19850601


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_679_ireland_unity_war.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_679",
	"nodesc": true,
	"num": 679,
	"priority": 67900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_679_ireland_unity_war.gd",
	"trigger_script": "res://数据脚本/事件效果/event_679_ireland_unity_war.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
