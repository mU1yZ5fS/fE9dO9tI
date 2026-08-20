extends "res://数据脚本/event_script_base.gd"

## 原作 Event151.cs：新生的国家。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - iron_and_blood 成就已接 Achievements（Set 编号见 execute 内注释）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R1 := "九月，陈亚先起草了一份宪法修正案，使国民军置于政府监督范围之内。作为回应，军方成立了人民革命阵线（PRF），这是一个由鲍特瑟、军委会的两名军官、三名学联及工会领导人领导的政治联盟，随后陈亚先被解职并驱逐出境。在执政的前期，鲍特瑟申明了他的反帝倾向，宣布苏里南革命进程同格林纳达革命是相近的，与格林纳达领导人莫里斯·毕晓普建立私交，并多次会见菲德尔·卡斯特罗。鲍特瑟推行彻底的工业国有化政策，并对政治异见者实施打压。在荷兰宣布对苏里南执行制裁，取消镇压极左、中、右翼反对派反对派的补贴后，鲍特瑟称，“我们不在乎，你们的补贴不到我们预算的20分之一”。苏里南同荷兰的关系急剧恶化，但与古巴、尼加拉瓜、圭亚那、委内瑞拉建立了更密切的关系。但是，在美国入侵格林纳达后，鲍特瑟停止了同社会主义阵营的合作与同西方世界的对抗，走上了和荷兰修复关系的道路，并坚持“游走在社会主义世界与资本主义世界之间”的政策。"
const TXT_R8 := "九月，陈亚先起草了一份宪法修正案，使国民军置于政府监督范围之内。作为回应，军方成立了人民革命阵线（PRF）以扳倒陈亚先。陈亚先通过向其他军官团成员承诺保证执政的左倾，并且军方在修宪后将保留一定的影响力与豁免权，从而获得了军方的支持。同时陈也得到了前总统的背书：约翰·费里埃主持了拥护陈亚先、反对鲍特瑟的集会。陈亚先召集了民族主义共和党的温和派成员以及军官团中的支持者，成立了苏里南工人党（WPS），并将“主权主义、劳动主义、守护1980年人民革命成果”作为意识形态。新宪法的通过标志着国家权力正式移交给民选文官政府和议会。一切军官政治组织被勒令解散，同时军队保留在国家危机时期解职总统、解散议会、举行提前选举的权力。根据宪法，只有不威胁当局的政党才获准参加第一次大选，与此同时，多党制与新闻自由得到恢复，对工会的压制得到取消，独立工会组织得以恢复。苏里南宣称自己是一个“合作共和国”，走的是建设“人民合作经济”的道路。"
const TXT_R9 := "苏伦德拉·兰博库斯并没有参加1980年的那场政变，但起先，他对于这些士官团的事业是抱有好感的。但随着时间的推移，兰博库斯对现政权的反感越发强烈，他认为权力的中心没有位置留给军人，新政权正陷入同旧政权一样的腐败泥沼。1982年3月10日至11日夜，兰博库斯从监狱解救了威尔弗雷德·霍克少校，后者在两年前曾率右翼军官发动了一次反鲍特瑟的政变尝试。二人控制了首都帕拉马里博的梅莫里博克军营，并和其他的盲动主义者自称为民族解放委员会（FNL）。他们计划在坦克的掩护下攻击关押政治犯的泽兰迪亚堡和鲍特瑟的总部，并成功逮捕了军官组织的所有成员，打死鲍特瑟。巴尔·乌姆劳辛教授被拥立为新总统，权力被集中在了解放委员会手中。新政府构想了一个不分宗教与民族、团结社会各阶层的有机国家方案。政府进行了大规模私有化、继续迫害独立工会组织与自有媒体的政策；并启动了发展基础设施、航运、医疗教育的大型国家工程。基于完全平等的原则，新宪法设立了一个由国家工会和企业协会的代表选举产生的上议院。反对者批判这一政权为“新法西斯主义”，而当局则成立了“民主与发展阵线”，并标榜自己为“有苏里南特色、倡导平等与人民团结的劳动主义”。至此，这个由基督教民主主义者、自由保守主义者、第三道路民粹主义者所组成的政治联盟宣告掌权。"
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

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(81)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([1, 8, 9])
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 4.0, 1)
			if winner == 1:
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
			winner = _get_winner_in_america(c, allowed, 4.0, 9)
			if winner == 9:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = GameConstants.Government.AUTHORITARIAN
	_set_next_election(c, 2222, 2, 22)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
		c.level_of_instability -= 15
		_add_power(EmpireData.USSR, 5)
		_add_power(EmpireData.USA, 5)
		context["result_text"] = TXT_R1 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, 5)
		# 原作 Event151.cs:103：iron_and_blood → achievements.Set(101)
		Achievements.set_achievement(101)
		context["result_text"] = TXT_R8 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, 15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R9 + _friend_suffix(c)
