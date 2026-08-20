extends "res://数据脚本/event_script_base.gd"

## 原作 Event557.cs：和平长入社会主义：第二幕（意大利贝林格，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1174-1176 —— 复杂条件见 evaluate()。
## 差异：data[175-182] raw index；inflCh→influence_china；isSEV→has_tag。

const TXT_OPT0_DIS_TAO := "我们怎能支持陶里亚蒂的徒子徒孙？"
const TXT_OPT0_DIS_CN := "意大利共产党看不上中国方案"
const TXT_OPT0_DIS_FAR := "鞭长莫及，鞭长莫及呐"
const TXT_OPT1_DIS_REV := "绝不同苏修社会帝国主义同流合污！"
const TXT_OPT1_DIS_NO := "苏联不会考虑这种意见的"
const TXT_OPT2_DIS_REV := "社会主义的修正式？没必要画蛇添足！"
const TXT_OPT2_DIS_GUA := "倘若无人作保，谁能向西方证明意大利修正主义真同共产党无关？"
const TXT_OPT2_DIS_GHOST := "绝无可能让意大利共产党摆脱陶里亚蒂主义的幽灵"
const TXT_R0_COUP := "随着主张民粹主义、改良主义与不结盟政治立场的新兴社会主义者得以在欧洲兴起并逐渐将自身作为一股势力进行活动，且作为此类政治选择的台柱得以在我们的支持下实现重振——中方的慷慨解囊不仅让南斯拉夫的铁托主义者得以勉力维持其政治立场，不至成为国际货币基金组织的附庸；更让于80年代初进入希腊政界万神殿，正将一切权力收归雅典的民粹社会主义总理安德烈亚斯·帕潘德里欧近乎完成其脱离西方集团，实现一切权力归雅典的政治愿景。那么，面对试图将类似经验在意大利，乃至世界范围内对上述成功经验进行再版的尝试，超级大国又怎会对此置之不理？借助意大利参与西方阵营时美方在该国安全机构内布置的“后备计划”，北大西洋联盟于亚平宁地区部署的军事设施，以及占据该国相当规模政治版图的保守主义政客们余威仍在。组织一场针对意大利共产党的军事政变可说是轻而易举，而标榜和平长入社会主义，完全沉浸于合法斗争和议会游戏，并以一系列镇压措施同极左翼活动家决裂的前者。处境甚至还不若曾拥有军事武装，并能背靠另一超级大国的民族解放委员会时期：很快，这场政变便成为场一边倒屠杀。支持共产党政府的一小撮卡宾枪骑兵与由共产党基层活动家仓促组建的赤卫队被意大利国防军轻易粉碎，亚历山德罗·佩尔蒂尼总统与恩里科·贝林格总理均在美军空降部队发起的斩首行动中身死殉国。历史上首个欧洲共产主义政权至此被彻底终结，并由前内务部长弗朗切斯科·科西加主持的军管体制取而代之。自战后开启的意大利民主游戏至此迎来终结……试图防止该国重蹈“智利悲剧”而押注合法路线的政治领袖则成了新版阿连德……"
const TXT_R0_OK := "随着主张民粹主义、改良主义与不结盟政治立场的新兴社会主义者得以在欧洲兴起并逐渐将自身作为一股势力进行活动，且作为此类政治选择的台柱得以在我们的支持下实现重振——中方的慷慨解囊不仅让南斯拉夫的铁托主义者得以勉力维持其政治立场，不至成为国际货币基金组织的附庸；更让于80年代初进入希腊政界万神殿，正将一切权力收归雅典的民粹社会主义总理安德烈亚斯·帕潘德里欧近乎完成其脱离西方集团，实现一切权力归雅典的政治愿景。那么为何不能在意大利，乃至世界范围内对上述成功经验进行再版呢？借助中国与意大利早早深耕建立的特别合作关系，我们向恩里科·贝林格总理与意大利共产党开出了彻底解决意大利，乃至冷战问题的政治药方：各国人民苦于两极对峙已久，且不论是经典资本主义还是正统社会主义，皆在政治实践中表现为实质上的帝国主义与各种独裁模式变体。因此，有必要在世界范围内实现民主替代。考虑到新兴社会主义者们都清楚谁是自己最大的贵人，我们很快便将欧洲各社会主义政权、政党与社会团体的主要旗手们聚拢，并计划以其中综合实力最强的意大利作为轴心筹建政治国际。很快，恩里科·贝林格便在罗马将其蓝图落到实处：国际组织“争取人道的，民主的社会主义联盟”至此成立，宣布将以增进人民福祉、实现社会进步、确保国家主权与外交关系平等化作为活动宗旨的同时对一切持人道主义、民主主义与社会主义立场的国际政治行为体采取“门户开放”政策，计划在新世纪到来前夕粉碎压迫性分工体系，终结冷战对峙格局。作为这一联盟的表率，意大利领导层几乎是在宣布“社会主义联盟”诞生的同时便终结其在欧洲共同体内的成员身份，松紧外资管制，并大幅降低对北约组织的参与度。掌舵该国的意共则同步开始将国际共产主义运动内的改良主义倾向（如南斯拉夫共产主义者联盟、希腊共产党（国内派）与大不列颠共产党），现代社会民主主义运动内的反西方情绪（如日本社会党与泛希腊社会主义运动），以及尚未明确自身位置的左翼民粹主义者（如桑地诺民族解放阵线）整编进入这一组织。相关倡议得到了欧洲共产主义政党与民主社会主义者们的热切响应。"
const TXT_R1 := "借助意大利共产党内部健康力量的就位与中国先前的系列耕耘，我们致电恩里科·贝林格总理，在美苏两强并立的国际局势下事实上并无可能争取建立第三阵营，但这并不代表不存在借助双边矛盾采取“第三选择”，即同两强中相对更无害，更不至动摇国家主权的一方合作的以巩固自身立场的机会：旋即，我们便向意大利领导人援引了埃及纳赛尔政权、印度社会主义与古巴革命（彼时的苏联对其采取结伴而非结盟的策略，致使上述政权足以在相当范围内自行其是——否则，萨达特不可能如此轻易地发起“纠正运动”并肃清苏联影响力；而古巴更不可能建立自身的三大洲会议圈子，在和平共处的口号外输出激进主义），乃至南斯拉夫作为经济互助委员会咨询国参与国际政治活动的系列案例。以此表示同布鲁塞尔的寡头统治相比，有限参与苏东体系的国际分工自是可取之道。而在呼吁改革欧洲共同体尝试失败，且西欧国家对“意大利社会主义”敌意昭然若揭的背景下。恩里科·贝林格最终毅然选择向东方经验看齐——意大利至此彻底退出欧洲共同体，松紧外资管制，并大幅降低对北约组织的参与度。同时递交了加入经济互助委员会的系列申请。这一转向让其西方国家盟友，尤其是美国大为光火：可在军事干预极有可能导致苏联下场，并造就新一轮核危机的背景下。大西洋主义者们最终只得偃旗息鼓，并对古巴经验按图索骥。期望以制裁封锁扼杀亚平宁的社会主义异类。"
const TXT_R1_COUP := "借助意大利共产党内部健康力量的就位与中国先前的系列耕耘，我们致电恩里科·贝林格总理，在美苏两强并立的国际局势下事实上并无可能争取建立第三阵营，但这并不代表不存在借助双边矛盾采取“第三选择”，即同两强中相对更无害，更不至动摇国家主权的一方合作的以巩固自身立场的机会：旋即，我们便向意大利领导人援引了埃及纳赛尔政权、印度社会主义与古巴革命（彼时的苏联对其采取结伴而非结盟的策略，致使上述政权足以在相当范围内自行其是——否则，萨达特不可能如此轻易地发起“纠正运动”并肃清苏联影响力；而古巴更不可能建立自身的三大洲会议圈子，在和平共处的口号外输出激进主义），乃至南斯拉夫作为经济互助委员会咨询国参与国际政治活动的系列案例。以此表示同布鲁塞尔的寡头统治相比，有限参与苏东体系的国际分工自是可取之道。而在呼吁改革欧洲共同体尝试失败，且西欧国家对“意大利社会主义”敌意昭然若揭的背景下。恩里科·贝林格最终毅然选择向东方经验看齐——然而，超级大国又怎会对此置之不理？借助意大利参与西方阵营时美方在该国安全机构内布置的“后备计划”，北大西洋联盟于亚平宁地区部署的军事设施，以及占据该国相当规模政治版图的保守主义政客们余威仍在。组织一场针对意大利共产党的军事政变可说是轻而易举，而标榜和平长入社会主义，完全沉浸于合法斗争和议会游戏，并以一系列镇压措施同极左翼活动家决裂的前者。处境甚至还不若曾拥有军事武装，并能背靠另一超级大国的民族解放委员会时期：很快，这场政变便成为场一边倒屠杀。支持共产党政府的一小撮卡宾枪骑兵与由共产党基层活动家仓促组建的赤卫队被意大利国防军轻易粉碎，亚历山德罗·佩尔蒂尼总统与恩里科·贝林格总理均在美军空降部队发起的斩首行动中身死殉国。历史上首个欧洲共产主义政权至此被彻底终结，并由前内务部长弗朗切斯科·科西加主持的军管体制取而代之。自战后开启的意大利民主游戏至此迎来终结……试图防止该国重蹈“智利悲剧”而押注合法路线的政治领袖则成了新版阿连德……"
const TXT_R1_OK := "借助苏东阵营之手保卫“意大利社会主义”的成功实践加速了意大利共产党内部的思潮转向，且进一步证实了欧洲共产主义构想在政治上的破产：这导致共产党内的亲苏派和保守主义者们正迅速攫取其影响力，并计划将该国体制向战后东欧初的人民民主模式转变。莫斯科自乐见于此。"
const TXT_R2 := "深受布拉格之春影响，且自20世纪70年代兴起，并在西欧共产党内逐步成为显学的欧洲共产主义与其政治实践表明：它只能作为一种挂靠既有意识形态的政治附庸存在。意大利共产党在国内选举的堂堂大胜与确立执政地位的政治现实，以及掌权后推进所谓“欧洲共产主义”新议程的乏善可陈（即事实上在落实混杂社会民主主义与进步自由主义的中左翼纲领，使该党完全无法同德国社会民主党等相区分），只能证明其掌握共产主义政治修辞与萃取现代社会民主主义支持者的能力炉火纯青。意识到继续这种形式大于内容的实践必然无助于意大利政坛的彻底洗牌，且抛弃共产主义旗帜意味着全新的意大利政党将有机会彻底驱逐作为政治丧尸的意大利社会党，至此统合该国的左翼政治生态。我们决定向意大利共产党方开出最终解决方案——虽说立即抛弃所谓“欧洲共产主义”，乃至借机同事实上堕落至保守主义思想变体的教条共产主义相切割是确立左翼阵营霸权的必需之举。可饭也得慢慢吃：为作为空壳的欧洲共产主义赋予现代社会民主主义的形式自然成为改革的第一步。借助早在议会与党中确立的霸权，“改进派”轻易提出了改组意共的一篮子提案：如在恩里科·贝林格“天主教+共产主义”基础上更进一步，吸纳平信徒与天主教会人士入党；将共产党思想的历史渊源同步追溯至启蒙运动与法国革命，并顺势将道义社会主义、社会天主教思想等观念通过党纲写入“思想源流”；组织上则同社会党国际持续靠拢，并对法国、奥地利与瑞典的现行模式取经。所有的一切皆试图淡化意共的阶级政党性质，并最终完成早在德国、英国等地早已实现之事（即一个既通过掌握工人运动确立根基，亦可采取更为开门且灵活的政治表态扩充支持群体的“人民党”模式）。在法国总统弗朗索瓦·密特朗“高度关切”意大利政局演变，并在西方阵营内积极为意大利改革斡旋辩护的背景下。这种转变自是极其顺利。而在总书记恩里科·贝林格年老力衰，对党务政务越加力不从心；且共产党内其他派系皆被“改进主义者”压倒的背景下。目前正推进党内改革重组，且作为“改进派”政治议程全权代表，更在此过程中收编总书记的前政治门生们（如西西里地区议员阿基利·奥凯托，青年运动组织者马西莫·达莱马等）的乔治·纳波利塔诺已然不可阻挡。因此我们可说，传统意义上的意共终结与新左翼的诞生不过是时间问题。"
const TXT_R3 := "意大利共产党的停滞并未引起我们的兴趣与注意。毕竟对长期保持在野地位的政党而言，与在社会中艰难生存，维持自身群众基础相比。获得政权后该如何做这一事项完全不足以被称之为是某种“问题”。而我们先前为帮助恩里科·贝林格掌权所作的布局显然已经足够。天主教民主党不复先前辉煌，而该国的社会主义者以不足以单独组成一股足够挑战意共的势力。接下来如何则完全看他们自己值不值得端坐在罗马万神殿内——不是吗？"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world.数值表
	if dd.size() <= 177:
		return false
	var c85 := world.get_country_by_legacy_index(85)
	if c85 == null:
		return false
	var r393 := int(world.completed_event_ids.get("event_393", 0))
	if not (r393 > 0 or world.completed_event_ids.has("event_392")):
		return false
	if c85.influence_china <= 0:
		return false
	if c85.sub_government == GameConstants.SubGovernment.LEFT_CONSERVATIVE:
		return false
	var r293 := int(world.completed_event_ids.get("event_293", 0))
	if r293 < 0 or r293 > 2:
		return false
	if not (dd[176] > dd[175] and dd[176] > dd[177]):
		return false
	if world.completed_event_ids.has("event_556") or world.completed_event_ids.has("event_396") or world.completed_event_ids.has("event_401"):
		return false
	if c85.sub_government == GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN:
		return false
	var y := dd[W.I_YEAR]
	var mo := dd[W.I_MONTH]
	var day := dd[W.I_DAY]
	if (y >= 1982 and mo >= 1 and day > 19) or (y >= 1982 and mo >= 1) or y >= 1983:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var c1 := world.get_country_by_legacy_index(1)
	var c15 := world.get_country_by_legacy_index(15)
	var c45 := world.get_country_by_legacy_index(45)
	var c51 := world.get_country_by_legacy_index(51)
	var line := d[W.I_POLITICAL_LINE]
	if line != 0 and line != 4 and not ws.modifiers[3].is_active and c45 != null and c45.government == GameConstants.Government.REFORMIST 			and c45 != null and not c45.内战中 and c15 != null and c15.government == GameConstants.Government.REFORMIST 			and ws.influence_prc >= 400 and not is_auth(c1) and not ws.is_socialism(c1, true) 			and (c15 != null and (c15.内战中 or c1 != null and c1.has_tag("econ"))) and c15 != null and c15.sub_government == GameConstants.SubGovernment.TITOIST:
		_enable(opt[0], event_def.options[0].text)
	elif line == 0 or line == 4 or ws.modifiers[3].is_active:
		_disable(opt[0], TXT_OPT0_DIS_TAO)
	elif is_auth(c1) or ws.is_socialism(c1, true):
		_disable(opt[0], TXT_OPT0_DIS_CN)
	else:
		_disable(opt[0], TXT_OPT0_DIS_FAR)
	var r293 := int(ws.completed_event_ids.get("event_293", 0))
	if line < 3 and not ws.modifiers[3].is_active and c1 != null and c1.has_tag("sev") 			and ws.get_flag("relres") and r293 == 2:
		_enable(opt[1], event_def.options[1].text)
	elif line >= 3 or ws.modifiers[3].is_active or not ws.get_flag("relres"):
		_disable(opt[1], TXT_OPT1_DIS_REV)
	else:
		_disable(opt[1], TXT_OPT1_DIS_NO)
	if line > 2 and c1 != null and c1.sub_government == GameConstants.SubGovernment.SOCIAL_DEMOCRAT and d[181] >= d[178] and d[181] >= d[179] 			and d[181] >= d[180] and c51 != null and c51.has_tag("对华贸易") and ws.modifiers[43].is_active:
		_enable(opt[2], event_def.options[2].text)
	elif line <= 2 or (c1 != null and c1.sub_government != GameConstants.SubGovernment.SOCIAL_DEMOCRAT):
		_disable(opt[2], TXT_OPT2_DIS_REV)
	elif (c51 == null or not c51.has_tag("对华贸易")) or not ws.modifiers[43].is_active:
		_disable(opt[2], TXT_OPT2_DIS_GUA)
	else:
		_disable(opt[2], TXT_OPT2_DIS_GHOST)


