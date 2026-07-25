extends RefCounted

## 原作 1977 年自动事件 33–41 的结果逻辑。
## 来源：TimeScript.cs:3732-3784，doneventscript.cs:895-1170，
##       Results_text.cs:2907-3681。
const W = preload("res://数据脚本/world_state.gd")


func execute(context: Dictionary) -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"pakistan_coup": _event_33(ws, option_index)
		"enemies_of_my_enemies": _event_34(ws, option_index)
		"end_of_revolution": _event_35(ws, option_index)
		"iraqi_coalition": _event_36(ws, option_index)
		"egyptian_unrest": _event_37(ws, option_index, context)
		"back_to_roots": _event_38(ws, option_index)
		"historical_resolution": _event_39(ws, option_index, context)
		"panchen_lama": _event_40(ws, option_index, context)
		"indian_elections": _event_41(ws, option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors(ws)


func _event_33(ws: WorldState, option_index: int) -> void:
	var pakistan := ws.get_country_by_legacy_index(31)
	match option_index:
		0:
			_add_empire_power(ws, EmpireData.USA, 30)
			ws.数值表[W.I_THOUGHT_FREEDOM] += 30
			_set_country(pakistan, 0, true, false, false)
		1:
			_add_empire_relation(ws, EmpireData.USA, -100)
			_add_data(ws, {W.I_INFLUENCE: 20, W.I_AGENTS: -60, W.I_BUDGET: -30})
			_set_country(pakistan, 2, false, false, true)
			_subtract_faction_fraction(ws, FactionData.LIBERAL, 0.25)
		2:
			ws.数值表[W.I_THOUGHT_FREEDOM] += 50
			_add_empire_relation(ws, EmpireData.USA, 50)
			_add_empire_relation(ws, EmpireData.USSR, -50)
			_add_empire_power(ws, EmpireData.USA, 20)
			_set_country(pakistan, 0, true, false, false)


func _event_34(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -50})
			_subtract_faction_fraction(ws, FactionData.REFORMIST, 0.50)
			_subtract_faction_fraction(ws, FactionData.MODERATE, 0.15)
			_change_politicians(ws, {2: [-100, 0], 0: [100, 0]})
			_add_power_by_index(ws, {7: -100, 6: -100})
		1:
			ws.数值表[W.I_PARTY_SUPPORT] -= 100
			_add_faction_ideology(ws, {FactionData.CONSERVATIVE: 400})
			_change_politicians(ws, {0: [100, 0]})
			_add_power_by_index(ws, {5: 100, 8: 100, 9: 100})
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -150, W.I_PEOPLE_SUPPORT: -50,
				W.I_THOUGHT_FREEDOM: 50, W.I_DIPLO: 20})
			_add_faction_ideology(ws, {FactionData.CONSERVATIVE: 400})
			_subtract_faction_fraction(ws, FactionData.REFORMIST, 0.10)
			_subtract_faction_fraction(ws, FactionData.MODERATE, 0.15)
			_change_politicians(ws, {2: [-200, 0], 0: [150, 0]})
			_add_power_by_index(ws, {6: -150, 7: -150})
		3:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_PEOPLE_SUPPORT: 50,
				W.I_THOUGHT_FREEDOM: 80, W.I_DIPLO: -20})
			_add_faction_ideology(ws, {FactionData.REFORMIST: 500})
			_change_politicians(ws, {2: [200, 120], 3: [0, 70], 0: [-200, 0]})
		4:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 30})
			_add_faction_ideology(ws, {FactionData.REFORMIST: 200})
			_change_politicians_at_least(ws, 2, 0, 70)


func _event_35(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_THOUGHT_FREEDOM: 40, W.I_PEOPLE_SUPPORT: -60})
			_change_politicians_at_least(ws, 1, -100, 0)
		1:
			_add_data(ws, {W.I_PEOPLE_SUPPORT: 60, W.I_THOUGHT_FREEDOM: 20,
				W.I_MANPOWER: -30, W.I_DIPLO: -20})
			ws.数值表[W.I_PRESS_POLICY] = 17
			_liberalization_party_effects(ws, 50, 30)
		2:
			_add_data(ws, {W.I_PEOPLE_SUPPORT: 70, W.I_THOUGHT_FREEDOM: 40, W.I_DIPLO: -30})
			ws.数值表[W.I_PRESS_POLICY] = 17
			ws.数值表[W.I_RELIGION] = 25
			_liberalization_party_effects(ws, 80, 30)
		3:
			_add_data(ws, {W.I_PEOPLE_SUPPORT: 90, W.I_THOUGHT_FREEDOM: 60, W.I_DIPLO: -40})
			ws.数值表[W.I_PRESS_POLICY] = 17
			ws.数值表[W.I_RELIGION] = 26
			_liberalization_party_effects(ws, 80, 50)


