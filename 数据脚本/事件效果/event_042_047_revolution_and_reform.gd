extends "res://数据脚本/event_script_base.gd"

## 原作事件 42–47：伊朗革命、越南经互会、改革派夺权、改革开放、匈牙利与北京之春。
## 来源：TimeScript.cs:3793-3837，doneventscript.cs:1102-1244，
##       Results_text.cs:3667-4170。

## 原版 Event42 选项1 的第二种禁用文案（agents>=50 但 political_line>1）。
const TXT_42_OPT1_DIS_USA := "event.script.event_042_047_revolution_and_reform.c0"

## 原版 Event43 描述（越南是否社会主义两分支）。
const TXT_43_DESC_COMMON := "event.script.event_042_047_revolution_and_reform.c1"
const TXT_43_DESC_SOCIALIST := "event.script.event_042_047_revolution_and_reform.c2"
const TXT_43_DESC_NOT_SOCIALIST := "event.script.event_042_047_revolution_and_reform.c3"

## 原版 Event44 动态文案（TextOfEvents / VariantsOfEvents）。
const TXT_44_TITLE_DENG := "event.script.event_042_047_revolution_and_reform.c4"
const TXT_44_TITLE_YE := "event.script.event_042_047_revolution_and_reform.c5"
const TXT_44_TITLE_REFORM := "event.script.event_042_047_revolution_and_reform.c6"
const TXT_44_DESC_A1 := "event.script.event_042_047_revolution_and_reform.c7"
const TXT_44_DESC_A2 := "event.script.event_042_047_revolution_and_reform.c8"
const TXT_44_DESC_A3_DENG := "event.script.event_042_047_revolution_and_reform.c9"
const TXT_44_DESC_A4_DENG := "event.script.event_042_047_revolution_and_reform.c10"
const TXT_44_DESC_A3_YE := "event.script.event_042_047_revolution_and_reform.c11"
const TXT_44_DESC_A4_YE := "event.script.event_042_047_revolution_and_reform.c12"
const TXT_44_DESC_A3_REF := "event.script.event_042_047_revolution_and_reform.c13"
const TXT_44_DESC_A4_REF := "event.script.event_042_047_revolution_and_reform.c14"
const TXT_44_DESC_A5_REF := "event.script.event_042_047_revolution_and_reform.c15"
const TXT_44_DESC_A6_REF := "event.script.event_042_047_revolution_and_reform.c16"
const TXT_44_OPT0_DENG := "event.script.event_042_047_revolution_and_reform.c17"
const TXT_44_OPT0_YE := "event.script.event_042_047_revolution_and_reform.c18"
const TXT_44_OPT0_REF_PREFIX := "event.script.event_042_047_revolution_and_reform.c19"
const TXT_44_OPT0_REF_SUFFIX := "event.script.event_042_047_revolution_and_reform.c20"

