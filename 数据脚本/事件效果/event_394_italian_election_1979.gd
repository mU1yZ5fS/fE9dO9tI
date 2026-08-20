extends "res://数据脚本/event_script_base.gd"

## 原作 Event394.cs：1979年意大利选举（五选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - VasilyisGay → ws.get_flag("VasilyisGay")；
##  - 原版 iron_and_blood 成就 Set(122) 已接 Achievements；
##  - 原版 data.italy_power_172..data.short_sword_power 为 raw index，直访并注释；
##  - 原版 allcountries[85].inflCh → influence_china。

const TXT_DESC_V := "阿尔多·莫罗领导下新党运动的崛起事实上使1976年以来的议会格局彻底过时（相当数量的天主教民主党政客倒戈加入“民主替代”，可议会席位仍根据天民党分离前的模式进行编排。事实上无法反映民意），并进一步加剧了政府的合法性危机。不乏有意大利人调侃国内是“少数派议会加更少数派政府”。而试图在两大党间达成“历史性妥协”计划的破产和天主教民主党政权在今年初就欧洲一体化与国有企业改革等问题上的一言堂做法耗尽了意大利共产党的最后耐心。终于宣告了跛脚前进的“民族团结”阶段终结：1月31日，由于共产党重回反对派阵营，作为“弃权政府”领导人的朱利奥·安德烈奥蒂宣布辞职；而随后的数月内也未能产生一个足以得到广泛支持与普遍信任的政府组成模式：总统亚历山德罗·佩尔蒂尼即便是尝试将意大利民主社会党、意大利共和党带入联盟，也无济于事。根据恩里科·贝林格在1979年3月举行的共产党第十五次代表大会上传达的精神，党员应坚决拒斥一个没有共产党人参与的政府，并在回归反对派阵营的同时事实上奉行“民主替代”路线。至此将另起炉灶的计划上升为全党的统一行动（最终也促成了大联盟政府被否决）。针对这一局势，总统决定解散提前解散众议院并举行大选，并试图寻找新的组合可能。而“民主替代”与意大利社会党均对此渴望已久：前者迫不及待地想要在选举中测试自身实力，并完成对老朋友天民党的复仇；后者则从共产党内的变节分子与新方针中汲取力量，并通过同莫罗的联盟逐步站稳脚跟。这两个中左翼改革派政党希望动摇已延续30年的两党霸权的传统体制，将意大利共产党与天主教民主党拉下马。不过，直到结果水落石出前，都还没法完全下定论。而这就得看我们的布局能在多大程度上影响结果了。"
const TXT_DESC_391_1 := "试图在两大党间达成“历史性妥协”计划的破产和天主教民主党政权在今年初就欧洲一体化与国有企业改革等问题上的一言堂做法事实上耗尽了意大利共产党的最后耐心。终于宣告了所谓“民族团结”阶段终结：1月31日，由于共产党重回反对派阵营，作为“弃权政府”领导人的朱利奥·安德烈奥蒂宣布辞职；而随后的数月内也未能产生一个足以得到广泛支持与普遍信任的政府组成模式：总统亚历山德罗·佩尔蒂尼即便是尝试将意大利民主社会党、意大利共和党带入联盟，也无济于事。根据恩里科·贝林格在1979年3月举行的共产党第十五次代表大会上传达的精神，党员应坚决拒斥一个没有共产党人参与的政府，并在回归反对派阵营的同时事实上奉行“民主替代”路线。至此将另起炉灶的计划上升为全党的统一行动（最终也促成了大联盟政府以一票之差被否决）。针对这一局势，总统决定解散提前解散众议院并举行大选，并试图寻找新的组合可能。如此做法在右翼激进分子刺杀阿尔多·莫罗，且天民党对此决策失当，反应消极而被千夫所指；以及政府对亲右翼犯罪集团与恐怖组织调查的三心二意更加剧民众不满的大背景下将成为改变力量对比的关键。预计将导致大量的抗议票流向该国其他民主党派——分析人士认为，本就拥有雄厚群众基础的共产党最能借助这一优势继续攀登，并最终获得组建政府的机会？不过，直到结果水落石出前，都还没法完全下定论。而这就得看我们的布局能在多大程度上影响结果了。"
const TXT_DIS0 := "他们不需要我们的支持，而我们也没必要提供支持"
const TXT_DIS1 := "意大利不需要长颈鹿"
const TXT_DIS2 := "1968年早已成为过去式"
const TXT_DIS3 := "同新法西斯主义运动勾搭？党可不会作法自毙"
const TXT_R0 := "我们没理由抛弃70年代“一条线，一大片”外交路线的成果：对于我们而言，欧洲国家眼中的一个“正常化”的中国本身就意味着无限可能——进可达成多边合作关系，退亦不至于相互为敌。在超级大国争霸日益激烈，缓冲地带持续缩小，中国有可能卷入同霸权主义政权直接冲突的关键当头上。争取“第二世界”的支持显然极有必要。因此，作为意大利政坛招牌的天主教民主党得到了我国青睐，而他们也以数份对我国有利的合同做了回应。接下来就得看他们有没有把钱给花在刀刃上。"
const TXT_R1 := "意大利共产党自步入70年代以来便持续保持高歌猛进态势——该党不仅在废除离婚法的公投上加入进步阵营并收获空前声望，更在洛克希德丑闻中吃到了不少抗议天主教民主党接受外国军事公司贿赂并“窒息”国防工业的抗议票。所有这些与该党为契合公民政治而采取的改良主义纲领共同奠定了该党在1976年的空前胜利。如今的共产党距组建政权只差临门一脚，而我们在关键时刻的投资将如虎添翼。接下来就得看他们有没有把钱给花在刀刃上。"
const TXT_R2 := "虽说“火热之秋”与“铅色岁月”的高潮早已落幕，可意大利的激进主义运动与社会团体并不会轻易退出舞台：其中既包括倾向工人主义的自治组织，亦有鼓吹直接展开武装斗争的军事化团体。通过外联部同志的渠道，我们很快便与该国77年运动期间广泛兴起的自管社会中心建立了联系。借助激进活动家的地下据点与网络，我们得以直接支持最合乎我们口味的政治盟友，逐步改变意大利政治环境。出于掩护这批社会斗士的需要，我们同时渗透了意大利国家安全机构，不仅搅黄了其试图绞杀基层活动家的部分计划，更发现了外国势力插手该国内政的蛛丝马迹。至于选举，就让合法主义者们自娱自乐去罢——"
const TXT_R3 := "我们决定押注意大利的合法法西斯主义路线，并计划将意大利社会运动推上前台：该党的班底基本上可追溯至第二次世界大战时的意大利保守军官，社会共和国的残余与极端保守主义者。并在意大利共产党于北方城市区持续做大的背景下积极吸纳南方地主与小市民阶层。然而，意大利社会运动试图进入政府的尝试常遭碰壁，并在1975年废除《离婚法》失败与1976年大选失利后持续衰退。事实上作为边缘人。因此，我们的援助仅能保持该党不至在接下来的选举中进一步衰退，并尽可能在意大利营造一种“多党健康竞争”的生态——仅此而已。"
const TXT_R_V := "最终，选举结果如下：借助舆论内的“民族英雄”宣传与主流政党内变节者的倒戈，阿尔多·莫罗组建的“民主替代”在意大利议会选举中实现开门红，拿下28%的选票；紧随其后的则是同1976年相比党势急剧回落的意大利共产党，“历史性妥协”政策的破产与莫罗事件期间的消极反应深刻影响了选情，最终导致该党不仅失却了先前从市民处获得的同情票，更吃到了“反政治巨头垄断”的战略性反对票，获得26%。与此同时，意大利社会党则借助左翼阵营内此消彼长的态势迅速膨胀，选战成绩较先前增长一倍有余，以16%的成绩俨然成为该国第三大政党。最终则是因莫罗出走与舆论压制打击而一蹶不振，因此遭遇惨败的天主教民主党，仅获10%选票。同采取温和化纲领，试图同主流保守派竞争的意大利社会运动几乎相当。此次大选至此终结了天民党与共产党二分天下的格局，并引入了相对多元化的“可协商”形式。此情此景自然让议会最大党党魁阿尔多·莫罗回想到“中左翼公式”的成功经验，并使形成一个非共产党参与的稳定改良派政府成为可能：通过与意大利社会党和数个小党派建立联盟，阿尔多·莫罗得以建立起标榜更新意大利社会生态的新秩序，即便它看起来更像是先前双头共治的变体形式……与此同时，共产党作为民主左翼身份的落败亦加剧了左翼内部的激进情绪，“萨莱诺转向”的又一次威严扫地使议会外左翼与议会内极左翼政党的活跃度得到显著提升。"
const TXT_R_DC := "最终，选举结果如下：由于在“民族团结”时期的碌碌无为与莫罗事件期间的处置失当，意大利共产党不复往昔辉煌.而意大利社会党从“左翼替代”方向发起的攻势亦动摇了该党的市民基础，最终导致其处境进一步恶化，获票30%。与之相对的则是稳如泰山，以38%选票保持优势并位居老大党位置的天主教民主党。而贝蒂诺·克拉克西主导下的社会党亦在恢复元气，在吸收共产党方变节者与民主左翼支持者的基础上取得10%选票。共产党的回落与中间派的恢复正逐渐将该国拉回到1976年前的格局。然而，本次选举只是将两强对峙转为了更倾向于天民党一方的模式，并使共产党回到了反对派阵营。组建新政府的难题依旧未能解决。对此，作为“中左翼公式”变体的“多方联合”（即排斥共产党，囊括该国所有主要议会政党的大联盟政府）正在酝酿；而共产党则进一步转向了替代方案。意识到在现存制度框架下不可能同天民党达成广泛联盟并进入政府。共产党事实上终结了“历史性妥协”共识，转而采用“民主替代”的新口号。旨在创建用以夺权的左翼政党联盟。然而，共产党几乎找不到同路人。因为包括意大利社会党、意大利自由党、意大利民主社会党、意大利共和党等在内的该国其他主要政党均持有强烈的反共立场。且它们都更青睐于加入“多方联合”。与此同时，共产党作为民主左翼身份的落败亦加剧了左翼内部的激进情绪，“萨莱诺转向”的又一次威严扫地使议会外左翼与议会内极左翼政党的活跃度得到显著提升。"
const TXT_R_PCI := "最终，选举结果如下：意大利共产党保持1976年以来的高歌猛进态势，首次反超天主教民主党，赢下全国四成选票；而天主教民主党则因弃权派政府时期的政策失当，以及对“历史性妥协”路线的出尔反尔，事实上表露出反变革与反民族团结立场而遭受拖累，很快便成为该国选民眼中的众矢之的。该党选票至此回落至34%，以此位居第二。贝蒂诺·克拉克西试图从左翼替代与民主社会主义角度对共产党实施的挤压策略亦未取得明显成效，导致意大利社会党只得艰难维持现状，党势亦继续走低。仅获得5%选票。因此，意大利政治格局发生空前逆转：共产党首次取得大比分优势，并可基于此类“绝对多数”地位近乎任意安排新政府组成。考虑到恩里科·贝林格早在1975年便已通过“历史性妥协”和欧洲共产主义路线向大西洋世界表忠心（即意大利既不会退出北约组织，亦会在保持该国社会稳定的同时摆脱经济滞涨顽疾，实现企业家与工人的协力同行），并从外交战略家兹比格涅夫·布热津斯基处切实取得了美国政府背书。因此，建立西欧首个“民主共产主义”政权自是一片通途——近乎是在恩里科·贝林格就任总理的当日，曾暗中支持共产党的大金主们便纷纷在媒体前表示祝贺，连先前被迫结束同共产党蜜月期的菲亚特集团总裁贾尼·阿涅利亦出现在荧幕前重谈历史友谊，并表示“没有共产党就没有新意大利”。对此，新任劳工部长兼意大利总工会领导人卢西亚诺·拉玛亦热烈回应称：“我们将继续努力，坚决反对挥霍、寄生与怠工，并将拯救国家的斗争转化为第二次复兴运动！”。“新秩序”就这样开始了——"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	if ws.get_flag("VasilyisGay"):
		event_def.description = TXT_DESC_V
	elif int(world.completed_event_ids.get("event_391", 0)) == 1 			and int(world.completed_event_ids.get("event_392", 0)) != 1:
		event_def.description = TXT_DESC_391_1
	var opt := event_def.options
	if _d(W.I_POLITICAL_LINE) >= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_DIS0)
	if _d(W.I_POLITICAL_LINE) >= 2 and _d(W.I_POLITICAL_LINE) <= 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_DIS1)
	if _d(W.I_POLITICAL_LINE) <= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_DIS2)
	if _d(W.I_DIPLO) >= 800 and _d(W.I_WAR_SUPPORT) > 300 and _d(W.I_POLITICAL_LINE) <= 3:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_DIS3)
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	var opt := int(context.get("option_index", -1))
	if _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
		_add(176, -1)  # 原版 data.italy_power_176
	if italy != null and italy.has_tag("nato"):
		_add(175, 1)  # 原版 data.italy_power_175
	if ws.empires[EmpireData.USSR].power < ws.empires[EmpireData.USA].power:
		_add(175, 2)  # 原版 data.italy_power_175
	else:
		_add(176, 1)  # 原版 data.italy_power_176
	if portugal != null and portugal.government == GameConstants.Government.LIBERAL:
		_add(175, 1)  # 原版 data.italy_power_175
	if italy != null and italy.level_of_development >= 60:
		_add(175, 2)  # 原版 data.italy_power_175
	if italy != null and italy.level_of_development <= 60 and italy.level_of_development >= 20:
		_add(176, 2)  # 原版 data.italy_power_176
	if _d(134) < 60 and _d(134) >= 20:  # 原版 data.italian_radical_left_power
		_add(176, 1)  # 原版 data.italy_power_176
	elif _d(134) < 100 and _d(134) >= 60:  # 原版 data.italian_radical_left_power
		_add(176, -3)  # 原版 data.italy_power_176
	elif _d(134) >= 100:  # 原版 data.italian_radical_left_power
		_add(176, -999)  # 原版 data.italy_power_176
	if _d(177) > 1:  # 原版 data.italy_power_177
		_add(176, -1)  # 原版 data.italy_power_176
	var txt := ""
	match opt:
		0:
			txt = TXT_R0
			_add(175, 1)  # 原版 data.italy_power_175
			_add(W.I_BUDGET, -50)
			_add(W.I_AGRICULTURE, 10)
			_add(W.I_INDUSTRY, 10)
			if italy != null and italy.has_tag("对华贸易"):
				_add(W.I_AGRICULTURE, 5)
				_add(W.I_INDUSTRY, 5)
		1:
			txt = TXT_R1
			_add(176, 1)  # 原版 data.italy_power_176
			_add(180, 1)  # 原版 data.italy_power_180
			_add(181, 1)  # 原版 data.italy_power_181
			_add(W.I_BUDGET, -50)
		2:
			txt = TXT_R2
			if italy != null and (italy.内战中 or italy.政变中):
				_add(134, 10)  # 原版 data.italian_radical_left_power
			_add(182, 2)  # 原版 data.short_sword_power
			if int(ws.completed_event_ids.get("event_291", 0)) < 3:
				var r291 := int(ws.completed_event_ids.get("event_291", 0))
				_add(172 + r291, 1)  # 原版 data.italy_power_172
				if r291 == 0:
					_add(172, 1)  # 原版 data.italy_power_172
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if italy != null:
				italy.level_of_development -= 5
		3:
			txt = TXT_R3
			_add(177, 1)  # 原版 data.italy_power_177
			_add(W.I_BUDGET, -50)
		_:
			txt = ""
	if ws.get_flag("VasilyisGay"):
		# 原作 Event394.cs:179：VasilyisGay && iron_and_blood → achievements.Set(122)
		Achievements.set_achievement(122)
		txt += TXT_R_V
		_add_power(EmpireData.USA, -20)
		_add(172, 3)  # 原版 data.italy_power_172
		_add(173, 6)  # 原版 data.italy_power_173
	elif _d(175) >= _d(176):  # 原版 data.get_data_by_index(175,176)
		txt += TXT_R_DC
		_add_power(EmpireData.USA, 25)
		_add(172, 1)  # 原版 data.italy_power_172
		_add(173, 2)  # 原版 data.italy_power_173
	else:
		txt += TXT_R_PCI
		_add_power(EmpireData.USA, -10)
		_add_power(EmpireData.USSR, 10)
		if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null 				and ws.empires[EmpireData.USSR].leaders.size() > 6:
			ws.empires[EmpireData.USSR].leaders[6].support += 1
		if portugal != null:
			portugal.special -= 5
		if italy != null:
			italy.influence_china = 1
	context["result_text"] = txt


func _mod_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0





