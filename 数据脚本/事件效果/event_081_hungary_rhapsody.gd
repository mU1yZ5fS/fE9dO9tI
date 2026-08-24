extends "res://数据脚本/event_script_base.gd"

## 原作 Event81.cs：匈牙利狂想曲（匈牙利债务危机，五选项）。 ## 触发：TimeScript.cs:10668-10674 —— ##   (月>=4 且 年>=1982 或 年>=1983) && c4.Gosstroy==2 && (c20.proprc relres)。 ##   relres → Godot global flag "relres"（game_manager.gd:2912）。 ## 差异：选项显隐 prepare 动态改写；result3 文本插领导人姓名（原版 names1+" "+names2）。

const TXT_R0 := "event.script.event_081_hungary_rhapsody.c0"

const TXT_R1 := "event.script.event_081_hungary_rhapsody.c1"

const TXT_R2 := "event.script.event_081_hungary_rhapsody.c2"

const TXT_R3_A := "event.script.event_081_hungary_rhapsody.c3"

const TXT_R4 := "event.script.event_081_hungary_rhapsody.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var stage := data.reform_stage if data.size() > W.I_REFORM_STAGE else -1
	var coal := _coalition_percent(world)
	var left_party := party < 8
	var left_line := line < 3
	var opt := event_def.options
	if ((line == 0 or line == 4) and left_party) or (coal > 66 and party > 7):
		_enable(opt[0], "我们将无条件向匈牙利提供经济援助（需要35百万元预算）")
	else:
		_disable(opt[0], "我们没有足够的钱资助卡达尔主义者")
	if stage == 0 and ((left_line and left_party) or (coal > 66 and party > 7)):
		_enable(opt[1], "我们利用匈牙利人民共和国的问题来诋毁市场改革")
	else:
		_disable(opt[1], "匈牙利的例子并不能证明一切改革的失败")
	if (line < 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[2], "我们将向匈牙利提供经济援助，但交换条件是平反比斯库集团（需要15百万元预算，8特工网络）")
	else:
		_disable(opt[2], "对我们来说不是很好")
	if (line <= 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[3], "我们将完全承担匈牙利国债，但交换条件是完全平反比斯库集团（需要45百万元预算，10特工）")
	else:
		_disable(opt[3], "对我们来说太激进了！")
	_enable(opt[4], "无视它")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var hungary := ws.get_country_by_legacy_index(4)
	match opt:
		0:
			_add(W.I_BUDGET, -300)
			_add(W.I_DIPLO, -10)
			_add_power(EmpireData.USA, -10)
			_add_relation(EmpireData.USSR, -100)
			_add_relation(EmpireData.USA, -80)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_THOUGHT_FREEDOM, -20)
			_add(W.I_PEOPLE_SUPPORT, -50)
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USA, -30)
			_add_relation(EmpireData.USSR, -80)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -80)
			ws.influence_prc += 10
			_add_relation(EmpireData.USSR, -100)
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_BUDGET, -450)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -100)
			_ussr_leader_add(6, -1)
			_add_relation(EmpireData.USSR, -200)
			if hungary != null:
				hungary.set_tag("亲苏", false)
				hungary.set_tag("对华贸易", true)
			context["result_text"] = _leader_name() + tr(TXT_R3_A)
		4:
			_add_power(EmpireData.USA, 10)
			_add_power(EmpireData.USSR, -10)
			context["result_text"] = tr(TXT_R4)


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
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



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_081_hungary_rhapsody.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_081",
	"num": 81,
	"priority": 8100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_081_hungary_rhapsody.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1982.4.1"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 2, "target": "4"}, {"t": "ANY", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "20"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
