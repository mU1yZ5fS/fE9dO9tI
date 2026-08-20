extends "res://数据脚本/event_script_base.gd"

## 原作 Event511.cs：黄金海岸的再革命？——第三幕（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "我们不会帮他"
const TXT_OPT1_DIS := "我们不能为社会帝国主义者做事！"
const TXT_R0_A := "我们为加纳提供了大批援助，作为交换，他将为我们提供廉价可可，并为我们在加纳开采黄金和勘探石油提供最大的帮助，我们的投资的涌入也为加纳经济注入了活力。另一方面，罗林斯表示他也将继续参与非洲进步政权之间的友好合作，并继续开展“加纳的人民民主革命”，他参照我们的经验，组织了加纳人民革命党，并继续实施保卫革命委员会下的直接民主。"
const TXT_R1_A := "得益于我们在经互会内的地位，我们提议将加纳纳入社会主义的真正进步的经济体系，加纳将为社会主义阵营提供可可、石油和黄金等特产，社会主义阵营将为加纳提供工业化和农业现代化的设备和相关干部的援助。很快，加纳的经济稳定下来了。罗林斯宣布加纳“进入了人民民主革命的阶段”，他正在组织加纳人民革命党，加纳将被改造为一个真正的社会主义国家。"
const TXT_R2_A := "最开始，加纳向莫斯科和利比亚寻求援助，但是苏联阵营陷入衰弱无力支援，卡扎菲则表示没有资金，但可以提供低价石油。由于无法从东欧阵营得到援助，加纳从国际货币基金组织、世界银行和西欧国家获得了大量贷款。在他们的敦促下，罗林斯放弃了部分左翼政策，经济开始放松管制，进行部分自由化的改革，以寻求更多的投资。1983年4月政府颁布了《经济复苏计划》，决定实施价格自由化，减少国家在经济管理中的作用，政府采取了货币贬值，并将部分国企可私有化，如可可、黄金和木材产业。加纳经济正在向好，其领导层的左翼谴责罗林斯“背叛了革命”。"
const TXT_R2_B := "加纳向莫斯科和利比亚寻求援助，莫斯科方面为其提供了一系列资金，利比亚为加纳的工业化提供了石油，苏东国家在加纳开设了合资国营企业，并为其提供了钻机以开发石油产业。加纳方面为将为苏联提供可可和木材，并允许其开采黄金。在苏联方面的敦促下，罗林斯成立了加纳人民革命党筹建委员会，并开始尝试加大合作化和国有化，准备将国家向马列主义模式的社会主义国家改造，以融入苏联阵营。加纳经济正在向好，其领导层的左翼对加纳革命有了新进展十分满意。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.political_line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _tag(1, "sev"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c63 := ws.get_country_by_legacy_index(63)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			if c63 != null: _leave_alliances(c63)
			if c63 != null: c63.government = GameConstants.Government.SOCIALIST
			if c63 != null: c63.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			if c63 != null: c63.set_tag("对华贸易", true)
			if c63 != null: c63.set_tag("亲中", true)
			ws.influence_prc += 10
			# UNHANDLED: GlobalScript.inst.gameState.allcountries[63].JoinAllOurAlliances(true)
			_add_relation(0, -(100))
			_add(8, -(70))
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(30))
			if c63 != null: _leave_alliances(c63)
			if c63 != null: c63.government = GameConstants.Government.SOCIALIST
			if c63 != null: c63.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			if c63 != null: c63.set_tag("sev", true)
			if c63 != null: c63.set_tag("亲苏", true)
			if c63 != null: c63.set_tag("对华贸易", true)
			_add_relation(0, -(100))
			_add_relation(1, 100)
		2:
			if ws.empires[0].power > ws.empires[1].power:
				context["result_text"] = TXT_R2_A
			context["result_text"] = TXT_R2_B
			if ws.empires[0].power > ws.empires[1].power:
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.government = GameConstants.Government.REFORMIST
				if c63 != null: c63.sub_government = GameConstants.SubGovernment.PRAGMATIST
				return
			if c63 != null: c63.government = GameConstants.Government.AUTHORITARIAN
			if c63 != null: c63.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			if c63 != null: _leave_alliances(c63)
			if c63 != null: c63.set_tag("亲苏", true)

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
