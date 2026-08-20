extends "res://数据脚本/event_script_base.gd"

## 原作 Event395.cs：马蹄铁理论真的可行？（意大利极左极右合流，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DIS0A := "现在可不是时候"
const TXT_DIS0B := "我们没必要染黑自己的手"
const TXT_DIS1A := "现在可不是时候"
const TXT_DIS1B := "我们没必要染红自己的手"
const TXT_R0 := "借助中方情报机构的晓之以情，动之以理。作为多国线人的弗朗哥·弗雷达很快便识时务地选取了开价最高的盟友，更顺势将建立极右翼联盟的战略提上日程：考虑到弗雷达曾在60年代便以一本《体制的崩溃》奠定了其在新一代法西斯活动家眼中“伟大导师”的崇高地位，并使泛欧民族主义者让-弗朗索瓦·蒂里亚特、亲法西斯神秘主义者尤利乌斯·埃佛拉同拥护贵族主义的哲学家柏拉图三者的政治思想共同成为一代法西斯主义者眼中的显学。筹建大联盟的计划近乎是一经提出便立即得以落实：他不仅拉来了作为“新秩序”政治运动碎片的“第三位置”、秩序活动小组与“建构行动”等组织一同商议大事，更借曾在60年代打出名气的人民斗争协会整合了另一个风头无两的法西斯主义恐怖组织底民族先锋队相关班与在1968年运动期间倒向议会外运动、极端民族主义与反资本主义激进倾向的多个学生社区。至此，除却因代际矛盾而拥抱反叛无政府主义，标榜唯有自身继承了革命纯洁性的“革命武装核心”组织外。意大利“新秩序”民族革命先锋队得以在整合该国绝大多数反建制右翼活动家的基础上迅速崛起，更让曾回归意大利社会运动的老将皮诺·劳蒂与其在党内的派系选择再度出走，以引入墨索里尼时代政治老将的方式实现了极右翼阵营内真正意义上的大团结。不久后，新的“新秩序”组织便在其对外发言人“三人帮”（即前人民斗争协会内的三巨头恩佐·玛丽亚·丹蒂尼、塞拉菲诺·迪·卢亚与乌戈·高登齐）通过了“青年欧洲”决议：计划“铲除雅尔塔体系下掠夺者，实现意大利民族完全独立”，并在“团结一切可团结的力量，终结法西斯与共产主义间的虚假对立”口号中彻底推翻“大西洋帝国主义、苏维埃帝国主义与梵蒂冈教权主义”三座大山。与此同时，该组织叫停了麾下恐怖小组同“红色旅”等左翼政治团体的武斗，并将重心集中到联合武装派系、策动联合袭击以“破除国家机器”本身。这一轰轰烈烈的整合行动让“新秩序”与其同情组织的兵力达到了数万人之多。而这不过是个开始……考虑到意大利的政治局势升温自然会招致该国建制派的疯狂反扑与超级大国的持续关注，我们必须速战速决……"
const TXT_R1 := "意识到我们的一切行动都将为接下来的多方乱战布局，提前物色一匹最强的黑马便是题中之义：显然，早已打出风头的“红色旅”自然成为了我们的目标，并被视为整合该国所有左翼游击队的可靠母本。随着该国治安环境进一步收拢，主张“武装宣传为辅，占领社会为主”路线的革命共产主义委员会这般曾同工人主义有所渊源的准工人纠察队式组织与仅在忠于“政治原则”基础上达成松散联合的“前线”都正每况愈下。事实上确认了“红色旅”领导人马里奥·莫雷蒂的“直面国家，政治斩首”公式与第一代领导人追随马克思列宁主义路线，尝试筹建集中化的军事-政治共产党政策的唯一合理性。因此，政治整合便自然而然地发生了。我们的特工成功实现了“红色旅”同“前线”、共产主义战斗队等团体领导人的联合，并最终使后者集体以“民主集中制”原则方式并入“红色旅”机体内。与此同时，因科西加体制实行而惨遭镇压的意大利社会党与意大利共产党成员也正借助我们的情报网络汇入这一策动大规模军事进攻计划的反国家司令部内。事实上实现了意大利国内左翼战线的最终统一：新生的“红色旅”宣称自身已然继承了民族解放委员会的未尽事业，并将在采纳格瓦拉主义、毛泽东思想与红色恐怖理论的基础上同“科西加法西斯主义匪帮”做殊死斗争。紧接着便是对于前工人主义者、左翼政党基层支部与武装派系的整合与大规模的战略转移（直接导致左翼激进派将矛头从“右翼同行”指向军警宪特，造就了前者内部事实上的停火）。这一轰轰烈烈的行动让“红色旅”与其同情组织的兵力达到了数万人之多。而这不过是个开始……考虑到意大利的政治局势升温自然会招致该国建制派的疯狂反扑与超级大国的持续关注，我们必须速战速决……"
const TXT_R2 := "弗朗切斯科·科西加对国内的领导权仍牢不可破，面对来势汹汹的特别监狱与武装部队，意大利的激进活动家们毫无还手之力。不久后，该国警方便成功对意大利国内的主要恐怖组织开展了斩首行动：作为极左翼头面的“红色旅”与反建制的极右翼政治典型“革命武装核心”的领导核心均被一网打尽，其武装力量不得不解体为数个互不统属的小型团体各自为政。旋即也被各个击破。试图兜售左右联合计划的弗朗哥·弗雷达亦在特别搜查行动中被隔离审查，并在不久后淡出舞台。转而在意大利情报机构内谋得新职。针对“转向者”的收编与打击恐怖活动的措施并行不悖，最终共同铸就了该国的稳定政治生态。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var italy := world.get_country_by_legacy_index(85)
	var opt := event_def.options
	var r391 := int(world.completed_event_ids.get("event_391", 0))
	if _d(W.I_WAR_SUPPORT) > 300 and _d(W.I_POLITICAL_LINE) <= 2 and _d(W.I_DIPLO) >= 900 			and (r391 == 0 or r391 == 2) and italy != null and italy.level_of_development < 50:
		_enable(opt[0], event_def.options[0].text)
	elif italy != null and italy.level_of_development >= 50:
		_disable(opt[0], TXT_DIS0A)
	else:
		_disable(opt[0], TXT_DIS0B)
	if _d(W.I_WAR_SUPPORT) > 300 and _d(W.I_POLITICAL_LINE) <= 2 and _d(W.I_DIPLO) >= 900 			and (r391 == 1 or r391 == 2) and italy != null and italy.level_of_development < 50:
		_enable(opt[1], event_def.options[1].text)
	elif italy != null and italy.level_of_development >= 50:
		_disable(opt[1], TXT_DIS1A)
	else:
		_disable(opt[1], TXT_DIS1B)
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -100)
			if italy != null:
				italy.level_of_development -= 10
			_add(134, 40)  # 原版 data[134]
			if italy != null:
				italy.set_tag("对华贸易", false)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -100)
			if italy != null:
				italy.level_of_development -= 10
			_add(134, 40)  # 原版 data[134]
			if italy != null:
				italy.set_tag("对华贸易", false)
		_:
			context["result_text"] = TXT_R2
			_add(134, 0)  # 原版 data[134] = 0
			if d.size() > 134:
				d[134] = 0  # 原版 data[134]
			if italy != null:
				italy.内战中 = false
				italy.政变中 = false




func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0



