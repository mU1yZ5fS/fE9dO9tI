extends "res://数据脚本/event_script_base.gd"

## 原作 1977 年自动事件 33–41 的结果逻辑。
## 来源：TimeScript.cs:3732-3784，doneventscript.cs:895-1170，
##       Event33-41.cs / Results_text.cs:2907-3681。
## 差异：
##  - 事件36 选项3、事件37 选项0 的禁用文案由 prepare 动态设置；
##  - OilProd 已建模（ws.oil_prod），Event36 两个选项各 +200；
##  - allcountries[69].numberOfSpecialEnding → tibet.special_ending。

const TXT_36_R2_BASED := "意识到萨达姆的野心，以及出于在各个阵线上尽可能的反对苏联扩张，并且武装了伊拉克共产党之后，我们认为现在是时候将伊拉克掀个底朝天了。外联部的同志面见了两个伊拉克共产党的领导人们，流亡在叙利亚的左翼复兴党成员马哈茂德·拉沙德·谢赫·拉迪、法齐·穆特拉克·拉维和马哈茂德·沙姆萨博士；复兴党内的马克思主义异见者；伊拉克革命劳动党和伊拉克革命共产党的残余成员也纷纷表示了合作的意愿；阿拉伯社会主义行动党的伊拉克支部同意了展开外围的合作，但希望不要破坏其与巴勒斯坦方面的友好关系即不要过分刺激萨达姆。以及一部分仍然在活动的少数民族抵抗组织，如库尔德斯坦爱国联盟和库尔德斯坦民主同盟的代表。我们诚挚的邀请他们就组建反抗萨达姆的社会法西斯政权组建统一战线。作为回报，我国和叙利亚将不遗余力的援助他们，在北京和大马士革设立办公室，并在叙利亚设置训练基地，我们将承担一切武器。很快，多方就组建“伊拉克爱国民主同盟”达成了一致。他们甚至引入了一些毛主义原则如“三大纪律八项注意”，农村包围城市，日常召开的批判大会，对《选集》的研究和农村工作队。该组织的长期目标是建立一个科学社会主义的伊拉克共和国，短期目标则是在伊拉克北部建立稳定的解放区。库尔德人，伊拉克共产党的游击队和倒戈的部分政府军被改组为伊拉克人民解放军。由自斋月革命以来就抵抗着政府的老将，同时也是亚述少数族裔的阿卜约瑟夫指挥。复兴党当局对于我们支持武装反对派非常不高兴，他要求莫斯科方面为其提供更多装备，并且在复兴党的代表大会上一个一个揪出了他所认为的反对派，伊拉克陷入了新的一轮恐慌和不稳定中。伊拉克共产党也被勒令解散，新政府以前所未有的力量压制共产主义者。"

const TXT_36_R2_NOT_BASED := "萨达姆的野心必须被遏制，这也是为什么我们要不遗余力的对抗该政权作为回报，我国和叙利亚将不遗余力的援助他们，在北京和大马士革设立办公室，并在叙利亚设置训练基地，我们将承担一切武器开销。我们依然支持伊拉克共产党中最为强大的一支力量——中央委员会派库尔德人，伊拉克共产党的游击队和倒戈的部分政府军被改组为伊拉克民族解放军。由自斋月革命以来就抵抗着政府的老将，同时也是亚述少数族裔的阿卜·约瑟夫指挥。但很快，由于又一次的路线之争，伊拉克共产党的三个派系很快就陷入了矛盾之中。据说，克格勃间谍也开始了浑水摸鱼……复兴党当局对于我们支持武装反对派非常不高兴，并要求莫斯科方面为其提供更多装备，并且在复兴党的代表大会上一个一个揪出了他所认为的反对派，伊拉克陷入了新的一轮恐慌和不稳定中。伊拉克共产党也被勒令解散，新政府以前所未有的力量压制共产主义者。"

const TXT_36_OPT3_DIS_LINE0 := "别忘了他们的“教友”对西路军犯下的罪行！"
const TXT_36_OPT3_DIS_LINE4 := "他们可是美国人榜上有名的恐怖组织！"
const TXT_36_OPT3_DIS_OTHER := "不要和神棍们打交道！"
const TXT_36_OPT3_ACTIVE := "开始接触达瓦党，说不定会有用"

