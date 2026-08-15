extends "res://数据脚本/event_script_base.gd"

## 原作 Event558.cs：将军（苏联利加乔夫上台，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1244-1246 —— 复杂条件见 evaluate()。

const TXT_TITLE := "将军"
const TXT_DESC := "来自莫斯科的突发消息。由于苏联新任领导人米哈伊尔·戈尔巴乔夫上任伊始便遭遇接连不断的政治与外交失败，且无法拿出扭转内外交困境地的果断方案。导致他在领导层内已民心尽失。作为其政治盟友空降的“新思维”改革小组也只会让他的处境变得更糟，这些人同苏联绝大多数官员间多有龃龉：尤其是试图以管制民主与总统制为蓝本改组苏联体制，为此不惜加速苏联社会内矛盾爆发，事实上持亲大西洋主义立场的亚历山大·雅科夫列夫。终于，即便是曾支持戈尔巴乔夫上位，作为其重要盟友的老政治家安德烈·葛罗米柯与管理党务的前托木斯克党委第一书记叶戈尔·利加乔夫也选择抛弃了他。几乎是在四月全会结束后不久，戈尔巴乔夫的前盟友们便串通安德罗波夫提拔的“经济总督”（即尼古拉·雷日科夫、列昂尼德·阿巴尔金等）与部分保守派达成共识，趁戈尔巴乔夫一行出访欧美时召开政治局紧急会议：雅科夫列夫因涉嫌组织“间谍活动”被克格勃领导人切布里科夫下辖的安全人员逮捕并开除出党，戈尔巴乔夫在各地的支持者则被纷纷孤立，他们的精神领袖在返回后遭批评、扣上“唯意志论”的帽子后被开除。其空位则被各派共同推举的妥协，走保守改革路线的叶戈尔·利加乔夫接替：新任总书记声称将遵循集体领导原则，延续拓展经济自主权的试验，并在坚持列宁主义理论基础上修正戈尔巴乔夫改革路线——告别了有史以来最短命的苏联领导人后，我们总得站出来说几句……利加乔夫是苏式爱国主义的忠实拥趸，必然会竭尽所能巩固并拓展苏联势力范围。"
const TXT_OPT0 := "祝贺苏联领导层的革新！"
const TXT_OPT0_DIS := "绝不能给非法政府站台！"
const TXT_OPT1 := "这是一场非法的，违宪的军事政变……"
const TXT_OPT2 := "兴许是个机会，我将亲自前往莫斯科会见利加乔夫"
const TXT_OPT2_DIS := "我们没必要支持半吊子列宁主义者！"
const TXT_OPT3 := "我们静观其变……"
const TXT_R0 := "事发次日，中国驻苏联大使便向克里姆林宫送去我国领导层的贺电。祝贺苏联共产党摆脱唯意志主义问题，回归实事求是的执政路线，并祝愿苏联接下来的经济与社会革新一切顺利。苏联对我们的表态颇为满意，并向中方表达感谢与合作意愿。尽管实际上中苏间关系仍未产生根本转变，新政府和戈尔巴乔夫政府间似乎也很难做出什么区分：苏联仍在打击酗酒的基础上整顿劳动纪律，各式经济试验仍在继续，只是一切都被冠以“新的新经济政策”之名。未来情况仍需观察。"
const TXT_R1 := "事发次日，中国领导人便表态称。苏联方罢免戈尔巴乔夫的行为既不合法，也不合规，严重违反党章国纪。实际上可说是采用解决敌我矛盾的不合理方式解决问题，充分体现了苏共缺乏民主作风，决策专断家长的事实。这自然引起了苏联的不满，并为那些试图借题发挥质疑新政府合法性的损友们提供了不少便利。我们与苏联间的外交联系也就此中断。除此之外，新政府和戈尔巴乔夫政府间似乎也很难做出什么区分：苏联仍在打击酗酒的基础上整顿劳动纪律，各式经济试验仍在继续，只是一切都被冠以“新的新经济政策”之名。未来情况仍需观察。"
const TXT_R2_A := "事发次日，中国驻苏联大使便向克里姆林宫送去我国领导层的贺电。祝贺苏联共产党摆脱唯意志主义问题，回归实事求是的执政路线，并祝愿苏联接下来的经济与社会革新一切顺利。此后，"
const TXT_R2_TAIL := "又在某日亲自造访莫斯科，同新一代苏联领导集体会面，并就深化经济合作，建立互惠互利关系达成共识。我们已与苏方达成多份贸易合同，为接下来的增长开拓不少前景。新政府和新政府间似乎也很难做出什么区分：苏联仍在打击酗酒的基础上整顿劳动纪律，各式经济试验仍在继续，只是一切都被冠以“新的新经济政策”之名。未来情况仍需观察。"
const TXT_R3 := "新政府和戈尔巴乔夫政府间似乎也很难做出什么区分：苏联仍在打击酗酒的基础上整顿劳动纪律，各式经济试验仍在继续，只是一切都被冠以“新的新经济政策”之名。未来情况仍需观察。"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world.数值表
	if dd.size() <= W.I_YEAR:
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	var ussr := world.empires[EmpireData.USSR]
	var c7 := world.get_country_by_legacy_index(7)
	if ussr.current_leader != 6:
		return false
	if c7 == null or c7.sub_government == 15:
		return false
	if ussr.leaders.size() <= 6 or ussr.leaders[6] == null or ussr.leaders[6].support >= 0:
		return false
	var y := dd[W.I_YEAR]
	var mo := dd[W.I_MONTH]
	if (y >= 1985 and mo >= 5) or y >= 1986:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if d[W.I_DIPLO] <= 900 and d[W.I_DIPLO] >= 500:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if d[W.I_POLITICAL_LINE] != 0 and d[W.I_POLITICAL_LINE] != 4:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c7 := ws.get_country_by_legacy_index(7)
	var ussr := ws.empires[EmpireData.USSR]
	ussr.current_leader = 8
	if ussr.power < 0:
		ussr.power = 0
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(EmpireData.USSR, 150)
			_add_relation(EmpireData.USA, -50)
			_add(W.I_DIPLO, 10)
			context["result_text"] = TXT_R0
		1:
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, 50)
			_add(W.I_DIPLO, 10)
			_add_power(EmpireData.USSR, -10)
			ws.set_flag("relres", false)
			if c7 != null:
				c7.set_tag("对华贸易", false)
			context["result_text"] = TXT_R1
		2:
			_add_relation(EmpireData.USSR, 250)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 20)
			_add_power(EmpireData.USSR, 10)
			_add_power(EmpireData.USA, -20)
			_add(W.I_BUDGET, -40)
			_add(W.I_INDUSTRY, 40)
			_add(W.I_AGRICULTURE, 40)
			ws.influence_prc += 10
			ws.set_flag("relres", true)
			if c7 != null:
				c7.set_tag("对华贸易", true)
			context["result_text"] = TXT_R2_A + _leader_name() + TXT_R2_TAIL
		3:
			context["result_text"] = TXT_R3


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
