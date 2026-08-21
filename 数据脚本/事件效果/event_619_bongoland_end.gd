extends "res://数据脚本/event_script_base.gd"

## 原作 Event619.cs：“邦戈兰”的终结？（加蓬干预，五选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:4656-4658（this_type 外交按钮）手动 number_event=619。
## 差异：based→有驻军基地；OilProd 已建模（ws.oil_prod），result1三路/2/3/4 各 +100；IsSocialism/IsAuthoritarianism→ws 谓词；name→chinese_name。

const TXT_OPT1_DIS := "我们没法找到这些人……"
const TXT_OPT2_DIS := "我们不会找他们"
const TXT_OPT3_DIS := "他们太左了！"
const TXT_OPT4_DIS := "他们没有足够力量"
const TXT_R0_INTRO := "加蓬召开由广泛的政治团体参加的全国协商会议，讨论“国家民主化前途”。此时，全国已出现多个政党和组织，有多个组织组成反对派联合阵线在全国会议上同加蓬民主党斗争。反对派号召民众举行总罢工，对邦戈政权施加压力，政府机构运行陷入混乱状态。|"
const TXT_R0_LEFT := "邦戈宣布实行多党制，成立过渡政府，吸收反对派人士入阁，但这一举动让法国觉得步子太小，随后，在法国的压力下，邦戈宣布辞职，进行大选。加蓬举行了全国立法选举和大选，在法国的支持下，左翼在议会中拿下了多数。全国复兴运动“原始派”、加蓬人民联盟、加蓬进步党和加蓬争取社会主义协会组成了联合政府，开始进行民主改革和经济改革，并建设福利制度。"
const TXT_R0_ELSE := "邦戈宣布实行多党制，成立过渡政府，吸收反对派人士入阁。加蓬举行了全国立法选举，组成由原执政的民主党占微弱多数的多党议会。成立了由过渡政府总理领导的、有反对派和无党派人士参加的新政府。在国际政治气候的影响下，加蓬政局持续动荡。尽管如此，邦戈看起来仍将继续坐在加蓬的总统宝座之上，法国人将继续保障他的地位……"
const TXT_R1 := "得益于我们此前联系到空军上尉亚历山大·曼贾·恩库塔的军内异见团体，帮助他们完善了政变计划，联系到加蓬政权内同情反对派和民主化的朱尔·博尔德斯·奥古利根德、安德烈·桑巴特、迪约·吉武旺吉·迪·恩丁格和莱昂·梅比亚梅等人，并策反了国民宪兵队和总统卫队的部分军官，我们得以成功发动一场政变。在空军内支持者成功轰炸了总统府以及主要军队驻地后，地面部队也展开行动，占领了总统府，控制了政府和主要机关和要地，抓获了邦戈，解散了加蓬民主党政府，政变集团宣布成立救国委员会，进行改革，并向我们靠近……"
const TXT_R2 := "得益于我们此前联系到空军上尉亚历山大·曼贾·恩库塔的军内异见团体，帮助他们完善了政变计划，联系到民主化反对派的最大派系——全国复兴运动“伐木者派”，并策反了国民宪兵队和总统卫队的部分军官，我们得以成功发动一场政变。在空军内支持者成功轰炸了总统府以及主要军队驻地后，地面部队也展开行动，占领了总统府，控制了政府和主要机关和要地，抓获了邦戈，解散了加蓬民主党政府，取缔民主党。政变集团宣布成立由保罗·姆巴·阿巴索贝领导的过渡政府，吸纳了大批反对派，进行民主改革。"
const TXT_R3 := "加蓬人民联盟主席皮埃尔·芒邦杜已与国民宪兵队参谋长阿兰·穆萨武、马本达中校、陆军总参谋长乔治·穆班吉奥中校以及在总统卫队的营长马赛厄斯·布松吉等人取得联络，散发反政府传单，要求实行政治改革，伺机发动政变。在我方的情报支持下，我们帮助他们完善了政变计划，联系到空军上尉亚历山大·曼贾·恩库塔的军内异见团体，并串联起全国复兴运动“原始派”、加蓬进步党、加蓬社会主义党和加蓬社会主义联盟等左翼力量，发起了一场政变。在空军内支持者成功轰炸了总统府以及主要军队驻地后，地面部队也展开行动，工运和学运也支持政变，他们扰乱了亲邦戈派力量，并和政变部队一起占领了总统府，控制了政府和主要机关和要地，抓获了邦戈，解散了加蓬民主党政府，最终，加蓬民主党也被取缔，大量参与镇压民主运动的官员被公审清算。政变力量效仿1964年政变，成立了革命委员会和临时政府，并任命皮埃尔·芒邦杜为新总统。新政府和革命委员会吸纳了大多数民主派和左翼力量，宣布将继承1964年政变的精神，反对帝国主义，没收法帝资产，开展民主化，进行广泛的经济和政治改革，并为1964政变等事件平反，建设民主的社会主义。\n加蓬不再是帝国主义者和卖国分子的加蓬了！"
const TXT_R4 := "在我们的支持下，以加蓬社会主义联盟为主体的左翼反对派已经重新成立了名为加蓬民族革命运动的统战机构，吸收了加蓬社会主义党和全国复兴运动“原始派”等左翼反对派，成立了“热尔曼·姆巴烈士旅”作为武装翼，进入该国开展游击运动和武装斗争。在加蓬工运和学运活跃、民众不断反对邦戈的情况下，革命已经到了最终进军的时机。加蓬民族革命运动决定武装群众，彻底推翻独裁政府。另一边，我们也联系到加蓬人民联盟和国民宪兵队参谋长阿兰·穆萨武、马本达中校、陆军总参谋长乔治·穆班吉奥中校以及在总统卫队的营长马赛厄斯·布松吉等左翼军官，吸收他们进入加蓬民族革命运动。在热尔曼·姆巴烈士旅进军的同时，左翼军官也配合行动，发起政变推翻了加蓬民主党，逮捕了邦戈，与革命力量完成了会师。加蓬人民民主共和国成立了，加蓬社会主义联盟、加蓬社会主义党、全国复兴运动“原始派”、加蓬人民联盟和加蓬进步党在剔除党内右派后宣布合并为奉行马克思主义和泛非主义的加蓬劳动党，塞尔日·姆巴·贝卡莱成为了党主席和革命委员会主席，加蓬进步党副主席马克·恩圭马（60年代加蓬民族革命运动的领导人之一）被任命为总理。加蓬民族革命运动则转型为类似政协和东欧人民阵线这样的统战机构。加蓬民主党被取缔，包括邦戈在内的大量参与镇压民主运动的加蓬民主党官员被送入人民法庭公审和清算。加蓬人民民主共和国宣布开始进行国有化和土地改革，成立人民军，没收帝国主义资产，进行人民民主化，将被前傀儡政权颠倒的历史颠倒过来，为1964政变等事件平反，并为向社会主义过渡进行准备工作。\n加蓬不再是帝国主义者和卖国分子的加蓬了！"
const TXT_NAME_R4 := "加蓬人民民主共和国"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 5:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var budget := d.budget if d.size() > W.I_BUDGET else 0
	var reserve := d.reserve if d.size() > W.I_RESERVE else 0
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	var army := d.army if d.size() > W.I_ARMY else 0
	var gabon := world.get_country_by_legacy_index(116)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if budget + reserve >= 50 and agents >= 80:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line >= 3 and budget + reserve >= 50 and agents >= 80:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if line <= 2 and budget + reserve >= 100 and agents >= 100:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	if line <= 1 and budget + reserve >= 150 and agents >= 150 and army >= 150 \
			and gabon != null and gabon.有驻军基地:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], TXT_OPT4_DIS)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var gabon := _country(116)
	var france := _country(21)
	var china := _country(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0_INTRO
			if france != null and (france.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST or france.sub_government == GameConstants.SubGovernment.EUROCOMMUNIST):
				text += TXT_R0_LEFT
				if gabon != null:
					gabon.government = GameConstants.Government.REFORMIST
					gabon.sub_government = GameConstants.SubGovernment.PRAGMATIST
					gabon.puppet_of = GameConstants.LegacySlot.FRANCE
			else:
				text += TXT_R0_ELSE
				if gabon != null:
					gabon.government = GameConstants.Government.AUTHORITARIAN
					gabon.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					gabon.puppet_of = GameConstants.LegacySlot.FRANCE
			context["result_text"] = text
		1:
			context["result_text"] = TXT_R1
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -80)
			if gabon != null:
				_leave_alliances(gabon)
				gabon.set_tag("对华贸易", true)
			if _empire_power(0) > ws.influence_prc:
				if gabon != null:
					gabon.government = GameConstants.Government.AUTHORITARIAN
					gabon.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					gabon.set_tag("亲美", true)
				_add_power(EmpireData.USA, 20)
			elif ws.is_socialism(china, true) or (china != null and china.government == GameConstants.Government.REFORMIST):
				if gabon != null:
					gabon.government = GameConstants.Government.REFORMIST
					gabon.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
					gabon.set_tag("亲中", true)
				ws.influence_prc += 10
				ws.oil_prod += 100.0  # Event619.cs result1 社会主义分支：加蓬石油合作
			elif ws.is_authoritarian(china):
				if gabon != null:
					gabon.government = GameConstants.Government.AUTHORITARIAN
					gabon.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					gabon.set_tag("亲中", true)
				ws.influence_prc += 10
				ws.oil_prod += 100.0  # Event619.cs result1 威权分支
			else:
				if gabon != null:
					gabon.government = GameConstants.Government.LIBERAL
					gabon.sub_government = GameConstants.SubGovernment.MODERATE
					gabon.set_tag("亲中", true)
				ws.influence_prc += 10
				ws.oil_prod += 100.0  # Event619.cs result1 其他分支
		2:
			context["result_text"] = TXT_R2
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -80)
			if gabon != null:
				gabon.government = GameConstants.Government.LIBERAL
				gabon.sub_government = GameConstants.SubGovernment.LIBERAL
				_leave_alliances(gabon)
				gabon.set_tag("对华贸易", true)
				gabon.set_tag("亲中", true)
			ws.influence_prc += 10
			ws.oil_prod += 100.0  # Event619.cs result2
		3:
			context["result_text"] = TXT_R3
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if gabon != null:
				gabon.government = GameConstants.Government.REFORMIST
				gabon.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				_leave_alliances(gabon)
				gabon.set_tag("对华贸易", true)
				gabon.set_tag("亲中", true)
			ws.influence_prc += 20
			ws.oil_prod += 100.0  # Event619.cs result3
		4:
			context["result_text"] = TXT_R4
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			if gabon != null:
				gabon.government = GameConstants.Government.SOCIALIST
				gabon.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(gabon)
				gabon.set_tag("对华贸易", true)
				gabon.set_tag("亲中", true)
				gabon.chinese_name = TXT_NAME_R4
			ws.influence_prc += 20
			ws.oil_prod += 100.0  # Event619.cs result4






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



func _empire_power(idx: int) -> int:
	if ws.empires.size() > idx and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0

