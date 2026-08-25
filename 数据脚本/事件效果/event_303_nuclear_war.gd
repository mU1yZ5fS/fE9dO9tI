## 原作 Event303.cs：核战（核战争后果，两选项）。
## 触发：全目录搜索无 this_num_event = 303 / Reset(303)；链外 REST 段，原版无自动条件。
## 差异：load_scene_after_click→game.queue_ending_after_event(7)；party_ideology[0]→factions[0].ideology；
##  GameObject.Find("Ach(Clone)") / iron_and_blood 成就 Set(112) 已接 Achievements；文本来自 Events_text_en 索引 50-56。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "event.script.event_303_nuclear_war.c0"
const TXT_R0 := "event.script.event_303_nuclear_war.c1"
const TXT_R1 := "event.script.event_303_nuclear_war.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var agents := world.agents if world.size() > W.I_AGENTS else 0
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if agents >= 150:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			game.queue_ending_after_event(7)
			context["result_text"] = tr(TXT_R0)
		1:
			if ws.factions.size() > 0 and ws.factions[0] != null:
				ws.factions[0].ideology = 0
			_add(W.I_LIVING, -150)
			_add(W.I_DIPLO, -600)
			_add(W.I_INFLUENCE, -300)
			_add(W.I_BUDGET, -150)
			_add(W.I_INDUSTRY, -500)
			_add_relation(EmpireData.USA, -500)
			_add(W.I_ARMY, -500)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 250
					p.power -= 250
			# 原作 Event303.cs:57：iron_and_blood → achievements.Set(112)
			Achievements.set_achievement(112)
			context["result_text"] = tr(TXT_R1)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_303_nuclear_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_303",
	"num": 303,
	"priority": 30300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_303_nuclear_war.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
