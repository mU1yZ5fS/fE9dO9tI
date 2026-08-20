extends "res://数据脚本/event_script_base.gd"

## 原作 Event140.cs：独裁并非永恒。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 已核对原作本文件无 achievements 调用（2026-08-16）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R7 := "1989年初，斯特罗斯纳总统以维护金融稳定为名关闭了巴拉圭的交易所办公室，而由于全国的交易所都是罗德里格斯的产业，这沉重打击了罗德里格斯并促使他最终决定起事。夜间，罗德里格斯所辖的步兵与装甲部队保卫并进攻了亚松森的主要行政大楼与军事设施。他亲率一个装甲团冲进总统府、保安警卫营房与斯特罗斯纳的府邸。2月3日凌晨5时30分，临时总统安德烈斯·罗德里格斯向全国发表重要讲话：他宣布罢免斯特罗斯纳、承诺进行民主化改革、尊重人权、保护巴拉圭天主教传统；并强调，将实现完全的言论自由、放弃红党（ANR）的执政特权及同天主教会展开合作。罗德里格斯组建的新政府废除了长达30年的戒严状态与私刑，释放了政治囚犯，并逮捕了“黄金四角”的成员和一些酷吏。斯特罗斯纳的死硬效忠者被逐出红党领导层，其旧政府的主要官员因不同时期的腐败与酷刑被追究责任，但同时一些招人厌恶的特务与国安官僚未被清算。许多人认为罗德里格斯想要建立一套属于他的“斯特罗斯纳专制”，这完全是空穴来风。1989年3月1日，巴拉圭就将举行第一次不记名自由选举。"
const TXT_R9 := "1989年初，斯特罗斯纳总统以维护金融稳定为名关闭了巴拉圭的交易所办公室，而由于全国的交易所都是罗德里格斯的产业，这沉重打击了罗德里格斯并促使他最终决定起事。夜间，罗德里格斯所辖的步兵与装甲部队保卫并进攻了亚松森的主要行政大楼与军事设施。他亲率一个装甲团冲进总统府、保安警卫营房与斯特罗斯纳的府邸。2月3日凌晨5时30分，临时总统安德烈斯·罗德里格斯向全国发表重要讲话：他宣布罢免斯特罗斯纳、承诺进行民主化改革、尊重人权、保护巴拉圭天主教传统；并强调，将实现完全的言论自由、放弃红党（ANR）的执政特权及同天主教会展开合作。罗德里格斯组建了一个由其恩师因斯弗兰领导的新政府，废除了长达30年的戒严状态与私刑，释放了政治囚犯，并逮捕了“黄金四角”的成员和一些酷吏。斯特罗斯纳的死硬效忠者被逐出红党领导层，其旧政府的主要官员因不同时期的腐败与酷刑被追究责任，但同时一些招人厌恶的特务与国安官僚未被清算。许多人认为罗德里格斯想要建立一套属于他的“斯特罗斯纳专制”，这并不是空穴来风。新总理因斯弗兰刚一上台便与黑恶组织亲密合作，并力图使后者合法化：以种植药用古柯为幌子合法化毒品交易，黑恶集团摇身一变为享有优惠税收的私人企业，黑恶大亨登堂入室进入红党高层。虽然新政权相比旧政府显得更加民主自由，但巴拉圭却成为了拉美毒品走私的中心，经济落到了合法化的黑恶组织手中，与其说是一个民主政权，不如说是黑手党开办的一个“民主”公司罢了。"
const TXT_R_FALLBACK := "光辉乍现"
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
	var c := ws.get_country_by_legacy_index(79)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([7, 9])
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 3.0, 7)
			c.government = GameConstants.Government.LIBERAL
			if winner == 4:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			c.government = GameConstants.Government.LIBERAL
			if int(ws.completed_event_ids.get("event_138", 0)) == 1:
				winner = _get_winner_in_america(c, allowed, 2.0, 9)
			else:
				winner = _get_winner_in_america(c, allowed, 1.5, 9)
			if winner == 9:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = c.sub_government
	c.sub_government = winner
	_want_to_leave(c)
	_set_next_election(c, 1989, 5, 1)
	if c.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, 5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R7 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		c.level_of_instability -= 30
		c.level_of_development -= 15
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, -15)
		context["result_text"] = TXT_R9 + _friend_suffix(c)
		return
	c.level_of_instability -= 20
	c.level_of_development -= 5
	_add_power(EmpireData.USA, 5)
	context["result_text"] = TXT_R_FALLBACK + _friend_suffix(c)