func is_auth(c: CountryData) -> bool:
	return c != null and c.government == GameConstants.Government.AUTHORITARIAN and c.sub_government != GameConstants.SubGovernment.LEFT_RADICAL


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c85 := ws.get_country_by_legacy_index(85)
	var c45 := ws.get_country_by_legacy_index(45)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var usa := ws.empires[EmpireData.USA]
			var ussr := ws.empires[EmpireData.USSR]
			if usa.power > ussr.power + ws.influence_prc and usa.current_leader == 0:
				_add(W.I_BUDGET, -60)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, 10)
				ws.influence_prc -= 5
				_set_data(182, 0)
				if c85 != null:
					c85.government = GameConstants.Government.AUTHORITARIAN
					c85.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					c85.set_tag("亲美", true)
					c85.set_tag("对华贸易", false)
					c85.influence_china = 0
				context["result_text"] = TXT_R0_COUP
			else:
				if c85 != null:
					_leave_alliances(c85)
					c85.set_tag("soc_eu", true)
					c85.set_tag("对华贸易", true)
				if c45 != null:
					_leave_alliances(c45)
					c45.set_tag("soc_eu", true)
					c45.set_tag("对华贸易", true)
				_add_relation(EmpireData.USSR, -200)
				_add_relation(EmpireData.USA, -200)
				_add(W.I_BUDGET, -60)
				ws.influence_prc += 5
				_add_power(EmpireData.USA, -30)
				d[179] += 1
				d[180] += 1
				d[182] += 7
				context["result_text"] = TXT_R0_OK
		1:
			if c85 != null:
				_leave_alliances(c85)
			var usa := ws.empires[EmpireData.USA]
			var ussr := ws.empires[EmpireData.USSR]
			if usa.power > ussr.power + ws.influence_prc and usa.current_leader == 0:
				_add(W.I_BUDGET, -60)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, 10)
				ws.influence_prc -= 5
				_set_data(182, 0)
				if c85 != null:
					c85.government = GameConstants.Government.AUTHORITARIAN
					c85.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					c85.set_tag("亲美", true)
					c85.influence_china = 0
				context["result_text"] = TXT_R1_COUP
			else:
				if c85 != null:
					c85.set_tag("对华贸易", true)
					c85.set_tag("sev", true)
				_add_relation(EmpireData.USSR, 200)
				_add_relation(EmpireData.USA, -200)
				_add(W.I_BUDGET, -50)
				_add(W.I_AGENTS, -50)
				ws.influence_prc += 5
				d[180] -= 1
				d[178] += 1
				d[182] += 7
				_add_power(EmpireData.USSR, 20)
				_add_power(EmpireData.USA, -30)
				if ussr.power >= usa.power and c85 != null:
					c85.set_tag("亲苏", true)
				context["result_text"] = TXT_R1 + TXT_R1_OK
		2:
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, 50)
			if c85 != null:
				c85.government = GameConstants.Government.LIBERAL
				c85.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3
