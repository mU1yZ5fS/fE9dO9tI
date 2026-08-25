extends "res://数据脚本/event_script_base.gd"

## 原作 Event348.cs：地下城市。选项0原版按 budget+reserve>=80 且 industry>=500 动态启用/销毁。原版无自动条件（决策/其他事件链手动触发）。




const TXT_R0 := "event.script.event_348_underground_city.c0"
const TXT_R1 := "event.script.event_348_underground_city.c1"
const TXT_R2 := "event.script.event_348_underground_city.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _dyn_ok(world):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], "没有这么做的资源。")


func _dyn_ok(w: WorldState) -> bool:
	@warning_ignore("shadowed_variable_base_class")
	var d := w
	return d.size() > W.I_BUDGET and d.size() > W.I_RESERVE and d.size() > W.I_INDUSTRY and d.budget + d.reserve >= 80 and d.industry >= 500

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -70)
			_add(W.I_ARMY, 100)
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_THOUGHT_FREEDOM, 10)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_348_underground_city.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_348",
	"num": 348,
	"priority": 34800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_348_underground_city.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
