extends "res://数据脚本/event_script_base.gd"

## 原作 Event147.cs：双头体系。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 已核对原作本文件无 achievements 调用（2026-08-16）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R5 := "路易斯·埃雷拉赢得了总统选举，从民主行动党（AD）人安德烈斯·佩雷斯手中接过了政权，后者在1975年石油产业繁荣时将其国有化。在埃雷拉任期的前几年，石油收入持续增长，埃雷拉采取了统制经济的政府经济观点，包括将公共资金投入农业和工业项目、采取慷慨的政府补贴、对多种商品实施价格限制。埃雷拉以总统的名义实施了多项文化发展工程，包括建立特雷莎·卡雷尼奥文化中心和改革教育体制。埃雷拉政府延续了佩雷斯执政时期的政策，从石油美金泛滥的世界市场高筑外债，到了80年代初，委内瑞拉欠了逾200亿美元的主权债务。政府预期全球油价将永远保持在高位，并使得公共支出与私人消费维持高涨。然而，在埃雷拉任期的末期，全球油价的暴跌与大量的外债迫使政府解除物价管制，这导致了通货膨胀的急剧攀升与经济的严重衰退。"
const TXT_R7 := "在当选总统之后，路易斯·皮涅拉·奥尔达斯提名了一届由前总统卡洛斯·佩雷兹领导的内阁班底。在奥尔达斯任内，石油牌价陡然下跌，而由于委内瑞拉的国民经济建立在石油出口之上，导致该国国际收入意外下降。基于此，政府背弃了奥尔达斯的竞选承诺，以国际货币基金组织的提议为基础，推出了名为“华盛顿共识”的新自由主义改革方案。上述方案，还有诸如提高石油价格等不受欢迎的经济与社会改革，换来了45亿美元的IMF贷款，也招致了民粹主义与反对自由主义的声潮。结果是，仅仅在第二年，首都加拉加斯就爆发了大规模的群众抗议活动，并遭到了奥尔达斯的严厉镇压。再下一年，记者何塞·兰格爆料称总理佩雷兹涉嫌贪腐，而司法部长雷蒙·埃斯科瓦尔·萨洛姆对其挪用国家资金达2.5亿玻利瓦尔的指控印证了这一点。经过调查，最高法院宣判佩雷兹挪用公款证据确凿，并在次日参议院投票剥夺佩雷兹豁免权后将其逮捕。这一事件使得奥尔达斯的支持率陡然下降，并宣布辞职。"
const TXT_R3 := "备受瞩目的记者与节目主持人何塞·兰格得以当选总统，但他的胜利并不是因为左翼政党形成了所谓“选举联盟”，而仅仅是因为所有左翼政党共同认可将他提名为候选人。这就意味着，兰格不得不在议会中组建一个“红蓝内阁”，并容纳持反帝立场的温和左翼政党人民选举运动（MEP）、温和左翼的社会主义运动（MAS）和经济上温和进步但政治上保守的社会基督教党（COPEI）。新政府的重点是进一步实现政治、立法、司法系统的民主化与自由化；加强反垄断，尤其在媒体与广电领域反对私人垄断。然而，随着国际油价突然下跌造成的国内经济危机，松散的执政联盟宣告瓦解：社基党要求同国际货币基金组织合作、实现部分自由化；民选运动和社运则希望转向经互会框架下的国际经济合作银行，向社会主义国家贷款，并且发展拉丁美洲内部的贸易。在这一分裂局面下，一位不起眼的左翼退役军官弗朗西斯科·卡德纳斯从名为玻利瓦尔革命运动200（MBR-200）的秘密军官团中组建了一套内阁班底，被民众称为“第一军”。尽管人人对内阁的过激举动战战兢兢，但军事政变最终没有发生，只是政府展开了为期200天的“非常经济措施”，期间政府亲自接管对外贸易的垄断，有效地促成了国家的外贸平衡与货币稳定。这一临时举措虽然已经事先设定明确的截止时间，但还是多次被自由主义者与保守主义者所诟病。在任期结束后，何塞·兰格宣布他将不再参选总统，因为政治不适合他，所以想解甲归田回到新闻业的老本行。"
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
	var c := ws.get_country_by_legacy_index(83)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([5, 7, 3])
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 5)
			if winner == 5:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 7)
			if winner == 7:
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
	c.government = 3
	_set_next_election(c, 1983, 12, 4)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == 5:
		c.level_of_instability -= 10
		c.level_of_development += 5
		context["result_text"] = TXT_R5 + _friend_suffix(c)
		return
	if c.sub_government == 7:
		c.level_of_instability -= 20
		c.level_of_development -= 5
		_add_power(EmpireData.USA, 5)
		context["result_text"] = TXT_R7 + _friend_suffix(c)
		return
	if c.sub_government == 3:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, 5)
		context["result_text"] = TXT_R3 + _friend_suffix(c)
