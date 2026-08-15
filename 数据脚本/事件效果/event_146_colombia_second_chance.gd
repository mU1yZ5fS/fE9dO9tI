extends "res://数据脚本/event_script_base.gd"

## 原作 Event146.cs：第二次机会。
## 触发：原版 TimeScript.EventsRequirements 链外 REST 段；全目录检索
##   this_num_event / Reset / event_done / resultOfEvents / StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - GetWinnerInAmerica / WantToLeave 逐行移植；
##  - 原版 string.Format 的 <color=red> 标签剥除，红字用 TXT_FRIEND / TXT_ENEMY 拼接；
##  - 原版 iron_and_blood 成就 achievements.Set 未建模，跳过并注释；
##  - 选项显隐/动态文案 prepare 动态改写（如有）。

const TXT_TITLE := "第二次机会"
const TXT_DESC := "到了1982年，哥伦比亚全国陷入普遍贫困，各地的游击队此起彼伏，这导致了左翼运动的强大。如果这些游击队能够成功实现合法化，那么他们便有资格以民主联盟（AD）的身份正式参选执政。与此同时，在麦德林和卡利的贩毒集团的串联下，哥伦比亚向美国贩卖可卡因的活动也在野蛮滋长。他们利用大笔钱财购买大型农场、从非洲进口野兽、洗白黑钱，和投入渗透社会政治之中。面对这一情形，新自由党（NL）和他们的代表路易斯·卡洛斯·加兰脱颖而出，并提出了社会自由主义的政治经济议程；与此同时，传统政党及其代表，保守党（“C”）的贝利萨里奥·贝坦库尔·夸尔塔斯站在政治民主、文化保守、联邦制与经济自由的立场；最后是自由党（“L”）的阿方索·洛佩斯·米切尔森，他在1978年前曾有过一段总统任期，这一任期内他发展哥伦比亚农业、精简法律体系，同时镇压了劳工工会抗议，使国内通胀达到峰值。总统之位花落谁家，我们才能得知这个国家能否真正发生改变。"
const TXT_OPT0 := "贝利萨里奥·贝坦库尔·夸尔塔斯，哥伦比亚保守党（自由主义）"
const TXT_OPT1 := "阿方索·洛佩斯·米切尔森，哥伦比亚自由党（右翼独裁主义）"
const TXT_OPT2 := "路易斯·卡洛斯·加兰，新自由党（社会民主主义）"
const TXT_OPT3 := "安东尼奥·何塞·纳瓦罗，民主联盟（国控社会主义）"
const TXT_OPT3_DIS := "游击运动尚未转入公开活动"
const TXT_OPT4 := "保持距离"
const TXT_R6 := "贝坦库尔的连任表明其政策在国家稳定、民主化与联邦化方向上取得了成功。然而，经济问题仍未得到解决，这给新政府带来极沉重的负担。尽管如此，政府继续高度关注媒体、集会、文学与舆论四大自由。司法制度也显著地民主化了：刑罚减少、新的拘留审讯规则出台、无罪推定不可侵犯、法官选举自由透明、法庭程序去封闭化。在对抗社会问题上，贝坦库尔政府实现了消灭文盲，在教宗的批准下吸引天主教会组织的广泛慈善项目。在新一届政府领导下，打击毒品的斗争继续进行，反腐措施得到加强，并出台了禁止私营企业向政客与政党献金的禁令。为了解决经济问题，贝坦库尔决定降低税收，并未吸引外资创造有利政策，赋予地方政府直接对外招商引资的权限。然而总的来说，这些消极的经济措施并没有创造十分可喜的成果：仅有少部分地区能够得到发展富裕，吸引贫困地区人口大量迁移，这最终导致了区域间发展失衡愈加严重。"
const TXT_R6_DEAD := "在贝坦库尔的总统任期内，他开始建造经济适用房、开办大学、推广扫盲运动。在贝坦库尔的努力下，政府同许多武装叛军展开谈判，并达成了为期一年的停火协议，成立一个混合委员会以讨论政治和解与解除武装的议程，一些叛军由此走上了合法活动与议会斗争的道路。贝坦库尔政府还为哥伦比亚的民主化与发展作出了贡献：在任内，他通过了市长选举法、市政司法改革法案、免费电视服务章程与国家假日法；开始对煤炭资源的勘探与出口以提振经济；成功开展反毒品贸易运动并反对大毒枭渗透国家政治体系。贝坦库尔任期的另一个特点是哥伦比亚行政权力与财政权力的下沉：市级政府在税收使用上取得了广泛的自主权；同时市长直选制被引入，取代了此前的市长由省长任命制。"
const TXT_R7 := "阿方索·洛佩斯·米切尔森的竞选口号是“米尔切森，舍他其谁？”，并受到了贩毒巨头与相关企业的赞助。将他提名为总统候选人的决定也导致了自由党（“L”）的分裂，导致该党仅剩下过去主导三十年的“传统路线”主要党员。米尔切森以总统的身份推行了他的“民主安全政策”，推行广泛的“反恐行动”以彻底摧毁反叛组织。一是通过建立“山地营”来使国家重新掌控边远山区，即由农民民兵组成，在数个城市服从国家警察指挥，向举报者提供奖励的组织；二是对游击队的根据地展开围剿。国家预算的很大一部分被用于扩编军队、内务与执法机关和资助军工复合体。因此，为了“为民主安全政策筹措必要花费”，投入武装行动，财产税制度被引入，资产超过1.695亿哥伦比亚比索的公民需缴纳税收。另一方面，为了发展旅游业，当局开发了数条受政府保护的旅游线路。米尔切森政府将“不管控市场、发展旅游业和消灭叛军”作为发展经济的三板斧，然而其结果却是，各个毒品集团披上了合法活动的外衣，渗透进国家机器，成为经济活动的主要参与者。"
const TXT_R4 := "路易斯·卡洛斯·加兰在“哥伦比亚是所有人的哥伦比亚”的口号下赢得选举，并意图实施民主、社会与经济改革。在执政之后，加兰发起了一场大规模审判贩毒集团成员的运动，清洗国家机关中任何与贩毒集团有某种联系的人员，并将其上升到国家战略高度。结果是，在大毒枭的授意下，加兰在索阿查的一次公开演讲中遇刺身亡。这一刺杀行动后来被证明是一项大型阴谋，背后有哥伦比亚许多重要人物的身影。在副总统恩里克·帕雷霍·冈萨雷斯继任总统后，授意军队指挥官进行秘密调查，发现安全部是暗杀计划最大的幕后黑手。于是军队在夜间大规模逮捕了许多自由党高层，甚至安全部门首长本人，这些人在后来哥伦比亚最大规模的调查中受审。在意识到哥伦比亚的主要问题是贩毒集团而非叛军后，冈萨雷斯同左翼叛军达成停战协议，并与后者联合对抗贩毒集团。从贩毒集团收缴的资产价值多达数十亿美元，这些资产后来拍卖给私人，所得资金被用于组织一项社会项目：为穷人建造住房、分发社会食品、打击失业，并投资建设大型基础设施项目，从而发展经济并提供岗位。在冈萨雷斯政府的末期，失去领袖的新自由党（NL）同旧的自由党（“L”）举行了一次联合大会，对旧自由党的“传统路线”派进行了肃清。重获新生的自由党主张走一条温和主义、民主主义与自由市场经济的道路。"
const TXT_R1 := "安东尼奥·何塞·纳瓦罗刚刚就任便面临与自由党（“L”）的激烈斗争。何塞的初步改革：向穷人分发饮用水、建立药品价格管制、给农民分发作物种子以停止古柯种植，被涌入司法部门与执法部门的自由党官僚严重破坏了。在这一斗争中新自由党（NL）的领袖，曾经与民主联盟结为临时联盟的路易斯·卡洛斯·加兰在演讲中被刺杀。这场刺杀的幕后主使后来被证明是大毒枭、自由党高层政客甚至国家安全部负责人。这引发了迄今为止闻所未闻的局面：军队和前游击队站在一起，对贩毒集团发起军事打击。一场内战打响了，民主联盟、军队、游击队，还有保守党（“C”）的一方同毒枭武装、自由党（“L”）、内政部与安全部所辖部队的一方进行了武装对抗。在国际共产主义运动的支持下，执政当局获得胜利，毒贩被清剿，自由党被取缔，参战人员得到了公正的审判。然而，在军方的坚持下，民主联盟没有成功废除旧有体制建立一党专政，但这并不妨碍在内部冲突中积攒大量威望的民主联盟成为“掌权党”，并在议会改选中获得多数席位。有了这种“人民授权”，新的执政当局开始实行一种类似于匈牙利的卡达尔主义者的改革：对土地进行再分配、耕者有其田、部分的价格控制、广泛的社会保障与国家对贸易的垄断。"
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
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var c := world.get_country_by_legacy_index(75)
	var opt := event_def.options
	if c != null and c.sub_government == 4:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c := ws.get_country_by_legacy_index(75)
	if c == null:
		return
	var opt := int(context.get("option_index", -1))
	var allowed := _allowed10([6, 7, 4])
	if c.sub_government == 4:
		allowed[1] = true
	var winner := 0
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 6)
			if winner == 6:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(c, allowed, 2.0, 7)
			if winner == 7:
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
		3:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			allowed[6] = false
			allowed[7] = false
			winner = _get_winner_in_america(c, allowed, 5.0, 1)
			if winner == 1:
				c.set_tag("亲中", true)
			else:
				c.set_tag("亲中", false)
		_:
			winner = _get_winner_in_america(c, allowed, 0.0, -1)
			if winner != c.sub_government:
				c.set_tag("亲中", false)
	c.government = 3
	_set_next_election(c, 1986, 5, 25)
	c.sub_government = winner
	_want_to_leave(c)
	if c.sub_government == 6:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, 5)
		# 原版此分支内 if (SubGosstroy != 6) 恒假，new_texts[502] 为死代码，已注释：
		# TXT_R6_DEAD := "..."
		# 原版 iron_and_blood 成就 achievements.Set(96)，未建模跳过。
		context["result_text"] = TXT_R6 + _friend_suffix(c)
		return
	if c.sub_government == 7:
		c.level_of_instability -= 20
		c.level_of_development -= 5
		_add_power(EmpireData.USA, 15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R7 + _friend_suffix(c)
		return
	if c.sub_government == 4:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -5)
		context["result_text"] = TXT_R4 + _friend_suffix(c)
		return
	if c.sub_government == 1:
		c.level_of_instability -= 10
		c.level_of_development += 5
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		# 原版 iron_and_blood 成就 achievements.Set(97)，未建模跳过。
		context["result_text"] = TXT_R1 + _friend_suffix(c)