const TXT_37_R1_SUCCESS := "我们最终决定通过利比亚和叙利亚来干涉埃及内政。利比亚和叙利亚在我们的帮助和苏联克格勃的秘密批准下，联合起来制订了一项消灭埃及总统的计划。不久，利比亚和叙利亚就派遣民兵和特工秘密进入埃及进内，混入抗议者的队伍，并秘密向抗议者提供武器。而克格勃特工则通过埃及共产党和民族统一进步党的组织网络串联起抗议者，并将他们吸收入组织之内。10月19日，安瓦尔·萨达特在开罗解放广场对埃及抗议者讲话时被一名愤怒的抗议者枪击，当场身亡；而抗议者组织的民兵冲入位于开罗的政府机构，强行解除了萨达特的亲信们的职务，埃及进入了事实上的小型内战中。在叙利亚、利比亚、我们和苏联的支持下，抗议者取得了胜利。最终，经过多方妥协，前副总统、纳赛尔主义者阿里·萨布里成为了埃及新总统，而民族统一进步党的领导人哈立德·毛希丁在苏联人的支持下成为了总理，新政权由纳赛尔主义者、民族统一进步党和埃及共产党组成的阿拉伯埃及人民民主团结阵线领导。新政府开始恢复泛阿拉伯主义的宣传，并重启在阿拉伯共和国联邦中的活动，恢复同苏联、中国、利比亚、叙利亚、伊拉克和其他社会主义国家的友好关系。与此同时，新总统还宣布取消“开放”政策和经济自由化，重启世俗化、打压伊斯兰主义者并在政治上比纳赛尔时期更加左倾和开明。萨布里已经恢复了与苏联关于恢复经济和军事技术合作的谈判，至此，埃及再次转向左翼——但不是转向我们的方向……"

const TXT_37_R1_FAILURE := "我们最终决定通过利比亚和叙利亚来干涉埃及内政。利比亚和叙利亚在我们的帮助和苏联克格勃的秘密批准下，联合起来制订了一项消灭埃及总统的计划。10月25日，安瓦尔·萨达特在开罗解放广场对埃及抗议者讲话时被一名利比亚狙击手击毙。埃及新总统是他的助手胡斯尼·穆巴拉克，他放弃了深化改革，转而采取多途径外交政策，尽管保留了反苏的基调。埃及与阿拉伯邻国的关系逐渐正常化。"

const TXT_37_OPT0_DIS := "对埃及内政的干涉太激进了！"
const TXT_37_OPT0_ACTIVE := "用一切手段去支持抗议者煽动推翻萨达特政权，并帮助纳赛尔主义者重掌权力"

const TXT_39_R2_BASE := "没了党内纪律的约束，准备筹建《决议》起草委员会的会议很快便炸开了锅，没多久便成了老干部们的诉苦现场——这些早在土地革命时期参加中共事业的“中版老布尔什维克”可受不了“文化大革命”时期的被迫靠边与紧随其后的政治迫害，上述经历只会让其觉得“伟大领袖”不过是卸磨杀驴的两面派，而刚得到平反消息官复原职的他们没多久便占据了会议的主流。叶剑英的意气发言（即将毛时代政治实践称之为“封建法西斯专政”）更是引来场上掌声不断。最终，党会议以多数表决将曾长期主持首都党务工作，并在“文革”时期首当其冲的彭真推上《决议》起草委员会主要负责人一职。他很快便伙同自己传媒界内的同僚们将老干部们的复仇愿望转化为了现实：建国以来的一系列悲剧均被归结于“抛弃集体领导，践踏法治原则”的一系列政治冲动，而毛泽东正是这一股思潮的代表——他最大的过错便在于没能实现从中共由“革命党”到“执政党”的转型，并痴迷于采用命令式的军事动员与战时突击方法掌管全国，将革命战争时期的三人团、小圈子与军事专断等经验神圣化。而这恰是国内各类冤假错案、政治迫害与个人崇拜乱象的起源。因此，有必要树立起“真理面前人人平等，法律面前人人平等”的价值观，并以建立集体领导，形成相应制度的方式彻底断绝个人独大可能。虽说这份文件决绝地同过往的各项实践与乱象做了切割，可考虑到它的严厉措辞、坚决态度与其中满溢出的价值判断，并不能指望这份“中国版本的秘密报告”能对通常党员与普通群众有多少规范作用。"

