extends "res://数据脚本/event_script_base.gd"

## 原作 Event559.cs：摩洛哥的柏林墙（西撒哈拉，3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:397-399 —— (1980.8.15 或 1980.9 或 1981+)。
## 差异：描述/结果由 prepare/execute 动态拼领袖姓名；cw→内战中。

const TXT_DESC_A := "event.script.event_559_morocco_berlin_wall.c0"
const TXT_DESC_B := "event.script.event_559_morocco_berlin_wall.c1"
const TXT_OPT0_DIS := "event.script.event_559_morocco_berlin_wall.c2"
const TXT_R0_A := "event.script.event_559_morocco_berlin_wall.c3"
const TXT_R0_B := "event.script.event_559_morocco_berlin_wall.c4"
const TXT_R0_C := "event.script.morocco_berlin_wall.txt_r0_c"
const TXT_R1 := "event.script.event_559_morocco_berlin_wall.c5"
const TXT_R1_TAIL := "event.script.morocco_berlin_wall.txt_r1_tail"
const TXT_R2 := "event.script.event_559_morocco_berlin_wall.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var n := _leader_name()
	event_def.description = n + tr(TXT_DESC_A) + n + tr(TXT_DESC_B)
	if event_def.options.size() < 3:
		return
	if d.political_line <= 1:
		_enable(event_def.options[0], event_def.options[0].text)
	else:
		_disable(event_def.options[0], tr(TXT_OPT0_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c18 := ws.get_country_by_legacy_index(18)
	var c54 := ws.get_country_by_legacy_index(54)
	var n := _leader_name()
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if c18 != null:
				c18.内战中 = true
			if c54 != null:
				c54.set_tag("对华贸易", false)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_ARMY, -50)
			context["result_text"] = tr(TXT_R0_A) + n + tr(TXT_R0_B) + n + tr(TXT_R0_C)
		1:
			if c54 != null:
				c54.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			_add(W.I_DIPLO, 50)
			context["result_text"] = tr(TXT_R1) + n + tr(TXT_R1_TAIL)
		2:
			context["result_text"] = tr(TXT_R2)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_559_morocco_berlin_wall.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_559",
	"nodesc": true,
	"num": 559,
	"priority": 55900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_559_morocco_berlin_wall.gd",
	"trigger": [{"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1980.8.15"}, {"t": "DATE_AFTER", "key": "1980.9.1"}, {"t": "DATE_AFTER", "key": "1981.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
