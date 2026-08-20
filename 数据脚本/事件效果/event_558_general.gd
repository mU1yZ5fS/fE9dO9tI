extends "res://数据脚本/event_script_base.gd"

## 原作 Event558.cs：将军（苏联利加乔夫上台，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1244-1246 —— 复杂条件见 evaluate()。

const TXT_OPT0_DIS := "绝不能给非法政府站台！"
const TXT_OPT2_DIS := "我们没必要支持半吊子列宁主义者！"
const TXT_R0 := "事发次日，中国驻苏联大使便向克里姆林宫送去我国领导层的贺电。祝贺苏联共产党摆脱唯意志主义问题，回归实事求是的执政路线，并祝愿苏联接下来的经济与社会革新一切顺利。苏联对我们的表态颇为满意，并向中方表达感谢与合作意愿。尽管实际上中苏间关系仍未产生根本转变，新政府和戈尔巴乔夫政府间似乎也很难做出什么区分：苏联仍在打击酗酒的基础上整顿劳动纪律，各式经济试验仍在继续，只是一切都被冠以“新的新经济政策”之名。未来情况仍需观察。"
const TXT_R1 := "事发次日，中国领导人便表态称。苏联方罢免戈尔巴乔夫的行为既不合法，也不合规，严重违反党章国纪。实际上可说是采用解决敌我矛盾的不合理方式解决问题，充分体现了苏共缺乏民主作风，决策专断家长的事实。这自然引起了苏联的不满，并为那些试图借题发挥质疑新政府合法性的损友们提供了不少便利。我们与苏联间的外交联系也就此中断。除此之外，新政府和戈尔巴乔夫政府间似乎也很难做出什么区分：苏联仍在打击酗酒的基础上整顿劳动纪律，各式经济试验仍在继续，只是一切都被冠以“新的新经济政策”之名。未来情况仍需观察。"
const TXT_R2_A := "事发次日，中国驻苏联大使便向克里姆林宫送去我国领导层的贺电。祝贺苏联共产党摆脱唯意志主义问题，回归实事求是的执政路线，并祝愿苏联接下来的经济与社会革新一切顺利。此后，"
const TXT_R2_TAIL := "又在某日亲自造访莫斯科，同新一代苏联领导集体会面，并就深化经济合作，建立互惠互利关系达成共识。我们已与苏方达成多份贸易合同，为接下来的增长开拓不少前景。新政府和新政府间似乎也很难做出什么区分：苏联仍在打击酗酒的基础上整顿劳动纪律，各式经济试验仍在继续，只是一切都被冠以“新的新经济政策”之名。未来情况仍需观察。"
const TXT_R3 := "新政府和戈尔巴乔夫政府间似乎也很难做出什么区分：苏联仍在打击酗酒的基础上整顿劳动纪律，各式经济试验仍在继续，只是一切都被冠以“新的新经济政策”之名。未来情况仍需观察。"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world
	if dd.size() <= W.I_YEAR:
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	var ussr := world.empires[EmpireData.USSR]
	var c7 := world.get_country_by_legacy_index(7)
	if ussr.current_leader != 6:
		return false
	if c7 == null or c7.sub_government == GameConstants.SubGovernment.PRAGMATIST:
		return false
	if ussr.leaders.size() <= 6 or ussr.leaders[6] == null or ussr.leaders[6].support >= 0:
		return false
	var y := dd.year
	var mo := dd.month
	if (y >= 1985 and mo >= 5) or y >= 1986:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if d.diplomatic_reputation <= 900 and d.diplomatic_reputation >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if d.political_line != 0 and d.political_line != 4:
		_enable(opt[2], event_def.options[2].text)
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
