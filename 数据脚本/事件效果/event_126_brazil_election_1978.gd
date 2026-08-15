extends "res://数据脚本/event_script_base.gd"

## 原作 Event126.cs：快乐里约（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_TITLE := "快乐里约"
const TXT_DESC := "长期以来，巴西一直由一个披着民主外衣的军政府所统治。在所谓“受控民主”下选举始终由国家革新联盟取胜，它是个保守的巴西政党，旨在为军事独裁提供政治支持。该国现任总统是埃内斯托·盖泽尔，他属于军队中的温和派，因其将1964年上台的军政府视为确保该国自由主义的过渡政权。在盖泽尔的统治下，巴西开始逐渐向自由民过渡主，审查制度有所放松、镇压行为减少，国家对法院和州长的控制也得以增强。但他没有争取连任，蓬勃兴起的反对派可能会赢得即将到来的选举。目前选举中有两名候选人：来自国家革新联盟的若昂·菲格雷多和来自巴西民主运动的欧拉·本斯特·蒙泰罗。统治集团的代表若昂打算延续盖泽尔的事业，逐步实现军队控制下的政权民主化、国家经济自由化并打击共产主义起义者。另一方面，不支持1964年政变的欧拉正在努力实现政权的迅速自由化并建立自由法院，而作为反对派巴西民主运动的代表，他要在反对派的立场上发言：他要求恢复民主、言论自由、社会保障和工会运动的合法化。尽管被盖泽尔的阴谋诡计妨碍着，反对派仍有机会从选举团中赢得足够的选票。"
const TXT_OPT0 := "若昂·菲格雷多，国家革新联盟（右翼独裁主义）"
const TXT_OPT1 := "欧拉·本特斯·蒙泰罗，巴西民主运动（温和主义）"
const TXT_OPT2 := "保持距离"
const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_R7 := "赢得选举之后，若昂承诺“伸出和解之手”，发誓要让“这个国家成为民主国家”。在来自反对派巴西民主运动所组织的大规模工会罢工的压力下，他做的第一件事就是宣布对政治家进行广泛的、全面无限制的大赦，允许那些被军政府流放的人回到巴西。此后不久，他发起了选举改革，结束了两党制，形成了四个反对执政党的政党。同时立法禁止政党联盟并要求“平等投票”（一个选民只能投票给一个政党的候选人）。作为总统，他还在联合国大会上发表讲话，批评发达国家的高利率，还推出了农业刺激计划。虽然因为巴西农业现代化的激励措施许多小农已经破产，但农业确实实现了现代化。"
const TXT_R5 := "\"为了在议会中形成政治多数，巴西民主运动和欧拉本人不得不与国家革新联盟中的温和派进行谈判。其结果是改革方案被阻断并大幅缩减，特别是社会支出的部分内容，最低工资、养老金和救济金的增加都被取消。最后的改革方案被称为捍卫国家宣言，剧作家和作家阿里亚诺·苏阿苏纳负责包括废除审查制度，有关国家艺术和创新的资助，发展以及自由的法案、律师和历史学家巴尔博萨参与了撰写、利马·索布里尼奥提出了为了保护国家安全条款，禁止国有公司私有化和禁止领导人员连任、还有社会学家和政治家费尔南多·恩里克·卡尔多苏为打击政治极端化和激进分子的项目以及一个教授群众政治知识以使他们不受激进分子影响的公司进行游说。同时作为一种妥协，所有被流放的巴西人和所有没有参与暴力的人都得到了大赦。这样就通过了对政治反对派的赦免，最终导致了两党政权的彻底垮台。但改革方案还包括一项法案，为旧政府的所有人、参与者和拥护者，特别是国家革新联盟的成员提供豁免权，保证禁止对1964年政变以来发生的任何事进行谴责或起诉。\""

func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _proprc_suffix(c: CountryData) -> String:
	return TXT_PROPRC_YES if c.has_tag("亲中") else TXT_PROPRC_NO

