extends "res://数据脚本/event_script_base.gd"

## 原作 Event300.cs：越南战争（边境冲突失败后，四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:447-449 ——
##   !event_done[300] && event_done[56] && resultOfEvents[56]==1 && war==1
##   && data.year>=1979 && data.month>=3；fire_only_once 承担 !event_done[300]。
## 差异：
##  - war→ws.war_state；isOVD/isSEV→set_tag("ovd"/"sev")；
##  - empires[1].relations=-250 按项目约定 clampi(…,0,1000) 处理；
##  - 死代码 result_num==5 跳过。

const TXT_OPT1_DIS := "event.script.event_300_vietnam_war.c0"
const TXT_OPT3_DIS := "event.script.event_300_vietnam_war.c1"
const TXT_R0 := "event.script.event_300_vietnam_war.c2"
const TXT_R1 := "event.script.event_300_vietnam_war.c3"
const TXT_R2 := "event.script.event_300_vietnam_war.c4"
const TXT_R3 := "event.script.event_300_vietnam_war.c5"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var vietnam := ws.get_country_by_legacy_index(11)
	var war1 := _get_war(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			ws.war_state = GameConstants.WarState.PEACE
			_set_data(W.I_WAR_PRESSURE, 5)
			if vietnam != null:
				vietnam.set_tag("ovd", true)
				vietnam.set_tag("sev", true)
			if war1 != null:
				war1.side1 = "柬埔寨"
				war1.name_war = "柬埔寨－越南战争"
		1:
			context["result_text"] = tr(TXT_R1)
			_add_relation(EmpireData.USSR, -200)
			ws.war_state = GameConstants.WarState.PEACE
			if vietnam != null:
				vietnam.set_tag("sev", true)
			if war1 != null:
				war1.side1 = "柬埔寨"
				war1.name_war = "柬埔寨－越南战争"
		2:
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)
			if war1 != null:
				war1.infl1 = 1000
				war1.infl2 = -1000
			if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
				ws.empires[EmpireData.USA].relations = 0
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				ws.empires[EmpireData.USSR].relations = clampi(-250, 0, 1000)
			_add(W.I_ARMY, -200)
			_add(W.I_WAR_SUPPORT, 50)
			_add(W.I_MANPOWER, -100)
			_add(W.I_DIPLO, 500)


func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)







# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_300_vietnam_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_300",
	"num": 300,
	"priority": 30000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_300_vietnam_war.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_056"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "event_056"}, {"t": "RESOURCE_EQUALS", "key": "war", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1979}, {"t": "RESOURCE_AT_LEAST", "key": "month", "v": 3}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "global_influence", "v": 500}, {"t": "RESOURCE_AT_LEAST", "key": "diplo", "v": 800}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "IS_FACTION_LEADER"}, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
