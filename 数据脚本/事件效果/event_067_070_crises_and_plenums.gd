extends "res://数据脚本/event_script_base.gd"

## 原作事件 67–70：波兰危机、光州起义与改革/保守两条五中全会清洗路线。
## 来源：TimeScript.cs:3919-3971，doneventscript.cs:1637-1766，
##       Results_text.cs:5691-6167。



## 事件 67–70 逐字中文文案。
## 来源：Event67.cs / Event68.cs / Event69.cs / Event70.cs。
## 说明：{0}{1} 为原版领袖姓名字段占位，显示前由 _fmt_leader() 替换为 name_display。

const TXT_67_TITLE := "event.script.event_067_070_crises_and_plenums.c0"
const TXT_67_DESC := "event.script.event_067_070_crises_and_plenums.c1"
const TXT_67_OPT0 := "event.script.event_067_070_crises_and_plenums.c2"
const TXT_67_OPT1 := "event.script.event_067_070_crises_and_plenums.c3"
const TXT_67_OPT2 := "event.script.event_067_070_crises_and_plenums.c4"
const TXT_67_OPT2_DIS := "event.script.event_067_070_crises_and_plenums.c5"
const TXT_67_OPT3 := "event.script.event_067_070_crises_and_plenums.c6"
const TXT_67_OPT3_DIS1 := "event.script.event_067_070_crises_and_plenums.c7"
const TXT_67_OPT3_DIS2 := "event.script.event_067_070_crises_and_plenums.c8"
const TXT_67_OPT4 := "event.script.event_067_070_crises_and_plenums.c9"
const TXT_67_OPT4_DIS1 := "event.script.event_067_070_crises_and_plenums.c10"
const TXT_67_OPT4_DIS2 := "event.script.event_067_070_crises_and_plenums.c11"
const TXT_67_OPT5 := "event.script.event_067_070_crises_and_plenums.c12"
const TXT_67_OPT5_DIS1 := "event.script.event_067_070_crises_and_plenums.c13"
const TXT_67_OPT5_DIS2 := "event.script.event_067_070_crises_and_plenums.c14"

const TXT_67_R0 := "event.script.event_067_070_crises_and_plenums.c15"
const TXT_67_R1A := "event.script.event_067_070_crises_and_plenums.c16"
const TXT_67_R1B := "event.script.event_067_070_crises_and_plenums.c17"
const TXT_67_R1C := "event.script.event_067_070_crises_and_plenums.c18"
const TXT_67_R1D := "event.script.event_067_070_crises_and_plenums.c19"
const TXT_67_R1E := "event.script.event_067_070_crises_and_plenums.c20"
const TXT_67_R1_TAIL := "event.script.event_067_070_crises_and_plenums.c21"
const TXT_67_R2 := "event.script.event_067_070_crises_and_plenums.c22"
const TXT_67_R3 := "event.script.event_067_070_crises_and_plenums.c23"
const TXT_67_R4 := "event.script.event_067_070_crises_and_plenums.c24"
const TXT_67_R4_YES := "event.script.event_067_070_crises_and_plenums.c25"
const TXT_67_R4_NO := "event.script.event_067_070_crises_and_plenums.c26"
const TXT_67_R5_YES := "event.script.event_067_070_crises_and_plenums.c27"
const TXT_67_R5_NO := "event.script.event_067_070_crises_and_plenums.c28"

const TXT_68_TITLE := "event.script.event_067_070_crises_and_plenums.c29"
const TXT_68_DESC := "event.script.event_067_070_crises_and_plenums.c30"
const TXT_68_OPT0 := "event.script.event_067_070_crises_and_plenums.c31"
const TXT_68_OPT1 := "event.script.event_067_070_crises_and_plenums.c32"
const TXT_68_OPT1_DIS := "event.script.event_067_070_crises_and_plenums.c33"
const TXT_68_OPT2 := "event.script.event_067_070_crises_and_plenums.c34"
const TXT_68_OPT3 := "event.script.event_067_070_crises_and_plenums.c35"
const TXT_68_R0 := "event.script.event_067_070_crises_and_plenums.c36"
const TXT_68_R1 := "event.script.event_067_070_crises_and_plenums.c37"
const TXT_68_R2 := "event.script.event_067_070_crises_and_plenums.c38"
const TXT_68_R3 := "event.script.event_067_070_crises_and_plenums.c39"

