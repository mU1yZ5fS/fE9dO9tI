extends "res://数据脚本/event_script_base.gd"

## 原作阿富汗事件链：63 → 48 → 49/50/51 → 52。
## 来源：TimeScript.cs:3838-3889，doneventscript.cs:1225-1310,1499-1522，
##       Results_text.cs:4162-4648。

## 原版 Event48 result2 动态文案（领导人人名由 _leader_name() 插入）。
const TXT_48_R2_A := "event.script.event_048_052_063_afghanistan.c0"
const TXT_48_R2_B := "event.script.event_048_052_063_afghanistan.c1"

## 原版 Event49 result0 两分支文案。
const TXT_49_R0_SARWARI := "event.script.event_048_052_063_afghanistan.c2"
const TXT_49_R0_KARMAL := "event.script.event_048_052_063_afghanistan.c3"

## 原版 Event50 result2 动态文案。
const TXT_50_R2_A := "event.script.event_048_052_063_afghanistan.c4"
const TXT_50_R2_B := "event.script.event_048_052_063_afghanistan.c5"

## 原版 ingamewars[5] 中文侧名。
const WAR_AFGHAN_NAME := "event.script.event_048_052_063_afghanistan.c6"
const WAR_DRA := "event.script.event_048_052_063_afghanistan.c7"
const WAR_MUJAHIDEEN := "event.script.event_048_052_063_afghanistan.c8"
const WAR_MAOIST_NAME := "event.script.event_048_052_063_afghanistan.c9"
const WAR_MAOIST := "event.script.event_048_052_063_afghanistan.c10"
const WAR_JOINT_OPPOSITION := "event.script.event_048_052_063_afghanistan.c11"

## 原版 Event52 结果标题：善邻难做…


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"afghan_april_revolution": _event_63(option_index)
		"afghan_amin_coup": _event_48(option_index, context)
		"afghan_soviet_plot": _event_49(option_index, context)
		"afghan_civil_war": _event_50(option_index, context)
		"afghan_soviet_intervention": _event_51(option_index)
		"afghan_pakistan_border": _event_52(option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_63(option_index: int) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null:
		afghanistan.government = GameConstants.Government.SOCIALIST
		afghanistan.set_tag("亲苏", true)
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -80, W.I_INFLUENCE: -10,
				W.I_AFGHAN_OPPOSITION: 10, W.I_AFGHAN_KHALQ: 150, W.I_AFGHAN_PARCHAM: 100})
			_add_empire_power(EmpireData.USSR, 30)
		1:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_AGENTS: -30, W.I_DIPLO: -10,
				W.I_AFGHAN_OPPOSITION: 40, W.I_AFGHAN_KHALQ: 150, W.I_AFGHAN_PARCHAM: 100})
			_add_empire_power(EmpireData.USSR, 30)
			_add_empire_relation(EmpireData.USSR, -100)
		2:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_AGENTS: -50, W.I_DIPLO: 20,
				W.I_INFLUENCE: -10, W.I_AFGHAN_OPPOSITION: 10,
				W.I_AFGHAN_KHALQ: 180, W.I_AFGHAN_PARCHAM: 100})
			_add_empire_power(EmpireData.USSR, 30)
			_add_empire_relation(EmpireData.USSR, -50)
		3:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_AGENTS: -60, W.I_DIPLO: 10,
				W.I_INFLUENCE: -10, W.I_AFGHAN_OPPOSITION: 10,
				W.I_AFGHAN_KHALQ: 140, W.I_AFGHAN_PARCHAM: 140})
			_add_empire_power(EmpireData.USSR, 30)
			_add_empire_relation(EmpireData.USSR, -50)


func _event_48(option_index: int, context: Dictionary) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null:
		afghanistan.government = GameConstants.Government.AUTHORITARIAN
		afghanistan.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
		afghanistan.set_tag("亲美", false)
	match option_index:
		0:
			pass
		1:
			_add_data({W.I_BUDGET: -20, W.I_DIPLO: 10})
			_add_empire_relation(EmpireData.USSR, -100)
		2:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_INFLUENCE: -10,
				W.I_COMMUNICATIONS: 40})
			ws.afghan_parcham = 110
			_add_empire_relation(EmpireData.USSR, 70)
			context["result_text"] = tr(TXT_48_R2_A) + _leader_name() + tr(TXT_48_R2_B)


func _event_49(option_index: int, context: Dictionary) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null:
		afghanistan.set_tag("亲美", false)
	match option_index:
		0:
			_add_empire_power(EmpireData.USSR, 10)
			ws.influence_prc += 20
			if ws.afghan_parcham > 150:
				ws.afghan_khalq = 150
				ws.afghan_parcham = 100
				ws.afghan_war_path = 9
				context["result_text"] = tr(TXT_49_R0_SARWARI)
			else:
				ws.afghan_khalq = 100
				ws.afghan_parcham = 150
				context["result_text"] = tr(TXT_49_R0_KARMAL)
			if afghanistan != null:
				afghanistan.government = GameConstants.Government.SOCIALIST
				afghanistan.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		1:
			_add_data({W.I_AGENTS: -70, W.I_AFGHAN_OPPOSITION: 100,
				W.I_AFGHAN_PARCHAM: 180, W.I_DIPLO: 50})
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USSR, -400)
			if afghanistan != null:
				afghanistan.set_tag("亲苏", false)
				afghanistan.set_tag("亲中", true)
			_start_afghan_war(tr(WAR_DRA), tr(WAR_MUJAHIDEEN), 500, 500, 1, -1, true)


