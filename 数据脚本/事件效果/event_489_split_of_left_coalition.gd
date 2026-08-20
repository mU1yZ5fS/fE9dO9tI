extends "res://数据脚本/event_script_base.gd"

## 原作 Event489.cs：左翼联合政府的分裂（土耳其三党选举，四选项）。
## 触发：ReqEventForDLC02.cs:1514-1516 ——
##   c84.cw && c84.Gosstroy==2 && 日期>=1984.1.1（原版第三子句 年>=1984 已蕴含）。
## 差异：
##  - Gosstroy/SubGosstroy → government/sub_government；
##  - prosov/proprc/Torg/isSocEU → set_tag；data[131] 原版无常量，raw index + 注释；
##  - LeaveAlliances() → _leave_alliances；JoinAllOurAlliances(true) → _join_alliances。




const TXT_R_COMMUNIST := "选举结果表明，联合共产党赢得多数选票。新政府宣布国家将向社会主义过渡，同苏东阵营展开合作，并要“解决一切过去遗留的历史问题”。他们承认了土耳其历史上的亚美尼亚种族灭绝事件，同时表示要尊重库尔德民族自决——土耳其控制下的库尔德人聚集区被赋予了自治权。苏东阵营欢迎新的兄弟加入他们的阵营。"

const TXT_R_PEOPLES := "选举结果表明，人民共产党赢得多数选票。新政府宣布国家将向社会主义过渡，并解决一切历史遗留问题。他们承认了土耳其历史上的亚美尼亚种族灭绝事件；与此同时，土耳其控制下的库尔德人聚集区被赋予了自治权。新政府宣布土耳其将向世界上革命的革命阵营靠拢，谴责一切修正主义。"

const TXT_R_REPUBLICAN := "选举结果表明，共和人民党赢得多数选票。新政府将推进土耳其式民主社会主义的构建，并推进国家的民主化进程。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	_enable(opt[2], event_def.options[2].text)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var turkey := ws.get_country_by_legacy_index(84)
	var spain := ws.get_country_by_legacy_index(86)
	var greece := ws.get_country_by_legacy_index(45)
	var britain := ws.get_country_by_legacy_index(92)
	var italy := ws.get_country_by_legacy_index(85)
	var france := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	var num3 := 0
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		num += 2
	elif opt == 1:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		num2 += 2
	elif opt == 2:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		num3 += 2
	if spain != null and spain.government == GameConstants.Government.SOCIALIST:
		num3 += 2
		num2 += 1
	elif spain != null and spain.government == GameConstants.Government.LIBERAL:
		num += 2
	# data[131]：原版无常量（世界局势变量），raw index + 注释。
	if d.size() > 131:
		if d[131] == 2:
			num3 += 1
			num2 += 1
		elif d[131] == 1:
			num2 += 1
		else:
			num += 2
	else:
		num += 2
	if greece != null and greece.government == GameConstants.Government.REFORMIST:
		num2 += 2
		num3 += 1
	elif greece != null and greece.government == GameConstants.Government.SOCIALIST:
		num3 += 2
		num2 += 1
	else:
		num += 1
	if britain != null and britain.government == GameConstants.Government.SOCIALIST:
		num3 += 1
		num2 += 1
	elif britain != null and britain.government == GameConstants.Government.REFORMIST:
		num2 += 1
		num3 += 1
	else:
		num += 1
	if italy != null and italy.government == GameConstants.Government.LIBERAL:
		num += 1
	elif italy != null and italy.government == GameConstants.Government.REFORMIST:
		num2 += 1
	elif italy != null and italy.government == GameConstants.Government.SOCIALIST:
		num3 += 1
	if france != null and france.has_tag("soc_eu"):
		num += 999
	if num2 >= num3 and num2 >= num:
		context["result_text"] = TXT_R_COMMUNIST
		if turkey != null:
			turkey.government = GameConstants.Government.SOCIALIST
			turkey.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
			_leave_alliances(turkey)
			turkey.set_tag("亲苏", true)
		_add_leader_support(EmpireData.USSR, 4, 1)
		if opt == 1:
			_add(W.I_DIPLO, 100)
			if turkey != null:
				turkey.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, 100)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 20
		_add_power(EmpireData.USSR, 50)
		return
	if num3 >= num2 and num3 >= num:
		context["result_text"] = TXT_R_PEOPLES
		if turkey != null:
			turkey.government = GameConstants.Government.SOCIALIST
			turkey.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			_leave_alliances(turkey)
		if opt == 2:
			_add(W.I_DIPLO, 100)
			if turkey != null:
				turkey.set_tag("亲中", true)
				turkey.set_tag("对华贸易", true)
				_join_alliances(turkey)
			_add_relation(EmpireData.USA, -150)
			ws.influence_prc += 50
		return
	context["result_text"] = TXT_R_REPUBLICAN
	if turkey != null:
		turkey.government = GameConstants.Government.REFORMIST
		turkey.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		_leave_alliances(turkey)
		if france != null and france.has_tag("soc_eu"):
			turkey.set_tag("soc_eu", true)
	if opt == 0:
		_add(W.I_DIPLO, 50)
		if turkey != null:
			turkey.set_tag("对华贸易", true)
		ws.influence_prc += 30


func _add_leader_support(empire_index: int, leader_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		var empire: EmpireData = ws.empires[empire_index]
		if leader_index >= 0 and leader_index < empire.leaders.size() and empire.leaders[leader_index] != null:
			empire.leaders[leader_index].support += delta



func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)


