extends RefCounted

## 原作阿富汗事件链：63 → 48 → 49/50/51 → 52。
## 来源：TimeScript.cs:3838-3889，doneventscript.cs:1225-1310,1499-1522，
##       Results_text.cs:4162-4648。
const W = preload("res://数据脚本/world_state.gd")


func execute(context: Dictionary) -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"afghan_april_revolution": _event_63(ws, option_index)
		"afghan_amin_coup": _event_48(ws, option_index)
		"afghan_soviet_plot": _event_49(ws, option_index, context)
		"afghan_civil_war": _event_50(ws, option_index)
		"afghan_soviet_intervention": _event_51(ws, option_index)
		"afghan_pakistan_border": _event_52(ws, option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors(ws)


func _event_63(ws: WorldState, option_index: int) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null:
		afghanistan.government = 1
		afghanistan.set_tag("亲苏", true)
	match option_index:
		0:
			_add_data(ws, {W.I_PARTY_SUPPORT: -80, W.I_INFLUENCE: -10,
				W.I_AFGHAN_OPPOSITION: 10, W.I_AFGHAN_KHALQ: 150, W.I_AFGHAN_PARCHAM: 100})
			_add_empire_power(ws, EmpireData.USSR, 30)
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_AGENTS: -30, W.I_DIPLO: -10,
				W.I_AFGHAN_OPPOSITION: 40, W.I_AFGHAN_KHALQ: 150, W.I_AFGHAN_PARCHAM: 100})
			_add_empire_power(ws, EmpireData.USSR, 30)
			_add_empire_relation(ws, EmpireData.USSR, -100)
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_AGENTS: -50, W.I_DIPLO: 20,
				W.I_INFLUENCE: -10, W.I_AFGHAN_OPPOSITION: 10,
				W.I_AFGHAN_KHALQ: 180, W.I_AFGHAN_PARCHAM: 100})
			_add_empire_power(ws, EmpireData.USSR, 30)
			_add_empire_relation(ws, EmpireData.USSR, -50)
		3:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_AGENTS: -60, W.I_DIPLO: 10,
				W.I_INFLUENCE: -10, W.I_AFGHAN_OPPOSITION: 10,
				W.I_AFGHAN_KHALQ: 140, W.I_AFGHAN_PARCHAM: 140})
			_add_empire_power(ws, EmpireData.USSR, 30)
			_add_empire_relation(ws, EmpireData.USSR, -50)


func _event_48(ws: WorldState, option_index: int) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null:
		afghanistan.government = 0
		afghanistan.set_tag("亲美", false)
	match option_index:
		0:
			pass
		1:
			_add_data(ws, {W.I_BUDGET: -20, W.I_DIPLO: 10})
			_add_empire_relation(ws, EmpireData.USSR, -100)
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_INFLUENCE: -10,
				W.I_COMMUNICATIONS: 40})
			ws.数值表[W.I_AFGHAN_PARCHAM] = 110
			_add_empire_relation(ws, EmpireData.USSR, 70)


func _event_49(ws: WorldState, option_index: int, context: Dictionary) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null:
		afghanistan.set_tag("亲美", false)
	match option_index:
		0:
			_add_empire_power(ws, EmpireData.USSR, 10)
			ws.数值表[W.I_INFLUENCE] += 20
			if ws.数值表[W.I_AFGHAN_PARCHAM] > 150:
				ws.数值表[W.I_AFGHAN_KHALQ] = 150
				ws.数值表[W.I_AFGHAN_PARCHAM] = 100
				ws.数值表[W.I_AFGHAN_WAR_PATH] = 9
				context["result_text"] = "The Soviet operation killed Amin and installed Khalqist security chief Assadullah Sarwari. Soviet troops continued entering Afghanistan."
			else:
				ws.数值表[W.I_AFGHAN_KHALQ] = 100
				ws.数值表[W.I_AFGHAN_PARCHAM] = 150
				context["result_text"] = "The Soviet operation killed Amin and installed Parcham leader Babrak Karmal. Soviet troops continued entering Afghanistan."
			if afghanistan != null: afghanistan.government = 1
		1:
			_add_data(ws, {W.I_AGENTS: -70, W.I_AFGHAN_OPPOSITION: 100,
				W.I_AFGHAN_PARCHAM: 180, W.I_DIPLO: 50})
			_add_empire_power(ws, EmpireData.USSR, -20)
			_add_empire_relation(ws, EmpireData.USSR, -400)
			if afghanistan != null:
				afghanistan.set_tag("亲苏", false)
				afghanistan.set_tag("亲中", true)
			_start_afghan_war(ws, "DRA", "Mujahideen", 500, 500, 1, -1, true)


