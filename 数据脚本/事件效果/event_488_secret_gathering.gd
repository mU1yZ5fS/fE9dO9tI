extends "res://数据脚本/event_script_base.gd"

## 原作 Event488.cs：秘密集结（民主德国危机，五选项）。
## 触发：ReqEventForDLC02.cs:1509-1511 —— 复合条件（含 parts[0] 数组）用
##   trigger_script 的 evaluate(world) 表达；fire_only_once 承担 !event_done[488]。
## 差异：
##  - Gosstroy/SubGosstroy → government/sub_government；dev → development；
##  - isSEV/isOVD/prosov/Torg/proprc → has_tag/set_tag；parts[0] 用 _set_part 置位；
##  - modifies[53].active = false → modifiers[53].is_active = false。

const TXT_TITLE := "秘密集结"

const TXT_DESC := "我们在波兰与匈牙利的同志传来了有趣的消息。由于国际局势风云突变，民主德国领导层苦心构建的“社会主义橱窗”正处于濒临违约的境地。众所周知，民主德国的社会主义之路从一开始便坎坷非常。出于构建欧洲集体安全体系的需要，苏联领导层曾将民主德国视为东方集团内可有可无的阑尾：前者不仅以民主德国“是否实行社会主义”作为同西方联盟议价筹建中立德国的筹码，更通过将富庶的西里西亚工业区划归波兰，实施大规模人口迁徙政策与严厉的战争赔偿削弱了经济潜力。且作为民主德国国内根基的德国统一社会党亦在合并后长期呈现为“名义共产党，实际社会民主党”的特质，并在《1949年宪法》中将自身的政治目标限定为民族统一与和平民主上。直到德国分立局面已成定局时，民德的社会主义才得以步入快车道，而这恰是另一个悲剧的开始：脆弱的产业基础，尚未为社会化经济做好准备的现状同瓦尔特·乌布利希的狂飙突进愿景交织一致直接导致了动摇国本的6月事变，至此奠定了该国先天不足的政治困境。而东德当局试图打破这一困局的尝试则在苏东阵营改革的背景下转向柯西金主义变体——即乌布利希先后主张的“新经济体系”与“社会主义经济体系”，计划在扩充国营部门的同时以委任技术官僚，强化经济核算并实现经济自动化的方式取得对联邦德国的经济优势，最终确立社会主义议程对德国的领导权。然而，计划内的“大跃进”最终只是重复了早在第三世界发生的一切。最终让乌布利希为埃里希·昂纳克所取代，不同于习惯在国际指挥棒下点头哈腰的乌布利希；后者直接扎根于德国本土的青年共产主义运动，并在战争结束后多少继承了“老斯巴达克”的些许气息：他将民主德国的政治前途锚定在“创造新社会体制”与“满足人民福祉”两大目标上，并借此开启了产业国有化、社会立法的自由化与兴建福利国家的议程。尝试与德国的草根阶级建立战略同盟。可考虑到民主德国的不稳定经济基础，这一计划自然得仰赖“特别赞助”：借助主管经济的二号人物君特·米塔格的手笔，该国得以从其波恩兄弟处获取巨额秘密贷款，并借此实现对于民众的收买政策：可在西德强硬派上台，拒绝继续奉行“以贸促变”政策；乃至苏联对该国态度亦转向“切割阑尾”的背景下。民主德国本身的局势便愈加焦灼。倘若无法立即提出替代性政治解决方案，6月政变再演不过是时间问题……不过考虑到混乱即阶梯，我们说不定能借用这一机会，将社会主义阵营的孤儿给收入囊中？"

const TXT_OPT0 := "患难见真情，我们将成为名副其实的“老大哥”，今后“红色威丁”将不会被出卖！"
const TXT_OPT1 := "想想老朋友的经验，德国人应试试紧缩政策和与之配套的罗马尼亚方案！"
const TXT_OPT1_DIS := "兵营社会主义不是我们的政策"
const TXT_OPT2 := "经济问题仅能通过经济方案解决，民主德国是时候迎来改革重组了！"
const TXT_OPT2_DIS := "乌布利希的失败足以证明，德国不需要所谓“改革重组”"
const TXT_OPT3 := "借助民主德国的政治失败煽动民粹主义，并寻找统社党内部代理人策动政变！"
const TXT_OPT3_DIS := "我们没必要和党阀狼狈为奸"
const TXT_OPT4 := "既然民主德国人喜欢说我们仍在这里，那我们就瞧瞧看……"