## 原版 Event44 结果文案（ResultsOfEvents）。
const TXT_44_R_LEADER_PREFIX := "event.script.event_042_047_revolution_and_reform.c21"
const TXT_44_R_DENG_ACCEPT := "event.script.event_042_047_revolution_and_reform.c22"
const TXT_44_R_COMMON_2 := "event.script.event_042_047_revolution_and_reform.c23"
const TXT_44_R_COMMON_3 := "event.script.event_042_047_revolution_and_reform.c24"
const TXT_44_R_COMMON_4_DENG := "event.script.event_042_047_revolution_and_reform.c25"
const TXT_44_R_YE_ACCEPT := "event.script.event_042_047_revolution_and_reform.c26"
const TXT_44_R_COMMON_3_YE := "event.script.event_042_047_revolution_and_reform.c27"
const TXT_44_R_COMMON_4_YE := "event.script.event_042_047_revolution_and_reform.c28"
const TXT_44_R_REF_ACCEPT_PREFIX := "event.script.event_042_047_revolution_and_reform.c29"
const TXT_44_R_REF_ACCEPT_SUFFIX := "event.script.event_042_047_revolution_and_reform.c30"
const TXT_44_R_REF_COMMON_3 := "event.script.event_042_047_revolution_and_reform.c31"
const TXT_44_R_REF_COMMON_4 := "event.script.event_042_047_revolution_and_reform.c32"
const TXT_44_R_REF_COMMON_5 := "event.script.event_042_047_revolution_and_reform.c33"
const TXT_44_R_REF_COMMON_6 := "event.script.event_042_047_revolution_and_reform.c34"
const TXT_44_R2_COMMON_4_DENG := "event.script.event_042_047_revolution_and_reform.c35"
const TXT_44_R2_COMMON_4_YE := "event.script.event_042_047_revolution_and_reform.c36"
const TXT_44_R2_COMMON_5 := "event.script.event_042_047_revolution_and_reform.c37"
const TXT_44_R2_COMMON_6 := "event.script.event_042_047_revolution_and_reform.c38"
const TXT_44_R1_A := "event.script.event_042_047_revolution_and_reform.c39"
const TXT_44_R1_B := "event.script.event_042_047_revolution_and_reform.c40"
const TXT_44_R1_C := "event.script.event_042_047_revolution_and_reform.c41"


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	ws = p_ws
	match str(event_def.event_id):
		"iranian_revolution":
			_prepare_42(event_def)
		"vietnam_cmea":
			_prepare_43(event_def)
		"reformers_take_power":
			_prepare_44(event_def)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"iranian_revolution": _event_42(option_index)
		"vietnam_cmea": _event_43(option_index)
		"reformers_take_power": _event_44(option_index, context)
		"reform_and_openness": _event_45()
		"hungarian_crisis": _event_46(option_index)
		"beijing_spring": _event_47(option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _prepare_42(event_def: EventDef) -> void:
	if event_def == null or event_def.options.size() < 2:
		return
	var opt := event_def.options[1]
	if ws.agents < 50:
		opt.disabled_text = "我们爱莫能助"
	elif ws.political_line > 1:
		opt.disabled_text = tr(TXT_42_OPT1_DIS_USA)
	else:
		opt.disabled_text = ""

func _prepare_43(event_def: EventDef) -> void:
	var vietnam := ws.get_country_by_legacy_index(23)
	if vietnam != null and vietnam.government == GameConstants.Government.SOCIALIST:
		event_def.description = tr(TXT_43_DESC_COMMON) + tr(TXT_43_DESC_SOCIALIST)
	else:
		event_def.description = tr(TXT_43_DESC_COMMON) + tr(TXT_43_DESC_NOT_SOCIALIST)


func _prepare_44(event_def: EventDef) -> void:
	var deng := _find_politician(13, 13)
	var ye := _find_politician(8, 8)
	if deng >= 0:
		event_def.title = tr(TXT_44_TITLE_DENG)
		event_def.description = tr(TXT_44_DESC_A1) + _leader_name() + tr(TXT_44_DESC_A2) + _leader_name() + tr(TXT_44_DESC_A3_DENG) + _leader_name() + tr(TXT_44_DESC_A4_DENG)
		if event_def.options.size() > 0:
			event_def.options[0].text = tr(TXT_44_OPT0_DENG)
	elif ye >= 0:
		event_def.title = tr(TXT_44_TITLE_YE)
		event_def.description = tr(TXT_44_DESC_A1) + _leader_name() + tr(TXT_44_DESC_A2) + _leader_name() + tr(TXT_44_DESC_A3_YE) + _leader_name() + tr(TXT_44_DESC_A4_YE)
		if event_def.options.size() > 0:
			event_def.options[0].text = tr(TXT_44_OPT0_YE)
	else:
		var ref_leader := _faction_leader_name(FactionData.REFORMIST)
		event_def.title = tr(TXT_44_TITLE_REFORM)
		event_def.description = tr(TXT_44_DESC_A1) + _leader_name() + tr(TXT_44_DESC_A2) + _leader_name() + tr(TXT_44_DESC_A3_REF) + ref_leader + tr(TXT_44_DESC_A4_REF) + _leader_name() + tr(TXT_44_DESC_A5_REF) + ref_leader + tr(TXT_44_DESC_A6_REF)
		if event_def.options.size() > 0:
			event_def.options[0].text = tr(TXT_44_OPT0_REF_PREFIX) + ref_leader + tr(TXT_44_OPT0_REF_SUFFIX)


func _event_42(option_index: int) -> void:
	var iran := ws.get_country_by_legacy_index(8)
	ws.set_flag("iran_revolution_started", true)
	# 原版 Event42.cs 三选项均设 iranrev=true，供战争图标特殊标记与后续事件链使用。
	ws.set_flag("iranrev", true)
	match option_index:
		0:
			if iran != null: iran.development = 4
		1:
			_add_data({W.I_IRAN_LEFT_SUPPORT: 70, W.I_AGENTS: -50, W.I_DIPLO: 20})
			if iran != null: iran.development = 1
		2:
			_add_data({W.I_IRAN_SHAH_SUPPORT: 70, W.I_AGENTS: -50, W.I_DIPLO: -10})
			if iran != null:
				iran.development = 0
				iran.set_tag("对华贸易", true)
		# 原版 Event42.cs 只有 3 个选项：0=不干涉、1=左翼、2=沙阿。
		# 旧 Godot 实现自造的伊斯兰/民主派分支（result 3~5）已删除。


func _event_43(option_index: int) -> void:
	var vietnam := ws.get_country_by_legacy_index(11)
	match option_index:
		0:
			ws.party_support -= 50
			_add_empire_power(EmpireData.USSR, 30)
			if vietnam != null: vietnam.set_tag("sev", true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_AGENTS: -30})
			_add_empire_relation(EmpireData.USSR, -70)


