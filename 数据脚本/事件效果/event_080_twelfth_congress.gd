extends "res://数据脚本/event_script_base.gd"

## 原作 Event80.cs：中共十二大（modifies[3] 双分支 + 常规三分支，超大事件）。
## 触发：event_080_trigger.gd（TimeScript.cs:10637-10650 两条 OR 分支）。
## 差异记录：
##  - modifies[3] 激活分支：2 选项；常规分支：3 选项。prepare 动态替换 options。
##  - num 计分逐项移植（TimeScript.cs:10719-10844 同款国家检查）。
##  - 原版 LeaderAsset / MoneyLevel / ServeRMB / doctr[] / party_change[]
##    为显示或建模说明字段，跳过；数值效果全部保留。
##  - result0（极左派胜利）的领袖轮换：leader ↔ politics[2] 逐字段交换，
##    faction_leader[0]=1，随后原版 KillPerson(2)（同序保留）。
##  - result2 新政治家姓名取自 polit_names1/2_en.txt：乔石/李锐/刘宾雁/鲍彤。

const TXT_DESC_MOD3 := "按照惯例，第十二届中国共产党全国代表大会在首都人民大会堂如期召开，代表我国社会各界的一千多名代表将齐聚会堂，共同商定影响我国历史进程的重要决议。这是自毛主席去世以后，我国人民坚定走主席革命路线的第六个年头。在会堂的发言台前，祖国又将面对命运的十字路口。\n在过去的六年里，极左派与保守派虽曾结成亲密的同盟，一同粉碎了改革派军事阴谋集团的政变企图，但在之后的相处中，两派面对内外局势与政策制定的看法日趋分裂，日常会议时两派的冲突逐渐频繁，极左派激烈的指责保守派面对革命高潮时的懦弱，保守派则以稳定为名不断的为极左派的激进政策添堵……党内存在路线分歧的暗示性信息已经出现在了部分报纸与宣传媒体上，“二帝共治”的局面显然已无法维持。如今虽然华国锋仍占据着中国头面领袖的身份，但曾经略显弱小的极左派经过六年的发展在党政军各界都积累了强大的力量，代表他们意志的王洪文副主席在行事风格上日渐独立，他在一些场合上与华国锋中央舆论风口明显不合的发言无一不显示出极左派已经有了挑战华国锋领袖权威的能力。\n无论曾经有过多么亲密的合作，代表两条不同路线的旗帜终究无法共同升起，可历史的车轮终将前进，在巨大的毛主席挂像的注视下，毛泽东的门徒们将在发言台前结束最后的争斗…"

const TXT_DESC_NORMAL := "不论如何，我党十一届六中全会的决定都已通过官方表态的方式对过往的各种问题“揭了盖子”，那么接下来的行动不过是在不同程度上确认我们的“修正”态度而已：中国共产党第十二届全国代表大会即将在北京的人民大会堂隆重召开，期间出席正式代表1545人，候补代表149人。代表全国3965万多名党员。考虑到其设计的常规议程平平无奇，这正是我党领导核心向全国公开自身政治立场，并落实自身政治新方案的大好时机。如果我们想的话，本次会议当然可以作为清算往日领导人毛泽东与其政治资产的极佳舞台：苏联前领导人尼基塔·赫鲁晓夫就是以类似的方式痛击了国内的斯大林主义政治势力，并坚决地启动了社会解冻与经济改革计划。当然，如此激烈的割舍必然在全党全国产生激烈震荡：毕竟，各位老大家都干了不是吗？当然，我们也可以选择相对迂回的方式解决这些问题：要么通过党内思想的“最新发展成就”另起炉灶，小心翼翼地放下并边缘化毛泽东思想；要么则没必要搭理上述问题，让一切发展如常，并用未来的政治实践告诉人民我们的真正目标。不论如何，决定权在您。"

