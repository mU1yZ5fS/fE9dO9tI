extends "res://数据脚本/event_script_base.gd"

## 原作 Event577.cs：美国南方邻居的危机（墨西哥，六选项含一个恒禁用）。
## 触发：ReqEventForDLC02.cs:794-797 —— (日>=30 且 月>=1 且 年>=1982) || (月>=2 且 年>=1982) || 年>=1983
##   → DATE_AFTER 1982.1.30。
## 差异：
##  - 选项显隐 prepare 动态改写；proprc → 亲中；influencePRC → ws.influence_prc；
##  - data[31] → W.I_WAR_SUPPORT；data[12]? 无（581 用）；cw → 内战中；
##  - 结果前全局 c140.gov=3/sub=12 对所有结果生效。

const TXT_TITLE := "美国南方邻居的危机"

const TXT_DESC := "主席同志！来自墨西哥合众国的紧急消息。因为国际石油危机和墨西哥工业化政策的弊端。墨西哥经济已经进入了一个相当危险的局面，大规模的失业以及饥饿问题开始困扰墨西哥。并且，毒品卡特尔正在迅速崛起…目前，以何塞·洛佩斯·波蒂略·帕切科总统为首的革命制度党建制派计划开展对国内私人银行的全面国有化以及开始引入国际货币基金组织和其他金融组织的资金以拯救这个高原国家…众所周知，墨西哥革命制度党（PRI）政府在过去数十年建立了一个“党国社团主义”国家。现在，这个被誉为“完美独裁”的地方已经暴露了他们色厉内荏，统治衰弱的真实面目。据悉，哈佛大学的毕业生，年富力强的米格尔·德拉马德里将被波蒂略总统任命为下一任的墨西哥总统，他极有可能开始逆转历届革命制度党政府执行的“革命民族主义”政策。这是极为不利于国际反帝反霸事业的。或者，我们可以押宝革命制度党政府的党内反对派，它由德高望重的墨西哥前总统拉萨罗·卡德纳斯的儿子，夸乌特莫克·卡德纳斯所领导，他们是革命制度党的民粹主义左派。又或者支持体制外有实力的反对党—国家行动党（PAN）.只要我们承担一部分的墨西哥债务。再者，我们可以开始支持墨西哥的真正左派力量——欧洲共产主义的墨西哥统一社会党或者一支城市和农村的游击队，这是我党在拉美地区进一步发展影响力的绝佳机会。又或者，我们可以设法与墨西哥的极右翼取得联系，他们曾经代表了极右翼的辛那其主义者（虽然现在只是一个小小的墨西哥右翼政党），但是，这些干涉真的有必要吗？我们有必要冒着干涉他国内政的指控以及激怒美国的风险去干涉美国的南方邻居吗？"

const TXT_OPT0 := "让我们支持墨西哥真正的同志们"
const TXT_OPT0_DIS := "天堂离墨西哥太远，美国离墨西哥太近"
const TXT_OPT1 := "押宝墨西哥的温和左翼反对派和革命制度党的“民主潮流派”"
const TXT_OPT1_DIS_68 := "68年奥运会上是谁对那些手无寸铁的贫民和学生挥舞屠刀？"
const TXT_OPT1_DIS_POP := "我们不需要一个民粹主义的墨西哥……"
const TXT_OPT2 := "让我们支持PAN和其他温和的右翼反对派，为了人权与正义"
const TXT_OPT2_DIS_NO := "最好不要支持一群“无意愿之人”"
const TXT_OPT2_DIS_CANT := "我们办不到啊……"
const TXT_OPT3 := "让我们支持“懂农民先生们”，他们似乎比左派更值得投资"
const TXT_OPT3_DIS := "我们不能干涉其他国家的内政……"
const TXT_OPT4 := "静观其变"
const TXT_OPT5 := "和墨西哥的毒品卡特尔开展合作？你想退休了？"

