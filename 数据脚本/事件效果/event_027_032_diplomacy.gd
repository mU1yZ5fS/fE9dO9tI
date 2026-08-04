extends "res://数据脚本/event_script_base.gd"

## 原作由国家面板外交操作直接触发的事件 27–32。
## 来源：DiploButtonScript.cs:79-92,279-291,321-329,860-868,960-980,1010-1020,
##       Results_text.cs:2563-3168。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"hong_kong_macau": _event_27(option_index, context)
		"indonesia_after_suharto": _event_28(option_index)
		"pressure_north_korea": _event_29(option_index, context)
		"palestine_settlement": _event_30(option_index, context)
		"south_korea_election": _event_31(option_index)
		"mongolia_reform": _event_32(option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_27(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data(d, {W.I_PEOPLE_SUPPORT: 100, W.I_THOUGHT_FREEDOM: 100,
				W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: 20})
			d[W.I_HK_MACAU_STATUS] = 1
		1:
			if (d[W.I_DIPLO] <= 60 or d[W.I_INFLUENCE] >= 150) and _relation(EmpireData.USA) >= 800:
				_add_data(d, {W.I_PEOPLE_SUPPORT: 100, W.I_INFLUENCE: 50, W.I_PARTY_SUPPORT: 100})
				d[W.I_HK_MACAU_STATUS] = 1
			else:
				_set_negotiation_failure(context)
				_add_data(d, {W.I_PEOPLE_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 50,
					W.I_INFLUENCE: -30, W.I_PARTY_SUPPORT: -100})
		2:
			if (d[W.I_DIPLO] <= 50 or d[W.I_INFLUENCE] >= 250) and _relation(EmpireData.USA) >= 800:
				_add_data(d, {W.I_PEOPLE_SUPPORT: 120, W.I_PARTY_SUPPORT: 200, W.I_INFLUENCE: 100})
				d[W.I_HK_MACAU_STATUS] = 2
			else:
				_set_negotiation_failure(context)
				_add_data(d, {W.I_PEOPLE_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 50,
					W.I_INFLUENCE: -30, W.I_PARTY_SUPPORT: -100})


func _event_28(option_index: int) -> void:
	var indonesia := ws.get_country_by_legacy_index(50)
	match option_index:
		0:
			_add_power(EmpireData.USA, -20)
			_set_country(indonesia, 3, false, false, false)
		1:
			_add_power(EmpireData.USA, -40)
			ws.数值表[W.I_INFLUENCE] += 20
			_set_country(indonesia, 2, false, true, false)
			_change_loyalty(func(personality: int) -> bool: return personality <= 2, 70)
		2:
			_add_power(EmpireData.USA, -50)
			_add_data(ws.数值表, {W.I_INFLUENCE: 40, W.I_DIPLO: 20})
			_set_country(indonesia, 1, false, true, true)
			_change_loyalty(func(personality: int) -> bool: return personality <= 1, 100)


func _event_29(option_index: int, context: Dictionary) -> void:
	var north_korea := ws.get_country_by_legacy_index(10)
	match option_index:
		0:
			d[W.I_INFLUENCE] += 10
			_add_relation(EmpireData.USA, 70)
			_change_loyalty_split(1, -50, 50)
		1:
			if d[W.I_INFLUENCE] > _power(EmpireData.USSR):
				d[W.I_INFLUENCE] += 10
				_add_relation(EmpireData.USA, 100)
				_add_relation(EmpireData.USSR, -100)
				_add_power(EmpireData.USA, 30)
				_change_loyalty_split(1, -100, 100)
				if north_korea != null:
					north_korea.government = 2
			else:
				_set_korea_soviet_result(context)
				_apply_korea_soviet_turn(north_korea)
		2:
			d[W.I_INFLUENCE] += 10
			d[W.I_BUDGET] += 40
			_change_loyalty(func(personality: int) -> bool: return personality >= 1, 100)
		3:
			_set_korea_soviet_result(context)
			_apply_korea_soviet_turn(north_korea)


func _event_30(option_index: int, context: Dictionary) -> void:
	var israel := ws.get_country_by_legacy_index(37)
	match option_index:
		0:
			if d[W.I_INFLUENCE] >= 150:
				d[W.I_INFLUENCE] += 10
				_add_relation(EmpireData.USSR, 100)
				_add_relation(EmpireData.USA, -50)
				d[W.I_PALESTINE_STATUS] = 2
				if israel != null: israel.set_tag("亲美", false)
			else:
				_apply_peace_failure(context)
		1:
			d[W.I_INFLUENCE] += 10
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, 50)
			d[W.I_PALESTINE_STATUS] = 1
		2:
			var player := ws.get_player_country()
			var oar_active := ws.get_flag("oar_founded") or (player != null and player.has_tag("oar"))
			if d[W.I_INFLUENCE] >= 200 and oar_active:
				d[W.I_INFLUENCE] += 30
				_add_relation(EmpireData.USA, -50)
				_add_relation(EmpireData.USSR, 100)
				d[W.I_PALESTINE_STATUS] = 3
				if israel != null:
					israel.set_tag("亲美", false)
					israel.set_tag("亲中", true)
			else:
				_apply_peace_failure(context)


func _event_31(option_index: int) -> void:
	var south_korea := ws.get_country_by_legacy_index(46)
	match option_index:
		0:
			ws.数值表[W.I_INFLUENCE] -= 10
			if south_korea != null: south_korea.government = 3
		1:
			_add_data(ws.数值表, {W.I_AGENTS: -40, W.I_INFLUENCE: 5})
			_add_relation(EmpireData.USA, -100)
			if south_korea != null: south_korea.government = 3
		2:
			_add_data(ws.数值表, {W.I_INFLUENCE: 20, W.I_DIPLO: 10, W.I_AGENTS: -60})
			_add_relation(EmpireData.USA, -250)
			if south_korea != null:
				south_korea.set_tag("亲美", false)
				south_korea.government = 2


func _event_32(option_index: int) -> void:
	var mongolia := ws.get_country_by_legacy_index(9)
	match option_index:
		0:
			_add_power(EmpireData.USSR, 10)
			_add_relation(EmpireData.USSR, -100)
		1:
			ws.数值表[W.I_AGENTS] -= 40
			_add_relation(EmpireData.USSR, -100)
			ws.数值表[W.I_INFLUENCE] += 5
			if mongolia != null: mongolia.set_tag("亲苏", false)


func _add_data(data: Array[int], changes: Dictionary) -> void:
	for raw_index in changes:
		data[int(raw_index)] += int(changes[raw_index])


func _relation(empire_index: int) -> int:
	return ws.empires[empire_index].relations if empire_index >= 0 and empire_index < ws.empires.size() else 0


func _power(empire_index: int) -> int:
	return ws.empires[empire_index].power if empire_index >= 0 and empire_index < ws.empires.size() else 0


func _add_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size():
		ws.empires[empire_index].relations += delta


func _add_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size():
		ws.empires[empire_index].power += delta


func _change_loyalty(predicate: Callable, delta: int) -> void:
	for politician in ws.politicians:
		if politician != null and predicate.call(politician.trait_personality):
			politician.loyalty += delta


func _change_loyalty_split(threshold: int, low_delta: int, high_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null:
			politician.loyalty += low_delta if politician.trait_personality <= threshold else high_delta


func _set_country(country: CountryData, government: int, pro_usa: bool, trade: bool, pro_china: bool) -> void:
	if country == null:
		return
	country.government = government
	country.set_tag("亲美", pro_usa)
	country.set_tag("对华贸易", trade)
	country.set_tag("亲中", pro_china)


func _apply_korea_soviet_turn(north_korea: CountryData) -> void:
	_add_power(EmpireData.USSR, 20)
	_add_data(ws.数值表, {W.I_INFLUENCE: -20, W.I_PARTY_SUPPORT: -100})
	if north_korea != null:
		north_korea.set_tag("亲苏", true)
		north_korea.set_tag("亲中", false)
		north_korea.set_tag("对华贸易", false)


func _apply_peace_failure(context: Dictionary) -> void:
	context["result_text"] = "Despite our efforts, the parties rejected the proposal and the negotiations failed."
	_add_relation(EmpireData.USA, -100)
	_add_data(ws.数值表, {W.I_INFLUENCE: -20, W.I_PARTY_SUPPORT: -100})


func _set_negotiation_failure(context: Dictionary) -> void:
	context["result_text"] = ("Britain and Portugal rejected our conditions as unacceptable. The transfer "
			+ "of the colonies has been postponed, apart from the existing New Territories commitment.")


func _set_korea_soviet_result(context: Dictionary) -> void:
	context["result_text"] = ("Kim Il-sung rejected our demands and obtained Soviet aid and troops, "
			+ "placing the DPRK firmly inside the Soviet sphere.")


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
