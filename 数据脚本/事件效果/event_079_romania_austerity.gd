extends "res://数据脚本/event_script_base.gd"

## 原作 Event79.cs：紧缩政策（罗马尼亚债务危机，五选项）。
## 触发：TimeScript.cs:10620-10626 —— data.year>=1982。
## 差异：
##  - 选项显隐 prepare 动态改写（原版 SetActive(false) 等价）。
##  - science[16]/science[25] → ws.techs.unlocked 下标（tech_state.gd）。
##  - OilProd 已建模（ws.oil_prod），result0 炼油技术转让 +100。
##  - result2：原版 ResultsOfEvents 没有 result_num==2 分支（可点但无文案无效果），
##    逐字保留该行为（result_text 空串）。

const TXT_R0 := "event.script.event_079_romania_austerity.c0"

const TXT_R1 := "event.script.event_079_romania_austerity.c1"

const TXT_R2 := "event.script.event_079_romania_austerity.c2"

const TXT_R3 := "event.script.event_079_romania_austerity.c3"

const TXT_R4 := "event.script.event_079_romania_austerity.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else GameConstants.PartySystem.PEOPLE_DEMOCRACY
	var coal := _coalition_percent(world)
	var policy_left := (line < 3 and party < GameConstants.PartySystem.PEOPLE_DEMOCRACY) or (coal > 66 and party > GameConstants.PartySystem.NEW_DEMOCRACY)
	var china := world.get_country_by_legacy_index(1)
	var done503: bool = world.completed_event_ids.has("event_503")
	var result503: int = world.completed_event_ids.get("event_503", -1)
	var opt := event_def.options
	if policy_left:
		_enable(opt[0], "向我们的老朋友提供援助，这是国际主义精神！")
	else:
		_disable(opt[0], "罗马尼亚不值得我们做这么多")
	if policy_left and world.influence_prc >= 400 and _tech(world, 16):
		_enable(opt[1], "向我们的老朋友提供援助的同时，建议齐奥塞斯库同志适当改变政策，用科技革命为罗马尼亚经济注入新动力")
	else:
		_disable(opt[1], "没有必要这么做")
	if world.influence_prc >= 300 and china != null and china.has_tag("sev"):
		_enable(opt[2], "我们将发扬社会主义大家庭的团结精神，号召社会主义阵营共同帮助罗马尼亚")
	else:
		_disable(opt[2], "社会主义阵营不会听我们的")
	if world.influence_prc >= 500 and _tech(world, 25) and (not done503 or result503 != 0):
		_enable(opt[3], "不能让齐奥塞斯库胡作非为下去了，开始联系罗马尼亚党内异见分子")
	else:
		_disable(opt[3], "我们不能这么对待好朋友！")
	_enable(opt[4], "让他独立自主地还债，这不是我们的问题")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var romania := ws.get_country_by_legacy_index(5)
	var opt := int(context.get("option_index", -1))
	var leader_name := _leader_name()
	match opt:
		0:
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USSR, -50)
			_add(W.I_BUDGET, -300)
			ws.influence_prc += 10
			if romania != null:
				romania.set_tag("对华贸易", true)
				romania.set_tag("亲中", true)
				romania.government = GameConstants.Government.AUTHORITARIAN
				romania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_add(W.I_SCIENCE, 200)
			ws.oil_prod += 100.0  # Event79.cs result0：炼油技术转让
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -150)
			_add_power(EmpireData.USSR, 30)
			ws.influence_prc += 30
			if romania != null:
				romania.set_tag("对华贸易", true)
			_add(W.I_SCIENCE, 200)
			_ussr_leader_add(4, 1)
			context["result_text"] = tr(TXT_R1).replace("{0}{1}", leader_name)
		2:
			# 原版 Event79.cs result2：号召经互会共同援助罗马尼亚（含文案与效果）。
			_add(W.I_BUDGET, -150)
			_add_power(EmpireData.USSR, 30)
			ws.influence_prc += 30
			if romania != null:
				romania.set_tag("对华贸易", true)
			_add(W.I_SCIENCE, 200)
			_ussr_leader_add(4, 1)
			context["result_text"] = tr(TXT_R2).replace("{0}{1}", leader_name)
		3:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			if romania != null:
				romania.government = GameConstants.Government.AUTHORITARIAN
				romania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = tr(TXT_R3)
		4:
			if romania != null:
				romania.government = GameConstants.Government.AUTHORITARIAN
				romania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = tr(TXT_R4)


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= GameConstants.PartySystem.NEW_DEMOCRACY:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total


func _tech(world: WorldState, index: int) -> bool:
	return world.techs != null and world.techs.unlocked.size() > index and world.techs.unlocked[index]




func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_079_romania_austerity.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_079",
	"num": 79,
	"priority": 7900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_079_romania_austerity.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1982.1.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
