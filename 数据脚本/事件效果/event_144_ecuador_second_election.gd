extends "res://数据脚本/event_script_base.gd"

## 原作 Event144.cs：二次选举。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - iron_and_blood 成就已接 Achievements（Set 编号见 execute 内注释）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R7 := "莱昂·费夫雷斯-科尔德罗·里瓦德内拉就任总统后，寻求推行以自由市场关系为基础的政策，然而，基督教社会党（PSC）在国民议会中的席位并不足以推动这一政策。故而，里瓦德内拉采取了极其强硬的手段：他发布“经济紧急法令”以控制公共开支与企业，并通过法令大幅削减公共开支、精简国家机器、重组（事实上是减少）国有企业规模与份额、为外资企业为主的企业提供成长的有利环境。在里瓦德内拉执政期间，厄瓜多尔还修建了高速公路与最大的体育场馆，央行将每年5%的预算用于文化项目，卫生部实施了一项名为“美格兰”的计划，向五岁以下儿童推广医疗保健与免费分发药物。后来，美洲人权法庭指控称，在里瓦德内拉统治期间发生了严重的人权侵害事件，军政府时期反对派强制失踪的事件在其任期内屡次重演。据称，为了打击社会主义、共产主义叛军与原住民运动，里瓦德内拉批准成立了“处决小队”，在未经调查审判的情况下大规模处决被捕者。"
const TXT_R4 := "罗德里戈·博尔哈·塞瓦略斯的政府致力于恢复民主与自由的价值观。他废除了作为酷刑执刑所而设立的刑事调查局（CIS），取而代之的是犯罪调查部，旨在专门处理反社会行为并保障公共安全。博尔哈承认原住民人民联盟（CONAIE）的合法地位，并致力于扩大他们的合法权益。同时，新总统也制定了一项国家社会改造计划，旨在完善监狱设施以克服刑事人员的身心不健康状况。政府捣毁了洛斯·雷耶斯·马格斯的贩毒集团，并建立了打击拉美毒品反对的国际合作机制。另一面，博尔哈也成功镇压工会运动，驱散集会并逮捕激进的工会领导人塔基。博尔哈对公共开支与货币发行作了严格控制，财政支出转而用于发展国内消费与出口粮食生产部门，工业渔船队也就此重建。然而，厄瓜多尔的通货膨胀率在博尔哈任期内急剧攀升，解决这一问题只能相信后人的智慧了。"
const TXT_R3 := "安赫尔·杜阿尔特凭借精湛的演说技巧游走政坛，他和他的人民力量集中党（CFP）成功地联合了左翼民主主义的人民团结党（MPD）、厄瓜多尔共产党（PCE）与温和的厄瓜多尔社会党（PSE），从而建立了一个左翼全面联盟的联合人民阵线（UPF）。杜阿尔特刚一上台，便要求国家总检察署逮捕所有过去参与过军政府暴行的分子并对其展开大规模调查。许多执法部门人员辞职或遭到清洗，前军政府高级官员飞离厄瓜多尔，针对他们的国际通缉令发布了。成千上万的工会成员走上街头支持新政府。所有此前被禁止的工会得以恢复，尤其是工人总工会（UGTE）被宣布为“隶属于政府”，拥有接受津贴、参加国家所有会议和经受非机密文件的权限。杜阿尔特的新政策被称为“折衷路线”，依赖扩大社会项目、扩大劳工权利、发展国家工业与基础设施。厄瓜多尔宣布建立“社会主义市场经济”以及“依靠全国劳动群众”。"
const TXT_FRIEND := "新政府决心和我们做朋友。"
const TXT_ENEMY := "新政府不想和我们做朋友。"



func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






func _set_next_election(c: CountryData, year: int, month: int, day: int) -> void:
	if c == null:
		return
	c.next_election_year = year
	c.next_election_month = month
	c.next_election_day = day




func _friend_suffix(c: CountryData) -> String:
	if c != null and c.has_tag("亲中"):
		return TXT_FRIEND
	return TXT_ENEMY


## Country.WantToLeave() 逐行移植。
func _want_to_leave(c: CountryData) -> void:
	if c == null:
		return
	var flag := true
	var sub := c.sub_government
	if sub == 0:
		if _d(W.I_IDEOLOGY) > 2 or _d(W.I_ECON_SYSTEM) >= 13 or _d(W.I_DIPLO) < 700 or _d(W.I_PARTY_SYSTEM) >= 8:
			flag = false
	elif (sub >= 1 and sub <= 3) or sub == 8 or sub == 17:
		if _d(W.I_IDEOLOGY) > 3 or _d(W.I_ECON_SYSTEM) > 13 or _d(W.I_DIPLO) < 500:
			flag = false
	elif sub >= 4 and sub <= 6:
		var china := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) < 2 or _d(W.I_ECON_SYSTEM) < 13 or _d(W.I_DIPLO) > 700 or _d(W.I_PARTY_SYSTEM) < 8 or _d(W.I_PRESS_POLICY) < 18 or (china != null and china.has_tag("ovd")):
			flag = false
	elif sub >= 7:
		var china2 := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) == 1 or _d(W.I_ECON_SYSTEM) <= 11 or _d(W.I_DIPLO) < 300 or (china2 != null and china2.has_tag("sev")):
			flag = false
	if c.has_tag("亲中"):
		c.set_tag("对华贸易", flag)
		c.set_tag("亲中", flag)
		if c.has_tag("亲美"):
			c.set_tag("亲美", not flag)


