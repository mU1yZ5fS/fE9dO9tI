extends "res://数据脚本/event_script_base.gd"

## 原作 Event459.cs：黑色星期四？红色星期四？（突尼斯干预四选项）。
## 触发：ReqEventForDLC02.cs:342-344 —— DATE_AFTER 1978.1.20；fire_only_once 承担 !event_done[459]。
## 差异：Vyshi→亲美、prosov→亲苏、Torg→对华贸易；cw→内战中；
##   结果3文本中 <color=red>...</color> 按项目规则剥除。

const TXT_OPT0_DIS := "可我们还真的能以社会主义者自称吗？"
const TXT_OPT1_DIS := "为什么要帮邪恶帝国？"
const TXT_OPT2_DIS := "法国人为什么还能插手？"
const TXT_R0 := "我们决定全力支持他们。在我们的帮助下，人民团结运动、社会主义民主运动（在我们的帮助下提前成立）和毛主义的突尼斯工人组织等左翼反对派被团结在工会周围，组成了一支人民阵线。数以万计的工人、青年，乃至一些不隶属于UGTT的失业者，被组织为民兵，而“意外”打开的军火库大门更是给了工人们和政府决战的底气，工人民兵纷纷涌上突尼斯的街头，筑起街垒。原本的罢工迅速升级为人民的浪潮，抗议者不仅占领了市中心，还攻入了资产阶级社区和政府机构，最后，海军和部分陆军的倒戈则是为布尔吉巴敲下了丧钟。\n最后，本·萨拉赫出任新的阿拉伯突尼斯共和国的总统，而社会主义民主运动领导人艾哈迈德·梅斯提里则出任总理。在新政府的支持下，布尔吉巴时期的左翼政治犯都被释放和平反，并允许他们组建政党。新的突尼斯采取左翼多党民主和泛阿拉伯主义的原则，他们宣布要清除西方帝国主义在突尼斯的影响，并加强同各个社会主义国家和阿拉伯进步兄弟国家的友谊。很快，突尼斯在我们和苏联的援助下，开始重启国有化和农业合作化运动。突尼斯赠予我们六颗突尼斯软籽石榴，以感谢我们对突尼斯人民的帮助。\n1978年1月26日这一天，在突尼斯被称为“红色星期四”。"
const TXT_R1 := "我们最终决定通过利比亚和阿尔及利亚来干涉突尼斯内政。利比亚和阿尔及利亚在我们的帮助和苏联克格勃的秘密批准下，联合起来制订了一项消灭突尼斯总统的计划。利比亚和阿尔及利亚一直致力于泛阿拉伯主义运动，而卡扎菲因早前将突尼斯和利比亚合并为阿拉伯伊斯兰共和国计划的失败而记恨着布尔吉巴，因此，他庇护了萨拉赫·本·优素福（布尔吉巴过去的竞争者，更支持纳赛尔的泛阿拉伯主义）的一批支持者所建立的突尼斯进步力量民族阵线，为他们提供军事训练，以用于颠覆布尔吉巴政权，而现在，正是机会。\n很快，突尼斯进步力量民族阵线组建了一支名为“突尼斯解放军”的武装小队，同利比亚和阿尔及利亚的民兵和特工一起秘密进入埃及进内，并混入抗议者的队伍，秘密向抗议者提供武器。而克格勃特工则通过突尼斯共产党的组织网络将抗议者、工会、人民团结运动和突尼斯进步力量民族阵线串联起来，同时吸收了一批阿拉伯社会主义者，组成了突尼斯人民民主团结阵线。突尼斯解放军的战士在利比亚人的支持下，在群众大会上伪装成保洁员，用安装在铁皮垃圾桶里的炸弹一劳永逸的干掉了布尔吉巴。随后，人民民主团结阵线就通过发动一切支持者进行暴动，夺取了突尼斯的政权，突尼斯国名也被改为阿拉伯突尼斯人民共和国。经过多方妥协，突尼斯进步力量民族阵线的领导人埃泽丁·谢里夫成为了突尼斯新总统，人民团结运动领导人本·萨拉赫成为了总理，哈比卜·阿库尔留任工会总书记同时兼任副总理，而突尼斯共产党总书记穆罕默德·纳法则在苏联的支持下兼任副总统和内政部长。新政府立刻得到了苏联和我们的承认。他们宣布要清除西方帝国主义在突尼斯的影响，并加强同东方社会主义国家和阿拉伯进步兄弟国家的友谊。随后，突尼斯开始进行新一轮社会主义改革。\n1978年1月26日这一天，在突尼斯被称为“红色星期四”。"
const TXT_R2 := "我们的大使在和法国外长的交谈中，暗示了我们对突尼斯问题的担忧。我们也指出，法国作为一个在马格里布地区拥有巨大影响力的国家，无论如何都不应该对突尼斯的现状坐视不管。\n法国人立刻理解了我们的暗示（或者说他们早有此意？）。很快，一支由鲍勃·德纳尔带领的军团坐着C-160，稳稳的在突尼斯着陆。这支部队立刻冲向总统府。在对总统用子弹痛陈利害后，布尔吉巴总统用身上的28个弹孔做出了回答。\n很快，法国选出了本·阿里作为其代言人，他宣布彻底地转向市场经济和对外开放，并恢复了法国人的军事基地。原先的社会主义宪政党也换汤不换药地被改为了突尼斯民主宪政联盟。虽然这个党既不民主更不宪政，但只要法国人还支持他们，突尼斯应该就能消停了吧？\n新总统本·阿里在当日傍晚时分宣布进入紧急状态，在突尼斯军队和法国雇佣兵的“照顾”下，工会和抗议群众都被镇压。据官方公布的数据，至少有52人丧生，超过365人受伤；而另有消息来源则称，死亡人数可能高达200多人，受伤者数以千计。政府的反击行动紧随其后，超过500人被迅速定罪。与此同时，紧急状态也迟迟没有解除的消息……\n1978年1月26日这一天，在突尼斯成为了敏感话题，被称为“黑色星期四”。"
const TXT_R3 := "随后，局势急转直下，彻底失控：数以万计的工人、青年，乃至一些不隶属于UGTT的失业者，纷纷涌上突尼斯的街头。原本的罢工迅速升级为骚乱与示威的浪潮，抗议者不仅占领了市中心，还侵入了高档社区。尽管当局迅速实施了宵禁，但警方很快便显得力不从心，双方对抗不断加剧。道路上布满了路障，公共建筑遭受破坏，熊熊燃烧的汽车数量激增，局势愈发严峻。\n尽管总统哈比卜·布尔吉巴在当日傍晚时分宣布进入紧急状态，但示威活动非但没有平息，反而愈演愈烈。这是自国家独立以来，政府首次动用了军队介入，由本·阿里指挥，他刚被总理埃迪·努伊拉紧急任命为总安全负责人。\n面对示威群众日益高涨的怒火，军队采取了一系列强硬措施，导致了严重的伤亡事件。据官方公布的数据，至少有52人丧生，超过365人受伤；而另有消息来源则称，死亡人数可能高达200多人，受伤者数以千计。政府的反击行动紧随其后，超过500人被迅速定罪。紧急状态与宵禁措施持续了一个多月之久，直至2月25日及随后的3月20日才相继解除。\n对于政府而言，1月26日的全面罢工不仅是一场危机，更将工会运动中激进反对派的力量推向了前所未有的高度。几位关键领袖，包括哈比卜·阿库尔在内，不幸被捕并入狱。此外，还有13人被判处不等刑罚，从10年苦役到6个月监禁不等。\n从此，在突尼斯，1978年没有一月，一月没有星期四。\n尽管如此，突尼斯的问题并没有解决，事情不会就这样结束的……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var ideology := d[W.I_IDEOLOGY] if d.size() > W.I_IDEOLOGY else 0
	var france := world.get_country_by_legacy_index(21)
	var opt := event_def.options
	if ideology <= 3 and line56 <= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 600:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line56 > 0 and france != null and france.has_tag("对华贸易") and france.government != GameConstants.Government.SOCIALIST:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var tunisia := _country(55)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if tunisia != null:
				tunisia.government = GameConstants.Government.REFORMIST
				tunisia.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				tunisia.set_tag("亲美", false)
				tunisia.set_tag("亲苏", false)
				tunisia.set_tag("对华贸易", true)
				tunisia.内战中 = true
			ws.influence_prc += 20
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -30)
			_add_relation(EmpireData.USSR, 50)
			_add_power(EmpireData.USSR, 10)
		1:
			context["result_text"] = TXT_R1
			if tunisia != null:
				tunisia.government = GameConstants.Government.REFORMIST
				tunisia.sub_government = GameConstants.SubGovernment.PRAGMATIST
				tunisia.set_tag("亲美", false)
				tunisia.set_tag("对华贸易", true)
				tunisia.set_tag("亲苏", true)
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -20)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USSR, 50)
			_add_power(EmpireData.USSR, 10)
		2:
			context["result_text"] = TXT_R2
			if tunisia != null:
				tunisia.government = GameConstants.Government.AUTHORITARIAN
				tunisia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				tunisia.puppet_of = GameConstants.LegacySlot.FRANCE
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 50)
		3:
			context["result_text"] = TXT_R3
			if tunisia != null:
				tunisia.government = GameConstants.Government.AUTHORITARIAN
				tunisia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				tunisia.set_tag("亲美", true)
			_add_power(EmpireData.USA, 50)




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


