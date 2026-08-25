extends "res://数据脚本/event_script_base.gd"

## 原作 Event80.cs：中共十二大（modifies[3] 双分支 + 常规三分支，超大事件）。
## 触发：event_080_trigger.gd（TimeScript.cs:10637-10650 两条 OR 分支）。
## 差异记录：
##  - modifies[3] 激活分支：2 选项；常规分支：3 选项。prepare 动态替换 options。
##  - num 计分逐项移植（TimeScript.cs:10719-10844 同款国家检查）。
##  - 原版 LeaderAsset / MoneyLevel / ServeRMB / doctr[] / party_change[]
##    为显示或建模说明字段，跳过；数值效果全部保留。
##  - result0（极左派胜利）的领袖轮换：leader ↔ politics[2] 逐字段交换，
##    faction_leader[0]=1，随后原版 KillPerson(2)（同序保留）。
##  - result2 新政治家姓名取自 polit_names1/2_en.txt：乔石/李锐/刘宾雁/鲍彤。

const TXT_DESC_MOD3 := "event.script.event_080_twelfth_congress.c0"

const TXT_DESC_NORMAL := "event.script.event_080_twelfth_congress.c1"

const TXT_R_MOD3_0 := "event.script.event_080_twelfth_congress.c2"

const TXT_R_MOD3_1 := "event.script.event_080_twelfth_congress.c3"

const TXT_R0 := "event.script.event_080_twelfth_congress.c4"

const TXT_R1 := "event.script.event_080_twelfth_congress.c5"

const TXT_R2 := "event.script.event_080_twelfth_congress.c6"

static var _opts_full: Array[EventOption] = []


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	if _opts_full.is_empty():
		for o in event_def.options:
			_opts_full.append(o)
	var mod3 := _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION)
	if mod3:
		event_def.description = tr(TXT_DESC_MOD3)
		var arr_mod3: Array[EventOption] = []
		arr_mod3.append(_opts_full[0])
		arr_mod3.append(_opts_full[1])
		event_def.options = arr_mod3
		var num := _compute_num(world)
		var data_mod3 := world
		var line_mod3 := data_mod3.get_data_by_index(W.I_POLITICAL_LINE) if data_mod3.size() > W.I_POLITICAL_LINE else 1
		var living := data_mod3.get_data_by_index(W.I_LIVING) if data_mod3.size() > W.I_LIVING else 0
		var flag := line_mod3 < 1 and living >= 500 and world.influence_prc >= 500 and num >= 15
		if flag:
			_enable(event_def.options[0], "中国人民的革命事业要排除万难，从胜利走向胜利！")
			_disable(event_def.options[1], "革命气势已经不可阻挡！")
		else:
			_disable(event_def.options[0], "革命引擎缺乏动力……")
			_enable(event_def.options[1], "党的团结是我国稳定发展的保证……")
		return
	var arr: Array[EventOption] = []
	for o in _opts_full:
		arr.append(o)
	event_def.options = arr
	event_def.description = tr(TXT_DESC_NORMAL)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var left_party := party < 8
	var opt := event_def.options
	if (line < 3 and left_party) or (coal > 66 and party > 7):
		_enable(opt[0], "没必要徒增麻烦，会议应照常进行")
	else:
		_disable(opt[0], "如果我们不打算在会议期间讨论真正要紧的问题，那为什么还要开会？")
	if (line > 0 and left_party) or party > 7:
		_enable(opt[1], "我们将在“中国特色社会主义”的旗下对毛主席做扬弃，并靠不争论的方式确立新思维的霸权")
	else:
		_disable(opt[1], "不争不行——党和人民需要一个足够清晰的表态！")
	if (line > 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[2], "不破不立，我们怎么就摸不着赫鲁晓夫过河？")
	else:
		_disable(opt[2], "你疯了吗！上一个中国版赫鲁晓夫还尸骨未寒呢？！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var mod3 := _mod_active(ws, GameConstants.Modifier.CULTURAL_REVOLUTION)
	var opt := int(context.get("option_index", -1))
	var leader_name := _leader_name(ws)
	if mod3:
		if opt == 0:
			_result_mod3_0(context)
		elif opt == 1:
			_result_mod3_1(context)
		return
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_DIPLO, 5)
			_add_relation(EmpireData.USA, -50)
			context["result_text"] = tr(TXT_R0).replace("{0}", leader_name)
		1:
			_add(W.I_PARTY_SUPPORT, 80)
			ws.influence_prc -= 10
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_DIPLO, -20)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_MANPOWER, -80)
			_set_modifier(6, false)
			# doctr[] 显示名：Godot 建模说明，跳过
			_set_data(W.I_MAO_HISTORY_LINE, 1)
			if ws.factions.size() > 1:
				ws.factions[1].ideology = int(ws.factions[1].ideology * 0.95)
			if ws.factions.size() > 0:
				ws.factions[0].ideology = int(ws.factions[0].ideology * 0.9)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 200
			context["result_text"] = tr(TXT_R1).replace("{0}", leader_name)
		2:
			_result_mod3_false_2(context, leader_name)