const TXT_69_TITLE := "event.script.event_067_070_crises_and_plenums.c40"
const TXT_69_DESC := "event.script.event_067_070_crises_and_plenums.c41"
const TXT_69_OPT0 := "event.script.event_067_070_crises_and_plenums.c42"
const TXT_69_OPT1 := "event.script.event_067_070_crises_and_plenums.c43"
const TXT_69_OPT1_DIS := "event.script.event_067_070_crises_and_plenums.c44"
const TXT_69_OPT2 := "event.script.event_067_070_crises_and_plenums.c45"
const TXT_69_OPT2_DIS := "event.script.event_067_070_crises_and_plenums.c46"
const TXT_69_R0 := "event.script.event_067_070_crises_and_plenums.c47"
const TXT_69_R1 := "event.script.event_067_070_crises_and_plenums.c48"
const TXT_69_R2 := "event.script.event_067_070_crises_and_plenums.c49"

const TXT_70_TITLE := "event.script.event_067_070_crises_and_plenums.c50"
const TXT_70_DESC := "event.script.event_067_070_crises_and_plenums.c51"
const TXT_70_OPT0 := "event.script.event_067_070_crises_and_plenums.c52"
const TXT_70_OPT1 := "event.script.event_067_070_crises_and_plenums.c53"
const TXT_70_OPT1_DIS := "event.script.event_067_070_crises_and_plenums.c54"
const TXT_70_OPT2 := "event.script.event_067_070_crises_and_plenums.c55"
const TXT_70_OPT2_DIS := "event.script.event_067_070_crises_and_plenums.c56"
const TXT_70_OPT3 := "event.script.event_067_070_crises_and_plenums.c57"
const TXT_70_R0 := "event.script.event_067_070_crises_and_plenums.c58"
const TXT_70_R1 := "event.script.event_067_070_crises_and_plenums.c59"
const TXT_70_R2 := "event.script.event_067_070_crises_and_plenums.c60"
const TXT_70_R3 := "event.script.event_067_070_crises_and_plenums.c61"


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	ws = p_ws
	d = p_ws
	match event_def.event_id:
		"polish_crisis":
			_prepare_67(event_def)
		"little_gang_of_four":
			_prepare_69(event_def)
		"zhou_enlai_heirs":
			_prepare_70(event_def)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"polish_crisis": _event_67(option_index, context)
		"gwangju_uprising": _event_68(option_index, context)
		"little_gang_of_four": _event_69(option_index, context)
		"zhou_enlai_heirs": _event_70(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_67(option_index: int, context: Dictionary) -> void:
	var poland := ws.get_country_by_legacy_index(2)
	match option_index:
		0:
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USSR, 50)
			if poland != null:
				poland.government = GameConstants.Government.AUTHORITARIAN
				poland.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				poland.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_67_R0)
		1:
			var line := int(ws.political_line)
			var r1 := ""
			if line <= 1:
				_add_data({W.I_DIPLO: 50})
				if not ws.global_flags.get("relres", false):
					r1 = tr(TXT_67_R1A)
					_add_empire_relation(EmpireData.USSR, -50)
				else:
					r1 = tr(TXT_67_R1B)
			elif line == 2:
				r1 = tr(TXT_67_R1C)
				_add_data({W.I_DIPLO: -50})
			elif line == 3:
				r1 = tr(TXT_67_R1D)
				_add_empire_relation(EmpireData.USA, 50)
				_add_empire_relation(EmpireData.USSR, -50)
				_add_data({W.I_DIPLO: 50})
			elif line == 4:
				r1 = tr(TXT_67_R1E)
				_add_empire_relation(EmpireData.USA, 150)
				_add_empire_relation(EmpireData.USSR, -150)
				_add_data({W.I_DIPLO: -50})
			r1 += tr(TXT_67_R1_TAIL)
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USSR, 50)
			if poland != null:
				poland.government = GameConstants.Government.AUTHORITARIAN
				poland.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				poland.set_tag("对华贸易", true)
			context["result_text"] = r1
		2:
			_add_data({W.I_PARTY_SUPPORT: 200, W.I_BUDGET: -200,
				W.I_AGENTS: -50, W.I_THOUGHT_FREEDOM: -10})
			_add_empire_power(EmpireData.USSR, -10)
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, 150)
			if poland != null:
				poland.government = GameConstants.Government.SOCIALIST
				poland.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				poland.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_67_R2)
		3:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_BUDGET: -300,
				W.I_AGENTS: -150, W.I_DIPLO: 100})
			ws.influence_prc += 30
			_add_empire_power(EmpireData.USSR, -30)
			_add_empire_power(EmpireData.USA, -20)
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, -150)
			if poland != null:
				poland.government = GameConstants.Government.AUTHORITARIAN
				poland.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				poland.set_tag("亲苏", false)
				poland.set_tag("亲中", true)
				poland.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_67_R3)
		4:
			var r4 := tr(TXT_67_R4)
			if _empire_relation(EmpireData.USSR) >= 800:
				r4 = tr(TXT_67_R4_YES)
				_add_data({W.I_PARTY_SUPPORT: 100, W.I_ARMY: -50,
					W.I_AGENTS: -50, W.I_DIPLO: 200,
					W.I_SOVIET_INTERVENTIONS: 1})
				ws.influence_prc += 10
				_add_empire_power(EmpireData.USA, -10)
				_add_empire_relation(EmpireData.USA, -150)
				_add_empire_relation(EmpireData.USSR, 150)
				if poland != null:
					poland.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
					poland.puppet_of = 7
			else:
				r4 = tr(TXT_67_R4_NO)
				_add_data({W.I_DIPLO: 200})
				ws.influence_prc += 10
				_add_empire_power(EmpireData.USSR, -20)
				if poland != null:
					poland.government = GameConstants.Government.AUTHORITARIAN
					poland.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = r4
		5:
			var united_states := ws.get_country_by_legacy_index(51)
			if _empire_relation(EmpireData.USA) >= 80 and united_states != null and united_states.development == 1:
				_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: 20,
					W.I_THOUGHT_FREEDOM: 160, W.I_BUDGET: -100,
					W.I_AGENTS: -200, W.I_DIPLO: -50})
				_add_empire_power(EmpireData.USSR, -30)
				_add_empire_relation(EmpireData.USA, 150)
				_add_empire_relation(EmpireData.USSR, -50)
				if poland != null:
					poland.government = GameConstants.Government.REFORMIST
					poland.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					poland.set_tag("亲苏", false)
					poland.set_tag("对华贸易", true)
				context["result_text"] = tr(TXT_67_R5_YES)
			else:
				_add_data({W.I_AGENTS: -200, W.I_BUDGET: -100,
					W.I_PARTY_SUPPORT: -100, W.I_THOUGHT_FREEDOM: 80})
				_add_empire_power(EmpireData.USSR, -10)
				_add_empire_relation(EmpireData.USA, -300)
				context["result_text"] = tr(TXT_67_R5_NO)


