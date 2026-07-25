extends RefCounted

## 原作事件 67–70：波兰危机、光州起义与改革/保守两条五中全会清洗路线。
## 来源：TimeScript.cs:3919-3971，doneventscript.cs:1637-1766，
##       Results_text.cs:5691-6167。
const W = preload("res://数据脚本/world_state.gd")


func execute(context: Dictionary) -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"polish_crisis": _event_67(ws, option_index, context)
		"gwangju_uprising": _event_68(ws, option_index)
		"little_gang_of_four": _event_69(ws, option_index)
		"zhou_enlai_heirs": _event_70(ws, option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors(ws)


func _event_67(ws: WorldState, option_index: int, context: Dictionary) -> void:
	var poland := ws.get_country_by_legacy_index(2)
	match option_index:
		0:
			_add_empire_power(ws, EmpireData.USSR, -20)
			_add_empire_relation(ws, EmpireData.USSR, 50)
			if poland != null:
				poland.government = 0
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 200, W.I_BUDGET: -200,
				W.I_AGENTS: -50, W.I_THOUGHT_FREEDOM: -10})
			_add_empire_power(ws, EmpireData.USSR, -10)
			_add_empire_relation(ws, EmpireData.USA, -100)
			_add_empire_relation(ws, EmpireData.USSR, 150)
			if poland != null:
				poland.government = 0
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: 100, W.I_BUDGET: -300,
				W.I_AGENTS: -150, W.I_INFLUENCE: 30, W.I_DIPLO: 60})
			_add_empire_power(ws, EmpireData.USSR, -30)
			_add_empire_power(ws, EmpireData.USA, -20)
			_add_empire_relation(ws, EmpireData.USA, -100)
			_add_empire_relation(ws, EmpireData.USSR, 200)
			if poland != null:
				poland.government = 0
				poland.set_tag("亲苏", false)
				poland.set_tag("亲中", true)
		3:
			if _empire_relation(ws, EmpireData.USSR) >= 800:
				_add_data(ws, {W.I_PARTY_SUPPORT: 100, W.I_ARMY: -50,
					W.I_AGENTS: -50, W.I_INFLUENCE: 10, W.I_DIPLO: 30,
					W.I_SOVIET_INTERVENTIONS: 1})
				_add_empire_power(ws, EmpireData.USA, -10)
				_add_empire_relation(ws, EmpireData.USA, -150)
				_add_empire_relation(ws, EmpireData.USSR, 150)
				context["result_text"] = "The USSR, GDR and Czechoslovakia accepted China's proposal and intervened militarily in Poland."
			else:
				_add_data(ws, {W.I_INFLUENCE: 10, W.I_DIPLO: 20})
				_add_empire_power(ws, EmpireData.USSR, -20)
				if poland != null:
					poland.government = 0
				context["result_text"] = "Moscow rejected intervention and instead backed Jaruzelski's independent imposition of martial law."
		4:
			var united_states := ws.get_country_by_legacy_index(51)
			if _empire_relation(ws, EmpireData.USA) >= 80 and united_states != null and united_states.stability == 1:
				_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: 20,
					W.I_THOUGHT_FREEDOM: 160, W.I_BUDGET: -100,
					W.I_AGENTS: -200, W.I_DIPLO: -20})
				_add_empire_power(ws, EmpireData.USSR, -30)
				_add_empire_relation(ws, EmpireData.USA, 150)
				_add_empire_relation(ws, EmpireData.USSR, -50)
				if poland != null:
					poland.government = 2
				context["result_text"] = "Joint Chinese-American pressure produced a reformist Polish compromise with Solidarity."
			else:
				_add_data(ws, {W.I_AGENTS: -200, W.I_BUDGET: -100,
					W.I_PARTY_SUPPORT: -100, W.I_THOUGHT_FREEDOM: 80})
				_add_empire_power(ws, EmpireData.USSR, -10)
				_add_empire_relation(ws, EmpireData.USA, -300)
				context["result_text"] = "The attempt to aid Solidarity failed and Warsaw Pact forces restored control."


func _event_68(ws: WorldState, option_index: int) -> void:
	if option_index == 0:
		_add_empire_power(ws, EmpireData.USA, 10)
		return
	_add_data(ws, {W.I_ARMY: -80, W.I_AGENTS: -80, W.I_DIPLO: 10})
	_add_empire_relation(ws, EmpireData.USA, -100)
	_add_empire_power(ws, EmpireData.USA, -10)
	ws.set_flag("south_korea_gwangju_rebellion", true)