func _result_mod3_0(context: Dictionary) -> void:
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_THOUGHT_FREEDOM, -100)
	_add(W.I_DIPLO, 100)
	# LeaderAsset / MoneyLevel / ServeRMB：显示字段建模说明，跳过
	if ws.modifiers.size() > 65 and ws.modifiers[65] != null:
		ws.modifiers[65].is_active = false
	_swap_leader_with_politician(2)
	if ws.factions.size() > 0:
		ws.factions[0].leader_index = 1
	PoliticianSystem.kill_politician(2)
	for i in [1, 3, 4]:
		if i < ws.politicians.size() and ws.politicians[i] != null:
			ws.politicians[i].power += 500
	for p in ws.politicians:
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty += 200
			p.power += 100
		if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 100
			p.power += 80
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty -= 100
			p.power -= 100
		elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
			p.loyalty -= 100
	if ws.factions.size() > 3:
		ws.factions[3].ideology = int(ws.factions[3].ideology * 0.85)
	context["result_text"] = tr(TXT_R_MOD3_0)


func _result_mod3_1(context: Dictionary) -> void:
	_add(W.I_PARTY_SUPPORT, 150)
	_add(W.I_PEOPLE_SUPPORT, 150)
	_add(W.I_THOUGHT_FREEDOM, 100)
	_add(W.I_DIPLO, -10)
	for p in ws.politicians:
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 300
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty += 150
		elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
			p.loyalty += 150
		elif p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 150
	_set_modifier(3, false)
	PoliticianSystem.kill_politician(1)
	PoliticianSystem.kill_politician(2)
	for i in [3, 4]:
		if i < ws.politicians.size() and ws.politicians[i] != null:
			ws.politicians[i].power -= 100
	if ws.politics_positions.size() > 2 and ws.politics_positions[2] < 100 \
			and ws.politics_positions[2] >= 0 \
			and ws.politics_positions[2] < ws.politicians.size():
		var pol: PoliticianData = ws.politicians[ws.politics_positions[2]]
		if pol != null:
			pol.loyalty -= 200
	context["result_text"] = tr(TXT_R_MOD3_1)


func _result_mod3_false_2(context: Dictionary, leader_name: String) -> void:
	_add(W.I_PARTY_SUPPORT, -500)
	_add(W.I_PEOPLE_SUPPORT, -500)
	_add(W.I_THOUGHT_FREEDOM, 250)
	_add(W.I_DIPLO, -100)
	ws.influence_prc -= 150
	_add_relation(EmpireData.USA, 300)
	_add(W.I_MANPOWER, -450)
	_add(W.I_THOUGHT_FREEDOM, 400)
	_add_relation(EmpireData.USSR, 300)
	_set_modifier(6, false)
	for pair in [[0, 0], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
			[8, 8], [9, 9], [10, 10], [11, 11], [13, 13], [16, 16], [27, 48]]:
		var idx := _find_politician_by_names(pair[0], pair[1])
		if idx >= 0:
			PoliticianSystem.kill_politician(idx)
	_overwrite_new_politician(18, 61, 1924, 3, 21, 5, 14, "乔石")
	_overwrite_new_politician(21, 62, 1917, 3, 28, 30, 15, "李锐")
	_overwrite_new_politician(23, 63, 1925, 3, 26, 4, 31, "刘宾雁")
	_overwrite_new_politician(46, 64, 1932, 3, 21, 6, 11, "鲍彤")
	_set_data(W.I_MAO_HISTORY_LINE, 2)
	for p in ws.politicians:
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 600
			p.power -= 500
		elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
			p.loyalty -= 400
			p.power -= 500
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty -= 300
			p.power -= 500
		elif p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
			p.loyalty += 200
			p.power += 500
	var faction4_leader := -1
	if ws.factions.size() > 4:
		faction4_leader = ws.factions[4].leader_index
	var liberal_leader_name := _politician_display_name(faction4_leader)
	context["result_text"] = tr(TXT_R2).replace("{0}", leader_name).replace("{1}", liberal_leader_name)