func _event_68(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_empire_power(EmpireData.USA, 10)
			context["result_text"] = tr(TXT_68_R0)
		1:
			_add_data({W.I_ARMY: -80, W.I_AGENTS: -80, W.I_DIPLO: 10})
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_power(EmpireData.USA, -10)
			ws.set_flag("south_korea_gwangju_rebellion", true)
			context["result_text"] = tr(TXT_68_R1)
		2:
			_add_data({W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USA, 20)
			_add_empire_power(EmpireData.USA, 10)
			context["result_text"] = tr(TXT_68_R2)
		3:
			_add_data({W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USA, 20)
			_add_empire_relation(EmpireData.USSR, -80)
			_add_empire_power(EmpireData.USA, 20)
			_change_politicians({3: [0, 100]})
			context["result_text"] = tr(TXT_68_R3)


func _event_69(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -70})
			_change_politicians({
				0: [0, 100], 1: [-150, 0], 2: [-150, 0], 3: [-150, 0],
			})
			context["result_text"] = tr(TXT_69_R0)
		1:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_REFORM_MOMENTUM: 20,
				W.I_THOUGHT_FREEDOM: 100, W.I_DIPLO: -30})
			_disable_faction(FactionData.MAOIST)
			_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.45)
			_enable_faction(FactionData.LIBERAL)
			_add_faction_ideology({FactionData.REFORMIST: 45, FactionData.LIBERAL: 24})
			_change_politicians({
				0: [-250, -200], 1: [0, 80], 2: [0, 100], 3: [0, 150],
			})
			context["result_text"] = tr(TXT_69_R1)
		2:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_REFORM_MOMENTUM: 10,
				W.I_THOUGHT_FREEDOM: 30, W.I_DIPLO: -15})
			_disable_faction(FactionData.MAOIST)
			_subtract_faction_fraction(FactionData.CONSERVATIVE, 0.45)
			_add_faction_ideology({
				FactionData.MODERATE: 27, FactionData.REFORMIST: 45, FactionData.LIBERAL: 15,
			})
			_change_politicians({
				0: [-300, -350], 1: [0, 100], 2: [0, 120], 3: [0, 80],
			})
			context["result_text"] = tr(TXT_69_R2)


