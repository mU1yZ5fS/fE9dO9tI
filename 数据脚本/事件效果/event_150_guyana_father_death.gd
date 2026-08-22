extends "res://数据脚本/event_script_base.gd"

## 原作 Event150.cs：国父的逝世。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - iron_and_blood 成就已接 Achievements（Set 编号见 execute 内注释）；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_OPT1_B := "切迪·贾根，人民进步党（左倾保守主义）"
const TXT_OPT2_DIS := "本在国内的政治影响力不足"
const TXT_R7 := "在大选的不久之前，休伊·霍伊特和人民国民大会（PNC）的其他成员开始与反对党人民进步党（PPP）进行谈判尝试，试图达成一项统一的全国方案以解决国家问题。霍伊特宣布他愿意继续展开对话，并宣布在大选中禁止海外投票、代理投票和邮寄投票以作为改革的面子姿态。而反对党质疑政府选举舞弊，抵制1986年的地区一级选举。结果是，人大党赢得了地区议会的所有席位，展开了国家改革。恢复经济被证明是政府所面临的主要挑战，而霍伊特迈出的第一步是增加私营部门在国民经济中的比例：社会主义经济被放弃、发展市场经济与私营企业被作为国家的首要任务、价格管制取消、鼓励私营企业的措施纷纷出台。1988年，霍伊特政府取消了外国企业在圭亚那经营的所有障碍，宣告自给自足的基本国策最终废除。然而，现在谈论民主化还太早了——1990年，霍伊特宣布圭亚那进入国家紧急状态，推迟选举，并把大片赤道森林租让给外国公司。"
const TXT_R1 := "选举的结果是出人意料的，在下野20余年之后，来自人民进步党（PPP）的切迪·贾根再次当选总统。然而正如风传的一样，人民全国大会党（PNC）通过选举舞弊在国民议会获得了22个席位，在地区议会获得10个席位。而民进党和联合力量仅获得21席与2席。在议会危机即将爆发的关头，休伊·霍伊特担心爆发民众骚乱，加入了人进党的执政联盟。作为妥协的成果，贾根成为了总统，并任命霍伊特为总理。面对经济危机，尤其是农作物签收与缺乏基础建设支持资金的情况，贾根起初试图向国际货币基金组织借款，但由于后者要求圭亚那实施私有化，贾根放弃了这一决定并转而接受社会主义诸国贷款。圭亚那的政治专制得到软化；开放向社会主义国家进口短缺品；东德、罗马尼亚、古巴的专家应邀来优化发展圭亚那的基础设施与医疗教育；圭亚那的专家也前往莫斯科和北京进修学习。解决圭亚那的社会经济问题有了暂时的可能性，但是经济增长陷入怠缓，而债务早晚需要偿付。"
const TXT_R8 := "切迪·贾根的第二个任期伊始便面临着同上一任期末期完全相同的问题：经济发展的停止与对社会主义国家的债务。不同于西方对他的担忧，他将自己标榜为民主社会主义者而非马列主义者执掌圭亚那。出于担心丧失国家独立性、依赖于其他国家的考虑，贾根不再继续接受社会主义阵营的援助，转而向国际货币基金组织贷款，并接受后者的条件将公共部门缺乏效益的部门，尤其是农业企业私有化，并将私有化所得用于投资基础设施与农业机械的现代化，从而恢复了财政盈余，加快了蔗糖出口速度。与此同时，贾根大力支持工会运动：他通过了新法以保护、发展工会活动，并强制工会监督工人雇佣。圭亚那至此正式确立了建设“合作型市场经济”与“社会导向型国家”的发展方针。"
const TXT_R9 := "在巧妙地赢得了黑人、原住民、小企业主、工人和农民的支持之后，布林德利·本的左右联盟成功在国民议会中获得次多的席位，而赢得最多席位的人民全国大会党（PNC）未能获得过半席位，人大党内部爆发了内部冲突与严重的宗派分裂，导致休伊·霍伊特被迫辞去了党首职务。在随后的联合政府谈判中，毛主义的劳动人民先锋党（WPVP）、黑人的非裔独立非洲文化关系协会（ASCRIA）和印第安原住民的泛印第安人民革命协会（IPRAR）和人大党本身被成功组建成立一个单一政党劳动人民联盟（WPA）。由于拒绝执政联盟结果，人大党的左翼分裂派、解放者党和人民民主运动退出了这一联盟。结果是，新成立的劳动人民联盟在国民议会中占据了79%的席位，成功执政。新政府成立后，它立即宣布旧政府为修正主义政权，右翼反对派都受境外情报机构资助；并决定进入国家紧急状态，对前人大党的左翼分裂派成员、右翼政党乃至人民进步党（PPP）的迫害就此开始，甚至切迪·贾根本人都被迫逃离圭亚那。与此同时，本宣布了全新的国家意识形态：“民族毛泽东主义”，其基础是逐步过渡到具有“拉美特色的社会主义”。他宣称：圭亚那还没有做好实行社会主义的准备，决定实行完全的农业私有化、废除自给自足的基本国策、允许外资进入圭亚那；对国产商品征收高额关税，外资公司必须在特许权基础上设立，并保证圭亚那公民至少持股40%。对于这些过激的市场改革，全国举行了大规模工会罢工，最终被血腥镇压。工会运动本身被勒令禁止，取而代之的是国家工人和雇主互助协会，旨在“确保工人与雇主间基于诚实与公平的互助”。圭亚那的国民经济与生产总值开始快速增长，然而，城市居民的福利正在下降，同时乡村人口的财富在大规模积累。"
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

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var c := world.get_country_by_legacy_index(77)
	var opt := event_def.options
	if c != null and c.sub_government != GameConstants.SubGovernment.STATE_SOCIALIST:
		_enable(opt[1], event_def.options[1].text)
	else:
		_enable(opt[1], TXT_OPT1_B)
	if c != null and c.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(77)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([7])
	if c.sub_government != GameConstants.SubGovernment.STATE_SOCIALIST:
		allowed[1] = true
	else:
		allowed[8] = true
	if c.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		allowed[9] = true
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
			if c.sub_government != GameConstants.SubGovernment.STATE_SOCIALIST:
				winner = _get_winner_in_america(c, allowed, 2.0, 1)
			else:
				winner = _get_winner_in_america(c, allowed, 2.0, 8)
			if winner == 1 or winner == 8:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 9)
			if winner == 9:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = GameConstants.Government.LIBERAL
	_set_next_election(c, 1992, 12, 5)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		c.level_of_instability -= 15
		_add_power(EmpireData.USSR, 5)
		context["result_text"] = TXT_R7 + _friend_suffix(c)
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
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, 15)
		# 原作 Event150.cs:143：iron_and_blood → achievements.Set(99)
		Achievements.set_achievement(99)
		context["result_text"] = TXT_R8 + _friend_suffix(c)
		return
	if c.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		c.government = GameConstants.Government.AUTHORITARIAN
		c.level_of_instability -= 20
		c.level_of_development -= 5
		_add_power(EmpireData.USA, 15)
		_add_power(EmpireData.USSR, -5)
		# 原作 Event150.cs:157：iron_and_blood → achievements.Set(100)
		Achievements.set_achievement(100)
		context["result_text"] = TXT_R9 + _friend_suffix(c)
