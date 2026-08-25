extends "res://数据脚本/event_script_base.gd"

## 原作 Event339.cs：海外同胞。触发：ReqEventForDLC02.cs:587-590 —— 日期>=1983.12.30。




const TXT_R0 := "event.script.event_339_overseas_compatriots.c0"
const TXT_R1 := "event.script.event_339_overseas_compatriots.c1"
const TXT_R2 := "event.script.event_339_overseas_compatriots.c2"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_DIPLO, 15)
			_add(W.I_THOUGHT_FREEDOM, 15)
			_add(W.I_POPULATION, 3)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_SCIENCE, 250)
			_add(W.I_BUDGET, -100)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_POPULATION, 44)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_339_overseas_compatriots.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_339",
	"num": 339,
	"priority": 33900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_339_overseas_compatriots.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.12.30"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
