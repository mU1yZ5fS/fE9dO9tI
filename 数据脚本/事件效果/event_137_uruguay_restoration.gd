extends "res://数据脚本/event_script_base.gd"

## 原作 Event137.cs：回归民主。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - iron_and_blood 成就已接 Achievements（Set 编号见 execute 内注释）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R4 := "在当时人们眼里，桑吉内蒂是一个在政治上持进步立场的政治家，在经济上则比较保守，他成功地重树了其政党的形象，该党中最保守的势力支持1973年的政变。他立即解除了对积极反抗独裁政权的政党与领导人的活动禁令，并签署了对政治犯的大赦令。在国际关系领域，桑吉内蒂恢复了与西班牙的关系，重建了与共产主义国家的联系，并根据拉丁美洲一体化协会（ALADI）制定的目标，在推动区域经济一体化方面发挥了决定性作用。在经济领域，桑吉内蒂政府最重要的目标之一是削减近5.1亿美元、逼近国内生产总值的外债。政府开始通过满足国际货币基金组织的要求，如减少政府开支、紧缩开支和私有化来偿还债务。工会对此不满，要求退出IMF并拒绝偿还公共债务，但各政党间的开放协议安抚了他们，各政党也以此达成了共识，能够提出符合共同利益的立法。以此共识为基础，1986年4月1日，PC、PN、左翼的广泛阵线（FA）和保守的公民联盟（UC）共同签署了《国家协议》。在他的统治下，“逾期法”也得以通过，那些在乌拉圭军官文官独裁期间犯下反人类罪行的军人最终得到了某种程度的赦免。"
const TXT_R8 := "作为民粹主义的中右翼政党候选人，祖马兰主要致力于在党内达成妥协。该党在一些议题上意见一致，但在其他社会问题上却存在种种分歧。一些政策在妥协协议后出台，然后由新任总统实施。在外交政策方面，乌拉圭采取了反帝国主义的立场，与共产主义国家、西班牙建立了联系，甚至还申请加入不结盟运动。同时，在社会问题上，禁止同性婚姻、禁止非传统性取向的人士领养孩子的规定被法律确认，但同时，堕胎和安乐死也不再视为犯罪，法律成年年龄也调高了，也只有成年人能被起诉。在经济问题上，新领导层直接采取了国家联邦化的路线，国有企业变成了股份制公司，并转交地方政府控制。乌拉圭的联邦化还伴随着经济上的权力下放改革，中央对市场的干预也减轻了（这些权力被转移到了地方当局手中）。与此同时，在祖马兰任期期间，文官政府与军方之间发生了摩擦，军方试图掌握对反人类罪进行追究的权力。最终，为避免再次发生政变，议会谴责了1973年政变，但将调查罪行与判罚的权力转交给了军事法庭，以此安抚军方，而军方只是谴责了一些替罪羊，其他人则恢复了自由身。"
const TXT_R3 := "本职为专科医生的胡安·何塞·克罗托吉尼执政之后，开始背靠他成分复杂的执政联盟展开改革。他的第一项法令便是大规模赦免乌拉圭所有因政治原因受指控的人员，并且恢复他们的政治权利；并且提名著名的左翼人士、退役军官利伯·塞雷尼·莫斯克拉为总理，他此前被军政府囚禁而被禁止参选。在医疗教育领域的国有化的第一项改革未能获得所需票数，未获议会通过，塞雷尼总理称“我不能容忍同其他来历不明的政治势力谈判与勾结”从而提请辞职，广泛阵线（BF）显然对此处境表示不甘。新成立的内阁推出了一套温和改革方案：广泛发展社会保障、大力发展医药技术产业、推广成本低廉的免费高等教育。这些改革大幅降低了乌拉圭的死亡率与疾病率，提升了民众的购买力，创造了一批坚实的技术工人阶层。乌拉圭经济在为期10年的军事独裁后得以枯木逢春。人民生活质量得到改善，GDP与投资吸引力得到提升，随之而来的是通货膨胀率的提升。"
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
	var c := ws.get_country_by_legacy_index(82)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([4, 8, 3])
	var winner := 0
	var r136 := int(ws.completed_event_ids.get("event_136", 0))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			if r136 <= 1:
				winner = _get_winner_in_america(c, allowed, 2.0, 4)
			else:
				winner = _get_winner_in_america(c, allowed, 1.5, 4)
			if winner == 4:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			if r136 <= 1:
				winner = _get_winner_in_america(c, allowed, 2.0, 8)
			else:
				winner = _get_winner_in_america(c, allowed, 1.5, 8)
			if winner == 8:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			if r136 == 1:
				winner = _get_winner_in_america(c, allowed, 2.0, 3)
			else:
				winner = _get_winner_in_america(c, allowed, 1.5, 3)
			if winner == 3:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = 3
	c.sub_government = winner
	_want_to_leave(c)
	_set_next_election(c, 1989, 11, 26)
	if c.sub_government == 4:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, 5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R4 + _friend_suffix(c)
		return
	if c.sub_government == 8:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, -5)
		# 原作 Event137.cs:124：iron_and_blood → achievements.Set(92)
		Achievements.set_achievement(92)
		context["result_text"] = TXT_R8 + _friend_suffix(c)
		return
	if c.sub_government == 3:
		c.level_of_instability -= 5
		c.level_of_development += 10
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		c.set_tag("亲美", false)
		context["result_text"] = TXT_R3 + _friend_suffix(c)
