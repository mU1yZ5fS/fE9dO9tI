extends "res://数据脚本/event_script_base.gd"

## 原作 Event331.cs：“束手束脚”。触发：ReqEventForDLC02.cs:567-570 —— econ_system>12 且日期>=1984.10.27。




const TXT_R0 := "event.script.event_331_hands_tied.c0"
const TXT_R1 := "event.script.event_331_hands_tied.c1"
const TXT_R2 := "event.script.event_331_hands_tied.c2"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, -150)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_DIPLO, 100)
			_add(W.I_PARTY_SUPPORT, -250)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_ECON_SYSTEM, -1)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_DIPLO, -50)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, -250)
			_add_relation(0, 50)
			if d.size() > W.I_ECON_SYSTEM and d.econ_system < 15:
				_add(W.I_ECON_SYSTEM, 1)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_331_hands_tied.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_331",
	"num": 331,
	"priority": 33100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_331_hands_tied.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1984.10.27"}, {"t": "RESOURCE_AT_LEAST", "key": "economy_system", "v": 13}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
