extends "res://数据脚本/event_script_base.gd"

## 原作政治转折事件 24–26 的强制剧情效果。
## 来源：Event24-26.cs / Results_text.cs:2066-2561；选项门槛见 doneventscript.cs:741-803。


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
			_change_loyalty_custom({0: 100, 1: 50, 2: -100, 20: 80})
			_add_faction_ideology({0: 300, 1: 500})
			d[W.I_POST_MAO_COURSE] = 1
		1:
			_add_data({
				W.I_PARTY_SUPPORT: -50, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: 100,
			})
			_change_loyalty_power_24_1()
			_add_faction_ideology({0: 800, 1: 300})
			d[W.I_POST_MAO_COURSE] = 2
		2:
			_add_data({W.I_DIPLO: -10, W.I_PEOPLE_SUPPORT: 50, W.I_THOUGHT_FREEDOM: 80})
			_set_modifier(3, false)
			_change_loyalty_custom({0: -20, 1: 100, 2: 100})
			_add_faction_ideology({2: 800, 3: 300})
			d[W.I_POST_MAO_COURSE] = 3
		3:
			_add_data({
				W.I_PEOPLE_SUPPORT: 80, W.I_PARTY_SUPPORT: -50,
				W.I_THOUGHT_FREEDOM: 100,
			})
			_set_modifier(3, false)
			_change_loyalty_24_3()
			_add_faction_ideology({2: 300, 3: 800, 4: 300})
			d[W.I_POST_MAO_COURSE] = 4


func _apply_event_25(option_index: int) -> void:
	match option_index:
		0:
			_add_data({
				W.I_PEOPLE_SUPPORT: 100, W.I_THOUGHT_FREEDOM: 70,
				W.I_PARTY_SUPPORT: 100, W.I_DIPLO: -30,
			})
			d[W.I_GANG_OF_FOUR_PATH] = 1
			_change_loyalty_custom({0: -50, 1: 50, 2: 50})
			_add_faction_ideology({1: 250, 2: 150, 3: 150})
			_kill_many([0, 1, 2, 3, 4, 17])
			_remake_as_wang_dongxing(1)
			_add_power_by_index({6: 100, 7: 100})
		1:
			_add_data({
				W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: 50,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -10,
			})
			d[W.I_GANG_OF_FOUR_PATH] = 2
			_change_loyalty_custom({0: -20, 1: 50, 2: 50})
			_add_faction_ideology({1: 200, 2: 100, 3: 100})
			_kill_many([1, 2])
			_remake_as_wang_dongxing(1)
			_add_power_by_index({6: 100, 7: 100})
			_force_position_threshold(2, 3, 50)
		2:
			_add_data({
				W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 250, W.I_DIPLO: 50,
			})
			d[W.I_GANG_OF_FOUR_PATH] = 3
			_change_loyalty_24_2_style()
			_add_faction_ideology({0: 250, 1: 150})
			_scale_faction_ideology(3, 0.90)
			_add_power_by_index({7: -100, 12: -100, 9: 100})
		3:
			# 原版 SceneManager.LoadScene("Ending")；项目用 queue_ending_after_event(2) 替代。
			d[W.I_ENDING_ROUTE] = 2
			GameManager.queue_ending_after_event(2)
	PoliticianSystem.sync_in_power_flags(ws)


func _apply_event_26(option_index: int) -> void:
	match option_index:
		0:
			_add_data({
				W.I_PEOPLE_SUPPORT: 40, W.I_THOUGHT_FREEDOM: 100,
				W.I_PARTY_SUPPORT: 50, W.I_DIPLO: -30, W.I_AGENTS: -70,
			})
			d[W.I_GANG_OF_FOUR_PATH] = 1
			_change_loyalty_custom({0: -100, 1: 50, 2: 50})
			_add_faction_ideology({1: 250, 2: 150, 3: 150})
			_kill_many([1, 2, 3, 4])
			_remake_as_wang_dongxing(1)
			_add_power_by_index({5: 400, 6: 100, 7: 100})
		1:
			_add_data({
				W.I_PARTY_SUPPORT: 20, W.I_PEOPLE_SUPPORT: 20,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -10, W.I_AGENTS: -50,
			})
			d[W.I_GANG_OF_FOUR_PATH] = 2
			_change_loyalty_custom({0: -50, 1: 50, 2: 50})
			_add_faction_ideology({1: 200, 2: 100, 3: 100})
			_kill_many([1, 2])
			_remake_as_wang_dongxing(1)
			_add_power_by_index({3: 100, 4: 100})
			_force_position_threshold(2, 3, 100)
		2:
			_add_data({
				W.I_PARTY_SUPPORT: -200, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: 100,
			})
			_kill_many([7])
			_remake_as_wang_dongxing(7)
			_recalc_relations()
			_add_power_by_index({1: 500, 3: 500, 4: 500})
			_change_loyalty_power_26_2()
			_add_faction_ideology({0: 250, 1: 100})
			_scale_faction_ideology(3, 0.85)
	PoliticianSystem.sync_in_power_flags(ws)


