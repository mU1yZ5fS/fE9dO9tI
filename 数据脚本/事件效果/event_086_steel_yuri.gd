extends "res://数据脚本/event_script_base.gd"

## 原作 Event86.cs："钢铁尤里"的终结（1979.7 后 且 苏 now_leader==0 且 result[85]==0 或 data.soviet_successor_route==3）。
## 触发：TimeScript.cs:10705。效果（Event86.cs ResultsOfEvents）：
##  - result0（推波助澜）：data.agents-=100、data.budget-=50、leaders[3](安德罗波夫).support=-100、leaders[1](谢尔比茨基).support+=10、data.party_support+=100
##  - result1（揭露材料）：苏关系>=400 → data.budget-=70、leaders[3].support=-100、leaders[1].support+=10；否则 data.budget-=70、leaders[3].support+=2
##  - result2（留到将来）：leaders[3].support+=2
## 选项条件：特工>=100 且（路线<3 且一党制<8，或多党联盟>66%）
const LDR_ANDROPOV := 3       # 苏 leaders[3] = 尤里·安德罗波夫
const LDR_SHCHERBITSKY := 1   # 苏 leaders[1] = 弗拉基米尔·谢尔比茨基


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	context["result_title"] = tr("event.script.event_086_steel_yuri.i0")
	if opt == 0:
		if d.size() > W.I_AGENTS:
			d.agents -= 100
		if d.size() > W.I_BUDGET:
			d.budget -= 50
		_leader_support(LDR_ANDROPOV, -100)
		_leader_support(LDR_SHCHERBITSKY, 10)
		if d.size() > W.I_PARTY_SUPPORT:
			d.party_support += 100
		context["result_text"] = tr("event.script.event_086_steel_yuri.i1")
	elif opt == 1:
		if d.size() > W.I_BUDGET:
			d.budget -= 70
		if ussr != null and ussr.relations >= 400:
			_leader_support(LDR_ANDROPOV, -100)
			_leader_support(LDR_SHCHERBITSKY, 10)
			context["result_text"] = tr("event.script.event_086_steel_yuri.i2")
		else:
			_leader_support(LDR_ANDROPOV, 2)
			context["result_text"] = tr("event.script.event_086_steel_yuri.i3")
	elif opt == 2:
		_leader_support(LDR_ANDROPOV, 2)
		context["result_text"] = tr("event.script.event_086_steel_yuri.i4")
	else:
		context["result_text"] = tr("event.script.event_086_steel_yuri.i5")


## 苏领导人 support 调整（越界安全）
func _leader_support(idx: int, delta: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr: EmpireData = ws.empires[EmpireData.USSR]
		if idx >= 0 and idx < ussr.leaders.size() and ussr.leaders[idx] != null:
			ussr.leaders[idx].support += delta



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_086_steel_yuri.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "steel_yuri",
	"num": 86,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1979.7.1"}, {"t": "EMPIRE_LEADER_IS", "key": "1"}, {"t": "ANY", "c": [{"t": "PREV_EVENT_RESULT_IS", "ref": "kazakh_german"}, {"t": "RESOURCE_EQUALS", "key": "data_149", "v": 3}]}]}],
	"options": [{"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 100}, {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "HAS_FLAG", "key": "relres"}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
