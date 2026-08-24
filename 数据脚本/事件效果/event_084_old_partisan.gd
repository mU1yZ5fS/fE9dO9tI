extends "res://数据脚本/event_script_base.gd"

## 原作 Event84.cs：我们的老游击队员…（1978.10.4 后 且 苏 now_leader==0 勃列日涅夫 且 result[83]==0 或 data.soviet_successor_route==1）。
## 触发：TimeScript.cs:10691。效果（Event84.cs ResultsOfEvents）：
##  - result0（散布谣言）：data.agents-=80、苏 leaders[3](安德罗波夫).support-=2、data.soviet_successor_route=2
##  - result1（黑料）：苏关系>=500 → data.budget-=50、leaders[3].support-=1、data.soviet_successor_route=2；否则仅 data.budget-=50
##  - result2（留到将来）：无效果
## 选项条件：特工>=80 且（路线<3 且 一党制<8，或多党联盟>66%）
const LDR_ANDROPOV := 3   # 苏 leaders[3] = 尤里·安德罗波夫


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = tr("event.script.event_084_old_partisan.i0")
	if opt == 0:
		if d.size() > W.I_AGENTS:
			d.agents -= 80
		_leader_support(-2)
		if d.size() > 149:
			d.soviet_successor_route = 2
		context["result_text"] = tr("event.script.event_084_old_partisan.i1")
	elif opt == 1:
		var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
		if d.size() > W.I_BUDGET:
			d.budget -= 50
		if ussr != null and ussr.relations >= 500:
			_leader_support(-1)
			if d.size() > 149:
				d.soviet_successor_route = 2
			context["result_text"] = tr("event.script.event_084_old_partisan.i2")
		else:
			context["result_text"] = tr("event.script.event_084_old_partisan.i3")
	elif opt == 2:
		context["result_text"] = tr("event.script.event_084_old_partisan.i4")
	else:
		context["result_text"] = tr("event.script.event_084_old_partisan.i5")


## 苏 leaders[3]（安德罗波夫）support 调整
func _leader_support(delta: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr: EmpireData = ws.empires[EmpireData.USSR]
		if LDR_ANDROPOV < ussr.leaders.size() and ussr.leaders[LDR_ANDROPOV] != null:
			ussr.leaders[LDR_ANDROPOV].support += delta



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_084_old_partisan.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "old_partisan",
	"num": 84,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1978.10.4"}, {"t": "EMPIRE_LEADER_IS", "key": "1"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_RESULT_IS", "ref": "stavropol_agronomist"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "stavropol_agronomist"}]}]}],
	"options": [{"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 80}, {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
