extends "res://数据脚本/event_script_base.gd"

## 原作 Event138.cs：永远的总统。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 原版 iron_and_blood 成就 achievements.Set 未建模，跳过并注释；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_TITLE := "永远的总统"
const TXT_DESC := "1954年，阿尔弗雷多·斯特罗斯纳通过军事政变在巴拉圭建立独裁军政府。在军政府初期，一切反对派都被禁止，左派、工会主义者、政治活动家被大规模镇压，一个强硬的反共政权被建立起来；同时在经济模式上倾向于采取法团主义方法。十年之后，斯特罗斯纳进行了一场政治软自由化运动，同他的支持者组建了名为“黄金四角”的团体，建立了以他为首的文官政权，同时容忍没有执政野心的温和反对派存在。与此同时的是，镇压愈发升级，国家机器开始与黑恶组织结合，形成卡特尔经济。到1978年，人口贫困加剧，与黑恶组织密切相关的垄断集团形成，只有执政党全国共和联盟－红党（ANR）的党员才能以权谋私来多多少少改善生活。至此，红党领导层和部分军方人士认为，反共招牌已经打不下去，斯特罗斯纳的位子已经坐得太久了。在1978年选举前夕，斯特罗斯纳召集红党领导层和军方高级将领开会，提出是否应该下野。大多数与会成员表示坚决反对，但是“名誉总统”是否真的批准斯特罗斯纳辞职；以及斯特罗斯纳的亲信，陆军军团司令安德烈斯·罗德里格斯是否被提名为国家元首，这些意见已经开始发酵。如果我们能够利用军方、平民以及“黄金四角”的矛盾，事态或将有所发展。"
const TXT_OPT0 := "试着利用矛盾逼斯特罗斯纳下台（右翼独裁主义）"
const TXT_OPT1 := "同地下组织接触并达成非法交易（原法西斯主义）"
const TXT_OPT2 := "保持距离"
const TXT_R0 := "厄瓜多尔民众、军方、天主教会甚至教皇本人，都呼吁和劝说斯特罗斯纳体面下野。作为下野的条件，斯特罗斯纳被授予名誉终身总统、参议员终身席位、丰厚的退休金、夏季别墅及儿子在政府部门任职。在1978年没有悬念的选举后，红党（ANR）的安德烈斯·罗德里格斯·佩多蒂宣布就职，并同美国大使馆、梵蒂冈秘密合作，开始逐步的民主化改革：进一步从宽的媒体自由化、由警察监督的记名投票过渡到不记名投票，以及特赦一些政治活动家。然而，新政府的最主要任务还是对抗“黄金四角”的势力：内政部长萨比诺·蒙塔纳罗、司法劳工部长尤吉尼奥·雅格、卫生部长阿丹·戈多伊和总统私人秘书老马里奥·阿夫多·贝尼特斯。首先，雅格被解职，为安抚斯特罗斯纳的情绪，由他的儿子古斯塔沃·斯特罗斯纳接任司法与劳工部长；随后，首次有反对党成员进入政府担任卫生部长——一位来自自由党的极温和反对派取代了戈多伊；最后，反对清洗“金四角”的蒙塔纳罗被指控试图组织政变而被解职，而从前是斯特罗斯纳的忠实拥趸，后转变为民主主义立场的埃德加·林尼奥·因斯弗兰接管了内政部。“金四角”中唯一幸免于清洗的是马里奥·阿夫多，他是黑恶组织在政府的线人，同时也是罗德里格斯本人的亲信。"
const TXT_R1 := "斯特罗斯纳坚决地撤回了他下野的提议，并表示将“勉为其难”，再干一届。斯特罗斯纳将民粹主义贯彻在社会、经济与文化政策的各方各面，从而用尽全力给他的政权收拢民心。红党（ANR）长期以来收到农民与支持分子的支持，斯特罗斯纳利用这一点，组织起囊括农民、企业家、工会、学生、天主教会的倾向于斯特罗斯纳主义文化的组织，并且统合成公民反共组织委员会（CECA）。名为“赤脚军”的民兵组织依然是该政权的重要武器，1973年8月，斯特罗斯纳动员了这一组织参加支持他本人的示威游行，以应对反对派的行动。这个独裁者精心设计了一种“制衡牵制体系”——为了与陆军指挥部相牵制，“赤脚军”被纳入党的框架，作为效忠斯特罗斯纳本人的特别武装力量；另外还有致力于消灭所有反对分子的“处决小队”，其头目来自红党，但是成员并不是红党的正式党员。"
const TXT_FRIEND := "新政府决心和我们做朋友。"
const TXT_ENEMY := "新政府不想和我们做朋友。"

func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


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
	var c := ws.get_country_by_legacy_index(79)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			c.level_of_instability -= 15
			c.government = 3
			c.sub_government = 7
			c.set_tag("亲中", true)
			_want_to_leave(c)
			context["result_text"] = TXT_R0 + _friend_suffix(c)
		1:
			_add(W.I_BUDGET, -5)
			_add(W.I_AGENTS, -5)
			c.level_of_instability -= 15
			c.set_tag("对华贸易", true)
			_want_to_leave(c)
			context["result_text"] = TXT_R1 + _friend_suffix(c)
		_:
			c.level_of_instability -= 15
			_want_to_leave(c)
			context["result_text"] = TXT_R1 + _friend_suffix(c)
	_set_next_election(c, 1983, 2, 6)
