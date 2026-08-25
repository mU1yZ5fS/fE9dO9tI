extends "res://数据脚本/event_script_base.gd"

## 原作 Event344.cs：兵役制度。触发：ReqEventForDLC02.cs:602-605 —— 日期>=1984.5.5。




const TXT_R0 := "event.script.event_344_conscription_system.c0"
const TXT_R1 := "event.script.event_344_conscription_system.c1"
const TXT_R2 := "event.script.event_344_conscription_system.c2"
const TXT_R3 := "event.script.event_344_conscription_system.c3"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_set_data(W.I_MIL_DOCTRINE, 33)
			_add(W.I_PARTY_SUPPORT, -150)
			_add(W.I_BUDGET, -50)
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_ARMY, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_set_data(W.I_MIL_DOCTRINE, 32)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_BUDGET, -20)
			_add(W.I_PEOPLE_SUPPORT, -25)
			_add(W.I_ARMY, 50)
			context["result_text"] = tr(TXT_R1)
		2:
			_set_data(W.I_MIL_DOCTRINE, 31)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_BUDGET, -5)
			_add(W.I_PEOPLE_SUPPORT, -50)
			_add(W.I_ARMY, 50)
			context["result_text"] = tr(TXT_R2)
		3:
			_set_data(W.I_MIL_DOCTRINE, 30)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, -75)
			_add(W.I_ARMY, 50)
			context["result_text"] = tr(TXT_R3)





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_344_conscription_system.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_344",
	"num": 344,
	"priority": 34400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_344_conscription_system.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1984.5.5"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
