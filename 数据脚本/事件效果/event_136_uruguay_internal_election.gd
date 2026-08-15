extends "res://数据脚本/event_script_base.gd"

## 原作 Event136.cs：皮诺切特的失败翻版。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 原版 iron_and_blood 成就 achievements.Set 未建模，跳过并注释；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_TITLE := "皮诺切特的失败翻版"
const TXT_DESC := "格雷戈里奥·阿尔瓦雷斯原本是军政府中的激进派。军队因他被任命为陆军司令官而陷入分裂。1978年3月3日，他发布了第7738号法令，根该据法令，信息与国防局（IDS）将隶属于他的指挥。而时任信息与国防局主任阿莫里·柏兰特将军拒绝执行该文件，他因此被处以六十天拘役并最终辞职。1980年，他试图组织一场宪法公投，按预期，公投后将只有三个合法政党得以保留，也只有一位候选人能被推选出来，军队权力也将写入宪法。而1980年公投反而表明了乌拉圭公民对恢复民主生活的意愿，此后，阿尔瓦雷斯中将不愿接受这一结果，并试图逼迫所谓的国家委员会将共和国总统职位移交给他，从而推迟恢复民主的进程。此时，他在军队中的对手是乌戈·梅迪纳将军，而后者更倾向于将权力移交给平民。由于乌拉圭的军队精英们正陷入内斗，试图干预战时最高统帅选举的机会比比皆是。"
const TXT_OPT0 := "“稍微”帮助乌戈·梅迪纳（右翼独裁主义）"
const TXT_OPT0_DIS := "我们与乌拉圭军政府内部没有任何联系"
const TXT_OPT1 := "推动军方维持文官政府的形象（自由主义）"
const TXT_OPT1_DIS := "乌拉圭的文官政府不够强大"
const TXT_OPT2 := "保持距离"
const TXT_R0 := "在内部选举期间，格雷戈里奥·阿尔瓦雷斯实际上已经下台，军队总司令一职由乌戈·梅迪纳接任。与此同时，亲民主派势力也赢得了议会的多数席位。作为军方与政界人士为摆脱独裁统治而进行的谈判的一部分，梅迪纳是武装部队内部最愿意进行对话的人，他也同意在1984年11月组织全国选举，保证议员在选举之前的享有一系列权利与权力，并逐步推进民主化进程。然而，作为一名军队将领，梅迪纳遭到了指控，称其在向独裁统治期间严重侵犯人权的军方人员发出传票所引发的危机中发挥了关键作用。而梅迪纳说，传票正放在他办公室的一个保险箱里，他也不会交出传票，并暗中威胁要拒不从命，这演变成了一种体制危机，最终，“逾期法”出台，任何人都无法因其军政府期间所犯的罪行被定罪。"
const TXT_R1 := "直到他去世为止，阿尔贝托·德米切利都允许亲民主派在政府内站稳脚跟，亲民主党派在内部议会选举中也赢得了大多数席位，这些事实都能让我们使军方理解维持文职政府的面具的必要性。格雷戈里奥·阿尔瓦雷斯直截了当地建立一个毫不掩饰的军政府的想法被否决了，他本人也被罢免。政客们同军方敲定，最高法院院长拉斐尔·阿迭戈·布鲁诺将接管行政权力。在其任期内，他负责处理乌拉圭近些年来最有争议的问题之一，即“逾期法”（该法使任何人都无法因其军政府期间所犯的罪行被定罪），他在发言中确定该法符合宪法。尽管接受了文官政府的存在，但国家安全委员会（KOSEN）与军方仍掌握着权力，副总统职位依然空缺。在他执政期间，布鲁诺致力于重塑并优化乌拉圭的法律体制，以便为国家向民主与自由选举的过渡做准备，选举定于1984年11月举行。"
const TXT_R2 := "在阿尔瓦雷斯执政期间，该国国内以及阿根廷的政治活动家是镇压的首要对象，他被指控在军营与秘密基地中犯下了反人类罪。政治反对派与军政府的反对者也被镇压、绑架或暗杀。对失踪人员下落的调查仍在进行之中。由于他持续镇压工会，他失去了许多民众的支持，军方的很多人也不再拥护他，所以，他立刻同意在1984年11月举行议会与总统选举，在此之前，他便在1982年举行了内部选举，亲民主力量赢得了这次选举。阿尔瓦雷斯在蒙得维的亚的住所成了示威者的活动中心，他们为在1973-1985年间的军官-文官统治下的下落不明的反对派而抗议。"
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

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var r135 := int(world.completed_event_ids.get("event_135", 0))
	var opt := event_def.options
	if r135 <= 1:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if r135 == 0:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(82)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			c.level_of_instability -= 15
			c.sub_government = 7
			c.set_tag("亲中", true)
			_want_to_leave(c)
			context["result_text"] = TXT_R0 + _friend_suffix(c)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			c.level_of_instability -= 15
			c.sub_government = 6
			c.set_tag("亲中", true)
			_want_to_leave(c)
			context["result_text"] = TXT_R1 + _friend_suffix(c)
		_:
			c.level_of_instability -= 20
			c.level_of_development -= 5
			c.government = 0
			c.sub_government = 7
			# 死代码/未建模：原版此分支不扣 data[8]/data[9]；proprc 沿用旧值拼红字。
			context["result_text"] = TXT_R2 + _friend_suffix(c)
	_set_next_election(c, 1984, 11, 25)
