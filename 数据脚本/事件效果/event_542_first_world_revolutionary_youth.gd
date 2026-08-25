extends "res://数据脚本/event_script_base.gd"

## 原作 Event542.cs：第一届世界革命青年与学生联欢会（1选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:207-209 ——
##   event_done[541] && resultOfEvents[541]==1 && modifies[3].active && (1985.5.4 或 1986+)。
## 差异：描述/结果由 prepare/execute 动态拼领袖姓名与总理姓名。

const TXT_DESC := "event.script.event_542_first_world_revolutionary_youth.c0"
const TXT_R0_A := "event.script.event_542_first_world_revolutionary_youth.c1"
const TXT_R0_PM := "event.script.event_542_first_world_revolutionary_youth.c2"
const TXT_R0_SPEECH := "event.script.first_world_revolutionary_youth.txt_r0_speech"
const TXT_R0_ZA := "event.script.first_world_revolutionary_youth.txt_r0_za"
const TXT_R0_OTHER := "event.script.first_world_revolutionary_youth.txt_r0_other"
const TXT_R0_CLOSE := "event.script.event_542_first_world_revolutionary_youth.c3"
const TXT_R0_CLOSE_TAIL := "event.script.event_542_first_world_revolutionary_youth.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	event_def.description = _leader_name() + tr(TXT_DESC)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c131 := ws.get_country_by_legacy_index(131)
	var text := tr(TXT_R0_A) + _leader_name()
	var pm := _prime_minister_name()
	text += tr(TXT_R0_PM) + pm + tr(TXT_R0_SPEECH)
	if c131 != null and (c131.sub_government == GameConstants.SubGovernment.NEO_FASCIST or c131.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN):
		text += tr(TXT_R0_ZA)
	else:
		text += tr(TXT_R0_OTHER)
	text += tr(TXT_R0_CLOSE) + _leader_name() + tr(TXT_R0_CLOSE_TAIL)
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_DIPLO, 50)
	_add(W.I_BUDGET, -150)
	_add_relation(EmpireData.USSR, -100)
	_add_relation(EmpireData.USA, -100)
	ws.influence_prc += 50
	context["result_text"] = text


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _prime_minister_name() -> String:
	if ws.politics_positions.size() > 0:
		var idx := ws.politics_positions[0]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null:
			var p := ws.politicians[idx]
			if p.name_display != "":
				return p.name_display
	return _leader_name()



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_542_first_world_revolutionary_youth.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_542",
	"nodesc": true,
	"num": 542,
	"priority": 54200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_542_first_world_revolutionary_youth.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_541"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "event_541"}, {"t": "MODIFIER_ACTIVE", "key": "3"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1985.5.4"}, {"t": "DATE_AFTER", "key": "1985.6.1"}, {"t": "DATE_AFTER", "key": "1986.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
