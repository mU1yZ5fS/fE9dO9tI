extends "res://数据脚本/event_script_base.gd"

## 原作 Event350.cs：劫持米格-25。选项0原版按 agents>=50 动态启用/销毁。触发：ReqEventForDLC02.cs:622-625 —— 日期>=1979.6.9。




const TXT_R0 := "event.script.event_350_mig25_hijack.c0"
const TXT_R1 := "event.script.event_350_mig25_hijack.c1"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	if _dyn_ok(world):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], "我们扎得不够深。")


func _dyn_ok(w: WorldState) -> bool:
	@warning_ignore("shadowed_variable_base_class")
	var d := w
	return d.size() > W.I_AGENTS and d.agents >= 50

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			_add_relation(1, -200)
			if not ws.techs.unlocked[18]:
				ws.techs.unlocked[18] = true
			elif not ws.techs.unlocked[23]:
				ws.techs.unlocked[23] = true
			else:
				_add(W.I_ARMY, 100)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_350_mig25_hijack.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_350",
	"num": 350,
	"priority": 35000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_350_mig25_hijack.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.6.9"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
