extends "res://数据脚本/event_script_base.gd"

## 原作 Event436.cs：《苏联1977年宪法》（1977.10）。
## 触发：TimeScript.cs:10144-10150 —— (月>=10 且 年>=1977) 或 年>=1978。
## 文案：Events_text_en.txt 行 1656-1663。
## 差异：
##  - 共同效果（三个选项都执行）：苏联 leaders[2]（契尔年科）support +1
##    （Event436.cs ResultsOfEvents 开头，result_num 分支之外）。
##  - SOV_PRC_PartiesConnection 映射为 I_COMMUNICATIONS（见 event_435 注释）。

const TXT_R0 := "event.script.event_436_soviet_constitution.c0"

const TXT_R1 := "event.script.event_436_soviet_constitution.c1"

const TXT_R2 := "event.script.event_436_soviet_constitution.c2"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	# Event436.cs 共同效果：苏联 leaders[2]（契尔年科）support +1
	_ussr_leader_add(2, 1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# Event436.cs result 0（联络规模 +5 已改为 .tres 显式 ADD_RESOURCE）
			if d.size() > W.I_BUDGET:
				d.budget -= 5
			if d.size() > W.I_PEOPLE_SUPPORT:
				d.people_support += 25
			if d.size() > W.I_THOUGHT_FREEDOM:
				d.thought_freedom -= 25
			if d.size() > W.I_LIVING:
				d.living_standard += 25
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 100
				else:
					p.loyalty += 50
			context["result_text"] = tr(TXT_R0)
		1:
			# Event436.cs result 1（联络规模 -5 已改为 .tres 显式 ADD_RESOURCE）
			if d.size() > W.I_PARTY_SUPPORT:
				d.party_support += 50
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				ws.empires[EmpireData.USSR].relations = clampi(ws.empires[EmpireData.USSR].relations - 50, 0, 1000)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 100
					p.power += 25
				else:
					p.loyalty -= 50
			context["result_text"] = tr(TXT_R1)
		2:
			# Event436.cs result 2：无效果
			context["result_text"] = tr(TXT_R2)


func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_436_soviet_constitution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_436",
	"num": 436,
	"priority": 4360,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.10.1"}],
	"options": [{"fx": [{"t": "ADD_RESOURCE", "key": "communications", "v": 5}, {"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "ADD_RESOURCE", "key": "communications", "v": -5}, {"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