const TXT_39_R2_MAUSOLEUM := "文件通过后的当晚，毛泽东的遗体被从纪念馆中移走，之后第二天这座建筑就被拆除了。在纪念馆的废墟上，将修建一座关于中共第一任总书记陈独秀的博物馆，他曾被指控为优柔寡断，后来又站在了托洛茨基反对派那边。"

const TXT_40_R1_REJECT := "确吉坚赞断然拒绝接受这一条件，理由是我们对西藏神职人员的压迫很严重。好吧，这是他自找的——让他在秦城待到他尘世的尽头吧……"

const TXT_40_R1_ACCEPT := "确吉坚赞最后同意这个条件，要求我们转告同志，总的来说，他赞同国家对待西藏僧侣的政策，同时他还向我们保证了他以后不会再参加宗教团体了。这之后他在整个中国游历，并与一名解放军战士李洁结婚。他在1981年正式的恢复名誉并回到了拉萨，之后甚至在西藏自治区的人大代表选举中当选为全国人大代表之一。"

const TXT_40_R3_SUCCESS := "回到拉萨之后，十世班禅对外界宣布他对中国政府没有任何不满，对他的囚禁使得他能思考他之前作为一个西藏人民的剥削者所犯下的种种罪孽，这使他更加的理解了佛法。在重新安葬了因扎什伦布寺被破坏而无处安葬的前几代班禅喇嘛的遗体之后，确吉坚赞现在的任务是参加慈善活动，访问（经苏联领导层同意）卡尔梅克、布里亚特和图瓦苏维埃自治社会主义共和国和向这些蒙古族自治共和国传播佛法，帮助西藏与这些苏维埃自治共和国建立宗教联系。人民和国际社会都很满意。"

const TXT_40_R3_FAILURE := "班禅喇嘛从未忘记中央政府是如何虐待他的，在回到拉萨后，十世班禅很快开始四处发表反动言论，例如“我能出来当然是好的，我在监狱中有着很多的思考，不过为了这些思考我付出了太大的代价。”，并开始与达赖喇嘛建立了联系。现在国际社会无不在谴责我们对西藏自治区的政策。最后当最高人民法院想重新逮捕他时，他逃到了不丹，之后移动到印度，加入了印度支持的“西藏流亡政府”，印度政府拒绝把他移交给我们，现在藏独分子手中又多了一个显赫的人物，这对我们无疑是不利的。"


