extends "res://数据脚本/event_script_base.gd"

## 原作 Event615.cs：红狮（塞内加尔大选，三选项）。
## 触发：ReqEventForDLC02.cs:919-921 —— DATE_AFTER 1983.2.27；fire_only_once 承担 !event_done[615]。
## 差异：c112.parts[1]/war52 显隐原版不 Destroy 的选项用 _enable 双文案；level_of_unstab→level_of_instability。

const TXT_TITLE := "红狮"
const TXT_DESC := "塞内加尔共和国在非洲的地位不可谓不特殊，一方面，利奥波德·塞达尔·桑戈尔——这位大力宣扬“黑人性”与非洲文化的老诗人曾是非洲社会主义与泛非主义的先驱和重要思想家，另一方面，他又将该国变成了法国的新殖民主义模范殖民地，在民主社会主义理念的面具之下，是事实上的一党制独裁——任何反对派都会遭到毫不留情的镇压（比如因与桑戈尔的意见分歧而被捕的总理马马杜·迪亚，和在监狱中遇害的毛派青年革命哲学家奥马尔·布隆丁·迪奥普），对异见者的恐吓、逮捕、监禁、酷刑和杀害的阴云笼罩于该国上空，再加上法资主导经济、政治腐败、社会裙带关系、宗教势力特权与恩庇政治，使得该国似乎与其他法国的非洲代理人政权别无二致，只有屡遭政治经济危机时塞内加尔政府的稳定局面能够彰显该国的那点特殊之处。\n当然，尽管塞内加尔禁止了除执政党外其他政党的存在，但得益于该国曾作为法属西非的行政中心，政治经济发展水平超越大多数西非国家，故此，该国成为了西非少有的受到1968运动影响的地区，许多地下极左翼团体于该国诞生，其中最富有战斗性的几支分别是由兰丁·萨瓦内领导的“共同行动/新民主革命运动”（该党以毛主义为指导思想），亲阿尔巴尼亚的人民民主联盟（由哈梅丁·拉辛·吉塞领导），亲苏的“独立与劳动党”，主张马列主义的民主联盟。\n步入七八十年代，塞内加尔又面临着新一轮的经济危机与政治动荡，席卷西非的大旱更是使该国经济雪上加霜，学校与工厂中的骚乱急剧增加。为了分化与控制反对派，1976年，塞内加尔政府授权成立了两个合法反对党（根据该规定，每个政党必须代表不同的思潮）：代表马列主义的“非洲独立党-复兴”与代表自由民主主义的塞内加尔民主党，1978年，代表保守主义的塞内加尔共和运动也应运而生。\n1980年12月，桑戈尔主动引退，并根据宪法指定他培养的继承人、总理阿卜杜·迪乌夫为总统。迪乌夫上任后便开始了缓慢的经济调整与政治开放改革，而为了进一步分化反对派，他决定放开对政党数量的限制，许多政党得以注册。在这种情况下，该国迎来了又一次大选，尽管塞内加尔社会党的霸权仍然稳固，但也许……新事物登台之时也快要到了？"
const TXT_OPT0 := "迪乌夫必须下台"
const TXT_OPT0_ALT := "这有什么可供选择的余地吗"
const TXT_OPT1 := "押宝于阿卜杜拉耶·瓦德与塞内加尔民主党"
const TXT_OPT1_DIS := "就算迪乌夫再不堪，我们也不能支持自由派啊"
const TXT_OPT2 := "让他们自己玩议会把戏去吧，我们应当让该国的极左翼团体联合起来"
const TXT_OPT2_DIS := "民主社会主义也是社会主义！"
const TXT_R0 := "塞内加尔军队在冈比亚战争中的灾难性战果导致迪乌夫的名声江河日下，社会党内部也因此出现了分裂（一部分党员出走组建了民主复兴联盟），财政赤字与外债急剧飙升，罢工游行接连不断，卡萨芒斯地区叛乱层出不穷，为此，政府不得不出台紧急措施增收节支，然而这也只是杯水车薪，随着西非法郎贬值，进口商品和生活必需品价格的大幅上涨，人民怨声载道。在这种情况下，1983年2月27日，阿卜杜拉耶·瓦德与塞内加尔民主党在总统选举中击败了迪乌夫，终结了社会党的霸权。新政府实行了一系列以自由市场、开放模式和创造良好投资环境为特征的经济自由化政策，开始了肢解国有资本与政治民主化的进程。现在，只有天知道这位桑戈尔口中的“狡兔”先生会把这个国家带到什么方向了……"
const TXT_R0_FAIL := "不出意料，在1983年2月27日举行的总统选举中，阿卜杜·迪乌夫拿到了83.45%的票数，而议会选举中社会党更是大获全胜，赢得了120个议会席位中的111席，而排名第二的阿卜杜拉耶·瓦德和塞内加尔民主党仅仅只有14.79%的票数和8个议会席位，至于马马杜·迪亚的人民民主运动亦或者其他规模更小的反对党，则更是完全没有能威胁到迪乌夫的能力。塞内加尔社会党的霸权总有终结的那一天，但看起来还不是现在……"
const TXT_R1 := "塞内加尔军队在冈比亚战争中的灾难性战果导致迪乌夫的名声江河日下，社会党内部也因此出现了分裂（一部分党员出走组建了民主复兴联盟），财政赤字与外债急剧飙升，罢工游行接连不断，卡萨芒斯地区叛乱层出不穷，为此，政府不得不出台紧急措施增收节支，然而这也只是杯水车薪，随着西非法郎贬值，进口商品和生活必需品价格的大幅上涨，人民怨声载道。在这种情况下，1983年2月27日，阿卜杜拉耶·瓦德与塞内加尔民主党在总统选举中击败了迪乌夫，终结了社会党的霸权。新政府实行了一系列以自由市场、开放模式和创造良好投资环境为特征的经济自由化政策，开始了肢解国有资本与政治民主化的进程。现在，只有天知道这位桑戈尔口中的“狡兔”先生会把这个国家带到什么方向了……"
const TXT_R2 := "不出意料，在1983年2月27日举行的总统选举中，阿卜杜·迪乌夫拿到了83.45%的票数，而议会选举中社会党更是大获全胜，赢得了120个议会席位中的111席，而排名第二的阿卜杜拉耶·瓦德和塞内加尔民主党仅仅只有14.79%的票数和8个议会席位，至于马马杜·迪亚的人民民主运动亦或者其他规模更小的反对党则更是根本没有威胁到迪乌夫的能力。不过，那又与我们有什么关系呢。\n靠着几内亚、加纳等西非社会主义国家的关系网络，我们成功与共同行动/新民主革命运动、人民民主联盟、民主联盟等极左翼团体建立了联系。在我们的推动下，由共同行动/新民主革命运动牵头成立了塞内加尔共产党/马列主义，兰丁·萨瓦内当选为该党总书记，新党以马克思列宁主义、毛泽东思想为指导思想，并积极参与工人运动和学生运动，向城市与乡村中传播马列主义思想。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	_bind_world()
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var _senegal := world.get_country_by_legacy_index(112)
	var guinea := world.get_country_by_legacy_index(68)
	var opt := event_def.options
	var cond := int(world.completed_event_ids.get("event_597", 0)) == 1 \
			and not _part(112, 1) and not _war_going(52)
	if cond:
		_enable(opt[0], TXT_OPT0)
	else:
		_enable(opt[0], TXT_OPT0_ALT)
	if cond and line > 2:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line < 2 and guinea != null and guinea.has_tag("对华贸易"):
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var senegal := _country(112)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if _res_ev("event_597") == 1 and not _part(112, 1) and not _war_going(52):
				context["result_text"] = TXT_R0
				if senegal != null:
					senegal.government = 3
					senegal.sub_government = 12
				_add(W.I_THOUGHT_FREEDOM, -20)
				_add(W.I_ARMY, -50)
				_add(W.I_BUDGET, -20)
			else:
				context["result_text"] = TXT_R0_FAIL
		1:
			context["result_text"] = TXT_R1
			if senegal != null:
				senegal.government = 3
				senegal.sub_government = 12
				senegal.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_BUDGET, -50)
		2:
			context["result_text"] = TXT_R2
			ws.influence_prc += 20
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if senegal != null:
				senegal.level_of_instability = 300



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

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
			c.puppet_of = -1

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

