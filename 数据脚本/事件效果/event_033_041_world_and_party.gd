extends "res://数据脚本/event_script_base.gd"

## 原作 1977 年自动事件 33–41 的结果逻辑。
## 来源：TimeScript.cs:3732-3784，doneventscript.cs:895-1170，
##       Event33-41.cs / Results_text.cs:2907-3681。
## 差异：
##  - 事件36 选项3、事件37 选项0 的禁用文案由 prepare 动态设置；
##  - OilProd 已建模（ws.oil_prod），Event36 两个选项各 +200；
##  - allcountries[69].numberOfSpecialEnding → tibet.special_ending。

const TXT_36_R2_BASED := "event.script.event_033_041_world_and_party.c0"

const TXT_36_R2_NOT_BASED := "event.script.event_033_041_world_and_party.c1"

const TXT_36_OPT3_DIS_LINE0 := "event.script.event_033_041_world_and_party.c2"
const TXT_36_OPT3_DIS_LINE4 := "event.script.event_033_041_world_and_party.c3"
const TXT_36_OPT3_DIS_OTHER := "event.script.event_033_041_world_and_party.c4"
const TXT_36_OPT3_ACTIVE := "event.script.event_033_041_world_and_party.c5"

const TXT_37_R1_SUCCESS := "event.script.event_033_041_world_and_party.c6"

const TXT_37_R1_FAILURE := "event.script.event_033_041_world_and_party.c7"

const TXT_37_OPT0_DIS := "event.script.event_033_041_world_and_party.c8"
const TXT_37_OPT0_ACTIVE := "event.script.event_033_041_world_and_party.c9"

const TXT_39_R2_BASE := "event.script.event_033_041_world_and_party.c10"

const TXT_39_R2_MAUSOLEUM := "event.script.event_033_041_world_and_party.c11"

const TXT_40_R1_REJECT := "event.script.event_033_041_world_and_party.c12"

const TXT_40_R1_ACCEPT := "event.script.event_033_041_world_and_party.c13"

const TXT_40_R3_SUCCESS := "event.script.event_033_041_world_and_party.c14"

const TXT_40_R3_FAILURE := "event.script.event_033_041_world_and_party.c15"


## 原版 Event36 TextOfEvents 的条件/末段描述（事件描述静态化后保留逐字文案备查）。
const TXT_36_DESC_BASED_1 := "event.script.event_033_041_world_and_party.c16"
const TXT_36_DESC_BASED_2 := "event.script.event_033_041_world_and_party.c17"
const TXT_36_DESC_BASED_3 := "event.script.event_033_041_world_and_party.c18"
const TXT_36_DESC_DAWA := "event.script.event_033_041_world_and_party.c19"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var dpre: WorldState = world
	if event_def.event_id == "iraqi_coalition" and event_def.options.size() >= 4:
		var line36: int = dpre.political_line
		var religion36: int = dpre.religion_policy
		var opt36 := event_def.options[3]
		if line36 > 0 and line36 < 4 and religion36 > 25:
			_enable(opt36, tr(TXT_36_OPT3_ACTIVE))
		elif line36 == 0:
			_disable(opt36, tr(TXT_36_OPT3_DIS_LINE0))
		elif line36 == 4:
			_disable(opt36, tr(TXT_36_OPT3_DIS_LINE4))
		else:
			_disable(opt36, tr(TXT_36_OPT3_DIS_OTHER))
	if event_def.event_id == "egyptian_unrest" and event_def.options.size() >= 1:
		var egypt37 := world.get_country_by_legacy_index(30)
		var ok37 := dpre.agents >= 60 and dpre.political_line <= 2 \
				and egypt37 != null and egypt37.stab == 1
		var opt37 := event_def.options[0]
		if ok37:
			_enable(opt37, tr(TXT_37_OPT0_ACTIVE))
		else:
			_disable(opt37, tr(TXT_37_OPT0_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"pakistan_coup": _event_33(option_index)
		"enemies_of_my_enemies": _event_34(option_index)
		"end_of_revolution": _event_35(option_index)
		"iraqi_coalition": _event_36(option_index, context)
		"egyptian_unrest": _event_37(option_index, context)
		"back_to_roots": _event_38(option_index)
		"historical_resolution": _event_39(option_index, context)
		"panchen_lama": _event_40(option_index, context)
		"indian_elections": _event_41(option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_33(option_index: int) -> void:
	var pakistan := ws.get_country_by_legacy_index(31)
	match option_index:
		0:
			_add_empire_power(EmpireData.USA, 30)
			d.thought_freedom += 30
			if pakistan != null:
				pakistan.government = GameConstants.Government.AUTHORITARIAN
				pakistan.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				pakistan.set_tag("亲美", true)
				pakistan.set_tag("亲中", false)
				pakistan.set_tag("对华贸易", false)
		1:
			_add_empire_relation(EmpireData.USA, -100)
			_add_data({W.I_INFLUENCE: 20, W.I_AGENTS: -60, W.I_BUDGET: -30})
			if pakistan != null:
				pakistan.government = GameConstants.Government.REFORMIST
				pakistan.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				pakistan.set_tag("亲美", false)
				pakistan.set_tag("亲中", true)
				pakistan.set_tag("sento", false)  # 帮助布托后巴基斯坦退出中央条约（CENTO）
				pakistan.prc_power = 1000
			_subtract_faction_fraction(FactionData.LIBERAL, 0.25)
		2:
			d.thought_freedom += 50
			_add_empire_relation(EmpireData.USA, 50)
			_add_empire_relation(EmpireData.USSR, -50)
			_add_empire_power(EmpireData.USA, 20)
			if pakistan != null:
				pakistan.government = GameConstants.Government.AUTHORITARIAN
				pakistan.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				pakistan.set_tag("亲美", true)
				pakistan.set_tag("亲中", false)


func _event_34(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -50})
			_subtract_faction_fraction(FactionData.REFORMIST, 0.50)
			_subtract_faction_fraction(FactionData.MODERATE, 0.15)
			_change_politicians({2: [-100, 0], 0: [100, 0]})
			_add_power_by_index({7: -100, 6: -100})
		1:
			d.party_support -= 100
			_add_faction_ideology({FactionData.CONSERVATIVE: 400})
			_change_politicians({0: [100, 0]})
			_add_power_by_index({5: 100, 8: 100, 9: 100})
		2:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_PEOPLE_SUPPORT: -50,
				W.I_THOUGHT_FREEDOM: 50, W.I_DIPLO: 20})
			_add_faction_ideology({FactionData.CONSERVATIVE: 400})
			_subtract_faction_fraction(FactionData.REFORMIST, 0.10)
			_subtract_faction_fraction(FactionData.MODERATE, 0.15)
			_change_politicians({2: [-200, 0], 0: [150, 0]})
			_add_power_by_index({6: -150, 7: -150})
		3:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_PEOPLE_SUPPORT: 50,
				W.I_THOUGHT_FREEDOM: 80, W.I_DIPLO: -20})
			_add_faction_ideology({FactionData.REFORMIST: 500})
			_change_politicians({2: [200, 120], 3: [0, 70], 0: [-200, 0]})
		4:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 30})
			_add_faction_ideology({FactionData.REFORMIST: 200})
			_change_politicians_at_least(2, 0, 70)


