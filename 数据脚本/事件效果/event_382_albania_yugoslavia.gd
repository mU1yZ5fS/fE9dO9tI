extends "res://数据脚本/event_script_base.gd"

## 原作 Event382.cs：南阿战争（阿尔巴尼亚-南斯拉夫，四选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_TITLE := "“突破行动”"
const TXT_DESC := "让我们把时间拨回到1977年11月，当时，阿尔巴尼亚内务部长卡德里·哈兹比乌向该国领导层发送了一份报告，就解决阿尔巴尼亚与南斯拉夫间的领土冲突问题给出了一份可能方案。他建议该国高筑墙广积粮，等到南斯拉夫总统铁托死后，等到对南斯拉夫社会主义联邦共和国的军事进攻计划大功告成后再行动。1979年1月至3月期间，阿尔巴尼亚举行了代号为“比扎”和“城堡”的军事演习，证明了阿尔巴尼亚人民军还没有做好与南斯拉夫人民军正面对抗的准备。\n然而，现在南斯拉夫已经没有铁托了，而政府军同科索沃分离主义者的对抗仍在持续。因此，阿尔巴尼亚领导层认为，在此时对南斯拉夫进行军事干预并捅一刀的成功率非常高。我们还不清楚北约对此将持何种态度，但根据从华约中非官方渠道流出的消息来看，倘若军事冲突仅限于有限范围内。东方将不考虑对其进行干预。\n根据“突破”行动的计划来看，22万阿尔巴尼亚人民军将开赴南斯拉夫。其中65%的兵力将被部署在科索沃，35%的兵力则被安置在马其顿与黑山的阿尔巴尼亚族社区。事实上，这一行动是阿尔巴尼亚的孤注一掷，包括其压箱仓的储备也将被压入赌局。意味着行动将变成场阿尔巴尼亚绝不能输掉的全面战争。毕竟，战败不仅意味着政权的崩溃，同时还意味着主权的沦亡。"
const TXT_OPT0 := "保证为阿尔巴尼亚的行动提供后勤支持（需要20.0百万{0}与20.0点{1}）"
const TXT_OPT1 := "劝阻阿尔巴尼亚方放弃军事冒险（需要3.0百万{0}与3.0点{1}）"
const TXT_OPT2 := "看起来我们的巴尔干伙伴们需要“团结一致向前看”，对他们施压。（需要15.0百万{0}与30.0点{1}）"
const TXT_OPT3 := "让他们自行其是"
const TXT_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_DIS_INFLUENCE := "中国的国际影响力应高于{0}......"
const TXT_DIS_ALBANIA := "阿尔巴尼亚人不会听我们的......"
const TXT_DIS_ECON := "没有经济联盟的我们，不可能让他们有信心有恒心......"
const TXT_DIS_COND := "搞这样的大新闻，必须得到超级大国的背书。要么与苏联复交，要么与美国签署友好协定......"
const TXT_R0 := "我们承诺将全力支援我们的阿尔巴尼亚同志与南斯拉夫集团间的斗争——已经没有必要对《凡尔赛合约》故事重提，毕竟它很早之前就已经成为了一张废纸。6月26日，阿尔巴尼亚人民军部队穿过边界，对普里什蒂纳（彼时当地还在交战）、斯科普里与铁托格勒发起了攻势。由于实力不足，科索沃本地的抵抗军在年初便被南斯拉夫部队解除了武装；但在新爆发的冲突中，阿尔巴尼亚部队在准备充分，装备更精良的南斯拉夫人民军的阻挠下进攻受挫，该国军队也无法拿下哪怕一座城市。\n美国要求阿尔巴尼亚“立即且无条件”撤走部队，并迅速增进了对南斯拉夫社会主义联邦共和国的军事援助，但苏联一方仅谴责侵略行为，并呼吁各方开展和平协商。"
const TXT_R1_OK := "阿尔巴尼亚领导层同意我们的观点，并认为“突破行动”是一场会导致无法预料后果的危险豪赌。所有与之有关的文件均被命令销毁，而在《人民之声》报（Zёriipopullit）上，也发表了一篇题为《保加利亚的勒索与威胁阴谋绝不可能在巴尔干得逞》的社论。该文点名称保加利亚（当然，也间接攻击了苏联）“恐吓南斯拉夫人民”。\n南斯拉夫领导层对这篇文章持积极立场，并支持阿尔巴尼亚方对保加利亚的描述。认为后者“正成为实施对阿尔巴尼亚、南斯拉夫与希腊三国人民侵略政策的走卒”。老对手之间的关系得到了显著提升，因此，他们之间得以落实数项联合基础设施工程。"
const TXT_R1_BAD := "阿尔巴尼亚领导层忽略了我们的观点，认为“中国同志不过是杞人忧天。至于南斯拉夫？他们在失去了修正主义头子铁托之后，便已经一脚踩入坟墓了”。从而同我们的警告背道而驰，宣布施行“突破”行动。6月26日，阿尔巴尼亚人民军部队穿过边界，对普里什蒂纳（彼时当地还在交战）、斯科普里与铁托格勒发起了攻势。由于实力不足，科索沃本地的抵抗军在年初便被南斯拉夫部队解除了武装；但在新爆发的冲突中，阿尔巴尼亚部队在准备充分，装备更精良的南斯拉夫人民军的阻挠下进攻受挫，该国军队也无法拿下哪怕一座城市。\n在清楚我们的立场后，苏联与美国联合谴责了阿尔巴尼亚领导层的侵略政策，并扩大了对南斯拉夫社会主义联邦共和国的援助。"
const TXT_R2 := "当我们得知阿尔巴尼亚的计划后，我方得以想起毛泽东主席与周恩来总理谋划已久的“地拉那-贝尔格莱德-布加勒斯特”轴心计划。通过这一联盟，我们足以遏制苏联与美国对巴尔干地区的野心，并允许中国登上冷战欧洲的博弈舞台。南斯拉夫在立场上的模棱两可，阿尔巴尼亚激进的孤立主义政策，以及罗马尼亚对苏联愈加增强的独立倾向。这三者不仅让我们，甚至让那些超级大国本身都感受到厌烦。因此，我们决定让自己接手这一烂摊子。也就在我方的政治与经济压力下，阿尔巴尼亚、南斯拉夫与罗马尼亚不得不在万象（注：老挝的首都）举行联合会谈，并宣布建立“巴尔干联邦”——一个具有“软”成员身份的区域组织，其目的是解决区域争端、实现地区经济文化合作、乃至建立集体安全机制。罗马尼亚领导层已经宣布退出华沙条约组织的军事一体化结构（尽管在形式上仍是该组织的成员），这激怒了苏联。\n看起来这一协商机制很难延续下去......但谁知道未来会如何......"
const TXT_R3 := "恩维尔·霍查在20世纪80年代初预言的铁托之死将导致的连锁反应（即南斯拉夫社会主义联邦共和国内的危机，在外部势力的干预下，最终将演化为一场全面的内部冲突）并没有到来。随后举行的“什本尼库-81”演习（Shebeniku-81）则进一步证明迅速完成“突破行动”的主要目标是不可能的。阿尔巴尼亚领导层指示立即结束行动，并销毁与之有关的各类材料。这次，巴尔干确实无战事。"
const TXT_WAR_NAME := "南阿战争"
const TXT_WAR_ATT := "阿尔巴尼亚"
const TXT_WAR_DEF := "南斯拉夫"