func _event_50(option_index: int, context: Dictionary) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null: afghanistan.set_tag("亲美", false)
	match option_index:
		0:
			_start_afghan_war(tr(WAR_DRA), tr(WAR_MUJAHIDEEN), 750, 250, 1, 0, true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 10,
				W.I_AFGHAN_OPPOSITION: 80, W.I_DIPLO: 20, W.I_COMMUNICATIONS: 30})
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USA, -250)
			_add_empire_relation(EmpireData.USSR, 50)
			_start_afghan_war(tr(WAR_DRA), tr(WAR_MUJAHIDEEN), 770, 230, 1, 0, true)
		2:
			_add_data({W.I_PARTY_SUPPORT: -70, W.I_DIPLO: 10, W.I_COMMUNICATIONS: 20})
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USA, -300)
			_add_empire_relation(EmpireData.USSR, 100)
			_start_afghan_war(tr(WAR_DRA), tr(WAR_MUJAHIDEEN), 760, 240, 1, 0, true)
			context["result_text"] = tr(TXT_50_R2_A) + _leader_name() + tr(TXT_50_R2_B)
		3:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_DIPLO: 30})
			_add_empire_power(EmpireData.USSR, -30)
			_add_empire_relation(EmpireData.USSR, -150)
			_add_empire_relation(EmpireData.USA, -150)
			_start_afghan_war(tr(WAR_MAOIST), tr(WAR_JOINT_OPPOSITION), 50, 950, 1, 1, false)
		4:
			ws.budget += 50
			_add_empire_power(EmpireData.USSR, -30)
			_add_empire_relation(EmpireData.USA, 200)
			_add_empire_relation(EmpireData.USSR, -200)
			_start_afghan_war(tr(WAR_DRA), tr(WAR_MUJAHIDEEN), 700, 300, 1, 0, true)


func _event_51(option_index: int) -> void:
	match option_index:
		0:
			pass
		1:
			ws.diplomatic_reputation -= 10
			_add_empire_relation(EmpireData.USA, 80)
			_add_empire_relation(EmpireData.USSR, -100)
		2:
			ws.party_support -= 50
			_add_empire_relation(EmpireData.USA, -110)
			_add_empire_relation(EmpireData.USSR, 100)


func _event_52(option_index: int) -> void:
	var war := _war(5)
	if war == null:
		return
	match option_index:
		0:
			pass
		1:
			_add_data({W.I_DIPLO: 10, W.I_AGENTS: -40, W.I_ARMY: -50})
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, 100)
			if war.ussr_side == GameConstants.WarSide.SIDE2:
				ws.afghan_policy = 1
			else:
				war.infl1 += 100
				war.infl2 -= 100
		2:
			_add_data({W.I_BUDGET: 30, W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USA, 100)
			_add_empire_relation(EmpireData.USSR, -120)
			war.infl1 -= 80
			war.infl2 += 80
			ws.afghan_policy = 2
		3:
			_add_data({W.I_BUDGET: -50, W.I_ARMY: -100, W.I_DIPLO: 30})
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, -100)
			war.infl1 += 10
			war.infl2 -= 10
			ws.afghan_policy = 3
	_clamp_war(war)


func _start_afghan_war(
		side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, apply_regional_modifiers: bool) -> void:
	game.start_war(5, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _war(5)
	if war == null:
		return
	if apply_regional_modifiers:
		var pakistan := ws.get_country_by_legacy_index(31)
		if pakistan != null and pakistan.has_tag("亲美"):
			war.infl1 -= 100
			war.infl2 += 100
		var iran := ws.get_country_by_legacy_index(8)
		if iran != null and iran.government == GameConstants.Government.AUTHORITARIAN:
			war.infl1 -= 50
			war.infl2 += 50
		if ws.afghan_war_path == 9:
			war.infl1 += 25
			war.infl2 -= 25
	_clamp_war(war)


func _war(index: int) -> WarData:
	return ws.wars[index] if index >= 0 and index < ws.wars.size() else null


func _clamp_war(war: WarData) -> void:
	war.infl1 = clampi(war.infl1, 0, 1000)
	war.infl2 = clampi(war.infl2, 0, 1000)


func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.size():
			ws.add_data_by_index(index, int(changes[raw_index]))


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.usa_relations = ws.empires[EmpireData.USA].relations
		ws.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.ussr_relations = ws.empires[EmpireData.USSR].relations
		ws.soviet_influence = ws.empires[EmpireData.USSR].power
