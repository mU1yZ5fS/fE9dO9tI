extends "res://数据脚本/event_script_base.gd"

## 原作 Event609.cs：直到永远，总统阁下（科摩罗反政变，四选项）。
## 触发：ReqEventForDLC02.cs:894-896 —— DATE_AFTER 1978.5.12；fire_only_once 承担 !event_done[609]。
## 差异：science[18]→techs.unlocked[18]；modifies[3].active→modifiers[3]；name→chinese_name。

const TXT_OPT0_DIS := "他是个疯子，而我是个聪明人"
const TXT_OPT1_DIS := "和苏联？他们是和法国沆瀣一气的一群人！"
const TXT_OPT2_DIS := "殖民主义去死吧！"
const TXT_R0_INTRO := "我们谨慎的提供驻科大使馆工作者向索利莱总统提供了通知。并向其表示愿意提供必要的帮助。\n"
const TXT_R0_BODY := "深夜，法国雇佣兵乘着夜色攻入了总统府。但出乎意料遭到了强硬的抵抗，对方口中说着既不是法语也不是斯瓦希里语的奇怪语言，训练有素，指挥完善。雇佣军很快就被打的溃不成军，鲍勃本人也受了伤。科摩罗全国陷入了紧急状态，全国人民都被动员起来保卫独立。在丢下了十具尸体和数杆步枪，以及一份手写的政变计划后，雇佣军们逃离了科摩罗。他们有的前往马约特岛，也有的前往留尼汪。鲍勃本人则前往法国养伤后不治身亡。\n随后在当日的日间新闻上，阿里·索利莱强烈谴责了死灰复燃的法兰西殖民主义妄图染指科摩罗。“科摩罗再也不会陷入痛苦的殖民之中，这不是几个人几条枪就能夺去的胜利。”总统阁下如是说道。同时他也感谢了我国的帮助，"
const TXT_R0_MAO := "他不仅在民族统一阵线党的新党章中认可了毛主义的理念，"
const TXT_R0_TAIL := "并公开向我们靠拢。"
const TXT_NAME_SUCCESS := "科摩罗人民共和国"
const TXT_R0_FAIL_BODY := "深夜，法国雇佣兵乘着夜色攻入了总统府。但出乎意料遭到了强硬的抵抗，对方口中说着既不是法语也不是斯瓦希里语的奇怪语言。他们尽管和雇佣军打的有来有回，鲍勃本人也受了伤，过于老久的武器导致了他们付出了更大的伤亡，神秘势力不得不撤退，阿里总统也就此被捕。科摩罗全国陷入了紧急状态。\n随后经过了短暂的军事管理后，艾哈迈德·阿卜杜拉总统宣布结束流亡，在巴黎的直接授意下再度当选总统。他对前任的社会改革完全不感兴趣，更别提无神论和反法元素了。但法国对现状很满意，双方正式交换了文书并建交。阿里也被判处叛国罪而被处死。但是，阿卜杜勒事实上不过是德纳尔的傀儡，雇佣兵之王彻底支配了这个小岛，看起来它又一次回到了独立之前……\n直到永远啊总统阁下，直到永远……"
const TXT_NAME_FAIL := "科摩罗伊斯兰联邦共和国"
const TXT_R1 := "我们决定利用与苏联的良好关系来拯救科摩罗。深夜，法国雇佣兵乘着夜色攻入了总统府。但出乎意料遭到了强硬的抵抗，对方口中说着既不是法语也不是斯瓦希里语的奇怪语言，训练有素，指挥完善。雇佣军很快就被打的溃不成军，鲍勃本人也受了伤。事后方知这支英勇的队伍是驻扎在安哥拉的古巴军队。科摩罗全国陷入了紧急状态，全国人民都被动员起来保卫独立。在丢下了三十具尸体和数杆步枪，以及一份手写的政变计划后，雇佣军们逃离了科摩罗。他们有的前往马约特岛，也有的前往留尼汪。鲍勃本人则前往法国养伤后不治身亡。\n苏联愿意为科国的经济提供大量帮助，并派出了足够多的古巴士兵保卫该国。只要其愿意为苏联提供足够的香蕉。从工业到城市建设，甚至在领土问题上苏联都愿意为其开绿灯。但是苏联的这些援助并非免费的午餐，作为条件，该国必须优先和苏联打交道，并不征收对苏联商品的关税。尽管该国对我们的好感大于苏联，但是苏联的影响力与日俱增，终有一天会赶超我们的。"
const TXT_NAME_R1 := "科摩罗社会主义共和国"
const TXT_R2 := "深夜，法国雇佣兵攻入了总统府。孱弱的国防力量和民兵难以抵抗强大的法国军队。在付出了大量伤亡后，阿里总统宣布投降并辞职。随后，他的死对头艾哈迈德·阿卜杜拉宣布结束流亡，在巴黎的直接授意下再度当选总统。他对前任的社会改革完全不感兴趣，更别提无神论和反法元素了。但法国对现状很满意，双方正式交换了文书并建交。阿里也被判处叛国罪而被处死。但是，阿卜杜勒事实上不过是德纳尔的傀儡，雇佣兵之王彻底支配了这个小岛，看起来它又一次回到了独立之前。\n我国外交部发言人发表声明：“我国支持法国的正义行动。法国的正义行动，撬走了骑在非洲人民头上的极权主义暴君，推动了非洲社会的进步，促进了印度洋地区的稳定。我们欢迎并支持阿卜杜拉先生再度就任总统，并期待两国关系发展的新时代！”\n法国感谢我们对他们行动的支持，阿卜杜拉，尤其是他背后的鲍勃·德纳尔对我们承认了新政府感到十分高兴，他将阿卜杜拉出访北京的行程安排在了巴黎之后，甚至在华盛顿之前。科摩罗与我们达成了几项合作协定，友谊万年长！"
const TXT_R3 := "深夜，法国雇佣兵攻入了总统府。孱弱的国防力量和民兵难以抵抗强大的法国军队。在付出了大量伤亡后，阿里总统宣布投降并辞职。随后，他的死对头艾哈迈德·阿卜杜拉宣布结束流亡，在巴黎的直接授意下再度当选总统。他对前任的社会改革完全不感兴趣，更别提无神论和反法元素了。但法国对现状很满意，双方正式交换了文书并建交。阿里也被判处叛国罪而被处死。但是，阿卜杜勒事实上不过是德纳尔的傀儡，雇佣兵之王彻底支配了这个小岛，看起来它又一次回到了独立之前。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	_bind_world()
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var diplo := d[W.I_DIPLO] if d.size() > W.I_DIPLO else 0
	var comoros := world.get_country_by_legacy_index(158)
	var opt := event_def.options
	if line <= 1 and _mod_active(3):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 700:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if comoros != null and comoros.government != 1 and line > 1 and diplo <= 700:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var comoros := _country(158)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			var text := TXT_R0_INTRO
			if _tech_unlocked(18):
				text += TXT_R0_BODY
				if _mod_active(3):
					text += TXT_R0_MAO
				text += TXT_R0_TAIL
				if comoros != null:
					comoros.government = 1
					comoros.sub_government = 17 if _mod_active(3) else 1
					_leave_alliances(comoros)
					comoros.set_tag("亲中", true)
					comoros.set_tag("对华贸易", true)
					comoros.chinese_name = TXT_NAME_SUCCESS
			else:
				text += TXT_R0_FAIL_BODY
				if comoros != null:
					comoros.government = 0
					comoros.sub_government = 7
					_leave_alliances(comoros)
					comoros.puppet_of = 21
					comoros.chinese_name = TXT_NAME_FAIL
			context["result_text"] = text
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -20)
			if comoros != null:
				comoros.government = 2
				comoros.sub_government = 3
				_leave_alliances(comoros)
				comoros.set_tag("亲苏", true)
				comoros.set_tag("对华贸易", true)
				comoros.chinese_name = TXT_NAME_R1
		2:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -30)
			if comoros != null:
				comoros.government = 0
				comoros.sub_government = 7
				_leave_alliances(comoros)
				comoros.puppet_of = 21
				comoros.set_tag("对华贸易", true)
				comoros.chinese_name = TXT_NAME_FAIL
		3:
			context["result_text"] = TXT_R3
			if comoros != null:
				comoros.government = 0
				comoros.sub_government = 7
				_leave_alliances(comoros)
				comoros.puppet_of = 21
				comoros.chinese_name = TXT_NAME_FAIL






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



func _tech_unlocked(idx: int) -> bool:
	return ws.techs != null and ws.techs.unlocked.size() > idx and ws.techs.unlocked[idx]

