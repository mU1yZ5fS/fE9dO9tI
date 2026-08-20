extends "res://数据脚本/event_script_base.gd"

## 原作由国家面板外交操作直接触发的事件 27–32。
## 来源：DiploButtonScript.cs:79-92,279-291,321-329,860-868,960-980,1010-1020,
##       Event27-32.cs / Results_text.cs:2563-3168。
## 差异：
##  - 事件31 选项3 的政治路线分支禁用文案由 prepare 动态设置；
##  - 事件29 选项3 的 isSEV 分支用 ussr.has_tag("sev") 表达；
##  - 事件30 选项2 的国名与政体复制按原版逐项移植；
##    原版 PlayerPrefs.GetInt("language") 分支国名：中文/俄文，项目固定中文。

const TXT_27_FAIL := "经过长时间的谈判，英国和葡萄牙拒绝了我们的条件，认为这是不可接受的，这给党和人民带来了极大的挫折。看来殖民地的回归问题被无限期地推迟了。至少，在这样的情况下，英国仍准备在1997年或者其他的时候返还新界。"

const TXT_29_R1_FAIL := "金日成不愿向我们做出让步，所以他向苏联求助。苏联很高兴地增加了对朝鲜的物资援助，并向朝鲜派遣了一支小分队以建立军事基地。朝鲜以前在中国和苏联间保持中立，但他们现在已坚定地进入苏联的势力范围。"

const TXT_29_R3_SEV := "金日成不愿向我们做出让步，所以他向苏联求助。苏联很高兴地增加了对朝鲜的物资援助，并向朝鲜派遣了一支小分队以建立军事基地。朝鲜以前在中国和苏联间保持中立，但他们现在已坚定地进入苏联的势力范围。"

const TXT_29_R3_NO_SEV := "金日成十分不情愿，但是苦于苏联此时忙于改革，无暇东顾，只能被迫接受我国意见，但是仍然以保障退休为条件来换取下台让张成泽接班。张成泽上台之后进行了温和的去金化改革，包括调整经济制度为国家管控资本主义，释放劳改营里的政治犯，逐步平反南方派和延安派，与西方国家缓和关系，甚至对南边的宣传火药味也淡了下来。"

const TXT_30_FAIL := "尽管我们作出了所有努力，但各方未能达成妥协，我们的建议遭到拒绝，谈判失败。新一轮的暴力似乎即将开始。"

const TXT_30_R2_NAME_ZH := "巴以联盟国家"
const TXT_30_R2_NAME_RU := "Союзное Гос-во"

const TXT_31_OPT3_DIS_LINE0 := "我们不能支持军政府独裁者"
const TXT_31_OPT3_DIS_MONEY := "我们没那能力支持"
const TXT_31_OPT3_ACTIVE := "支持卢泰愚"

const TXT_32_R1_ZALAN := "1984年8月23日，蒙古人民革命党中央委员会举行的非常全会解除了泽登巴尔担任的蒙古人民革命党中央委员会总书记和政治局委员的职务。同日，蒙古大人民呼拉尔第五次会议解除了泽登巴尔的大人民呼拉尔主席团主席职务。此后，泽登巴尔在苏联居住。蒙古第二号人物桑丕勒·扎兰阿扎布当选为蒙古人民革命党中央委员会总书记，同年12月12日被任命为大人民呼拉尔主席团主席。他结束了蒙古的亲苏政策，并开始寻求更加独立的政策。"
const TXT_32_R1_BATMUNKH := "1984年8月23日，蒙古人民革命党中央委员会举行的非常全会解除了泽登巴尔担任的蒙古人民革命党中央委员会总书记和政治局委员的职务。同日，蒙古大人民呼拉尔第五次会议解除了泽登巴尔的大人民呼拉尔主席团主席职务。此后，泽登巴尔在苏联居住。保守派的姜巴·巴特蒙赫当选为蒙古人民革命党中央委员会总书记，同年12月12日被任命为大人民呼拉尔主席团主席。巴特蒙赫在中蒙关系上采取了更加务实的态度，希望推进蒙中关系正常化。"