const TXT_R0_INTRO := "我们决定向苏东政权的另类保守派抛出橄榄枝，并向其展示何为“真正的社会主义”议程。作为重振民主德国社会主义计划的一部分。我们将承担该国在“两德密约”期间的所有外债，并为民主德国企业提供慷慨的技术转让与特别资金支持以重振该国生产。当然，民主德国方亦需要拿出解决该国社会主义内“三大障碍”的相应诚意：将以柏林地区第一书记康拉德·瑙曼为代表的强硬派政治路线全面引入当前政治议程（借助同该国工人与基层人民的广泛联系，瑙曼得以将自身塑造为人民领袖，并同该国越加无法代表“劳动群众需求”的老朽官员与拥抱精英主义的文化界人士泾渭分明）；在道德激励与大众动员的基础上重塑该国经济-社会体系；以及在外交上同步实现“经济与社会体制的步调一致”——这不仅意味着拒绝同联邦德国的勾肩搭背，更要同对德国社会主义事业叶公好龙的苏联集团完全分离。\n"

const TXT_R0_FULL := "意识到苏东集团已是明日黄花，且基于动员治理模式的中国切实蒸蒸日上。埃里希·昂纳克最终识时务地选择跳船，把驻德苏军遣送回国，并下定决心退出了经济互助委员会和华沙条约组织。接下来便是开始推行“有民主德国色彩的社会主义”新方针：以库尔特·哈格、君特·米塔格为代表的党务官僚们同汉斯·莫德罗等改革派一齐在党务体系内被边缘化，康拉德·瑙曼、亲斯大林主义宣传家汉娜·沃尔夫，以及剧作家彼得·哈克斯、历史学家和经济学家库尔特·戈斯韦勒等斯大林主义知识分子则被推上前台。参照苏联早期“列宁征召”的经验，德国统一社会党开始吸纳广泛进步工人、激进妇女与德国共产党（马列）东德支部（显然，该党在新方略下得以平反）成员加入其中实施改组。为扩充德国公民对政权的参与度，电子办公平台得以在全国范围广泛铺开，选民罢免代表与工人集体解雇董事的权利也在随后确立。得到我国启发的文化革命更在此后迅速推行：借助康拉德·瑙曼的柏林经验，“苏联先锋派”艺术形式得以在他治下实现推广，的对摇滚、说唱和朋克等类雅皮士表现形式则在“丰富社会主义表现型”的背景下大开绿灯。至此将其同目前官方正严打的“资产阶级艺术”、后现代主义艺术和西方现代主义等典型实现分离。各级艺术委员会本身也被洗牌，为年轻一代人才让路。此后，民主德国更将中国大字报与阿尔巴尼亚“闪电报”形式实现本土化，并与既有的国家传媒与试行的电子办公平台整合。决心深度揭批清算旧政府、旧制度与官僚主义残余。以此服务经济领域内逐步推开的两参一改三结合与工会民主新形式。自下而上，从基层开始革新民主德国一党制与计划经济框架的计划已然走在路上，让我们瞧瞧接下来会如何……"

const TXT_R0_COMPROMISE := "然而，党内保守派的势大和苏东社会主义阵营的牢靠控制成为了昂纳克的政治羁绊。导致其依然在苏东一体化与完全向我国一边倒间举棋不定。在统社党高层彻夜的谈话后，我们最终达成妥协：中国以承担民主德国一半外债与优惠贷款为代价，交换民主德国方减少苏联的联系、实行多边外交政策、并采纳部分旨在扩充群众参与的新方针。民主德国把驻德苏军遣送回国，但仍保持经济互助委员会的成员身份。此后的民主德国则迎来了“有民主德国色彩的社会主义”：自由德国工会联合会取得参与五年计划制定的咨询权，劳动集体也在企业与地方计划委员会中被授予类似权限。工人得以通过此类方式参与并干预计划委员会、党代会和企业的工作。雅皮士文化圈子实现解冻并开始作为政府的有机支持。然而，民主德国的经济与社会体系仍然保持强大的政治惯性：出于偿还债务需要，“经济沙皇”君特·米塔格自然而然地转向了老一套：押注经济核算、适当降低社会福利与支持所有能够直接服务生产的部门——即在某种程度上对乌布利希的“新经济体制”故事重提……而党务体制亦在“人民民主”的旗下维持统一社会党特别监护，同东欧的政治同僚们在大方向上步调一致……"

