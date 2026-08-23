## 原作 Event293.cs：和平长入社会主义：第一幕（意大利共产党上台，五选项）。
## 触发：全目录搜索无 this_num_event = 293 / Reset(293)；链外 REST 段，原版无自动条件。
## 差异：result0/1 的 {0}{1} 插入领袖姓名（name_display）；science[19]→techs.unlocked[19]；
##  is_party_enabled[0]→factions[0].is_enabled；empires[1].leaders[6].support 按原样。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT0_DIS := "我们怎能支持陶里亚蒂的徒子徒孙？！"
const TXT_OPT1_DIS := "只要意共不迷途知返，我们绝不会停印《意共反华言论选》！"
const TXT_OPT2_DIS := "和超级大国狼狈为奸？你要背叛和平共处五项原则！"
const TXT_OPT3_DIS := "我们没法指望在意大利发动一场革命"
const TXT_OPT1_DIS_A := "只要意共不迷途知返，我们绝不会停印《意共反华言论选》！"
const TXT_OPT1_DIS_B := "意共拒绝将自己的社会主义同极权主义等量齐观"
const TXT_OPT2_DIS_A := "和超级大国狼狈为奸？你要背叛和平共处五项原则！"
const TXT_OPT2_DIS_B := "上下不一的情况下，不可能有革命！"
const TXT_R0 := "我们对欧洲首个民选共产主义大国的诞生乐见其成，并相信这足以成为推进国际关系民主化的重要契机。毕竟，只要抛开意识形态问题不谈，国际社会内中间力量的扩大只会有助于以我国为代表的第三世界阵营。为此，外联部同志们大力促成了恩里科·贝林格总理的访华计划，并让这位预备将罗马变为“共产主义新罗马”的新教宗对我国留下了深刻印象。其中尤以{0}{1}同志亲自向其传授的“中国式四个现代化”与“三个世界”理论令其印象深刻。对话最后以贝林格称：“你我之间的观点有许多共同之处啊！真是相见恨晚！如此观之！其实，我们意共早就是中国人了！”与{0}{1}同志的回应：“不！没有你们意共率先挑战莫斯科权威，中国人民就不能紧随其后掀起大论战，中华人民共和国就不能摆脱苏联路线。走自己的路，建设有中国特色的社会主义。所以，陶里亚蒂对我们是一个很好的教员，也是你们的教员”的双方趣味调侃结束。随后则是中意就经济，军事方面达成的一揽子合作协定与意共在会议后的果断行动——新兴力量的背书得以使其果断实施欧洲共产主义纲领：累进税与工人强制持股得以确立，亲政府的大型企业内形成公私合营，主张警察抢先自卫的《皇家法》被公投完全废除，持有左翼倾向的自管社会中心亦开始接受国家补贴，并开始排挤同生态位的极端主义者。试图以意大利总工会为核心形成劳动战线一致的协商计划亦已启动，以重塑劳动纪律，形成多边共识。试图革新政治生态的反腐调查也随之步入深水区，包括贝蒂诺·克拉克西、朱利奥·安德烈奥蒂等在内的政治红人皆被发现同商界势力，甚至同黑手党有染的蛛丝马迹。即便此类信息的揭露还仅停留在传言水准，尚未形成系统证据链。且在意共掌权的背景下显得如此“巧合”，可终归是让该国的老牌政党们颜面无光，并进一步巩固了意共作为自诩革新民主派的清白。总的来说，意大利目前正迈入发展正道，两国之间的合作前景广阔。"
const TXT_R1 := "我们对革新社会主义在欧洲的首次胜利乐见其成，并相信这足以作为推进国内改革事业的外来活水。考虑到教条主义分子仍在党内占据相当相当分量，思想解放与改革事业仍裹足不前。我们有必要好好请外来的和尚来念念经：为此，外联部同志们大力促成了恩里科·贝林格总书记的访华计划，并让这位预备将罗马变为“共产主义新罗马”的新教宗对我党留下了深刻印象。其中尤以{0}{1}同志亲自勾勒的“中国特色社会主义”蓝图与“实事求是”理论令其印象深刻。对话最后以贝林格的感慨：“{0}{1}的态度相当诚恳，同小学生般不耻下问，谦卑好学。在如此领袖领导下的大党，怎不可能领导中国从胜利走向新胜利呢”与{0}{1}同志口中“世界在变化，我们的思想和行动也要随之而变。过去把自己封闭起来，自我孤立，这对社会主义有什么好处呢？历史在前进，我们却停滞不前，就落后了。拿我党来说，四十年代在思想方面与意共差距也不是那么大。但是我们封闭了三十年，没有把革新意识形态摆在议事日程上，而意共却在这个期间变成了国际思想潮流引领者”的痛定思痛反思结束。此后便是中意两党间关系的突飞猛进：陶里亚蒂的“构造改革”理论、贝林格主张“宗教同社会主义适应”，“同资产阶级实现历史性妥协”的社会和解思想与作为意共官方意识形态，主张坚决捍卫国家统一、主权完整与社会民主，坚决反对法西斯独裁专政的“葛兰西理论”等悉数引进我国，部分原则开始被应用至抓纲治党内。党内生活开始在陶里亚蒂时代卓有成效的“不换思想就换人”方法下快速实现民主化，自由化。一批批改革闯将悉数就位，以往的死气沉沉得以一扫而空。与此同时，同我党的合作也让意共得以取长补短——显然，干部名册制度与公务员体系给了其不小启发：国家补贴持续滋养着意共议员们，而他们基本上是清一色社会改良主义者……"
const TXT_R2 := "意识到一个“欧洲共产主义”国家实体的诞生极有可能导致现代改良主义倾向的死灰复燃，并最终威胁共产党作为阶级政党的革命性质。我们决定联合苏联共同采取果断措施。考虑到苏东社会主义阵营对西欧式修正主义倾向的高度警惕，且对一切试图在国际共产主义运动内另立山头尝试的敌意并非秘密。相关方案很快便得到批准：具体措施无非是意大利“铅色岁月”与1977年马德里三方会谈时期策略的再版——国安同志们很快便加入到了克格勃、史塔西与捷克斯洛伐克国家安全局的情报网络内共谋生计，不仅找上了以阿曼多·科苏塔为代表，坚决反对“历史性妥协”并捍卫社会主义阵营内部团结的意大利共产党保守派；更利用意共目前力行的反腐政策顺水推舟，以“阻挠正义实现”、“暗中接受政治献金”等丑闻直接将矛头指向该党的改良主义者：作为“改进派”新星，批判司法部门越来越像往日少数派政府时期专断，甚至大有转化为最高苏维埃之势的乔治·纳波利塔诺很快便成为众矢之的；如安东内洛·特龙巴多里这般暗地同情意大利社会党事业的两面派人士亦被视为“对党和国家不诚实”，“试图发展政治裙带”而被边缘化；与此同时，有关意共党魁恩里科·贝林格在故乡萨丁岛经营巨额地产，以及利用特权为多家建筑公司招标开后门的消息亦开始传开。即便此类信息的揭露还仅停留在传言水准，尚未形成系统证据链。可终究是让自诩将担起革新政坛大任的意共颜面无光。对此，该党领导层不得不援引自我批评并进行洗牌，将那些尚未卷入不利传言的人士带入核心领导层。而这些清一色保守派更是导致了连锁反应：对阶级斗争理论的部分重提使得意大利旧知识分子选民同党分道扬镳，为此不得不靠拢激进学生进行替代；与此同时，针对亲共工会组织意大利总工会同企业间达成秘密协定的丑闻亦开始发酵，并开始动摇起这一依赖总工会内在编工人支持政党的基础建制。这导致意共不得不采取更为传统，将组织重任委以其基层组织内活动家的做法——在企业家意识到调和体系崩溃，和意共合作已无收益的背景下；押注边缘工人成为了自然而然的选择。而这也为强硬派共产党人与逐步脱离恐怖活动，回归合法范畴的极左翼人士们提供了发展便利。意共党内的健康力量正逐步站稳脚跟，而我们则乐见与此。"
const TXT_R3 := "显然，意大利共产党目前推进的政治议程充分暴露了其“假革命，真建制”的丑陋面目。对此，我们还有什么可说的呢？博洛尼亚地区由工人主义者主导的自管社会中心已准备接收新一批物资支持，为保卫社区生活与扩充势力范围蓄势；以“红色旅”为代表的城市游击队亦开始鸟枪换炮，以绑架案与袭警持续挑衅意共政府权威。社会气氛的骤然升温导致恩里科·贝林格不得不选择逐步叫停试图“正常化”局势的民主改革方案，并将安全重任委以卡宾枪骑兵与同为共产党成员的司法部长上。与此同时，对意共重要群众组织意大利总工会的破坏工作正如火如荼推进：工会官僚作为在编工人代理，同企业主单独议价的体制注定不会合乎激进派共产主义者与非职业工人的口味。这便为自发斗争、野猫罢工与双重工会主义的发展创造了机遇：只需要一点火花，“火热之秋”时代学生与工人共斗的风景便会轻易重演。极左翼准工会组织与政治团体如雨后春笋般涌现，并持续滋养着该国的议会外激进派。然而局势并非一片大好。倘若它们仍保持碎片化状态并安于各自为战的现状，那么激进主义者注定不可能提出系统性替代议程。而这种拉锯只会导致一种僵局——即意共只会在保卫民族国家的口号下事实上冻结所有政治改革方案，变为纯粹建制派；而议会外激进派也只能作为不可能执政的在野党充当起安保体制的“合理性”补充。最终的结果便是左翼阵营的普遍冷却与“回归日常”的潮流泛起（而这恰是“1977年运动”后得到国家机器鼓励的新一波潮流：要求公民放弃一切宏大叙事与社会运动，安心退回个人生活并享受现代消费主义）。希望我们能赶在一切无可挽回前完成早该降临的革命。"
const TXT_R4 := "恩里科·贝林格发起的“复兴运动”仍在掌控之中，至少目前尚未出现足以挑战这位意大利国家新教宗的敌人：不只是美国对贝林格的“北大西洋公约亦可作为社会主义屏障”的甜枣表示满意，就连苏联的积极国际主义者亦视意大利的现状为机遇——考虑到贝林格尚未对叛逆的欧洲共产主义阵营计划故事重提，而该党同马克思主义意识形态的渊源尚在。依托国际联系实现转向亦非不可能之事。而意大利国内发生的一切亦井井有条：意识到意大利共产党比传统议会政党更能保证社会生活与经济生产秩序，并通过控制工人与学生运动把握激进主义的命脉。该国的企业家、中产阶级与旧式知识分子们很自然地抛弃了自己的原本选择，将更多关注予以共产党幕僚领导的“稳定高于一切”路径上。从而维系美妙的共治。可问题是，一旦共产党完成了健全意大利民主主义的中心任务，那失却核心竞争优势的它又将何去何从？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var china := world.get_country_by_legacy_index(1)
	var relres := world.get_flag("relres")
	var res65 := int(world.completed_event_ids.get("event_65", 0))
	var tech19 := world.techs != null and world.techs.unlocked.size() > 19 and world.techs.unlocked[19]
	var opt := event_def.options
	if line >= 1 and line <= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 3 and not world.is_socialism(china, true) and not world.is_authoritarian(china):
		_enable(opt[1], event_def.options[1].text)
	elif line < 3:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	if line <= 2 and relres and res65 != 2 and res65 != 3 and (_mod_active(GameConstants.Modifier.COOPERATE_WITH_STASI) or tech19):
		_enable(opt[2], event_def.options[2].text)
	elif line > 2:
		_disable(opt[2], TXT_OPT2_DIS_A)
	else:
		_disable(opt[2], TXT_OPT2_DIS_B)
	if line <= 1:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -20)
			_add(W.I_AGENTS, -20)
			_add(W.I_ARMY, -20)
			_add_relation(EmpireData.USSR, -100)
			_add_relation(EmpireData.USA, -100)
			if italy != null:
				italy.set_tag("对华贸易", true)
			_add(180, 2)
			_add(179, 1)
			if italy != null:
				italy.set_tag("亲美", false)
				italy.set_tag("eu", false)
				italy.government = GameConstants.Government.REFORMIST
				italy.sub_government = GameConstants.SubGovernment.EUROCOMMUNIST
			var t0 := _leader_name()
			context["result_text"] = TXT_R0.format([t0, ""])
		1:
			_add(W.I_BUDGET, -10)
			if ws.factions.size() > 0 and ws.factions[0] != null:
				ws.factions[0].is_enabled = false
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
					p.power += 200
				elif p.trait_personality == 4:
					p.power += 100
			_add(W.I_THOUGHT_FREEDOM, 100)
			if italy != null:
				italy.set_tag("对华贸易", true)
			_add(181, 2)
			var t1 := _leader_name()
			context["result_text"] = TXT_R1.format([t1, ""])
		2:
			_add(W.I_AGENTS, -60)
			_add_relation(EmpireData.USSR, 100)
			_add_relation(EmpireData.USA, -100)
			_add(180, -1)
			_add(181, -1)
			_add(178, 1)
			_add(182, 1)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].leaders.size() > 6:
				ws.empires[EmpireData.USSR].leaders[6].support -= 1
			context["result_text"] = TXT_R2
		3:
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -25)
			_add(W.I_ARMY, -25)
			if italy != null:
				italy.level_of_development -= 5
			_add(134, 10)
			_add(172, 1)
			_add(173, 1)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].leaders.size() > 6:
				ws.empires[EmpireData.USSR].leaders[6].support -= 1
			context["result_text"] = TXT_R3
		4:
			context["result_text"] = TXT_R4




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	PoliticianSystem.copy_leader_appearance(ws.leader, p)