## 原版 Event36 TextOfEvents 的条件/末段描述（事件描述静态化后保留逐字文案备查）。
const TXT_36_DESC_BASED_1 := "现在，随着我们事实上成为了伊拉克共产主义运动的大金主，更为激进的中央委员会派成员已经架空了阿齐兹，并愿意推行暴力的武装活动。"
const TXT_36_DESC_BASED_2 := "同时，斋月革命之后与原先的共产党决裂的“伊拉克共产党——中央指挥部”派则更推行类似中国的武装革命道路，直到与1968年，其高级成员被一举粉碎后再起不能，虚弱的中央指挥部派无力再度掀起革命。"
const TXT_36_DESC_BASED_3 := "随着我们的资金通过叙利亚的渠道再度就位，他们大有和巴尔扎尼的后人们统一战线的机会。复兴幼发拉底游击区和库尔德游击区不再是不可能的事情，但这都需要我们的支持。"
const TXT_36_DESC_DAWA := "除了复兴党和伊拉克的共产主义者以外，我们还有一个可能的战友。由神学生巴克尔·萨德尔依托列宁主义原则后改组的伊斯兰民粹主义政党——伊斯兰达瓦党（您在世界知识上看到的是另一种译名：伊斯兰号召党）是该国什叶派信徒的最大公约数。以全国近六成的民众为基本盘，该党是复兴主义政权的眼中钉，肉中刺。该党与伊朗的阿亚图拉霍梅尼关系紧密，其在什叶派民众中的强大号召力招致了复兴主义政府的担心和强力弹压。多名成员被伊拉克官方暗杀。达瓦党的纲领相对温和，其致力于推行一种夹带了伊斯兰主义元素的民主主义政策。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var dpre: Array[int] = world.数值表
	if event_def.event_id == "iraqi_coalition" and event_def.options.size() >= 4:
		var line36: int = dpre[W.I_POLITICAL_LINE]
		var religion36: int = dpre[W.I_RELIGION]
		var opt36 := event_def.options[3]
		if line36 > 0 and line36 < 4 and religion36 > 25:
			_enable(opt36, TXT_36_OPT3_ACTIVE)
		elif line36 == 0:
			_disable(opt36, TXT_36_OPT3_DIS_LINE0)
		elif line36 == 4:
			_disable(opt36, TXT_36_OPT3_DIS_LINE4)
		else:
			_disable(opt36, TXT_36_OPT3_DIS_OTHER)
	if event_def.event_id == "egyptian_unrest" and event_def.options.size() >= 1:
		var egypt37 := world.get_country_by_legacy_index(30)
		var ok37 := dpre[W.I_AGENTS] >= 60 and dpre[W.I_POLITICAL_LINE] <= 2 \
				and egypt37 != null and egypt37.stab == 1
		var opt37 := event_def.options[0]
		if ok37:
			_enable(opt37, TXT_37_OPT0_ACTIVE)
		else:
			_disable(opt37, TXT_37_OPT0_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"pakistan_coup": _event_33(option_index)
		"enemies_of_my_enemies": _event_34(option_index)
		"end_of_revolution": _event_35(option_index)
		"iraqi_coalition": _event_36(option_index, context)
		"egyptian_unrest": _event_37(option_index, context)
		"back_to_roots": _event_38(option_index)
		"historical_resolution": _event_39(option_index, context)
		"panchen_lama": _event_40(option_index, context)
		"indian_elections": _event_41(option_index)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_33(option_index: int) -> void:
	var pakistan := ws.get_country_by_legacy_index(31)
	match option_index:
		0:
			_add_empire_power(EmpireData.USA, 30)
			d[W.I_THOUGHT_FREEDOM] += 30
			if pakistan != null:
				pakistan.government = 0
				pakistan.sub_government = 7
				pakistan.set_tag("亲美", true)
				pakistan.set_tag("亲中", false)
				pakistan.set_tag("对华贸易", false)
		1:
			_add_empire_relation(EmpireData.USA, -100)
			_add_data({W.I_INFLUENCE: 20, W.I_AGENTS: -60, W.I_BUDGET: -30})
			if pakistan != null:
				pakistan.government = 2
				pakistan.sub_government = 3
				pakistan.set_tag("亲美", false)
				pakistan.set_tag("亲中", true)
				pakistan.set_tag("sento", false)  # 帮助布托后巴基斯坦退出中央条约（CENTO）
				pakistan.prc_power = 1000
			_subtract_faction_fraction(FactionData.LIBERAL, 0.25)
		2:
			d[W.I_THOUGHT_FREEDOM] += 50
			_add_empire_relation(EmpireData.USA, 50)
			_add_empire_relation(EmpireData.USSR, -50)
			_add_empire_power(EmpireData.USA, 20)
			if pakistan != null:
				pakistan.government = 0
				pakistan.sub_government = 7
				pakistan.set_tag("亲美", true)
				pakistan.set_tag("亲中", false)


func _event_34(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: -100, W.I_PEOPLE_SUPPORT: -50})
			_subtract_faction_fraction(FactionData.REFORMIST, 0.50)
			_subtract_faction_fraction(FactionData.MODERATE, 0.15)
			_change_politicians({2: [-100, 0], 0: [100, 0]})
			_add_power_by_index({7: -100, 6: -100})
		1:
			d[W.I_PARTY_SUPPORT] -= 100
			_add_faction_ideology({FactionData.CONSERVATIVE: 400})
			_change_politicians({0: [100, 0]})
			_add_power_by_index({5: 100, 8: 100, 9: 100})
		2:
			_add_data({W.I_PARTY_SUPPORT: -150, W.I_PEOPLE_SUPPORT: -50,
				W.I_THOUGHT_FREEDOM: 50, W.I_DIPLO: 20})
			_add_faction_ideology({FactionData.CONSERVATIVE: 400})
			_subtract_faction_fraction(FactionData.REFORMIST, 0.10)
			_subtract_faction_fraction(FactionData.MODERATE, 0.15)
			_change_politicians({2: [-200, 0], 0: [150, 0]})
			_add_power_by_index({6: -150, 7: -150})
		3:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_PEOPLE_SUPPORT: 50,
				W.I_THOUGHT_FREEDOM: 80, W.I_DIPLO: -20})
			_add_faction_ideology({FactionData.REFORMIST: 500})
			_change_politicians({2: [200, 120], 3: [0, 70], 0: [-200, 0]})
		4:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_THOUGHT_FREEDOM: 30})
			_add_faction_ideology({FactionData.REFORMIST: 200})
			_change_politicians_at_least(2, 0, 70)


