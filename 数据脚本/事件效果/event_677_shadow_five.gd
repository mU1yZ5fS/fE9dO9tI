extends "res://数据脚本/event_script_base.gd"

## 原作 Event677.cs：“暗影五号”爆炸案（北爱尔兰路线，六选项）。
## 触发：ReqEventsDLC02.cs:1456-1459 —— !ev673 && DATE_AFTER 1979.8.27。
## 差异：data[162]/[163]/[164]/[165]/[166] 无命名常量，按原版 raw index 读写；
##   Torg→对华贸易；{0}{1} 领袖姓名 → ws.leader.name_display。

const TXT_TITLE := "“暗影五号”爆炸案"
const TXT_DESC := "无数的爱尔兰仁人志士从来没有停止过对英国殖民者的抵抗，自爱尔兰大饥荒到复活节起义，再到一代又一代的自由战士为之献身。而就在今天，知名（或恶名远扬）的爱尔兰共和军（临时派）发动了一次成功的暗杀，蒙巴顿勋爵及其家人在一次炸弹袭击中丧生。这是自北爱尔兰冲突以来官职最为显赫的死者。主席同志，也许我们是时候给不知好歹的英国佬们一点教训了，但在此之前，请允许我对几个派系做出简单的介绍。\n首先：正如您所知道的那样，爱尔兰共和军发生了一次分裂。共和军领导人卡沙尔·古尔丁认为单纯依靠武装暴力不能争取到完全的解放，必须把北爱尔兰的民族解放斗争转化为一场推翻联合王国和爱尔兰共和国的工人革命。这招致了大批共和军内反对高层的马主义倾向，从而忽视共和主义传统的同志的反对。以乔·卡希尔和比利·麦基为首的同志在1969年的大规模流血事件中强烈谴责了古尔丁的不作为，并成立了“临时派”（PIRA）共和军并继续展开暴力活动。古尔丁率领的共和军则被称为“正式派”（OIRA）1972年末宣布停火并暂停敌对武装行动，尽管英国和爱尔兰仍然视他们为眼中钉。苏联，朝鲜和利比亚给共和军们提供过慷慨的支持，不过显然他们不会介意更多国家的慷慨解囊。\n1974年，由正式派新芬党副主席兼共和军参谋斯莫斯·科斯特洛组建的爱尔兰共和社会党（IRSP）也在崛起，他们的武装组织爱尔兰民族解放军（INLA）相较之下孱弱也更需要帮助。随着科斯特洛在1977年被暗杀，该党正在陷入内部路线分歧。一向与其不和爱尔兰共和军，爱尔兰官方和英国人也对他们没有什么好脸色瞧。但如果我们希望在翡翠之岛上雕刻出美丽的作品，他们就是最好的一把刻刀。\n在他们的对立面是一个意料之外的，但是潜在的合作者：以阿尔斯特志愿军（UVF）和阿尔斯特防卫协会（UDA）为首的新教民族主义亲英团体同样活跃。尽管在理论上，该系列组织同样与IRA一道属于恐怖主义组织。英国军方却经常假借他们之手对北爱尔兰平民执行“作战计划”，从而在民众与北爱尔兰反抗军中间制造恐慌和不信任。\n其实，还有一个意料之外的选项。布兰登·克利福德所代表的不列颠与爱尔兰共产主义者组织（BICO）是一支新兴崛起的反修正主义势力，该党认为爱尔兰存在不列颠新教徒与爱尔兰天主教徒两个民族，工人阶级政党应承认他们的权利，并坚决与迷信宗教者、民族主义者和镇压性政权做斗争。考虑到他们的意识形态，我们也许可以藉此机会介入他们？\n如果我们能妥善理由这样的一批组织，我们就可以在该地区施加更多的影响力。\n当然还有最后的选择，我们可以置身事外。"
const TXT_OPT0 := "黑棕部队滚出去！我们将支持共和军正式派抗争到底"
const TXT_OPT0_DIS := "拒绝恐怖主义！"
const TXT_OPT1 := "若要死，也要死在爱尔兰的天空下！我们将与临时派共和军同行"
const TXT_OPT1_DIS := "我的手很干净"
const TXT_OPT2 := "以詹姆斯·康诺利的名义，高高升起星犁旗吧。共和社会党将领导爱尔兰人向前进"
const TXT_OPT2_DIS := "极左恐怖主义分子可以休矣！"
const TXT_OPT3 := "黑棕部队滚回来！我们将支持亲英武装"
const TXT_OPT4 := "不要共和军，不要共和社会党，我们支持BICO"
const TXT_OPT4_DIS := "……他们是谁？我的通讯录上怎么没有这批人？"
const TXT_OPT5 := "说白了，我们能干什么？"
const TXT_R0 := "通过外联部组建的皮包组织“中国——爱尔兰友好协会”，“迈克尔·柯林斯基金会”以及朝鲜的走私网络，我们设法在都柏林和贝尔法斯特立足，与正式派共和军达成了一系列协议。我国将为他们提供足够的活动资金，换取他们对我们的无限支持。也正因如此，新芬工人党和正式派共和军得到了新的支持。古尔丁也需要我们的资金支持用于维系已经摇摇欲坠的官方派网络。毫无疑问的，我们达成了这笔协议。但是我们必须记住要定期支持他们，毕竟，革命尚未成功。"
const TXT_R1_FMT := "通过外联部组建的皮包组织“中国——爱尔兰友好协会”，“迈克尔·柯林斯基金会”以及朝鲜的走私网络，我们设法在都柏林和贝尔法斯特立足，与临时派共和军达成了一系列协议。我国将为他们提供足够的军火和武器装备，换取他们对我们的无限支持。不久之后，在贝尔法斯特的一处民族派据点的住宅楼旁。临时派的共和军战士们画上了毛泽东主席，{0}{1}同志和两位穿着六五式军服的IRA士兵。用模仿大字报的格式写着“星星之火，可以燎原”。\n毫无疑问的，我们达成了这笔协议。但是我们必须记住要定期支持他们，毕竟，革命尚未成功。"
const TXT_R2 := "考虑到IRSP和INLA的弱小，这反而给了我们更多的可乘之机。通过“中国——爱尔兰友好协会”，开设在北京外国语大学的“詹姆斯·康诺利研究会”和其他组织。我们设法与爱尔兰共和社会党人和爱尔兰民族解放军取得了联系在外联部和军委同志们仔细的研究后，我们决定借此机会改组INLA和IRSP内部已有的组织架构。在我们的强力拟合下，模仿中国革命早期的组织架构，IRSP作为党组织正式接手了INLA，在邓多克和纽里则开设了前线的指挥机关。\n同时，我们设法让爱尔兰共产党（马克思列宁主义）、科克工人俱乐部和“火花”团体等组织也加入到了IRSP和INLA的事业中来，为反修正主义事业和争取爱尔兰彻底独立添砖加瓦。爱共马列党籍的议员大卫·维庞德高度赞扬了我们对爱尔兰左翼运动事业的支持，将这一举动比做在爱尔兰大饥荒中送来粮食的土耳其苏丹，虽不同文同种却同心。上述组织的许多成员将拥有IRSP党籍和其他的党派身份，有助于IRSP作为政治力量在爱尔兰左翼圈子中扎根并阻止在地方性选举中的分票。一部分受到其激进左翼纲领吸引的新芬工人党成员和爱尔兰共和军成员也在考虑加入其中，这对共和军们来说算不上什么好消息，不过二者的关系本就算不上太好。\n考虑到IRSP长期活动于南方，而军事活动则在北方进行，我们甚至为他们提供了新的一批军用级通讯系统用于指挥作战。这一剂强心针成功让他们在全岛站稳脚跟，就此，我们在贝尔法斯特和都柏林收获了新的盟友。但是我们要记得一直支持他们，不然1977年随时可能再度上演……"
const TXT_R3 := "虽然这一步无比艰难，但，敌人的敌人总归是可以争取的，对吧？再不济，我们也可以把他们的破事泼给英国人，一举两得！\n在香港的珍宝海鲜舫，我国线人“碰巧”遇到了前来用餐的阿尔斯特防御协会会长安德鲁·泰尔，并“非常不小心”的把一张写有重要共和军调动情报的文件和一张存有三百万美元的银行卡落在了桌子上。眼尖的泰尔深谙其义。格伦安尼帮，阿尔斯特防卫军，皇家阿尔斯特警察等忠诚派武装更是加大了针对各路共和主义者，左翼叛匪与民族主义者的袭击。阿尔斯特工人议会更是多次发起针对天主教徒的反游行，一贯坐不定的奥兰治党也越发活跃。\n与北京共舞是危险的一步，但是随他呢。不过我们必须记得援助他们，否则以他们的力量，被更为强大的存在所碾碎只是时间问题……"
const TXT_R4 := "通过外联部组建的皮包组织“中国——爱尔兰友好协会”，“盖尔语研究会”以及朝鲜的走私网络，我们设法在都柏林和贝尔法斯特立足，与BICO的领导团体们达成了一系列协议。我国将为他们提供足够的军火和武器装备，换取他们对我们的无限支持。BICO是一支相对弱小的力量，并且没有过执行军事行动的经验。为此，我们特地请教了转职敌后破坏的前中央特科专员和朝鲜观察家们，还特别聘请了也门的前游击队队员们教授抗英技巧。很快，爱尔兰解放阵线闪亮登场，所做的第一件事便是爆破了与之敌对的武装分子的基地。新组织宣布要在爱尔兰建立马克思列宁主义的国家，彻底解放全岛并建立社会主义政权。其初级目标则是在北爱尔兰扫清盘踞的压迫者团体并消灭敌对的，抢占了民族解放话语权的修正主义分子和封建主义—小资产阶级民族主义者。\n不过我们必须要记得援助他们，毕竟他们没了我们可真的就难以活下去了。"
const TXT_R5 := "和大多数国家一样，我们发表了对于此次恐怖袭击不痛不痒的谴责声明。毕竟就连爱尔兰官方都不愿意支持如此过激的行动，也许是求仁得仁，也许蒙巴顿勋爵只是这次不义战争的又一位牺牲者。总之，北爱尔兰问题还会困扰我们很久。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 6:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	var opt := event_def.options
	if line <= 2:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line <= 1:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line <= 1 and mod6:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)
	if line <= 1:
		_enable(opt[4], TXT_OPT4)
	else:
		_disable(opt[4], TXT_OPT4_DIS)
	_enable(opt[5], TXT_OPT5)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uk := ws.get_country_by_legacy_index(92)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -30)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_add_power(EmpireData.USSR, 10)
			_add(W.I_DIPLO, 50)
			_add_raw(162, 10)
			if uk != null:
				uk.set_tag("对华贸易", false)
		1:
			context["result_text"] = TXT_R1_FMT.replace("{0}{1}", _leader_name())
			_add(W.I_ARMY, -80)
			_add(W.I_BUDGET, -30)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_add(W.I_DIPLO, 100)
			_add_raw(163, 10)
			if uk != null:
				uk.set_tag("对华贸易", false)
		2:
			context["result_text"] = TXT_R2
			_add(W.I_ARMY, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -50)
			ws.influence_prc += 15
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_DIPLO, 80)
			_add_raw(164, 10)
			if uk != null:
				uk.set_tag("对华贸易", false)
		3:
			context["result_text"] = TXT_R3
			_add(W.I_BUDGET, -50)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -150)
			_add_raw(165, 10)
			_add(W.I_DIPLO, 100)
		4:
			context["result_text"] = TXT_R4
			_add(W.I_ARMY, -100)
			_add(W.I_BUDGET, -100)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			_add(W.I_DIPLO, 100)
			_add_raw(166, 5)
			if uk != null:
				uk.set_tag("对华贸易", false)
		5:
			context["result_text"] = TXT_R5


func _add_raw(idx: int, delta: int) -> void:
	while d.size() <= idx:
		d.append(0)
	d[idx] += delta


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
