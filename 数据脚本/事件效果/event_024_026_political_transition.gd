extends "res://数据脚本/event_script_base.gd"

## 原作政治转折事件 24–26 的强制剧情效果。
## 来源：Results_text.cs:2066-2561；选项门槛见 doneventscript.cs:741-803。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"post_mao_course":
			_apply_event_24(option_index)
		"gang_of_four":
			_apply_event_25(option_index)
		"weak_alliance":
			_apply_event_26(option_index)


func _apply_event_24(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_PEOPLE_SUPPORT: 20, W.I_THOUGHT_FREEDOM: 100})
			_add_empire_relation(0, -50)
			_add_empire_relation(1, -50)
			_set_modifier(3, false)
			_change_loyalty({0: 100, 1: 50, 2: -100})
			_add_faction_ideology({0: 300, 1: 500})
			ws.数值表[W.I_POST_MAO_COURSE] = 1
		1:
			_add_data({
				W.I_PARTY_SUPPORT: -50, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: 100,
			})
			_change_loyalty({0: 100, 1: -200, 2: -200, 3: -200})
			_change_power({1: -100, 2: -100, 3: -100})
			_add_faction_ideology({0: 800, 1: 300})
			ws.数值表[W.I_POST_MAO_COURSE] = 2
		2:
			_add_data({W.I_DIPLO: -10, W.I_PEOPLE_SUPPORT: 50, W.I_THOUGHT_FREEDOM: 80})
			_change_loyalty({0: -20, 1: 100, 2: 100})
			_add_faction_ideology({2: 800, 3: 300})
			ws.数值表[W.I_POST_MAO_COURSE] = 3
		3:
			_add_data({
				W.I_PEOPLE_SUPPORT: 80, W.I_PARTY_SUPPORT: -50,
				W.I_THOUGHT_FREEDOM: 100,
			})
			_change_loyalty({0: -100, 2: 100, 3: 100})
			_add_faction_ideology({2: 300, 3: 800, 4: 300})
			ws.数值表[W.I_POST_MAO_COURSE] = 4


func _apply_event_25(option_index: int) -> void:
	match option_index:
		0:
			_add_data({
				W.I_PEOPLE_SUPPORT: 100, W.I_THOUGHT_FREEDOM: 70,
				W.I_PARTY_SUPPORT: 100, W.I_DIPLO: -30,
			})
			ws.数值表[W.I_GANG_OF_FOUR_PATH] = 1
			_change_loyalty({0: -50, 1: 50, 2: 50})
			_add_faction_ideology({1: 250, 2: 150, 3: 150})
			_kill_many([1, 2, 3, 4])
			_add_power_by_index({6: 100, 7: 100})
		1:
			_add_data({
				W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: 50,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -10,
			})
			ws.数值表[W.I_GANG_OF_FOUR_PATH] = 2
			_change_loyalty({0: -20, 1: 70, 2: 50})
			_add_faction_ideology({1: 200, 2: 100, 3: 100})
			_kill_many([1, 2])
			_add_power_by_index({6: 100, 7: 100})
			_force_position(2, 3)
		2:
			_add_data({
				W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 250, W.I_DIPLO: 50,
			})
			ws.数值表[W.I_GANG_OF_FOUR_PATH] = 3
			_change_loyalty({0: 200, 1: -100, 2: -100})
			_add_faction_ideology({0: 250, 1: 150})
			_scale_faction_ideology(3, 0.90)
			_add_power_by_index({7: -100, 12: -100, 9: 100})
			_force_position(2, 4)
			_force_position(1, 2)
		3:
			ws.数值表[W.I_ENDING_ROUTE] = 2
			GameManager.queue_ending_after_event(2)
	PoliticianSystem.sync_in_power_flags(ws)


func _apply_event_26(option_index: int) -> void:
	match option_index:
		0:
			_add_data({
				W.I_PEOPLE_SUPPORT: 40, W.I_THOUGHT_FREEDOM: 100,
				W.I_PARTY_SUPPORT: 50, W.I_DIPLO: -30, W.I_AGENTS: -70,
			})
			ws.数值表[W.I_GANG_OF_FOUR_PATH] = 1
			_change_loyalty({0: -100, 1: 50, 2: 50})
			_add_faction_ideology({1: 250, 2: 150, 3: 150})
			_kill_many([1, 2, 3, 4])
			_add_power_by_index({5: 400, 6: 100, 7: 100})
		1:
			_add_data({
				W.I_PARTY_SUPPORT: 20, W.I_PEOPLE_SUPPORT: 20,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -10, W.I_AGENTS: -50,
			})
			ws.数值表[W.I_GANG_OF_FOUR_PATH] = 2
			_change_loyalty({0: -50, 1: 50, 2: 50})
			_add_faction_ideology({1: 200, 2: 100, 3: 100})
			_kill_many([1, 2])
			_add_power_by_index({3: 100, 4: 100})
			_force_position(2, 3)
		2:
			_add_data({
				W.I_PARTY_SUPPORT: -200, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: 100,
			})
			_swap_leader_with_politician(1)
			_add_power_by_index({2: 500, 3: 500, 4: 500})
			_change_loyalty({0: 200, 1: -100, 2: -100})
			_change_power({0: 100, 2: -100})
			_add_faction_ideology({0: 250, 1: 100})
			_scale_faction_ideology(3, 0.85)
	PoliticianSystem.sync_in_power_flags(ws)


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.数值表.size():
			ws.数值表[index] += int(changes[raw_index])


