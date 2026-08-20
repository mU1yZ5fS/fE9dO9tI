extends "res://数据脚本/event_script_base.gd"

## 原作 Event509.cs：黄金海岸的再革命？——第一幕（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "我们不会帮助修正主义者！"
const TXT_OPT1_DIS := "为什么要这么做？"
const TXT_OPT2_DIS := "我们无从下手"
const TXT_R0_A := "为了帮助加纳解决经济问题，我们决定向加纳提供一笔无息贷款，并派出顾问团为利曼总统提供帮助。而他也抓住了中国这个救命稻草，决定背靠中国来巩固以他为首的文官政府的统治。作为交换，他也为我们在加纳开采黄金和勘探石油提供了最大的帮助，我们的投资的涌入为加纳经济注入了活力，利曼也决定继续进行一定的国有化和福利建设。在我们的帮助下，加纳第三共和国正在稳定下来，并成功安抚了不满的年轻军官。虽然利曼博士比起恩克鲁玛而言，更像是个打着他旗号的非洲民主社会主义者，不过对于我们而言，能抓到老鼠的就是好猫，不是吗？"
const TXT_R1_A := "加纳再度左转将可能加强苏东阵营的力量投射，我们应该阻止这种事情的发生！我们秘密通知了美国。不久，来自邻国科特迪瓦和多哥的雇佣军便在中情局的帮助下攻破了阿克拉，加纳政府猝不及防，没有组织起像样的抵抗。左翼政府被推翻，新的军政府成立了。"
const TXT_R1_B := "加纳的情报机构发现了来自科特迪瓦和多哥方向的异动。他们宣布全国进入战时状态，并在边界和首都加强了防御，同时向苏联请求援助。最后，加纳政府粉碎了政变阴谋，宣布与美国和我们断绝关系并倒向苏联。"
const TXT_R2_A := "斯托克利·卡迈克尔，另一个名字是夸梅·杜尔，是一位泛非主义者和共产主义者，曾领导美国的黑人解放运动，并参与了黑豹党。1969年，他来到了几内亚，成为了塞古·杜尔的助手和恩克鲁玛的学生。他加入了几内亚民主党，并致力于“将恩克鲁玛带回加纳”。卡迈克尔与恩克鲁玛一起创建了全非人民革命党，该组织是恩克鲁玛晚年思想的实践组织。\n我们为罗林斯和全非人民革命党提供了活动资金，杜尔总统、卡迈克尔和我们的外交人员与罗林斯进行了一番深入交流，他决定与卡迈克尔联合起来，实现不同于利曼的真正的恩克鲁玛主义。之后，罗林斯和他的同志们便在几内亚秘密进行军事训练，并谋划着下一场革命，以终结Kalabule。"
const TXT_R3_A := "我们什么都没做。在被开除军职后，罗林斯就秘密前往利比亚接受军事训练。利曼的文官政府和Kalabule一样，仍继续存在着。只是在民间，不满的民众和下野的年轻军官又会在这片土地擦出什么火花呢？"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if ws.political_line != 0 and ws.political_line != 4:
		_enable(opt[0], event_def.options[0].text)
	elif ws.political_line == 4:
		_disable(opt[0], "我们不会帮助左派")
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.political_line > 1 and _cf(51, "dev") == 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if ws.political_line <= 1 and ws.completed_event_ids.has("event_505") and int(ws.completed_event_ids.get("event_505", 0)) == 0:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c63 := ws.get_country_by_legacy_index(63)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(50))
			ws.influence_prc += 20
			_add_relation(0, -(50))
			if c63 != null: c63.government = GameConstants.Government.REFORMIST
			if c63 != null: c63.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			if c63 != null: _leave_alliances(c63)
			if c63 != null: c63.set_tag("亲中", true)
			if c63 != null: c63.set_tag("对华贸易", true)
		1:
			if ws.empires[0].relations >= 500:
				context["result_text"] = TXT_R1_A
			else:
				context["result_text"] = TXT_R1_B
			_add(9, -(50))
			if ws.empires[0].relations >= 500:
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.government = GameConstants.Government.AUTHORITARIAN
				if c63 != null: c63.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				if c63 != null: c63.set_tag("亲美", true)
				if c63 != null: c63.set_tag("对华贸易", true)
			else:
				if c63 != null: c63.government = GameConstants.Government.REFORMIST
				if c63 != null: c63.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.set_tag("亲苏", true)
				if c63 != null: c63.set_tag("对华贸易", false)
		2:
			context["result_text"] = TXT_R2_A
			_add(8, -(60))
			_add(9, -(60))
			_add(22, -(60))
			if c63 != null: c63.government = GameConstants.Government.REFORMIST
			if c63 != null: c63.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			if c63 != null: _leave_alliances(c63)
			if c63 != null: c63.内战中 = true
		3:
			context["result_text"] = TXT_R3_A
			if c63 != null: c63.government = GameConstants.Government.REFORMIST
			if c63 != null: c63.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			if c63 != null: _leave_alliances(c63)

