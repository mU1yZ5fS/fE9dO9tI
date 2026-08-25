extends "res://数据脚本/event_script_base.gd"

## 原作由国家面板外交操作直接触发的事件 27–32。
## 来源：DiploButtonScript.cs:79-92,279-291,321-329,860-868,960-980,1010-1020,
##       Event27-32.cs / Results_text.cs:2563-3168。
## 差异：
##  - 事件31 选项3 的政治路线分支禁用文案由 prepare 动态设置；
##  - 事件29 选项3 的 isSEV 分支用 ussr.has_tag("sev") 表达；
##  - 事件30 选项2 的国名与政体复制按原版逐项移植；
##    原版 PlayerPrefs.GetInt("language") 分支国名：中文/俄文，项目固定中文。

const TXT_27_FAIL := "event.script.event_027_032_diplomacy.c0"

const TXT_29_R1_FAIL := "event.script.event_027_032_diplomacy.c1"

const TXT_29_R3_SEV := "event.script.event_027_032_diplomacy.c2"

const TXT_29_R3_NO_SEV := "event.script.event_027_032_diplomacy.c3"

const TXT_30_FAIL := "event.script.event_027_032_diplomacy.c4"

const TXT_30_R2_NAME_ZH := "event.script.event_027_032_diplomacy.c5"
const TXT_30_R2_NAME_RU := "event.script.event_027_032_diplomacy.c6"

const TXT_31_OPT3_DIS_LINE0 := "event.script.event_027_032_diplomacy.c7"
const TXT_31_OPT3_DIS_MONEY := "event.script.event_027_032_diplomacy.c8"
const TXT_31_OPT3_ACTIVE := "event.script.event_027_032_diplomacy.c9"

const TXT_32_R1_ZALAN := "event.script.event_027_032_diplomacy.c10"
const TXT_32_R1_BATMUNKH := "event.script.event_027_032_diplomacy.c11"

