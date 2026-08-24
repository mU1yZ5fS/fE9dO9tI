extends "res://数据脚本/event_script_base.gd"

## 原作 Event334.cs：专利法。触发：ReqEventForDLC02.cs:577-580 —— econ_system>12 且日期>=1984.2.11。




const TXT_R0 := "event.script.event_334_patent_law.c0"
const TXT_R1 := "event.script.event_334_patent_law.c1"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add_relation(0, -150)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -150)
			_add_relation(0, 150)
			_add(W.I_DIPLO, -50)
			_set_modifier_active(36)
			_add(W.I_SCIENCE, 50)
			context["result_text"] = tr(TXT_R1)





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_334_patent_law.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_334",
	"num": 334,
	"priority": 33400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_334_patent_law.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1984.2.11"}, {"t": "RESOURCE_AT_LEAST", "key": "economy_system", "v": 13}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
