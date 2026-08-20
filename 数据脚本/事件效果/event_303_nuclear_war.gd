## 原作 Event303.cs：核战（核战争后果，两选项）。
## 触发：全目录搜索无 this_num_event = 303 / Reset(303)；链外 REST 段，原版无自动条件。
## 差异：load_scene_after_click→GameManager.queue_ending_after_event(7)；party_ideology[0]→factions[0].ideology；
##  GameObject.Find("Ach(Clone)") / iron_and_blood 成就 Set(112) 已接 Achievements；文本来自 Events_text_en 索引 50-56。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "但是下令核打击的是我们，不是极左派......"
const TXT_R0 := "我们的城市已成为废土，但我们的导弹也在向敌人飞去。你和你的同僚们躲在地堡里。但是如雪花般飞来的关于数千万人死亡的报道让你无法理智地做出决定，你头痛欲裂，核战不会有赢家，世界将永不会重归常态的想法已无法抑制......"
const TXT_R1 := "你下达了命令，很快极左派的头目就被逮捕了。联合国、苏联和美国都收到报告说，正是这些罪犯要对核打击负责，这群要为国际社会负责的党员也已被消灭。你已准备好以严重的经济与名誉损失的形式承担所有后果。此外，国际机构肯定会要求我国大幅裁减军队，并销毁所有核武器。但这对世界来说只是微不足道的代价。让极左派准备好上国际法庭吧。"


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
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			GameManager.queue_ending_after_event(7)
			context["result_text"] = TXT_R0
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
			context["result_text"] = TXT_R1




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