const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var albania := world.get_country_by_legacy_index(20)
	var china := world.get_country_by_legacy_index(1)
	var usa := world.get_country_by_legacy_index(51)
	var opt := event_def.options
	if world.influence_prc >= 300 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 200 and _d(W.I_AGENTS) >= 200:
		_enable(opt[0], TXT_OPT0.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 200:
		_disable(opt[0], TXT_DIS_BUDGET.format([20]))
	elif _d(W.I_AGENTS) < 200:
		_disable(opt[0], TXT_DIS_AGENTS.format([20]))
	else:
		_disable(opt[0], TXT_DIS_INFLUENCE.format([30]))
	if albania != null and albania.has_tag("亲中") and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 30 and _d(W.I_AGENTS) >= 30:
		_enable(opt[1], TXT_OPT1.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt[1], TXT_DIS_BUDGET.format([3]))
	elif _d(W.I_AGENTS) < 30:
		_disable(opt[1], TXT_DIS_AGENTS.format([3]))
	else:
		_disable(opt[1], TXT_DIS_ALBANIA)
	if world.influence_prc >= 300 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 150 and _d(W.I_AGENTS) >= 300 			and china != null and china.has_tag("econ") 			and (world.get_flag("relres") or (usa != null and usa.has_tag("对华贸易"))) 			and albania != null and albania.has_tag("亲中"):
		_enable(opt[2], TXT_OPT2.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif china == null or not china.has_tag("econ"):
		_disable(opt[2], TXT_DIS_ECON)
	elif world.influence_prc < 300:
		_disable(opt[2], TXT_DIS_INFLUENCE.format([30]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 150:
		_disable(opt[2], TXT_DIS_BUDGET.format([15]))
	elif _d(W.I_AGENTS) < 300:
		_disable(opt[2], TXT_DIS_AGENTS.format([30]))
	else:
		_disable(opt[2], TXT_DIS_COND)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_start_war_382(300, 700, 1, -1)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
		1:
			if _d(W.I_INFLUENCE) >= 300:
				context["result_text"] = TXT_R1_OK
				_add(W.I_DIPLO, -50)
				_add_relation(EmpireData.USSR, -50)
				_add_relation(EmpireData.USA, 100)
				_add(W.I_AGENTS, -30)
				_add(W.I_BUDGET, -30)
				_add(W.I_INFLUENCE, 10)
			else:
				context["result_text"] = TXT_R1_BAD
				_add(W.I_DIPLO, -50)
				_add_relation(EmpireData.USSR, -150)
				_add_relation(EmpireData.USA, -150)
				_add(W.I_BUDGET, -30)
				_add(W.I_AGENTS, -30)
				_add(W.I_INFLUENCE, -10)
				_start_war_382(200, 800, 1, 1, 8)  # 原版 TickTime(4)，但 TimeScript WorldWarsDone 对 result382==1 的有效阈值是 8
		2:
			context["result_text"] = TXT_R2
			var romania := ws.get_country_by_legacy_index(5)
			var albania := ws.get_country_by_legacy_index(20)
			var yugo := ws.get_country_by_legacy_index(15)
			if romania != null:
				romania.set_tag("亲中", true)
			if albania != null:
				albania.set_tag("亲中", true)
			_add(W.I_INFLUENCE, 50)
			_add_power(EmpireData.USSR, -100)
			_add_power(EmpireData.USA, -100)
			_add(W.I_AGENTS, -300)
			_add(W.I_BUDGET, -150)
			_add(W.I_DIPLO, 100)
			if albania != null:
				albania.special = 1
				albania.set_tag("balecon", true)
			if yugo != null:
				yugo.set_tag("balecon", true)
			if romania != null:
				romania.set_tag("balecon", true)
			_add_relation(EmpireData.USA, -200)
			_add_relation(EmpireData.USSR, -200)
		_:
			context["result_text"] = TXT_R3


func _start_war_382(infl1: int, infl2: int, usa_side: int, ussr_side: int, tick: int = 20) -> void:
	GameManager.start_war(18, TXT_WAR_ATT, TXT_WAR_DEF, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > 18 and ws.wars[18] != null:
		ws.wars[18].name_war = TXT_WAR_NAME
		ws.wars[18].fortnight_max = tick


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