func _event_35(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_THOUGHT_FREEDOM: 40, W.I_PEOPLE_SUPPORT: -60})
			_change_politicians_at_least(1, -100, 0)
		1:
			_add_data({W.I_PEOPLE_SUPPORT: 60, W.I_THOUGHT_FREEDOM: 20,
				W.I_MANPOWER: -30, W.I_DIPLO: -20})
			_clamp_at_least(W.I_PRESS_POLICY, 17)
			_liberalization_party_effects(50, 30)
		2:
			_add_data({W.I_PEOPLE_SUPPORT: 70, W.I_THOUGHT_FREEDOM: 40, W.I_DIPLO: -30})
			_clamp_at_least(W.I_PRESS_POLICY, 17)
			_clamp_at_least(W.I_RELIGION, 25)
			_liberalization_party_effects(80, 30)
		3:
			_add_data({W.I_PEOPLE_SUPPORT: 90, W.I_THOUGHT_FREEDOM: 60, W.I_DIPLO: -40})
			_clamp_at_least(W.I_PRESS_POLICY, 17)
			_clamp_at_least(W.I_RELIGION, 26)
			_liberalization_party_effects(80, 50)


func _event_36(option_index: int, context: Dictionary) -> void:
	var iraq := ws.get_country_by_legacy_index(14)
	match option_index:
		0:
			_add_data({W.I_BUDGET: -50, W.I_AGENTS: -50})
			if iraq != null:
				_leave_alliances(iraq)
				iraq.government = GameConstants.Government.REFORMIST
				iraq.sub_government = GameConstants.SubGovernment.PRAGMATIST
				iraq.set_tag("对华贸易", true)
			ws.oil_prod += 200.0  # Event36.cs result0：扩大石油出口
			d.influence_prc += 10
			_add_empire_relation(EmpireData.USSR, -50)
		1:
			_add_data({W.I_BUDGET: -50, W.I_AGENTS: -50})
			if iraq != null:
				_leave_alliances(iraq)
				iraq.government = GameConstants.Government.AUTHORITARIAN
				iraq.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				iraq.set_tag("对华贸易", true)
			ws.oil_prod += 200.0  # Event36.cs result1：扩大石油出口
			d.influence_prc += 10
			_add_empire_relation(EmpireData.USSR, -50)
		2:
			if iraq != null:
				iraq.government = GameConstants.Government.AUTHORITARIAN
				iraq.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				iraq.set_tag("对华贸易", false)
				iraq.prc_power = 10
			_add_data({W.I_PARTY_SUPPORT: 70, W.I_THOUGHT_FREEDOM: -30,
				W.I_BUDGET: -50, W.I_AGENTS: -50})
			if iraq != null and iraq.有驻军基地:
				context["result_text"] = tr(TXT_36_R2_BASED)
			else:
				context["result_text"] = tr(TXT_36_R2_NOT_BASED)
		3:
			if iraq != null:
				iraq.government = GameConstants.Government.AUTHORITARIAN
				iraq.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				iraq.prc_power = 20
			_add_data({W.I_BUDGET: -50, W.I_AGENTS: -50})
		4:
			if iraq != null:
				iraq.government = GameConstants.Government.AUTHORITARIAN
				iraq.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST


func _event_37(option_index: int, context: Dictionary) -> void:
	var egypt := ws.get_country_by_legacy_index(30)
	var libya := ws.get_country_by_legacy_index(13)
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 20,
				W.I_AGENTS: -60, W.I_BUDGET: -40})
			_add_empire_relation(EmpireData.USA, -150)
			_add_empire_relation(EmpireData.USSR, 80)
			_add_empire_power(EmpireData.USA, -10)
			if egypt != null:
				egypt.government = GameConstants.Government.REFORMIST
				egypt.sub_government = GameConstants.SubGovernment.PRAGMATIST
				egypt.set_tag("亲美", false)
				egypt.set_tag("对华贸易", true)
		1:
			var success := (libya != null and libya.has_tag("对华贸易")) or (egypt != null and egypt.stab == 1)
			_add_data({W.I_AGENTS: -20, W.I_BUDGET: -20})
			if success:
				context["result_text"] = tr(TXT_37_R1_SUCCESS)
				_add_data({W.I_PARTY_SUPPORT: 20, W.I_INFLUENCE: 10})
				_add_empire_power(EmpireData.USSR, 20)
				_add_empire_power(EmpireData.USA, -20)
				_add_empire_relation(EmpireData.USSR, 50)
				if egypt != null:
					egypt.government = GameConstants.Government.REFORMIST
					egypt.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					egypt.set_tag("亲苏", true)
					egypt.set_tag("亲美", false)
			else:
				context["result_text"] = tr(TXT_37_R1_FAILURE)
				_add_empire_power(EmpireData.USA, -10)
				if egypt != null:
					egypt.set_tag("亲美", false)
		2:
			_add_data({W.I_AGENTS: -20, W.I_BUDGET: -20})
		3:
			_add_data({W.I_AGENTS: -20, W.I_BUDGET: -20})
		4:
			pass


func _event_38(option_index: int) -> void:
	match option_index:
		0:
			pass
		1:
			_add_data({W.I_BUDGET: -10, W.I_DIPLO: 20, W.I_THOUGHT_FREEDOM: 50,
				W.I_PEOPLE_SUPPORT: -40})
			_add_empire_relation(EmpireData.USA, -70)
			_add_empire_relation(EmpireData.USSR, 50)
			d.econ_system = 10
			_add_faction_ideology({FactionData.MAOIST: 250, FactionData.CONSERVATIVE: 250})
			_change_politicians({0: [100, 0], 1: [-30, 0], 2: [-100, 0]})
		2:
			_add_data({W.I_DIPLO: -10, W.I_THOUGHT_FREEDOM: 20, W.I_PEOPLE_SUPPORT: 30})
			_add_empire_relation(EmpireData.USSR, -70)
			_add_empire_relation(EmpireData.USA, 80)
			d.econ_system = 12
			_add_faction_ideology({FactionData.MODERATE: 450, FactionData.REFORMIST: 450})
			_change_politicians({2: [150, 100], 1: [70, 50], 0: [-170, -100]})


func _event_39(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_PEOPLE_SUPPORT: 20, W.I_DIPLO: 10})
			d.mao_history_line = 0
			_add_faction_ideology({FactionData.MAOIST: 150, FactionData.CONSERVATIVE: 150})
			_change_politicians({0: [100, 30], 1: [60, 20], 2: [50, 0], 3: [-100, -30]})
			var kill_index := _find_politician(13, 13)
			if kill_index >= 0:
				game.kill_politician(kill_index)
		1:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_PEOPLE_SUPPORT: 50,
				W.I_DIPLO: -30, W.I_COMMUNICATIONS: 20})
			d.mao_history_line = 1
			_add_faction_ideology({FactionData.MAOIST: 150, FactionData.CONSERVATIVE: 150})
			_change_politicians({0: [50, 10], 1: [100, 40], 2: [80, 30], 3: [60, 0]})
		2:
			if d.mao_mausoleum == 10:
				d.mao_mausoleum = 9
				context["result_text"] = tr(TXT_39_R2_BASE) + "\n" + tr(TXT_39_R2_MAUSOLEUM)
			else:
				context["result_text"] = tr(TXT_39_R2_BASE)
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_PEOPLE_SUPPORT: -50, W.I_DIPLO: -60})
			d.mao_history_line = 2
			_add_faction_ideology({FactionData.REFORMIST: 150, FactionData.LIBERAL: 100})
			_change_politicians({0: [-150, 0], 1: [-100, 0], 2: [50, 0], 3: [150, 0]})


