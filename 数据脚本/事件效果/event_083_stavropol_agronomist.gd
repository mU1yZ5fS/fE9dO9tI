extends "res://数据脚本/event_script_base.gd"

## 原作 Event83.cs：斯塔夫罗波尔农学家的问题（1977.7.4 后，中苏关系链开端）。
## 触发：TimeScript.cs:10712（1977.7.4 后，fire_only_once）。
## 效果（Event83.cs ResultsOfEvents）：
##  - result0（泄露情报）：data.party_support+=50 党内支持、data.agents-=50 特工、苏 leaders[3](安德罗波夫).support-=1、data.soviet_successor_route=1
##  - result1（媒体揭露）：苏关系>=500 → 同上（data.budget-=20 预算 而非特工）；否则仅 data.budget-=20
##  - result2（留到将来）：无效果
## 选项条件：
##  - 选项0：特工>=50 且（路线<4 且 一党制<8，或多党联盟支持率>66%）
##  - 选项1：（路线<3 且 一党制<8，或多党联盟支持率>66%）
## 差异：summa_3_2（Awake 执政联盟支持率）→ 本地辅助 _coalition_pct（对齐 EventEngine._coalition_support_percent）
const LDR_ANDROPOV := 3   # 苏 leaders[3] = 尤里·安德罗波夫


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = tr("event.script.event_083_stavropol_agronomist.i0")
	if opt == 0:
		if d.size() > W.I_PARTY_SUPPORT:
			d.party_support += 50
		if d.size() > W.I_AGENTS:
			d.agents -= 50
		_leader_support(-1)
		if d.size() > 149:
			d.soviet_successor_route = 1   # 原 data.soviet_successor_route（中苏关系路线，无端口命名键）
		context["result_text"] = tr("event.script.event_083_stavropol_agronomist.i1")
	elif opt == 1:
		var ussr: EmpireData = ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
		if ussr != null and ussr.relations >= 500:
			if d.size() > W.I_PARTY_SUPPORT:
				d.party_support += 50
			if d.size() > W.I_BUDGET:
				d.budget -= 20
			_leader_support(-1)
			if d.size() > 149:
				d.soviet_successor_route = 1
			context["result_text"] = tr("event.script.event_083_stavropol_agronomist.i2")
		else:
			if d.size() > W.I_BUDGET:
				d.budget -= 20
			context["result_text"] = tr("event.script.event_083_stavropol_agronomist.i3")
	elif opt == 2:
		context["result_text"] = tr("event.script.event_083_stavropol_agronomist.i4")
	else:
		context["result_text"] = tr("event.script.event_083_stavropol_agronomist.i5")


## 苏 leaders[3]（安德罗波夫）support -1（Event83.cs result 0/1 共同效果）
func _leader_support(_unused: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr: EmpireData = ws.empires[EmpireData.USSR]
		if LDR_ANDROPOV < ussr.leaders.size() and ussr.leaders[LDR_ANDROPOV] != null:
			ussr.leaders[LDR_ANDROPOV].support -= 1



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_083_stavropol_agronomist.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "stavropol_agronomist",
	"num": 83,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.7.4"}],
	"options": [{"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}, {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 3}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