const TXT_28_WAR_NAME := "event.script.event_027_032_diplomacy.c12"
const TXT_28_WAR_SIDE1 := "event.script.event_027_032_diplomacy.c13"
const TXT_28_WAR_SIDE2 := "event.script.event_027_032_diplomacy.c14"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	if event_def.event_id == "south_korea_election" and event_def.options.size() >= 4:
		var line: int = world.political_line
		var opt := event_def.options[3]
		if line == 0:
			_disable(opt, tr(TXT_31_OPT3_DIS_LINE0))
		else:
			_enable(opt, tr(TXT_31_OPT3_ACTIVE))


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
		"mongolia_reform": _event_32(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_27(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data(d, {W.I_PEOPLE_SUPPORT: 100, W.I_THOUGHT_FREEDOM: 100,
				W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: 20})
			d.hk_macau_status = 1
		1:
			if (d.diplomatic_reputation <= 600 or d.global_influence >= 150) and _relation(EmpireData.USA) >= 800:
				_add_data(d, {W.I_PEOPLE_SUPPORT: 100, W.I_INFLUENCE: 50, W.I_PARTY_SUPPORT: 100})
				d.hk_macau_status = 1
			else:
				_set_negotiation_failure(context)
				_add_data(d, {W.I_PEOPLE_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 50,
					W.I_INFLUENCE: -30, W.I_PARTY_SUPPORT: -100})
		2:
			if (d.diplomatic_reputation <= 500 or d.global_influence >= 250) and _relation(EmpireData.USA) >= 800:
				_add_data(d, {W.I_PEOPLE_SUPPORT: 120, W.I_PARTY_SUPPORT: 200, W.I_INFLUENCE: 100})
				d.hk_macau_status = 2
			else:
				_set_negotiation_failure(context)
				_add_data(d, {W.I_PEOPLE_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 50,
					W.I_INFLUENCE: -30, W.I_PARTY_SUPPORT: -100})


func _event_28(option_index: int) -> void:
	var indonesia := ws.get_country_by_legacy_index(50)
	match option_index:
		0:
			if indonesia != null:
				indonesia.government = GameConstants.Government.AUTHORITARIAN
				indonesia.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		1:
			_add_data(d, {W.I_BUDGET: -20, W.I_AGENTS: -20})
			_add_power(EmpireData.USA, -20)
			d.global_influence += 5
			if indonesia != null:
				indonesia.set_tag("亲美", false)
				indonesia.government = GameConstants.Government.LIBERAL
				indonesia.set_tag("对华贸易", true)
				indonesia.sub_government = GameConstants.SubGovernment.LIBERAL
			_change_loyalty(func(personality: int) -> bool: return personality <= 2, 70)
		2:
			_add_data(d, {W.I_BUDGET: -60, W.I_AGENTS: -60, W.I_DIPLO: 20})
			_add_power(EmpireData.USA, -40)
			d.global_influence += 20
			if indonesia != null:
				indonesia.set_tag("亲美", false)
				indonesia.set_tag("asean", false)
				indonesia.government = GameConstants.Government.REFORMIST
				indonesia.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				indonesia.set_tag("对华贸易", true)
			_change_loyalty(func(personality: int) -> bool: return personality <= 1, 100)
		3:
			_add_data(d, {W.I_BUDGET: -100, W.I_AGENTS: -100, W.I_DIPLO: 40})
			if indonesia != null:
				indonesia.government = GameConstants.Government.AUTHORITARIAN
				indonesia.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			if ws.wars.size() > 35:
				var war := ws.wars[35]
				if war != null:
					war.name_war = tr(TXT_28_WAR_NAME)
					war.is_going = true
					war.side1 = tr(TXT_28_WAR_SIDE1)
					war.side2 = tr(TXT_28_WAR_SIDE2)
					war.usa_side = GameConstants.WarSide.SIDE2
					war.infl1 = 300
					war.infl2 = 700
					war.fortnight_max = 20
			_add_relation(EmpireData.USA, -300)
			d.global_influence += 20


func _event_29(option_index: int, context: Dictionary) -> void:
	var north_korea := ws.get_country_by_legacy_index(10)
	match option_index:
		0:
			d.global_influence += 10
			_add_relation(EmpireData.USA, 70)
			_change_loyalty_split(1, -50, 50)
		1:
			if d.global_influence > _power(EmpireData.USSR):
				d.global_influence += 10
				_add_relation(EmpireData.USA, 100)
				_add_relation(EmpireData.USSR, -100)
				_add_power(EmpireData.USA, 30)
				_change_loyalty_split(1, -100, 100)
				if north_korea != null:
					north_korea.government = GameConstants.Government.REFORMIST
					north_korea.sub_government = GameConstants.SubGovernment.PRAGMATIST
			else:
				_set_korea_soviet_result(context)
				_apply_korea_soviet_turn(north_korea)
		2:
			d.global_influence += 10
			d.budget += 40
			_change_loyalty(func(personality: int) -> bool: return personality >= 1, 100)
		3:
			var ussr := ws.get_country_by_legacy_index(7)
			if ussr != null and ussr.has_tag("sev"):
				_set_korea_soviet_result(context)
				_apply_korea_soviet_turn(north_korea)
			else:
				context["result_text"] = tr(TXT_29_R3_NO_SEV)
				d.global_influence += 30
				_add_relation(EmpireData.USA, 150)
				_add_relation(EmpireData.USSR, -150)
				_change_loyalty_split(0, -120, 120)
				if north_korea != null:
					north_korea.government = GameConstants.Government.REFORMIST
					north_korea.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST


func _event_30(option_index: int, context: Dictionary) -> void:
	var israel := ws.get_country_by_legacy_index(37)
	match option_index:
		0:
			if d.global_influence >= 150:
				d.global_influence += 10
				_add_relation(EmpireData.USSR, 100)
				_add_relation(EmpireData.USA, -50)
				d.palestine_status = 2
				if israel != null:
					israel.set_tag("亲美", false)
			else:
				_apply_peace_failure(context)
		1:
			d.global_influence += 10
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, 50)
			d.palestine_status = 1
		2:
			var player := ws.get_player_country()
			var oar_active := ws.oar or ws.get_flag("oar") or (player != null and player.has_tag("oar"))
			if d.global_influence >= 200 and oar_active:
				var china := ws.get_country_by_legacy_index(1)
				d.global_influence += 30
				_add_relation(EmpireData.USA, -50)
				_add_relation(EmpireData.USSR, 100)
				d.palestine_status = 3
				if israel != null:
					israel.set_tag("亲美", false)
					israel.set_tag("亲中", true)
					if china != null:
						israel.government = china.government
						israel.sub_government = china.sub_government
					israel.name = tr(TXT_30_R2_NAME_ZH)
			else:
				_apply_peace_failure(context)


func _event_31(option_index: int) -> void:
	var south_korea := ws.get_country_by_legacy_index(46)
	match option_index:
		0:
			d.global_influence -= 10
			if south_korea != null:
				south_korea.government = GameConstants.Government.AUTHORITARIAN
				south_korea.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
		1:
			_add_data(d, {W.I_BUDGET: -50, W.I_DIPLO: -10, W.I_INFLUENCE: 10})
			_add_relation(EmpireData.USA, 50)
			if south_korea != null:
				south_korea.set_tag("亲美", false)
				south_korea.government = GameConstants.Government.LIBERAL
				south_korea.sub_government = GameConstants.SubGovernment.MODERATE
				south_korea.set_tag("对华贸易", true)
		2:
			_add_data(d, {W.I_BUDGET: -30, W.I_DIPLO: -15, W.I_INFLUENCE: 10})
			_add_relation(EmpireData.USA, 50)
			if south_korea != null:
				south_korea.government = GameConstants.Government.LIBERAL
				south_korea.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				south_korea.set_tag("对华贸易", true)
		3:
			d.global_influence += 5
			_add_data(d, {W.I_BUDGET: -30, W.I_DIPLO: 10})
			if south_korea != null:
				south_korea.government = GameConstants.Government.AUTHORITARIAN
				south_korea.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				south_korea.set_tag("对华贸易", true)
		4:
			_add_relation(EmpireData.USA, -100)
			_add_data(d, {W.I_BUDGET: -80, W.I_DIPLO: 15, W.I_INFLUENCE: 20})
			if south_korea != null:
				south_korea.set_tag("亲美", false)
				south_korea.government = GameConstants.Government.REFORMIST
				south_korea.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				south_korea.set_tag("对华贸易", true)


func _event_32(option_index: int, context: Dictionary) -> void:
	var mongolia := ws.get_country_by_legacy_index(9)
	var china := ws.get_country_by_legacy_index(1)
	match option_index:
		0:
			if mongolia != null:
				if china != null:
					if (china.government == GameConstants.Government.SOCIALIST and _modifier_active(6)) or china.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
						mongolia.government = GameConstants.Government.SOCIALIST
						mongolia.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
					elif china.government == GameConstants.Government.SOCIALIST and not _modifier_active(6):
						mongolia.government = GameConstants.Government.SOCIALIST
						mongolia.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					elif china.government == GameConstants.Government.REFORMIST:
						mongolia.government = GameConstants.Government.REFORMIST
						mongolia.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				mongolia.set_tag("对华贸易", true)
				mongolia.set_tag("亲苏", false)
				mongolia.set_tag("亲中", true)
				mongolia.set_tag("sev", false)
			_add_data(d, {W.I_BUDGET: -100, W.I_AGENTS: -100})
			_add_relation(EmpireData.USSR, -100)
			_add_power(EmpireData.USSR, -20)
			d.global_influence += 20
		1:
			if int(ws.completed_event_ids.get("event_549", -1)) == 0:
				context["result_text"] = tr(TXT_32_R1_ZALAN)
				_add_power(EmpireData.USSR, -10)
				_add_relation(EmpireData.USSR, -80)
				if mongolia != null:
					mongolia.set_tag("亲苏", false)
			else:
				context["result_text"] = tr(TXT_32_R1_BATMUNKH)
				_add_power(EmpireData.USSR, 10)


func _modifier_active(modifier_index: int) -> bool:
	return ws.modifiers.size() > modifier_index and ws.modifiers[modifier_index] != null \
			and ws.modifiers[modifier_index].is_active


func _add_data(data: WorldState, changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < data.size():
			data.add_data_by_index(index, int(changes[raw_index]))


func _relation(empire_index: int) -> int:
	return ws.empires[empire_index].relations if empire_index >= 0 and empire_index < ws.empires.size() else 0


func _power(empire_index: int) -> int:
	return ws.empires[empire_index].power if empire_index >= 0 and empire_index < ws.empires.size() else 0


func _add_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)


func _change_loyalty(predicate: Callable, delta: int) -> void:
	for politician in ws.politicians:
		if politician != null and predicate.call(politician.trait_personality):
			politician.loyalty += delta


func _change_loyalty_split(threshold: int, low_delta: int, high_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null:
			politician.loyalty += low_delta if politician.trait_personality <= threshold else high_delta


func _apply_korea_soviet_turn(north_korea: CountryData) -> void:
	_add_power(EmpireData.USSR, 20)
	_add_data(d, {W.I_INFLUENCE: -20, W.I_PARTY_SUPPORT: -100})
	if north_korea != null:
		north_korea.set_tag("亲苏", true)
		north_korea.set_tag("亲中", false)
		north_korea.set_tag("对华贸易", false)


func _apply_peace_failure(context: Dictionary) -> void:
	context["result_text"] = tr(TXT_30_FAIL)
	_add_relation(EmpireData.USA, -100)
	_add_data(d, {W.I_INFLUENCE: -20, W.I_PARTY_SUPPORT: -100})


func _set_negotiation_failure(context: Dictionary) -> void:
	context["result_text"] = tr(TXT_27_FAIL)


func _set_korea_soviet_result(context: Dictionary) -> void:
	context["result_text"] = tr(TXT_29_R1_FAIL)




func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.usa_relations = ws.empires[EmpireData.USA].relations
		ws.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.ussr_relations = ws.empires[EmpireData.USSR].relations
		ws.soviet_influence = ws.empires[EmpireData.USSR].power