const TXT_R_MOD3_0 := "如今国内外无产阶级斗争的局势较毛主席刚去世时已经有了空前的发展，无产阶级文化大革命进入新的高潮，全世界人民积极响应我国的号召，各人民民主政权一个接一个成立。此正当中流击水之势，华国锋中央举棋不定踌躇不前的政策早已引起了革命群众的极大不满。在十二大会议上，极左派成员激烈的发表了对华国锋各方面批评，指责他无视革命群众诉求，对无产阶级专政理论认识不清，缺乏无产阶级国际主义思想等；来自社会各界的群众代表也从这几年来遇到的实际问题出发，含沙射影的指责华国锋执政不力……而华国锋本人面对大会上对他的大量指责，只能奉上几句苍白的辩解和不断的清空他桌上的水杯。\n而轮到王洪文发表讲话时，几乎全会场的成员都为他献上热烈的掌声，在讲话中，王洪文热情的赞扬了全国人民的革命激情，并表示“中国人民的革命事业要排除万难，从胜利走向胜利。”，在他大声呐喊“伟大光荣的中国人民万岁”时，如雷鸣般的掌声将大会的氛围带向高潮，就连华国锋也在一旁不情愿的鼓掌，在这之后，各式各样的口号响彻会场持续了有整整五分钟，以至于台上领导不得不停下维持秩序。而在这些口号中，不乏有“坚决拥护王洪文同志”这类的话语……\n面对此景，华国锋深知自己败局已定，同时也在各方面的施压下，华国锋在后续会议里进行了自我批评并向大会宣布了自己的辞呈，辞呈毫不意外的以绝对优势票数通过了，这也意味着他将正式退出中国的政治舞台，而王洪文也在人民的欢呼声中坐上了第一把交椅。\n华国锋最终在全党人员的陪同下慢步走出大会堂，面对国内外媒体他表示“很高兴中央能通过我的请求……中国应该由更年轻更有志向的人领导……”但当他坐上离开中南海的轿车时，人们仍从挡风玻璃外看到了他眼神中的一丝落寞。\n而现在，中国将和世界一起向更美好的未来进发！"

const TXT_R_MOD3_1 := "很显然，这几年来极左派的所作所为并没有给整个国家带来一丝正面的因素，反而还使我们陷入了社会不稳，党内相互征伐的混乱。为了祖国的稳定与长治久安，是时候让极左分子夹紧尾巴做人了。\n在党的十二大会议期间，极左派仍与其他党员嘴上官司不断，极左派领袖上台发言期间，会场总是时不时陷入混乱以至于发言者不得不一再停下维持会场秩序。大会轮到华国锋发言后，他不紧不慢的走到演讲台前，面对台下党员困惑的眼神，华国锋强调要维护国家的稳定并表示“安定团结是毛主席生前的指示，是我国稳定发展的保证。”之后他开始了对极左派的攻击，指责他们大搞宗派主义，无视党内民主，在群众革命问题上无视纪律等，极左派面对华国锋突然的指责显得不知所措，王洪文等极左代表只能尴尬的默认，只有江青一类的激进分子当场起身大声反驳，但他们很快就 被更大的嘘声击退。最终在华国锋坚定的说出“伟大光荣正确的中国共产党万岁！”时，如雷般的掌声将大会气氛送上高潮，极左派成员只能低头灰溜溜的走出会场，华国锋背靠长椅，享受他的胜利时刻。\n在之后的职位选举时，虽然作为极左派代表的几位成员依然稳握权力，但影响力早已大不如前，同时还有大量的极左派成员在这次被踢出了党的高层圈子，这一切无一不显示出极左派在这次斗争中的失败，这也让部分人开始担心文化大革命的前途……\n如今，华国锋彻底巩固了自己的中央领导核心地位，他将坚持毛主席过去的方针，把社会主义祖国建设的蒸蒸日上。"

const TXT_R0 := "中国共产党第十二届全国代表大会将以“团结，胜利的大会”之名载入史册。一如彼时苏联召开的联共（布）第十八次代表大会那般。全党全军团结在{0}同志周围，决心在继承毛泽东思想伟大旗帜的基础上继往开来开创新事业。{0}同志在会议期间尤其强调要在坚持社会主义主旋律的基础上“防左反右”，并对1979年推出的“四项基本原则”（即必须坚持社会主义道路；必须坚持无产阶级专政；必须坚持中国共产党的领导与必须坚持马列主义、毛泽东思想）故事重提。接下来则是适当调整《中国共产党章程》并改革党务制度：我党将废除党主席职务，独设总书记，并为主要政治领导职务引入任期与退休制度。多少展现了新人治下的新气象。预计大会将在此后顺利闭幕。"

