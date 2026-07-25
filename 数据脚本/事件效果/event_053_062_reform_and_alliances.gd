extends RefCounted

## 原作事件 53–62：农业/外资改革、缅甸、越南、日本、伊朗终局、
## 中国主导的经济与军事集团、国歌和内蒙古政策。
## 来源：TimeScript.cs:3858-3947，doneventscript.cs:1307-1488，
##       Results_text.cs:4649-5479。
const W = preload("res://数据脚本/world_state.gd")


func execute(context: Dictionary) -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"agricultural_reform": _event_53(ws, option_index)
		"reform_investment": _event_54(ws, option_index)
		"burmese_socialism": _event_55(ws, option_index)
		"teach_vietnam_lesson": _event_56(ws, option_index)
		"red_rising_sun": _event_57(ws, option_index)
		"iranian_revolution_endgame": _event_58(ws, context)
		"economic_union": _event_59(ws, option_index)
		"military_alliance": _event_60(ws, option_index)
		"anthem_problem": _event_61(ws, option_index)
		"inner_mongolia_problem": _event_62(ws, option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors(ws)


func _event_53(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: -80, W.I_AGRICULTURE: -100,
				W.I_THOUGHT_FREEDOM: 50, W.I_PEOPLE_SUPPORT: -70, W.I_LIVING: -50})
			_change_all_politicians(ws, -100, 0)
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: -150, W.I_AGRICULTURE: 50,
				W.I_REFORM_MOMENTUM: 10, W.I_THOUGHT_FREEDOM: 30,
				W.I_DIPLO: -10, W.I_LIVING: 50, W.I_CORRUPTION: 15})
			_add_faction_ideology(ws, {FactionData.MODERATE: 80, FactionData.REFORMIST: 80})
			_change_politicians(ws, {1: [100, 120], 2: [100, 120]})
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -70, W.I_REFORM_MOMENTUM: 30,
				W.I_THOUGHT_FREEDOM: 50, W.I_PEOPLE_SUPPORT: 70, W.I_DIPLO: -20,
				W.I_USA_RELATIONS: 30, W.I_BUDGET: 40, W.I_MANPOWER: -30,
				W.I_CORRUPTION: 30})
			_add_empire_relation(ws, EmpireData.USA, 30)
			_add_faction_ideology(ws, {
				FactionData.MODERATE: 30, FactionData.REFORMIST: 100, FactionData.LIBERAL: 80,
			})
			_change_politicians(ws, {
				0: [-250, -100], 2: [100, 150], 3: [200, 150],
			})
		3:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_BUDGET: -50,
				W.I_PEOPLE_SUPPORT: 70, W.I_LIVING: 30,
				W.I_USSR_RELATIONS: 50, W.I_AGRICULTURE: 50})
			_add_empire_relation(ws, EmpireData.USSR, 50)
			_unlock_tech(ws, 2)
			_set_modifier_active(ws, 15, false)
			_subtract_faction_fraction(ws, FactionData.MODERATE, 0.09)
			_subtract_faction_fraction(ws, FactionData.REFORMIST, 0.50)
			_subtract_faction_fraction(ws, FactionData.LIBERAL, 0.24)
			_change_politicians(ws, {
				0: [150, 120], 1: [-100, -80], 2: [-150, -100], 3: [-200, -150],
			})


func _event_54(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: -150, W.I_DIPLO: 20,
				W.I_PEOPLE_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 80})
			_change_politicians(ws, {1: [-200, 0], 2: [-200, 0], 3: [-200, 0]})
		1:
			_add_data(ws, {W.I_BUDGET: 30, W.I_REFORM_MOMENTUM: 10,
				W.I_THOUGHT_FREEDOM: 70, W.I_DIPLO: -20, W.I_MANPOWER: -30})
			ws.数值表[W.I_REFORM_STAGE] = 3
			_add_empire_relation(ws, EmpireData.USA, 100)
			_add_faction_ideology(ws, {FactionData.MODERATE: 80, FactionData.REFORMIST: 80})
			ws.set_flag("sez", true)
			_change_politicians(ws, {1: [100, 120], 2: [150, 120]})
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -100, W.I_REFORM_MOMENTUM: 20,
				W.I_THOUGHT_FREEDOM: 100, W.I_PEOPLE_SUPPORT: 30, W.I_DIPLO: -30,
				W.I_BUDGET: 50, W.I_MANPOWER: -70})
			ws.数值表[W.I_REFORM_STAGE] = 3
			_add_empire_relation(ws, EmpireData.USA, 150)
			_add_faction_ideology(ws, {FactionData.REFORMIST: 50, FactionData.LIBERAL: 80})
			_subtract_faction_fraction(ws, FactionData.MODERATE, 0.09)
			ws.set_flag("sez", true)
			_change_politicians(ws, {
				0: [-250, -100], 1: [-80, -50], 2: [50, 100], 3: [200, 150],
			})


