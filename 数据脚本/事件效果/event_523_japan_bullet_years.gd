extends "res://数据脚本/event_script_base.gd"

## 原作 Event523.cs：日本的铅弹岁月（2选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "我们不可能支持极左恐怖分子！"
const TXT_R0_A := "多亏了出色的特勤帮助，我们成功与中核派、革马派与其他激进组织的残留成员建立联系。尽管彼此之间的意识形态存在巨大差异，但是谁又能拒绝长期且稳定的资金、武器和工具援助呢？\n在一次集体会议后，各个团体均同意暂时联合起来组成日本共产主义抵抗者同盟。为了彰显它的实力，该团体向自由民主党总部、美军基地均实施了炸弹袭击，这在社会上引起了不同的反应。同时在我们的帮助下，一批新的学生活动家开始深入日工劳动者等工人阶级现场发展组织，开展工会活动。整体而言，该团体开始从单纯的激进暴力全面转型成为一个“工人党”，并开始建立完整的组织体系。尽管内部依旧有着诸多矛盾，但至少最初的架构已经显现。至于未来如何，就不得而知了。"
const TXT_R1_A := "支持这些团体不仅需要长期的援助，而且要冒着事情暴露之后被大批国家指责为“恐怖主义支持者”的风险，风险实在是太大了。况且为什么要这些没有系统理论基础、没有基层组织甚至没有统一指导的小团体给予帮助？与其从零开始手把手教育这些冒失的青年，还不如优先向那些势力更强，组织架构更完善的左翼组织伸出援手！\n最终，在缺乏外部支援以及日本警方的围堵下，日本国内的左翼激进团体陆续沉寂下去。一些势力相对较大的团体则开始顺应国际潮流的转向，转型成为关注环保问题、妇女权益、核风险等问题的新左翼团体。但无论如何，属于这些人的铅弹岁月，已经远去了……"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	if ws.political_line <= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var _c44 := ws.get_country_by_legacy_index(44)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			# UNHANDLED: this.a.allcountries[44].prcpower = 10
			_add(9, -(50))
			_add(8, -(50))
			_add(1, 50)
			_add(3, 50)
			_add(6, 5)
		1:
			context["result_text"] = TXT_R1_A

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
		elif data.ideology <= 2 and data.econ_system < 13 				and data.diplomatic_reputation >= 700 and data.party_system < 8 				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data.econ_system >= 13 and data.war_support >= 700 and not _mod_active(6)) 				or _mod_active(38):
			result = 9
		elif data.econ_system <= 13 and data.war_support >= 700 				and data.diplomatic_reputation >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data.econ_system >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data.party_system <= 7 				and data.econ_system <= 12 and data.religion_policy <= 25:
			result = 17
		elif data.ideology == 1 and not _mod_active(6) and data.religion_policy <= 26:
			result = 16
		elif data.econ_system < 13 and data.press_policy >= 17 				and data.ideology == 1 and data.religion_policy <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(40):
			result = 8
		elif data.ideology >= 2 and data.econ_system >= 13 				and data.diplomatic_reputation <= 700 and data.party_system >= 8 				and data.press_policy >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data.ideology <= 3 and data.econ_system >= 12 				and data.econ_system <= 13 and data.diplomatic_reputation >= 300 				and data.territory_policy > 21 and data.war_support >= 700:
			result = 11
		elif data.ideology <= 3 and data.econ_system <= 14 				and data.diplomatic_reputation >= 500 and data.econ_system > 11 				and data.war_support >= 400:
			result = 8
		elif data.ideology <= 3 and data.econ_system <= 13 				and data.press_policy > 17:
			result = 3
		elif data.party_system <= 8 				and (data.econ_system == 13 or data.econ_system == 12) 				and data.war_support < 700 and not _mod_active(3) 				and data.press_policy >= 17:
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
