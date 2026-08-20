extends "res://数据脚本/event_script_base.gd"

## 原作阿富汗事件链：63 → 48 → 49/50/51 → 52。
## 来源：TimeScript.cs:3838-3889，doneventscript.cs:1225-1310,1499-1522，
##       Results_text.cs:4162-4648。

## 原版 Event48 result2 动态文案（领导人人名由 _leader_name() 插入）。
const TXT_48_R2_A := "继续我们与苏联的友好关系，并不真正信任阿明，"
const TXT_48_R2_B := "决定与苏联就阿明政权对民主共和国的危险和清除他的必要性进行秘密谈判，尽管中央委员会个别成员提出抗议。但苏联领导人对我们愿意这样“结束”一个潜在盟友感到非常惊讶，而且似乎并不完全信任我们，但总的来说，他们非常高兴。我们将等待这些事件的进一步发展。阿明上台后，针对他目前和潜在的政治对手，发起了广泛的肃清运动。尽管有“消灭封建领主”的政策，但在这一政策下，不仅仅是在“消灭封建领主”。尽管它假装一切都很好，但苏联似乎对政变有些不满。我们的秘密大使和特勤处与阿明建立了联系，阿明对新盟友的获得非常满意。然而，与此同时，他开始要求我们向阿富汗提供物质援助。"

## 原版 Event49 result0 两分支文案。
const TXT_49_R0_SARWARI := "12月27日晚，克格勃特种部队的苏联部队和军队封锁了喀布尔驻军的部分地区，并占领了总参谋部大楼，冲进了阿明的住所，在那里他被杀害了（尽管命令里要求他活着）。在苏联的支持下，阿富汗由阿萨杜拉·萨瓦里领导，他是人民派的一名成员，也是阿富汗特勤部队的前负责人，被阿明所镇压。总的来说，尽管军队中仍有个别忠于阿明的部分抵抗，但他的免职毫无问题。与此同时，苏联军队的进入和部署仍在继续。"
const TXT_49_R0_KARMAL := "12月27日晚，克格勃特种部队的苏联部队和军队封锁了喀布尔驻军的部分地区，并占领了总参谋部大楼，冲进了阿明的住所，在那里他被杀害了（尽管命令里要求他活着）。在苏联的支持下，阿富汗由巴布拉克·卡尔迈勒领导，巴布拉克·卡尔迈勒是旗帜派的创始人和常任领导人，也是阿明的长期对手。总的来说，尽管军队中仍有个别忠于阿明的部分抵抗，但他的免职毫无问题。与此同时，苏联军队的进入和部署仍在继续。"

## 原版 Event50 result2 动态文案。
const TXT_50_R2_A := "在政治局进行了长时间的讨论后，个别党员顽固地抗议支持亲苏的阿富汗民主共和国政权，"
const TXT_50_R2_B := "同志仍然坚持支持阿富汗民主共和国的策略（至少是口头上），这样的话他们绝对不会介意。与此同时，在这个国家，内战正如火如荼般的进行着，没有人能预料到战争的结果。"

## 原版 ingamewars[5] 中文侧名。
const WAR_AFGHAN_NAME := "阿富汗内战"
const WAR_DRA := "阿富汗民主共和国"
const WAR_MUJAHIDEEN := "圣战者"
const WAR_MAOIST_NAME := "阿富汗毛派起义"
const WAR_MAOIST := "毛派"
const WAR_JOINT_OPPOSITION := "联合反对派"

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
			ws.数值表[W.I_AFGHAN_PARCHAM] = 110
			_add_empire_relation(EmpireData.USSR, 70)
			context["result_text"] = TXT_48_R2_A + _leader_name() + TXT_48_R2_B


func _event_49(option_index: int, context: Dictionary) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null:
		afghanistan.set_tag("亲美", false)
	match option_index:
		0:
			_add_empire_power(EmpireData.USSR, 10)
			ws.数值表[W.I_INFLUENCE] += 20
			if ws.数值表[W.I_AFGHAN_PARCHAM] > 150:
				ws.数值表[W.I_AFGHAN_KHALQ] = 150
				ws.数值表[W.I_AFGHAN_PARCHAM] = 100
				ws.数值表[W.I_AFGHAN_WAR_PATH] = 9
				context["result_text"] = TXT_49_R0_SARWARI
			else:
				ws.数值表[W.I_AFGHAN_KHALQ] = 100
				ws.数值表[W.I_AFGHAN_PARCHAM] = 150
				context["result_text"] = TXT_49_R0_KARMAL
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
			_start_afghan_war(WAR_DRA, WAR_MUJAHIDEEN, 500, 500, 1, -1, true)


