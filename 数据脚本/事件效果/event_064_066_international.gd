extends "res://数据脚本/event_script_base.gd"

## 原作事件 64–66：泛阿拉伯统一、莫斯科奥运会与铁托逝世。
## 来源：TimeScript.cs:3890-3918，doneventscript.cs:1523-1636，
##       Results_text.cs:5429-5690。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"pan_arabism": _event_64(option_index)
		"moscow_olympics": _event_65(option_index, context)
		"death_of_tito": _event_66(option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_64(option_index: int) -> void:
	if option_index == 0:
		_add_empire_power(EmpireData.USA, 10)
		return
	_add_data({W.I_BUDGET: -70, W.I_AGENTS: -50, W.I_DIPLO: 10,
		W.I_MANPOWER: -30, W.I_INFLUENCE: 10})
	_add_empire_relation(EmpireData.USSR, 80)
	_add_empire_relation(EmpireData.USA, -70)
	_add_empire_power(EmpireData.USSR, 10)
	_add_empire_power(EmpireData.USA, -10)
	ws.set_flag("oar", true)
	_add_faction_ideology({FactionData.MODERATE: 24, FactionData.REFORMIST: 24})
	_change_politicians({1: [100, 120], 2: [100, 120]})


func _event_65(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 150, W.I_PEOPLE_SUPPORT: 80,
				W.I_DIPLO: -20, W.I_INFLUENCE: 10, W.I_BUDGET: -40})
			_add_empire_power(EmpireData.USSR, 20)
			_add_empire_relation(EmpireData.USSR, 250)
			_add_empire_relation(EmpireData.USA, -100)
		1:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -100,
				W.I_INFLUENCE: -20})
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_relation(EmpireData.USA, -150)
			_add_empire_relation(EmpireData.USSR, -50)
		2:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: 50,
				W.I_INFLUENCE: -10, W.I_BUDGET: -40, W.I_THOUGHT_FREEDOM: 60})
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_relation(EmpireData.USA, 80)
			_add_empire_relation(EmpireData.USSR, 50)
		3:
			_add_data({W.I_PARTY_SUPPORT: 70, W.I_PEOPLE_SUPPORT: 30,
				W.I_THOUGHT_FREEDOM: 60, W.I_BUDGET: -30})
			_add_empire_relation(EmpireData.USA, 200)
			_add_empire_relation(EmpireData.USSR, -200)
		4:
			_add_data({W.I_PARTY_SUPPORT: 200, W.I_PEOPLE_SUPPORT: 50,
				W.I_INFLUENCE: 20, W.I_BUDGET: -200})
			_add_empire_relation(EmpireData.USA, -50)
			_add_empire_relation(EmpireData.USSR, -50)
			var reputation := ws.数值表[W.I_DIPLO]
			if reputation >= 85:
				context["result_text"] = "GANEFO was revived, but only sixteen African military regimes accepted China's invitation."
			elif reputation >= 65:
				context["result_text"] = "GANEFO was revived with broad participation from the Non-Aligned Movement."
			else:
				context["result_text"] = "GANEFO was revived with unexpectedly universal participation, including secondary Soviet and American teams."


func _event_66(option_index: int) -> void:
	match option_index:
		0:
			ws.数值表[W.I_DIPLO] -= 10
			_add_empire_relation(EmpireData.USA, 20)
			_add_empire_relation(EmpireData.USSR, 20)
		1:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_DIPLO: -20})
			_add_empire_relation(EmpireData.USA, 50)
			_add_empire_relation(EmpireData.USSR, 50)
			var yugoslavia := ws.get_country_by_legacy_index(15)
			if yugoslavia != null:
				yugoslavia.set_tag("对华贸易", true)
			var albania := ws.get_country_by_legacy_index(20)
			if albania != null and albania.has_tag("亲中"):
				albania.set_tag("对华贸易", false)
				albania.set_tag("亲中", false)
		2:
			_add_data({W.I_PARTY_SUPPORT: -30, W.I_DIPLO: -15})
			_add_empire_relation(EmpireData.USSR, 30)
			_add_empire_relation(EmpireData.USA, 30)
		3:
			ws.数值表[W.I_DIPLO] += 10


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