const TXT_R1 := "面对即将到来的十二大，{0}决定精心设计政治议程，并以《关于建国以来党的若干历史问题的决议》其中的精神与强调集体领导方式的态度为大会主旋律提纲挈领：同以往的会议相比，十二大会场场景布置上有了变化。撤掉了此前的领袖画像，改为悬挂镰刀锤头组成的巨大党徽，在两侧十面红旗的映衬下，庄严隆重，朴素大方。而其探讨的内容更是在党史上开创了多项“第一”：其中最瞩目的当属{0}同志在开幕式上做出的铿锵有力论断——“把马克思主义的普遍真理同我国的具体实际结合起来，走自己的道路，建设有中国特色的社会主义，这就是我们总结长期历史经验得出的基本结论”。随后其政治盟友的《全面开创社会主义现代化建设的新局面》与新版《中国共产党章程》等文件背书只会进一步巩固其立场，并将标榜“除旧布新，生机盎然”的“中国特色社会主义”给逐渐推上前台，作为新时代的指导思想。接下来则是将支持革故鼎新的一批政治新人与才俊推上前台，修改党内领导体制并推进干部退休制度，以及建立囊括党内主要元老的“中央顾问委员会”监督国内改革与落实集体领导，实现多数人按规矩说了算。大会也就在一派胜利喜悦中顺利结束。此后便是思想宣传层面的善后工作：国内各大媒体一致减少了提及毛泽东的次数，后者在20世纪50年代后出版的文章与著作（如《论十大关系》、《关于国际共产主义运动总路线的论战》、民间自制的《毛泽东思想万岁》与所谓“红宝书”《毛泽东语录》）等逐渐从图书馆中下架，并被要求停止再版。同时，由于考虑到“毛主席在建国时期提出的思想仍需实践检验其正确性”，中央编译局推出新版《毛泽东选集》的计划也被无限期搁置，对《毛选》第五卷的印刷工作已经停止。各地高校内的毛泽东思想课程也已被扩容为毛泽东思想-中国特色社会主义思想政治课，对毛泽东的论述仅集中在革命战争时期。虽说毛泽东没有遭遇类似斯大林时代大多数“老布尔什维克”的命运，并从中国和中国共产党的历史中彻底消失；且中国的党政机器仍旧在相当程度上保留了对他的尊重，对其进行批评的行为依然可能招致官司与行政处罚上身。可他的地位已同弗拉基米尔·列宁在苏联扮演的角色无异——“只属于过去，不属于未来；活在历史内，死在现实中；既是伟大的国父，也是无害的偶像；总之和孙中山一样，是党最好的政治木偶”——仅此而已。"

const TXT_R2 := "面对即将到来的十二大，{0}决定精心设计政治议程，并以苏共二十大为蓝本安排了接下来的政治议程：即首先是通过新版《中国共产党章程》，改革党务制度与确认国家未来的经济、社会发展规划等方式夯实基础，在“炮打司令部”前将去毛泽东化的主要工作落入实际当中。接下来便是在会议的最后一天放出猛料：{0}要求代表们留下来参加秘密会议，并在全场沉默中宣读了自己与{1}等同志共同操刀的新报告《关于迷信文化与其历史后果》。毫不留情地炮打以毛泽东为代表的人民共和国开国元勋与包括绝大多数“老干部”在内的头面人物们，他们被控犯有下述六大罪行：利用中国文化糟粕与王侯将相观培植个人崇拜；以人治、政治恐怖与军事专制手段取代法制与民主，消灭了以刘少奇、彭德怀等为代表的诚实共产党人；在民族问题上奉行实质上大汉族主义，造成了内蒙古惨案与西北地区的饥荒、叛逃与民族文化灭绝等一系列问题；在国内政策上也摒弃实事求是，滥用家长制、终身制、委任制等手段并架空党内会议；在经济与外交内大搞教条主义、山头主义与闭关锁国思维；以及在反右运动、四清运动与文化大革命内组织山头相互勾结，搞所谓“保皇派”、“造反派”、“林彪集团”或“四人帮”的方式争权夺利并肉体消灭反对派。《历史后果》一文将上述现象的根源归结于党内受早期军事斗争习气与封建社会余毒影响而形成的官本位与媚上思维，缺乏自我纠错的健康力量，这才导致了所谓的“毛泽东时代政治恐怖”。由此，绝大多数曾同毛泽东共事并默许其行为的老牌党员都应当“自觉承担责任”。代表们情绪低落，毫无讨论地接受了报告。接下来便是全国各地党组织由此陷入震惊和拒斥，以及随之而来的大规模政治清洗——党内左派与老干部的社会基础同时惨遭打击。如此激烈的改组自然导致了空前的社会动荡：数以百万计的不满者开始抵制我们拆除毛泽东与“老革命”纪念碑，发表“黑材料”，以及下架前者相关作品与传记的举动；以湖南、江西、陕西为代表的老牌苏区已开始组织游行示威抗议这一行动；西方的毛派运动也一个接一个地谴责起我们“重蹈赫鲁晓夫主义覆辙”并“背叛革命事业”。我们试图刮骨疗毒的尝试使得党在国内外地位都受到严重损害，只有美苏两大国对此颇为乐见。如果有人企图发动政变，没有意识形态支持的党内保守派阵营显然不会为你辩护。"