func _event_35(option_index: int) -> void:
	match option_index:
		0:
			_add_data({W.I_THOUGHT_FREEDOM: 40, W.I_PEOPLE_SUPPORT: -60})
			_change_politicians_at_least(1, -100, 0)
		1:
			_add_data({W.I_PEOPLE_SUPPORT: 60, W.I_THOUGHT_FREEDOM: 20,
				W.I_MANPOWER: -30, W.I_DIPLO: -20})
			_clamp_at_least(W.I_PRESS_POLICY, 17)
			_liberalization_party_effects(50, 30)
		2:
			_add_data({W.I_PEOPLE_SUPPORT: 70, W.I_THOUGHT_FREEDOM: 40, W.I_DIPLO: -30})
			_clamp_at_least(W.I_PRESS_POLICY, 17)
			_clamp_at_least(W.I_RELIGION, 25)
			_liberalization_party_effects(80, 30)
		3:
			_add_data({W.I_PEOPLE_SUPPORT: 90, W.I_THOUGHT_FREEDOM: 60, W.I_DIPLO: -40})
			_clamp_at_least(W.I_PRESS_POLICY, 17)
			_clamp_at_least(W.I_RELIGION, 26)
			_liberalization_party_effects(80, 50)


func _event_36(option_index: int, context: Dictionary) -> void:
	var iraq := ws.get_country_by_legacy_index(14)
	match option_index:
		0:
			_add_data({W.I_BUDGET: -50, W.I_AGENTS: -50})
			if iraq != null:
				_leave_alliances(iraq)
				iraq.government = 2
				iraq.sub_government = 15
				iraq.set_tag("对华贸易", true)
			ws.oil_prod += 200.0  # Event36.cs result0：扩大石油出口
			d[W.I_INFLUENCE] += 10
			_add_empire_relation(EmpireData.USSR, -50)
		1:
			_add_data({W.I_BUDGET: -50, W.I_AGENTS: -50})
			if iraq != null:
				_leave_alliances(iraq)
				iraq.government = 0
				iraq.sub_government = 10
				iraq.set_tag("对华贸易", true)
			ws.oil_prod += 200.0  # Event36.cs result1：扩大石油出口
			d[W.I_INFLUENCE] += 10
			_add_empire_relation(EmpireData.USSR, -50)
		2:
			if iraq != null:
				iraq.government = 0
				iraq.sub_government = 10
				iraq.set_tag("对华贸易", false)
				iraq.prc_power = 10
			_add_data({W.I_PARTY_SUPPORT: 70, W.I_THOUGHT_FREEDOM: -30,
				W.I_BUDGET: -50, W.I_AGENTS: -50})
			if iraq != null and iraq.有驻军基地:
				context["result_text"] = TXT_36_R2_BASED
			else:
				context["result_text"] = TXT_36_R2_NOT_BASED
		3:
			if iraq != null:
				iraq.government = 0
				iraq.sub_government = 10
				iraq.prc_power = 20
			_add_data({W.I_BUDGET: -50, W.I_AGENTS: -50})
		4:
			if iraq != null:
				iraq.government = 0
				iraq.sub_government = 10


func _event_37(option_index: int, context: Dictionary) -> void:
	var egypt := ws.get_country_by_legacy_index(30)
	var libya := ws.get_country_by_legacy_index(13)
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_INFLUENCE: 20,
				W.I_AGENTS: -60, W.I_BUDGET: -40})
			_add_empire_relation(EmpireData.USA, -150)
			_add_empire_relation(EmpireData.USSR, 80)
			_add_empire_power(EmpireData.USA, -10)
			if egypt != null:
				egypt.government = 2
				egypt.sub_government = 15
				egypt.set_tag("亲美", false)
				egypt.set_tag("对华贸易", true)
		1:
			var success := (libya != null and libya.has_tag("对华贸易")) or (egypt != null and egypt.stab == 1)
			_add_data({W.I_AGENTS: -20, W.I_BUDGET: -20})
			if success:
				context["result_text"] = TXT_37_R1_SUCCESS
				_add_data({W.I_PARTY_SUPPORT: 20, W.I_INFLUENCE: 10})
				_add_empire_power(EmpireData.USSR, 20)
				_add_empire_power(EmpireData.USA, -20)
				_add_empire_relation(EmpireData.USSR, 50)
				if egypt != null:
					egypt.government = 2
					egypt.sub_government = 3
					egypt.set_tag("亲苏", true)
					egypt.set_tag("亲美", false)
			else:
				context["result_text"] = TXT_37_R1_FAILURE
				_add_empire_power(EmpireData.USA, -10)
				if egypt != null:
					egypt.set_tag("亲美", false)
		2:
			_add_data({W.I_AGENTS: -20, W.I_BUDGET: -20})
		3:
			_add_data({W.I_AGENTS: -20, W.I_BUDGET: -20})
		4:
			pass


