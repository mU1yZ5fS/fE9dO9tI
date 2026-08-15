extends "res://数据脚本/event_script_base.gd"

## 原作 Event141.cs：光辉乍现。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 原版 iron_and_blood 成就 achievements.Set 未建模，跳过并注释；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_TITLE := "光辉乍现"
const TXT_DESC := "不同于拉丁美洲的其他军政府，由胡安·贝拉斯科·阿尔瓦拉多将军领导的秘鲁军政府进行了诸多左翼改革：土地改革、保护土著文化、保护和改善劳工权益、赋权工会，甚至建立了工团模式经济；负面来看，秘鲁当局也控制媒体、全面审查与迫害反对派。然而，由于军政府一方面实施自然资源国有化、没收外企资本；一方面拒绝同苏联的密切往来，导致了它在国际上备受孤立，陷入经济危机。对此，1975年弗朗西斯科·莫拉莱斯·贝穆德斯将军政变上台后，秘鲁转向国际货币基金组织。为换取大量贷款，开始遵守国际金融机构的各项约束，实施私有化、去管制化与民主化。1975年制宪会议召开后，1980自由选举推出了以下候选人：费尔南多·贝朗德·特里，来自温和主义的人民党（PP）的代表，该党在军事政变前执政，是1979年民主化的重要内部助推手；阿曼多·维拉纽埃瓦，来自一个特立独行的非马克思主义、泛美社会主义的政党美洲人民革命联盟（APRA），持改良主义与反帝国主义立场；最后值得一提的是，来自地下游击队运动的毛主义组织光辉道路（PCP-SL），他们对选举不屑一顾，并着手建立军政司令部以发动农民起义。"
const TXT_OPT0 := "费尔南多·贝朗德·特里，人民党（温和主义）"
const TXT_OPT1 := "阿曼多·维拉纽埃瓦，美洲人民革命联盟（民主社会主义）"
const TXT_OPT2 := "光辉道路，毛主义游击队与革命派（毛主义）"
const TXT_OPT2_DIS := "毛派拒绝听从我们的修正主义领导"
const TXT_OPT3 := "保持距离"
const TXT_R5 := "贝朗德重返执政之后的第一件事便是将军方控制的报刊归还给合法所有人，从而恢复言论自由。然而，由于军政府的土地改革实现了秘鲁农业的去封建化，他并不想废除国家征用土地制度。与此同时，新总统着力打破孤立局面，恢复与美、英、法的关系，并在外交领域取得巨大成功。在经济方面，贝朗德麾下的是，由《快车报》主编兼经济部长曼努埃尔·乌路亚所领导的自由主义经济团队，他们着手于贝朗德的前一任期便开始的水利、道路基础设施项目的建设与部分私有化。利马与各个城市兴建了大型住宅小区、城乡基础设施几乎在全国各地都重建完成，一项供应饮用水与卫生设施的国家工程得以展开；与之相对的是，大多数私有化与放松管制的改革并没有得到议会的通过。总而言之，在军政府统治末年的沉闷与停止之后，新领导班子终于为这个国家吹进了一股清新的空气。"
const TXT_R3 := "美洲人民革命联盟，或称秘鲁阿普拉党（APRA）起初将泛西语主义奉为纲领。该党创始人阿亚·德·拉·托雷拒绝西方资本主义模式与苏联社会主义道路，认为拉丁美洲，或是他所称的印第安美洲，应该有自己的发展道路，以及自己的社会主义国民经济体制。拉·托雷去世后，该党分裂为两个派系，最终“左翼阿普拉主义者”阿曼多·维拉纽埃瓦在党内两位领导人的斗争中胜出，并且赢得了选举。执政之后，他宣布对军政府执政末期的改革实行逐步的“拨乱反正”。维拉纽埃瓦的政敌汤森德指责他“在意识形态上修正，有腐败的迹象”，作为回应，他将汤森德及党内其他右翼成员开除出党，并与基督教人民党、革命工人党、革命左翼联盟及左翼统一党组成联盟，形成一个温和的左翼议会联盟。进一步的改革部分恢复了军政府执政前期的改革成果：企业必须同工人分享股份，工人因享有股权而获得投票权的工团化企业模式；规定工人必须参与工会，雇佣合同必须经过工会批准才能签订，从而扩大了工会权力；保障原住民与劳工权利；开办农业银行，扶持年轻农业从业者。同时，由于预估经济形势的条件不足，新政府没有像军政府建立开始时一样建立工人对企业的完全控制。与军政府不同的是，新政府保障了媒体的充分自由、意见的多元化与多党民主，致力于创建在政治与经济上高度互信的泛拉美合作组织。"
const TXT_R_FALLBACK := "在后军政府时期的混乱局势下，新总统费尔南多·贝朗德因害怕被军队再一次推翻而不愿使用军队解决问题、实施镇压。光辉道路的毛派武装把握了这一形势，在农村地区开展了声势浩大的游击运动，并依托无地的贫下中农支持，开展人民战争，接连解放一座又一座村庄。面对毛派日益增长的影响力，贝朗德不得不动用警察与内务机关的力量，狼狈为奸地制造白色恐怖。由于这些压迫，久而久之地，举起“光辉道路”的旗帜进行武装斗争成为穷苦人唯一的生存手段，革命形势日渐高涨。然而，由于秘鲁周围并没有愿意与中国合作的国家，因此在我们的第一批援助到达后，秘鲁的邻国便在美国的指示下便对光辉道路进行了封锁，毛派武装陷入孤立无援的境地。很快，邻国在美国的暗中援助下发动了一场联合维和特别军事行动，即“秃鹰计划”，清洗了还在活动的毛派武装，光辉道路被迫转入地下游击。此后，在美国国务卿的调解下，秘鲁成立了费尔南多·贝朗德与人民党的临时政府。"
const TXT_R17 := "在后军政府时期的混乱局势下，新总统费尔南多·贝朗德因害怕被军队再一次推翻而不愿使用军队解决问题、实施镇压。光辉道路的毛派武装把握了这一形势，在农村地区开展了声势浩大的游击运动，并依托无地的贫下中农支持，开展人民战争，接连解放一座又一座村庄。面对毛派日益增长的影响力，贝朗德不得不动用警察与内务机关的力量，狼狈为奸地制造白色恐怖。由于这些压迫，久而久之地，举起“光辉道路”的旗帜进行武装斗争成为穷苦人唯一的生存手段，革命形势空前高涨。最终光辉道路的城市地下党在首都利马组织工人发起了一场大起义，占领了各个行政机关，光辉道路宣布将大楼移交给新政府，军队随之展开行动。然而，已经接受了革命宣传的基层士兵迅速倒向毛派，迫使将官逃离秘鲁。秘鲁革命胜利了，贡萨罗主席在建国大会上宣布成立秘鲁人民共和国，开始领导人民建设新民主主义。党领导贫下中农在农村地区开展大规模的土地改革运动，在城市中没收帝国主义和官僚资产阶级的企业；原住民自治制度也在秘鲁确立了，秘鲁人民正走在社会主义的光辉道路上。光辉道路的胜利让拉美的左翼游击队活动更加活跃了，部分游击队开始放弃格瓦拉的游击中心主义，转向马列毛主义的人民战争理论——秘鲁的胜利对整个拉美而言也是一段光辉道路的开始。总的来说，毛主义者的政权已经站稳了脚跟。"
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
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var cond := false
	if world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active:
		var d := world.数值表
		if d.size() > W.I_ECON_SYSTEM and d[W.I_IDEOLOGY] <= 3 and d[W.I_ECON_SYSTEM] <= 12 and world.influence_prc >= 150:
			cond = true
	if cond:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(80)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([5, 3])
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 5)
			c.government = 3
			_set_next_election(c, 1985, 4, 14)
			if winner == 5:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 3)
			c.government = 3
			_set_next_election(c, 1985, 4, 14)
			if winner == 3:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = 17
		_:
			c.government = 3
			_set_next_election(c, 1985, 4, 14)
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == 5:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, 15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R5 + _friend_suffix(c)
		return
	if c.sub_government == 3:
		c.level_of_instability += 10
		c.level_of_development += 25
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R3 + _friend_suffix(c)
		return
	var c72 := ws.get_country_by_legacy_index(72)
	var c73 := ws.get_country_by_legacy_index(73)
	var c74 := ws.get_country_by_legacy_index(74)
	if (c72 != null and c72.sub_government < 6) or (c73 != null and c73.sub_government < 6) or (c74 != null and c74.sub_government < 6):
		c.government = 1
		c.set_tag("亲中", true)
		_set_next_election(c, 2222, 2, 22)
		c.level_of_instability -= 30
		c.level_of_development -= 15
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, -15)
		ws.influence_prc += 15
		# 原版 iron_and_blood 成就 achievements.Set(94)，未建模跳过。
		context["result_text"] = TXT_R17 + _friend_suffix(c)
		return
	c.sub_government = 5
	c.government = 3
	c.set_tag("亲中", false)
	_set_next_election(c, 1985, 4, 14)
	c.level_of_instability -= 20
	c.level_of_development -= 5
	_add_power(EmpireData.USA, 15)
	ws.influence_prc -= 15
	context["result_text"] = TXT_R_FALLBACK + _friend_suffix(c)