func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _office_name(pos: int) -> String:
	if ws != null and ws.politics_positions.size() > pos:
		var pi: int = ws.politics_positions[pos]
		if pi >= 0 and pi < ws.politicians.size():
			var p: PoliticianData = ws.politicians[pi]
			if p != null and p.name_display != "":
				return p.name_display
	return "华国锋"


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() 		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data.party_system == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data.ideology <= 2 and data.econ_system < 13 				and data.diplomatic_reputation >= 700 and data.party_system < 8 				and _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
			result = 0
		elif (data.econ_system >= 13 and data.war_support >= 700 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK)) 				or _mod_active(GameConstants.Modifier.PRESIDENT_FOR_LIFE):
			result = 9
		elif data.econ_system <= 13 and data.war_support >= 700 				and data.diplomatic_reputation >= 700 and (_mod_active(GameConstants.Modifier.MAOIST_BULWARK) or _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION)):
			result = 10
		elif data.econ_system >= 13 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(GameConstants.Modifier.FOURTH_INTERNATIONAL):
			result = 18
		elif _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and data.party_system <= 7 				and data.econ_system <= 12 and data.religion_policy <= 25:
			result = 17
		elif data.ideology == 1 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and data.religion_policy <= 26:
			result = 16
		elif data.econ_system < 13 and data.press_policy >= 17 				and data.ideology == 1 and data.religion_policy <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(GameConstants.Modifier.RETURN_TO_AGRARIAN_CIVILIZATION):
			result = 8
		elif data.ideology >= 2 and data.econ_system >= 13 				and data.diplomatic_reputation <= 700 and data.party_system >= 8 				and data.press_policy >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data.ideology <= 3 and data.econ_system >= 12 				and data.econ_system <= 13 and data.diplomatic_reputation >= 300 				and data.territory_policy > 21 and data.war_support >= 700:
			result = 11
		elif data.ideology <= 3 and data.econ_system <= 14 				and data.diplomatic_reputation >= 500 and data.econ_system > 11 				and data.war_support >= 400:
			result = 8
		elif data.ideology <= 3 and data.econ_system <= 13 				and data.press_policy > 17:
			result = 3
		elif data.party_system <= 8 				and (data.econ_system == 13 or data.econ_system == 12) 				and data.war_support < 700 and not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) 				and data.press_policy >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data.econ_system <= 13 and data.diplomatic_reputation >= 500:
		result = 4
	elif (data.party_system <= 8 and data.press_policy <= 18) 			or data.war_support >= 700:
		result = 12
	elif data.econ_system > 13 and data.diplomatic_reputation < 700:
		result = 6
	else:
		result = 5
	return result


func _tech(idx: int) -> bool:
	return ws != null and ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _mod(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx].is_active


func _empire_rel(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].relations
	return 0


func _empire_power(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func _cf(idx: int, field: String) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return 0
	match field:
		"Gosstroy": return c.government
		"SubGosstroy": return c.sub_government
		"dev": return c.development
		"spec": return c.special
		"soc_stab": return c.social_stability
		"stab": return c.stab
		"puppetOf": return c.puppet_of
		"prcpower": return c.prc_power
		"prcinfl": return c.prc_influence
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)
