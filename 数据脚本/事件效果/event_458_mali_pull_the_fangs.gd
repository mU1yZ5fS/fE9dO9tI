extends "res://数据脚本/event_script_base.gd"

## 原作 Event458.cs：拔掉獠牙（马里政变四选项）。
## 触发：ReqEventForDLC02.cs:332-334 —— DATE_AFTER 1978.2.28；fire_only_once 承担 !event_done[458]。
## 差异：Vyshi→亲美、prosov→亲苏、proprc→亲中、Torg→对华贸易；cw→内战中；
##   resultOfEvents[505] 移植说明按 int 默认 0 处理。

const TXT_OPT0_DIS := "支持他？他推翻了凯塔！"
const TXT_OPT1_DIS := "他们和特拉奥雷有区别吗？"
const TXT_OPT2_DIS := "我们的手伸不了那么长"
const TXT_R0 := "2月28日，特拉奥雷总统以快打慢，他召开特别会议，当场逮捕杜卡拉、巴加约科与登贝莱组成的“三人帮”，3月逮捕外交部长夏尔·桑巴·西索科（“三人帮”计划由其担任总统），另有25名军警高官涉案被捕。10月21日，国家安全法庭判处杜卡拉、巴加约科死刑，登贝莱20年苦役，西索科5年苦役，23人获6个月至15年不等刑期。1979年2-3月，法庭以“贪腐罪”再审涉案人员，杜卡拉再判死刑，巴加约科加刑5年，登贝莱加刑10年。最终杜卡拉与巴加约科被关押至陶德尼盐矿（劳动营），1983年在狱中死亡。此次事件后，特拉奥雷清除了委员会内部的核心反对力量，为正式掌权铺平了道路。|1979年3月底在巴马科召开了马里人民民主联盟第一次代表大会，穆萨·特拉奥雷当选为总书记。马里工会全国联合会、马里全国妇女联合会和马里全国青年联合会等群众组织被纳入马里人民民主联盟领导之下。民盟党章规定：党的目标是“发展独立的、有计划的民族经济”，“在以民族经济为基础的发展道路上建立一个民族民主国家”，并遵循民主集中制和为人民服务的原则。特拉奥雷指出：民盟“确定了一条在独立计划经济和民主国家基础上的发展道路”。1979年6月19日，在没有任何竞争对手的情况下，马里人民民主联盟作为全国政党在议会选举中以99.85%的得票率，赢得国民议会全部议席，穆萨·特拉奥雷作为候选人当选马里第二共和国总统。同年6月28日，马里全国解放军事委员会解散，原军委会成员转而担任党内职务。|我们的大使祝贺特拉奥雷总统粉碎苏修社会帝国主义支持的“三人帮”阴谋的伟大胜利，并表示愿意向马里提供一批援助，以支持其建设民族民主国家。特拉奥雷欣然同意，与我们签订了一批合作协定，并对中国老朋友表达了感谢，他并不介意通过引入我们的力量来平衡法国的影响力。"
const TXT_R1_KGB := "我们决定同克格勃一起向三人提供帮助，我们的大使告诉杜卡拉和巴加约科，要学会“以快打慢”，两派摊牌已是板上钉钉，掌握秘密警察的他们应该利用好优势，尽快行动。很快，在克格勃的情报支援下，他们发起了行动。马里全国工人联合会总书记赛义杜·迪亚洛动员工人发起了一场抗议当局政策的罢工，被解职的马里全国妇女联盟前总书记法图·塔尔也利用其关系网和剩余影响力煽动市场妇女抗议物价，联合学生与工人制造混乱。随后，支持三人的巴马科警察局长动员部下以维持秩序为由在首都进行交通管制，干扰特拉奥雷派的行动。杜卡拉、巴加约科和登贝莱以“保护”为由派兵包围了全国解放军事委员会总部。在首都混乱的情况下，特拉奥雷在交火中身中数枪身亡，许多忠于他的人物也被抓获。在第二天的发布会上，杜卡拉部长向全国广播了马里的叛徒、内奸、国贼穆萨·特拉奥雷被就地正法的消息（不过大多数市民选择以彻夜的狂欢庆祝他的死），他宣布，是特拉奥雷破坏了凯塔的革命，并谋害了狱中的前总统。此次行动，是为了纠正这一错误的政策。正在出国访问的外交与合作部长夏尔·桑巴·西索科很快回到了马里，在一场会议后，他被选为新总统，杜卡拉、巴加约科和登贝莱真正掌握实权，法图·塔尔也取代特拉奥雷夫人重新成为马里全国妇女联盟总书记。全国解放军事委员会在经过一次清洗后，改组为马里军事革命临时行政委员会，并宣布将国名改为社会主义马里。在一次群众大会上，西索科演说道：“让法帝国主义见鬼去吧，我们将继承凯塔的事业，带领马里走向社会主义，一切反对我们社会主义马里事业的敌人，都将被正义的铁拳粉碎！”特拉奥雷的亲信们被送上国家安全法庭审判，随后被关押至陶德尼盐矿（劳动营）。在苏方的建议下，他们明白维持军事统治并不明智，而政变也教会他们应该利用民间组织的力量，因此，他们宣布马里已经从民族民主革命进入了人民民主革命的阶段，并仿照埃塞俄比亚的模式组建了群众组织事务临时办公室，协调马里全国工人联合会、马里全国妇女联盟的工作，并尝试吸收马里劳动党和马里革命与民主党的部分派系和活动家加入其中，而不接受这一政策的左翼政党将被取缔、抓捕，送入劳动营。筹备中的马里人民民主联盟被改组为马里工人党筹建委员会。新政府同社会主义阵营展开了更多的合作，并与各个非洲进步政权发展了联系。西索科总统向我们表达了感谢，同我们达成了一些合作协定。"
const TXT_R1_OURS := "我们决定向三人提供帮助，我们的大使告诉杜卡拉和巴加约科，要学会“以快打慢”，两派摊牌已是板上钉钉，掌握秘密警察的他们应该利用好优势，尽快行动。很快，在我们的情报支援下，他们发起了行动。马里全国工人联合会总书记赛义杜·迪亚洛动员工人发起了一场抗议当局政策的罢工，被解职的马里全国妇女联盟前总书记法图·塔尔也利用其关系网和剩余影响力煽动市场妇女抗议物价，联合学生与工人制造混乱。随后，支持三人的巴马科警察局长动员部下以维持秩序为由在首都进行交通管制，干扰特拉奥雷派的行动。杜卡拉、巴加约科和登贝莱以“保护”为由派兵包围了全国解放军事委员会总部。在首都混乱的情况下，特拉奥雷在交火中身中数枪身亡，许多忠于他的人物也被抓获。在第二天的发布会上，杜卡拉部长向全国广播了马里的叛徒、内奸、国贼穆萨·特拉奥雷被就地正法的消息（不过大多数市民选择以彻夜的狂欢庆祝他的死），他宣布，是特拉奥雷破坏了凯塔的革命，并谋害了狱中的前总统。此次行动，是为了纠正这一错误的政策。正在出国访问的外交与合作部长夏尔·桑巴·西索科很快回到了马里，在一场会议后，他被选为新总统，杜卡拉、巴加约科和登贝莱真正掌握实权，法图·塔尔也取代特拉奥雷夫人重新成为马里全国妇女联盟总书记。全国解放军事委员会在经过一次清洗后，改组为马里军事革命临时行政委员会，并宣布将国名改为社会主义马里。在一次群众大会上，西索科演说道：“让法帝国主义见鬼去吧，我们将继承凯塔的事业，带领马里走向社会主义，一切反对我们社会主义马里事业的敌人，都将被正义的铁拳粉碎！”特拉奥雷的亲信们被送上国家安全法庭审判，随后被关押至陶德尼盐矿（劳动营）。在我方的建议下，他们明白维持军事统治并不明智，而政变也教会他们应该利用民间组织的力量，因此，他们宣布马里已经从民族民主革命进入了人民民主革命的阶段，并仿照埃塞俄比亚的模式组建了群众组织事务临时办公室，协调马里全国工人联合会、马里全国妇女联盟的工作，并尝试吸收马里劳动党和马里革命与民主党的部分派系和活动家加入其中，而不接受这一政策的左翼政党将被取缔、抓捕，送入劳动营。筹备中的马里人民民主联盟被改组为马里工人党筹建委员会。新政府同社会主义阵营展开了更多的合作，并与各个非洲进步政权发展了联系。西索科总统向我们表达了感谢，同我们达成了一些合作协定。"
const TXT_R2 := "2月28日，特拉奥雷总统以快打慢，他召开特别会议，当场逮捕杜卡拉、巴加约科与登贝莱组成的“三人帮”，3月逮捕外交部长夏尔·桑巴·西索科（“三人帮”计划由其担任总统），另有25名军警高官涉案被捕。10月21日，国家安全法庭判处杜卡拉、巴加约科死刑，登贝莱20年苦役，西索科5年苦役，23人获6个月至15年不等刑期。1979年2-3月，法庭以“贪腐罪”再审涉案人员，杜卡拉再判死刑，巴加约科加刑5年，登贝莱加刑10年。最终杜卡拉与巴加约科被关押至陶德尼盐矿（劳动营），1983年在狱中死亡。此次事件后，特拉奥雷清除了委员会内部的核心反对力量，为正式掌权铺平了道路。|1979年3月底在巴马科召开了马里人民民主联盟第一次代表大会，穆萨·特拉奥雷当选为总书记。马里工会全国联合会、马里全国妇女联合会和马里全国青年联合会等群众组织纳入马里人民民主联盟领导之下。民盟党章规定：党的目标是“发展独立的、有计划的民族经济”，“在以民族经济为基础的发展道路上建立一个民族民主国家”，并遵循民主集中制和为人民服务的原则。特拉奥雷指出：民盟“确定了一条在独立计划经济和民主国家基础上的发展道路”。1979年6月19日，在没有任何竞争对手的情况下，马里人民民主联盟作为全国政党在议会选举中以99.85%的得票率，赢得国民议会全部议席，穆萨·特拉奥雷作为候选人当选马里第二共和国总统。同年6月28日，马里全国解放军事委员会解散，原军委会成员转而担任党内职务。|当然，我们并不用在乎那些。依托于几内亚的支持，在外联部以及阿尔巴尼亚同志的工作和协调下，我们帮助马里劳动党清除了主张对军政府进行“打入主义”（他们的“打入主义”实际上沦为同军政府合流，镇压群众）和主张“民族民主人民革命”中关于“需培育民族资产阶级作为必要阶段”（他们主张推动精英阶层致富，以促进“民族资产阶级的崛起”，并亲自实践，成为了商人，利用在穆萨·特拉奥雷政府中的职位，构建了庞大的利益网络）的机会主义分子，吸收了分裂出去的“云朵”团体、蒂埃莫科·加朗·库亚特团体等革命派的成员，重组为以穆罕默德·塔布雷、约罗·迪亚凯特、谢赫·奥马尔·西索科、伊萨·恩迪亚耶和穆罕默德·拉明·加库等人为核心的革命派新领导层，并同语言学家阿卜杜拉耶·巴里领导的马里革命与民主党，以及苏丹联盟-非洲民主联盟、马里民主人民阵线、左翼出版物《人民公报》编辑部、马里全国学生与学徒联盟和马里全国工人联盟等左翼组织一起成立了全国人民民主阵线以及一支附属的准军事武装——人民突击队，以协调共同开展暴力革命。树已植下，让我们等待它长大吧。"
const TXT_R3 := "2月28日，特拉奥雷总统以快打慢，他召开特别会议，当场逮捕杜卡拉、巴加约科与登贝莱组成的“三人帮”，3月逮捕外交部长夏尔·桑巴·西索科（“三人帮”计划由其担任总统），另有25名军警高官涉案被捕。10月21日，国家安全法庭判处杜卡拉、巴加约科死刑，登贝莱20年苦役，西索科5年苦役，23人获6个月至15年不等刑期。1979年2-3月，法庭以“贪腐罪”再审涉案人员，杜卡拉再判死刑，巴加约科加刑5年，登贝莱加刑10年。最终杜卡拉与巴加约科被关押至陶德尼盐矿（劳动营），1983年在狱中死亡。此次事件后，特拉奥雷清除了委员会内部的核心反对力量，为正式掌权铺平了道路。\n1979年3月底在巴马科召开了马里人民民主联盟第一次代表大会，穆萨·特拉奥雷当选为总书记。马里工会全国联合会、马里全国妇女联合会和马里全国青年联合会等群众组织纳入马里人民民主联盟领导之下。民盟党章规定：党的目标是“发展独立的、有计划的民族经济”，“在以民族经济为基础的发展道路上建立一个民族民主国家”，并遵循民主集中制和为人民服务的原则。特拉奥雷指出：民盟“确定了一条在独立计划经济和民主国家基础上的发展道路”。1979年6月19日，在没有任何竞争对手的情况下，马里人民民主联盟作为全国政党在议会选举中以99.85%的得票率，赢得国民议会全部议席，穆萨·特拉奥雷作为候选人当选马里第二共和国总统。同年6月28日，马里全国解放军事委员会解散，原军委会成员转而担任党内职务。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var mali := world.get_country_by_legacy_index(58)
	var alb := world.get_country_by_legacy_index(20)
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var res505 := int(world.completed_event_ids.get("event_505", 0))
	var opt := event_def.options
	if line56 >= 1 and line56 <= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line56 <= 2 and (mali != null and mali.内战中 or (world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 500)):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line56 <= 1 and mod6 and alb != null and alb.has_tag("对华贸易") and res505 == 0:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var mali := _country(58)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_tag(58, "对华贸易", true)
			_add(W.I_BUDGET, -70)
			_add_relation(EmpireData.USA, 50)
		1:
			if mali != null and not mali.内战中:
				context["result_text"] = TXT_R1_KGB
				if mali != null:
					mali.government = GameConstants.Government.AUTHORITARIAN
					mali.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					mali.puppet_of = GameConstants.LegacySlot.NONE
					mali.set_tag("亲美", false)
					mali.set_tag("对华贸易", true)
					mali.set_tag("亲苏", true)
			else:
				context["result_text"] = TXT_R1_OURS
				if mali != null:
					mali.government = GameConstants.Government.AUTHORITARIAN
					mali.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					mali.puppet_of = GameConstants.LegacySlot.NONE
					mali.set_tag("亲美", false)
					mali.set_tag("对华贸易", true)
					mali.set_tag("亲中", true)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -50)
		2:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -30)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -50)
		3:
			context["result_text"] = TXT_R3




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


