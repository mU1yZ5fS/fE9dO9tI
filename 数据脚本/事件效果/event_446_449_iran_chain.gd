extends "res://数据脚本/event_script_base.gd"

## 原作事件 446–449：伊朗革命后续事件链。
## 来源：Event446.cs / Event447.cs / Event448.cs / Event449.cs；
##       触发链 ReqEventsDLC02/ReqEventForDLC02.cs:357-367；
##       概览显示分支 modify_choose.cs:577-655（已由 概览.gd 实现，本脚本不改）。
##
## 触发关系：
##   446 伊朗法基赫监护（自动触发）
##   447 拯救伊朗大起义（PREV_EVENT_DONE 446 自动触发）
##   448 伊朗选举：涅槃？（447 result 0 且 data[45]<=300 时，由 .tres 的
##       TRIGGER_EVENT 效果在选项执行前入队，复刻原版 load_scene_after_click）
##   449 伊朗革命战争（PREV_EVENT_DONE 447 + PREV_EVENT_NOT_DONE 448 自动触发）
##
## 字段映射（Unity → Godot）：
##   allcountries[8]            → ws.get_country_by_legacy_index(8)
##   Gosstroy / SubGosstroy     → CountryData.government / sub_government
##   Vyshi / proprc / Torg / prosov → set_tag("亲美"/"亲中"/"对华贸易"/"亲苏")
##   data[45]                   → ws.数值表[W.I_IRAN_ISLAMIST_SUPPORT]
##   data[56]                   → ws.数值表[W.I_POLITICAL_LINE]
##   data[6/8/9/22]             → W.I_DIPLO / W.I_BUDGET / W.I_AGENTS / W.I_ARMY
##   influencePRC               → ws.influence_prc
##   ingamewars[33]             → ws.wars[33]（world_factory 已 resize 到 34）
##   ussr_place / usa_place     → WarData.ussr_side / usa_side
##   gameState.iranrev          → 无字段，暂用 ws.set_flag("iranrev", true) 表达
##   allcountries[8].prcpower   → CountryData.prc_power