func _event_40(option_index: int, context: Dictionary) -> void:
	var tibet := ws.get_country_by_legacy_index(69)
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: -50, W.I_DIPLO: 5})
		1:
			if d.religion_policy <= 25:
				_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: -60,
					W.I_DIPLO: 10, W.I_MANPOWER: -50, W.I_INFLUENCE: -10})
				context["result_text"] = tr(TXT_40_R1_REJECT)
			else:
				_add_data({W.I_PEOPLE_SUPPORT: 60, W.I_INFLUENCE: 10,
					W.I_MANPOWER: 40, W.I_DIPLO: -20})
				_add_empire_relation(EmpireData.USA, 50)
				if tibet != null:
					tibet.special_ending = 33
				context["result_text"] = tr(TXT_40_R1_ACCEPT)
		2:
			_add_data({W.I_PEOPLE_SUPPORT: 80, W.I_INFLUENCE: 10,
				W.I_MANPOWER: 40, W.I_AGENTS: -40, W.I_DIPLO: -20})
			_add_empire_relation(EmpireData.USA, 100)
			if tibet != null:
				tibet.special_ending = 33
		3:
			if d.religion_policy >= 26 and d.people_support >= 700:
				_add_data({W.I_INFLUENCE: 10, W.I_PEOPLE_SUPPORT: 120,
					W.I_DIPLO: -20, W.I_MANPOWER: 40})
				_add_empire_relation(EmpireData.USA, 120)
				_add_empire_relation(EmpireData.USSR, 50)
				if tibet != null:
					tibet.special_ending = 33
				context["result_text"] = tr(TXT_40_R3_SUCCESS)
			else:
				_add_data({W.I_PEOPLE_SUPPORT: -100, W.I_INFLUENCE: -20,
					W.I_MANPOWER: -100, W.I_DIPLO: 20})
				_add_empire_relation(EmpireData.USA, -100)
				context["result_text"] = tr(TXT_40_R3_FAILURE)
		4:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: -10,
				W.I_MANPOWER: -30, W.I_AGENTS: -70, W.I_BUDGET: -40,
				W.I_DIPLO: 20, W.I_PEOPLE_SUPPORT: -100})
			_add_empire_relation(EmpireData.USA, -100)


func _event_41(option_index: int) -> void:
	var india := ws.get_country_by_legacy_index(19)
	match option_index:
		0:
			d.influence_prc += 10
			d.india_election = 2
			if india != null:
				india.set_tag("对华贸易", true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 70, W.I_INFLUENCE: 20,
				W.I_BUDGET: -30, W.I_AGENTS: -50})
			d.india_election = 1
			_add_empire_relation(EmpireData.USSR, -70)
			if india != null:
				india.set_tag("对华贸易", true)
				india.set_tag("亲苏", false)
		2:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_AGENTS: -50, W.I_COMMUNICATIONS: 30})
			d.india_election = 3
			_add_empire_power(EmpireData.USSR, 20)
			_add_empire_relation(EmpireData.USSR, 100)


func _liberalization_party_effects(loyalty_delta: int, power_delta: int) -> void:
	_add_faction_ideology({FactionData.REFORMIST: 150, FactionData.MODERATE: 200})
	_change_politicians_at_least(1, loyalty_delta, power_delta)


func _clamp_at_least(index: int, value: int) -> void:
	if d.size() > index and d.get_data_by_index(index) < value:
		d.set_data_by_index(index, value)


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < d.size():
			d.add_data_by_index(index, int(changes[raw_index]))


func _change_politicians(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			var pair: Array = changes[politician.trait_personality]
			politician.loyalty += int(pair[0])
			politician.power += int(pair[1])


func _change_politicians_at_least(minimum: int, loyalty_delta: int, power_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null and politician.trait_personality >= minimum:
			politician.loyalty += loyalty_delta
			politician.power += power_delta


func _add_power_by_index(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.politicians.size() and ws.politicians[index] != null:
			ws.politicians[index].power += int(changes[raw_index])


func _add_faction_ideology(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _subtract_faction_fraction(faction_index: int, fraction: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		var current := ws.factions[faction_index].ideology
		ws.factions[faction_index].ideology = current - int(float(current) * fraction)


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1



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