const TXT_28_WAR_NAME := "印度尼西亚革命"
const TXT_28_WAR_SIDE1 := "印度尼西亚反对派"
const TXT_28_WAR_SIDE2 := "印度尼西亚政府"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	if event_def.event_id == "south_korea_election" and event_def.options.size() >= 4:
		var line: int = world.数值表[W.I_POLITICAL_LINE]
		var opt := event_def.options[3]
		if line == 0:
			_disable(opt, TXT_31_OPT3_DIS_LINE0)
		else:
			_enable(opt, TXT_31_OPT3_ACTIVE)


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
			d[W.I_HK_MACAU_STATUS] = 1
		1:
			if (d[W.I_DIPLO] <= 600 or d[W.I_INFLUENCE] >= 150) and _relation(EmpireData.USA) >= 800:
				_add_data(d, {W.I_PEOPLE_SUPPORT: 100, W.I_INFLUENCE: 50, W.I_PARTY_SUPPORT: 100})
				d[W.I_HK_MACAU_STATUS] = 1
			else:
				_set_negotiation_failure(context)
				_add_data(d, {W.I_PEOPLE_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 50,
					W.I_INFLUENCE: -30, W.I_PARTY_SUPPORT: -100})
		2:
			if (d[W.I_DIPLO] <= 500 or d[W.I_INFLUENCE] >= 250) and _relation(EmpireData.USA) >= 800:
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
			if indonesia != null:
				indonesia.government = GameConstants.Government.AUTHORITARIAN
				indonesia.sub_government = GameConstants.SubGovernment.NEO_FASCIST
		1:
			_add_data(d, {W.I_BUDGET: -20, W.I_AGENTS: -20})
			_add_power(EmpireData.USA, -20)
			d[W.I_INFLUENCE] += 5
			if indonesia != null:
				indonesia.set_tag("亲美", false)
				indonesia.government = GameConstants.Government.LIBERAL
				indonesia.set_tag("对华贸易", true)
				indonesia.sub_government = GameConstants.SubGovernment.LIBERAL
			_change_loyalty(func(personality: int) -> bool: return personality <= 2, 70)
		2:
			_add_data(d, {W.I_BUDGET: -60, W.I_AGENTS: -60, W.I_DIPLO: 20})
			_add_power(EmpireData.USA, -40)
			d[W.I_INFLUENCE] += 20
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
					war.name_war = TXT_28_WAR_NAME
					war.is_going = true
					war.side1 = TXT_28_WAR_SIDE1
					war.side2 = TXT_28_WAR_SIDE2
					war.usa_side = GameConstants.WarSide.SIDE2
					war.infl1 = 300
					war.infl2 = 700
					war.fortnight_max = 20
			_add_relation(EmpireData.USA, -300)
			d[W.I_INFLUENCE] += 20


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
					north_korea.government = GameConstants.Government.REFORMIST
					north_korea.sub_government = GameConstants.SubGovernment.PRAGMATIST
			else:
				_set_korea_soviet_result(context)
				_apply_korea_soviet_turn(north_korea)
		2:
			d[W.I_INFLUENCE] += 10
			d[W.I_BUDGET] += 40
			_change_loyalty(func(personality: int) -> bool: return personality >= 1, 100)
		3:
			var ussr := ws.get_country_by_legacy_index(7)
			if ussr != null and ussr.has_tag("sev"):
				_set_korea_soviet_result(context)
				_apply_korea_soviet_turn(north_korea)
			else:
				context["result_text"] = TXT_29_R3_NO_SEV
				d[W.I_INFLUENCE] += 30
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
			if d[W.I_INFLUENCE] >= 150:
				d[W.I_INFLUENCE] += 10
				_add_relation(EmpireData.USSR, 100)
				_add_relation(EmpireData.USA, -50)
				d[W.I_PALESTINE_STATUS] = 2
				if israel != null:
					israel.set_tag("亲美", false)
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
				var china := ws.get_country_by_legacy_index(1)
				d[W.I_INFLUENCE] += 30
				_add_relation(EmpireData.USA, -50)
				_add_relation(EmpireData.USSR, 100)
				d[W.I_PALESTINE_STATUS] = 3
				if israel != null:
					israel.set_tag("亲美", false)
					israel.set_tag("亲中", true)
					if china != null:
						israel.government = china.government
						israel.sub_government = china.sub_government
					israel.name = TXT_30_R2_NAME_ZH
			else:
				_apply_peace_failure(context)


func _event_31(option_index: int) -> void:
	var south_korea := ws.get_country_by_legacy_index(46)
	match option_index:
		0:
			d[W.I_INFLUENCE] -= 10
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
			d[W.I_INFLUENCE] += 5
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
			d[W.I_INFLUENCE] += 20
		1:
			if int(ws.completed_event_ids.get("event_549", -1)) == 0:
				context["result_text"] = TXT_32_R1_ZALAN
				_add_power(EmpireData.USSR, -10)
				_add_relation(EmpireData.USSR, -80)
				if mongolia != null:
					mongolia.set_tag("亲苏", false)
			else:
				context["result_text"] = TXT_32_R1_BATMUNKH
				_add_power(EmpireData.USSR, 10)


func _modifier_active(modifier_index: int) -> bool:
	return ws.modifiers.size() > modifier_index and ws.modifiers[modifier_index] != null \
			and ws.modifiers[modifier_index].is_active


func _add_data(data: Array[int], changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < data.size():
			data[index] += int(changes[raw_index])


func _relation(empire_index: int) -> int:
	return ws.empires[empire_index].relations if empire_index >= 0 and empire_index < ws.empires.size() else 0


func _power(empire_index: int) -> int:
	return ws.empires[empire_index].power if empire_index >= 0 and empire_index < ws.empires.size() else 0


func _add_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


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
	context["result_text"] = TXT_30_FAIL
	_add_relation(EmpireData.USA, -100)
	_add_data(d, {W.I_INFLUENCE: -20, W.I_PARTY_SUPPORT: -100})


func _set_negotiation_failure(context: Dictionary) -> void:
	context["result_text"] = TXT_27_FAIL


func _set_korea_soviet_result(context: Dictionary) -> void:
	context["result_text"] = TXT_29_R1_FAIL




func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
