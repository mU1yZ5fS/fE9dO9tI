extends "res://数据脚本/event_script_base.gd"

## 原作 Event395.cs：马蹄铁理论真的可行？（意大利极左极右合流，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DIS0A := "event.script.event_395_horseshoe_theory.c0"
const TXT_DIS0B := "event.script.event_395_horseshoe_theory.c1"
const TXT_DIS1A := "event.script.event_395_horseshoe_theory.c2"
const TXT_DIS1B := "event.script.event_395_horseshoe_theory.c3"
const TXT_R0 := "event.script.event_395_horseshoe_theory.c4"
const TXT_R1 := "event.script.event_395_horseshoe_theory.c5"
const TXT_R2 := "event.script.event_395_horseshoe_theory.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var italy := world.get_country_by_legacy_index(85)
	var opt := event_def.options
	var r391 := int(world.completed_event_ids.get("event_391", 0))
	if _d(W.I_WAR_SUPPORT) > 300 and _d(W.I_POLITICAL_LINE) <= 2 and _d(W.I_DIPLO) >= 900 			and (r391 == 0 or r391 == 2) and italy != null and italy.level_of_development < 50:
		_enable(opt[0], event_def.options[0].text)
	elif italy != null and italy.level_of_development >= 50:
		_disable(opt[0], tr(TXT_DIS0A))
	else:
		_disable(opt[0], tr(TXT_DIS0B))
	if _d(W.I_WAR_SUPPORT) > 300 and _d(W.I_POLITICAL_LINE) <= 2 and _d(W.I_DIPLO) >= 900 			and (r391 == 1 or r391 == 2) and italy != null and italy.level_of_development < 50:
		_enable(opt[1], event_def.options[1].text)
	elif italy != null and italy.level_of_development >= 50:
		_disable(opt[1], tr(TXT_DIS1A))
	else:
		_disable(opt[1], tr(TXT_DIS1B))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -100)
			if italy != null:
				italy.level_of_development -= 10
			_add(134, 40)  # 原版 data.italian_radical_left_power
			if italy != null:
				italy.set_tag("对华贸易", false)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -100)
			if italy != null:
				italy.level_of_development -= 10
			_add(134, 40)  # 原版 data.italian_radical_left_power
			if italy != null:
				italy.set_tag("对华贸易", false)
		_:
			context["result_text"] = tr(TXT_R2)
			_add(134, 0)  # 原版 data.italian_radical_left_power = 0
			if d.size() > 134:
				d.italian_radical_left_power = 0  # 原版 data.italian_radical_left_power
			if italy != null:
				italy.内战中 = false
				italy.政变中 = false




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_395_horseshoe_theory.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_395",
	"num": 395,
	"priority": 39500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_395_horseshoe_theory.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