func _event_44(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			# 原版 result0 共同效果：LeaderAsset/MoneyLevel/ServeRMB 建模说明，跳过。
			_set_modifier_active(3, false)
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: -20,
				W.I_THOUGHT_FREEDOM: 70, W.I_PEOPLE_SUPPORT: 60, W.I_DIPLO: -20})
			ws.reform_stage = 1
			_add_empire_relation(EmpireData.USA, 100)
			_subtract_faction_fraction(FactionData.MAOIST, 0.15)
			_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.15)
			var deng := _find_politician(13, 13)
			var ye := _find_politician(8, 8)
			if deng >= 0:
				ws.factions[FactionData.REFORMIST].leader_index = deng
				context["result_text"] = _build_44_result0_deng()
			elif ye >= 0:
				ws.factions[FactionData.REFORMIST].leader_index = ye
				ws.press_policy = 16
				context["result_text"] = _build_44_result0_ye()
			else:
				context["result_text"] = _build_44_result0_generic()
			_kill_politician_if_exists(11, 11)
			_kill_politician_if_exists(6, 6)
			ws.party_system = 7
			_change_politicians({0: [-500, -200], 1: [-100, 100], 2: [200, 200], 3: [70, 80]})
			var reform_leader := _faction_leader_index(FactionData.REFORMIST)
			if reform_leader >= 0:
				_swap_leader_with_politician(reform_leader)
			PoliticianSystem.sync_in_power_flags(ws)
		1:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_PEOPLE_SUPPORT: -120,
				W.I_AGENTS: -150, W.I_THOUGHT_FREEDOM: 150, W.I_DIPLO: 30})
			_kill_faction_leader(FactionData.REFORMIST)
			_kill_politician_if_exists(13, 13)
			_kill_politician_if_exists(8, 8)
			context["result_text"] = _leader_name() + tr(TXT_44_R1_A) + _leader_name() + tr(TXT_44_R1_B) + _leader_name() + tr(TXT_44_R1_C)
		2:
			_set_modifier_active(3, false)
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: -20,
				W.I_THOUGHT_FREEDOM: 70, W.I_PEOPLE_SUPPORT: 60, W.I_DIPLO: -20})
			ws.reform_stage = 1
			_add_empire_relation(EmpireData.USA, 100)
			_subtract_faction_fraction(FactionData.MAOIST, 0.15)
			_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.15)
			_change_politicians({0: [-500, -200], 1: [-100, 100], 2: [200, 200], 3: [70, 80]})
			var deng2 := _find_politician(13, 13)
			var ye2 := _find_politician(8, 8)
			if deng2 > 0:
				ws.factions[FactionData.REFORMIST].leader_index = deng2
				context["result_text"] = _build_44_result2_deng()
			elif ye2 > 0:
				ws.factions[FactionData.REFORMIST].leader_index = ye2
				ws.press_policy = 16
				context["result_text"] = _build_44_result2_ye()
			else:
				context["result_text"] = _build_44_result2_generic()
			_kill_politician_if_exists(11, 11)
			_kill_politician_if_exists(6, 6)
			ws.party_system = 7
			PoliticianSystem.sync_in_power_flags(ws)
	# 原版 NewPolitician[4]=false / party_change[] 仅 UI 缓冲，建模说明。