func _get_winner_in_america(country: CountryData, ideo: Array, sup: Array, coef: float, party: int) -> int:
	if country == null:
		return -1
	var sg := country.sub_government
	if sg >= 0 and sg < 10 and ideo[sg]:
		sup[sg] -= float(country.level_of_instability)
		sup[sg] += float(country.level_of_development)
	if sg - 1 >= 0 and sg - 1 < 10 and ideo[sg - 1]:
		sup[sg - 1] -= float(country.level_of_instability) / 4.0
		sup[sg - 1] += float(country.level_of_development) / 2.0
	if sg + 1 <= 9 and sg + 1 < 10 and ideo[sg + 1]:
		sup[sg + 1] -= float(country.level_of_instability) / 4.0
		sup[sg + 1] += float(country.level_of_development) / 2.0
	if not ideo[sg]:
		if sg >= 1 and sg <= 3:
			if ideo[1]:
				sup[1] -= float(country.level_of_instability) / 4.0
				sup[1] += float(country.level_of_development) / 2.0
			elif ideo[2]:
				sup[2] -= float(country.level_of_instability) / 4.0
				sup[2] += float(country.level_of_development) / 2.0
			elif ideo[3]:
				sup[3] -= float(country.level_of_instability) / 4.0
				sup[3] += float(country.level_of_development) / 2.0
		elif sg >= 4 and sg <= 6:
			if ideo[4]:
				sup[4] -= float(country.level_of_instability) / 4.0
				sup[4] += float(country.level_of_development) / 2.0
			elif ideo[5]:
				sup[5] -= float(country.level_of_instability) / 4.0
				sup[5] += float(country.level_of_development) / 2.0
			elif ideo[6]:
				sup[6] -= float(country.level_of_instability) / 4.0
				sup[6] += float(country.level_of_development) / 2.0
	if sg <= 3:
		if 9 - sg >= 0 and 9 - sg < 10 and ideo[9 - sg]:
			sup[9 - sg] += float(country.level_of_instability)
			sup[9 - sg] -= float(country.level_of_development)
		elif ideo[5]:
			sup[5] += float(country.level_of_instability)
			sup[5] -= float(country.level_of_development)
		elif ideo[4]:
			sup[4] -= float(country.level_of_instability) / 2.0
			sup[4] += float(country.level_of_development) / 2.0
		if 8 - sg >= 0 and 8 - sg < 10 and ideo[8 - sg]:
			sup[8 - sg] += float(country.level_of_instability) / 2.0
			sup[8 - sg] -= float(country.level_of_development) / 4.0
		if 10 - sg <= 9 and 10 - sg >= 0 and ideo[sg]:
			sup[10 - sg] += float(country.level_of_instability) / 2.0
			sup[10 - sg] -= float(country.level_of_development) / 4.0
	elif sg >= 6:
		if 9 - sg >= 0 and 9 - sg < 10 and ideo[9 - sg]:
			sup[9 - sg] += float(country.level_of_instability)
			sup[9 - sg] -= float(country.level_of_development)
		elif ideo[4]:
			sup[4] += float(country.level_of_instability)
			sup[4] -= float(country.level_of_development)
		elif ideo[5]:
			sup[5] -= float(country.level_of_instability) / 2.0
			sup[5] += float(country.level_of_development) / 2.0
		if 8 - sg >= 0 and 8 - sg < 10 and ideo[8 - sg]:
			sup[8 - sg] += float(country.level_of_instability) / 2.0
			sup[8 - sg] -= float(country.level_of_development) / 4.0
		if 10 - sg <= 9 and 10 - sg >= 0 and ideo[10 - sg]:
			sup[10 - sg] += float(country.level_of_instability) / 2.0
			sup[10 - sg] -= float(country.level_of_development) / 4.0
	elif sg == 4:
		for i in [0, 1, 2, 6, 7, 8, 9]:
			if ideo[i]:
				sup[i] += float(country.level_of_instability) / 2.0
				sup[i] -= float(country.level_of_development) / 4.0
	elif sg == 5:
		for i in [0, 1, 2, 6, 7, 8, 9]:
			if ideo[i]:
				sup[i] += float(country.level_of_instability) / 2.0
				sup[i] -= float(country.level_of_development) / 4.0
	if coef > 0.0:
		coef *= 3.0
		if party >= 0 and party < 10:
			if sup[party] > 1.0:
				sup[party] *= coef
			else:
				sup[party] += coef
	for i in sup.size():
		if i >= 0 and i < 10 and ideo[i]:
			sup[i] += 100.0
	var best := 0
	var best_val := -1e30
	for i in sup.size():
		if sup[i] > best_val:
			best_val = sup[i]
			best = i
	return best


func _make_ideo(active: Array) -> Array:
	var ideo: Array[bool] = []
	ideo.resize(10)
	for i in active:
		if i >= 0 and i < 10:
			ideo[i] = true
	return ideo


func _make_sup() -> Array:
	var sup: Array[float] = []
	sup.resize(10)
	for i in sup.size():
		sup[i] = 0.0
	return sup

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var brazil := ws.get_country_by_legacy_index(73)
	if brazil == null:
		return
	var opt := int(context.get("option_index", -1))
	var ideo := _make_ideo([7, 5])
	var sup := _make_sup()
	var winner := -1
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 7)
			brazil.set_tag("亲中", winner == 7)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 5)
			brazil.set_tag("亲中", winner == 5)
		_:
			winner = _get_winner_in_america(brazil, ideo, sup, 0.0, -1)
			if winner != brazil.sub_government:
				brazil.set_tag("亲中", false)
	brazil.government = 3
	brazil.sub_government = winner
	_leave_alliances(brazil)
	brazil.next_election_year = 1985
	brazil.next_election_month = 1
	brazil.next_election_day = 15
	if winner == 7:
		brazil.level_of_instability -= 15
		context["result_text"] = TXT_R7 + _proprc_suffix(brazil)
	elif winner == 5:
		brazil.level_of_instability -= 5
		brazil.level_of_development += 10
		_add_power(EmpireData.USA, -5)
		context["result_text"] = TXT_R5 + _proprc_suffix(brazil)

