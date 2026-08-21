extends "res://数据脚本/event_script_base.gd"

## 原作 Event142.cs：选举，选举......。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 已核对原作本文件无 achievements 调用（2026-08-16）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R4 := "基于阿普拉主义的反帝价值观，加西亚制定了疏离于国际市场的经济政策，这削减了秘鲁的国际投资。加西亚还试图将银行业与保险业国有化，并单方面宣布以GDP的10%为最高债务偿还上限，国际货币基金组织与国际金融届感到不安，从而国际金融市场孤立了秘鲁。这使得阿普拉政府被迫为多个国内项目增发货币，引发了恶性通货膨胀。国际的孤立、外资外企的撤出、恶劣的通胀，使得贫困的问题非但没有得到解决，反而愈加严重。同一时期，图帕克·阿马鲁革命运动（MRTA）风生水起。加西亚政府试图以军事手段解决日益猖獗的恐怖主义问题，甚至不惜牺牲人权为代价，但宣告失败。其中包括1985年8月武装部队枪杀47名农民的“阿科马卡大屠杀”；1988年5月造成约30人被杀，数十人失踪的卡亚拉大屠杀；1986年在卢里甘乔、圣胡安巴蒂斯塔和圣芭芭拉监狱暴动期间对逾200名囚犯的处决。一项官方调查称，在加西亚的任期内，约1600名民众因强制原因失踪。"
const TXT_R1 := "在左翼联盟执政之后，他们同阿普拉党合作以赢得议会多数席位，从而组成了单一的左翼政府。巴特兰斯总统的第一项举措是在秘鲁各地分发“奶罐子工程”，即向全国所有贫困人口提供基本必需品。与此同时，宪法改革在巴特兰斯的领导下开始进行，其形式是废除旧资产阶级基层制度，在自愿原则基础上联合所有城市居民与农民，组成居民委员会与合作社，由这些基层组织选举代表参加地区一级的治理委员会，而后者选举代表形成秘鲁国家的一院制国会。这一宪法的修订也标志着秘鲁的联邦化，即赋予地方、基层的管委会、居委会、合作社充分的自治权力。同时，巴特兰斯也将旧“左倾”军政府的一些经济原则予以恢复，但附加更多的国家干预要素：银行、矿业与加工部门收归国有，其余的私营企业被强制股份化，每个工人依法持有最低规模的企业股份，享受企业分红。此外通过进行累进税制的改革，税收极大地补充了财政预算。因此即便受到欧美的联合制裁（烈度逊于古巴），秘鲁也有足够的资金展开大规模改革，甚至普及了免费医疗与免费教育。在新制度之下，社会主义者-共产主义者-阿普拉主义者的执政联盟被空前巩固了，但是联盟内也出现了相互权力斗争的迹象。总而言之，没有人能够给巴特兰斯的总统任期挑出任何毛病，因为他印证了一句常理，那就是诚实之道自古以来便是唯一正确且备受欢迎的那一条。"
const TXT_R6 := "基督教民主党（DK）与人民党（NP）组成选举联盟后，提名了单一候选人路易斯·雷耶斯并赢得了选举。在雷耶斯上台后，他与自由运动结盟赢得了宪法多数，从而开始了广泛的政治改革：媒体和国家广电开始完全私有化，所有审查制度被废除并禁止，外国报刊允许自由印刷发行。持不同政见者、囚犯、难民得到了大规模特赦，政治迫害被法定禁止。然而大多数报刊都被私人企业收购，变得纯粹商业化。在经济领域，由于持有大量公共债务，雷耶斯决定同国际货币基金组织合作，遵守其规定的约束——削减政府开支，将无利可图的国企私有化、降低税收、为外国投资者提供有利政策。新政府虽然克服了通胀与债务问题，但是国民福利未能得到可观提升。"
const TXT_RESULT_NAME := "光辉乍现"
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
	# 原版 ResultsOfEvents 结果页标题复用 new_texts[453]。
	context["result_title"] = TXT_RESULT_NAME
	var c := ws.get_country_by_legacy_index(80)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([4, 1, 6])
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
			winner = _get_winner_in_america(c, allowed, 2.0, 1)
			if winner == 1:
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
	_set_next_election(c, 1990, 4, 8)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT:
		c.level_of_instability -= 20
		c.level_of_development -= 5
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R4 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
		c.level_of_instability += 5
		c.level_of_development += 20
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		context["result_text"] = TXT_R1 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.LIBERAL:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, 5)
		context["result_text"] = TXT_R6 + _friend_suffix(c)
