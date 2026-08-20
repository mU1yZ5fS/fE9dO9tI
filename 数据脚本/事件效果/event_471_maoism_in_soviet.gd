extends "res://数据脚本/event_script_base.gd"

## 原作 Event471.cs：毛泽东思想在……苏联？（苏联左翼异见者三选项）。
## 触发：ReqEventForDLC02.cs:437-439 —— DATE_AFTER 1980.9.1；fire_only_once 承担 !event_done[471]。
## 差异：relres→ws.get_flag("relres")；proprc→亲中、Torg→对华贸易；
##   SOV_PRC_PartiesConnection 未出现在本事件，data[11] 直接按原版。

const TXT_OPT0_DIS := "我们已经不再需要过去错误的“极左”方法了，韬光养晦才是正道"
const TXT_OPT1_DIS_A := "就算我们需要与北方缓和，也不至于要到这个地步！"
const TXT_OPT1_DIS_B := "苏联不会和我们合作"
const TXT_R0 := "借助在苏联境内布置的暗线，中国工作人员很快便将对古比雪夫地区的工业考察变为了针对潜在同志的摸底行动，并成功将其主要理论家阿列克谢·拉兹拉茨基安全送至北京以领导该党筹备的“海外机关”；格里戈里·伊萨耶夫则在公安同志支持下转入地下，计划巩固本土工人运动并确立其罢工委员会在古比雪夫地区作为第二权威的地位；阿尔巴尼亚同志则同样为其提供了相应助力，以派遣数十位西古里米探员协力的办法筹建了无产阶级专政党的首个东欧分支。当然，我们的目光并不会仅限于此：考虑到“工人中心”作为区域性组织与热心诉诸工团主义用语的特质，导致其不可避免地具有关门主义气息，必须对其进行更加深入的改造：因此，我们的目光同时转向了苏联境内活跃的各派“异端思想者”。其中包括但不限于借助非正式教育学发展壮大，并开始同共青团竞争青年的党外潮流“公社运动”与其主要领导者，计划将其作为发动社会革命契机的“旅长”（Kombrig）组织；从苏联版嬉皮士群体中汲取力量，推崇意大利红色旅、德国红军派与格瓦拉主义政治实践，且同“公社运动”积极串联的“大火”（Antares）俱乐部；以及莫斯科的以卡斯特罗、切·格瓦拉和德布雷精神的“革命马克思主义”思想为导向的切·格瓦拉支队；乃至在莫斯科、图拉和雅罗斯拉夫尔等地颇具影响，主张在1968年精神的基础上走革命马克思主义路线的“争取共产主义的青年”集团。此外，通过外联部同志的协力，我们还在留学苏联的拉美学生与苏联激进主义者中建立了特别关系，将当前正积极抵抗美帝国主义的尼加拉瓜桑解阵与智利的革左运等组织内的武装斗争政治观点与军事训练经验引入这一群体中，基本建成了具有纠察队性质的革命保卫组织“切·格瓦拉国际旅”。旨在替代苏共的苏联革命共产党（布尔什维克）至此雏形已现，并与阿尔巴尼亚在苏联境内寻得的反修正主义政治网络开始融合。当然，克格勃不可能不被完全蒙在鼓里，他们已开始采取相应手段切断“地下电台”、查封“自印出版”并“特别关注”涌入该国境内的第三世界移民。与之相对的则是苏联政府的态度，勃列日涅夫式自信仍在相当程度上支配着该国党政领导层，让其依旧假装列车仍在前进，计划照常进行。至于接下来会发生什么，那就等着瞧罢。"
const TXT_R1_BASE := "我们将所知的异见者情报交给了苏联方面，包括前些年成功将信传递到我国的组织。苏方对我国的政策转变很是高兴，并称赞我国为“社会主义大家庭的团结”做出了巨大贡献。为此，他们与我方达成了一批新的合作协定。|由于“工人中心”一些积极分子非常仔细地坚持研究了十月革命前夕以及卫国战争期间的地下组织活动，这保证了“工人中心”得以在1974至1981年期间成功地活动着。因为他们井井有条的阴谋方法，克格勃无法找出大量激进分子的身份。到1981年，根据苏联法律，没有发现足以拘留或逮捕“工人中心”领导人的事实，安全部门也只能找出该组织领导人的姓名。但是到1981年底，苏联的国际局势变得越来越复杂。在苏共中央委员会上，他们非常担心波兰的工人运动会使苏联工人从中找到某种鼓动，因此，尤里·安德罗波夫亲自下令逮捕“工人中心”的领导人，尽管克格勃没有证据表明他们的非法活动。这是在1981年12月14日波兰宣布戒严状态后的第二天。在古比雪夫，伊萨耶夫和拉兹拉茨基被捕。尽管无论是搜查还是随后的调查都无法收集到任何有关其非法活动的证据，“工人中心”的领导人还是于1982年11月被判处长期徒刑。拉兹拉茨基被判处7年监禁加上5年流放，伊萨耶夫6年徒刑和5年流放。与此同时，其他的左翼异见者也在经历着苏联当局的管控，并继续按照他们的轨迹活动着，谁知道接下来会如何发展？毕竟，苏联这棵大树是如此难以撼动。|"
const TXT_R1_ALB := "阿尔巴尼亚劳动党大力谴责了我们的行为，指责我们背叛革命，并事实上蜕变为莫斯科的傀儡。好吧，不过谁在乎？"
const TXT_R2 := "这些组织在这些年层出不穷，但相比苏联强大的国家机器而言，他们仍是微不足道的。得益于“工人中心”一些积极分子非常仔细地坚持研究了十月革命前夕以及卫国战争期间的地下组织活动，这保证了“工人中心”得以在1974至1981年期间成功地活动着。多亏了井井有条的地下活动方法，克格勃无法找出大量激进分子的身份。到1981年，根据苏联法律，没有发现足以拘留或逮捕“工人中心”领导人的事实，安全部门也只能找出该组织领导人的姓名。但是到1981年底，苏联的国际局势变得越来越复杂。在苏共中央委员会上，他们非常担心波兰的工人运动会使苏联工人从中找到某种鼓动，因此，尤里·安德罗波夫亲自下令逮捕“工人中心”的领导人，尽管克格勃没有证据表明他们的非法活动。这是在1981年12月14日波兰宣布戒严状态后的第二天。在古比雪夫，伊萨耶夫和拉兹拉茨基被捕。尽管无论是搜查还是随后的调查都无法收集到任何有关其非法活动的证据，“工人中心”的领导人还是于1982年11月被判处长期徒刑。拉兹拉茨基被判处7年监禁加上5年流放，伊萨耶夫6年徒刑和5年流放。与此同时，其他的左翼异见者也在经历着苏联当局的管控，并继续按照他们的轨迹活动着，谁知道接下来会如何发展？毕竟，苏联这棵大树是如此难以撼动。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var albania := world.get_country_by_legacy_index(20)
	var sov := world.get_country_by_legacy_index(7)
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var mod53 := world.modifiers.size() > 53 and world.modifiers[53] != null and world.modifiers[53].is_active
	var opt := event_def.options
	if line56 < 2 and albania != null and albania.has_tag("亲中") and world.influence_prc >= 500 and mod6:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if not mod3 and line56 != 0 and world.get_flag("relres") and sov != null and sov.has_tag("对华贸易") and mod53:
		_enable(opt[1], event_def.options[1].text)
	elif line56 == 0:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			ws.influence_prc += 20
			_add_power(EmpireData.USSR, -10)
		1:
			var text := TXT_R1_BASE
			var albania := _country(20)
			if albania != null and albania.has_tag("亲中"):
				text += TXT_R1_ALB
				albania.set_tag("亲中", false)
				albania.set_tag("对华贸易", false)
				albania.set_tag("econ", false)
				albania.set_tag("okb", false)
			context["result_text"] = text
			_add_relation(EmpireData.USSR, 150)
			_add(W.I_BUDGET, 100)
			_add(W.I_SCIENCE, 100)
			_add(W.I_DIPLO, -100)
			ws.influence_prc -= 50
			_add_power(EmpireData.USSR, 50)
		2:
			context["result_text"] = TXT_R2




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

