extends "res://数据脚本/event_script_base.gd"

## 原作 Event97.cs：自动化？（两选项）。 ## 触发：TimeScript.cs:10808-10814 —— science[17] && (data.econ_system==10 data.econ_system==11)。 ## 差异：doctr[10]/[11] 显示名（new_events_text[360/361]）Godot 建模说明，跳过。

const TXT_R0 := "event.script.event_097_automation.c0"

const TXT_R1 := "event.script.event_097_automation.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if d.size() > W.I_PARTY_SUPPORT:
				d.party_support = 0
			_add(W.I_BUDGET, -50)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 1000
				else:
					p.loyalty -= 500
			_set_modifier(11, true)
			# doctr[10]/[11] = new_events_text[360/361]：显示名建模说明，跳过 context["result_text"] = tr(TXT_R0) 1: context["result_text"] = tr(TXT_R1)




func _set_modifier(index: int, active: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_097_automation.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_097",
	"num": 97,
	"priority": 9700,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "TECH_UNLOCKED", "v": 17}, {"t": "ANY", "c": [{"t": "RESOURCE_EQUALS", "key": "economy_system", "v": 10}, {"t": "RESOURCE_EQUALS", "key": "economy_system", "v": 11}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