func _change_loyalty(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			politician.loyalty += int(changes[politician.trait_personality])


func _change_power(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			politician.power += int(changes[politician.trait_personality])


func _add_power_by_index(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.politicians.size() and ws.politicians[index] != null:
			ws.politicians[index].power += int(changes[raw_index])


func _add_faction_ideology(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size():
			ws.factions[index].ideology += int(changes[raw_index])


func _scale_faction_ideology(faction_index: int, factor: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size():
		ws.factions[faction_index].ideology = int(float(ws.factions[faction_index].ideology) * factor)


func _set_modifier(modifier_index: int, active: bool) -> void:
	if modifier_index >= 0 and modifier_index < ws.modifiers.size() and ws.modifiers[modifier_index] != null:
		ws.modifiers[modifier_index].is_active = active


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index < 0 or empire_index >= ws.empires.size() or ws.empires[empire_index] == null:
		return
	ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
	if empire_index == 0:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[empire_index].relations
	elif empire_index == 1:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[empire_index].relations


func _kill_many(indexes: Array[int]) -> void:
	for index in indexes:
		GameManager.kill_politician(index)


func _force_position(position_index: int, politician_index: int) -> void:
	if position_index < 0 or position_index >= ws.politics_positions.size():
		return
	var previous := ws.politics_positions[position_index]
	if previous >= 0 and previous < ws.politicians.size() and previous != politician_index:
		ws.politicians[previous].loyalty -= 200
	ws.politics_positions[position_index] = politician_index


func _swap_leader_with_politician(
		politician_index: int, faction_index: int = FactionData.MAOIST) -> void:
	if ws.leader == null or politician_index < 0 or politician_index >= ws.politicians.size():
		return
	var politician := ws.politicians[politician_index]
	if politician == null:
		return
	_swap_identity(ws.leader, politician)
	if faction_index >= 0 and faction_index < ws.factions.size():
		# 原版 faction_leader[faction_index]=200；项目用 -2 表示实权领袖本人。
		ws.factions[faction_index].leader_index = WorldFactory.LEADER_POSITION_SENTINEL
	for position_index in ws.politics_positions.size():
		if ws.politics_positions[position_index] == WorldFactory.LEADER_POSITION_SENTINEL:
			ws.politics_positions[position_index] = politician_index
		elif ws.politics_positions[position_index] == politician_index:
			ws.politics_positions[position_index] = WorldFactory.LEADER_POSITION_SENTINEL
	for index in ws.politicians.size():
		WorldFactory._calc_rel(ws, index)
		WorldFactory._calc_rel2(ws, index)
		WorldFactory._calc_rel_leader(ws, index)


func _swap_identity(a: PoliticianData, b: PoliticianData) -> void:
	var old_name := a.name_display
	var old_portrait := a.portrait
	var old_historical := a.is_historical
	var old_personality := a.trait_personality
	var old_alignment := a.trait_alignment
	var old_special := a.trait_special
	var old_faction := a.faction
	var old_age := a.age
	var old_name_first := a.name_first
	var old_name_last := a.name_last
	var old_face_type := a.face_type
	var old_face_parts := a.face_parts.duplicate()
	var old_jacket := a.jacket

	a.name_display = b.name_display
	a.portrait = b.portrait
	a.is_historical = b.is_historical
	a.trait_personality = b.trait_personality
	a.trait_alignment = b.trait_alignment
	a.trait_special = b.trait_special
	a.faction = b.faction
	a.age = b.age
	a.name_first = b.name_first
	a.name_last = b.name_last
	a.face_type = b.face_type
	a.face_parts = b.face_parts.duplicate()
	a.jacket = b.jacket

	b.name_display = old_name
	b.portrait = old_portrait
	b.is_historical = old_historical
	b.trait_personality = old_personality
	b.trait_alignment = old_alignment
	b.trait_special = old_special
	b.faction = old_faction
	b.age = old_age
	b.name_first = old_name_first
	b.name_last = old_name_last
	b.face_type = old_face_type
	b.face_parts = old_face_parts
	b.jacket = old_jacket