func _event_55(ws: WorldState, option_index: int) -> void:
	var burma := ws.get_country_by_legacy_index(33)
	match option_index:
		0:
			pass
		1:
			_add_data(ws, {W.I_BUDGET: -30, W.I_DIPLO: 10})
			_add_empire_relation(ws, EmpireData.USA, -50)
			if burma != null:
				burma.set_tag("对华贸易", true)
		2:
			_add_data(ws, {W.I_AGENTS: -40, W.I_DIPLO: 20, W.I_BUDGET: -20})
			_add_empire_relation(ws, EmpireData.USA, -80)
			if burma != null:
				burma.government = 1
				burma.set_tag("对华贸易", true)
				burma.set_tag("亲中", true)


func _event_56(ws: WorldState, option_index: int) -> void:
	var vietnam := ws.get_country_by_legacy_index(11)
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: -150, W.I_INFLUENCE: -20})
			ws.set_flag("vietnam_peace", true)
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_WAR_PRESSURE: 200, W.I_DIPLO: 20})
			_add_empire_relation(ws, EmpireData.USSR, -200)
			ws.war_state = 1
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -100, W.I_INFLUENCE: 10,
				W.I_USSR_RELATIONS: 200, W.I_COMMUNICATIONS: 40})
			_add_empire_relation(ws, EmpireData.USSR, 200)
			ws.set_flag("vietnam_peace", true)
			if vietnam != null:
				vietnam.set_tag("对华贸易", true)


func _event_57(ws: WorldState, option_index: int) -> void:
	if option_index != 1:
		return
	_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 20,
		W.I_BUDGET: -40, W.I_AGENTS: -60})
	_add_empire_relation(ws, EmpireData.USA, -150)
	var japan := ws.get_country_by_legacy_index(44)
	if japan != null:
		japan.government = 2
		japan.set_tag("亲美", false)


func _event_58(ws: WorldState, context: Dictionary) -> void:
	var left := ws.数值表[W.I_IRAN_LEFT_SUPPORT]
	var shah := ws.数值表[W.I_IRAN_SHAH_SUPPORT]
	var democrat := ws.数值表[W.I_IRAN_DEMOCRAT_SUPPORT]
	var islamist := ws.数值表[W.I_IRAN_ISLAMIST_SUPPORT]
	var iran := ws.get_country_by_legacy_index(8)
	if left > shah and left > democrat and left > islamist:
		_add_empire_power(ws, EmpireData.USA, -10)
		if iran != null:
			iran.government = 1
			iran.set_tag("亲美", false)
		context["result_text"] = "The left coalition won the revolution, suppressed Khomeini's uprising and proclaimed socialism with Islamic characteristics."
	elif shah > left and shah > democrat and shah > islamist:
		_add_empire_power(ws, EmpireData.USA, 10)
		context["result_text"] = "The Shah survived with Chinese and American support, crushed the opposition and then introduced limited concessions."
	elif democrat > left and democrat > shah and democrat > islamist:
		if iran != null:
			iran.government = 3
			iran.set_tag("亲美", false)
		context["result_text"] = "The democratic coalition overthrew the Shah, defeated the Islamist revolt and formed a multi-vector Islamic democracy."
	else:
		if iran != null:
			iran.set_tag("亲美", false)
		context["result_text"] = "No secular faction won outright; Khomeini's supporters seized power and proclaimed an Islamic republic."
	ws.set_flag("iran_revolution_started", false)