## TimeScript.cs 同款 num 计分（Event80 VariantsOfEvents modifies[3] 分支）。
func _compute_num(world: WorldState) -> int:
	var num := 0
	var c := world.get_country_by_legacy_index(2)
	if c != null:
		if c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 3
		if c.government == GameConstants.Government.SOCIALIST:
			num += 1
	c = world.get_country_by_legacy_index(19)
	if c != null:
		if c.sub_government == GameConstants.SubGovernment.MAOIST:
			num += 1
		if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 3
	for idx in [33, 11, 22, 47, 23]:
		c = world.get_country_by_legacy_index(idx)
		if c != null and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			num += 1
	for idx in [34, 8, 86]:
		c = world.get_country_by_legacy_index(idx)
		if c != null and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			num += 2
	c = world.get_country_by_legacy_index(86)
	if c != null and c.has_tag("亲中"):
		num += 1
	c = world.get_country_by_legacy_index(87)
	if c != null:
		if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 1
		if c.has_tag("亲中"):
			num += 1
	c = world.get_country_by_legacy_index(12)
	if c != null:
		if c.has_tag("亲中"):
			num += 1
		if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 1
		if c.has_tag("亲苏"):
			num -= 1
		if c.sub_government == GameConstants.SubGovernment.MAOIST:
			num += 1
	c = world.get_country_by_legacy_index(44)
	if c != null and c.government == GameConstants.Government.SOCIALIST:
		num += 3
	c = world.get_country_by_legacy_index(12)
	if c != null and c.sub_government == GameConstants.SubGovernment.MAOIST:
		num += 2
	c = world.get_country_by_legacy_index(24)
	if c != null:
		if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 1
		if c.has_tag("亲中") and c.parts.size() > 0 and c.parts[0]:
			num += 2
	c = world.get_country_by_legacy_index(49)
	if c != null and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
		num += 1
	c = world.get_country_by_legacy_index(85)
	if c != null and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
		num += 3
	for idx in [74, 80, 35, 14, 104, 42, 50]:
		c = world.get_country_by_legacy_index(idx)
		if c != null and world.is_socialism(c, true):
			num += 1
	c = world.get_country_by_legacy_index(74)
	if c != null and world.is_socialism(c, true):
		num += 1  # 74 额外 +1（原版 +2 总计）
	c = world.get_country_by_legacy_index(10)
	if c != null and c.government != GameConstants.Government.SOCIALIST and c.sub_government != GameConstants.SubGovernment.LEFT_RADICAL:
		num -= 1
	c = world.get_country_by_legacy_index(20)
	if c == null or not c.has_tag("亲中"):
		num -= 1
	if world.size() > 185:
		if world.anthem_choice == 1:
			num -= 1
		elif world.anthem_choice == 3:
			num += 1
	return num


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total


func _mod_active(world: WorldState, index: int) -> bool:
	return index >= 0 and index < world.modifiers.size() \
		and world.modifiers[index] != null and world.modifiers[index].is_active


func _set_modifier(index: int, active: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active


func _swap_leader_with_politician(slot: int, _faction_index: int = -1) -> void:
	if ws.leader == null or slot < 0 or slot >= ws.politicians.size():
		return
	var other: PoliticianData = ws.politicians[slot]
	if other == null:
		return
	PoliticianSystem.swap_leader_profile(ws.leader, other)
	var leader_post_swap: Array[int] = []
	for i in ws.politics_positions.size():
		if ws.politics_positions[i] == -2:
			ws.politics_positions[i] = slot
		elif ws.politics_positions[i] == slot:
			leader_post_swap.append(i)
	for i in leader_post_swap:
		ws.politics_positions[i] = -2


func _find_politician_by_names(name_first: int, name_last: int) -> int:
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p != null and p.name_first == name_first and p.name_last == name_last:
			return i
	return -1


## 最弱且 personality != 3 的槽位（原版循环逐字）。
func _weakest_not_personality(not_personality: int) -> int:
	var num := 0
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		var base: PoliticianData = ws.politicians[num]
		if base == null:
			num = i
			continue
		if p.power < base.power and p.trait_personality != not_personality:
			num = i
	return num


func _overwrite_new_politician(
		name_first: int, name_last: int, birth_year: int,
		personality: int, background: int, alignment: int, special: int,
		display_name: String
) -> void:
	var idx := _weakest_not_personality(3)
	if idx < 0 or idx >= ws.politicians.size():
		return
	# 防重名：若该历史人物已由预备池/其它事件登场，不再重复覆写。
	if PoliticianSystem.has_politician(display_name, name_first, name_last):
		return
	var p: PoliticianData = ws.politicians[idx]
	if p == null:
		return
	var year := ws.date.year if ws.date != null else 1982
	PoliticianSystem.apply_historical_profile(
		p, display_name, name_first, name_last,
		personality, background, alignment, special,
		maxi(0, year - birth_year), 800, 800
	)
	p.is_historical = false
	p.faction = -1
	p.faction = PoliticianSystem.trait_faction_slot(p)


func _politician_display_name(idx: int) -> String:
	if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
			and ws.politicians[idx].name_display != "":
		return ws.politicians[idx].name_display
	return "自由派领袖"




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)




func _leader_name(world: WorldState) -> String:
	if world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"