func _event_36(ws: WorldState, option_index: int) -> void:
	var iraq := ws.get_country_by_legacy_index(14)
	match option_index:
		0:
			if iraq != null: iraq.government = 0
		1:
			ws.数值表[W.I_DIPLO] += 10
			if iraq != null:
				iraq.government = 0
				iraq.set_tag("对华贸易", false)
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: 70, W.I_THOUGHT_FREEDOM: -30,
				W.I_INFLUENCE: -10, W.I_AGENTS: -50})
			ws.set_flag("iraqi_communist_coalition", true)


func _event_37(ws: WorldState, option_index: int, context: Dictionary) -> void:
	var egypt := ws.get_country_by_legacy_index(30)
	var libya := ws.get_country_by_legacy_index(13)
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 20,
				W.I_AGENTS: -60, W.I_BUDGET: -40})
			_add_empire_relation(ws, EmpireData.USA, -150)
			_add_empire_relation(ws, EmpireData.USSR, 80)
			_add_empire_power(ws, EmpireData.USA, -10)
			if egypt != null:
				egypt.government = 2
				egypt.set_tag("亲美", false)
				egypt.set_tag("对华贸易", true)
		1:
			var success := (libya != null and libya.has_tag("对华贸易")) or (egypt != null and egypt.stability == 1)
			_add_data(ws, {W.I_AGENTS: -20, W.I_BUDGET: -20})
			if success:
				_add_data(ws, {W.I_PARTY_SUPPORT: 20, W.I_INFLUENCE: 10})
				_add_empire_power(ws, EmpireData.USSR, 20)
				_add_empire_power(ws, EmpireData.USA, -20)
				_add_empire_relation(ws, EmpireData.USSR, 50)
				if egypt != null:
					egypt.government = 2
					egypt.set_tag("亲苏", true)
					egypt.set_tag("亲美", false)
				context["result_text"] = "Libyan and Syrian services removed Sadat. Ali Sabri returned Egypt to a leftward, increasingly Soviet-oriented course."
			else:
				_add_empire_power(ws, EmpireData.USA, -10)
				if egypt != null: egypt.set_tag("亲美", false)
				context["result_text"] = "The operation removed Sadat, but Hosni Mubarak retained an anti-Soviet, multi-vector Egyptian government."


func _event_38(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			pass
		1:
			_add_data(ws, {W.I_BUDGET: -10, W.I_DIPLO: 20, W.I_THOUGHT_FREEDOM: 50,
				W.I_PEOPLE_SUPPORT: -40})
			_add_empire_relation(ws, EmpireData.USA, -70)
			_add_empire_relation(ws, EmpireData.USSR, 50)
			ws.数值表[W.I_ECON_SYSTEM] = 10
			_add_faction_ideology(ws, {FactionData.MAOIST: 250, FactionData.CONSERVATIVE: 250})
			_change_politicians(ws, {0: [100, 0], 1: [-30, 0], 2: [-100, 0]})
		2:
			_add_data(ws, {W.I_DIPLO: -10, W.I_THOUGHT_FREEDOM: 20, W.I_PEOPLE_SUPPORT: 30})
			_add_empire_relation(ws, EmpireData.USSR, -70)
			_add_empire_relation(ws, EmpireData.USA, 80)
			_add_faction_ideology(ws, {FactionData.MODERATE: 450, FactionData.REFORMIST: 450})
			_change_politicians(ws, {2: [150, 100], 1: [70, 50], 0: [-170, -100]})


func _event_39(ws: WorldState, option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: 80, W.I_PEOPLE_SUPPORT: 20, W.I_DIPLO: 10})
			ws.数值表[W.I_MAO_HISTORY_LINE] = 0
			_add_faction_ideology(ws, {FactionData.MAOIST: 150, FactionData.CONSERVATIVE: 150})
			_change_politicians(ws, {0: [100, 30], 1: [60, 20], 2: [50, 0], 3: [-100, -30]})
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 100, W.I_PEOPLE_SUPPORT: 50,
				W.I_DIPLO: -30, W.I_COMMUNICATIONS: 20})
			ws.数值表[W.I_MAO_HISTORY_LINE] = 1
			_add_faction_ideology(ws, {FactionData.MAOIST: 150, FactionData.CONSERVATIVE: 150})
			_change_politicians(ws, {0: [50, 10], 1: [100, 40], 2: [80, 30], 3: [60, 0]})
		2:
			if ws.数值表[W.I_MAO_MAUSOLEUM] == 10:
				ws.数值表[W.I_MAO_MAUSOLEUM] = 9
				context["result_text"] = ("The liberal commission condemned Mao's rule. That night Mao was removed "
						+ "from the mausoleum, which was then demolished and replaced by a Chen Duxiu museum.")
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_PEOPLE_SUPPORT: -50, W.I_DIPLO: -60})
			ws.数值表[W.I_MAO_HISTORY_LINE] = 2
			_add_faction_ideology(ws, {FactionData.REFORMIST: 150, FactionData.LIBERAL: 100})
			_change_politicians(ws, {0: [-150, 0], 1: [-100, 0], 2: [50, 0], 3: [150, 0]})


