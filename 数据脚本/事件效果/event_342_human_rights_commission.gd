extends "res://数据脚本/event_script_base.gd"

## 原作 Event342.cs：人权委员会。触发：ReqEventForDLC02.cs:597-600 —— 日期>=1979.7.20。




const TXT_R0 := "event.script.event_342_human_rights_commission.c0"
const TXT_R1 := "event.script.event_342_human_rights_commission.c1"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, 150)
			_add_relation(0, -250)
			_add_relation(1, -300)
			_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, -50)
			_add_relation(0, 50)
			_add_relation(1, 50)
			_set_modifier_active(37)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_342_human_rights_commission.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_342",
	"num": 342,
	"priority": 34200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_342_human_rights_commission.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.7.20"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
