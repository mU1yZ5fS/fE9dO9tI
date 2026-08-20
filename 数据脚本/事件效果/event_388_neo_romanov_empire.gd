extends "res://数据脚本/event_script_base.gd"

## 原作 Event388.cs：新罗曼诺夫帝国（苏联吞并东欧/蒙古，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 描述随机票数 prepare 用 randi_range 复现；
##  - 原版 iron_and_blood 成就 Set(142) 已接 Achievements；
##  - ingamewars[22].usa_place → WarData.usa_side（c51 对华贸易时置 0）。

const TXT_DESC_FMT := "更让人始料不及的事发生了，苏联领导人格里戈里·罗曼诺夫宣称：“一些处于社会主义大家庭的国家已经表达了加入苏联的期望。出于尊重其自决权的需要，我们绝不能否认他们的要求。但事关重大，有必要为此举行一场全民公投。”\n长久以来，保加利亚便已为成为苏联的第16个加盟共和国做足了准备，驱动其加入苏联的原因很可能是其欠苏联的外债。然而，现在该国已经举行了公投，其中有{1}%的公民支持加入苏联。\n长期以来，蒙古便被看作是“主权最名不副其实的社会主义国家”，在苏联军队的监管下，那里甚至连分离主义团体产生的苗头都没有。驻守在外贝加尔湖军区的苏军牢牢把控当地局势。因此结果显而易见，有{2}%的公民支持加入苏联。\n而在相对“叛逆”得多的波兰境内，问题则要复杂的多。已经数次失去主权的国家绝不会轻易再度灭亡。但这次，华沙并没有什么新闻。因为有{2}%的公民支持波兰成为苏联境内的苏维埃共和国。\n所以究竟发生了什么，为什么发生了这种事，这些问题均悬而未决。因此，美国和西方国家指责苏联伪造全民公决结果并借机吞并这些国家。而苏联则称西方言行不一。\n可我们对此应该怎么做？毕竟在此次扩张后，我们与苏联之间的边界扩大了许多倍。"
const TXT_OPT2_RELRES := "与苏联断交，并让他们尝尝“第二次珍宝岛冲突”！（需要75.0点{2}）"
const TXT_OPT2_NORELRES := "让他们尝尝“第二次珍宝岛冲突”！（需要75.0点{2}）"
const TXT_DIS_INFLUENCE := "中国的国际影响力应高于{0}......"
const TXT_DIS_ARMY := "军事实力必须高于{0}点......"
const TXT_DIS_WAR := "战争已经爆发！"
const TXT_DIS_ISLANDS := "银龙岛与黑瞎子岛已经属于我国！"
const TXT_DIS_FACTION := "极左派并不是党内的主要派系......"
const TXT_R0 := "苏联的新帝国主义政策即将大功告成......"
const TXT_R1 := "中国外交部长称：“苏联的扩张直接威胁中国国家安全，加剧中苏边界冲突。我们绝不承认各国内举行的公投”。\n苏联外交政策设计师安德烈·葛罗米柯则回应中国是“民族的监狱，一切有关独立的要求都将被利维坦残酷镇压。”"
const TXT_R2_FMT := "中国部队穿过乌苏里江，并登陆银龙岛与黑瞎子岛屿。对岸的苏联边界部队以重机枪与狙击枪回应，随后便是步兵战车赶来。苏军也开始准备登岛作战。\n苏联领导人格里戈里·罗曼诺夫威胁中国称：“倘若中国军队敢跨过乌苏里江，就给中国人迎头痛击”。同时他还声称：“不妨让我们上堂历史课，过去俄罗斯对中国领土的宣称确实少不了。比如伊犁地区啊、黄俄罗斯计划啊。也许是时候让我们把这些扩张计划落地了？”\n{1}"
const TXT_RELRES := "苏联与中华人民共和国之间的外交关系急剧恶化。"
const TXT_WAR_NAME := "第二次珍宝岛冲突"
const TXT_WAR_ATT := "中国"
const TXT_WAR_DEF := "苏联"


const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	event_def.description = TXT_DESC_FMT.format(["\n", randi_range(80, 94), randi_range(80, 94)])
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	var relres: bool = world.get_flag("relres")
	var war22 := world.wars[22] if world.wars.size() > 22 else null
	if relres and world.influence_prc >= 750 and _d(W.I_ARMY) >= 750 			and GameManager.is_faction_leading(0) 			and (war22 == null or not war22.is_going) and _d(133) == 0:  # 原版 data[133]
		_enable(opt[2], TXT_OPT2_RELRES.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif not relres and world.influence_prc >= 950 and _d(W.I_ARMY) >= 750:
		_enable(opt[2], TXT_OPT2_NORELRES.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif world.influence_prc < 750:
		_disable(opt[2], TXT_DIS_INFLUENCE.format([95]))
	elif _d(W.I_ARMY) < 750:
		_disable(opt[2], TXT_DIS_ARMY.format([75]))
	elif war22 != null and war22.is_going:
		_disable(opt[2], TXT_DIS_WAR)
	elif _d(133) != 0:  # 原版 data[133]
		_disable(opt[2], TXT_DIS_ISLANDS)
	else:
		_disable(opt[2], TXT_DIS_FACTION)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	for i in [2, 6, 9]:
		var c := ws.get_country_by_legacy_index(i)
		if c != null:
			c.set_tag("亲苏", false)
			c.set_tag("对华贸易", false)
			c.set_tag("ovd", false)
			c.set_tag("sev", false)
	_add_power(EmpireData.USSR, 150)
	var ussr := ws.get_country_by_legacy_index(7)
	if ussr != null:
		if ussr.parts.size() < 3:
			ussr.parts.resize(3)
		if ussr.parts[0]:
			ussr.parts[2] = true
			ussr.parts[0] = false
		else:
			ussr.parts[1] = true
	for c in ws.countries:
		if c != null and c.puppet_of == 7:
			c.government = GameConstants.Government.AUTHORITARIAN
			c.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
	if ussr != null:
		ussr.government = GameConstants.Government.AUTHORITARIAN
		ussr.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
			_add_relation(EmpireData.USSR, -500)
			_add_relation(EmpireData.USA, 100)
			_add(W.I_DIPLO, -50)
		_:
			context["result_text"] = TXT_R2_FMT.format(["\n", TXT_RELRES if ws.get_flag("relres") else ""])
			ws.set_flag("relres", false)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				ws.empires[EmpireData.USSR].relations = 0
			# 原作 Event388.cs:122：iron_and_blood → achievements.Set(142)
			Achievements.set_achievement(142)
			_start_war_388()
			var usa388 := ws.get_country_by_legacy_index(51)
			if ws.wars.size() > 22 and ws.wars[22] != null and usa388 != null and usa388.has_tag("对华贸易"):
				ws.wars[22].usa_side = 0
			_add(W.I_PARTY_SUPPORT, 300)
			_add(W.I_ARMY, -750)


func _start_war_388() -> void:
	GameManager.start_war(22, TXT_WAR_ATT, TXT_WAR_DEF, 250, 750, -1, -1)
	if ws.wars.size() > 22 and ws.wars[22] != null:
		ws.wars[22].name_war = TXT_WAR_NAME
		ws.wars[22].fortnight_max = 500




func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0