func _event_50(option_index: int, context: Dictionary) -> void:
	var afghanistan := ws.get_country_by_legacy_index(12)
	if afghanistan != null: afghanistan.set_tag("亲美", false)
	match option_index:
		0:
			_start_afghan_war(WAR_DRA, WAR_MUJAHIDEEN, 750, 250, 1, 0, true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 10,
				W.I_AFGHAN_OPPOSITION: 80, W.I_DIPLO: 20, W.I_COMMUNICATIONS: 30})
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USA, -250)
			_add_empire_relation(EmpireData.USSR, 50)
			_start_afghan_war(WAR_DRA, WAR_MUJAHIDEEN, 770, 230, 1, 0, true)
		2:
			_add_data({W.I_PARTY_SUPPORT: -70, W.I_DIPLO: 10, W.I_COMMUNICATIONS: 20})
			_add_empire_power(EmpireData.USSR, -20)
			_add_empire_relation(EmpireData.USA, -300)
			_add_empire_relation(EmpireData.USSR, 100)
			_start_afghan_war(WAR_DRA, WAR_MUJAHIDEEN, 760, 240, 1, 0, true)
			context["result_text"] = TXT_50_R2_A + _leader_name() + TXT_50_R2_B
		3:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_DIPLO: 30})
			_add_empire_power(EmpireData.USSR, -30)
			_add_empire_relation(EmpireData.USSR, -150)
			_add_empire_relation(EmpireData.USA, -150)
			_start_afghan_war(WAR_MAOIST, WAR_JOINT_OPPOSITION, 50, 950, 1, 1, false)
		4:
			ws.数值表[W.I_BUDGET] += 50
			_add_empire_power(EmpireData.USSR, -30)
			_add_empire_relation(EmpireData.USA, 200)
			_add_empire_relation(EmpireData.USSR, -200)
			_start_afghan_war(WAR_DRA, WAR_MUJAHIDEEN, 700, 300, 1, 0, true)


func _event_51(option_index: int) -> void:
	match option_index:
		0:
			pass
		1:
			ws.数值表[W.I_DIPLO] -= 10
			_add_empire_relation(EmpireData.USA, 80)
			_add_empire_relation(EmpireData.USSR, -100)
		2:
			ws.数值表[W.I_PARTY_SUPPORT] -= 50
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
				ws.数值表[W.I_AFGHAN_POLICY] = 1
			else:
				war.infl1 += 100
				war.infl2 -= 100
		2:
			_add_data({W.I_BUDGET: 30, W.I_DIPLO: -10})
			_add_empire_relation(EmpireData.USA, 100)
			_add_empire_relation(EmpireData.USSR, -120)
			war.infl1 -= 80
			war.infl2 += 80
			ws.数值表[W.I_AFGHAN_POLICY] = 2
		3:
			_add_data({W.I_BUDGET: -50, W.I_ARMY: -100, W.I_DIPLO: 30})
			_add_empire_relation(EmpireData.USA, -100)
			_add_empire_relation(EmpireData.USSR, -100)
			war.infl1 += 10
			war.infl2 -= 10
			ws.数值表[W.I_AFGHAN_POLICY] = 3
	_clamp_war(war)


func _start_afghan_war(
		side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, apply_regional_modifiers: bool) -> void:
	GameManager.start_war(5, side1, side2, infl1, infl2, usa_side, maxi(ussr_side, 0))
	var war := _war(5)
	if war == null:
		return
	war.ussr_side = ussr_side
	if apply_regional_modifiers:
		var pakistan := ws.get_country_by_legacy_index(31)
		if pakistan != null and pakistan.has_tag("亲美"):
			war.infl1 -= 100
			war.infl2 += 100
		var iran := ws.get_country_by_legacy_index(8)
		if iran != null and iran.government == GameConstants.Government.AUTHORITARIAN:
			war.infl1 -= 50
			war.infl2 += 50
		if ws.数值表[W.I_AFGHAN_WAR_PATH] == 9:
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
		if index >= 0 and index < ws.数值表.size():
			ws.数值表[index] += int(changes[raw_index])


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
