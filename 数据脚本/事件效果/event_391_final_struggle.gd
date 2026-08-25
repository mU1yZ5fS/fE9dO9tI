extends "res://数据脚本/event_script_base.gd"

## 原作 Event391.cs：最后斗争（意大利极左极右，五选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 描述按 resultOfEvents[291] 动态拼接；
##  - data.italy_power_172-data.short_sword_power 为原版原始下标，端口无 W.I_ 常量，raw index 直访。

const TXT_DESC1 := "event.script.event_391_final_struggle.c0"
const TXT_DESC2 := "event.script.event_391_final_struggle.c1"
const TXT_DESC3 := "event.script.event_391_final_struggle.c2"
const TXT_DIS0 := "event.script.event_391_final_struggle.c3"
const TXT_DIS1 := "event.script.event_391_final_struggle.c4"
const TXT_DIS2 := "event.script.event_391_final_struggle.c5"
const TXT_R0 := "event.script.event_391_final_struggle.c6"
const TXT_R1 := "event.script.event_391_final_struggle.c7"
const TXT_R2 := "event.script.event_391_final_struggle.c8"
const TXT_R3 := "event.script.event_391_final_struggle.c9"
const TXT_R4 := "event.script.event_391_final_struggle.c10"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	event_def.description = tr(TXT_DESC1)
	if int(world.completed_event_ids.get("event_291", 0)) != 0:
		event_def.description += tr(TXT_DESC2)
	event_def.description += tr(TXT_DESC3)
	var opt := event_def.options
	if _d(W.I_DIPLO) >= 900 and _d(W.I_WAR_SUPPORT) > 300 and _d(W.I_POLITICAL_LINE) <= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_DIS0))
	if _d(W.I_DIPLO) >= 800 and _d(W.I_POLITICAL_LINE) <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_DIS1))
	if _d(W.I_DIPLO) >= 900 and _d(W.I_WAR_SUPPORT) > 300 and _d(W.I_POLITICAL_LINE) <= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_DIS2))
	_enable(opt[3], event_def.options[3].text)
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if italy != null:
				italy.政变中 = true
			_add(W.I_BUDGET, -20)
			_add(W.I_AGENTS, -40)
			_add(W.I_ARMY, -40)
			_add(172, -1)  # 原版 data.italy_power_172
			_add(175, 1)   # 原版 data.italy_power_175
			_add(177, 1)   # 原版 data.italy_power_177
			_add(182, 1)   # 原版 data.short_sword_power
			if italy != null and italy.内战中:
				_add(175, -1)  # 原版 data.italy_power_175
				_add(177, 1)  # 原版 data.italy_power_177
				italy.level_of_development -= 10
				_add(134, 10)  # 原版 data.italian_radical_left_power
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
		1:
			context["result_text"] = tr(TXT_R1)
			if italy != null:
				italy.政变中 = true
			_add(W.I_BUDGET, -20)
			_add(W.I_AGENTS, -40)
			_add(W.I_ARMY, -40)
			_add(172, -1)  # 原版 data.italy_power_172
			_add(176, 2)   # 原版 data.italy_power_176
			_add(182, 1)  # 原版 data.short_sword_power
			if italy != null and italy.内战中:
				_add(175, -1)  # 原版 data.italy_power_175
				_add(177, 1)  # 原版 data.italy_power_177
				italy.level_of_development -= 10
				_add(134, 10)  # 原版 data.italian_radical_left_power
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
		2:
			context["result_text"] = tr(TXT_R2)
			if italy != null:
				italy.政变中 = true
			_add(W.I_BUDGET, -40)
			_add(W.I_AGENTS, -80)
			_add(W.I_ARMY, -80)
			_add(172, -1)  # 原版 data.italy_power_172
			_add(182, 2)  # 原版 data.short_sword_power
			if italy != null and italy.内战中:
				italy.level_of_development -= 20
				_add(134, 40)  # 原版 data.italian_radical_left_power
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
		3:
			context["result_text"] = tr(TXT_R3)
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, 50)
			_add(W.I_INDUSTRY, 30)
			_add(W.I_AGRICULTURE, 20)
			_add(W.I_CORRUPTION, 10)
			_add(W.I_SERVICES, 10)
			_add(172, -999)  # 原版 data.italy_power_172
			_add(173, -1)    # 原版 data.italy_power_173
			if italy != null:
				italy.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, 50)
		_:
			context["result_text"] = tr(TXT_R4)




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0








# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_391_final_struggle.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_391",
	"num": 391,
	"priority": 39100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_391_final_struggle.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
