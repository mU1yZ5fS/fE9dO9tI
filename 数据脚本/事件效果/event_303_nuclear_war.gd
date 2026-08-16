## 原作 Event303.cs：核战（核战争后果，两选项）。
## 触发：全目录搜索无 this_num_event = 303 / Reset(303)；链外 REST 段，原版无自动条件。
## 差异：load_scene_after_click→GameManager.queue_ending_after_event(7)；party_ideology[0]→factions[0].ideology；
##  GameObject.Find("Ach(Clone)") / iron_and_blood 成就 Set(112) 已接 Achievements；文本来自 Events_text_en 索引 50-56。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "核战"
const TXT_DESC := "我们的核打击并非毫无后果。就在第二天，联合国安理会便召开了紧急会议，决定了我们的命运，据情报机构报告称，苏美两国的核导弹已经瞄准了我们，两国军队也收到了对中华人民共和国发动军事行动的计划。当然，谁都打不垮我们的革命精神，我们要反抗全世界，因为我们能把他们变成一滩放射性灰烬。但是，悄悄把那些把世界推到毁灭边缘的疯子赶下台，向全人类作出让步是个值当的打算么？"
const TXT_OPT0 := "和平解决方案已无可能！"
const TXT_OPT1 := "逮捕激进派。"
const TXT_OPT1_DIS := "但是下令核打击的是我们，不是极左派......"
const TXT_R0 := "我们的城市已成为废土，但我们的导弹也在向敌人飞去。你和你的同僚们躲在地堡里。但是如雪花般飞来的关于数千万人死亡的报道让你无法理智地做出决定，你头痛欲裂，核战不会有赢家，世界将永不会重归常态的想法已无法抑制......"
const TXT_R1 := "你下达了命令，很快极左派的头目就被逮捕了。联合国、苏联和美国都收到报告说，正是这些罪犯要对核打击负责，这群要为国际社会负责的党员也已被消灭。你已准备好以严重的经济与名誉损失的形式承担所有后果。此外，国际机构肯定会要求我国大幅裁减军队，并销毁所有核武器。但这对世界来说只是微不足道的代价。让极左派准备好上国际法庭吧。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var agents := world.数值表[W.I_AGENTS] if world.数值表.size() > W.I_AGENTS else 0
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if agents >= 150:
		_enable(opt[1], TXT_OPT1)
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
				if p.trait_personality == 0:
					p.loyalty -= 250
					p.power -= 250
			# 原作 Event303.cs:57：iron_and_blood → achievements.Set(112)
			Achievements.set_achievement(112)
			context["result_text"] = TXT_R1


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _mod_active(idx: int) -> bool:
	var w: WorldState = ws if ws != null else GameManager.world
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
	ws.leader.face_type = p.face_type
	if p.face_parts.size() >= 8:
		ws.leader.face_parts = p.face_parts.duplicate()
	ws.leader.jacket = p.jacket

