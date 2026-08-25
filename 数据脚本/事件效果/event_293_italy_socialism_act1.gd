## 原作 Event293.cs：和平长入社会主义：第一幕（意大利共产党上台，五选项）。
## 触发：全目录搜索无 this_num_event = 293 / Reset(293)；链外 REST 段，原版无自动条件。
## 差异：result0/1 的 {0}{1} 插入领袖姓名（name_display）；science[19]→techs.unlocked[19]；
##  is_party_enabled[0]→factions[0].is_enabled；empires[1].leaders[6].support 按原样。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT0_DIS := "event.script.event_293_italy_socialism_act1.c0"
const TXT_OPT1_DIS := "event.script.event_293_italy_socialism_act1.c1"
const TXT_OPT2_DIS := "event.script.event_293_italy_socialism_act1.c2"
const TXT_OPT3_DIS := "event.script.event_293_italy_socialism_act1.c3"
const TXT_OPT1_DIS_A := "event.script.event_293_italy_socialism_act1.c4"
const TXT_OPT1_DIS_B := "event.script.event_293_italy_socialism_act1.c5"
const TXT_OPT2_DIS_A := "event.script.event_293_italy_socialism_act1.c6"
const TXT_OPT2_DIS_B := "event.script.event_293_italy_socialism_act1.c7"
const TXT_R0 := "event.script.event_293_italy_socialism_act1.c8"
const TXT_R1 := "event.script.event_293_italy_socialism_act1.c9"
const TXT_R2 := "event.script.event_293_italy_socialism_act1.c10"
const TXT_R3 := "event.script.event_293_italy_socialism_act1.c11"
const TXT_R4 := "event.script.event_293_italy_socialism_act1.c12"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var china := world.get_country_by_legacy_index(1)
	var relres := world.get_flag("relres")
	var res65 := int(world.completed_event_ids.get("event_65", 0))
	var tech19 := world.techs != null and world.techs.unlocked.size() > 19 and world.techs.unlocked[19]
	var opt := event_def.options
	if line >= 1 and line <= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line >= 3 and not world.is_socialism(china, true) and not world.is_authoritarian(china):
		_enable(opt[1], event_def.options[1].text)
	elif line < 3:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	if line <= 2 and relres and res65 != 2 and res65 != 3 and (_mod_active(GameConstants.Modifier.COOPERATE_WITH_STASI) or tech19):
		_enable(opt[2], event_def.options[2].text)
	elif line > 2:
		_disable(opt[2], tr(TXT_OPT2_DIS_A))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_B))
	if line <= 1:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -20)
			_add(W.I_AGENTS, -20)
			_add(W.I_ARMY, -20)
			_add_relation(EmpireData.USSR, -100)
			_add_relation(EmpireData.USA, -100)
			if italy != null:
				italy.set_tag("对华贸易", true)
			_add(180, 2)
			_add(179, 1)
			if italy != null:
				italy.set_tag("亲美", false)
				italy.set_tag("eu", false)
				italy.government = GameConstants.Government.REFORMIST
				italy.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
			var t0 := _leader_name()
			context["result_text"] = tr(TXT_R0).format([t0, ""])
		1:
			_add(W.I_BUDGET, -10)
			if ws.factions.size() > 0 and ws.factions[0] != null:
				ws.factions[0].is_enabled = false
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
					p.power += 200
				elif p.trait_personality == 4:
					p.power += 100
			_add(W.I_THOUGHT_FREEDOM, 100)
			if italy != null:
				italy.set_tag("对华贸易", true)
			_add(181, 2)
			var t1 := _leader_name()
			context["result_text"] = tr(TXT_R1).format([t1, ""])
		2:
			_add(W.I_AGENTS, -60)
			_add_relation(EmpireData.USSR, 100)
			_add_relation(EmpireData.USA, -100)
			_add(180, -1)
			_add(181, -1)
			_add(178, 1)
			_add(182, 1)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].leaders.size() > 6:
				ws.empires[EmpireData.USSR].leaders[6].support -= 1
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -25)
			_add(W.I_ARMY, -25)
			if italy != null:
				italy.level_of_development -= 5
			_add(134, 10)
			_add(172, 1)
			_add(173, 1)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].leaders.size() > 6:
				ws.empires[EmpireData.USSR].leaders[6].support -= 1
			context["result_text"] = tr(TXT_R3)
		4:
			context["result_text"] = tr(TXT_R4)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	PoliticianSystem.copy_leader_appearance(ws.leader, p)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_293_italy_socialism_act1.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_293",
	"num": 293,
	"priority": 29300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_293_italy_socialism_act1.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
