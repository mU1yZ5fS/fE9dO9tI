extends "res://数据脚本/event_script_base.gd"

## 原作 Event333.cs：外国企业。触发：ReqEventForDLC02.cs:572-575 —— SEZ 标记且日期>=1981.8.24。




const TXT_R0 := "event.script.event_333_foreign_enterprises.c0"
const TXT_R1 := "event.script.event_333_foreign_enterprises.c1"
const TXT_R2 := "event.script.event_333_foreign_enterprises.c2"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(0, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_LIVING, 50)
			_add_relation(0, -250)
			_add(W.I_DIPLO, 100)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, -100)
			_add_relation(0, 150)
			_add(W.I_BUDGET, 50)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_333_foreign_enterprises.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_333",
	"num": 333,
	"priority": 33300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_333_foreign_enterprises.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1981.8.24"}, {"t": "HAS_FLAG", "key": "sez"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