func _event_38(option_index: int) -> void:
	match option_index:
		0:
			pass
		1:
			_add_data({W.I_BUDGET: -10, W.I_DIPLO: 20, W.I_THOUGHT_FREEDOM: 50,
				W.I_PEOPLE_SUPPORT: -40})
			_add_empire_relation(EmpireData.USA, -70)
			_add_empire_relation(EmpireData.USSR, 50)
			d[W.I_ECON_SYSTEM] = 10
			_add_faction_ideology({FactionData.MAOIST: 250, FactionData.CONSERVATIVE: 250})
			_change_politicians({0: [100, 0], 1: [-30, 0], 2: [-100, 0]})
		2:
			_add_data({W.I_DIPLO: -10, W.I_THOUGHT_FREEDOM: 20, W.I_PEOPLE_SUPPORT: 30})
			_add_empire_relation(EmpireData.USSR, -70)
			_add_empire_relation(EmpireData.USA, 80)
			d[W.I_ECON_SYSTEM] = 12
			_add_faction_ideology({FactionData.MODERATE: 450, FactionData.REFORMIST: 450})
			_change_politicians({2: [150, 100], 1: [70, 50], 0: [-170, -100]})


func _event_39(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 80, W.I_PEOPLE_SUPPORT: 20, W.I_DIPLO: 10})
			d[W.I_MAO_HISTORY_LINE] = 0
			_add_faction_ideology({FactionData.MAOIST: 150, FactionData.CONSERVATIVE: 150})
			_change_politicians({0: [100, 30], 1: [60, 20], 2: [50, 0], 3: [-100, -30]})
			var kill_index := _find_politician(13, 13)
			if kill_index >= 0:
				GameManager.kill_politician(kill_index)
		1:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_PEOPLE_SUPPORT: 50,
				W.I_DIPLO: -30, W.I_COMMUNICATIONS: 20})
			d[W.I_MAO_HISTORY_LINE] = 1
			_add_faction_ideology({FactionData.MAOIST: 150, FactionData.CONSERVATIVE: 150})
			_change_politicians({0: [50, 10], 1: [100, 40], 2: [80, 30], 3: [60, 0]})
		2:
			if d[W.I_MAO_MAUSOLEUM] == 10:
				d[W.I_MAO_MAUSOLEUM] = 9
				context["result_text"] = TXT_39_R2_BASE + "\n" + TXT_39_R2_MAUSOLEUM
			else:
				context["result_text"] = TXT_39_R2_BASE
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_PEOPLE_SUPPORT: -50, W.I_DIPLO: -60})
			d[W.I_MAO_HISTORY_LINE] = 2
			_add_faction_ideology({FactionData.REFORMIST: 150, FactionData.LIBERAL: 100})
			_change_politicians({0: [-150, 0], 1: [-100, 0], 2: [50, 0], 3: [150, 0]})