const TXT_R1 := "意识到民主德国当前处境危如累卵，且建制派的老路线已因债务危机而再无延续可能。我们决定赶在局势无可挽回前抢先物色强力人物并调整航线：很快，权力指针便转向了借助长久经营而发展壮大的国安机构与军方要员。绰号民主德国版“安德罗波夫”的史塔西负责人埃里希·米尔克、史塔西的外事专员兼二把手“无面人”马库斯·沃尔夫、在60年代危机期间以铁腕手段著称的国防部长海因茨·霍夫曼与拒绝一切形式改革、主张尽早改变亲苏立场的总参谋长海因茨·凯斯勒将军四人得以在我们的点拨下立即采取行动。借助史塔西与国家人民军的合力，米尔克迅速召开了统社党特别全会，并通过隔离会场与派遣专机加塞代表的形式以快打慢。最终，借助这一合理合法的政变形式。米尔克得以让昂纳克因健康原因“光荣退休”，后者则在不久后赴古巴度过余生。紧随其后的便是对统一社会党的改组，终止民主德国同苏东阵营的合作关系与遣送苏军回国：在“有德意志民族特色的社会主义道路”旗下，新政府一次性提升了日用品价格并引入燃料、电力等关键产品的配给制度，同时开始对前端人民企业进行改革（其中的效益低下者则被转卖给私人与国际买家——后者不言自明）、废除同自由德国工会联合会挂靠的福利制度与签署多项引进廉价劳工（主要来自于罗马尼亚、阿尔巴尼亚此类更欠发达的社会主义政权）的相关合同。有关民族主义的宣传则跟着开始占领该国舆论界：除却“马克思主义就是现代的德国民族主义”，“实现德意志民族统一便是当前德国社会主义的最大理想”等经典外。该国出现了更加不安的变化：参与“瓦尔基里行动”的部分纳粹战犯被平反；恩斯特·尼基施的观点逐步成为显学；以及针对东方邻国的敌性用语更是显著增加。波兰在舆论内越加被称之为“修正社会主义典型”、“偷走西里西亚的小偷”与“通货膨胀猖獗、瘾君子遍地与掠夺成性的流氓政权”。上述情形显然遭到了华沙当局的强烈抗议。可在东欧话事人苏联都不得不在东方以东干预下知难而退的背景下，他们又能在何种程度上改变局势呢？人们惊恐地看着特务头子与军方幕僚正垄断权力，反对派也开始利用这一事实渲染恐怖氛围。但史塔西的铁拳会教他们怎么当个好德国人与共产主义者！"

const TXT_R2 := "意识到民主德国当前处境危如累卵，且建制派的老路线已因债务危机而再无延续可能。我们决定赶在局势无可挽回前抢先调整航线：很快，权力指针便转向了主张增强民主德国经济基础，提升该国造血能力以避免违约可能的实用主义者们。反对赤字财政与“经济与社会体制步调一致”的老将，前国家计划委员会负责人格哈德·许雷尔；曾主刀瓦尔特·乌布利希时代“新经济规划与管理体系”（NÖSPL）改革的前总书记私人助理沃尔夫冈·贝尔格与回归正道的君特·米塔格等技术官僚在我们的支持下得以组合为一股强大实力。此后，借助民主德国“三号人物”，昂纳克昔日政治学徒埃贡·克伦茨与无立场部长霍斯特·辛德曼的支持，民主德国迎来了它的改组。昂纳克因健康原因“光荣退休”，不久后便奔赴赴古巴度过余生。埃贡·克伦茨则接过了权力之柄，计划在预防危机的基础上迅速筹备新一轮改革：根据现有情报考察，其中的绝大多数计划可被视为乌布利希胎死腹中的“新经济规划与管理体系”的延续。"

