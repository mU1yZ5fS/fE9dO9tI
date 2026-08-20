extends "res://数据脚本/event_script_base.gd"

## 原作 Event383.cs：新查梅尼亚（阿尔巴尼亚-希腊，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_DIS_MOD := "需要拥有修正效果“毛主义的壁垒”或极左派在党内为主流......"
const TXT_DIS_INFLUENCE := "中国的国际影响力应高于{0}......"
const TXT_R0 := "阿尔巴尼亚情报组织的行动并没有如计划般进行——载有登陆部队的船只被希腊边防部队发现，并遭到了后者的回击。因此，奇袭失败了。然而，“查梅尼亚解放军”得以拿下城市并占领了无线电塔，从而发出了进攻信号。阿尔巴尼亚人民军已经穿过边界，在并没有遭遇多少抵抗的情况下向前推进。尽管华约与北约并不想卷入另一场冲突当中，但苏联与美国舰队还是封从海上封锁了阿尔巴尼亚，切断了该国的贸易。"
const TXT_R1 := "5月16日早晨，一枚巡航导弹绕开了阿尔巴尼亚的导弹防御系统，直接击中了“查梅尼亚解放军”的营地。所有的破坏者均当场死亡。中国以实施大规模经济制裁为名威胁阿尔巴尼亚社会主义人民共和国，要求该国在巴尔干战争问题上止步。因此，在计划被我们公布，并引起苏联与美国双方强烈反应的背景下。阿尔巴尼亚领导层不得不选择同意。希腊则向阿尔巴尼亚发去了外交照会，并谴责该国的“社会帝国主义”行径。我们同时还得知了有关阿尔巴尼亚社会主义人民共和国内军政精英被清洗的消息——根据未经证实的消息，国防部长普罗科普·穆拉与西古里米领导人齐里法塔尔·拉米兹均被枪决。同时，阿尔巴尼亚当局非正式的“建议”他们的组织减少与我们的贸易往来，恩维尔·霍查选集内的反华言论也开始越加频繁的出现在媒体前。"
const TXT_R2 := "中方表示有兴趣协助阿尔巴尼亚解决同希腊之间的领土问题，因此，我们得到了来自阿尔巴尼亚领导层的感谢。在我方教官的指导下，行动被重新进行了规划，其效果则胜过往昔。因此，“查梅尼亚解放军”得以在不被发现的情况下轻易穿过边界并占领伊古迈尼察，由此发出信号。阿尔巴尼亚人民军也得以在没有遭遇抵抗的情况下迅速前进。然而苏联与美国发现了我国的干预计划。无论他们多么厌恶与两大超级大国同时打嘴仗的希腊，出于对中国崛起的恐惧，他们还是选择积极援助希腊。美国第六舰队封锁了阿尔巴尼亚的海岸线，并切断了该国的贸易。苏联的武器则宛如河流般，通过土耳其海峡运往希腊港口。"
const TXT_WAR_NAME := "希阿战争"
const TXT_WAR_ATT := "阿尔巴尼亚"
const TXT_WAR_DEF := "希腊"


const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if _d(W.I_AGENTS) >= 350:
		_enable(opt[1], event_def.options[1].text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	else:
		_disable(opt[1], TXT_DIS_AGENTS.format([20]))
	var mod6: bool = ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 250 and _d(W.I_AGENTS) >= 150 and _d(W.I_INFLUENCE) >= 700 			and (mod6 or GameManager.is_faction_leading(0)):
		_enable(opt[2], event_def.options[2].text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif not mod6 and not GameManager.is_faction_leading(0):
		_disable(opt[2], TXT_DIS_MOD)
	elif _d(W.I_INFLUENCE) < 700:
		_disable(opt[2], TXT_DIS_INFLUENCE.format([30]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt[2], TXT_DIS_BUDGET.format([25]))
	else:
		_disable(opt[2], TXT_DIS_AGENTS.format([15]))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_start_war_383(500, 500, -1, -1)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_DIPLO, -50)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, 50)
			_add(W.I_AGENTS, -350)
			if albania != null:
				_leave_alliances(albania)
				albania.set_tag("亲中", false)
				albania.set_tag("对华贸易", false)
		_:
			context["result_text"] = TXT_R2
			_add(W.I_DIPLO, 100)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, -250)
			_add_power(EmpireData.USA, -50)
			_add_power(EmpireData.USSR, -50)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -250)
			_start_war_383(600, 400, 1, 1)


func _start_war_383(infl1: int, infl2: int, usa_side: int, ussr_side: int) -> void:
	GameManager.start_war(19, TXT_WAR_ATT, TXT_WAR_DEF, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > 19 and ws.wars[19] != null:
		ws.wars[19].name_war = TXT_WAR_NAME
		ws.wars[19].fortnight_max = 11



func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0