static var _opts_full: Array[EventOption] = []


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	if _opts_full.is_empty():
		for o in event_def.options:
			_opts_full.append(o)
	var mod3 := _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION)
	if mod3:
		event_def.description = TXT_DESC_MOD3
		var arr_mod3: Array[EventOption] = []
		arr_mod3.append(_opts_full[0])
		arr_mod3.append(_opts_full[1])
		event_def.options = arr_mod3
		var num := _compute_num(world)
		var data_mod3 := world
		var line_mod3 := data_mod3.get_data_by_index(W.I_POLITICAL_LINE) if data_mod3.size() > W.I_POLITICAL_LINE else 1
		var living := data_mod3.get_data_by_index(W.I_LIVING) if data_mod3.size() > W.I_LIVING else 0
		var flag := line_mod3 < 1 and living >= 500 and world.influence_prc >= 500 and num >= 15
		if flag:
			_enable(event_def.options[0], "中国人民的革命事业要排除万难，从胜利走向胜利！")
			_disable(event_def.options[1], "革命气势已经不可阻挡！")
		else:
			_disable(event_def.options[0], "革命引擎缺乏动力……")
			_enable(event_def.options[1], "党的团结是我国稳定发展的保证……")
		return
	var arr: Array[EventOption] = []
	for o in _opts_full:
		arr.append(o)
	event_def.options = arr
	event_def.description = TXT_DESC_NORMAL
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var left_party := party < 8
	var opt := event_def.options
	if (line < 3 and left_party) or (coal > 66 and party > 7):
		_enable(opt[0], "没必要徒增麻烦，会议应照常进行")
	else:
		_disable(opt[0], "如果我们不打算在会议期间讨论真正要紧的问题，那为什么还要开会？")
	if (line > 0 and left_party) or party > 7:
		_enable(opt[1], "我们将在“中国特色社会主义”的旗下对毛主席做扬弃，并靠不争论的方式确立新思维的霸权")
	else:
		_disable(opt[1], "不争不行——党和人民需要一个足够清晰的表态！")
	if (line > 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[2], "不破不立，我们怎么就摸不着赫鲁晓夫过河？")
	else:
		_disable(opt[2], "你疯了吗！上一个中国版赫鲁晓夫还尸骨未寒呢？！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var mod3 := _mod_active(ws, GameConstants.Modifier.CULTURAL_REVOLUTION)
	var opt := int(context.get("option_index", -1))
	var leader_name := _leader_name(ws)
	if mod3:
		if opt == 0:
			_result_mod3_0(context)
		elif opt == 1:
			_result_mod3_1(context)
		return
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_DIPLO, 5)
			_add_relation(EmpireData.USA, -50)
			context["result_text"] = TXT_R0.replace("{0}", leader_name)
		1:
			_add(W.I_PARTY_SUPPORT, 80)
			ws.influence_prc -= 10
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_DIPLO, -20)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_MANPOWER, -80)
			_set_modifier(6, false)
			# doctr[] 显示名：Godot 建模说明，跳过
			_set_data(W.I_MAO_HISTORY_LINE, 1)
			if ws.factions.size() > 1:
				ws.factions[1].ideology = int(ws.factions[1].ideology * 0.95)
			if ws.factions.size() > 0:
				ws.factions[0].ideology = int(ws.factions[0].ideology * 0.9)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 200
			context["result_text"] = TXT_R1.replace("{0}", leader_name)
		2:
			_result_mod3_false_2(context, leader_name)


func _result_mod3_0(context: Dictionary) -> void:
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_THOUGHT_FREEDOM, -100)
	_add(W.I_DIPLO, 100)
	# LeaderAsset / MoneyLevel / ServeRMB：显示字段建模说明，跳过
	if ws.modifiers.size() > 65 and ws.modifiers[65] != null:
		ws.modifiers[65].is_active = false
	_swap_leader_with_politician(2)
	if ws.factions.size() > 0:
		ws.factions[0].leader_index = 1
	PoliticianSystem.kill_politician(2)
	for i in [1, 3, 4]:
		if i < ws.politicians.size() and ws.politicians[i] != null:
			ws.politicians[i].power += 500
	for p in ws.politicians:
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty += 200
			p.power += 100
		if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 100
			p.power += 80
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty -= 100
			p.power -= 100
		elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
			p.loyalty -= 100
	if ws.factions.size() > 3:
		ws.factions[3].ideology = int(ws.factions[3].ideology * 0.85)
	context["result_text"] = TXT_R_MOD3_0