func _event_40(option_index: int, context: Dictionary) -> void:
	var tibet := ws.get_country_by_legacy_index(69)
	match option_index:
		0:
			_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: -50, W.I_DIPLO: 5})
		1:
			if d[W.I_RELIGION] <= 25:
				_add_data({W.I_PARTY_SUPPORT: 50, W.I_PEOPLE_SUPPORT: -60,
					W.I_DIPLO: 10, W.I_MANPOWER: -50, W.I_INFLUENCE: -10})
				context["result_text"] = TXT_40_R1_REJECT
			else:
				_add_data({W.I_PEOPLE_SUPPORT: 60, W.I_INFLUENCE: 10,
					W.I_MANPOWER: 40, W.I_DIPLO: -20})
				_add_empire_relation(EmpireData.USA, 50)
				if tibet != null:
					tibet.special_ending = 33
				context["result_text"] = TXT_40_R1_ACCEPT
		2:
			_add_data({W.I_PEOPLE_SUPPORT: 80, W.I_INFLUENCE: 10,
				W.I_MANPOWER: 40, W.I_AGENTS: -40, W.I_DIPLO: -20})
			_add_empire_relation(EmpireData.USA, 100)
			if tibet != null:
				tibet.special_ending = 33
		3:
			if d[W.I_RELIGION] >= 26 and d[W.I_PEOPLE_SUPPORT] >= 700:
				_add_data({W.I_INFLUENCE: 10, W.I_PEOPLE_SUPPORT: 120,
					W.I_DIPLO: -20, W.I_MANPOWER: 40})
				_add_empire_relation(EmpireData.USA, 120)
				_add_empire_relation(EmpireData.USSR, 50)
				if tibet != null:
					tibet.special_ending = 33
				context["result_text"] = TXT_40_R3_SUCCESS
			else:
				_add_data({W.I_PEOPLE_SUPPORT: -100, W.I_INFLUENCE: -20,
					W.I_MANPOWER: -100, W.I_DIPLO: 20})
				_add_empire_relation(EmpireData.USA, -100)
				context["result_text"] = TXT_40_R3_FAILURE
		4:
			_add_data({W.I_PARTY_SUPPORT: 100, W.I_INFLUENCE: -10,
				W.I_MANPOWER: -30, W.I_AGENTS: -70, W.I_BUDGET: -40,
				W.I_DIPLO: 20, W.I_PEOPLE_SUPPORT: -100})
			_add_empire_relation(EmpireData.USA, -100)


func _event_41(option_index: int) -> void:
	var india := ws.get_country_by_legacy_index(19)
	match option_index:
		0:
			d[W.I_INFLUENCE] += 10
			d[W.I_INDIA_ELECTION] = 2
			if india != null:
				india.set_tag("对华贸易", true)
		1:
			_add_data({W.I_PARTY_SUPPORT: 70, W.I_INFLUENCE: 20,
				W.I_BUDGET: -30, W.I_AGENTS: -50})
			d[W.I_INDIA_ELECTION] = 1
			_add_empire_relation(EmpireData.USSR, -70)
			if india != null:
				india.set_tag("对华贸易", true)
				india.set_tag("亲苏", false)
		2:
			_add_data({W.I_PARTY_SUPPORT: -50, W.I_AGENTS: -50, W.I_COMMUNICATIONS: 30})
			d[W.I_INDIA_ELECTION] = 3
			_add_empire_power(EmpireData.USSR, 20)
			_add_empire_relation(EmpireData.USSR, 100)


func _liberalization_party_effects(loyalty_delta: int, power_delta: int) -> void:
	_add_faction_ideology({FactionData.REFORMIST: 150, FactionData.MODERATE: 200})
	_change_politicians_at_least(1, loyalty_delta, power_delta)


func _clamp_at_least(index: int, value: int) -> void:
	if d.size() > index and d[index] < value:
		d[index] = value


func _add_data(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < d.size():
			d[index] += int(changes[raw_index])


func _change_politicians(changes: Dictionary) -> void:
	for politician in ws.politicians:
		if politician != null and changes.has(politician.trait_personality):
			var pair: Array = changes[politician.trait_personality]
			politician.loyalty += int(pair[0])
			politician.power += int(pair[1])


func _change_politicians_at_least(minimum: int, loyalty_delta: int, power_delta: int) -> void:
	for politician in ws.politicians:
		if politician != null and politician.trait_personality >= minimum:
			politician.loyalty += loyalty_delta
			politician.power += power_delta


func _add_power_by_index(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.politicians.size() and ws.politicians[index] != null:
			ws.politicians[index].power += int(changes[raw_index])


func _add_faction_ideology(changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.factions.size() and ws.factions[index] != null:
			ws.factions[index].ideology += int(changes[raw_index])


func _subtract_faction_fraction(faction_index: int, fraction: float) -> void:
	if faction_index >= 0 and faction_index < ws.factions.size() and ws.factions[faction_index] != null:
		var current := ws.factions[faction_index].ideology
		ws.factions[faction_index].ideology = current - int(float(current) * fraction)


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1



func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta




func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
