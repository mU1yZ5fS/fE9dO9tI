extends "res://数据脚本/event_script_base.gd"

## 原作 Event651.cs：树丛恶魔（塞拉利昂暴乱，三选项）。
## 触发：TimeScript.cs:11027-11033 —— (月>=5 且 年>=1982 或 年>=1983)。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线）。
##  - War 77：GameManager.start_war(77,...) + fortnight_max=40（TickTime(40)），
##    SovietSupportDefender/AmericanSupportAttacker → ussr_side=1 / usa_side=0。
##  - c107=塞拉利昂；c107.parts[0]=true 保留。

const TXT_TITLE := "树丛恶魔"

const TXT_DESC := "塞拉利昂自1961年独立后便长期为政治问题所困扰：虽说该国以英联邦内的“狮子山”与“河里淘钻”之国闻名，但该国似乎并没有配得上如此财富的手腕。自塞拉利昂国父米尔顿·马盖与其弟相继被反英情绪绊倒后，最高权力便落入了全国大会党党魁萨卡·斯蒂文森手中。斯蒂文森自诩将走一条社会主义道路，并对该国发起了令人印象深刻的革新：塞拉利昂脱离了英联邦框架，正式转为共和体制；随后便是在不结盟旗下同我国建交，并对英国产业坚决没收，将其转为民族资产。可他也就到此为止了——斯蒂文森的一党制构型与其内部的贪污腐败“盛况”只会叫人想到扎伊尔的大酋长，被塞拉利昂回收的民族资产也事实上成为了“家天下”私产。与此同时，当局的胃口竟仍无法满足，甚至将黑手伸向了教育与医疗经费。这只会让塞拉利昂全国变成个火药桶——也就在今天，斯蒂文森的对头塞拉利昂人民党借势发起了全国暴乱。后者成功聚集了大量对斯蒂文森部族不满的门德人，并背靠英美国家的支持预备起事。如果我们想要在钻石之国立足的话，现在也是时候了。"

const TXT_OPT0 := "支持斯蒂文森维持国内秩序，打击新殖民主义者的代理人！"
const TXT_OPT0_DIS := "我们没必要染黑自己的手"
const TXT_OPT1 := "支持塞拉利昂人民党，并协助其发动反政府起义！"
const TXT_OPT1_DIS := "真的要支持外国代理人摘桃子吗？"
const TXT_OPT2 := "充耳不闻"

const TXT_R0 := "我们坚决控诉塞拉利昂反对派不识大体并有意识充当外国势力侵略走卒的行为，并向政府送去了援助。斯蒂文森对此表示相当感动，并顺势同中国建立了合作伙伴关系。虽说塞拉利昂的暴乱迅速演变为了双边无差别攻击的大规模流血事件，可斯蒂文森还是能够背靠我国援助，以及自己同军方的关系牢牢掌握大局。国际社会对此则表示“高度关切”并附上谴责——当然也就到此为止了。"

const TXT_R1 := "我们坚决控诉塞拉利昂政府的暴行并积极声援反对派，这最终导致塞拉利昂政府决定同我国断交并押注苏联——前提是在他们还能保住政权的情况下。得到了中国支持的人民党得以将暴乱升级为全国范围的起义，塞拉利昂完全陷入了无差别屠杀的血海……我们需要赶在一切无法挽回前尽快行动！"

const TXT_R2 := "塞拉利昂的暴乱迅速演变为了双边无差别攻击的大规模流血事件，可斯蒂文森还是能够背靠自己同军方的关系牢牢掌握大局。国际社会对此则表示“高度关切”并附上谴责——当然也就到此为止了。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var opt := event_def.options
	if line != 0 and line != 4:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 3:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var sierra := ws.get_country_by_legacy_index(107)
	if sierra != null:
		sierra.government = 0
		sierra.sub_government = 13
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if sierra != null:
				sierra.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -20)
			ws.influence_prc += 15
			_add(W.I_DIPLO, 15)
			_add_relation(EmpireData.USA, -100)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -40)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, -10)
			if sierra != null:
				while sierra.parts.size() <= 0:
					sierra.parts.append(false)
				sierra.parts[0] = true
			GameManager.start_war(77, "人民党", "政府军", 200, 800, 0, 1)
			if ws.wars.size() > 77 and ws.wars[77] != null:
				ws.wars[77].name_war = "塞拉利昂内战"
				ws.wars[77].fortnight_max = 40
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
