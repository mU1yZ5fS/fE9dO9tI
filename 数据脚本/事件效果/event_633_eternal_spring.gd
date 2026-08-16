extends "res://数据脚本/event_script_base.gd"

## 原作 Event633.cs：永恒的春天（危地马拉内战转折，四选项）。
## 触发：ReqEventsDLC02.cs:976-979 —— IsAuthoritarianism(149) && DATE_AFTER 1982.3.23。
##   IsAuthoritarianism 无单一 ExprNode → trigger_script evaluate。
## 差异：原版按 data[56]/对美关系 Destroy(button[i])；Godot _disable 同义；
##   美国总统 now_leader==0(里根)/否则(卡特) 用 empires[0].current_leader 分支。

const TXT_TITLE := "永恒的春天"
const TXT_DESC := "危地马拉共和国向来只是中美洲诸多香蕉共和国中最平平无奇的一个。自独立以来，该国仿效现代民主国家的政治体制就只是一个空壳，在现代共和国的表面下，旧殖民地时期的权力层级几乎原封不动地保留了下来。而从西班牙的殖民统治中脱离也并未为该国带来真正的独立，这个小国相继落入了英国和美国的控制之下，靠着地主、军队、教会与帝国主义的支持，卖国贼们自能毫无后顾之忧地将该国变成帝国主义的咖啡园或是香蕉园。1859年，“国父”拉斐尔·卡雷拉同英国签订了《艾西内纳-威克条约》，将伯利兹地区的主权拱手让人，1871年的自由主义革命的最终成果也不过是使该国成为了咖啡共和国，曼努埃尔·卡布雷拉与豪尔赫·乌维科更是将自己的祖国变成了联合果品公司的傀儡。而尽管曾经出现过哈科沃·阿本斯这样的革命性政权，但1954年美国的入侵还是宣告了——这不过是危地马拉漫长黑暗历史中的一个小插曲。就这样，十年改革成果被悉数奉还，土改所分配的土地被交还给地主和联合果品，军事独裁阴影再次笼罩于该国上空，一切都仿佛从未来过。\n但是，危地马拉人民绝不会屈从于帝国主义强加的和平。于是乎，尽管军政府和独裁者如走马灯般更换，但每一任考迪罗们都得面临一个严峻问题——日益壮大的左翼游击队。在漫长的革命斗争中，逐渐形成了这几个左翼派别：受苏联承认的危地马拉劳动党（PGT）中央委员会派，由该党分裂出的坚持武装斗争的激进派别危地马拉劳动党-全国指导核心（PGT-NDN），脱胎自军队左翼起义的游击队“武装反叛部队”（FAR），以及由其中分裂出来的两个左翼游击队——罗兰多·莫兰指挥官的贫民游击军（EGP）和主要由玛雅人组成、由著名文学家米格尔·安赫尔·阿斯图里亚斯的儿子罗德里戈·阿斯图里亚斯（化名加斯巴尔·伊龙来自其父亲的小说《玉米人》）指挥的武装人民组织（ORPA）。1982年2月8日，为协调游击队行动、统一政治军事力量，在古巴的斡旋下，危地马拉的各左翼游击队组成了一个统一的伞形组织——危地马拉全国革命联盟。\n哪怕联合果品公司的衰弱也只是把该国的主人换成了格蒂石油公司、德士古公司和国际镍公司。为了在横断北部地带发现的丰富石油矿藏，将军们摧毁了许多印第安公社，把更多的人逐出家园，被剥夺一切、饥肠辘辘的基切玛雅人成了游击队中最坚定的革命力量。\n而军政府对游击队的应对措施也很简单——只要把当地化为“焦土”，游击队便无处藏身了。通过大规模行动的焦土政策和反共民兵“敢死队”，军政府确实取得了可观的成效，自1954年至1982年，因内战而死的危地马拉人已达十余万（而这个小国只有不足七百万人），第一代游击队FAR的领导人容·索萨和图西奥斯·利马也身死于战场，但很快，EGP等第二代游击队便从FAR的尸骸上成立并迅速发展。\n1982年3月23日，为“结束腐败”，一群青年军官发动政变推翻了总统罗密欧·卢卡斯·加西亚将军，随后，在军队中深孚众望的国防部长里奥斯·蒙特将军被推举为领袖，与奥拉西奥·马尔多纳多·沙德将军、弗朗西斯科·路易斯·戈迪略上校组成了三头执政同盟，新政府宣布解散国会，废除宪法，呼吁“尊重所有危地马拉人的人权”，特赦了一万五千多名游击队员并寻求与URNG展开谈判。尽管这遭到了游击队的激烈反对，但也许这会是个改变危地马拉的惨烈内战现状的好机会。"
const TXT_OPT0 := "而战斗已经打响了。"
const TXT_OPT0_DIS := "我们为什么要支持流匪？"
const TXT_OPT1 := "也许我们该试着促成游击队与军政府的和谈？"
const TXT_OPT1_DIS := "可他们手上沾满了鲜血！"
const TXT_OPT2 := "全力支持里奥斯·蒙特总统先生"
const TXT_OPT2_DIS := "为什么要支持这个刽子手？"
const TXT_OPT3 := "危地马拉？与我无关"
const TXT_MASSACRE := "军政府摆出的“民族和解”姿态并没有得到游击队的响应，因此，蒙特将军很快便撕下了面具，放弃了模糊不清的纲领并转而以强硬的反共主义替代。1982年6月9日，里奥斯·蒙特任命自己为国家元首，7月1日，宣布全国戒严，开始“最后的战斗”。五分之三的军队被调往该国西北部镇压叛乱，并成立了由总统任命的特别法庭，该机构有权不经过任何法律手段对“颠覆分子”判处死刑。为了切断在玛雅人聚居区中如鱼得水的游击队的“水源”，在“步枪与豆子”的口号下，军政府制定了通过改善政府提供给玛雅村庄的基础设施和资源来增加军民接触与合作的计划，并在农村中建立了反共民兵“民防巡逻队”，与游击队有联系的村庄则被摧毁，这在短短几个月间便造成了超过一万名玛雅农民的死亡与十余万人的流离失所。"
const TXT_MASSACRE_REAGAN := "军政府的恶劣人权记录与蒙特将军拒绝举行选举导致危地马拉甚至遭到了美国国会的反对，而罗纳德·里根则绕过国会向军政府提供援助，以色列也向危地马拉提供了武器装备与军事训练。"
const TXT_MASSACRE_CARTER := "军政府的恶劣人权记录与蒙特将军拒绝举行选举导致危地马拉甚至遭到了美国国会的反对，因此，吉米·卡特总统被迫停止了向军政府的援助，然而cia仍然通过以色列向危地马拉提供武器装备与军事训练。"
const TXT_R0_END := "不过，这位“玛雅人屠夫”的所作所为是显而易见的结果。而我们则向URNG提供了军事训练与援助，趁机扩大游击队控制区并展开了大规模的宣传工作。就让我们静待游击运动花朵的绽放吧……"
const TXT_R1_BASE := "事实证明，我们做错了。\n尽管URNG内部对军政府疑虑重重，但在我们的大力推动下，还是成功促成了革命者与新政府的和谈。该谈判于伊斯坎丛林中举行。\n而接下来发生的事情很快便给我们上了一课。在谈判中，里奥斯·蒙特将军要求游击队放下一切武装无条件投降，并拒绝URNG提出的“以合法政党形式活动”的要求，而这种要求自然遭到了URNG的激烈反对，于是，和谈破裂。就这样不欢而散后，URNG代表团在归途中遭遇了政府军的袭击，尽管最终还是突破了包围圈，但仍然造成了极其惨重的损失，数名游击队核心人物与中坚干部战死。而蒙特将军则彻底撕下了“民族和解”的面具，放弃了模糊不清的纲领并转而以强硬的反共主义替代。1982年6月9日，里奥斯·蒙特任命自己为国家元首，7月1日，宣布全国戒严，开始“最后的战斗”。五分之三的军队被调往该国西北部镇压叛乱，并成立了由总统任命的特别法庭，该机构有权不经过任何法律手段对“颠覆分子”判处死刑。为了切断在玛雅人聚居区中如鱼得水的游击队的“水源”，在“步枪与豆子”的口号下，军政府制定了通过改善政府提供给玛雅村庄的基础设施和资源来增加军民接触与合作的计划，并在农村中建立了反共民兵“民防巡逻队”，与游击队有联系的村庄则被摧毁，这在短短几个月间便造成了超过一万名玛雅农民的死亡与十余万人的流离失所。"
const TXT_R2_A := "里奥斯·蒙特将军上任第二天，我们便承认了新政府，邀请他对我国进行一次国事访问。而中国的一切无不令将军阁下啧啧称奇，在招待宴席上，蒙特总统高度赞扬了"
const TXT_R2_B := "同志，酒过三巡后，他说出了这样一番话“我看中国搞得不错，利润极大丰富，共产党人基本消灭，对美关系也受重视，如果加上军政府执政，中国简直就是我们理想中的社会”。回国后，蒙特立即宣布同台湾当局断交，承认中华人民共和国为唯一合法政府，并与我国签署了几张合作协议。\n不过，军政府摆出的“民族和解”姿态并没有得到游击队的响应，因此，蒙特将军很快便撕下了面具，放弃了模糊不清的纲领并转而以强硬的反共主义替代。1982年6月9日，里奥斯·蒙特任命自己为国家元首，7月1日，宣布全国戒严，开始“最后的战斗”。五分之三的军队被调往该国西北部镇压叛乱，并成立了由总统任命的特别法庭，该机构有权不经过任何法律手段对“颠覆分子”判处死刑。为了切断在玛雅人聚居区中如鱼得水的游击队的“水源”，在“步枪与豆子”的口号下，军政府制定了通过改善政府提供给玛雅村庄的基础设施和资源来增加军民接触与合作的计划，并在农村中建立了反共民兵“民防巡逻队”，与游击队有联系的村庄则被摧毁，这在短短几个月间便造成了超过一万名玛雅农民的死亡与十余万人的流离失所。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var usa_rel := ws.empires[0].relations if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 0:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line > 2 and usa_rel >= 500:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var guatemala := ws.get_country_by_legacy_index(149)
	var usa_leader := ws.empires[0].current_leader if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var president_tail := TXT_MASSACRE_REAGAN if usa_leader == 0 else TXT_MASSACRE_CARTER
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_MASSACRE + "\n" + president_tail + "\n" + TXT_R0_END
			if guatemala != null:
				guatemala.level_of_instability += 50
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			ws.influence_prc += 5
			_add_power(EmpireData.USA, -5)
			_add_relation(EmpireData.USA, -50)
		1:
			context["result_text"] = TXT_R1_BASE + "\n" + president_tail
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if guatemala != null:
				guatemala.level_of_instability -= 50
			_add_power(EmpireData.USA, 5)
			ws.influence_prc -= 5
		2:
			context["result_text"] = TXT_R2_A + _leader_name() + TXT_R2_B + "\n" + president_tail
			_add(W.I_BUDGET, -20)
			if guatemala != null:
				guatemala.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, 5)
			_add_relation(EmpireData.USA, 80)
		3:
			context["result_text"] = TXT_MASSACRE + "\n" + president_tail
			_add_power(EmpireData.USA, 5)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19820323:
		return false
	var guatemala := world.get_country_by_legacy_index(149)
	return guatemala != null and world.is_authoritarian(guatemala)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