func _event_69(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -70})
			_change_politicians(ws, {
				0: [0, 100], 1: [-150, 0], 2: [-150, 0], 3: [-150, 0],
			})
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 80, W.I_REFORM_MOMENTUM: 20,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -30})
			_disable_faction(ws, FactionData.MAOIST)
			_subtract_faction_fraction(ws, FactionData.CONSERVATIVE, 0.45)
			_enable_faction(ws, FactionData.LIBERAL)
			_add_faction_ideology(ws, {FactionData.REFORMIST: 45, FactionData.LIBERAL: 24})
			_change_politicians(ws, {
				0: [-250, -200], 1: [0, 80], 2: [0, 100], 3: [0, 150],
			})
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_REFORM_MOMENTUM: 10,
				W.I_THOUGHT_FREEDOM: 30, W.I_DIPLO: -15})
			_disable_faction(ws, FactionData.MAOIST)
			_subtract_faction_fraction(ws, FactionData.CONSERVATIVE, 0.45)
			_add_faction_ideology(ws, {
				FactionData.MODERATE: 27, FactionData.REFORMIST: 45, FactionData.LIBERAL: 15,
			})
			_change_politicians(ws, {
				0: [-300, -350], 1: [0, 100], 2: [0, 120], 3: [0, 80],
			})


func _event_70(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 100})
			_add_faction_ideology(ws, {FactionData.REFORMIST: 25})
			_change_politicians(ws, {0: [-100, 0], 2: [0, 100]})
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_THOUGHT_FREEDOM: -50, W.I_DIPLO: 40})
			_remove_deng_if_modifier_active(ws)
			_add_faction_ideology(ws, {FactionData.CONSERVATIVE: 45, FactionData.MAOIST: 30})
			_change_politicians(ws, {
				0: [0, 150], 1: [-200, -150], 2: [-200, -350], 3: [-200, -250],
			})
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: 80, W.I_THOUGHT_FREEDOM: -50, W.I_DIPLO: 30})
			_remove_deng_if_modifier_active(ws)
			_add_faction_ideology(ws, {
				FactionData.MAOIST: 30, FactionData.CONSERVATIVE: 45, FactionData.MODERATE: 24,
			})
			_change_politicians(ws, {2: [-200, -350], 3: [-200, -250]})
		3:
			_add_data(ws, {W.I_PARTY_SUPPORT: -200, W.I_THOUGHT_FREEDOM: 150,
				W.I_PEOPLE_SUPPORT: -200, W.I_DIPLO: 50})
			_remove_deng_if_modifier_active(ws)
			_add_faction_ideology(ws, {FactionData.MAOIST: 30, FactionData.CONSERVATIVE: 45})
			_subtract_faction_fraction(ws, FactionData.MODERATE, 0.09)
			_change_politicians(ws, {
				0: [0, 150], 1: [-30, -50], 2: [-30, -350], 3: [-300, -250],
			})


func _remove_deng_if_modifier_active(ws: WorldState) -> void:
	if ws.modifiers.size() > 14 and ws.modifiers[14] != null and ws.modifiers[14].is_active:
		GameManager.kill_politician(12)
		ws.modifiers[14].is_active = false


func _disable_faction(ws: WorldState, faction_index: int) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		ws.factions[faction_index].is_enabled = false
		ws.factions[faction_index].is_ally = false


func _enable_faction(ws: WorldState, faction_index: int) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		ws.factions[faction_index].is_enabled = true


func _empire_relation(ws: WorldState, empire_index: int) -> int:
	return ws.empires[empire_index].relations if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null else 0


func _add_data(ws: WorldState, changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.数值表.size():
			ws.数值表[index] += int(changes[raw_index])


func _change_politicians(ws: WorldState, changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			var pair: Array = changes[politician.trait_personality]
			politician.loyalty += int(pair[0])
			politician.power += int(pair[1])


func _add_faction_ideology(ws: WorldState, changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _subtract_faction_fraction(ws: WorldState, faction_index: int, fraction: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		var current := ws.factions[faction_index].ideology
		ws.factions[faction_index].ideology = current - int(float(current) * fraction)


func _add_empire_relation(ws: WorldState, empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(ws: WorldState, empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors(ws: WorldState) -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