func _event_45() -> void:
	_add_data({W.I_INFLUENCE: -20, W.I_THOUGHT_FREEDOM: 50,
		W.I_REFORM_MOMENTUM: 20, W.I_DIPLO: -30})
	if ws.econ_system == 10:
		ws.econ_system = 12
	elif ws.econ_system <= 14:
		ws.econ_system += 1
	ws.reform_stage = 2
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
			_add_ussr_leader_support(6, -1)
			if hungary != null:
				hungary.government = GameConstants.Government.SOCIALIST
				hungary.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				hungary.set_tag("对华贸易", true)
				hungary.set_tag("亲苏", false)
		2:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_INFLUENCE: -15,
				W.I_AGENTS: -30, W.I_ARMY: -10, W.I_DIPLO: 40,
				W.I_SOVIET_INTERVENTIONS: 1})
			_add_empire_relation(EmpireData.USSR, -150)
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_power(EmpireData.USA, -10)
			_add_ussr_leader_support(6, -2)
			if hungary != null:
				hungary.government = GameConstants.Government.SOCIALIST
				hungary.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				hungary.puppet_of = 7
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
			# 原版 party_change[3]=1f 仅 UI 缓冲，端口无等价，跳过。
			_change_politicians({2: [50, 150]})


# ── Event44 文案组装 ──

func _build_44_result0_deng() -> String:
	return (tr(TXT_44_R_LEADER_PREFIX) + _leader_name() + tr(TXT_44_R_DENG_ACCEPT)
			+ _leader_name() + tr(TXT_44_R_COMMON_2) + _leader_name()
			+ tr(TXT_44_R_COMMON_3) + _leader_name() + tr(TXT_44_R_COMMON_4_DENG))


func _build_44_result0_ye() -> String:
	return (tr(TXT_44_R_LEADER_PREFIX) + _leader_name() + tr(TXT_44_R_YE_ACCEPT)
			+ _leader_name() + tr(TXT_44_R_COMMON_2) + _leader_name()
			+ tr(TXT_44_R_COMMON_3_YE) + _leader_name() + tr(TXT_44_R_COMMON_4_YE))


func _build_44_result0_generic() -> String:
	var ref_leader := _faction_leader_name(FactionData.REFORMIST)
	return (tr(TXT_44_R_LEADER_PREFIX) + _leader_name() + tr(TXT_44_R_REF_ACCEPT_PREFIX)
			+ ref_leader + tr(TXT_44_R_REF_ACCEPT_SUFFIX) + _leader_name()
			+ tr(TXT_44_R_COMMON_2) + _leader_name() + tr(TXT_44_R_REF_COMMON_3)
			+ ref_leader + tr(TXT_44_R_REF_COMMON_4) + _leader_name()
			+ tr(TXT_44_R_REF_COMMON_5) + ref_leader + tr(TXT_44_R_REF_COMMON_6))