const TXT_R3 := "有关民主德国债务危机的消息很快便通过我方及欧洲盟友控制下的媒体传开，并迅速引爆为针对昂纳克-米塔尔集团的巨大丑闻与该国境内的社会骚乱。我们声称其治下的“德国社会奇迹”只是外债社会主义的又一类变种，并将两德间秘密交易的实况与部分难辨真假的情报混合一致。在东德群众眼中造就了民主德国现任当局与联邦德国建制派集团间已达成秘密合作，有意识破坏东德经济社会建设的印象，民主德国版的“国防威胁论”便得以该国境内喧嚷其上。对党政高官的质疑与经济局势的持续动荡最终使得罪魁祸首埃里希·昂纳克与君特·米塔格不得不自请隐退；东德意识形态秘书哈格、部长会议主席威利·斯托夫和斯塔西负责人埃里希·米尔克等高级行政干部也纷纷引咎辞职。东德高层出现的政治真空让我们挑选的代理人，年轻的党政官僚君特·沙博夫斯基得了便宜：他缺乏意识形态原则性，精于实事求是，跟随总路线一贯摇摆；被同事冠以“两面人”（Wendehals）之名，最有助于推进东德本身的改革。随后，沙博夫斯基便带着我们的援助与许诺“降低物价、开放政治、肃清外敌并恢复东德国家主权”的口号，首先恢复了首都地区秩序，随后便通过引入宵禁、拓宽福利与许诺政治自由的方式稳定局势。如此功绩自然使其在统一社会党的特别代表大会上被选为新任总书记。东德新任领导人并未忘记我们的帮助：几乎在新领导集体形成与秩序稳定的第二天，便以苏联克格勃协助策动骚乱，干预东德内政，威胁东德国家主权为由。遣返了驻德苏军，并加入了我们的怀抱。"

const TXT_R4_SUPPRESSED := "结果，东德当局决定效法波兰式紧缩政策（即一次性抬高日用消费品价格筹资，并降低工人工资，抬高劳动强度）。这一的做法更是彻底引爆了局势。第一次示威活动在莱比锡举行，每天都会重复。随后东德其他主要城市也开始举行示威活动。随后的几天里，德累斯顿、哈勒、卡尔·马克思城、马格德堡、普劳恩、阿恩施塔特、罗斯托克、波茨坦和什未林加入了运动。政治口号也从“面包与和平”上升到了“工人当家做主人”和“统社党滚蛋”之类的政治性口号。不过，抗议活动也就到此为止了。在苏联驻军和史塔西的帮助下，暴乱迅速的被镇压下去，东德将继续如此生活数十年……"

const TXT_R4_REVOLT := "结果，东德当局决定效法波兰式紧缩政策（即一次性抬高日用消费品价格筹资，并降低工人工资，抬高劳动强度）。这一的做法更是彻底引爆了局势。第一次示威活动在莱比锡举行，每天都会重复。随后东德其他主要城市也开始举行示威活动。随后的几天里，德累斯顿、哈勒、卡尔·马克思城、马格德堡、普劳恩、阿恩施塔特、罗斯托克、波茨坦和什未林加入了运动。政治口号也从“面包与和平”上升到了“工人当家做主人”和“统社党滚蛋”之类的政治性口号。显然，局势正在逐步激化。随着时间流逝，甚至连一部分前国家人民军官兵和工人阶级战斗队的成员也开始加入到暴力示威当中。愤怒的群众砸毁了史塔西大楼，东柏林事实上卷入场小型内战。而足以对当地局势一锤定音的苏联却因外交政策改弦更张，拒绝对民主德国进行武装干涉。于是我们只能看着事情起变化……\n"

const TXT_R4_EICHBERG := "然而，国际观察家们所预估的最糟糕情况还是发生了。艾希伯格宣布将“解放在苏联帝国主义奴役下的德意志同胞”。武装人民党卫军跨过了边境线，迅速攻占了大半个民主德国。统社党，波兰人大惊失色，纷纷逃亡周围的国家。联合国强烈谴责了这一行为，但于事无补。德国在铁与血的手段下获得了统一……"

const TXT_NAME_EICHBERG := "德意志人民国"

const TXT_R4_REMER := "然而，我们所预估的最糟糕情况还是发生了。雷默宣布将“帮助对面的民族兄弟恢复秩序”。德国国防军跨过了边境线，迅速攻占了大半个民主德国。统社党，波兰人大惊失色，纷纷逃亡周围的国家。联合国强烈谴责了这一行为，但于事无补。德国在铁与血的手段下获得了统一……"

