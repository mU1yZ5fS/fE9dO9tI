extends "res://数据脚本/event_script_base.gd"

## 原作事件 64–66：泛阿拉伯统一、莫斯科奥运会与铁托逝世。
## 来源：TimeScript.cs:3890-3918，doneventscript.cs:1523-1636，
##       Results_text.cs:5429-5690。



## 事件 64–66 逐字中文文案。
## 来源：Event64.cs / Event65.cs / Event66.cs。
## 说明：{0}{1} 为原版领袖姓名字段占位，显示前由 _fmt_leader() 替换为 name_display。

const TXT_64_TITLE_SOC := "event.script.event_064_066_international.c0"
const TXT_64_DESC_SOC := "event.script.event_064_066_international.c1"
const TXT_64_TITLE := "event.script.event_064_066_international.c2"
const TXT_64_DESC := "event.script.event_064_066_international.c3"
const TXT_64_OPT0_SOC := "event.script.event_064_066_international.c4"
const TXT_64_OPT0 := "event.script.event_064_066_international.c5"
const TXT_64_OPT1 := "event.script.event_064_066_international.c6"
const TXT_64_OPT1_DIS_AGENTS := "event.script.event_064_066_international.c7"
const TXT_64_OPT1_DIS_REL := "event.script.event_064_066_international.c8"
const TXT_64_OPT1_DIS_OTHER := "event.script.event_064_066_international.c9"
const TXT_64_R_SOC := "event.script.event_064_066_international.c10"
const TXT_64_R0 := "event.script.event_064_066_international.c11"
const TXT_64_R1 := "event.script.event_064_066_international.c12"

## 原版 socialist 分支写入 old_modify_texts[46] 与 old_modify_desc[46] 的文案（本版 ModifierCatalog 动态生成，故仅留存溯源）。
const TXT_64_MOD_TITLE := "event.script.event_064_066_international.c13"
const TXT_64_MOD1 := "event.script.event_064_066_international.c14"
const TXT_64_MOD2 := "event.script.event_064_066_international.c15"
const TXT_64_MOD3 := "event.script.event_064_066_international.c16"
const TXT_64_MOD4 := "event.script.event_064_066_international.c17"
const TXT_64_MOD5 := "event.script.event_064_066_international.c18"
const TXT_64_MOD6 := "event.script.event_064_066_international.c19"
const TXT_64_MOD7 := "event.script.event_064_066_international.c20"
const TXT_64_MOD8 := "event.script.event_064_066_international.c21"
const TXT_64_MOD9 := "event.script.event_064_066_international.c22"
const TXT_64_MOD10 := "event.script.event_064_066_international.c23"
const TXT_64_MOD11 := "event.script.event_064_066_international.c24"
const TXT_64_MOD12 := "event.script.event_064_066_international.c25"
const TXT_64_MOD13 := "event.script.event_064_066_international.c26"
const TXT_64_MOD14 := "event.script.event_064_066_international.c27"
const TXT_64_MOD15 := "event.script.event_064_066_international.c28"

const TXT_65_TITLE := "event.script.event_064_066_international.c29"
const TXT_65_DESC := "event.script.event_064_066_international.c30"
const TXT_65_DESC_GANEFO := "event.script.event_064_066_international.c31"
const TXT_65_OPT0 := "event.script.event_064_066_international.c32"
const TXT_65_OPT0_DIS := "event.script.event_064_066_international.c33"
const TXT_65_OPT1 := "event.script.event_064_066_international.c34"
const TXT_65_OPT1_DIS := "event.script.event_064_066_international.c35"
const TXT_65_OPT2 := "event.script.event_064_066_international.c36"
const TXT_65_OPT2_DIS := "event.script.event_064_066_international.c37"
const TXT_65_OPT3 := "event.script.event_064_066_international.c38"
const TXT_65_OPT3_DIS := "event.script.event_064_066_international.c39"
const TXT_65_OPT4 := "event.script.event_064_066_international.c40"
const TXT_65_OPT4_DIS := "event.script.event_064_066_international.c41"

const TXT_65_R0A := "event.script.event_064_066_international.c42"
const TXT_65_R0B := "event.script.event_064_066_international.c43"
const TXT_65_R_IRAN := "event.script.event_064_066_international.c44"
const TXT_65_R_TAIL := "event.script.event_064_066_international.c45"
const TXT_65_R1A := "event.script.event_064_066_international.c46"
const TXT_65_R_TAIL1 := "event.script.event_064_066_international.c47"
const TXT_65_R2A := "event.script.event_064_066_international.c48"
const TXT_65_R2_TAIL := "event.script.event_064_066_international.c49"
const TXT_65_R3A := "event.script.event_064_066_international.c50"
const TXT_65_R3_TAIL := "event.script.event_064_066_international.c51"
const TXT_65_R4A := "event.script.event_064_066_international.c52"
const TXT_65_R4_GOOD := "event.script.event_064_066_international.c53"
const TXT_65_R4_MID := "event.script.event_064_066_international.c54"
const TXT_65_R4_BAD := "event.script.event_064_066_international.c55"
const TXT_65_R4_TAILA := "event.script.event_064_066_international.c56"
const TXT_65_R4_TAIL := "event.script.event_064_066_international.c57"

const TXT_66_TITLE := "event.script.event_064_066_international.c58"
const TXT_66_DESC_P1 := "event.script.event_064_066_international.c59"
const TXT_66_DESC_P2 := "event.script.event_064_066_international.c60"
const TXT_66_DESC_ALB := "event.script.event_064_066_international.c61"
const TXT_66_OPT0 := "event.script.event_064_066_international.c62"
const TXT_66_OPT1 := "event.script.event_064_066_international.c63"
const TXT_66_OPT1_DIS := "event.script.event_064_066_international.c64"
const TXT_66_OPT2 := "event.script.event_064_066_international.c65"
const TXT_66_OPT2_DIS := "event.script.event_064_066_international.c66"
const TXT_66_OPT3 := "event.script.event_064_066_international.c67"
const TXT_66_OPT3_DIS := "event.script.event_064_066_international.c68"

const TXT_66_R0 := "event.script.event_064_066_international.c69"
const TXT_66_R1_P1 := "event.script.event_064_066_international.c70"
const TXT_66_R1_P2 := "event.script.event_064_066_international.c71"
const TXT_66_R1_P3 := "event.script.event_064_066_international.c72"
const TXT_66_R1_ALB := "event.script.event_064_066_international.c73"
const TXT_66_R2 := "event.script.event_064_066_international.c74"
const TXT_66_R3_P1 := "event.script.event_064_066_international.c75"
const TXT_66_R3_P2 := "event.script.event_064_066_international.c76"


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null:
		return
	ws = p_ws
	d = p_ws
	match event_def.event_id:
		"pan_arabism":
			_prepare_64(event_def)
		"moscow_olympics":
			_prepare_65(event_def)
		"death_of_tito":
			_prepare_66(event_def)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"pan_arabism": _event_64(option_index, context)
		"moscow_olympics": _event_65(option_index, context)
		"death_of_tito": _event_66(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_64(option_index: int, context: Dictionary) -> void:
	var egypt := ws.get_country_by_legacy_index(30)
	# 原版 TextOfEvents/ResultsOfEvents 按 IsSocialism(true, 30) 分支（Gosstroy==1 或 SubGosstroy==0），
	# 与 .tres 红阿联触发（埃及/伊拉克/叙利亚/利比亚全部社会主义）保持一致。
	if egypt != null and ws.is_socialism(egypt, true):
		_add_data({W.I_DIPLO: 10, W.I_MANPOWER: 30})
		_add_empire_relation(EmpireData.USSR, -100)
		_add_empire_relation(EmpireData.USA, -100)
		_add_empire_power(EmpireData.USSR, -20)
		ws.influence_prc += 10
		if ws.size() > 143:
			ws.oil_price += 5
		_add_empire_power(EmpireData.USA, -20)
		var oar := [30, 13, 14, 35]
		for idx in oar:
			var c := ws.get_country_by_legacy_index(idx)
			if c != null:
				c.set_tag("oar", true)
		_set_modifier(46, true)
		ws.set_flag("oar", true)
		ws.oar = true
		for i in range(1, ws.countries.size()):
			var c := ws.countries[i]
			if c == null:
				continue
			var idx := int(c.原版序号)
			# 原版 Event64.cs:90 用 IsSocialism(true, i)（Gosstroy==1 或 SubGosstroy==0）。
			var socialism := ws.is_socialism(c, true)
			if idx in [54, 55, 18, 40, 104, 93, 53]:
				if socialism:
					c.set_tag("oar", true)
			elif idx == 24 and c.parts.size() > 0 and c.parts[0]:
				if socialism:
					c.set_tag("oar", true)
		# 原版 party_change[2]=0.24 / party_change[3]=0.24 移植说明（DLC 选举系统未启用）。
		context["result_text"] = tr(TXT_64_R_SOC)
		return
	if option_index == 0:
		_add_empire_power(EmpireData.USA, 10)
		context["result_text"] = tr(TXT_64_R0)
		return
	_add_data({W.I_BUDGET: -70, W.I_AGENTS: -50, W.I_DIPLO: 10,
		W.I_MANPOWER: -30, W.I_INFLUENCE: 10})
	_add_empire_relation(EmpireData.USSR, 80)
	_add_empire_relation(EmpireData.USA, -70)
	_add_empire_power(EmpireData.USSR, 10)
	_add_empire_power(EmpireData.USA, -10)
	ws.set_flag("oar", true)
	ws.oar = true
	var uar := [30, 14, 35]
	for idx in uar:
		var c := ws.get_country_by_legacy_index(idx)
		if c != null:
			c.set_tag("oar", true)
	_add_faction_ideology({FactionData.MODERATE: 24, FactionData.REFORMIST: 24})
	_change_politicians({1: [100, 120], 2: [100, 120]})
	context["result_text"] = tr(TXT_64_R1)


func _event_65(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 150, W.I_PEOPLE_SUPPORT: 80,
				W.I_DIPLO: -20, W.I_INFLUENCE: 10, W.I_BUDGET: -40})
			_add_empire_power(EmpireData.USSR, 20)
			_add_empire_relation(EmpireData.USSR, 250)
			_add_empire_relation(EmpireData.USA, -100)
			var r0 := _leader_name() + tr(TXT_65_R0A) + _leader_name() + tr(TXT_65_R0B)
			var iran := ws.get_country_by_legacy_index(8)
			if iran != null and iran.government == GameConstants.Government.AUTHORITARIAN:
				r0 += tr(TXT_65_R_IRAN)
			r0 += tr(TXT_65_R_TAIL)
			context["result_text"] = r0
		1:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -100,
				W.I_INFLUENCE: -20})
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_relation(EmpireData.USA, -150)
			_add_empire_relation(EmpireData.USSR, -50)
			var r1 := tr(TXT_65_R1A)
			var iran1 := ws.get_country_by_legacy_index(8)
			if iran1 != null and iran1.government == GameConstants.Government.AUTHORITARIAN:
				r1 += tr(TXT_65_R_IRAN)
			r1 += tr(TXT_65_R_TAIL1)
			context["result_text"] = r1
		2:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: 50,
				W.I_INFLUENCE: -10, W.I_BUDGET: -40, W.I_THOUGHT_FREEDOM: 60})
			_add_empire_power(EmpireData.USSR, 10)
			_add_empire_relation(EmpireData.USA, 80)
			_add_empire_relation(EmpireData.USSR, 50)
			var r2 := tr(TXT_65_R2A)
			var iran2 := ws.get_country_by_legacy_index(8)
			if iran2 != null and iran2.government == GameConstants.Government.AUTHORITARIAN:
				r2 += tr(TXT_65_R_IRAN)
			r2 += tr(TXT_65_R2_TAIL)
			context["result_text"] = r2
		3:
			_add_data({W.I_PARTY_SUPPORT: 70, W.I_PEOPLE_SUPPORT: 30,
				W.I_THOUGHT_FREEDOM: 60, W.I_BUDGET: -30})
			_add_empire_relation(EmpireData.USA, 200)
			_add_empire_relation(EmpireData.USSR, -200)
			var r3 := tr(TXT_65_R3A)
			var iran3 := ws.get_country_by_legacy_index(8)
			if iran3 != null and iran3.government == GameConstants.Government.AUTHORITARIAN:
				r3 += tr(TXT_65_R_IRAN)
			r3 += tr(TXT_65_R3_TAIL)
			context["result_text"] = r3
		4:
			_add_data({W.I_PARTY_SUPPORT: 200, W.I_PEOPLE_SUPPORT: 50,
				W.I_INFLUENCE: 20, W.I_BUDGET: -100})
			# 原版 Event65.cs result4：data.budget -= 100（10 百万预算，与选项文案一致）；
			# 旧值 -200 会多扣 10 百万，已修正。
			_add_empire_relation(EmpireData.USA, -50)
			_add_empire_relation(EmpireData.USSR, -50)
			var r4 := tr(TXT_65_R4A)
			var reputation := int(ws.diplomatic_reputation)
			if reputation < 65:
				r4 += tr(TXT_65_R4_GOOD)
			elif reputation < 85:
				r4 += tr(TXT_65_R4_MID)
			else:
				r4 += tr(TXT_65_R4_BAD)
			r4 += tr(TXT_65_R4_TAILA)
			var iran4 := ws.get_country_by_legacy_index(8)
			if iran4 != null and iran4.government == GameConstants.Government.AUTHORITARIAN:
				r4 += tr(TXT_65_R_IRAN)
			r4 += tr(TXT_65_R4_TAIL)
			context["result_text"] = r4


