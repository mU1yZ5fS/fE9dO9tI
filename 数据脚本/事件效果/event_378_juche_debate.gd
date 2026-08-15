extends "res://数据脚本/event_script_base.gd"

## 原作 Event378.cs：肝胆相照（朝鲜主体思想争论，六选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 选项显隐 prepare 动态改写；
##  - 原版 politics 循环 → ws.politicians，traits[0] → trait_personality；
##  - 原版 guns 字段端口未建模，按 ws.get_flag("guns") 处理（默认 false）。

const TXT_TITLE := "肝胆相照"
const TXT_DESC := "70年代时，朝鲜的主体思想还处于萌芽阶段，并以“金日成主义”的名字示人。朝鲜意识形态理论家以双层嵌套逻辑为该意识形态镀金：首先是证明斯大林派的马克思主义诠释是马克思列宁主义理论的唯一范本，其次便将金日成主义称为朝鲜化的斯大林式马列主义。金日成本身也被冠以“我们时代最伟大的马列主义者”之名。然而到了20世纪80年代，一切都变了：主体思想已经找齐了属于自己的“专有名词”，终于得以同马列主义分道扬镳，从而自成一派。\n这些年来，金日成发表了大量有关主体思想的文章，最终形成了一个哲学体系。而身为他长子与继承人的金正日，则完成了他父亲的工作，得以将体系转为概括。在金正日于1982年所作的《论主体思想》一文中，他提出了主体思想的主要原则与相关推论。\n然而，并不是每个人都能接受这种明目张胆的意识形态修正：一些党员认为，主体思想充其量不过是一种有朝鲜民族特色的马列主义，而另一部分党员认为主体已经成为了某种逐步远离马克思主义基本原则的修正主义理论，同建立人民政府与反对传统主义、官僚主义的原则渐行渐远。而最激进的马克思主义哲学家则公开宣称主体思想就是种披着左翼外衣的儒家思想与韩国传统宗教天道教的大杂烩。\n那么，作为朝鲜民主主义人民共和国邻居与长期合作伙伴的我们，究竟该如何回应呢？"
const TXT_OPT0 := "为朝鲜同志在马克思主义观点上的新创见欢呼"
const TXT_OPT1 := "主体思想不过是一类修正主义变种，我们得给朝鲜点苦头尝尝"
const TXT_OPT2 := "对朝鲜用兵，推翻这一残暴的独裁政权（需要25.0点{2}）"
const TXT_OPT3 := "朝鲜已经不能被看作朋友，我们将增进同韩国的关系，他们是更好的生意伙伴"
const TXT_OPT4 := "以制裁威胁朝鲜当局放弃修正主义（需要10.0点{1}）"
const TXT_OPT5 := "我们怎么能干涉他国的内政？按兵不动"
const TXT_DIS_IDEOLOGY := "国家体制必须比社会民主主义更激进......"
const TXT_DIS_NO_ALLIANCE := "我们还没有属于自己的军事联盟......"
const TXT_DIS_NK_ALLIANCE := "朝鲜是我们的盟友！"
const TXT_DIS_ARMY := "军事实力必须高于{0}点......"
const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"
const TXT_DIS_NO_MOD := "没有修正效果“毛主义的壁垒”......"
const TXT_DIS_NOT_FACTION := "极左派并不是党内的主要派系......"
const TXT_DIS_DOCTRINE := "国内军事政策过于软弱......"
const TXT_DIS_GOV := "国家体制不是自由主义......"
const TXT_DIS_KOREA_TRADE := "我们已经与韩国建立了贸易关系......"
const TXT_DIS_ECON := "经济体制必须比“鸟笼经济”更自由......"
const TXT_DIS_GOV2 := "国家体制必须比邓式实用主义更自由......"
const TXT_DIS_SEV := "中国并不是经济互助委员会的成员......"
const TXT_DIS_SUB := "意识形态不是保守社会主义......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_R0 := "正如伟大领袖列宁同志所说：“条条大道通社会主义”。而主体思想，当然也只是根据该国环境产生的某类民族特色社会主义模式的变种而已，是适合该国文化、历史与风土人情的朝鲜化社会主义道路。所以，我们有必要谴责他们吗？我们也是走着同样的道路过来的！因此，我们热烈欢迎我们的朝鲜同志实现其发展的独立自主，创造了朝鲜马克思主义新境界。"
const TXT_R1 := "中华人民共和国领导层的官方声明如下：“主体思想并不是某种斯大林式的马列主义阐述，而是压制广大群众创造力的官僚主义修正理论。主体思想预设领袖的地位毋庸置疑，由此否定了党，乃至无产阶级的领导作用。从而用官僚专政取代无产阶级组织与无产阶级专政。主体思想不过是一种官僚主义反革命理论，同时也是实现资本主义完全复辟的前奏。出于捍卫国际社会主义运动的需要，我们必须不惜一切代价遏制朝鲜修正主义——包括对朝鲜实施外交与政治制裁，乃至推行封锁政策。除了隔离这种病毒外，我们别无选择。”"
const TXT_R2 := "中华人民共和国领导层对朝鲜问题的最后通牒如下：“主体思想并不是某种斯大林式的马列主义阐述，而是压制广大群众创造力的官僚主义修正理论。主体思想预设领袖的地位毋庸置疑，由此否定了党，乃至无产阶级的领导作用。从而用官僚专政取代无产阶级组织与无产阶级专政。主体思想不过是一种官僚主义反革命理论，同时也是实现资本主义完全复辟的前奏。主体思想不过是国家资本主义的一种表现型，并代表朝鲜的各类落后传统与封建资本主义势力的利益。为的就是便利朝鲜民主主义人民共和国的新资产阶级精英镇压朝鲜无产阶级，并加重对其的剥削。朝鲜资产阶级军政府定灭亡——我们将不惜一切代价保护我们的朝鲜无产阶级兄弟！”。随后，中国军队便跨过鸭绿江，对朝鲜进行军事干涉。"
const TXT_R3 := "在朝鲜的畸形斯大林主义政权垮台后，它最终转变为了一个野蛮的极权主义军政府。中国领导层明智地决定同已成为疯狗的金日成断交，并彻底改变以意识形态定亲疏的外交政策，转而以经济建设为中心。在公开谴责朝鲜政府后，中国当局开始直接同韩国当局接触，交涉相当成功。其中最重要的成果当属韩国电子产品打开了前往中国的大门，中国得以用先进的外国电子技术武装其人民与产业。毫无疑问，这一互利互惠协定对韩国与中国都有利可图，并让“山姆大叔”感到欣慰。只有朝鲜独裁者对此表示不满。"
const TXT_R4 := "中华人民共和国在经互会的一次例会上做出如下声明：“主体思想并不是某种斯大林式的马列主义阐述，而是压制广大群众创造力的官僚主义修正理论。主体思想预设领袖的地位毋庸置疑，由此否定了党，乃至无产阶级的领导作用。从而用官僚专政取代无产阶级组织与无产阶级专政。主体思想不过是一种官僚主义反革命理论，同时也是实现资本主义完全复辟的前奏。出于捍卫国际社会主义运动的需要，我们必须不惜一切代价遏制朝鲜修正主义——包括对朝鲜实施外交与政治制裁，乃至推行封锁政策。因此，中方将与苏联，乃至经互会其他国家的一起举行特别会议。商讨相关事宜。”在经济互助委员会与国际组织的通力合作下，朝鲜领导层得以开展一场反对反革命势力的斗争。\n随后，金日成承认了朝鲜劳动党政治局常委吴振宇将军的思想错误，并将其开除出党。朝鲜对20世纪80年代的畸形政治路线进行了拨乱反正。而金正日也在前者的压力下，对自己所犯的错误进行了自我批评，同时离开了中央军事委员会，但他仍留在政治局、主席团与书记处内。\n总之，国际分析者将此次事件看作是北朝鲜当局试图收拢军事控制的失败，并在“中苏双方的联合施压下”，重回既定斯大林主义路线的标志。"
const TXT_R5 := "中国政府部门与媒体对朝鲜发生的事情不予置评。尽管欧洲哲学家已为此爆发了争论，但中国毕竟不是欧洲，而朝鲜又是中国的长期合作伙伴。所以，我们为什么要干涉主权国家的内政呢？"
const TXT_WAR_NAME := "中朝战争"
const TXT_WAR_ATT := "中国"
const TXT_WAR_DEF := "朝鲜"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var china := world.get_country_by_legacy_index(1)
	var nkorea := world.get_country_by_legacy_index(10)
	var skorea := world.get_country_by_legacy_index(46)
	var opt := event_def.options
	if _d(W.I_IDEOLOGY) < 4:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_DIS_IDEOLOGY)
	if _d(W.I_IDEOLOGY) < 4:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_DIS_IDEOLOGY)
	var mod6: bool = ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if china != null and (china.has_tag("okb") or china.has_tag("seato")) 			and nkorea != null and not nkorea.has_tag("okb") and _d(W.I_ARMY) >= 250 			and (mod6 and GameManager.is_faction_leading(0) or (china != null and china.government == 3)):
		_enable(opt[2], TXT_OPT2.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif china == null or (not china.has_tag("okb") and not china.has_tag("seato")):
		_disable(opt[2], TXT_DIS_NO_ALLIANCE)
	elif nkorea != null and nkorea.has_tag("okb"):
		_disable(opt[2], TXT_DIS_NK_ALLIANCE)
	elif _d(W.I_ARMY) < 250:
		_disable(opt[2], TXT_DIS_ARMY.format([25]))
	elif not mod6 or not GameManager.is_faction_leading(0):
		if not mod6:
			_disable(opt[2], TXT_DIS_NO_MOD)
		else:
			_disable(opt[2], TXT_DIS_NOT_FACTION)
	elif _d(W.I_MIL_DOCTRINE) >= 32 and china != null and china.government != 3:
		_disable(opt[2], TXT_DIS_DOCTRINE)
	else:
		_disable(opt[2], TXT_DIS_GOV)
	if skorea != null and not skorea.has_tag("对华贸易") and (_d(W.I_ECON_SYSTEM) > 13 or _d(W.I_IDEOLOGY) >= 4):
		_enable(opt[3], TXT_OPT3)
	elif skorea != null and skorea.has_tag("对华贸易"):
		_disable(opt[3], TXT_DIS_KOREA_TRADE)
	elif _d(W.I_ECON_SYSTEM) <= 13:
		_disable(opt[3], TXT_DIS_ECON)
	else:
		_disable(opt[3], TXT_DIS_GOV2)
	if china != null and china.has_tag("sev") and _d(W.I_AGENTS) >= 100:
		_enable(opt[4], TXT_OPT4.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif china == null or not china.has_tag("sev"):
		_disable(opt[4], TXT_DIS_SEV)
	elif china != null and china.sub_government != 16:
		_disable(opt[4], TXT_DIS_SUB)
	else:
		_disable(opt[4], TXT_DIS_AGENTS.format([15]))
	_enable(opt[5], TXT_OPT5)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nkorea := ws.get_country_by_legacy_index(10)
	if nkorea != null:
		nkorea.government = 0
		nkorea.sub_government = 10
	if GameManager.is_faction_leading(0):
		_add(W.I_PARTY_SUPPORT, 100)
	else:
		_add(W.I_PARTY_SUPPORT, -200)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_DIPLO, 50)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == 0:
					pol.loyalty -= 250
				elif pol != null and pol.trait_personality > 1:
					pol.loyalty -= 200
		1:
			context["result_text"] = TXT_R1
			if GameManager.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, 300)
			else:
				_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_DIPLO, -30)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, 50)
			if nkorea != null:
				nkorea.set_tag("对华贸易", false)
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == 0:
					pol.loyalty += 50
				elif pol != null and pol.trait_personality == 1:
					pol.loyalty += 200
				elif pol != null:
					pol.loyalty -= 50
		2:
			context["result_text"] = TXT_R2
			var num := 0
			if ws.get_flag("guns"):
				num += 100
			_add(W.I_DIPLO, 70)
			_add(W.I_PARTY_SUPPORT, -300)
			ws.influence_prc -= 100
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, -250)
			if nkorea != null:
				nkorea.set_tag("对华贸易", false)
			_add_power(EmpireData.USSR, 20)
			if nkorea != null:
				_establish_government(nkorea, "prosov")
				nkorea.influence_nato = 1
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == 0:
					pol.power += 300
					pol.loyalty += 250
				elif pol != null and pol.trait_personality == 1:
					pol.loyalty += 250
				elif pol != null:
					pol.loyalty -= 100
			_start_war_378(700 - num, 300 + num)
		3:
			context["result_text"] = TXT_R3
			if GameManager.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, -300)
			elif GameManager.is_faction_leading(1):
				_add(W.I_PARTY_SUPPORT, 50)
			else:
				_add(W.I_PARTY_SUPPORT, 200)
			_add(W.I_DIPLO, -70)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -100)
			if skorea_country() != null:
				skorea_country().set_tag("对华贸易", true)
			_add(W.I_SCIENCE, 1000)
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == 0:
					pol.power -= 500
				elif pol != null and pol.trait_personality == 1:
					pol.loyalty -= 100
				elif pol != null:
					pol.loyalty += 100
		4:
			context["result_text"] = TXT_R4
			if nkorea != null:
				nkorea.government = 1
				nkorea.sub_government = 1
				nkorea.set_tag("sev", true)
			_add(W.I_DIPLO, -20)
			_add_relation(EmpireData.USSR, 100)
			if GameManager.is_faction_leading(0):
				_add(W.I_PARTY_SUPPORT, -300)
			elif GameManager.is_faction_leading(1):
				_add(W.I_PARTY_SUPPORT, 50)
			else:
				_add(W.I_PARTY_SUPPORT, 200)
			for pol in ws.politicians:
				if pol != null and pol.trait_personality == 0:
					pol.power -= 150
				elif pol != null and pol.trait_personality == 1:
					pol.loyalty += 100
		_:
			context["result_text"] = TXT_R5


func skorea_country() -> CountryData:
	return ws.get_country_by_legacy_index(46)


func _start_war_378(infl1: int, infl2: int) -> void:
	GameManager.start_war(16, TXT_WAR_ATT, TXT_WAR_DEF, infl1, infl2, -1, 1)
	if ws.wars.size() > 16 and ws.wars[16] != null:
		ws.wars[16].name_war = TXT_WAR_NAME
		ws.wars[16].fortnight_max = 40


func _establish_government(c: CountryData, kind: String) -> void:
	if kind == "prosov":
		c.set_tag("亲中", false)
		c.set_tag("亲苏", true)
		c.set_tag("亲美", false)


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