func _event_70(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -100,
				W.I_THOUGHT_FREEDOM: 100})
			_add_faction_ideology({FactionData.REFORMIST: 25})
			_change_politicians({0: [-100, 0], 2: [0, 100]})
			context["result_text"] = tr(TXT_70_R0)
		1:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_THOUGHT_FREEDOM: -50, W.I_DIPLO: 40})
			_remove_deng_if_modifier_active()
			_add_faction_ideology({FactionData.CONSERVATIVE: 45, FactionData.MAOIST: 30})
			_change_politicians({
				0: [0, 150], 1: [-200, -150], 2: [-200, -350], 3: [-200, -250],
			})
			context["result_text"] = tr(TXT_70_R1)
		2:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_THOUGHT_FREEDOM: -50, W.I_DIPLO: 30})
			_remove_deng_if_modifier_active()
			_add_faction_ideology({
				FactionData.MAOIST: 30, FactionData.CONSERVATIVE: 45, FactionData.MODERATE: 24,
			})
			_change_politicians({2: [-200, -350], 3: [-200, -250]})
			context["result_text"] = tr(TXT_70_R2)
		3:
			_add_data({W.I_PARTY_SUPPORT: -200, W.I_THOUGHT_FREEDOM: 150,
				W.I_PEOPLE_SUPPORT: -200, W.I_DIPLO: 50})
			_remove_deng_if_modifier_active()
			_add_faction_ideology({FactionData.MAOIST: 30, FactionData.CONSERVATIVE: 45})
			_subtract_faction_fraction(FactionData.MODERATE, 0.09)
			_change_politicians({
				0: [0, 150], 1: [-30, -50], 2: [-30, -350], 3: [-300, -250],
			})
			context["result_text"] = tr(TXT_70_R3)


func _remove_deng_if_modifier_active() -> void:
	if ws.modifiers.size() > 14 and ws.modifiers[14] != null and ws.modifiers[14].is_active:
		game.kill_politician(12)
		ws.modifiers[14].is_active = false


func _disable_faction(faction_index: int) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		ws.factions[faction_index].is_enabled = false
		ws.factions[faction_index].is_ally = false


func _enable_faction(faction_index: int) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		ws.factions[faction_index].is_enabled = true


func _empire_relation(empire_index: int) -> int:
	return ws.empires[empire_index].relations if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null else 0


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

