extends "res://数据脚本/event_script_base.gd"

## 原作 Event605.cs：后翼弃车？（阿扎尼亚温妮·曼德拉，三选项）。
## 触发：ReqEventForDLC02.cs:879-881 —— c131.SubGosstroy==10 && DATE_AFTER 1985.12.1。
## 差异：Torg→对华贸易、proprc→亲中；结果2 文本按原版逐字。

const TXT_OPT2_DIS := "我们不会将阿扎尼亚变成第二个罗马尼亚"
const TXT_R0 := "也就在温妮·曼德拉上位次日，我们便立即承认了新阿扎尼亚政府的合法性并送去贺电。中国的率先表态显然让曼德拉夫人看清了谁才是她最值得依靠的“盟友”——不久后，我们便得以同阿扎尼亚建立特殊关系。与此同时，苏东阵营与大多数非洲国家也顺水推舟承认新政府。根据温妮·曼德拉的计划，阿扎尼亚革命政府将在改组为一党制国家“阿扎尼亚民主主义人民共和国”，在以类似《伊拉克1970年宪法》形式确立非国大作为该国唯一执政党地位的同时，要求6岁以上的全体公民均有加入该“反帝黑人社会主义先锋党”的义务。阿扎尼亚泛非主义大会等组织则因缺乏武装力量与失败的种族和解政策而被曼德拉政府连根拔起。此后，莱索托也在阿扎尼亚支持下选择了类似立场。下一步便是在电视上公审作为失败者的“非洲叛徒”。"
const TXT_R1 := "也就在温妮·曼德拉上位次日，我们便立即谴责了其发动政变的行为，认为这只会让加剧阿扎尼亚局势混乱并激化民族矛盾。中国的率先表态显然让曼德拉夫人看清了谁是她该留意的敌人——我们也只能收获一顶“中华定居派沙文主义”的帽子并同阿扎尼亚断交。根据温妮·曼德拉的计划，阿扎尼亚革命政府将在改组为一党制国家“阿扎尼亚民主主义人民共和国”，在以类似《伊拉克1970年宪法》形式确立非国大作为该国唯一执政党地位的同时，要求6岁以上的全体公民均有加入该“反帝黑人社会主义先锋党”的义务。阿扎尼亚泛非主义大会等组织则因缺乏武装力量与失败的种族和解政策而被曼德拉政府连根拔起。此后，莱索托也在阿扎尼亚支持下选择了类似立场。下一步便是在电视上公审作为失败者的“非洲叛徒”。"
const TXT_R2 := "也就在温妮·曼德拉上位次日，我们便立即承认了新阿扎尼亚政府的合法性并送去贺电。中国的率先表态显然让曼德拉夫人看清了谁才是她最值得依靠的“盟友”——不久后，我们便得借同阿扎尼亚建立特殊关系为由邀请阿扎尼亚民主主义人民共和国主席温妮·曼德拉同志造访我国，展开为期一周的国事访问与理论学习活动。期间，温妮主席对我国守正初心，牢记使命的“革命江山代代传”理论颇感兴趣，并高度赞扬了我国推动国内各族现代化与革命化，建构举国一体体制的实践。访问结束后，有人问温妮·曼德拉同志对我国有什么感想，曼德拉夫人说：“我看中国搞得不错，革命意志极其坚定，反动民族基本消灭，社会公正，社会福利也受重视，如果加上非国大执政，中国就是我们理想中的社会主义社会”。阿扎尼亚的改革就此步入了全新阶段：已故的纳尔逊·曼德拉被阿扎尼亚人民议会封为“永远的总统和大元帅、全体阿扎尼亚人民的舵手和导师”，其遗体将在不久后安置在由中国工程师参与修建，位于桌山之巅的“彩虹宫”中。温妮·曼德拉自己则被议会一致任命为阿扎尼亚总司令，与曼德拉家族其他成员一道组成统摄军政大权的“阿扎尼亚国防会议”。有关曼德拉夫妇个人崇拜的民谣与民俗故事已在民间流传，并与类似“蒙博托·塞塞·塞科·库库·恩本杜·瓦·扎·邦加”此类尊号的阿扎尼亚化版本相伴而行。随着“前所未有的最天真、最自然、最有感情也最纯粹的革命者”的大女儿泽纳尼已被任命为教育部部长，并被授予上校军衔。第二扎伊尔与曼德拉家族的统治就这样开始了。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	if china != null and china.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var south_africa := _country(131)
	var lesotho := _country(132)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if south_africa != null:
				south_africa.set_tag("亲中", true)
				south_africa.set_tag("对华贸易", true)
			if lesotho != null:
				lesotho.set_tag("对华贸易", true)
			_add(W.I_DIPLO, 30)
			_add_relation(EmpireData.USA, -50)
		1:
			context["result_text"] = TXT_R1
			if south_africa != null:
				south_africa.set_tag("对华贸易", false)
			if lesotho != null:
				lesotho.set_tag("对华贸易", false)
			_add(W.I_DIPLO, -20)
			_add_relation(EmpireData.USA, 50)
		2:
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -100)
			context["result_text"] = TXT_R2
			if south_africa != null:
				south_africa.government = GameConstants.Government.AUTHORITARIAN
				south_africa.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				south_africa.set_tag("亲中", true)
				south_africa.set_tag("对华贸易", true)






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


