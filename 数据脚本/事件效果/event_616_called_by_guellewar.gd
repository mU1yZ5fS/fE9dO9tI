extends "res://数据脚本/event_script_base.gd"

## 原作 Event616.cs：在盖勒瓦尔的召唤下（塞内加尔革命，单选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:4533-4535（this_type 外交按钮）手动 number_event=616。
## 差异：IsSocialism(true,id) 计数用 ws.is_socialism(c,true)；proprc→亲中、Torg→对华贸易。

const TXT_TITLE := "在盖勒瓦尔的召唤下"
const TXT_DESC := "自在冈比亚战争中败于几内亚-几内亚比绍联军之后，塞内加尔就处于极其混乱的状态。惨烈的战争不仅打破了塞内加尔社会党的声望，也撕碎了该国的最后一点遮羞布。罢工、学生运动、游行示威层出不穷。为此，迪乌夫总统被迫一方面镇压罢工与游行，一方面加快了政治自由化改革，但仍然于事无补。在民主反对派于达喀尔举行的一次群众集会中，几百名群众涌上街头，举行示威游行，抗议政府提高物价。政府立即出动军警进行干预，阻止群众上街游行。愤怒的示威群众手持棍棒、锄头甚至匕首与警察搏斗，几名警察与部分示威群众当场死亡，数十人受伤。当晚政府便谴责反对党煽动暴力，逮捕了所有涉嫌参与和操纵这次事件的人，这迅速激化了矛盾。很快，一场大罢工便从达喀尔席卷全国。在武力镇压无果后，迪乌夫被迫辞职，宣布将重新举行选举。然而，该国的混乱局面导致选举无法正常进行。依靠几内亚、几内亚比绍与冈比亚所提供的军事训练与援助，塞共/马列已经秘密组织起了一支武装部队。现在，是时候一鼓作气终结塞内加尔的“民主社会主义”实验了。"
const TXT_OPT0 := "站起身来去革命！"
const TXT_R0 := "在几内亚、几内亚比绍、冈比亚等国的支持下，塞内加尔共产党/马列将自己所掌握的武装力量与受革命思想影响的军人改编为由该党中央统一指挥的塞内加尔民族解放军，西非的社会主义国家将为他们提供他们所需要的一切支持。\n随着塞内加尔的局势日益恶化，陆军总参谋长约瑟夫·路易斯·塔瓦雷斯·德苏萨将军发动了一场政变，轻而易举地占领了达喀尔的政府大楼，在广播中宣布成立革命军事委员会，无限期暂停议会选举与宪法，接管政府。而这遭到了全国上下的激烈反对，很快，该国的混乱局势便演化为一场内战。而几内亚、几内亚比绍与冈比亚的志愿军则直接介入了内战，倚仗于他们的支持，塞共/马列得以四两拨千斤，彻底击溃了政府军，最终接管了全国。一个彻底脱离殖民主义阴魂的新塞内加尔诞生了。"
const TXT_R0_FAIL := "在几内亚、几内亚比绍、冈比亚等国的支持下，塞内加尔共产党/马列将自己所掌握的武装力量与的军人改编为由该党中央统一指挥的塞内加尔民族解放军，而西非的社会主义国家将为他们提供他们所需要的一切支持。\n随着塞内加尔的局势日益恶化，陆军总参谋长约瑟夫·路易斯·塔瓦雷斯·德苏萨将军发动了一场政变，轻而易举地占领了达喀尔的政府大楼，在广播中宣布成立革命军事委员会，无限期暂停议会选举与宪法，接管政府。而这遭到了全国上下的激烈反对，很快，该国的混乱局势便演化为一场内战。而几内亚、几内亚比绍与冈比亚的志愿军则直接介入了内战。最终，尽管在面对卡萨芒斯的分离主义叛军遭遇一系列惨败，军政府还是成功击退了所有外国干涉军。\n在大天使的剑影下，塞内加尔河、冈比亚河、卡萨芒斯河全被染红了……"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var senegal := _country(112)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var num := 0
			for idx in [59, 113, 58, 68, 114, 107, 64, 63, 108, 61]:
				var c := _country(idx)
				if c != null and ws.is_socialism(c, true):
					num += 1
			if num >= 5 and _socialism(68) and _socialism(114) and _socialism(113):
				context["result_text"] = TXT_R0
				if senegal != null:
					senegal.government = 1
					senegal.sub_government = 17
					_leave_alliances(senegal)
					senegal.set_tag("对华贸易", true)
					senegal.set_tag("亲中", true)
				_add_relation(EmpireData.USSR, -150)
				_add_relation(EmpireData.USA, -150)
			else:
				context["result_text"] = TXT_R0_FAIL
				if senegal != null:
					senegal.government = 0
					senegal.sub_government = 7



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

