extends "res://数据脚本/event_script_base.gd"

## 原作 Event600.cs：坦桑尼亚大选（四选项）。
## 触发：ReqEventForDLC02.cs:854-856 —— DATE_AFTER 1985.10.1；fire_only_once 承担 !event_done[600]。
## 差异：描述按 resultOfEvents[599]==0 动态插入巴布回归句；JoinAllOurAlliances(true)→_join_alliances。

const TXT_DESC_A := "在坦桑尼亚成立之后，自1965年开始，每五年将会进行一次总统选举，但是由于坦桑尼亚是革命党的一党制共和国，自然这五年的总统选举都会是革命党推举的总统候选人。然而据传言，已经连任四届坦桑尼亚总统的尼雷尔已经决定不参与总统选举并将自己的继承人扶上位。根据我们的情报，尼雷尔的继承人大概率是阿里·哈桑·姆维尼，他是1984年的桑给巴尔总统，因其治下的市场自由化政策得以恢复桑给巴尔的经济而知名。\n如果我们对坦桑尼亚的影响力足够大到可以让尼雷尔转变主意的话，我们其实还有几个备用人选，第一个就是前桑给巴尔政党乌玛党的党主席阿卜杜勒拉赫曼·穆罕默德·巴布，他是一位激进的马克思主义者，巴布参加过全非洲人民会议，访问过我国并于我国高层建立了密切联系，其为坦赞铁路的建成发挥了关键作用，但其并不看好尼雷尔的乌贾马社会主义，且因时任桑给巴尔总统阿贝德·阿马尼·卡鲁梅刺杀案而被错捕，最后被特赦"
const TXT_DESC_MID := "并在我们的帮助下重回政府，并逐步扩大了自己的影响）"
const TXT_DESC_B := "。第二位是恩贡巴莱·姆维鲁，其为坦噶尼喀非洲民族联盟（革命党在坦噶尼喀地区的前组织）的领导人之一，并参与了将坦噶尼喀非洲民族联盟和桑给巴尔的非洲-设拉子党合并为革命党的过程，其有对马克思主义有着坚定的信念且较为支持乌贾马社会主义。第三位则是名不见经传的斯坦福经济学博士易卜拉欣·利彭巴，其支持自由市场，虽然肯定成不了革命党的总统候选人，但是可以让他参与内阁来逐渐影响坦桑尼亚。"
const TXT_OPT0_DIS := "我们对我们的盟友干预的太过激进了"
const TXT_OPT1_DIS := "我们为何要阻挠我们的好盟友进行改革？"
const TXT_OPT2_DIS := "我们怎么能放任这种右翼分子来污染我们的非洲社会主义同志？"
const TXT_R0 := "在我们为坦桑尼亚建设做的贡献面前，尼雷尔最终同意将姆维尼撤职，并将巴布推举为坦桑尼亚总统候选人，但是革命党党主席一职依旧由尼雷尔担任。不出所料，巴布顺利的在1985年选举中当上坦桑尼亚总统，其宣布将会对坦桑尼亚进行更进一步的社会主义化。"
const TXT_R1_PRE_A := "在我们为坦桑尼亚建设做的贡献面前"
const TXT_R1_PRE_B := "在我们和苏联为坦桑尼亚建设做的贡献面前"
const TXT_R1_SEV := "，尼雷尔最终同意将姆维尼撤职，并将姆维鲁推举为坦桑尼亚总统候选人，但是革命党党主席一职依旧由尼雷尔担任。不出所料，姆维鲁顺利的在1985年选举中当上坦桑尼亚总统，并宣布将会继续维持乌贾马社会主义政策，但是由于苏联在当地的长期影响使得坦桑尼亚最终更加的亲近苏联而非亲近我们。"
const TXT_R1_NO_SEV := "在我们和苏联为坦桑尼亚建设做的贡献面前，尼雷尔最终同意将姆维尼撤职，并将姆维鲁推举为坦桑尼亚总统候选人，但是革命党党主席一职依旧由尼雷尔担任。不出所料，姆维鲁顺利的在1985年选举中当上坦桑尼亚总统，并宣布将会继续维持乌贾马社会主义政策。"
const TXT_R2 := "在我们为坦桑尼亚建设做的贡献面前，尼雷尔最终同意让利彭巴担任坦桑尼亚政府的经济顾问，并将姆维尼推举为坦桑尼亚总统候选人，但是革命党党主席一职依旧由尼雷尔担任。不出所料，姆维尼顺利的在1985年选举中当上坦桑尼亚总统，其宣布将会对坦桑尼亚的经济进行大范围的改革，接下来便是期待他们的改革成果是否成效。"
const TXT_R3 := "尼雷尔最终将姆维尼推举为坦桑尼亚总统候选人，但是革命党党主席一职依旧由尼雷尔担任。不出所料，姆维尼顺利的在1985年选举中当上坦桑尼亚总统。姆维尼在当上总统后，进行全国范围内的经济自由化政策，鼓励私营企业的发展，开始与国际货币基金组织进行谈判，并以拒绝削减免费公共服务和政府内部加薪，最后获得了一笔低息贷款。之后开始向政府内部进行改革并准备实行多党制。但是在其经济改革下，腐败行为逐渐增加，“奔驰人”也越来越多，贫富差距逐步拉大。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	var desc := TXT_DESC_A
	if int(world.completed_event_ids.get("event_599", 0)) == 0:
		desc += TXT_DESC_MID
	desc += TXT_DESC_B
	event_def.description = desc
	if line < 2 and int(world.completed_event_ids.get("event_599", 0)) == 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line < 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line > 2 and not world.completed_event_ids.has("event_500"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var tanzania := _country(122)
	var china := _country(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_BUDGET, -50)
			if tanzania != null:
				tanzania.government = GameConstants.Government.SOCIALIST
				tanzania.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				_join_alliances(tanzania)
				tanzania.social_stability = 1000
				tanzania.set_tag("对华贸易", true)
			ws.influence_prc += 50
		1:
			var text := TXT_R1_NO_SEV
			if tanzania != null and tanzania.has_tag("sev"):
				var pre := TXT_R1_PRE_A
				if china != null and china.has_tag("sev"):
					pre = TXT_R1_PRE_B
				text = pre + TXT_R1_SEV
			context["result_text"] = text
			if tanzania != null:
				_leave_alliances(tanzania)
				if tanzania.has_tag("sev"):
					_establish_prosoviet(tanzania)
					_add_power(EmpireData.USSR, 25)
					_add_relation(EmpireData.USSR, 100)
				else:
					_establish_prochina(tanzania)
			_add(W.I_BUDGET, -50)
			if tanzania != null:
				tanzania.government = GameConstants.Government.SOCIALIST
				tanzania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				tanzania.set_tag("对华贸易", true)
				tanzania.social_stability = 1000
			ws.influence_prc += 5
		2:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -60)
			if tanzania != null:
				tanzania.government = GameConstants.Government.LIBERAL
				tanzania.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.set_tag("对华贸易", true)
				tanzania.social_stability = 1000
			ws.influence_prc += 5
		3:
			context["result_text"] = TXT_R3
			_add(W.I_BUDGET, -60)
			if tanzania != null:
				tanzania.government = GameConstants.Government.REFORMIST
				tanzania.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.set_tag("对华贸易", true)
				tanzania.social_stability = 1000
			ws.influence_prc += 5






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

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = GameConstants.LegacySlot.NONE


