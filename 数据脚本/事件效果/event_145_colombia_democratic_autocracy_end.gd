extends "res://数据脚本/event_script_base.gd"

## 原作 Event145.cs：民主专制的终结。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 已核对原作本文件无 achievements 调用（2026-08-16）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_R7 := "在图尔瓦伊·阿亚拉的统治下，游击队在哥伦比亚各地的恐怖活动愈加频繁。对此，图尔瓦伊决定建立极右翼准军事组织“处决小队”，赋予其不仅审判调查执行处决的权力；并通过一项法律扩大军队打击叛乱分子的权力，允许军队拘留并折磨无辜的人直到他们承认有罪，这导致许多政治活动人士被反对团体除名。在经济方面，图尔瓦伊政府强调生产、安全与就业，重点关注基础设施建设与电力部门发展。这些经济政策没有取得成效：主要出口品的咖啡价格下跌，通货膨胀、外债攀升，就业仅仅在地下行业才有所增长。在图尔瓦伊统治期间，毒品交易也出现了新的形式，对社会的危害越发明显。在图尔瓦伊上任的前一年，麦德林市的各个毒枭联合起来成立了麦德林贩毒集团。图尔瓦伊上台后对此不闻不问，导致可卡因贩运激增、腐败与政治贿赂四处蔓延。在外交上，哥伦比亚也转向右倾，作出驯顺于美国的盟友姿态。"
const TXT_R6 := "在贝坦库尔的总统任期内，他开始建造经济适用房、开办大学、推广扫盲运动。在贝坦库尔的努力下，政府同许多武装叛军展开谈判，并达成了为期一年的停火协议，成立一个混合委员会以讨论政治和解与解除武装的议程，一些叛军由此走上了合法活动与议会斗争的道路。贝坦库尔政府还为哥伦比亚的民主化与发展作出了贡献：在任内，他通过了市长选举法、市政司法改革法案、免费电视服务章程与国家假日法；开始对煤炭资源的勘探与出口以提振经济；成功开展反毒品贸易运动并反对大毒枭渗透国家政治体系。贝坦库尔任期的另一个特点是哥伦比亚行政权力与财政权力的下沉：市级政府在税收使用上取得了广泛的自主权；同时市长直选制被引入，取代了此前的市长由省长任命制。"
const TXT_R4 := "亲苏联的哥伦比亚共产党（CPC）、毛派的独立革命劳工运动（MOIR）、温和左翼的哥伦比亚广泛运动（MAC）左翼民族主义的全国人民联盟（ANAPO）、基督教人文主义的基督教民主党（CDP）以及社会民主主义的坚实党（F）组成了一个联合政府。这个成分复杂的政治联盟只有一个目标——那就是进行大规模的政治体制民主化，并同两党专制的残余势力做斗争。新政府在头几年通过了一系列有关议会选举民主化和市政选举民主化的法律：在议会制度上，政党竞选资金由国家划拨、提高选举过程与结果的透明度、邀请国际观察团、设立无党派委员会；在地方制度上，地区管理人不由上级任命，而由辖区居民选举。新政府还展开大规模的广泛特赦、通过保障媒体自由、打击信息领垄断的法律、调查并审判涉嫌侵犯人权的自由党与保守党领导人。新政府的主要成就是，同国内的两大游击队组织：受古巴控制的左翼游击队哥伦比亚革命武装力量（FRAC）和寻求建立民主社会主义的玻利瓦尔运动组织4月19日运动（M-19）达成了和平协议。作为解除武装与去暴力化的条件，FRAC与M-19的成员获得了一些政府岗位，并获准以4月19日民主联盟（AD）的政党形式破格注册。然而，在完成了政治改革后，联合政府面临着无法在社会改革与经济改革中形成共识的问题，故而宣告瓦解。而全民联盟、基民党与保守党组成了新政府，在维持经济体制现状的同时，开始了温和的社会改革。"
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
	var c := ws.get_country_by_legacy_index(75)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([7, 6, 4])
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
			winner = _get_winner_in_america(c, allowed, 2.0, 4)
			if winner == 4:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = GameConstants.Government.LIBERAL
	_set_next_election(c, 1982, 5, 30)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		c.level_of_instability -= 15
		_add_power(EmpireData.USA, 15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R7 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.LIBERAL:
		c.level_of_instability -= 10
		c.level_of_development += 5
		context["result_text"] = TXT_R6 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		context["result_text"] = TXT_R4 + _friend_suffix(c)