func _event_59(ws: WorldState, option_index: int) -> void:
	var china := ws.get_country_by_legacy_index(1)
	match option_index:
		0:
			pass
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: 30,
				W.I_PEOPLE_SUPPORT: 80, W.I_THOUGHT_FREEDOM: 50, W.I_BUDGET: -150})
			_add_empire_relation(ws, EmpireData.USSR, -100)
			_add_empire_relation(ws, EmpireData.USA, -100)
			if china != null:
				china.set_tag("econ", true)
			for country in ws.countries:
				if _is_legacy_range(country) and country.has_tag("亲中"):
					country.set_tag("econ", true)
			_change_all_politicians(ws, 100, 0)
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -100, W.I_INFLUENCE: -30,
				W.I_THOUGHT_FREEDOM: 100})
			_add_empire_relation(ws, EmpireData.USSR, 200)
			_add_empire_relation(ws, EmpireData.USA, -200)
			_add_empire_power(ws, EmpireData.USSR, 30)
			if china != null:
				china.stability = 1
				china.set_tag("sev", true)
			if ws.数值表[W.I_ALBANIA_BREAK] == 0:
				var albania := ws.get_country_by_legacy_index(20)
				if albania != null:
					albania.set_tag("亲中", false)
					albania.set_tag("econ", false)
					albania.set_tag("对华贸易", false)
					albania.set_tag("okb", false)
			for country in ws.countries:
				if country == null:
					continue
				var joins_cmea := country.has_tag("econ") and (
					country.has_tag("亲苏") or country.has_tag("亲中"))
				country.set_tag("econ", false)
				if joins_cmea:
					country.set_tag("sev", true)
			_change_politicians(ws, {2: [-200, 0], 3: [-200, 0]})


func _event_60(ws: WorldState, option_index: int) -> void:
	if option_index != 0:
		return
	_add_data(ws, {W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: 20,
		W.I_PEOPLE_SUPPORT: 80, W.I_BUDGET: -50, W.I_AGENTS: -50})
	_add_empire_relation(ws, EmpireData.USA, -200)
	_add_empire_relation(ws, EmpireData.USSR, -200)
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china.set_tag("okb", true)
	for country in ws.countries:
		if _is_legacy_range(country) and country.has_tag("亲中"):
			country.set_tag("okb", true)
	_change_all_politicians(ws, 100, 0)


func _event_61(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_BUDGET: -10, W.I_PEOPLE_SUPPORT: 20, W.I_PARTY_SUPPORT: 70})
			_change_politicians(ws, {1: [0, 50], 2: [0, 50]})
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: -100, W.I_DIPLO: 10,
				W.I_PEOPLE_SUPPORT: 40})
			_add_empire_relation(ws, EmpireData.USA, -50)
			_add_empire_relation(ws, EmpireData.USSR, -50)
			_change_politicians(ws, {0: [0, 50]})
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_DIPLO: 5,
				W.I_BUDGET: -10, W.I_PEOPLE_SUPPORT: 10})


func _event_62(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: -80, W.I_MANPOWER: 50,
				W.I_THOUGHT_FREEDOM: 20, W.I_PEOPLE_SUPPORT: 60, W.I_DIPLO: -10,
				W.I_REFORM_MOMENTUM: 10, W.I_BUDGET: -30, W.I_COMMUNICATIONS: 20})
			_add_empire_relation(ws, EmpireData.USA, 30)
			_add_empire_relation(ws, EmpireData.USSR, 100)
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: -20, W.I_MANPOWER: -150,
				W.I_PEOPLE_SUPPORT: -50})
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: 10, W.I_MANPOWER: 10,
				W.I_THOUGHT_FREEDOM: 30, W.I_PEOPLE_SUPPORT: 20,
				W.I_DIPLO: -5})
			_add_empire_relation(ws, EmpireData.USA, -50)
		3:
			_add_data(ws, {W.I_PARTY_SUPPORT: 30, W.I_BUDGET: -10,
				W.I_PEOPLE_SUPPORT: 30, W.I_DIPLO: -5, W.I_MANPOWER: 30,
				W.I_COMMUNICATIONS: 10})
		4:
			_add_data(ws, {W.I_PARTY_SUPPORT: -150, W.I_BUDGET: -60,
				W.I_PEOPLE_SUPPORT: 100, W.I_THOUGHT_FREEDOM: 50, W.I_DIPLO: -20,
				W.I_MANPOWER: -30, W.I_REFORM_MOMENTUM: 30, W.I_TERRITORY: 1})
			_add_empire_relation(ws, EmpireData.USA, 80)
			_add_empire_relation(ws, EmpireData.USSR, 150)


func _is_legacy_range(country: CountryData) -> bool:
	return country != null and country.原版序号 >= 2 and country.原版序号 < 53


func _unlock_tech(ws: WorldState, tech_index: int) -> void:
	if ws.techs != null and tech_index >= 0 and tech_index < ws.techs.unlocked.size():
		ws.techs.unlocked[tech_index] = true


func _set_modifier_active(ws: WorldState, modifier_index: int, active: bool) -> void:
	if modifier_index >= 0 and modifier_index < ws.modifiers.size() and ws.modifiers[modifier_index] != null:
		ws.modifiers[modifier_index].is_active = active


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


func _change_all_politicians(ws: WorldState, loyalty_delta: int, power_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null:
			politician.loyalty += loyalty_delta
			politician.power += power_delta


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
