extends "res://数据脚本/event_script_base.gd"

## 原作 Event393.cs：历史性妥协（意大利“民族团结”政府，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（见 event_435 约定）；
##  - 原版 iron_and_blood 成就 Set(121) 已接 Achievements。

const TXT_DIS1A := "我们可没处插手……"
const TXT_DIS1B := "绝不同陶里亚蒂的徒子徒孙同流合污！"
const TXT_DIS2 := "没必要竹篮打水"
const TXT_R0 := "经历了漫长且复杂的谈判，最终意大利共产党得以同天主教民主党达成如下共识：仅容纳上述两党的法定多数政府“民族团结”得以成立，其领导人仍是能够在天民党各派中达成妥协的右翼人士，实用主义者朱利奥·安德烈奥蒂牵头。以此制衡主张实现对共产党立场替代的天民党左派与顽固拒绝一切妥协共治形式的极端人士。共产党人则拿下内务（显然顽固反共人士弗朗切斯科·科西加成为了妥协的牺牲品，然而从其手中接过大权，同样以自由派家庭背景与铁腕闻名的大鳄乔治·阿门多拉注定了原方针将以修正形式延续）、“南方基金”不管部长（皮奥·拉托雷）、预算与经济计划部（乔瓦尼·贝林格）、劳动与社保（卢西亚诺·拉玛）、文化（乔瓦尼·切尔维蒂）、教育（吉安·卡洛·帕杰塔）等职位。其他职务则由天民党一手包揽。显然，新政府的内部构成在相当程度上参考了战后初年阿尔契德·加斯贝利时代，左右团结尚存时的联合政府设计思路（即左翼政党包揽经济岗位，右翼政党则关注于权力“杠杆”——同东欧人民民主政权的早期形式“相映成趣”），并在考量两大党利益的情况下进行改造。虽说仍存在些许技术层面的细小问题，超级大国借助意大利国内政党施加域外干涉的可能，以及有关政治巨头垄断国内议程的指责。可所有的一切在天民党与共产党共同掌握全国过半选票，近乎边缘化所有中间派与极端势力的事实面前已不再重要，昔日的掣肘成了如今巩固政权的最大助力。新时代至此来临——不过，这一联盟真的能够成为名副其实的“民族团结”纽带吗？让我们拭目以待……"
const TXT_R1 := "考虑到意大利共产党是该国唯一有实力，有资格在革新该国政治的同时实现国际关系民主化，并有利于我国实现外交突围的政党。我们很快便对帕尔米罗·陶里亚蒂主张的国际共运多中心论故事重提，并接住了毛时代因唯意志论实践而抛弃的橄榄枝。不久后，我方便在罗马尼亚同志的斡旋下同意共实现关系正常化，随后达成的政治担保协定（即我党将同苏共国际部一般，无条件为意共提供支撑其社区建设与参与选战的必须资金；并暗示一旦意共入阁，中方便会立即同相关背景部长商谈多边合作事宜，以亮眼政绩巩固1976年内的选战成绩）让恩里科·贝林格与其盟友有了充分底气，这自然便转化为议会协商期间更为激进的立场。当然，其中亦有打入意共队伍的我方同志，以及受我国资金赞助下说客的推波助澜作用。根据意共提出的新方案，为保证“民族团结”政府能在充分代表民意同时的兼具革新之感，将部长会议主席一职扩充为部长会议，设置若干参会者（其中自然包括非天民党成员，用意不言自明）共同主持会议，实现国家内多头共治格局的做法便势在必行。部分激进派更是呼吁在投票结束后立即讨论总统问题，计划将意共的选战明星乔治·阿门多拉推上前台。考虑到意共从来都是属于党生活者，党的整体利益同全体成员高度一致的团体，意共党内的几乎派别自然而然地达成了共识——“要么在‘民族团结’中分得足够大的蛋糕，要么就没必要费力支持这个瘸腿政府”。而这恰触及“民族团结”政府议题内最敏感的领导权问题，“历史性妥协”得以实现的前提，并最终击穿天民党所能接受的底线。终于，双方在会议上的当仁不让，唇枪舌战最终只是导致朱利奥·安德烈奥蒂的“弃权政府”（1976年诞生，彼时共产党、社会党等主要政党对此投了弃权票，最终造成其只是个不稳定且缺合法性的单色少数派政府）得以痛苦续命，以及共产党态度的转折——意识到已无可能实现“历史性妥协”，恩里科·贝林格转而押注“民主替代”新路线。尝试让共产党同该国活跃的激进派与进步主义运动小党在即将到来的新一轮大选中组成新多数。正如天民党先前实践的“中左翼公式”般。而我们的资金恰恰能使其先人一步……于是新一轮拉锯战开始了……"
const TXT_R2 := "我们决定借题发挥，将尚未成形的“历史性妥协”预案变为让两大党重燃纷争的金苹果：通过70年代的外交成果，具有中方背景的企业与得到北京赞助的游说势力借助“商贸合作”之名轻易深入天主教民主党主导的单色治理格局中，并顺藤摸瓜找上该党内对意大利共产党崛起颇为忌惮的巨头们。表示“左右共治”格局不仅将使天民党自绝于欧洲——美国对“妥协”的敌意并非秘密，而苏联亦不会因共产党走入政府而对其网开一面；至于我们，当他们得到破坏“妥协”的暗示时，这一话题便无需再提；更会成为刺激共产党野心进一步膨胀，乃至再版“人民民主”故事的割肉饲鹰之举。很快，我们便完成了对天民党党内派系“民主倡议”（主张按照“国父”阿尔契德·加斯贝利的“亲西、反共、改革”既定方针办）；“多罗西亚”（社会保守主义与天主教权威拥护者，自“历史性妥协”诞生便坚定站在反对派角度抨击这种“绥靖”）和“新力量”——（得到亲天主教工会运动意大利工会联合会支持的党内左翼，因同共产党共享社会基础而形成强烈竞争关系）的思想工作，更将其撮合为一个反对“历史性妥协”的临时性联盟。后者将在不久后证明自身的价值：也就在议会表决的关键时刻，“新力量”派领导人卡洛·多纳特-卡廷迅速带动其控制的左翼派阀对天民党领导层发难，要求在新政府名单更有利于天民党一方（如必须确保对天民党对国家安全机构的垄断，并在经济领域内实现“共同审计”）而这恰是崩溃的开端。通过变节者与意大利国内其他党派（意大利社会党、意大利共和党等角色对共产党的敌意并非秘密）的合力，试图组建“民族团结”政府的计划终究是在议会流产，并被酝酿中的非共产主义“大联盟”政府取而代之。当然，如此方案只是意味着天民党改变了其妥协对象，并回到了一个更缺乏群众基础的共治形式而已。意识到已无可能实现“历史性妥协”，恩里科·贝林格转而押注“民主替代”新路线。尝试让共产党同该国活跃的激进派与进步主义运动小党在即将到来的新一轮大选中组成新多数。而共产党内的激进派亦对这一结果大为愤慨，部分地区甚至出现了支部独走，以多起游行示威的形式抗议天民党霸权的事件——显然在新一轮全国选举到来前，天民党政府注定不会有好日子过……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if _d(W.I_POLITICAL_LINE) >= 2 and _d(W.I_POLITICAL_LINE) <= 3 and world.influence_prc >= 250 			and _d(W.I_COMMUNICATIONS) >= 100:
		_enable(opt[1], event_def.options[1].text)
	elif world.influence_prc < 250 or _d(W.I_COMMUNICATIONS) < 100:
		_disable(opt[1], TXT_DIS1A)
	else:
		_disable(opt[1], TXT_DIS1B)
	var italy := world.get_country_by_legacy_index(85)
	if _d(W.I_POLITICAL_LINE) <= 2 and italy != null and (italy.内战中 or italy.政变中):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_DIS2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	# 原作 Event393.cs:54：ResultsOfEvents 开头 iron_and_blood → achievements.Set(121)
	Achievements.set_achievement(121)
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add_power(EmpireData.USA, -15)
			_add_power(EmpireData.USSR, -15)
			if portugal != null:
				portugal.special += 10
			if italy != null:
				italy.sub_government = GameConstants.SubGovernment.LIBERAL
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -50)
			_add(175, -1)  # 原版 data[175]
			_add(176, 1)   # 原版 data[176]
			_add_power(EmpireData.USA, -15)
			_add_power(EmpireData.USSR, -15)
			if portugal != null:
				portugal.special += 10
			if italy != null:
				italy.sub_government = GameConstants.SubGovernment.LIBERAL
		_:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -60)
			_add(W.I_AGENTS, -60)
			_add(173, 1)   # 原版 data[173]
			_add(175, -1)  # 原版 data[175]
			_add(176, -1)  # 原版 data[176]
			if italy != null:
				italy.level_of_development -= 5
			_add_power(EmpireData.USA, -15)
			_add_power(EmpireData.USSR, -15)
			if portugal != null:
				portugal.special += 10
			if italy != null:
				italy.sub_government = GameConstants.SubGovernment.LIBERAL




func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0