func _event_66(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USA, 20)
			_add_empire_relation(EmpireData.USSR, 20)
			context["result_text"] = _leader_name() + tr(TXT_66_R0)
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
			var r1 := tr(TXT_66_R1_P1) + _leader_name() + tr(TXT_66_R1_P2) + _leader_name() + tr(TXT_66_R1_P3)
			if albania != null and albania.has_tag("亲中"):
				r1 += tr(TXT_66_R1_ALB)
			context["result_text"] = r1
		2:
			_add_data({W.I_PARTY_SUPPORT: -30, W.I_DIPLO: -15})
			_add_empire_relation(EmpireData.USSR, 30)
			_add_empire_relation(EmpireData.USA, 30)
			context["result_text"] = tr(TXT_66_R2)
		3:
			_add_data({W.I_DIPLO: 10})
			context["result_text"] = tr(TXT_66_R3_P1) + _leader_name() + tr(TXT_66_R3_P2)


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

func _prepare_64(event_def: EventDef) -> void:
	if event_def.options.size() < 2:
		return
	var opts := event_def.options
	var egypt := ws.get_country_by_legacy_index(30)
	# 原版 TextOfEvents/VariantsOfEvents 按 IsSocialism(true, 30) 分支，与红阿联触发判定一致。
	if egypt != null and ws.is_socialism(egypt, true):
		event_def.title = tr(TXT_64_TITLE_SOC)
		event_def.description = tr(TXT_64_DESC_SOC)
		_enable(opts[0], tr(TXT_64_OPT0_SOC))
		_disable(opts[1], tr(TXT_64_OPT1))
		return
	event_def.title = tr(TXT_64_TITLE)
	event_def.description = tr(TXT_64_DESC)
	_enable(opts[0], tr(TXT_64_OPT0))
	var agents := int(ws.agents)
	var egypt_prosov := egypt != null and egypt.has_tag("亲苏")
	if agents < 50:
		_disable(opts[1], tr(TXT_64_OPT1_DIS_AGENTS))
	elif egypt_prosov and not ws.global_flags.get("relres", false):
		_disable(opts[1], tr(TXT_64_OPT1_DIS_REL))
	elif not ((not egypt_prosov) or ws.global_flags.get("relres", false)):
		_disable(opts[1], tr(TXT_64_OPT1_DIS_OTHER))
	else:
		_enable(opts[1], tr(TXT_64_OPT1))