func _change_loyalty_power_24_1() -> void:
	for politician in ws.politicians:
		if politician == null:
			continue
		if politician.trait_personality == 0:
			politician.loyalty += 100
		elif politician.trait_personality == 20:
			politician.loyalty += 80
		elif politician.trait_personality > 0:
			politician.loyalty -= 200
			politician.power -= 100


## Event24 result3：原版 Event24.cs ResultsOfEvents 的 traits 分支
##  if traits[0]==0 → loyalty -= 100；if traits[0]==20 → loyalty -= 50；
##  else if traits[0]>1 → loyalty += 100（20 不进入该分支）。
func _change_loyalty_24_3() -> void:
	for politician in ws.politicians:
		if politician == null:
			continue
		if politician.trait_personality == 0:
			politician.loyalty -= 100
		if politician.trait_personality == 20:
			politician.loyalty -= 50
		elif politician.trait_personality > 1:
			politician.loyalty += 100


func _change_loyalty_24_2_style() -> void:
	for politician in ws.politicians:
		if politician == null:
			continue
		if politician.trait_personality == 0:
			politician.loyalty += 200
		elif politician.trait_personality == 20:
			politician.loyalty += 100
		else:
			politician.loyalty -= 100


func _change_loyalty_power_26_2() -> void:
	for politician in ws.politicians:
		if politician == null:
			continue
		if politician.trait_personality == 0:
			politician.loyalty += 200
			politician.power += 100
		elif politician.trait_personality == 20:
			politician.loyalty += 100
			politician.power += 80
		elif politician.trait_personality == 2:
			politician.loyalty -= 100
			politician.power -= 100
		elif politician.trait_personality == 1:
			politician.loyalty -= 100


func _change_loyalty_custom(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			politician.loyalty += int(changes[politician.trait_personality])


func _change_loyalty_above(minimum: int, delta: int) -> void:
	for politician in ws.politicians:
		if politician != null and politician.trait_personality > minimum:
			politician.loyalty += delta


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < d.size():
			d[index] += int(changes[raw_index])




func _add_power_by_index(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.politicians.size() and ws.politicians[index] != null:
			ws.politicians[index].power += int(changes[raw_index])


func _add_faction_ideology(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _scale_faction_ideology(faction_index: int, factor: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
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


func _remake_as_wang_dongxing(index: int) -> void:
	if index < 0 or index >= ws.politicians.size() or ws.politicians[index] == null:
		return
	var politician := ws.politicians[index]
	politician.name_first = 16
	politician.name_last = 16
	politician.name_display = "汪东兴"
	politician.age = d[W.I_YEAR] - 1905
	politician.trait_personality = 1
	politician.trait_background = 21
	politician.trait_alignment = 5
	politician.trait_special = 11
	politician.power = 800
	politician.loyalty = 800
	politician.wanted_position = 0


func _recalc_relations() -> void:
	for index in ws.politicians.size():
		WorldFactory._calc_rel(ws, index)
		WorldFactory._calc_rel2(ws, index)
		WorldFactory._calc_rel_leader(ws, index)


func _force_position_threshold(position_index: int, politician_index: int, threshold: int) -> void:
	if position_index < 0 or position_index >= ws.politics_positions.size():
		return
	var previous := ws.politics_positions[position_index]
	if previous >= 0 and previous < ws.politicians.size() and previous != politician_index and previous < threshold:
		ws.politicians[previous].loyalty -= 200
	ws.politics_positions[position_index] = politician_index
