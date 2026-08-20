extends "res://数据脚本/event_script_base.gd"

## 原作 Event507.cs：“虾”行动（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "他们不愿意听我们的"
const TXT_OPT1_DIS := "我们再讨厌苏联人，也不能做这种事"
const TXT_R0_A := "我们打了一通电话，提示了克雷库同志警惕可能的反革命政变。克雷库感谢了我们的警告，并加强了对科托努的警戒。\n1月16日凌晨，法国雇佣兵从加蓬乘坐飞机出发前往科托努。飞机刚刚接近机场，两架米格21飞机立刻起飞警戒。在屡次警告无果之后，防空部队用高射炮予以驱赶，瞬间运输机冒起了浓烟。在摇晃了几下后，飞机直直的坠入了地里。瞬间机场浓烟滚滚，赶来的消防队员只找到了几具穿着法式军服的尸体，并没有找到鲍勃·德纳尔（事后被证实是他睡过头了忘记登机）。克雷库在电视演讲中公开谴责了法国对贝宁内政的无耻干涉，并且感谢了中国的提示。克雷库公开转向社会主义阵营，彻底和法国一刀两断，并着手发行自己的货币。"
const TXT_R1_A := "1月16日凌晨，法国雇佣兵从加蓬坐运输机前往科托努。凌晨的科托努机场静悄悄。很快，头戴红色贝雷帽的雇佣兵从飞机上下来。坐上吉普车，一路风驰电掣的冲往总统府。在路上刚好遇到了准备上班的克雷库总统和总统卫队。双方发生了激烈交火，而克雷库在战斗中被一枚流弹打中了喉咙，最终死于失血过多。\n随后，达荷美救国委员会宣布接管权力，并开始重新修正前政府的国有化政策。"
const TXT_R2_A := "1月16日凌晨，法国雇佣兵从加蓬坐运输机前往科托努。凌晨的科托努机场静悄悄。很快，头戴红色贝雷帽的雇佣兵从飞机上下来。坐上吉普车，一路风驰电掣的冲往总统府。但就在同时，另一伙人也坐着运输机下来了，这是一伙亚洲人。亚洲人在说了几句听不懂的话后，立刻拿起武器和雇佣兵对抗。事后方知这是应邀来参观的朝鲜人民军军事代表团。雇佣兵抛下一地的尸体灰溜溜的逃跑了。\n赶来的消防队员只找到了几具穿着法式军服的尸体，并没有找到鲍勃·德纳尔（事后被证实是他睡过头了忘记登机）。克雷库在电视演讲中公开谴责了法国对贝宁内政的无耻干涉，并宣布将扩大与社会主义国家的合作。大量的法裔因为这件事而遭到了迫害。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.数值表[56] <= 2 and ws.influence_prc >= 10:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _tag(21, "对华贸易") and _cf(21, "Gosstroy") != 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c62 := ws.get_country_by_legacy_index(62)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(20))
			_add(22, -(100))
			ws.influence_prc += 50
			_add_relation(0, -(100))
			_add_power(0, -(50))
			if c62 != null: c62.set_tag("对华贸易", true)
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(10))
			if c62 != null: c62.government = 0
			if c62 != null: c62.sub_government = 7
			if c62 != null: _leave_alliances(c62)
			if c62 != null: c62.puppet_of = 21
			if c62 != null: c62.set_tag("对华贸易", true)
			if c62 != null: c62.name = "达荷美"
			_add_relation(0, 80)
			_add_power(0, 50)
		2:
			context["result_text"] = TXT_R2_A
			if c62 != null: c62.government = 0
			if c62 != null: c62.sub_government = 10

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
	if china.government == 0:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data[W.I_PARTY_SYSTEM] == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data[W.I_IDEOLOGY] <= 2 and data[W.I_ECON_SYSTEM] < 13 				and data[W.I_DIPLO] >= 700 and data[W.I_PARTY_SYSTEM] < 8 				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data[W.I_ECON_SYSTEM] >= 13 and data[W.I_WAR_SUPPORT] >= 700 and not _mod_active(6)) 				or _mod_active(38):
			result = 9
		elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_WAR_SUPPORT] >= 700 				and data[W.I_DIPLO] >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data[W.I_ECON_SYSTEM] >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == 1:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data[W.I_PARTY_SYSTEM] <= 7 				and data[W.I_ECON_SYSTEM] <= 12 and data[W.I_RELIGION] <= 25:
			result = 17
		elif data[W.I_IDEOLOGY] == 1 and not _mod_active(6) and data[W.I_RELIGION] <= 26:
			result = 16
		elif data[W.I_ECON_SYSTEM] < 13 and data[W.I_PRESS_POLICY] >= 17 				and data[W.I_IDEOLOGY] == 1 and data[W.I_RELIGION] <= 26:
			result = 2
		else:
			result = 1
	elif china.government == 2:
		if _mod_active(40):
			result = 8
		elif data[W.I_IDEOLOGY] >= 2 and data[W.I_ECON_SYSTEM] >= 13 				and data[W.I_DIPLO] <= 700 and data[W.I_PARTY_SYSTEM] >= 8 				and data[W.I_PRESS_POLICY] >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] >= 12 				and data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 300 				and data[W.I_TERRITORY] > 21 and data[W.I_WAR_SUPPORT] >= 700:
			result = 11
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 14 				and data[W.I_DIPLO] >= 500 and data[W.I_ECON_SYSTEM] > 11 				and data[W.I_WAR_SUPPORT] >= 400:
			result = 8
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 13 				and data[W.I_PRESS_POLICY] > 17:
			result = 3
		elif data[W.I_PARTY_SYSTEM] <= 8 				and (data[W.I_ECON_SYSTEM] == 13 or data[W.I_ECON_SYSTEM] == 12) 				and data[W.I_WAR_SUPPORT] < 700 and not _mod_active(3) 				and data[W.I_PRESS_POLICY] >= 17:
			result = 21
		else:
			result = 15
	elif china.government != 3:
		result = 13
	elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 500:
		result = 4
	elif (data[W.I_PARTY_SYSTEM] <= 8 and data[W.I_PRESS_POLICY] <= 18) 			or data[W.I_WAR_SUPPORT] >= 700:
		result = 12
	elif data[W.I_ECON_SYSTEM] > 13 and data[W.I_DIPLO] < 700:
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
