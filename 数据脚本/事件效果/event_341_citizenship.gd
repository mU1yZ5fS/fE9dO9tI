extends "res://数据脚本/event_script_base.gd"

## 原作 Event341.cs：公民权问题。触发：ReqEventForDLC02.cs:592-595 —— 日期>=1980.9.10。




const TXT_R0 := "event.script.event_341_citizenship.c0"
const TXT_R1 := "event.script.event_341_citizenship.c1"
const TXT_R2 := "event.script.event_341_citizenship.c2"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_MANPOWER, -150)
			_add(W.I_WAR_SUPPORT, 300)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PEOPLE_SUPPORT, 25)
			_add(W.I_MANPOWER, 25)
			_add(W.I_WAR_SUPPORT, -50)
			_add(W.I_POPULATION, 1)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_MANPOWER, 50)
			_add(W.I_WAR_SUPPORT, -150)
			_add(W.I_POPULATION, 5)
			_add_relation(0, -150)
			context["result_text"] = tr(TXT_R2)





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_341_citizenship.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_341",
	"num": 341,
	"priority": 34100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_341_citizenship.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1980.9.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
