extends "res://数据脚本/event_script_base.gd"

## 原作 Event683.cs：落幕的选举（美国特别大选，六选项）。
## 触发：ReqEventForDLC02.cs:1254-1256 —— data[21]>=1985 && !c51.nato && !c0.eu
##   && (c44 亲中/亲苏) && (c140 亲中/亲苏 || (gov==2 && !亲美)) && (c101 亲中/亲苏) && !c131 亲美
##   → trigger_script evaluate。
## 差异：OAR→ws.oar；is_gkchp→get_flag("is_gkchp")；traits[0]→ws.leader.trait_personality；
##   isRIM→rim、isSocEU→soc_eu、Torg→对华贸易、cw→内战中；now_leader→current_leader。
## 注意：原版 option4 条件 data[8]+data[8]>=300 是双重预算加法的原作笔误，按字面移植（预算*2>=300）。
const TXT_TITLE := "落幕的选举"
const TXT_DESC_HEAD := "时代正巨变，即便是曾被视为不可动摇的建制派政治框架也开始动摇。北大西洋联盟与大西洋主义的崩溃只是开端，传统政客的外交失败与其引发的国内动荡已让美国人忍无可忍：这便为美国民粹主义运动崛起提供了空前便利。从洛杉矶骚乱到占领华尔街，乃至南方的暴动等运动层出不穷。各式边缘政治组织也得到了久违的支持——自70年代以来便持续萎靡的美国共产党甚至在短短数日迎来了堪比现存党员数的新成员申请函。也就在大规模群众集会的压力下，该国原总统不得不接受苦涩失败并最终退出政治舞台。美国即将召开特别大选，人们已踌躇满志与物色新任领导人。由于美国政治生态事实上走向碎片化，本次大选必然相当有趣，接下来，让我们瞧瞧候选人有哪些罢：|"
const TXT_DESC_BUSH := "吸取先前的失败经验，建制派决心将美国老战鹰，前中情局长，罗纳德·里根的代言人乔治·布什推选上台，决心彻底扭转导致美国霸权沦落的怀柔主义，并以军备扩张与新自由主义两手振兴美国战争与对外扩张机器。"
const TXT_DESC_DUKAKIS := "意识到新保守主义与传统鹰派外交已一败涂地，吸取先前的失败经验，建制派决心转向新政治明星，创造了“马萨诸塞奇迹”的希腊裔美国人迈克尔·杜卡基斯。期望以他的移民身份与治理奇迹重塑美国梦合法性。"
const TXT_DESC_TAIL := "接下来则是主要反建制派阵营的情况：由于建制派节节败退，以自由意志党为代表的老牌第三党得以发展壮大。自由意志党甚至吸纳了曾作为共和党议员的罗纳德·欧内斯特·保罗，试图将小政府主义、美国宪政理想与地方分权政策杂交一致。回归国父时代的“美国属于美洲”；不过，靠着类似立场吃饭的可不只有它们：美国的亿万富翁们也已开始寻求将财力与草根撮合一致的法子，让自身的政治方案登堂入室。改革运动已物色罗斯·佩罗作为其头面人物、并得到了唐纳德·特朗普等媒体大亨支持，预计将在美国刮起蓝领民粹旋风。当然，传统边缘派在这一议程内也未缺席。得到新一轮反建制运动加码的美国共产党又拿出了信心，其党魁格斯·霍尔打算将新老左翼撮合的计划故事重提。社会主义圈子则看准了佛蒙特州的老牌独立人士，支持斯堪的纳维亚社会主义的伯尼·桑德斯，并开始谋划组建首个容纳美国进步派与社会改良主义者的共治政府。|美国社会的局势只会持续沸腾，现在是时候让我们下注了！"
const TXT_OPT0 := "我们将支持建制派总统保障美国稳定！"
const TXT_OPT0_DIS := "我们为什么要拉老对手一把？"
const TXT_OPT1 := "我们将推进罗纳德·欧内斯特·保罗的新版新自由主义议程。"
const TXT_OPT1_DIS := "没必要选择最坏的资本主义"
const TXT_OPT2 := "我们将让罗斯·佩罗刮起人民资本主义旋风。"
const TXT_OPT2_DIS := "支持民粹主义者毫无意义"
const TXT_OPT3 := "我们将开创历史新篇，是时候选择伯尼·桑德斯了！"
const TXT_OPT3_DIS := "苹果派社会主义，让下一个厄尔·白劳德上位？"
const TXT_OPT4 := "我们没必要局限在上述选择内——为什么不直接培植一位中国代理人做总统呢？"
const TXT_OPT4_DIS := "我们余力不足"
const TXT_OPT5 := "静观其变"
const TXT_CAND_AVAKIAN := "我们很快便联系上了老朋友，美国革命共产党领导人鲍勃·阿瓦基安。阿瓦基安借20世纪60年代的美国新左翼之风与言论自由运动快速崛起，并通过筹建湾区革命联盟等举措迅速成为了该国最著名的毛主义活动家。此后，他更是与黑豹党等激进革命组织发展了令人深刻的关系。我们相信如今正是让他同著名黑人活动家休伊·牛顿一齐登上台前，大显身手，给美国人民看看什么是真正社会主义的时候。\n"
const TXT_CAND_NOVACK := "由于老牌托派组织社会主义工人党主要领导人杰克·巴恩斯、玛丽-爱丽丝·沃特斯等于20世纪80年代开始便逐步调转路线并疏远正统的托洛茨基主义立场。我们只能同那些与社工党的分道扬镳的托派组织（如社会主义行动与第四国际倾向）以及独立的民主社会主义圈子合作。将它们撮合起来可谓是一件难事，不过靠着人力密集型的方式，我们至少能让他们在选举期间发出革命社会主义者的声音。他们已将社会主义工人党内的老牌托派乔治·诺瓦克作为候选推上前台，并预备为该国带来社会革命。\n"
const TXT_CAND_HALL := "我们只得转向历史悠久的美国共产党及其领导人格斯·霍尔。霍尔自50年代开始便领导该党，延续了其前任领导人尤金·丹尼斯的对苏绝对忠诚路线。他在意识形态上则基本延用30年代共产党领导人厄尔·白劳德的“苹果派共产主义”（即共产主义是20世纪美国主义的社会爱国主义修辞）。通过苏联大使馆与古巴的联系，霍尔很快便收到了我们的支持，并准备再次同黑人民权新星安吉拉·戴维斯一同备战总统。\n"
const TXT_CAND_FONDA := "我们决定扶持反战民主人士，电影明星简·方达当选美国总统。靠着好莱坞内的打拼与在反战运动内的活跃表现，方达很快便以“河内的简”身份成为了彼时激进学生眼中的红人。她更是在70年代同学生活动家汤姆·海登强强联手，巩固了自身在青年内的人气。通过好莱坞的人脉，我们有潜力将方达同其伴侣海登塑造为新时代的“威廉玛丽”，并在美国预备一场光荣革命。\n"
const TXT_CAND_GRAVEL := "考虑到美国作为当代自由灯塔与民主国家表率的地位，其政治巨变必然引发多米诺骨牌效应。我们决定最大限度地把握机会，直面挑战：不仅要确保经典自由主义的系列原则不为民粹主义激进派所颠覆，从而终结美国的传统政治模式；更要在维系这一框架的同时为美国社会降温，并确保我国的利益得以贯彻。为此，我们找上了脾气火爆，年轻气盛的前民主党人麦克·葛拉威尔，并争取到了从共和党的叛逃的首位华裔美国议员邝友良与之陪跑：葛拉威尔不仅靠着反越战征兵与最早打出中美建交牌两项亮眼履历确立了自身的独到优势，更在政治纲领上同其他挑战者泾渭分明，形成了足够瞩目的另类选择。他们比罗纳德·保罗更重视社保与联邦团结，比罗斯·佩罗更关切社会价值观，比伯尼·桑德斯更坚守中道与自由原则。这就是我们与美国都应当拥有的黑马！现在就得看看我们的钱有没有花到刀刃上……\n"
const TXT_CAND_KIM := "也就在英明领袖华国锋同志的亲自过问下，我们决定让我国在美国境内的王牌线人，中央情报局内的工作人员金无怠同志接受最神圣，最重大，最光荣的使命——以“国家安全”与“首位华裔总统，开民族团结先例”两面大旗去竞选美国总统！毕竟，机不可失！失不再来！要么赢下一切！要么一无所有！在美情报网络与华人社区已开始全面运转，执行将“王牌鼹鼠”打入美国心脏的高级任务，代号“偷星换日”。\n"
const TXT_CAND_LAROUCHE := "我们决定推举著名阴谋论者林登·拉罗奇角逐美国总统职位。拉罗奇早年曾参与持托洛茨基主义立场的社会主义工人党，接受了马克思主义式的反资本主义理论训练，但在20世纪70年代开始发生转向。最终成为了具有美国特色的法西斯主义者——主张将罗斯福新政的国家干预原则，新保守主义的全球进攻政策与建立社会统制的方法实现统合。他的另类全球化与反苏立场足以成为我们利益的代言人。\n"
const TXT_WIN_BUSH := "最终，美国的政治惯性取得了胜利。建制派联合推选的共和党人乔治·布什取得了选战胜利。布什上任初承诺重振美国国防，批准新一批军事预算，并实行“重返欧洲”、“重返亚太”两个拳头打人的策略。国内政策也转向现代保守主义，期望以减税降费刺激国内企业发展，并通过减少福利支出方式填补预算亏空。可考虑到国家架构的建制派联盟性质——他所要面临的最大挑战显然是自己在议会内的“民主党同僚”……"
const TXT_WIN_DUKAKIS := "最终，美国的政治惯性取得了胜利。建制派联合推选的民主党人迈克尔·杜卡基斯取得了选战胜利。杜卡基斯上任初承诺将在全国大推“马萨诸塞经验”，并大力发展信息技术与现代服务业。国内政策也转向自由放任主义，期望以减税降费刺激国内企业发展，并通过减少对外干涉的支出方式填补预算亏空。可考虑到国家架构的建制派联盟性质——他所要面临的最大挑战显然是自己在议会内的“共和党同僚”……"
const TXT_WIN_PEROT := "祖宗之法胜利了！祖宗之法终结了！多亏了媒体大亨唐纳德·特朗普等的精心运作。改革党的罗斯·佩罗得以拿出电影般的攻势横扫各派并取得相对多数，形成了美国历史上首个统合商界精英与大众情绪的民粹主义政府。新政府开始削减军事开支，减少国际义务，将宏观调控转向扶持中小企业减税政策；并同时拿出了强硬的贸易保护主义——美国近乎偏执地拒绝了各种自由贸易协定，力行关税与进口替代政策以“重振美国制造”。日后更会向主宰美国的一系列基本构型发起挑战——世界上首个新保守主义政权就此诞生。"
const TXT_WIN_PAUL := "祖宗之法胜利了！祖宗之法终结了！自由意志党的罗纳德·欧内斯特·保罗最终以微弱优势取得相对多数，并击败诸候选人。罗纳德·保罗上任初便预备对“深层国家”开战：取消窃听、削弱联邦调查局与中央情报局权限、确保全体公民的宪法权利；下一步便是取消政治献金限制、开始赋权美国各州，并以“侵犯人权”之名肃清建制派内老油条与强硬保守主义者。政治的去管制与经济的去管制同步启动：警察与情报机构改组为德国联邦模式，国民警卫队也以开始效法南斯拉夫模式，如今人们将完全奉行“自食其力原则”（即社会服务自己购买，弱势群体自己供养，人身安全自我保卫——社会保障网络基本被社会保障市场取代）。美国的第二次革命开始了：旧政权就此终结，是时候改变了，有必要重建国父们的统治。"
const TXT_WIN_SANDERS := "祖宗之法终结了！美国社会主义者成功背靠国际支持与劳联-产联的联系网，形成了一个蓝领工人、进步派政客与温和社会主义者的联盟。让改良主义者伯尼·桑德斯当选美国总统！作为自诩的“民主社会主义者”，桑德斯政府决心致力于工厂民主、社会保障与提升工薪家庭收入，并在同时将全面医保、环境保护、发展合作社与确立工人持股纳入不久后的政治议程。为此，首先便是引入资本管制、设立财产限额、提升所得税与巨富税与废除外包制度。美国政治就此迎来了向欧洲社会民主主义模式的大转变，挪威与瑞典也多了个跨洋兄弟。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var desc := TXT_DESC_HEAD
	if usa != null and usa.current_leader == 3:
		desc += TXT_DESC_BUSH
	elif usa != null and (usa.current_leader == 0 or usa.current_leader == 2):
		desc += TXT_DESC_DUKAKIS
	desc += TXT_DESC_TAIL
	event_def.description = desc
	if event_def.options.size() < 6:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line > 2:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line == 4:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line > 1:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if line > 0 and line < 4:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	var china := ws.get_country_by_legacy_index(1)
	if (china == null or china.government != 3) and _res(W.I_BUDGET) * 2 >= 300 \
			and _res(W.I_AGENTS) >= 20:
		_enable(opt[4], TXT_OPT4)
	else:
		_disable(opt[4], TXT_OPT4_DIS)
	_enable(opt[5], TXT_OPT5)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var num := 0
	var num2 := 0
	var num3 := 0
	var num4 := 0
	var text := ""
	if opt == 0:
		_add(W.I_BUDGET, -150)
		_add(W.I_AGENTS, -150)
		num += 2
	elif opt == 1:
		_add(W.I_BUDGET, -150)
		_add(W.I_AGENTS, -150)
		num2 += 2
	elif opt == 2:
		_add(W.I_BUDGET, -150)
		_add(W.I_AGENTS, -150)
		num3 += 2
	elif opt == 3:
		_add(W.I_BUDGET, -150)
		_add(W.I_AGENTS, -150)
		num4 += 2
	elif opt == 4:
		_add(W.I_BUDGET, -300)
		_add(W.I_AGENTS, -200)
		ws.influence_prc += 50
		num += 1
		text += _candidate_text()
	var china := ws.get_country_by_legacy_index(1)
	var gdr := ws.get_country_by_legacy_index(7)
	var france := ws.get_country_by_legacy_index(21)
	var italy := ws.get_country_by_legacy_index(17)
	var spain := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(86)
	var sweden := ws.get_country_by_legacy_index(131)
	var indonesia := ws.get_country_by_legacy_index(135)
	var nigeria := ws.get_country_by_legacy_index(136)
	var west_germany := ws.get_country_by_legacy_index(15)
	var usa_country := ws.get_country_by_legacy_index(51)
	var japan := ws.get_country_by_legacy_index(140)
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	# num：建制派（原版顺序逐项）
	if gdr != null and gdr.has_tag("ovd"):
		num += 1
	if gdr != null and gdr.has_tag("sev"):
		num += 1
	if china != null and china.has_tag("econ"):
		num += 1
	if china != null and china.has_tag("okb"):
		num += 1
	if france != null and france.sub_government != 14 and ws.is_socialism(france, false):
		num += 1
	if indonesia != null and indonesia.government == 3:
		num += 1
	if nigeria != null and nigeria.government == 3:
		num += 1
	if france != null and (france.has_tag("fxseu") or france.has_tag("nazimao")) \
			or ws.get_flag("is_gkchp"):
		num += 999
	# num2：自由意志党/反建制
	if gdr == null or not gdr.has_tag("ovd"):
		num2 += 1
	if gdr == null or not gdr.has_tag("sev"):
		num2 += 1
	if china != null and china.has_tag("econ"):
		num2 -= 1
	if china != null and china.has_tag("okb"):
		num2 -= 1
	if ws.oar:
		num2 -= 1
	if ws.event_done_num(500):
		num2 -= 1
	if china != null and china.has_tag("rim") and _mod_active(3) and _mod_active(6) \
			and ws.is_socialism(china, true):
		num2 -= 1
	if china != null and china.government == 3:
		num2 += 1
	if west_germany != null and west_germany.内战中:
		num2 += 1
	if usa_country != null and usa_country.has_tag("对华贸易"):
		num2 += 1
	if ussr != null and ussr.current_leader == 6:
		num2 += 1
	# num3：民粹/改革党
	if ws.leader != null and ws.leader.trait_personality == 2:
		num3 += 1
	if _mod_active(39):
		num3 += 1
	if italy != null and italy.sub_government == 5:
		num3 += 1
	if france != null and (france.sub_government == 5 or france.sub_government == 20):
		num3 += 1
	if spain != null and spain.sub_government == 5:
		num3 += 1
	if china != null and china.government == 2:
		num3 += 1
	if indonesia != null and indonesia.sub_government == 8:
		num3 += 1
	if japan != null and (japan.sub_government == 7 or japan.government == 3):
		num3 += 1
	# num4：社会民主/桑德斯
	if italy != null and italy.government == 2:
		num4 += 1
	if france != null and france.government == 2:
		num4 += 1
	if portugal != null and portugal.government == 2:
		num4 += 1
	if ussr != null and ussr.current_leader == 8:
		num4 += 1
	if sweden != null and sweden.sub_government == 3:
		num4 += 1
	if spain != null and spain.has_tag("soc_eu"):
		num4 += 3
	# 胜负判定（原版 if/else 顺序与 tie-break 完全一致）
	if num >= num2 and num >= num3 and num >= num4:
		if usa != null and usa.current_leader == 3:
			text += TXT_WIN_BUSH
			usa.current_leader = 2
			if usa_country != null:
				usa_country.sub_government = 12
			context["result_text"] = text
			return
		text += TXT_WIN_DUKAKIS
		if usa != null:
			usa.current_leader = 4
		if usa_country != null:
			usa_country.sub_government = 6
		context["result_text"] = text
		return
	if num3 >= num2 and num3 >= num and num3 >= num4:
		text += TXT_WIN_PEROT
		if usa != null:
			usa.current_leader = 6
		if usa_country != null:
			usa_country.sub_government = 5
		context["result_text"] = text
		return
	if num2 >= num3 and num2 >= num and num2 >= num4:
		text += TXT_WIN_PAUL
		if usa != null:
			usa.current_leader = 5
		if usa_country != null:
			usa_country.sub_government = 12
		context["result_text"] = text
		return
	text += TXT_WIN_SANDERS
	if usa != null:
		usa.current_leader = 7
	if usa_country != null:
		usa_country.sub_government = 4
	context["result_text"] = text


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null:
		return false
	if world.数值表.size() > W.I_YEAR and world.数值表[W.I_YEAR] < 1985:
		return false
	var europe_union := world.get_country_by_legacy_index(0)
	var us := world.get_country_by_legacy_index(51)
	if us != null and us.has_tag("nato"):
		return false
	if europe_union != null and europe_union.has_tag("eu"):
		return false
	var denmark := world.get_country_by_legacy_index(44)
	var japan := world.get_country_by_legacy_index(140)
	var cuba := world.get_country_by_legacy_index(101)
	var sweden := world.get_country_by_legacy_index(131)
	if denmark == null or (not denmark.has_tag("亲中") and not denmark.has_tag("亲苏")):
		return false
	if japan == null or (not japan.has_tag("亲中") and not japan.has_tag("亲苏") \
			and not (japan.government == 2 and not japan.has_tag("亲美"))):
		return false
	if cuba == null or (not cuba.has_tag("亲中") and not cuba.has_tag("亲苏")):
		return false
	if sweden != null and sweden.has_tag("亲美"):
		return false
	return true


func _candidate_text() -> String:
	var china := ws.get_country_by_legacy_index(1)
	if ws.is_socialism(china, true) and ws.result_of_event_num(25) == 2 \
			and ws.result_of_event_num(26) == 2:
		return TXT_CAND_AVAKIAN
	if china != null and china.sub_government == 18:
		return TXT_CAND_NOVACK
	if ws.is_socialism(china, true):
		return TXT_CAND_HALL
	if china != null and china.government == 2:
		return TXT_CAND_FONDA
	if china != null and china.government == 3:
		return TXT_CAND_GRAVEL
	if china != null and china.sub_government == 19:
		return TXT_CAND_KIM
	return TXT_CAND_LAROUCHE


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active