func _event_50(ws: WorldState, option_index: int) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null: afghanistan.set_tag("亲美", false)
	match option_index:
		0:
			_start_afghan_war(ws, "DRA", "Mujahideen", 750, 250, 1, 0, true)
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 10,
				W.I_AFGHAN_OPPOSITION: 80, W.I_DIPLO: 20, W.I_COMMUNICATIONS: 30})
			_add_empire_power(ws, EmpireData.USSR, -20)
			_add_empire_relation(ws, EmpireData.USA, -250)
			_add_empire_relation(ws, EmpireData.USSR, 50)
			_start_afghan_war(ws, "DRA", "Mujahideen", 770, 230, 1, 0, true)
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -70, W.I_DIPLO: 10, W.I_COMMUNICATIONS: 20})
			_add_empire_power(ws, EmpireData.USSR, -20)
			_add_empire_relation(ws, EmpireData.USA, -300)
			_add_empire_relation(ws, EmpireData.USSR, 100)
			_start_afghan_war(ws, "DRA", "Mujahideen", 760, 240, 1, 0, true)
		3:
			_add_data(ws, {W.I_PARTY_SUPPORT: 50, W.I_DIPLO: 30})
			_add_empire_power(ws, EmpireData.USSR, -30)
			_add_empire_relation(ws, EmpireData.USSR, -150)
			_add_empire_relation(ws, EmpireData.USA, -150)
			_start_afghan_war(ws, "Maoists", "Other", 50, 950, 1, 1, false)
		4:
			ws.数值表[W.I_BUDGET] += 50
			_add_empire_power(ws, EmpireData.USSR, -30)
			_add_empire_relation(ws, EmpireData.USA, 200)
			_add_empire_relation(ws, EmpireData.USSR, -200)
			_start_afghan_war(ws, "DRA", "Mujahideen", 700, 300, 1, 0, true)


func _event_51(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			pass
		1:
			ws.数值表[W.I_DIPLO] -= 10
			_add_empire_relation(ws, EmpireData.USA, 80)
			_add_empire_relation(ws, EmpireData.USSR, -100)
		2:
			ws.数值表[W.I_PARTY_SUPPORT] -= 50
			_add_empire_relation(ws, EmpireData.USA, -110)
			_add_empire_relation(ws, EmpireData.USSR, 100)


func _event_52(ws: WorldState, option_index: int) -> void:
	var war := _war(ws, 5)
	if war == null:
		return
	match option_index:
		0:
			pass
		1:
			_add_data(ws, {W.I_DIPLO: 10, W.I_AGENTS: -40, W.I_ARMY: -50})
			_add_empire_relation(ws, EmpireData.USA, -100)
			_add_empire_relation(ws, EmpireData.USSR, 100)
			if war.ussr_side == 1:
				ws.数值表[W.I_AFGHAN_POLICY] = 1
			else:
				war.infl1 += 100
				war.infl2 -= 100
		2:
			_add_data(ws, {W.I_BUDGET: 30, W.I_DIPLO: -10})
			_add_empire_relation(ws, EmpireData.USA, 100)
			_add_empire_relation(ws, EmpireData.USSR, -120)
			war.infl1 -= 80
			war.infl2 += 80
			ws.数值表[W.I_AFGHAN_POLICY] = 2
		3:
			_add_data(ws, {W.I_BUDGET: -50, W.I_ARMY: -100, W.I_DIPLO: 30})
			_add_empire_relation(ws, EmpireData.USA, -100)
			_add_empire_relation(ws, EmpireData.USSR, -100)
			war.infl1 += 10
			war.infl2 -= 10
			ws.数值表[W.I_AFGHAN_POLICY] = 3
	_clamp_war(war)


func _start_afghan_war(
		ws: WorldState, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, apply_regional_modifiers: bool) -> void:
	GameManager.start_war(5, side1, side2, infl1, infl2, usa_side, maxi(ussr_side, 0))
	var war := _war(ws, 5)
	if war == null:
		return
	war.ussr_side = ussr_side
	if apply_regional_modifiers:
		var pakistan := ws.get_country_by_legacy_index(31)
		if pakistan != null and pakistan.has_tag("亲美"):
			war.infl1 -= 100
			war.infl2 += 100
		var iran := ws.get_country_by_legacy_index(8)
		if iran != null and iran.government == 0:
			war.infl1 -= 50
			war.infl2 += 50
		if ws.数值表[W.I_AFGHAN_WAR_PATH] == 9:
			war.infl1 += 25
			war.infl2 -= 25
	_clamp_war(war)


func _war(ws: WorldState, index: int) -> WarData:
	return ws.wars[index] if index >= 0 and index < ws.wars.size() else null


func _clamp_war(war: WarData) -> void:
	war.infl1 = clampi(war.infl1, 0, 1000)
	war.infl2 = clampi(war.infl2, 0, 1000)


func _add_data(ws: WorldState, changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.数值表.size():
			ws.数值表[index] += int(changes[raw_index])


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