func _result_mod3_1(context: Dictionary) -> void:
	_add(W.I_PARTY_SUPPORT, 150)
	_add(W.I_PEOPLE_SUPPORT, 150)
	_add(W.I_THOUGHT_FREEDOM, 100)
	_add(W.I_DIPLO, -10)
	for p in ws.politicians:
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 300
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty += 150
		elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
			p.loyalty += 150
		elif p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
			p.loyalty += 150
	_set_modifier(3, false)
	PoliticianSystem.kill_politician(1)
	PoliticianSystem.kill_politician(2)
	for i in [3, 4]:
		if i < ws.politicians.size() and ws.politicians[i] != null:
			ws.politicians[i].power -= 100
	if ws.politics_positions.size() > 2 and ws.politics_positions[2] < 100 \
			and ws.politics_positions[2] >= 0 \
			and ws.politics_positions[2] < ws.politicians.size():
		var pol: PoliticianData = ws.politicians[ws.politics_positions[2]]
		if pol != null:
			pol.loyalty -= 200
	context["result_text"] = TXT_R_MOD3_1


func _result_mod3_false_2(context: Dictionary, leader_name: String) -> void:
	_add(W.I_PARTY_SUPPORT, -500)
	_add(W.I_PEOPLE_SUPPORT, -500)
	_add(W.I_THOUGHT_FREEDOM, 250)
	_add(W.I_DIPLO, -100)
	ws.influence_prc -= 150
	_add_relation(EmpireData.USA, 300)
	_add(W.I_MANPOWER, -450)
	_add(W.I_THOUGHT_FREEDOM, 400)
	_add_relation(EmpireData.USSR, 300)
	_set_modifier(6, false)
	for pair in [[0, 0], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
			[8, 8], [9, 9], [10, 10], [11, 11], [13, 13], [16, 16], [27, 48]]:
		var idx := _find_politician_by_names(pair[0], pair[1])
		if idx >= 0:
			PoliticianSystem.kill_politician(idx)
	_overwrite_new_politician(18, 61, 1924, 3, 21, 5, 14, "乔石")
	_overwrite_new_politician(21, 62, 1917, 3, 28, 30, 15, "李锐")
	_overwrite_new_politician(23, 63, 1925, 3, 26, 4, 31, "刘宾雁")
	_overwrite_new_politician(46, 64, 1932, 3, 21, 6, 11, "鲍彤")
	_set_data(W.I_MAO_HISTORY_LINE, 2)
	for p in ws.politicians:
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
			p.loyalty -= 600
			p.power -= 500
		elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
			p.loyalty -= 400
			p.power -= 500
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.loyalty -= 300
			p.power -= 500
		elif p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
			p.loyalty += 200
			p.power += 500
	var faction4_leader := -1
	if ws.factions.size() > 4:
		faction4_leader = ws.factions[4].leader_index
	var liberal_leader_name := _politician_display_name(faction4_leader)
	context["result_text"] = TXT_R2.replace("{0}", leader_name).replace("{1}", liberal_leader_name)


