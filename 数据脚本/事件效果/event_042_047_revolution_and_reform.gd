extends "res://数据脚本/event_script_base.gd"

## 原作事件 42–47：伊朗革命、越南经互会、改革派夺权、改革开放、匈牙利与北京之春。
## 来源：TimeScript.cs:3793-3837，doneventscript.cs:1102-1244，
##       Results_text.cs:3667-4170。
const POLITICAL_TRANSITION = preload("res://数据脚本/事件效果/event_024_026_political_transition.gd")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"iranian_revolution": _event_42(option_index)
		"vietnam_cmea": _event_43(option_index)
		"reformers_take_power": _event_44(option_index)
		"reform_and_openness": _event_45()
		"hungarian_crisis": _event_46(option_index)
		"beijing_spring": _event_47(option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_42(option_index: int) -> void:
	var iran := ws.get_country_by_legacy_index(8)
	ws.set_flag("iran_revolution_started", true)
	match option_index:
		0:
			if iran != null: iran.development = 4
		1:
			_add_data({W.I_IRAN_LEFT_SUPPORT: 70, W.I_AGENTS: -50, W.I_DIPLO: 20})
			if iran != null: iran.development = 1
		2:
			_add_data({W.I_IRAN_ISLAMIST_SUPPORT: 70, W.I_AGENTS: -50, W.I_DIPLO: 20})
			if iran != null: iran.development = 3
		3:
			_add_data({W.I_IRAN_SHAH_SUPPORT: 70, W.I_AGENTS: -50, W.I_DIPLO: -10})
			if iran != null: iran.development = 0
		4:
			_add_data({W.I_IRAN_DEMOCRAT_SUPPORT: 70, W.I_AGENTS: -50, W.I_DIPLO: -20})
			if iran != null: iran.development = 2


func _event_43(option_index: int) -> void:
	var vietnam := ws.get_country_by_legacy_index(11)
	match option_index:
		0:
			ws.数值表[W.I_PARTY_SUPPORT] -= 50
			_add_empire_power(EmpireData.USSR, 30)
			if vietnam != null: vietnam.set_tag("sev", true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_AGENTS: -30})
			_add_empire_relation(EmpireData.USSR, -70)


func _event_44(option_index: int) -> void:
	match option_index:
		0:
			_apply_market_reform_base()
			var reform_leader := _faction_leader_index(FactionData.REFORMIST)
			if reform_leader >= 0:
				var transition = POLITICAL_TRANSITION.new()
				transition._swap_leader_with_politician(reform_leader, FactionData.REFORMIST)
			# 原作在身份互换后才按新 traits 结算权力变化。
			_change_politicians({0: [0, -200], 1: [0, 100], 2: [0, 200], 3: [0, 80]})
		1:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_PEOPLE_SUPPORT: -120,
				W.I_AGENTS: -150, W.I_THOUGHT_FREEDOM: 150, W.I_DIPLO: 30})
		2:
			_apply_market_reform_base()
			_change_politicians({0: [-250, -200], 1: [100, 100],
				2: [200, 200], 3: [70, 80]})
	PoliticianSystem.sync_in_power_flags(ws)


func _event_45() -> void:
	_add_data({W.I_INFLUENCE: -20, W.I_THOUGHT_FREEDOM: 50,
		W.I_REFORM_MOMENTUM: 20, W.I_DIPLO: -30})
	if ws.数值表[W.I_ECON_SYSTEM] == 10:
		ws.数值表[W.I_ECON_SYSTEM] = 12
	elif ws.数值表[W.I_ECON_SYSTEM] <= 14:
		ws.数值表[W.I_ECON_SYSTEM] += 1
	ws.数值表[W.I_REFORM_STAGE] = 2
	_add_empire_relation(EmpireData.USA, 100)
	var albania := ws.get_country_by_legacy_index(20)
	if albania != null:
		albania.set_tag("对华贸易", false)
		albania.set_tag("亲中", false)
	_change_politicians({1: [0, 50], 2: [0, 100], 3: [0, 50]})


func _event_46(option_index: int) -> void:
	var hungary := ws.get_country_by_legacy_index(4)
	match option_index:
		0:
			_add_empire_power(EmpireData.USSR, -10)
		1:
			_add_data({W.I_INFLUENCE: 20, W.I_AGENTS: -80, W.I_DIPLO: 20})
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USSR, -300)
			if hungary != null:
				hungary.government = 1
				hungary.set_tag("对华贸易", true)
				hungary.set_tag("亲苏", false)
		2:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_INFLUENCE: -15,
				W.I_AGENTS: -30, W.I_ARMY: -10, W.I_DIPLO: 40,
				W.I_SOVIET_SUCCESSOR_THIRD: -1, W.I_SOVIET_INTERVENTIONS: 1})
			_add_empire_relation(EmpireData.USSR, -150)
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_power(EmpireData.USA, -10)
			if hungary != null: hungary.government = 1
		3:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 10,
				W.I_DIPLO: 20, W.I_THOUGHT_FREEDOM: -40})
			_add_empire_relation(EmpireData.USSR, -80)
			_add_empire_power(EmpireData.USSR, -10)


func _event_47(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -80, W.I_THOUGHT_FREEDOM: 100,
				W.I_PEOPLE_SUPPORT: -80, W.I_DIPLO: 10})
			_subtract_faction_fraction(FactionData.REFORMIST, 0.05)
			_change_politicians({2: [-100, -100]})
		1:
			_add_data({W.I_PARTY_SUPPORT: 30, W.I_THOUGHT_FREEDOM: 80,
				W.I_PEOPLE_SUPPORT: -50, W.I_DIPLO: -10})
			_change_politicians({2: [50, 50]})
		2:
			_add_data({W.I_PARTY_SUPPORT: -80, W.I_THOUGHT_FREEDOM: 120,
				W.I_PEOPLE_SUPPORT: -60})
			_add_faction_ideology({FactionData.REFORMIST: 100})
			_change_politicians({2: [50, 150]})


func _apply_market_reform_base() -> void:
	_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: -20,
		W.I_THOUGHT_FREEDOM: 70, W.I_PEOPLE_SUPPORT: 60, W.I_DIPLO: -20})
	ws.数值表[W.I_REFORM_STAGE] = 1
	_add_empire_relation(EmpireData.USA, 100)
	_add_faction_ideology({
		FactionData.MODERATE: 300, FactionData.REFORMIST: 400, FactionData.LIBERAL: 250,
	})
	_subtract_faction_fraction(FactionData.MAOIST, 0.15)
	_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.15)


func _faction_leader_index(faction_index: int) -> int:
	if faction_index < 0 or faction_index >= ws.factions.size() or ws.factions[faction_index] == null:
		return -1
	var index := ws.factions[faction_index].leader_index
	return index if index >= 0 and index < ws.politicians.size() else -1


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.数值表.size():
			ws.数值表[index] += int(changes[raw_index])


func _change_politicians(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			var pair: Array = changes[politician.trait_personality]
			politician.loyalty += int(pair[0])
			politician.power += int(pair[1])


func _add_faction_ideology(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _subtract_faction_fraction(faction_index: int, fraction: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		var current := ws.factions[faction_index].ideology
		ws.factions[faction_index].ideology = current - int(float(current) * fraction)


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
