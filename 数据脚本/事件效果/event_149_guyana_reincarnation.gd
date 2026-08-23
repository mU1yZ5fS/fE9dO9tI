extends "res://数据脚本/event_script_base.gd"

## 原作 Event149.cs：转世轮回（圭亚那）。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 已核对原作本文件无 achievements 调用（2026-08-16）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R3 := "1980年12月15日选举结果公布，人民全国大会党（PNC）赢得了77%的民众选票，获得了国民议会43席与地区议会的10席。人民进步党（PPP）与联合力量（TUS）分别仅获得10席与12席。劳动人民先锋党（WPVP）宣称选举结果为事先伪造而拒绝参加选举，这一猜想被英国埃夫伯里勋爵所率的国际观察团所证实。在人大党获胜之后，圭亚那在80年代初期面临的经济危机明显加剧，基础设施严重恶化，生活水平普遍下降。停电拉闸几乎每天发生，河湖水质脏污难闻，大米、糖料食用油与煤油的短缺更是证实了圭亚那的严重衰退。在公开经济凋敝的同时，黑市逐渐泛滥成风。在这一艰难的时期，伯纳姆前往古巴进行了一次喉部手术。在古巴医生的护理下，圭亚那独立后的首位和首要领导人福布斯·伯纳姆突然去世。圭亚那就这样措手不及地从伯纳姆的时代过渡到一个新时期。"
const TXT_R1 := "选举的结果是出人意料的，在下野20余年之后，来自人民进步党（PPP）的切迪·贾根再次当选总统。然而正如风传的一样，人民全国大会党（PNC）通过选举舞弊在国民议会获得了22个席位，在地区议会获得10个席位。而民进党和联合力量仅获得21席与2席。在议会危机即将爆发的关头，福布斯·伯纳姆特担心爆发民众骚乱，加入了人进党的执政联盟。作为妥协的成果，贾根成为了总统，并提名伯纳姆为总理，将内阁大多数部长职位任命给人大党党员。面对经济危机，尤其是农作物歉收与缺乏基础建设支持资金的情况，贾根起初试图向国际货币基金组织借款，但由于后者要求圭亚那实施私有化，贾根放弃了这一决定并转而接受社会主义诸国贷款。圭亚那的政治专制得到软化；开放向社会主义国家进口短缺品；东德、罗马尼亚、古巴的专家应邀来优化发展圭亚那的基础设施与医疗教育；圭亚那的专家也前往莫斯科和北京进修学习。解决圭亚那的社会经济问题有了暂时的可能性，但是经济增长陷入怠缓，而债务早晚需要偿付。"
const TXT_R8 := "在成功同右翼激进主义的解放者党（LP）、温和主义的人民民主运动（PDM）和毛主义的工人人民先锋党达成谈判之后，马塞勒斯·辛格组建了一个囊括左右两方势力的解放与民主先锋队（VLD）赢得选举。然而，然而正如风传的一样，人民全国大会党（PNC）通过选举舞弊在国民议会获得了22个席位，在地区议会获得10个席位。解民党和人民进步党（PPP）分别获得16席与7席。在议会危机即将爆发的关头，福布斯·伯纳姆特担心爆发民众骚乱，加入了解民先锋队的执政联盟。作为妥协的成果，辛格成为了总统，并提名伯纳姆为总理"
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
	var c := ws.get_country_by_legacy_index(77)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([3, 1, 8])
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
			winner = _get_winner_in_america(c, allowed, 2.0, 1)
			if winner == 1:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 8)
			if winner == 8:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = GameConstants.Government.LIBERAL
	_set_next_election(c, 1985, 12, 9)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST:
		c.level_of_instability -= 20
		c.level_of_development -= 5
		_add_power(EmpireData.USSR, 5)
		context["result_text"] = TXT_R3 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, 15)
		context["result_text"] = TXT_R1 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, 15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R8 + _friend_suffix(c)
