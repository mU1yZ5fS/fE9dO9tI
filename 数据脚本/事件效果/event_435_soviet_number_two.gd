extends "res://数据脚本/event_script_base.gd"

## 原作 Event435.cs：苏维埃的二号人物（反波德戈尔内行动，1977.1）。
## 触发：TimeScript.cs:10138-10143 —— (月>=1 且 年>=1977) 或 年>=1978。
## 文案：Events_text_en.txt 行 1647-1655（new_events_text[]，0 基索引）。
## 差异：
##  - 选项0（1649 散布情报）原版按 data.agents>=10 且 data.budget+data.reserve>=50 显隐按钮，
##    本版用 EventOption.enable_condition + disabled_text（1649/1652）等价建模。
##  - SOV_PRC_PartiesConnection 映射为 I_COMMUNICATIONS（data.communications）：
##    原版 GameStartScript.cs:947 初始化即 `SOV_PRC_PartiesConnection = data.communications`，
##    Godot 外交面板已按 data.communications 建模（国家面板.gd:576-578）。
##  - 苏联领导人索引沿用 world_factory.gd:1162 注释的 USSR leaders 槽位。

const TXT_R0 := "event.script.event_435_soviet_number_two.c0"

const TXT_R1 := "event.script.event_435_soviet_number_two.c1"

const TXT_R2 := "event.script.event_435_soviet_number_two.c2"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# Event435.cs result 0
			_ussr_leader_add(6, -1)
			_ussr_leader_add(4, -1)
			_ussr_leader_add(1, -1)
			_ussr_leader_add(3, -2)
			if d.size() > W.I_BUDGET:
				d.budget -= 50
			if d.size() > W.I_AGENTS:
				d.agents -= 100
			context["result_text"] = tr(TXT_R0)
		1:
			# Event435.cs result 1
			# 原版 SOV_PRC_PartiesConnection += 5（显示 +0.5）。.tres 已通过 ADD_RESOURCE 改 data.communications（I_COMMUNICATIONS），
			# 数据源已统一为 data.communications，无需再同步镜像字段。
			_ussr_leader_add(3, 1)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				ws.empires[EmpireData.USSR].relations = clampi(ws.empires[EmpireData.USSR].relations + 50, 0, 1000)
			context["result_text"] = tr(TXT_R1)
		2:
			# Event435.cs result 2：无效果
			context["result_text"] = tr(TXT_R2)


func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_435_soviet_number_two.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_435",
	"num": 435,
	"priority": 4350,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.1.1"}],
	"options": [{"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 10}, {"t": "RESOURCE_SUM_AT_LEAST", "v": 50, "keys": ["budget", "money_reserve"]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "ADD_RESOURCE", "key": "communications", "v": 5}, {"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