## 447 选项 0 的原版 Destroy 按钮文案有两个分支：
##   influencePRC < 300 且 data[56] > 1 → “我们为什么要帮他们？”
##   influencePRC < 300 且 data[56] <= 1 → “他们不会信任我们的”
## .tres 只能存一个静态 disabled_text，因此在显示前按原版条件动态覆写。
func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def.event_id == "event_449":
		var iraq := p_ws.get_country_by_legacy_index(14)
		var arg := ""
		if iraq != null and iraq.puppet_of < 0:
			if iraq.sub_government == 10:
				arg = "以及对于萨达姆政权的犹豫不决，"
			elif iraq.sub_government == 15:
				arg = "以及对于伊拉克的复兴党政权的犹豫不决，"
			elif p_ws.is_socialism(iraq, true):
				arg = "以及对于伊拉克的“卡菲勒”政权的犹豫不决，"
		event_def.description = "由于伊朗总统阿布·哈桑·巴尼萨德尔在伊朗人质事件上有着比霍梅尼及其党徒更温和的立场，{0}加之对于神学家的传统立场，霍梅尼最终认定其“作为大地上的腐化者”而罢黜了他，转而让新伊斯兰共和党秘书、霍梅尼最得力的亲信之一——贝赫什蒂负责国内全权事务。革命卫队占领了总统府和花园，并查封了一家与巴尼萨德尔关系密切的报社。在接下来的几天里，他们处决了他几个最亲密的朋友，包括侯赛因·纳瓦布、拉希德·萨德罗赫法齐和马努切赫尔·马苏迪。阿亚图拉·侯赛因·阿里·蒙塔泽里是政府中为数不多的仍然支持巴尼萨德尔的人之一，但他很快就被剥夺了权力。大部分左派乐于看见自由主义的知识分子被霍梅尼清洗，因此初期大力支持霍梅尼的政策，人民党主席基亚努里甚至公然宣布自己永远忠诚于伊玛目的路线，他也是伊朗革命中少数没有被清算的左派。仅仅有少数左翼势力选择了作壁上观，不随便站队法基赫政权。“红色什叶派”早已在链接两个派别的桥梁——阿亚图拉·塔莱加尼病逝后就与霍梅尼主义者的关系不断恶化，最终以马苏德·拉贾维为首的人民圣战者也选择了和巴尼萨德尔一起出走。反对派的活动规模虽庞大，但仍缺乏统一领导。根据我们的信息，政府正准备严厉镇压反对派的活动。我们该怎么办？".replace("{0}", arg)
		return
	if event_def.event_id != "event_447":
		return

	if p_ws == null or event_def.options.is_empty():
		return
	if p_ws.influence_prc >= 300:
		return
	# Event447.cs:26-35
	var line: int = p_ws.数值表[W.I_POLITICAL_LINE] if p_ws.数值表.size() > W.I_POLITICAL_LINE else 0
	if line > 1:
		event_def.options[0].disabled_text = "我们为什么要帮他们？"
	else:
		event_def.options[0].disabled_text = "他们不会信任我们的"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"event_446":
			_event_446(option_index, context)
		"event_447":
			_event_447(option_index, context)
		"event_448":
			_event_448(option_index, context)
		"event_449":
			_event_449(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _iran() -> CountryData:
	return ws.get_country_by_legacy_index(8)


func _event_446(option_index: int, context: Dictionary) -> void:
	var iran := _iran()
	match option_index:
		0:
			# Event446.cs:58-64
			d[W.I_AGENTS] -= 50
			d[W.I_BUDGET] -= 50
			d[W.I_DIPLO] += 30
			ws.influence_prc -= 15
			if iran != null:
				iran.government = 0
				iran.sub_government = 20
			d[W.I_IRAN_ISLAMIST_SUPPORT] -= 100
			context["result_text"] = "在我方的支持下，以人民圣战者，伊朗共产主义者联盟，人民党左翼和“风暴”组织的成员形成了一支左翼同盟“伊朗爱国阵线”。这只组织开始着手训练其武装团体。同时，霍梅尼决定派出伊朗革命卫队前去镇压，大不里士西北的伊朗空军宣布支持人民。在双方紧张对峙之时，左派学生会产生了分裂，一部分机会主义者倒戈支持霍梅尼。随着革命卫队的坦克开进了大不里士，运动也渐渐消停。随后，大阿亚图拉沙里亚特马达里被软禁。伊朗的未来，似乎走向了一个不可控的地步……"
		1:
			# Event446.cs:70-76
			d[W.I_AGENTS] -= 100
			d[W.I_BUDGET] -= 100
			d[W.I_DIPLO] += 50
			ws.influence_prc += 80
			if iran != null:
				iran.government = 0
				iran.sub_government = 20
			d[W.I_IRAN_ISLAMIST_SUPPORT] -= 300
			context["result_text"] = "在我方的支持下，以人民圣战者，伊朗共产主义者联盟，人民党左翼和“风暴”组织的成员形成了一支左翼同盟“伊朗爱国阵线”。这支组织开始着手训练其武装团体。我们的特工决定为革命力量送上一份大礼，在伊朗线人的帮助下，我们的特勤人员找到了努尔丁的住所，用包在鲜花里的炸药将这个叛徒送去了马克思那里。余下的人民党宣布作为温和力量加入伊朗爱国阵线。同时，霍梅尼决定派出伊朗革命卫队前去镇压，大不里士西北的伊朗空军宣布支持人民。在双方紧张对峙之时，左翼阵线更加团结，学生们占领壁垒，拿上63式和40火，做出要和政府决一死战的地步。在极度的高压和多方势力的威胁下，伊朗政府宣布停止围攻大不里士，双方将对新宪法作出更多讨论。看起来，神也不过如此。"
		2:
			# Event446.cs:82-88
			d[W.I_AGENTS] -= 50
			d[W.I_BUDGET] -= 50
			d[W.I_DIPLO] += 30
			if iran != null:
				iran.government = 0
				iran.sub_government = 20
			ws.influence_prc += 30
			d[W.I_IRAN_ISLAMIST_SUPPORT] -= 200
			context["result_text"] = "我们的特工决定为伊朗人送上一份大礼，在伊朗线人的帮助下，我们的特勤人员找到了努尔丁的住所，用包在鲜花里的炸药将这个叛徒送去了马克思那里。同时，霍梅尼决定派出伊朗革命卫队前去镇压，大不里士西北的伊朗空军宣布支持人民。在双方紧张对峙之时，左派学生会产生了分裂，一部分机会主义者倒戈支持霍梅尼。随着革命卫队的坦克开进了大不里士，运动也渐渐消停。随后，大阿亚图拉沙里亚特马达里被软禁。伊朗的未来，似乎走向了一个不可控的地步……"
		3:
			# Event446.cs:94-96
			d[W.I_DIPLO] -= 50
			if iran != null:
				iran.government = 0
				iran.sub_government = 20
			context["result_text"] = "“我国不会允许这种对人民开火的暴行，”外交部长" + _foreign_minister_name() + "同志如是说道，“但同时，我们也呼吁伊朗方面冷静下来，不要在自己人身上浪费弹药，让伊朗人的子弹去杀伊朗人！”但霍梅尼显然没有听我们的，他决定派出伊朗革命卫队前去镇压，大不里士西北的伊朗空军宣布支持人民。在双方紧张对峙之时，左派学生会产生了分裂，一部分机会主义者倒戈支持霍梅尼。随着革命卫队的坦克开进了大不里士，运动也渐渐消停。随后，大阿亚图拉沙里亚特马达里被软禁。伊朗的未来，似乎走向了一个不可控的地步……"
		4:
			# Event446.cs:102-103
			if iran != null:
				iran.government = 0
				iran.sub_government = 20
			context["result_text"] = "霍梅尼决定派出伊朗革命卫队前去镇压，大不里士西北的伊朗空军宣布支持人民。在双方紧张对峙之时，左派学生会产生了分裂，一部分机会主义者倒戈支持霍梅尼。随着革命卫队的坦克开进了大不里士，运动也渐渐消停。随后，大阿亚图拉沙里亚特马达里被软禁。伊朗的未来，似乎走向了一个不可控的地步……我也希望，我们的不作为不会带来什么灾难性的后果。"


func _event_447(option_index: int, context: Dictionary) -> void:
	var iran := _iran()
	match option_index:
		0:
			# Event447.cs:53-55（两个分支共同的前置消耗）
			d[W.I_AGENTS] -= 200
			d[W.I_ARMY] -= 200
			d[W.I_BUDGET] -= 100
			if d[W.I_IRAN_ISLAMIST_SUPPORT] > 300:
				# Event447.cs:56-66：伊斯兰势力尚强，政变后君主派雅利安纳夺权
				d[W.I_DIPLO] += 30
				if iran != null:
					iran.government = 0
					iran.sub_government = 9
					iran.set_tag("亲美", true)
				ws.influence_prc += 10
				d[W.I_IRAN_ISLAMIST_SUPPORT] -= 1000
				context["result_text"] = "一通来自中国大使馆的电话打进了军营，莫哈格吉准将，马赫迪奥和阿梅里在我方的劝说之下，接纳了将我国作为靠山的计划。为此，我国将会为他们提供军火和逃生路线。一切按计划进行。第23空中突击旅顺利拿下位于哈马丹的诺耶空军基地，这里停有18架强-5战机。一队伊朗“金冠”飞行员驾驶，于6分钟后飞抵德黑兰上空，用BL755集束炸弹和90mm火箭弹对伊斯兰革命卫队总部等多处据点实施精准轰炸。其中，霍梅尼位于首都贾马拉的住所，由三架战机一起行动。在数百磅炸弹的洗礼下，霍梅尼这位真主的仆人便去见了安拉。原帝国近卫师、德黑兰宪兵和警察部队在内的3000人立刻占领广播电台等重要设施，并对主要毛拉进行抓捕。同时，在首都以外，第2、21、92装甲师和第81巴赫塔兰师、第77步兵师、及第1海军陆战旅，也将在伊斯法罕等全国15个城市迅速清理当地革命卫队。失去了领袖和大量军事力量的伊斯兰主义者再无东山再起的可能性，伊朗伊斯兰革命失败了。之后发生的事情，则超出了所有人的预料。巴赫拉姆·雅利安纳，这位“阿扎德甘组织”的领袖，在代号名“戈尔巴”的特工（他也是为政变者搭建了主要的联系网络的特工）的渗透下，一举拿下了运动的领导权！实际上，这种事态的发生并不应该意外，毕竟主要参与政变的部队普遍指挥权都隶属于“阿扎德甘组织”，而左翼与霍梅尼的对抗则更是为他们积攒力量提供了优势。雅利安纳宣布将不会迎回不得人心的老沙阿，而是将作为摄政王，等待小礼萨·巴列维二世加冕。雅利安纳很快开始实践他的理念。政治上，推行以帕提亚帝国为蓝本的技术官僚和精英主义政府体系，设立由精英和“智者”组成的选举大会作为上院，负责选举行政部门、国家元首并监督政府，下院是代表普通民众、行会和企业的代表大会，充当人民与国家之间的调节者；实行政教分离，禁止教士干政，并废除面纱和一夫多妻制；经济上关键部门国有化，实施社会保障；文化上，雅利安纳开始“复兴伊朗传统”，“净化”波斯语，推行去“阿拉伯化”，用拉丁字母取代阿拉伯字母，强调前伊斯兰时期的波斯文化，逐渐淡化伊斯兰教，复兴祆教和民族节日。而这些政策显然引起了伊朗全国性的动荡，几乎没有伊斯兰革命，乃至伊朗革命中的参与者会对此感到满意，但轰炸机和喷火器正在对他们做物理的批判……"
			else:
				# Event447.cs:68-74：左翼总起义路线，448 由 .tres 的 TRIGGER_EVENT 入队
				d[W.I_DIPLO] += 30
				if iran != null:
					iran.government = 2
					iran.sub_government = 15
				ws.influence_prc += 50
				d[W.I_IRAN_ISLAMIST_SUPPORT] -= 1000
				context["result_text"] = "一通来自中国大使馆的电话打进了军营，莫哈格吉准将，马赫迪奥和阿梅里在我方的劝说之下，接纳了将我国作为靠山的计划。为此，我国将会为他们提供军火和逃生路线。一切按计划进行。第23空中突击旅顺利拿下位于哈马丹的诺耶空军基地，这里停有18架强-5战机。一队伊朗“金冠”飞行员驾驶，于6分钟后飞抵德黑兰上空，用BL755集束炸弹和90mm火箭弹对伊斯兰革命卫队总部等多处据点实施精准轰炸。其中，霍梅尼位于首都贾马拉的住所，由三架战机一起行动。在数百磅炸弹的洗礼下，霍梅尼这位真主的仆人便去见了安拉。原帝国近卫师、德黑兰宪兵和警察部队在内的3000人立刻占领广播电台等重要设施，并对主要毛拉进行抓捕。同时，在首都以外，第2、21、92装甲师和第81巴赫塔兰师、第77步兵师、及第1海军陆战旅，也将在伊斯法罕等全国15个城市迅速清理当地革命卫队。与此同时，全国在我们的策动下发生了左翼分子的总武装起义，关键性地为伊斯兰共和国盖上了棺材板。失去了领袖和大量军事力量的伊斯兰主义者再无东山再起的可能性，伊朗伊斯兰革命失败了。在伊朗大部分起义的头领事实上接纳我国作为靠山的大背景，左翼运动积极参与起义的过程的背景下，伊朗的反伊斯兰革命军政府宣布解散了阿扎德甘运动。巴赫拉姆·雅利安纳可谓是气急败坏，他遥控伊朗起义的计划失败了！看起来，除了最顽固的两位“反革命”，大家都赢了。"
		1:
			# Event447.cs:82-88：向伊朗当局告密
			d[W.I_AGENTS] -= 30
			d[W.I_DIPLO] -= 50
			ws.influence_prc += 50
			d[W.I_IRAN_ISLAMIST_SUPPORT] += 300
			if iran != null:
				iran.government = 0
				iran.sub_government = 20
				iran.set_tag("对华贸易", true)
			context["result_text"] = "我们决定打电话给伊斯兰共和国政府总理，告知了他们关于政变的阴谋。7月9日晚，莫哈格吉和几名飞行员散会后，在路边等待接应的车辆时，突然看见革命卫队的吉普正这朝边奔来。他们迅速钻进路旁的小树林逃避。莫哈格吉懵了，他不清楚是不是他们已经暴露。跑回公寓后，他直接拨通了原防空司令马赫迪奥的电话。随后，二人开车在德黑兰街头碰面。哥俩现在都不排除计划已泄露的可能性，但如箭在弦，已无回头路。马赫迪奥告诉莫哈格吉将联系陆军的阿梅里，准备提前动手。无论是否成功，他们都将坦然面对。这终将是一场灾难性的失败……第二天一早，伊斯兰革命卫队开始了对“面具”的清剿。包括莫哈格吉、马赫迪奥在内的600多人先后被捕，一些人在抵抗中遭击毙。陆军上校阿梅里和少数人成功逃进了土耳其。在伊朗政府安排的电视审判上，还有相当戏剧性的一幕，莫哈格吉准将挣脱了两旁的革命卫队成员，怒吼道：“我是一名伊朗军人！……我之所以参与行动，是因为我对祖国所发生的一切感到幻灭。阿訇先生（在伊朗是对毛拉的贬义称呼），请不要问我是否后悔！我们参加行动不是为了金钱或地位，而是为了拯救我的祖国！他（霍梅尼）是你们这些蠢货的伊玛目，不是我的！！”伊朗人感谢我们的通风报信，并决定扩大和我们的贸易往来。并决定为我们的主席颁发一枚伊朗伊斯兰共和国二级国旗勋章。"
		2:
			# Event447.cs:94-96：不介入，人民党自行告密
			if iran != null:
				iran.government = 0
				iran.sub_government = 20
			d[W.I_IRAN_ISLAMIST_SUPPORT] += 300
			context["result_text"] = "人民党利用其在军中的情报网络，无意间获取了部分武装力量将发动起义的消息。时任该党中央委员的穆罕默德·阿里·阿穆伊在与党魁基亚努里商议后，决定抓住这个机会向老霍头邀功、表忠心！希望以此让霍梅尼认为自己这个共产主义者将和他永远穿一条裤子。7月9日晚，莫哈格吉和几名飞行员散会后，在路边等待接应的车辆时，突然看见革命卫队的吉普正这朝边奔来。他们迅速钻进路旁的小树林逃避。莫哈格吉懵了，他不清楚是不是他们已经暴露。跑回公寓后，他直接拨通了原防空司令马赫迪奥的电话。随后，二人开车在德黑兰街头碰面。哥俩现在都不排除计划已泄露的可能性，但如箭在弦，已无回头路。马赫迪奥告诉莫哈格吉将联系陆军的阿梅里，准备提前动手。无论是否成功，他们都将坦然面对。这终将是一场灾难性的失败……第二天一早，伊斯兰革命卫队开始了对“面具”的清剿。包括莫哈格吉、马赫迪奥在内的600多人先后被捕，一些人在抵抗中遭击毙。陆军上校阿梅里和少数人成功逃进了土耳其。在伊朗政府安排的电视审判上，还有相当戏剧性的一幕，莫哈格吉准将挣脱了两旁的革命卫队成员，怒吼道：“我是一名伊朗军人！……我之所以参与行动，是因为我对祖国所发生的一切感到幻灭。阿訇先生（在伊朗是对毛拉的贬义称呼），请不要问我是否后悔！我们参加行动不是为了金钱或地位，而是为了拯救我的祖国！他（霍梅尼）是你们这些蠢货的伊玛目，不是我的！！"


func _event_448(option_index: int, context: Dictionary) -> void:
	var iran := _iran()
	match option_index:
		0:
			# Event448.cs:48-56：支持伊朗人民联盟（左翼）
			d[W.I_AGENTS] -= 80
			d[W.I_BUDGET] -= 20
			d[W.I_DIPLO] += 50
			ws.influence_prc += 50
			if iran != null:
				iran.government = 2
				iran.sub_government = 3
				iran.set_tag("亲中", true)
				iran.set_tag("对华贸易", true)
				iran.prc_power = 1000
			context["result_text"] = "我们决定支持伊朗人民联盟，在我们雄厚资金的支持下，该党设法取得了立宪会议和伊朗人民议会的绝对多数席位，即便只获得了23%的选票而大量弃票表示对“拯救伊朗大起义”的否定。人民联盟上台便开始着手实现其竞选诺言，对原先被外资垄断的石油工业被迅速的收为国有，土地改革在我们特勤的帮助下，也得以稳定的进行。借着石油和我们的一笔无息贷款，人民联盟开始组建更为完善的福利体系，包括了全民医保和直至高中的义务教育。同时，他们也没有忘记过去几年所受到的耻辱。新政府上台以来颁布的第一项法令，便是逮捕（如果没有在小型内战中罹害的话）原伊斯兰革命卫队成员和伊朗伊斯兰共和党党员。他们的后代被禁止参与到政府的决策中，部分阿訇和毛拉也被丢进了监狱。新政府也决定放下对伊拉克的敌视，双方再次确定了对入海口和胡齐斯坦/阿拉伯斯坦自治权对保障，作为回报，伊拉克将帮助新生的共和国训练一支足够强大的陆军。新政府也没有忘记打井人，伊朗宣布将“和中华人民共和国开展更广泛且深入的合作。”一张又一张的贸易协定在北京和德黑兰之间签成。我们也收获了一位强大的盟友。然而，大量对于该国新生民主持有反对的团体依然在进行城市游击战，其中除了意料之中的伊斯兰派外，甚至包括不少左翼团体。"
		1:
			# Event448.cs:61-69：支持伊朗解放阵线（右翼）
			d[W.I_AGENTS] -= 80
			d[W.I_BUDGET] -= 20
			d[W.I_DIPLO] -= 50
			ws.influence_prc += 30
			if iran != null:
				iran.government = 3
				iran.sub_government = 12
				iran.set_tag("亲中", true)
				iran.set_tag("对华贸易", true)
				iran.prc_power = 1000
			context["result_text"] = "我们决定支持伊朗解放阵线，在我们雄厚资金的支持下，该党设法取得了立宪会议和伊朗人民议会的绝对多数席位即便只获得了21%的选票而大量弃票表示对“拯救伊朗大起义”的否定。自由运动上台便开始着手实现其竞选诺言，对原先被外资垄断的石油工业再次被外资所把握，中石化和中石油得以继承美国人所留下的一切。同时，他们也没有忘记过去几年所受到的耻辱。新政府上台以来颁布的第一项法令，便是逮捕（如果没有在小型内战中罹害的话）原伊斯兰革命卫队成员和伊朗伊斯兰共和党党员。他们的后代被禁止参与到政府的决策中，部分阿訇和毛拉也被丢进了监狱。作为“新摩萨台主义”，政府大力鼓励伊朗民族主义，强调历史和解。新政府拒绝同伊拉克和解，伊朗的F-4“鬼怪”战机和Q-5“番摊”型攻击机频频飞入伊拉克领空，伊拉克也开始试射自己的小型导弹，并谴责伊朗新政府为“帝国主义安插在阿拉伯湾的一枚楔子”。新政府也没有忘记打井人，伊朗宣布将“和中华人民共和国开展更广泛且深入的合作。”一张又一张的贸易协定在北京和德黑兰之间签成。我们也收获了一位强大的盟友。然而，大量对于该国新生民主持有反对的团体依然在进行城市游击战，其中除了意料之中的伊斯兰派外，甚至包括不少左翼团体。"
		2:
			# Event448.cs:72-87：不介入，由美苏影响力决定选举结果
			var ussr_power := 0
			var usa_power := 0
			if ws.empires.size() > 0 and ws.empires[0] != null:
				usa_power = ws.empires[0].power
			if ws.empires.size() > 1 and ws.empires[1] != null:
				ussr_power = ws.empires[1].power
			if ussr_power >= usa_power:
				# Event448.cs:77-80
				if iran != null:
					iran.government = 2
					iran.sub_government = 3
					iran.set_tag("对华贸易", false)
					iran.set_tag("亲苏", true)
				context["result_text"] = "即便只获得了23%的选票而大量弃票表示对“拯救伊朗大起义”的否定，人民联盟得以以微弱的优势击败伊朗解放阵线。人民联盟上台便开始着手实现其竞选诺言，对原先被外资垄断的石油工业被迅速的收为国有，土地改革几乎是灾难性的，大量自耕农以杀死耕畜和毁坏农机，烧毁粮食作为抵制。借着石油，人民联盟开始组建更为完善的福利体系，包括了全民医保和直至高中的义务教育。罢工和罢课频频发生。同时，他们也没有忘记过去几年所受到的耻辱。新政府上台以来颁布的第一项法令，便是逮捕（如果没有在小型内战中罹害的话）原伊斯兰革命卫队成员和伊朗伊斯兰共和党党员。他们的后代被禁止参与到政府的决策中，部分阿訇和毛拉也被丢进了监狱。新政府也决定放下对伊拉克的敌视，双方再次确定了对入海口和胡齐斯坦/阿拉伯斯坦自治权对保障，作为回报，伊拉克将帮助新生的共和国训练一支足够强大的陆军。然而，大量对于该国新生民主持有反对的团体依然在进行城市游击战，其中除了意料之中的伊斯兰派外，甚至包括不少左翼团体。不过，目前的伊朗当局再差，也比伊斯兰好，对吧？"
			else:
				# Event448.cs:84-87
				if iran != null:
					iran.government = 3
					iran.sub_government = 12
					iran.set_tag("对华贸易", false)
					iran.set_tag("亲美", true)
				context["result_text"] = "即便只获得了21%的选票而大量弃票表示对“拯救伊朗大起义”的否定，伊朗解放阵线设法取得了立宪会议和伊朗人民议会的相对多数，不得不与伊朗人民联盟事实上共同管理伊朗。自由运动上台便开始着手实现其竞选诺言，对原先被外资垄断的石油工业再次被外资所把握，美国人得以重返伊朗，和我们的石油企业展开了激烈斗争。同时，他们也没有忘记过去几年所受到的耻辱。新政府上台以来颁布的第一项法令，便是逮捕（如果没有在小型内战中罹害的话）原伊斯兰革命卫队成员和伊朗伊斯兰共和党党员。他们的后代被禁止参与到政府的决策中，部分阿訇和毛拉也被丢进了监狱。作为“新摩萨台主义”，政府大力鼓励伊朗民族主义，强调历史和解。新政府拒绝同伊拉克和解，伊朗的F-4“鬼怪”战机和Q-5“番摊”型攻击机频频飞入伊拉克领空，伊拉克也开始试射自己的小型导弹，并谴责伊朗新政府为“帝国主义安插在阿拉伯湾的一枚楔子”。然而，大量对于该国新生民主持有反对的团体依然在进行城市游击战，其中除了意料之中的伊斯兰派外，甚至包括不少左翼团体。不过，目前的伊朗当局再差，也比伊斯兰好，对吧？"


func _event_449(option_index: int, context: Dictionary) -> void:
	var iran := _iran()
	match option_index:
		0:
			# Event449.cs:52-65：支持反对派武装总起义，开启伊朗革命战争
			d[W.I_AGENTS] -= 100
			d[W.I_BUDGET] -= 100
			d[W.I_DIPLO] += 100
			if ws.wars.size() <= 33:
				ws.wars.resize(34)
			var war := ws.wars[33]
			if war == null:
				war = WarData.new()
				ws.wars[33] = war
			# Event449.cs:55-63
			war.name_war = "伊朗革命战争"
			war.is_going = true
			war.side1 = "伊朗人民革命阵线"
			war.side2 = "伊朗伊斯兰共和国"
			war.ussr_side = -1
			war.usa_side = -1
			war.infl1 = 300
			war.infl2 = 700
			war.fortnight_max = 20
			# Event449.cs:64：原版 gameState.iranrev = true；Godot 无此字段，
			# 暂写入全局标记供后续 450 等事件移植时读取。
			ws.set_flag("iranrev", true)
			# Event449.cs:65
			if iran != null:
				iran.set_tag("对华贸易", false)
			context["result_text"] = "我们的特工联系到人民敢死游击队（德赫加尼派），伊朗人民敢死游击队组织（少数派），工人阶级解放斗争组织（佩卡尔），伊朗共产主义者联盟，伊朗劳动者党，伊朗劳动党（风暴）等组织和其他小型共产主义团体，以及库尔德民主党和俾路支解放阵线等正在武装反抗伊斯兰共和国的少数民族左翼团体，共同组建了伊朗人民革命阵线作为各个武装团体的统一指挥和联络机构。很快，阿莫勒市爆发了一场大起义，同时，在其他抗议城市中，一些中国制式武器不知从什么渠道流通到了抗议民众和罢工工人那里，伊朗全国各地的人民革命阵线成员和抗议民众联合起来，击退了政府的镇压队伍。全国各个城市都爆发了火并。人民圣战者制造了多次暗杀——先是一枚炸弹在德黑兰的伊斯兰共和党总部爆炸，当时该党领导人会议正在进行中，伊朗伊斯兰共和国的七十四名主要官员被送去见了真主，其中包括首席大法官阿亚图拉·穆罕默德·贝赫什蒂，他是伊朗革命中第二有权势的人物（仅次于阿亚图拉·鲁霍拉·霍梅尼）；随后，总理办公室也发生了一场爆炸，时任总统拉贾伊和总理巴霍纳尔被炸死。霍梅尼非常愤怒，宣称这是“伪君子和乌合之众对于正信的背弃”，“自由派想要把我们的国家再一次出卖给大撒旦”立马动员了各级伊斯兰革命委员会、巴斯基动员军以及正在形成中的革命卫队，人民党、激进穆斯林联盟、人民敢死游击队（多数派）也站在霍梅尼这边，希望这次的“从龙之功”能够让他们在未来任何可能的社会改造中拥有更大的话语权。“伊玛目路线的学生”和各种仍持反对派立场的左翼人士已经进入街垒冲突阶段。"
		1:
			# Event449.cs:71-74：不干涉，伊斯兰共和国稳住阵脚
			if iran != null:
				iran.government = 0
				iran.sub_government = 20
				iran.set_tag("亲中", false)
				iran.set_tag("对华贸易", false)
			context["result_text"] = "伊朗各地都爆发了各种反抗活动。阿博尔哈桑·巴尼萨德尔在人民圣战者的掩护下逃到了法国。政府迅速对抗议做出了反应，大量抗议者被逮捕。几天后，一枚炸弹在德黑兰的伊斯兰共和党总部爆炸，当时该党领导人会议正在进行中，伊朗伊斯兰共和国的七十四名主要官员被送去见了真主，包括首席大法官阿亚图拉·穆罕默德·贝赫什蒂，他是伊朗革命中第二有权势的人物（仅次于阿亚图拉·鲁霍拉·霍梅尼），伊朗人民圣战者组织被霍梅尼指控为袭击的幕后黑手；一个月后，总理办公室也发生了一场爆炸，时任总统拉贾伊和总理巴霍纳尔被炸死。伊朗共产主义者联盟在阿莫勒附近的森林中动员力量，发动了反对伊朗伊斯兰政权的武装运动。该起义由赛厄马克·扎伊姆领导，但最终失败，许多伊共盟成员和毛派领导人被枪杀。革命卫队强行夺回阿莫勒市后，扎伊姆被他们逮捕。其他的共产主义团体在各地也开展了一些武装运动，但是由于彼此孤立，互相缺乏联系而被各个击破。少数民族的反抗运动最后也被镇压。伊朗伊斯兰共和国虽然经历了一个动荡的时期，但仍旧稳固。人民圣战者不会放弃斗争，他们正在准备下一次行动……"


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power


## 外交部长姓名（politics_positions[2]），缺失回退"黄华"。
func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"