const TXT_R0 := "我们决定从政党和游击队两方面入手。出于聚拢弱小的革命派力量的需要，我们决定向各个派别发出邀请。在我们的协调下，亲苏的墨西哥统一社会党（USPM）、霍查派的墨西哥共产党（马列主义）和托派的工人革命党等共产党得到了一大笔来自中国武器援助和情报支持；与此同时，我们也依托于前民族解放军（FLN）和九月二十三日共产主义联盟等左翼游击队将肮脏战争中受到沉重打击的革命派组织起来，成功地重组了毛主义的墨西哥无产阶级革命党【（PRPM）该党派曾在70年代于我国接受过训练】。在我们的牵线搭桥下，这些组织建立了一个新的一个伞式组织——墨西哥人民革命联盟，联盟内各派拥有的武装被统一为人民革命军。在几次协调和磋商行动后，萨帕塔地区的原住民运动也加入了这个左翼联盟。在我们设法“说服”了联盟的妥协派后，人民革命军开始了大规模的游击活动，烈度远远超过了70年代。在成功袭击墨西哥国家石油公司的管道后，南部邻国的动荡使得他们北边的邻居不满，华府公开谴责墨西哥的游击队是“恐怖分子”。墨西哥陆军和联邦安全局认为：游击队正在成长为一支正规军。美国再度开始介入墨西哥——在CIA的直接援助下，新的肮脏战争就要爆发了……"
const TXT_R1_A := "趁着革命制度党政府焦头烂额之际，中国的援助和特勤很快注入了墨西哥统一社会党（USPM），以及革命制度党当中的民粹主义左派。并迅速“制造”了一批墨西哥左翼反对派。在我们的帮助下，在墨西哥城和部分州首府爆发了罢工和游行，在国安局特工的协调下，民主潮流派迅速从革命制度党中分离出来，同温和左翼反对派组成了全国民主阵线。与此同时，一些墨西哥当局在秃鹰行动中的丑闻也不知从何处泄露了出来。这对墨西哥革命制度党中的主流保守派和墨西哥社会造成了前所未有的冲击。"
const TXT_R1_MANY := "幸亏我们早有准备，80年代在拉美出现了一批左派执政的国家。面对来自国内外日益增长的反对压力，墨西哥政府不得不屈服于前所未有的大规模罢工风险。墨西哥军队和警察也日益不满低薪，开始出现士气低迷和公开抗命。很快，在一系列磋商和谈判后，革命制度党政府决定进一步放权，比卡洛斯·马德拉索所提出的更加全面的选举改革法案获得了通过。新自由主义改革停止了。中国承担了墨西哥一部分债务，提供了一批技术援助并同墨西哥签订了一些贸易合同，两国的交往更深了，这些被认为是埃切维利亚外交政策的延续。预计在1988年的大选中，左派将被提名为总统候选人……"
const TXT_R1_FEW := "尽管得到了墨西哥社会绝大多数人的支持，但是左翼反对党仍然无法得到任何一个墨西哥城市的议员席位，很快，墨西哥城和州首府的罢工被墨西哥政府联合美国情报部门强力镇压了，暴力表现得比起1968年的镇压更加残忍和广泛。当然，对于墨西哥政府来说，这只不过是多了几个类似70年代埃切维利亚政府建立的拘留营地罢了，但是事实上，成千上万的无辜贫民被拷打和迫害——以打击毒品卡特尔的名义……"
const TXT_R2 := "蒙特雷市的工业家们早就不满意于革命制度党的“左倾政策”，波蒂略政府的银行国有化政策成为了压倒工业家所剩无几的忠诚的稻草。资金注入了更加行动党和其他自由主义反对派，同时，我们也设法利用了墨西哥政府中传统技术官僚与新生代财经官僚之间的冲突，得以在革命制度党中制造分裂。在国际货币基金组织和美国愈发强大的压力下，革命制度党最终屈服于新自由主义改革的愿景。利用经济混乱和民生下降的时机，PAN开始大规模的活跃并组织示威，革命制度党的警察部队也愈发难以遏制失控的局势。在蒙特雷，工业家的抗议超过了埃切维利亚政府时期的烈度，甚至连和政府长期合作的实用派企业家都开始不满于革命制度党的控制……面对大规模资本外逃了来自中美的压力，大规模的政治让步发生在了墨西哥。中国和美国均承担了墨西哥一部分债务，提供了一批技术援助并同墨西哥签订了一些贸易合同，两国的交往更深了。预计在1988年的大选中，国家行动党将被允许提名总统候选人……\n美国对南方邻居发生的事情感到高兴，华盛顿明确的表示愿意于墨西哥政府开展大规模的合作。"
const TXT_R3 := "趁着革命制度党政府焦头烂额之际，中国的援助和特勤很快注入了国家行动党（PAN）的强硬派，促使和墨西哥天主教会与如墨西哥民主党一类的极右翼组织形成影子联盟——他们都普遍具有辛纳其主义背景。在国际货币基金组织和美国愈发强大的压力下，革命制度党最终屈服于新自由主义改革的愿景。利用经济混乱和民生下降的时机，PAN开始大规模的活跃并组织示威，革命制度党的警察部队也愈发难以遏制失控的局势。在巨大的压力下，德拉马德里说服党内同僚，开始通过了一些允许由反对派担任地方职务的法案，并增加反对党的议员席位数目。当然，革命制度党预计将仍然保持一段时间的权力……然而，我们也注意到美国对于墨西哥的政治让步显得比以往热心更少，华盛顿只是冷淡的“表达对局势的关切”……也许我们骗不过雄鹰。"
const TXT_R4 := "在国际货币基金组织和美国愈发强大的压力下，革命制度党最终屈服于新自由主义改革的愿景。很快，米格尔·德拉马德里成为了新任的墨西哥总统。他很快开始提拔革命制度党中那些新自由主义改革派（例如卡洛斯·萨利纳斯——这位前革命制度的党大员的儿子，他是德拉马德里的哈佛同学）。进一步放权国内的商业集团并与国内反对派开始了一些极为有限的让步。很快，革命制度党本就有限的改良完全停止了，预计墨西哥向自由民主政治的转型将不可避免的充满暴力……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var num := _count_proprc(world)
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if line == 0 and num > 4 and world.influence_prc >= 800:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 1 and line <= 2 and world.influence_prc >= 500:
		_enable(opt[1], TXT_OPT1)
	elif line == 0:
		_disable(opt[1], TXT_OPT1_DIS_68)
	else:
		_disable(opt[1], TXT_OPT1_DIS_POP)
	if line == 3 and china != null and china.has_tag("seato") and world.empires.size() > EmpireData.USA \
			and world.empires[EmpireData.USA] != null and world.empires[EmpireData.USA].relations >= 800:
		_enable(opt[2], TXT_OPT2)
	elif line < 3:
		_disable(opt[2], TXT_OPT2_DIS_NO)
	else:
		_disable(opt[2], TXT_OPT2_DIS_CANT)
	if data.size() > W.I_WAR_SUPPORT and data[W.I_WAR_SUPPORT] >= 700:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], TXT_OPT4)
	_disable(opt[5], TXT_OPT5)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c140 := ws.get_country_by_legacy_index(140)
	if c140 != null:
		c140.government = 3
		c140.sub_government = 12
	var num := _count_proprc(ws)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -100)
			context["result_text"] = TXT_R0
		1:
			var text := TXT_R1_A
			if num > 4:
				text += TXT_R1_MANY
				if c140 != null:
					c140.内战中 = true
			else:
				text += TXT_R1_FEW
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -100)
			context["result_text"] = text
		2:
			if c140 != null:
				c140.内战中 = true
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			context["result_text"] = TXT_R2
		3:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			context["result_text"] = TXT_R3
		4:
			context["result_text"] = TXT_R4
		5:
			context["result_text"] = TXT_OPT5


func _count_proprc(world: WorldState) -> int:
	var num := 0
	for i in range(71, 84):
		var c := world.get_country_by_legacy_index(i)
		if c != null and c.has_tag("亲中"):
			num += 1
	for j in range(138, 150):
		if j == 145:
			continue
		var c := world.get_country_by_legacy_index(j)
		if c != null and c.has_tag("亲中"):
			num += 1
	return num
