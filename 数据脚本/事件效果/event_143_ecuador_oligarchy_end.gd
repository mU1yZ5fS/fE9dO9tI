extends "res://数据脚本/event_script_base.gd"

## 原作 Event143.cs：寡头政治的终结。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 已核对原作本文件无 achievements 调用（2026-08-16）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R3 := "根据民意调查，军政府当局预估著名反对人士阿萨德·布卡拉姆的胜选几率较大，因此临时在选举法基础上增添了一项限制性条款，剥夺布拉卡马连同前总统卡洛斯·阿罗塞梅纳和何塞·贝拉斯科·伊瓦拉的竞选资格。基于这一情况，人民力量联盟（CFP）提名海梅·罗尔多斯·阿吉莱拉为总统候选人，并提出了“罗尔多斯做总统，布卡拉姆在幕后”的竞选口号。赢得选举后，罗尔多斯签署法令限制每周工作时间为40小时，并将最低工资提高一倍。他还推动了涉及基础设施发展、社会项目与政府合同的国家发展计划和儿童学校早餐计划。罗尔多斯最重要的贡献是他的国际人权政策。他在安第斯共同体提出了尊重人权原则、普遍正义原则与人权优于不干预原则。新总统的外交政策被概括为“罗尔多斯主义”，即推动拉美统一、尊重人权民主正义与反军政府反独裁。1981年1月，罗尔多斯拒绝参加美国总统里根的就职典礼，因为他对里根支持反人权的拉美政权的行为表示反对。同时，罗尔多斯还加强了厄瓜多尔与尼加拉瓜桑德尔政府及萨尔瓦多反军事独裁武装革命民主阵线的联系。一些分析人士称，正是这些政策导致总统专机“意外”起火。在这场起火事故中，飞机撞上了一块岩石，导致总统及其家人全部遇难。"
const TXT_R5 := "杜兰-巴连的执政以急剧的经济改革为标志：在国际货币基金组织的支持下，厄瓜多尔在电信、电力与烷烃化工等战略部门展开了私有化。根据所谓“华盛顿共识”，杜兰-巴连采取了一系列经济措施，包括削减政府开支、放松管制、国企私有化、贸易自由化、立法保障外资投入、大幅增加共计3.12亿元的世界银行信贷额度。厄瓜多尔迎来了大幅降低通胀、充盈外汇储备与原住民社区改善的希望。杜兰-巴连设立了一笔社区基金，向数百个贫困的小社区分配财政援助；并且设立了环境保护部与原住民事务部。然而，上述这些措施的代价是，厄瓜多尔的外债规模急剧膨胀，达到了164亿美元的规模。在杜兰-巴连的执政末期，一份涉及总统家族成员与政府人员的腐败丑闻名单被曝光；同时副总统阿尔伯特·达伊卡因滥用公共资金被弹劾辞职，这些丑闻都使杜兰-巴连的社会声望大大受损。"
const TXT_R6 := "劳尔·克莱门特·韦尔塔的总统任期在风波不平中宣告开始。其所在政党激进自由党（PLRE）由于对于自由主义及韦尔塔施政主张的分歧而陷入分裂。在这一情况下，劳尔教授试图采取“自由、公正、团结”的妥协方案。在外交方面，韦尔塔试图采取积极的反全球化外交，包括退出国际货币基金组织、维持军事中立与反对大国在拉美设军事基地；在法制方面力图建立透明法治，确保有法可依、法官选举、削弱军方影响、普及公共开支等；在经济政策上建立自由的市场经济，包括非社会服务领域的国有企业完全私有化。这些妥协性的政策虽然取得了一定的成效，但依旧无法阻止激进自由党的最终瓦解。在韦尔塔的执政末期，激进自由党已经明显地分裂为了数派无法妥协的派系：温和自由主义者、民粹主义者、基金自由主义者与社会民主主义者。韦尔塔本人也不得不在1983年同基督教社会党（PSC）的中间派联合组建新政府。"
const TXT_FRIEND := "[color=red]新政府决心和我们做朋友。[/color]"
const TXT_ENEMY := "[color=red]新政府不想和我们做朋友。[/color]"



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
	var allowed := _allowed10([3, 5, 6])
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 3)
			if winner == 3:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 5)
			if winner == 5:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 6)
			if winner == 6:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = GameConstants.Government.LIBERAL
	_set_next_election(c, 1984, 1, 29)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
		c.level_of_instability -= 5
		c.level_of_development += 10
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R3 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.MODERATE:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, 5)
		context["result_text"] = TXT_R5 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.LIBERAL:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R6 + _friend_suffix(c)