func _event_40(ws: WorldState, option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: -50, W.I_DIPLO: 5})
		1:
			if ws.数值表[W.I_RELIGION] <= 25:
				_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: -60,
					W.I_DIPLO: 10, W.I_MANPOWER: -50, W.I_INFLUENCE: -10})
				context["result_text"] = "The Panchen Lama rejected release under forced renunciation of his monastic vows and remained in custody."
			else:
				_add_data(ws, {W.I_PEOPLE_SUPPORT: 60, W.I_INFLUENCE: 10,
					W.I_MANPOWER: 40, W.I_DIPLO: -20})
				_add_empire_relation(ws, EmpireData.USA, 50)
				context["result_text"] = "The Panchen Lama accepted the condition, left monastic life, and was later rehabilitated."
		2:
			_add_data(ws, {W.I_PEOPLE_SUPPORT: 80, W.I_INFLUENCE: 10,
				W.I_MANPOWER: 40, W.I_AGENTS: -40, W.I_DIPLO: -20})
			_add_empire_relation(ws, EmpireData.USA, 100)
		3:
			if ws.数值表[W.I_RELIGION] >= 26 and ws.数值表[W.I_PEOPLE_SUPPORT] >= 700:
				_add_data(ws, {W.I_INFLUENCE: 10, W.I_PEOPLE_SUPPORT: 120,
					W.I_DIPLO: -20, W.I_MANPOWER: 40})
				_add_empire_relation(ws, EmpireData.USA, 120)
				_add_empire_relation(ws, EmpireData.USSR, 50)
				context["result_text"] = "Rehabilitation succeeded: the Panchen Lama publicly reconciled with the state and resumed religious and charitable work."
			else:
				_add_data(ws, {W.I_PEOPLE_SUPPORT: -100, W.I_INFLUENCE: -20,
					W.I_MANPOWER: -100, W.I_DIPLO: 20})
				_add_empire_relation(ws, EmpireData.USA, -100)
				context["result_text"] = "The Panchen Lama denounced the authorities, escaped to India, and became a powerful symbol for Tibetan separatists."
		4:
			_add_data(ws, {W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: -10,
				W.I_MANPOWER: -30, W.I_AGENTS: -70, W.I_BUDGET: -40,
				W.I_DIPLO: 20, W.I_PEOPLE_SUPPORT: -100})
			_add_empire_relation(ws, EmpireData.USA, -100)


func _event_41(ws: WorldState, option_index: int) -> void:
	var india := ws.get_country_by_legacy_index(19)
	match option_index:
		0:
			ws.数值表[W.I_INFLUENCE] += 10
			ws.数值表[W.I_INDIA_ELECTION] = 2
			if india != null: india.set_tag("对华贸易", true)
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 70, W.I_INFLUENCE: 20,
				W.I_BUDGET: -30, W.I_AGENTS: -50})
			ws.数值表[W.I_INDIA_ELECTION] = 1
			_add_empire_relation(ws, EmpireData.USSR, -70)
			if india != null:
				india.set_tag("对华贸易", true)
				india.set_tag("亲苏", false)
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_AGENTS: -50, W.I_COMMUNICATIONS: 30})
			ws.数值表[W.I_INDIA_ELECTION] = 3
			_add_empire_power(ws, EmpireData.USSR, 20)
			_add_empire_relation(ws, EmpireData.USSR, 100)


func _liberalization_party_effects(ws: WorldState, loyalty_delta: int, power_delta: int) -> void:
	_add_faction_ideology(ws, {FactionData.REFORMIST: 150, FactionData.MODERATE: 200})
	_change_politicians_at_least(ws, 1, loyalty_delta, power_delta)


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


func _change_politicians_at_least(ws: WorldState, minimum: int, loyalty_delta: int, power_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null and politician.trait_personality >= minimum:
			politician.loyalty += loyalty_delta
			politician.power += power_delta


func _add_power_by_index(ws: WorldState, changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.politicians.size() and ws.politicians[index] != null:
			ws.politicians[index].power += int(changes[raw_index])


func _add_faction_ideology(ws: WorldState, changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _subtract_faction_fraction(ws: WorldState, faction_index: int, fraction: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		var current := ws.factions[faction_index].ideology
		ws.factions[faction_index].ideology = current - int(float(current) * fraction)


func _set_country(country: CountryData, government: int, pro_usa: bool, trade: bool, pro_china: bool) -> void:
	if country == null:
		return
	country.government = government
	country.set_tag("亲美", pro_usa)
	country.set_tag("对华贸易", trade)
	country.set_tag("亲中", pro_china)


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
