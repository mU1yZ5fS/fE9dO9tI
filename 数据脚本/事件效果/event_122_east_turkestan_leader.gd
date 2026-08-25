extends "res://数据脚本/event_script_base.gd"

## 原作 Event122.cs：维吾尔领导人（3 选项）。
## 触发：由 Decision(GlobalScript.cs:23) 手动触发（维吾儿自治路线），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻选项显隐与结果效果。

const TXT_OPT0_DIS := "event.script.event_122_east_turkestan_leader.c0"
const TXT_OPT2_DIS := "event.script.event_122_east_turkestan_leader.c1"
const TXT_R0 := "event.script.event_122_east_turkestan_leader.c2"
const TXT_R1 := "event.script.event_122_east_turkestan_leader.c3"
const TXT_R2 := "event.script.event_122_east_turkestan_leader.c4"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var usa := world.get_country_by_legacy_index(51)
	var opt := event_def.options
	if world.get_flag("relres"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)
	if (usa != null and usa.has_tag("对华贸易")) or world.territory_policy >= 22:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))




func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var east_turkestan := ws.get_country_by_legacy_index(70)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if east_turkestan != null:
				east_turkestan.special_ending = 0
			_set_modifier_active(21, true)
			_add(W.I_ARMY, -50)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, 500)
			_add_power(EmpireData.USSR, 15)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -25)
			_add(W.I_BUDGET, -25)
			if east_turkestan != null:
				east_turkestan.special_ending = 1
			_set_modifier_active(22, true)
			_add_relation(EmpireData.USSR, -250)
			_add(W.I_INFLUENCE, 5)
			_add_power(EmpireData.USSR, -25)
			if d.religion_policy < 27:
				_add(W.I_RELIGION, 2)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_DIPLO, -50)
			_add(W.I_AGENTS, -25)
			_add(W.I_ARMY, -250)
			_add(W.I_INFLUENCE, 5)
			_add_relation(EmpireData.USA, 500)
			_add_power(EmpireData.USA, 50)
			if east_turkestan != null:
				east_turkestan.special_ending = 2
			_set_modifier_active(23, true)
			context["result_text"] = tr(TXT_R2)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_122_east_turkestan_leader.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_122",
	"num": 122,
	"priority": 12200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_122_east_turkestan_leader.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
