extends "res://数据脚本/event_script_base.gd"

## 原作 Event139.cs：民主化转型。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - iron_and_blood 成就已接 Achievements（Set 编号见 execute 内注释）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_OPT2 := "吉列尔莫·瓦尔加斯，国家机遇党（社会民主主义）"
const TXT_OPT2_LEFT := "吉列尔莫·瓦尔加斯，国家机遇党（民主社会主义）"
const TXT_R7 := "在安德烈斯·罗德里格斯担任总统期间，他任命胡安·卡洛斯·瓦斯莫西为巴拉圭的民族融合部部长，并在选举中支持瓦斯莫西作为自己的总统接班人。在巴拉圭史上第一次自由选举中，当选人对败者以不到10%的优势赢得选举——红党（ANR）的瓦斯莫西以41.6%比33.5%的得票率战胜对手，真正激进自由党（PLRA）的多明戈·莱诺。尽管投票过程中发现了一些违反规定的行为，但这被认为是微不足道的，并没有引起吉米·卡特率领的国际选举观察团的异议。然而，当瓦斯莫西开始让长期支持斯特罗斯纳的人物重新进入政府时，他的政治声望降到了冰点。同时，罗德里格斯开展的民主化改革并没有在瓦斯莫西手中得到延续，他的任期专注于维持个人权力、增加个人财富与向美国企业开放市场。"
const TXT_R6 := "作为真正激进自由党（PLRA）的领导人和激进派，多明戈·莱诺从阿尔弗雷多·斯特罗斯纳独裁统治建立的那一天起便开始抗争，并多次遭到迫害、逮捕，监禁，多年来流亡海外。直到这次选举，在大量支持者的压力下，他才被当局允许回国。在流亡期间，他因捍卫人权与民主获得多项国际奖项，并凭借威望成功当选总统。在其任期内，莱诺开始了大规模的政治自由化，营造了前所未有的媒体自由与党派活动自由，使巴拉圭成为拉美第一个真正的民主国家。在实现国家民主化与政治完全透明之后，莱诺开始着手对斯特罗斯纳统治时期内，巴拉圭组织和参与迫害和侵犯人权的军官和文官展开清算与审判。这引发了巴拉圭军官利诺·奥维耶多发动政变，以违宪与滥用职权为名逮捕并将莱诺驱逐出境。在随后的大规模集会与示威游行中，奥维耶多宣布将权力移交给真正激进自由党的温和派代表朱利叶斯·凯撒·佛朗哥。新一届政府任命奥维耶多出任国防部长，结束对军方的清算，集中精力打击黑恶组织、贩毒集团，并着力发展医药与经济自由化。"
const TXT_R4 := "国家机遇党（PEN）是一个由社会民主主义的二月革命党（PFR）、基督教民主党（PDC）、全民亚松森党与红党的温和左翼民主派所组成的政治联盟。机遇党给自己的运动设立的目标是：“为祖国提供好儿好女，最能干和最诚实的人，那些真正想建立一个基于社会正义和法治的共和国的人”。由于未获得议会多数席位，吉列尔莫·瓦尔加斯决定与真正激进自由党（PLRA）组成执政联盟，从而开始了温和左翼路线的改革：包括扩大言论自由、意见多元、政权、媒体与司法的大规模民主化。涉嫌腐败的官僚、充当黑恶组织帮凶的法官被判处长期监禁；作为妥协，涉嫌侵犯人权的官员仅仅被解职。在经济上，执政联盟致力于扩大平等，引入累进税制、社会福利、公共补贴、免费医疗与免费普及中等教育，从而改善财富、健康与识字率。机遇党还开展了大规模基础建设项目，以创造就业机会和发展经济。同时，针对黑恶组织与贩毒集团的斗争正积极展开，吸引外资的政策正广泛出台。"
const TXT_R3 := "国家机遇党（PEN）是一个由共产主义者与卡斯特罗运动（从前被取缔）、社会民主主义的二月革命党（PFR）、基督教民主党（PDC）、全民亚松森党与红党的温和左翼民主派所组成的政治联盟。在中国政府的资助下，该党在基督教社会主义解放神学的旗帜下团结了起来，从而获得了人民一致拥护，其候选人吉列尔莫·瓦尔加斯也得以成功担任总统。巴拉圭军队领导人，利诺·奥维耶多将军因此发动了一场政变，将瓦尔加斯抓捕，并被关在一个封闭的别墅中，贫民掀起了大规模的抗议并对军队发起了攻击。十余万人聚集在利诺·奥维耶多的住所周围，政变领导人不得不释放总统，辞职并逃离巴拉圭。在胜利地重掌权力后，瓦尔加斯决定以共谋反人类罪取缔红党，开始大规模逮捕斯特罗斯纳独裁政权的参与者，并对国家机器、执法机关与司法机构进行大规模清洗。在此之后，国家机遇党宣布举行临时选举，并在选举中获得了大多数选票，广泛的社会改革就此开始：重要经济领域被国有化、免费住房制度得以建立、广泛的社会保障，免费的医疗以及中等与高等教育也逐步铺开。此后，该国开始实施建设社会主义市场经济体制并全面建成小康社会的计划。"
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
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var left := d.size() > W.I_ECON_SYSTEM and d[W.I_IDEOLOGY] <= 3 and d[W.I_ECON_SYSTEM] <= 12 and d[W.I_INFLUENCE] >= 150
	if left:
		_enable(event_def.options[2], TXT_OPT2_LEFT)
	else:
		_enable(event_def.options[2], TXT_OPT2)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(79)
	if c == null:
		return
	var left := _d(W.I_IDEOLOGY) <= 3 and _d(W.I_ECON_SYSTEM) <= 12 and _d(W.I_INFLUENCE) >= 150
	var third_party := 3
	if not left:
		third_party = 4
	var allowed := _allowed10([7, 6, third_party])
	var opt := int(context.get("option_index", -1))
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 7)
			if winner == 7:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 6)
			if winner == 6:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			if left:
				winner = _get_winner_in_america(c, allowed, 2.0, 3)
			else:
				winner = _get_winner_in_america(c, allowed, 2.0, 4)
			if winner == 3 or winner == 4:
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
	if c.sub_government == 7:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, 5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R7 + _friend_suffix(c)
		return
	if c.sub_government == 6:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R6 + _friend_suffix(c)
		return
	if c.sub_government == 4:
		c.level_of_instability -= 5
		c.level_of_development += 10
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, 5)
		c.set_tag("亲美", false)
		context["result_text"] = TXT_R4 + _friend_suffix(c)
		return
	if c.sub_government == 3:
		c.level_of_instability -= 5
		c.level_of_development += 10
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		_add_relation(EmpireData.USA, -25)
		c.set_tag("亲美", false)
		# 原作 Event139.cs:145：iron_and_blood → achievements.Set(93)
		Achievements.set_achievement(93)
		context["result_text"] = TXT_R3 + _friend_suffix(c)