## TimeScript.cs 同款 num 计分（Event80 VariantsOfEvents modifies[3] 分支）。
func _compute_num(world: WorldState) -> int:
	var num := 0
	var c := world.get_country_by_legacy_index(2)
	if c != null:
		if c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 3
		if c.government == GameConstants.Government.SOCIALIST:
			num += 1
	c = world.get_country_by_legacy_index(19)
	if c != null:
		if c.sub_government == GameConstants.SubGovernment.MAOIST:
			num += 1
		if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 3
	for idx in [33, 11, 22, 47, 23]:
		c = world.get_country_by_legacy_index(idx)
		if c != null and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			num += 1
	for idx in [34, 8, 86]:
		c = world.get_country_by_legacy_index(idx)
		if c != null and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
			num += 2
	c = world.get_country_by_legacy_index(86)
	if c != null and c.has_tag("亲中"):
		num += 1
	c = world.get_country_by_legacy_index(87)
	if c != null:
		if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 1
		if c.has_tag("亲中"):
			num += 1
	c = world.get_country_by_legacy_index(12)
	if c != null:
		if c.has_tag("亲中"):
			num += 1
		if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 1
		if c.has_tag("亲苏"):
			num -= 1
		if c.sub_government == GameConstants.SubGovernment.MAOIST:
			num += 1
	c = world.get_country_by_legacy_index(44)
	if c != null and c.government == GameConstants.Government.SOCIALIST:
		num += 3
	c = world.get_country_by_legacy_index(12)
	if c != null and c.sub_government == GameConstants.SubGovernment.MAOIST:
		num += 2
	c = world.get_country_by_legacy_index(24)
	if c != null:
		if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
			num += 1
		if c.has_tag("亲中") and c.parts.size() > 0 and c.parts[0]:
			num += 2
	c = world.get_country_by_legacy_index(49)
	if c != null and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
		num += 1
	c = world.get_country_by_legacy_index(85)
	if c != null and (c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
		num += 3
	for idx in [74, 80, 35, 14, 104, 42, 50]:
		c = world.get_country_by_legacy_index(idx)
		if c != null and world.is_socialism(c, true):
			num += 1
	c = world.get_country_by_legacy_index(74)
	if c != null and world.is_socialism(c, true):
		num += 1  # 74 额外 +1（原版 +2 总计）
	c = world.get_country_by_legacy_index(10)
	if c != null and c.government != GameConstants.Government.SOCIALIST and c.sub_government != GameConstants.SubGovernment.LEFT_RADICAL:
		num -= 1
	c = world.get_country_by_legacy_index(20)
	if c == null or not c.has_tag("亲中"):
		num -= 1
	if world.size() > 185:
		if world.anthem_choice == 1:
			num -= 1
		elif world.anthem_choice == 3:
			num += 1
	return num


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total


func _mod_active(world: WorldState, index: int) -> bool:
	return index >= 0 and index < world.modifiers.size() \
		and world.modifiers[index] != null and world.modifiers[index].is_active


func _set_modifier(index: int, active: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active


func _swap_leader_with_politician(slot: int) -> void:
	if ws.leader == null or slot < 0 or slot >= ws.politicians.size():
		return
	var other: PoliticianData = ws.politicians[slot]
	if other == null:
		return
	PoliticianSystem.swap_leader_profile(ws.leader, other)


func _find_politician_by_names(name_first: int, name_last: int) -> int:
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p != null and p.name_first == name_first and p.name_last == name_last:
			return i
	return -1


## 最弱且 personality != 3 的槽位（原版循环逐字）。
func _weakest_not_personality(not_personality: int) -> int:
	var num := 0
	for i in ws.politicians.size():
		var p: PoliticianData = ws.politicians[i]
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		var base: PoliticianData = ws.politicians[num]
		if base == null:
			num = i
			continue
		if p.power < base.power and p.trait_personality != not_personality:
			num = i
	return num


func _overwrite_new_politician(
		name_first: int, name_last: int, birth_year: int,
		personality: int, background: int, alignment: int, special: int,
		display_name: String
) -> void:
	var idx := _weakest_not_personality(3)
	if idx < 0 or idx >= ws.politicians.size():
		return
	# 防重名：若该历史人物已由预备池/其它事件登场，不再重复覆写。
	for i in ws.politicians.size():
		if i == idx:
			continue
		var other: PoliticianData = ws.politicians[i]
		if other != null and not PoliticianSystem.is_vacant_politician(other) \
				and other.name_display == display_name:
			return
	var p: PoliticianData = ws.politicians[idx]
	if p == null:
		return
	var year := ws.date.year if ws.date != null else 1982
	p.name_display = display_name
	p.name_first = name_first
	p.name_last = name_last
	p.age = maxi(0, year - birth_year)
	p.trait_personality = personality
	p.trait_background = background
	p.trait_alignment = alignment
	p.trait_special = special
	p.power = 800
	p.loyalty = 800
	p.portrait = null
	p.is_historical = false
	p.faction = -1
	p.faction = PoliticianSystem.trait_faction_slot(p)


func _politician_display_name(idx: int) -> String:
	if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
			and ws.politicians[idx].name_display != "":
		return ws.politicians[idx].name_display
	return "自由派领袖"




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)




func _leader_name(world: WorldState) -> String:
	if world.leader != null and world.leader.name_display != "":
		return world.leader.name_display
	return "华国锋"
