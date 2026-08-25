extends "res://数据脚本/event_script_base.gd"

## 原作 Event340.cs：地方自治。原版无自动条件（决策/其他事件链手动触发）。




const TXT_R0 := "event.script.event_340_local_autonomy.c0"
const TXT_R1 := "event.script.event_340_local_autonomy.c1"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_THOUGHT_FREEDOM, 30)
			_add(W.I_AGRICULTURE, -30)
			context["result_text"] = tr(TXT_R0)
		1:
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_340_local_autonomy.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_340",
	"num": 340,
	"priority": 34000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_340_local_autonomy.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
