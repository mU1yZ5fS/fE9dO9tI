extends "res://数据脚本/event_script_base.gd"

## 原作 Event601.cs：两个国家，一面旗帜（几内亚比绍政变，四选项）。
## 触发：ReqEventForDLC02.cs:859-861 —— DATE_AFTER 1980.11.1；fire_only_once 承担 !event_done[601]。
## 差异：proprc→亲中；Torg→对华贸易；name→chinese_name；names1+names2→_leader_name()。

const TXT_OPT0_DIS := "几内亚？赤道几内亚？几内亚比绍？出事的是哪个？"
const TXT_OPT1_DIS_A := "为什么要支持一个军事独裁者？"
const TXT_OPT1_DIS_B := "他们之间有区别吗？"
const TXT_OPT2_DIS := "引法国佬的走狗来侵略我们的同志？你疯了吗"
const TXT_R0_A := "1980年11月14日，尼诺·维埃拉将军发动了一场政变，企图推翻路易斯·卡布拉尔总统，在首都比绍进行了一场激烈的交火后，几内亚和佛得角协助忠诚于政府的部队粉碎了叛军，维埃拉在混战中被流弹击中，当场身亡。随后，我国向几内亚比绍提供了一笔无息贷款，缓解了该国严重的经济危机，该国得以无后顾之忧地继续进行社会主义建设。来自中国的粮食援助与工程队为几内亚比绍经济建设注入了新活力，在中国专家的指导下，崭新的工厂与水利设施在该国建立，长期被忽视的南部农村地区也得到了大力发展。卡布拉尔总统非常感谢我国对他的帮助，宣布将毛主义纳入几佛独立党指导思想中，并学习莫桑比克的经验重启了因党内派系斗争严重而成效甚微的将该党向先锋党转型的道路。在"
const TXT_R0_B := "同志与塞古·杜尔的推动下，几内亚比绍总统路易斯·卡布拉尔与佛得角总统阿里斯蒂德斯·佩雷拉在几内亚首都科纳克里签订了《几内亚佛得角共和国宪章》，正式宣告两国统一，泛非主义之梦得以更进一步。"
const TXT_NAME_UNION := "几内亚佛得角共和国"
const TXT_R0_FAIL := "1980年11月14日，尼诺·维埃拉将军发动了一场政变，企图推翻路易斯·卡布拉尔总统，在首都比绍进行了一场激烈的交火后，忠于维埃拉的部队还是攻入了总统府，路易斯·卡布拉尔总统被迫流亡几内亚。随后，维埃拉成立了军人占绝大多数的革命委员会，禁止了几佛独立党并使几内亚比绍与塞内加尔等亲法国家建立了密切合作，与法国签订了几项合同。出于对我们在政变过程中支持前总统的怨恨，新政府驱逐了我国大使，并转而同中华民国建交。佛得角总统、几佛独立党总书记阿里斯蒂德斯·佩雷拉强烈谴责了“对几内亚比绍革命的背叛”行径和“法帝国主义在非洲的又一笔孽债”，与其政府断绝了关系，并支持忠诚于几佛独立党革命事业的几内亚比绍人民革命武装力量成员再度打起了游击战。“葡萄牙的越南”又要上演一场兄弟阋墙了……"
const TXT_R1 := "1980年11月14日，尼诺·维埃拉将军发动了一场政变，企图推翻路易斯·卡布拉尔总统，在我们的支持下，政变顺利进行，维埃拉成立了军人占绝大多数的革命委员会，接管了政府。维埃拉将军的政变引起了佛得角政府的不满，在经过了几天对几内亚比绍政变性质的分析讨论后，佛得角总统、几佛独立党总书记阿里斯蒂德斯·佩雷拉最终宣布将该党的佛得角部分在1981年1月20日独立为佛得角非洲独立党，两国一党执政实验就此戛然而止，而我国大使也被驱逐出佛得角，不过谁会在意这个不起眼的小国呢？\n在几佛独立党的新一届大会上，路易斯·卡布拉尔被定性为“美帝国主义、法帝国主义与苏联社会帝国主义的走狗，佛得角新殖民主义的代理人”。但愿我们的选择是正确的……"
const TXT_R2 := "我们联系了与几内亚比绍的共产主义政府有领土争端的塞内加尔。1980年11月14日，尼诺·维埃拉将军发动了一场名为“调整运动”的不流血政变，推翻了路易斯·卡布拉尔总统，成立军人占绝大多数的革命委员会，接管了政府。不过，塞内加尔总统阿卜杜·迪乌夫宣布这场政变非法，并以拯救路易斯·卡布拉尔政府的名义入侵了几内亚比绍，尽管几内亚比绍进行了激烈的抵抗，但最终首都比绍还是被攻破。随后，在塞内加尔监督下，该国举行了选举，此前流亡塞内加尔的“几内亚民族解放与独立阵线”（FLING）的本杰明·平托·布尔战胜了几佛独立党推举的候选人，成为了新一任总统，新政府宣布将奉行民主社会主义理念，并与塞内加尔和法国展开合作。佛得角强烈谴责了法帝国主义及其代理人对他国的入侵行径，在他们的支持下，几内亚比绍人民革命武装力量残部对新政府发起了内战。又一场几内亚比绍解放战争开始了……"
const TXT_R3 := "1980年11月14日，尼诺·维埃拉将军发动了一场名为“调整运动”的不流血政变，推翻了路易斯·卡布拉尔总统，成立军人占绝大多数的革命委员会，接管了政府。迫于对几内亚比绍可能倒向亲法国家一边的担忧，安哥拉、莫桑比克、几内亚等国只得承认了新政府。维埃拉将军的政变引起了佛得角政府的不满，在经过了几天对几内亚比绍政变性质的分析讨论后，佛得角总统、几佛独立党总书记阿里斯蒂德斯·佩雷拉最终宣布将该党的佛得角部分在1981年1月20日独立为佛得角非洲独立党，两国一党执政实验就此戛然而止。尽管双方又在之后恢复了外交关系，但几内亚比绍与佛得角之间的裂痕恐怕再也无法弥合了……"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line != 0 and line != 4:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	if line >= 3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var guinea := _country(68)
	var guinea_bissau := _country(114)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if guinea != null and guinea.has_tag("对华贸易") and ws.influence_prc >= 500:
				context["result_text"] = TXT_R0_A + _leader_name() + TXT_R0_B
				if guinea_bissau != null:
					guinea_bissau.set_tag("亲中", true)
					guinea_bissau.set_tag("对华贸易", true)
					guinea_bissau.chinese_name = TXT_NAME_UNION
				ws.influence_prc += 10
			else:
				context["result_text"] = TXT_R0_FAIL
				if guinea_bissau != null:
					guinea_bissau.government = GameConstants.Government.AUTHORITARIAN
					guinea_bissau.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					_leave_alliances(guinea_bissau)
		1:
			context["result_text"] = TXT_R1
			if guinea_bissau != null:
				guinea_bissau.government = GameConstants.Government.AUTHORITARIAN
				guinea_bissau.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				guinea_bissau.set_tag("亲中", true)
				guinea_bissau.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -50)
		2:
			context["result_text"] = TXT_R2
			if guinea_bissau != null:
				guinea_bissau.puppet_of = GameConstants.LegacySlot.FRANCE
				guinea_bissau.government = GameConstants.Government.LIBERAL
				guinea_bissau.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				guinea_bissau.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -50)
		3:
			context["result_text"] = TXT_R3
			if guinea_bissau != null:
				guinea_bissau.government = GameConstants.Government.AUTHORITARIAN
				guinea_bissau.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST






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
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
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