func _build_44_result2_deng() -> String:
	return (tr(TXT_44_R_LEADER_PREFIX) + _leader_name() + tr(TXT_44_R_DENG_ACCEPT)
			+ _leader_name() + tr(TXT_44_R_COMMON_2) + _leader_name()
			+ tr(TXT_44_R_COMMON_3) + _leader_name() + tr(TXT_44_R2_COMMON_4_DENG))


func _build_44_result2_ye() -> String:
	return (tr(TXT_44_R_LEADER_PREFIX) + _leader_name() + tr(TXT_44_R_YE_ACCEPT)
			+ _leader_name() + tr(TXT_44_R_COMMON_2) + _leader_name()
			+ tr(TXT_44_R_COMMON_3_YE) + _leader_name() + tr(TXT_44_R2_COMMON_4_YE))


func _build_44_result2_generic() -> String:
	var ref_leader := _faction_leader_name(FactionData.REFORMIST)
	return (tr(TXT_44_R_LEADER_PREFIX) + _leader_name() + tr(TXT_44_R_REF_ACCEPT_PREFIX)
			+ ref_leader + tr(TXT_44_R_REF_ACCEPT_SUFFIX) + _leader_name()
			+ tr(TXT_44_R_COMMON_2) + _leader_name() + tr(TXT_44_R_REF_COMMON_3)
			+ ref_leader + tr(TXT_44_R_REF_COMMON_4) + _leader_name()
			+ tr(TXT_44_R2_COMMON_5) + ref_leader + tr(TXT_44_R2_COMMON_6))


func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _faction_leader_name(faction_index: int) -> String:
	if faction_index < 0 or faction_index >= ws.factions.size():
		return "改革派领袖"
	var faction: FactionData = ws.factions[faction_index]
	if faction == null:
		return "改革派领袖"
	var idx := faction.leader_index
	if idx < 0 or idx >= ws.politicians.size() or ws.politicians[idx] == null:
		return "改革派领袖"
	var p: PoliticianData = ws.politicians[idx]
	if p.name_display != "":
		return p.name_display
	return "改革派领袖"


func _find_politician(name_first: int, name_last: int) -> int:
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p != null and p.name_first == name_first and p.name_last == name_last:
			return i
	return -1


func _kill_politician_if_exists(name_first: int, name_last: int) -> void:
	var idx := _find_politician(name_first, name_last)
	if idx >= 0:
		game.kill_politician(idx)


func _kill_faction_leader(faction_index: int) -> void:
	var idx := _faction_leader_index(faction_index)
	if idx >= 0:
		game.kill_politician(idx)


func _faction_leader_index(faction_index: int) -> int:
	if faction_index < 0 or faction_index >= ws.factions.size() or ws.factions[faction_index] == null:
		return -1
	var index := ws.factions[faction_index].leader_index
	return index if index >= 0 and index < ws.politicians.size() else -1


func _set_modifier_active(modifier_index: int, active: bool) -> void:
	if modifier_index >= 0 and modifier_index < ws.modifiers.size() and ws.modifiers[modifier_index] != null:
		ws.modifiers[modifier_index].is_active = active


func _add_ussr_leader_support(leader_index: int, delta: int) -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		var ussr = ws.empires[EmpireData.USSR]
		if leader_index >= 0 and leader_index < ussr.leaders.size() and ussr.leaders[leader_index] != null:
			ussr.leaders[leader_index].support += delta


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.size():
			ws.add_data_by_index(index, int(changes[raw_index]))


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
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.usa_relations = ws.empires[EmpireData.USA].relations
		ws.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.ussr_relations = ws.empires[EmpireData.USSR].relations
		ws.soviet_influence = ws.empires[EmpireData.USSR].power