func _prepare_67(event_def: EventDef) -> void:
	if event_def.options.size() < 6:
		return
	var opts := event_def.options
	event_def.title = tr(TXT_67_TITLE)
	event_def.description = _leader_name() + tr(TXT_67_DESC)
	_enable(opts[0], tr(TXT_67_OPT0))
	_enable(opts[1], tr(TXT_67_OPT1))
	if ws.global_flags.get("relres", false):
		_enable(opts[2], tr(TXT_67_OPT2))
	else:
		_disable(opts[2], tr(TXT_67_OPT2_DIS))
	var albania := ws.get_country_by_legacy_index(20)
	var line := int(ws.political_line)
	var ps := int(ws.party_system)
	var summa := _summa_3_2()
	var cond := (line < 3 and ps < 8) or (summa > 66 and ps > 7)
	if albania != null and albania.has_tag("亲中") and cond:
		_enable(opts[3], tr(TXT_67_OPT3))
	elif albania == null or not albania.has_tag("亲中"):
		_disable(opts[3], tr(TXT_67_OPT3_DIS1))
	else:
		_disable(opts[3], tr(TXT_67_OPT3_DIS2))
	var china := ws.get_country_by_legacy_index(1)
	if _empire_relation(EmpireData.USSR) >= 600 and china != null and china.has_tag("ovd"):
		_enable(opts[4], tr(TXT_67_OPT4))
	elif china == null or not china.has_tag("ovd"):
		_disable(opts[4], tr(TXT_67_OPT4_DIS1))
	else:
		_disable(opts[4], tr(TXT_67_OPT4_DIS2))
	var united_states := ws.get_country_by_legacy_index(51)
	if _empire_relation(EmpireData.USA) >= 600 and united_states != null and united_states.has_tag("对华贸易"):
		_enable(opts[5], tr(TXT_67_OPT5))
	elif united_states == null or not united_states.has_tag("对华贸易"):
		_disable(opts[5], tr(TXT_67_OPT5_DIS1))
	else:
		_disable(opts[5], tr(TXT_67_OPT5_DIS2))


func _prepare_69(event_def: EventDef) -> void:
	if event_def.options.size() < 3:
		return
	var opts := event_def.options
	event_def.title = tr(TXT_69_TITLE)
	event_def.description = _leader_name() + tr(TXT_69_DESC)
	_enable(opts[0], tr(TXT_69_OPT0))
	var moderate_reformer_power := _trait_power_sum([1, 2])
	var maoist_power := _trait_power_sum([0])
	if int(ws.party_support) >= 650 and moderate_reformer_power > maoist_power:
		_enable(opts[1], tr(TXT_69_OPT1))
	else:
		_disable(opts[1], tr(TXT_69_OPT1_DIS))
	if int(ws.party_support) >= 600 and moderate_reformer_power > maoist_power:
		_enable(opts[2], tr(TXT_69_OPT2))
	else:
		_disable(opts[2], tr(TXT_69_OPT2_DIS))


func _prepare_70(event_def: EventDef) -> void:
	if event_def.options.size() < 4:
		return
	var opts := event_def.options
	event_def.title = tr(TXT_70_TITLE)
	event_def.description = _leader_name() + tr(TXT_70_DESC)
	_enable(opts[0], tr(TXT_70_OPT0))
	var moderate_reformer_power := _trait_power_sum([1, 2])
	var maoist_power := _trait_power_sum([0])
	if int(ws.party_support) >= 800 and maoist_power > moderate_reformer_power:
		_enable(opts[1], tr(TXT_70_OPT1))
	else:
		_disable(opts[1], tr(TXT_70_OPT1_DIS))
	if int(ws.party_support) >= 700 and int(ws.mao_history_line) != 0:
		_enable(opts[2], tr(TXT_70_OPT2))
	else:
		_disable(opts[2], tr(TXT_70_OPT2_DIS))
	_enable(opts[3], tr(TXT_70_OPT3))


func _trait_power_sum(traits: Array) -> int:
	var total := 0
	for politician in ws.politicians:
		if politician != null and politician.trait_personality in traits:
			total += int(politician.power)
	return total


func _summa_3_2() -> int:
	if ws.party_system <= 7:
		return 0
	var num := 0
	var den := 0
	for i in range(5):
		if i >= ws.factions.size() or ws.factions[i] == null:
			continue
		den += int(ws.factions[i].support)
		if i == FactionData.CONSERVATIVE:
			num += int(ws.factions[i].support)
		elif ws.factions[i].is_ally and ws.factions[i].is_enabled:
			num += int(ws.factions[i].support)
	if den == 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / den


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _fmt_leader(text: String) -> String:
	var n := _leader_name()
	return text.replace("{0}{1}", n).replace("{0}", n).replace("{1}", n)