func _idiv(a: int, b: int) -> int:
	return int(float(a) / float(b))


## GameState.GetWinnerInAmerica 逐行移植（C# int 除法向零截断）。
func _get_winner_in_america(c: CountryData, allowed: Array, coef: float, party: int) -> int:
	if c == null:
		return 0
	var sup: Array = []
	sup.resize(10)
	sup.fill(0.0)
	var sub := c.sub_government
	var unstab := c.level_of_instability
	var dev := c.level_of_development
	if allowed[sub]:
		sup[sub] = sup[sub] - unstab + dev
	if sub - 1 >= 0 and allowed[sub - 1]:
		sup[sub - 1] = sup[sub - 1] - _idiv(unstab, 4) + _idiv(dev, 2)
	if sub + 1 <= 9 and allowed[sub + 1]:
		sup[sub + 1] = sup[sub + 1] - _idiv(unstab, 4) + _idiv(dev, 2)
	if not allowed[sub]:
		if sub >= 1 and sub <= 3:
			if allowed[1]:
				sup[1] = sup[1] - _idiv(unstab, 4) + _idiv(dev, 2)
			elif allowed[2]:
				sup[2] = sup[2] - _idiv(unstab, 4) + _idiv(dev, 2)
			elif allowed[3]:
				sup[3] = sup[3] - _idiv(unstab, 4) + _idiv(dev, 2)
		elif sub >= 4 and sub <= 6:
			if allowed[4]:
				sup[4] = sup[4] - _idiv(unstab, 4) + _idiv(dev, 2)
			elif allowed[5]:
				sup[5] = sup[5] - _idiv(unstab, 4) + _idiv(dev, 2)
			elif allowed[6]:
				sup[6] = sup[6] - _idiv(unstab, 4) + _idiv(dev, 2)
	if sub <= 3:
		if allowed[9 - sub]:
			sup[9 - sub] = sup[9 - sub] + unstab - dev
		elif allowed[5]:
			sup[5] = sup[5] + unstab - dev
		elif allowed[4]:
			sup[4] = sup[4] - _idiv(unstab, 2) + _idiv(dev, 2)
		if 8 - sub >= 0 and allowed[8 - sub]:
			sup[8 - sub] = sup[8 - sub] + _idiv(unstab, 2) - _idiv(dev, 4)
		if 10 - sub <= 9 and allowed[sub]:
			sup[10 - sub] = sup[10 - sub] + _idiv(unstab, 2) - _idiv(dev, 4)
	elif sub >= 6:
		if allowed[9 - sub]:
			sup[9 - sub] = sup[9 - sub] + unstab - dev
		elif allowed[4]:
			sup[4] = sup[4] + unstab - dev
		elif allowed[5]:
			sup[5] = sup[5] - _idiv(unstab, 2) + _idiv(dev, 2)
		if 8 - sub >= 0 and allowed[8 - sub]:
			sup[8 - sub] = sup[8 - sub] + _idiv(unstab, 2) - _idiv(dev, 4)
		if 10 - sub <= 9 and allowed[10 - sub]:
			sup[10 - sub] = sup[10 - sub] + _idiv(unstab, 2) - _idiv(dev, 4)
	elif sub == 4:
		if allowed[0]:
			sup[0] = sup[0] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[1]:
			sup[1] = sup[1] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[2]:
			sup[2] = sup[2] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[6]:
			sup[6] = sup[6] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[7]:
			sup[7] = sup[7] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[8]:
			sup[8] = sup[8] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[9]:
			sup[9] = sup[9] + _idiv(unstab, 2) - _idiv(dev, 4)
	elif sub == 5:
		if allowed[0]:
			sup[0] = sup[0] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[1]:
			sup[1] = sup[1] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[2]:
			sup[2] = sup[2] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[3]:
			sup[6] = sup[6] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[7]:
			sup[7] = sup[7] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[8]:
			sup[8] = sup[8] + _idiv(unstab, 2) - _idiv(dev, 4)
		if allowed[9]:
			sup[9] = sup[9] + _idiv(unstab, 2) - _idiv(dev, 4)
	if coef > 0.0:
		coef *= 3.0
		if sup[party] > 1.0:
			sup[party] = sup[party] * coef
		else:
			sup[party] = sup[party] + coef
	for i in range(10):
		if allowed[i]:
			sup[i] = sup[i] + 100.0
	var best := 0
	var best_val := -1.0e30
	for i in range(10):
		var v := float(sup[i])
		if v > best_val:
			best_val = v
			best = i
	return best


func _allowed10(a: Array) -> Array:
	var arr := [false, false, false, false, false, false, false, false, false, false]
	for i in a:
		arr[int(i)] = true
	return arr

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(76)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([7, 4, 3])
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 3.0, 7)
			if winner == 7:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 4)
			if winner == 4:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 3)
			if winner == 3:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = GameConstants.Government.LIBERAL
	_set_next_election(c, 1988, 1, 31)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, 5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R7 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -5)
		context["result_text"] = TXT_R4 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
		c.level_of_instability -= 5
		c.level_of_development += 10
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		# 原作 Event144.cs:111：iron_and_blood → achievements.Set(95)
		Achievements.set_achievement(95)
		context["result_text"] = TXT_R3 + _friend_suffix(c)
