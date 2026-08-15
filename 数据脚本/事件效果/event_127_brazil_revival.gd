extends "res://数据脚本/event_script_base.gd"

## 原作 Event127.cs：巴西复兴（5 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_TITLE := "巴西复兴"
const TXT_DESC := "目前，巴西原有的两党局面已经不复存在。民主运动党（PMDB）和国家社会党（PDS）分别在巴民运（MDB）和国家革新联盟（ARENA）的基础上建立起来。在1980至1981年期间，军方极反动派别从事恐怖主义活动，制造了一系列爆炸案与绑架案，并将袭击归咎于左翼激进分子，但这样的嫁祸未能让民众信服（毕竟左翼地下组织早在1974年便消亡殆尽）。在本次1985年大选的数月前，名为“直接行动”的平民运动席卷了全国，要求在大选中实现直接选举，但这一诉求遭到了议会的否决。在这一形势下，在野势力联合起来支持民主运动党候选人坦克雷多·内维斯，他提出了最终实现巴西政治制度与经济体制自由化的方针；相对应的是，议会中的多数党民主社会党则陷入分裂，在保罗·马卢夫与马里奥·安德里亚扎两位候选人的提名上摇摆不定。安德利亚扎在推动基础设施、航运、住宅综合体和环境工程的高质量快速发展上表现出色；而马卢夫是一位相对保守的候选人，他在其职业生涯中主要处于经济与金融岗位，负责在金融与税务系统反对官僚主义、减少基础教育学校普遍存在的歧视、创设市民休闲设施，以及改善脏乱的人居环境。如果马卢夫获胜，则民主化将稳步推进；而如果安德利亚扎当选，工作重心将放在经济上。与此同时，在这样不稳与撕裂的政局中，如果左翼政党能够联合起来组成一个联盟，那么他们也会有可乘之机......"
const TXT_OPT0 := "坦克雷多·内维斯，巴西民主运动党（右翼独裁主义）"
const TXT_OPT1 := "保罗·马卢夫，民主社会党（左倾保守主义）"
const TXT_OPT2 := "马里奥·安德里亚扎，民主社会党（自由主义）"
const TXT_OPT3 := "莱昂内尔·布里佐拉，民主工党-工党-劳工党（民主社会主义）"
const TXT_OPT4 := "保持距离"
const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_R7 := "坦克雷多·内韦斯上任后不久便不幸逝世，并由副总统若泽·萨尔内接任总统，他是前巴民运成员，后来另行组党。在他的改革下，巴西最终宣告重回民主，审查制度得以完全废除，总统直选制得以恢复，新闻界、工会获得了言论自由，制宪会议得以召开。在诸多改革事项中值得一提的是，他以商业基础而非招标的方式出让了上千份公共广播电视的特许权，这标志着广电媒体的所有权来到私人垄断者手中，实现了“私有化”。在外交上，萨尔内重申了独立自主外交政策的理念，与众多拉美国家展开对话，其中也包括在1964年政变后断交的社会主义古巴。此外，萨尔内也从事农业改革、推动环境工程和削减官僚编制。然而他任内的诸项改革都未能阻止他任内猖獗的通货膨胀，这成为其执政期间最危险的危机。"
const TXT_R8 := "由于国家的高度稳定，民主社会党的内部分裂影响被最小化了。因此，当马卢夫而非安德利亚扎被提名为候选人时，党内自由派作出了妥协，而没有退党抗议。总统直选制没有实现，作为向自由派的交换，直接选举在州长一级被引入了。紧接着，保罗着手于经济问题：为了克服通货膨胀、扶植商业发展，政府决定上马大型基础设施与工业项目，并分包给私人企业，以换取利润投资巴西经济。已结束10年的“大工程时代”宣告重启，路桥、学校、医院、发电厂、港口数量大幅增加，教育、医疗与电力产业快速发展。这些改革大大提升了消费人口的购买力，暂时遏止了通货膨胀。与此同时，随着新兴政党与政治运动的越加活跃，巴西的政治面貌日趋向好。尽管民主社会党尽力去维护“1964年革命”的政治遗产，但政治冷漠与两党相护的时代已经宣告落幕。"
const TXT_R6 := "由于党内自由派与温和派威胁退党并与反对党组成选举联盟，保罗·马卢夫宣布退选，而民主社会党最终提名马里奥·安德利亚扎为候选人，这也为马卢夫在民主运动党的反对派中赢得了部分选票，并最终被任命为副总统以巩固党派力量。作为政治改革的一项议程，也是为了使指挥棒不被在野党夺走，新政府引入了州长直接选举与总统直接选举制度，成为首个实施这一制度的政党。这一举措不仅广受欢迎，也使执政党巧妙地避开了召开制宪会议的呼吁，保留了议会多数党的地位。在经济方面，新政府宣布展开“新经济计划”：将所有无利可图的国有企业私有化，并将所获得的的资金投入一项庞大的住房计划与环境工程，从而为所有人提供自住保障房。由于终止了对诸多国有企业的补贴，政府得以进一步大幅削减财政支出，从而有效遏制了威胁巴西经济的通货膨胀。"
const TXT_R3 := "社会的动荡、局势的紧张与对未来的不安最终使右翼政党没能站稳脚跟。尽管三个左翼政党存在分歧，民主工党（PDT）、奉行左翼威权主义，与军方关系暧昧的巴西工党（PTB），以及同工会运动关系密切的劳工党（PT）最终组成了选举联盟并提名了共同候选人。同时，由于民主社会党的分裂，新诞生的中间派决定支持左翼候选人，因为他承诺将维持并深化巴西的民主化与联邦化。左翼联盟在获取执政权后，由于未能得到议会多数党地位，联盟不得不进行建立妥协式的统战联盟：接受中间派的方案以实施政治改革、接受民主社会党的方案实施经济改革。其结果是，总统和州长的直接选举制度被引入、审查制度得以废除，不过，广播电视媒体的私有化没有发生。在经济领域，政府采取了“国有化”改革，即强制收购石油、天然气公司51%的股份以及收回所有包含自然资源的土地财产。由于改革产生的效益，一种被称为“布里佐拉主义”的现象发生了：以贫困、弱势、边缘化人口为执政基本盘、广泛建设社会用住房、通过国家力量以非经济利益目的创造就业岗位、引入由国家买单的面包篮子......这些方案也被后来的委内瑞拉查韦斯政府所采纳。"

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
	var ideo := _make_ideo([7, 8, 6, 3])
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
			winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 8)
			brazil.set_tag("亲中", winner == 8)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 6)
			brazil.set_tag("亲中", winner == 6)
		3:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			if brazil.sub_government == 5:
				winner = _get_winner_in_america(brazil, ideo, sup, 2.0, 3)
			else:
				winner = _get_winner_in_america(brazil, ideo, sup, 1.5, 3)
			brazil.set_tag("亲中", winner == 3)
		_:
			winner = _get_winner_in_america(brazil, ideo, sup, 0.0, -1)
			if winner != brazil.sub_government:
				brazil.set_tag("亲中", false)
	brazil.government = 3
	brazil.sub_government = winner
	_leave_alliances(brazil)
	brazil.next_election_year = 1989
	brazil.next_election_month = 11
	brazil.next_election_day = 15
	if winner == 7:
		brazil.level_of_instability -= 15
		context["result_text"] = TXT_R7 + _proprc_suffix(brazil)
	elif winner == 8:
		brazil.level_of_development += 15
		_add_power(EmpireData.USA, -5)
		context["result_text"] = TXT_R8 + _proprc_suffix(brazil)
	elif winner == 6:
		brazil.level_of_instability -= 10
		brazil.level_of_development += 5
		context["result_text"] = TXT_R6 + _proprc_suffix(brazil)
	elif winner == 3:
		brazil.level_of_instability -= 5
		brazil.level_of_development += 10
		_add_power(EmpireData.USA, -25)
		var argentina := ws.get_country_by_legacy_index(71)
		if argentina != null:
			argentina.set_tag("亲美", false)
		context["result_text"] = TXT_R3 + _proprc_suffix(brazil)