const TXT_NAME_REMER := "德意志民族工人国"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var west := world.get_country_by_legacy_index(17)
	var east := world.get_country_by_legacy_index(16)
	var poland := world.get_country_by_legacy_index(2)
	var hungary := world.get_country_by_legacy_index(4)
	var romania := world.get_country_by_legacy_index(5)
	if west == null or east == null:
		return false
	if west.government != 2 and not west.has_tag("soc_eu"):
		return false
	if _part_true(west, 0):
		return false
	if _part_true(east, 0):
		return false
	if poland == null or hungary == null or romania == null:
		return false
	if poland.has_tag("亲苏") or hungary.has_tag("亲苏") or romania.has_tag("亲苏"):
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	if world.empires[EmpireData.USSR].power > 100:
		return false
	var leader := world.empires[EmpireData.USSR].current_leader
	if leader != 5 and leader != 6 and leader != 8:
		return false
	return world.date.to_int() >= 19850617


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var china := world.get_country_by_legacy_index(1)
	var econ := world.数值表[W.I_ECON_SYSTEM] if world.数值表.size() > W.I_ECON_SYSTEM else 11
	var line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if china != null and china.government <= 1:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if (china != null and (china.government == 2 or china.government == 3)) or econ >= 13:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if line > 1:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], TXT_OPT4)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var gdr := ws.get_country_by_legacy_index(16)
	var west := ws.get_country_by_legacy_index(17)
	var ussr_country := ws.get_country_by_legacy_index(7)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var sev_count := 0
			for c in ws.countries:
				if c != null and c.has_tag("sev"):
					sev_count += 1
			var text := TXT_R0_INTRO
			if sev_count < 5:
				text += TXT_R0_FULL
				_add(W.I_BUDGET, -200)
				_add(W.I_AGENTS, -50)
				if gdr != null:
					_leave_alliances(gdr)
					gdr.set_tag("亲中", true)
					gdr.sub_government = 2
					_join_alliances(gdr)
					gdr.set_tag("对华贸易", true)
				ws.influence_prc += 50
				_add_power(EmpireData.USSR, -50)
				_add_relation(EmpireData.USSR, -300)
			else:
				text += TXT_R0_COMPROMISE
				_add(W.I_BUDGET, -100)
				_add(W.I_AGENTS, -50)
				if gdr != null:
					gdr.set_tag("ovd", false)
					gdr.set_tag("亲苏", false)
					gdr.sub_government = 1
					gdr.set_tag("对华贸易", true)
				ws.influence_prc += 20
				_add_power(EmpireData.USSR, -20)
				_add_relation(EmpireData.USSR, -200)
			context["result_text"] = text
		1:
			_add(W.I_DIPLO, 100)
			if gdr != null:
				gdr.government = 0
				gdr.sub_government = 10
				_leave_alliances(gdr)
				gdr.set_tag("亲中", true)
				gdr.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -200)
			_add(W.I_BUDGET, -30)
			ws.influence_prc += 5
			_add_relation(EmpireData.USA, -500)
			_add_relation(EmpireData.USSR, -500)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			if gdr != null:
				gdr.set_tag("亲苏", false)
				gdr.government = 2
				gdr.sub_government = 21
				gdr.set_tag("对华贸易", true)
			context["result_text"] = TXT_R2
		3:
			_add(W.I_BUDGET, -250)
			_add(W.I_AGENTS, -200)
			_add(W.I_ARMY, -100)
			ws.influence_prc += 50
			_add_power(EmpireData.USSR, -50)
			_add_relation(EmpireData.USSR, -400)
			if gdr != null:
				_leave_alliances(gdr)
				gdr.set_tag("亲中", true)
				gdr.government = 2
				gdr.sub_government = 8
				_join_alliances(gdr)
				gdr.set_tag("对华贸易", true)
			context["result_text"] = TXT_R3
		4:
			var ussr := _empire(EmpireData.USSR)
			var ussr_in_ovd := ussr_country != null and ussr_country.has_tag("ovd")
			if ussr != null and ussr.power >= 100 and ussr_in_ovd:
				context["result_text"] = TXT_R4_SUPPRESSED
			else:
				var text := TXT_R4_REVOLT
				if gdr != null:
					gdr.内战中 = true
				if west != null and west.sub_government == 22:
					text += TXT_R4_EICHBERG
					if west != null:
						_set_part(west, 0, true)
						west.development = 2
						west.name = TXT_NAME_EICHBERG
						west.chinese_name = TXT_NAME_EICHBERG
					if gdr != null:
						_leave_alliances(gdr)
					_set_modifier_active(53, false)
				elif west != null and west.sub_government == 9:
					text += TXT_R4_REMER
					if west != null:
						_set_part(west, 0, true)
						west.development = 2
						west.name = TXT_NAME_REMER
						west.chinese_name = TXT_NAME_REMER
					if gdr != null:
						_leave_alliances(gdr)
					_set_modifier_active(53, false)
				context["result_text"] = text


func _part_true(c: CountryData, index: int) -> bool:
	return c != null and c.parts.size() > index and c.parts[index]


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value


func _set_modifier_active(index: int, value: bool) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = value


func _empire(index: int) -> EmpireData:
	if ws.empires.size() > index and ws.empires[index] != null:
		return ws.empires[index]
	return null


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta
