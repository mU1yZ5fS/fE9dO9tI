extends "res://数据脚本/event_script_base.gd"

## 原作 Event85.cs：哈萨克斯坦的德意志族自治区（1979.6 后 且 苏 now_leader==0 且 result[84]==0 或 data.soviet_successor_route==2）。
## 触发：TimeScript.cs:10698。效果（Event85.cs ResultsOfEvents）：
##  - result0（煽动）：data.agents-=100、leaders[3](安德罗波夫).support-=1、data.party_support+=50、data.soviet_successor_route=3
##  - result1（预警）：苏关系>=500 → data.agents-=30、leaders[3].support-=1、data.soviet_successor_route=3；否则仅 data.agents-=30
##  - result2（留到将来）：无效果
## 选项条件：特工>=100 且（路线<3 且一党制<8，或多党联盟>66%）；选项1另需 relres 且（路线<4 且一党制<8，或多党联盟>66%）
const LDR_ANDROPOV := 3   # 苏 leaders[3] = 尤里·安德罗波夫


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = tr("event.script.event_085_kazakh_german.i0")
	if opt == 0:
		if d.size() > W.I_AGENTS:
			d.agents -= 100
		_leader_support(-1)
		if d.size() > W.I_PARTY_SUPPORT:
			d.party_support += 50
		if d.size() > 149:
			d.soviet_successor_route = 3
		context["result_text"] = tr("event.script.event_085_kazakh_german.i1")
	elif opt == 1:
		var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
		if d.size() > W.I_AGENTS:
			d.agents -= 30
		if ussr != null and ussr.relations >= 500:
			_leader_support(-1)
			if d.size() > 149:
				d.soviet_successor_route = 3
			context["result_text"] = tr("event.script.event_085_kazakh_german.i2")
		else:
			context["result_text"] = tr("event.script.event_085_kazakh_german.i3")
	elif opt == 2:
		context["result_text"] = tr("event.script.event_085_kazakh_german.i4")
	else:
		context["result_text"] = tr("event.script.event_085_kazakh_german.i5")


## 苏 leaders[3]（安德罗波夫）support 调整
func _leader_support(delta: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr: EmpireData = ws.empires[EmpireData.USSR]
		if LDR_ANDROPOV < ussr.leaders.size() and ussr.leaders[LDR_ANDROPOV] != null:
			ussr.leaders[LDR_ANDROPOV].support += delta



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_085_kazakh_german.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "kazakh_german",
	"num": 85,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1979.6.1"}, {"t": "EMPIRE_LEADER_IS", "key": "1"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_RESULT_IS", "ref": "old_partisan"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "old_partisan"}]}]}],
	"options": [{"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 100}, {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 3}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
