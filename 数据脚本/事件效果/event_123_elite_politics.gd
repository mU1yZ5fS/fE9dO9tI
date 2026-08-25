extends "res://数据脚本/event_script_base.gd"

## 原作 Event123.cs：精英政治（4 选项）。
## 触发：由 Decision(GlobalScript.cs:25) 手动触发（精英政治），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻结果效果。

const TXT_R0 := "event.script.event_123_elite_politics.c0"
const TXT_R1 := "event.script.event_123_elite_politics.c1"
const TXT_R2 := "event.script.event_123_elite_politics.c2"
const TXT_R3 := "event.script.event_123_elite_politics.c3"



func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_set_modifier_active(24, true)
			_add(W.I_AGENTS, -50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PARTY_SUPPORT, -250)
			_add(W.I_THOUGHT_FREEDOM, -25)
			_set_modifier_active(25, true)
			_add(W.I_INFLUENCE, -5)
			_add_power(EmpireData.USSR, -25)
			if d.religion_policy < 28:
				d.religion_policy = 28
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, -250)
			_add(W.I_THOUGHT_FREEDOM, -25)
			_set_modifier_active(26, true)
			if d.press_policy < 16:
				d.press_policy = 16
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_PARTY_SUPPORT, -250)
			_add(W.I_PEOPLE_SUPPORT, -250)
			_add(W.I_ARMY, 250)
			_add(W.I_INFLUENCE, 5)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, -250)
			_set_modifier_active(27, true)
			context["result_text"] = tr(TXT_R3)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_123_elite_politics.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_123",
	"num": 123,
	"priority": 12300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_123_elite_politics.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
