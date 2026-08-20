extends "res://数据脚本/event_script_base.gd"

## 原作 Event148.cs：重蹈覆辙。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - iron_and_blood 成就已接 Achievements（Set 编号见 execute 内注释）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_OPT2_DIS := "玻利瓦尔革命运动-200尚未转入公开活动"
const TXT_R4 := "凭借“我们要紧缩和社会责任”的口号，海梅·卢辛奇成功当选委内瑞拉总统。他的第一项举措便是设立国家改革总领导小组（COPRE）。他提议将总统任命地区长官改为州长不记名直接普选，并创设市政长官，来推动地区层面与政府层面的民主化。卢辛奇的经济政策目标在于稳定经济、清偿外债与减少政府开支，因此他立即在国内推行紧缩政策，但这导致主权货币进一步贬值、通货膨胀加剧和人口贫困，政治危机也随之恶化。在这之后，卢辛奇颁布了一系列关于提高工资、控制物价、增发货币与发行背对背债券用于补贴的法令，这些举措是为了应对其任期内不断升级的社会紧张局势。与此同时，在卢辛奇的治下，一些公立医院与包括共331615幢房屋的住房综合体得到建成，两座水力发电站得到建设，总长372公里的东部高速公路得到开工。因此，卢辛奇的政策是饱受争议的，因为他并没有真正将深陷于石油出口依赖的委内瑞拉经济拯救出来，然而这也并不妨碍他称为委内瑞拉历史上最受欢迎的总统之一。"
const TXT_R8 := "在赢得了从共产主义政党到中右翼政党的支持之后，拉斐尔·卡尔德拉以维护主权、对抗帝国主义者、实施全面的社会改革等民粹主义承诺赢得了总统选举。在卡尔德拉60年代的上一个任期内，他领导委内瑞拉同社会主义国家建立了关系、进行广泛的政治特赦、开始发展经济中的石油产业部门，创造了委内瑞拉发达的经济与稳定的政局。而在石油危机的背景下，再次上台的卡尔德拉深感于委内瑞拉经济对石油出口的过度依赖，宣布了旨在恢复稳定、降低通货膨胀的“委内瑞拉议程”。首先，基于国家干预经济的国情，卡尔德拉通过社会改革、教育医疗住房项目和提高工资，设法稳定了国家的社会政治局势。然后，由于急需国际货币基金组织的贷款，卡尔德拉不得不违背自己的理念在经济领域实施了一系列新自由主义政策，诸如价格自由化、国有资产私有化和玻利瓦尔贬值。这些政策得到了国际货币基金组织的赞许，但是引发了民众的强烈抗议。几年过去，国内生产总值保持了5%以上的增长，通货膨胀率下降了将近一半。在这期间，工会、民营企业与政府经过十年的协商，终于达成了劳动福利、社会保障和养老金的三方协议。总的来说，上述这些颇具争议的措施虽然损害了卡尔德拉的个人形象，但切切实实拯救了委内瑞拉的经济。"
const TXT_R1 := "西蒙·玻利瓦尔大爱国极点（GPPSB）是一个由数个左翼政党组成的运动性组织，受退役军官弗朗西斯科·卡德纳斯的领导。在执政后，卡德纳斯开始进行广泛的社会经济改革：石油工业国有化、扩大工人与工会权利、实施广泛的社会项目。这导致了美国实施禁运制裁、贸易伙伴转向中立国与社会主义阵营，国内的反对声浪逐渐增长。这一剧变吓坏了高层将领与实业家们，他们发动了一场政变将卡德纳斯囚禁在某地，并推举了由重要企业家佩德罗·卡莫纳·埃斯唐领导的临时政府。这引起了效忠于内政部长乌戈·查韦斯的军官士兵的愤怒。在军队内部玻利瓦尔革命运动-200（MBR-200）势力的帮助下，查韦斯得以将大批部队派往加拉加斯市中心，对临时政府展开了一场反政变，逮捕了高层将领并提拔一批中层校官。解救卡德纳斯后，查韦斯以“健康原因”拒绝前者回到总统职位；宣布通过新宪法以保护“玻利瓦尔革命的果实”，批准国家垄断对原材料的开采、销售、外售并掌控社会领域；将GPPSB改组为委内瑞拉统一社会党（PSUV）。统社党在全民公投中赢得78.1%的支持率后，一党专政宣布在委内瑞拉确定下来，同时民众有权罢免由自己选出的代表、州长甚至总统，并就特定问题发起全民公投，从而实现了“党权与民权的平衡”。政府还宣布了一项新的经济政策，虽然混合了拉丁美洲一体化的理念，但这份政策总是让人回想起苏联的新经济政策。"
const TXT_FRIEND := "新政府决心和我们做朋友。"
const TXT_ENEMY := "新政府不想和我们做朋友。"



func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
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

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var c := world.get_country_by_legacy_index(83)
	var opt := event_def.options
	if c != null and c.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(83)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([4, 8])
	if c.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
		allowed[1] = true
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 4)
			if winner == 4:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 8)
			if winner == 8:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 1)
			if winner == 1:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = GameConstants.Government.LIBERAL
	_set_next_election(c, 1988, 12, 4)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, 5)
		context["result_text"] = TXT_R4 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, 5)
		_add_power(EmpireData.USSR, 5)
		context["result_text"] = TXT_R8 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		c.government = GameConstants.Government.REFORMIST
		# 原作 Event148.cs:123：iron_and_blood → achievements.Set(98)
		Achievements.set_achievement(98)
		context["result_text"] = TXT_R1 + _friend_suffix(c)