func _prepare_65(event_def: EventDef) -> void:
	if event_def.options.size() < 5:
		return
	var opts := event_def.options
	event_def.title = tr(TXT_65_TITLE)
	event_def.description = tr(TXT_65_DESC)
	if ws.factions.size() > 0 and ws.factions[0] != null and ws.factions[0].is_enabled:
		event_def.description += tr(TXT_65_DESC_GANEFO)
	var line := int(ws.political_line)
	var ps := int(ws.party_system)
	var summa := _summa_3_2()
	var cond_line_below3 := (line < 3 and ps < 8) or (summa > 66 and ps > 7)
	var cond_line_1_2 := (line > 0 and line < 3 and ps < 8) or (summa > 66 and ps > 7)
	var cond_line_above1 := (line > 1 and ps < 8) or (summa > 66 and ps > 7)
	var china_sev := false
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china_sev = china.has_tag("sev")
	var stage_zero := int(ws.reform_stage) == 0
	var stage_positive := int(ws.reform_stage) > 0
	if (stage_zero and cond_line_below3) or china_sev:
		_enable(opts[0], tr(TXT_65_OPT0))
	else:
		_disable(opts[0], tr(TXT_65_OPT0_DIS))
	if (stage_zero and cond_line_1_2) or (ws.global_flags.get("relres", false) and line != 0):
		_enable(opts[1], tr(TXT_65_OPT1))
	else:
		_disable(opts[1], tr(TXT_65_OPT1_DIS))
	if stage_positive and cond_line_above1:
		_enable(opts[3], tr(TXT_65_OPT3))
	else:
		_disable(opts[3], tr(TXT_65_OPT3_DIS))
	if stage_zero and cond_line_below3:
		_enable(opts[4], tr(TXT_65_OPT4))
	else:
		_disable(opts[4], tr(TXT_65_OPT4_DIS))
	var disabled_count := 0
	for i in [0, 1, 3, 4]:
		if opts[i].enable_condition != null:
			disabled_count += 1
	var cond_line_below4 := (line < 4 and ps < 8) or (summa > 66 and ps > 7)
	if (cond_line_below4 and line != 0) or disabled_count >= 4:
		_enable(opts[2], tr(TXT_65_OPT2))
	else:
		_disable(opts[2], tr(TXT_65_OPT2_DIS))


func _prepare_66(event_def: EventDef) -> void:
	if event_def.options.size() < 4:
		return
	var opts := event_def.options
	event_def.title = tr(TXT_66_TITLE)
	event_def.description = tr(TXT_66_DESC_P1) + _leader_name() + tr(TXT_66_DESC_P2)
	var albania := ws.get_country_by_legacy_index(20)
	if albania != null and albania.has_tag("亲中"):
		event_def.description += tr(TXT_66_DESC_ALB)
	_enable(opts[0], tr(TXT_66_OPT0))
	var line := int(ws.political_line)
	var ps := int(ws.party_system)
	var summa := _summa_3_2()
	var china_sev := false
	var china := ws.get_country_by_legacy_index(1)
	if china != null:
		china_sev = china.has_tag("sev")
	if (line > 1 and ps < 8) or (summa > 66 and ps > 7) or china_sev:
		_enable(opts[1], _leader_name() + tr(TXT_66_OPT1))
	else:
		_disable(opts[1], _leader_name() + tr(TXT_66_OPT1_DIS))
	if (line > 0 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[2], tr(TXT_66_OPT2))
	else:
		_disable(opts[2], tr(TXT_66_OPT2_DIS))
	if (line < 3 and ps < 8) or (summa > 66 and ps > 7):
		_enable(opts[3], tr(TXT_66_OPT3))
	else:
		_disable(opts[3], tr(TXT_66_OPT3_DIS))


func _summa_3_2() -> int:
	if ws.party_system <= GameConstants.PartySystem.NEW_DEMOCRACY:
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


func _set_modifier(index: int, active: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



