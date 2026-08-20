extends "res://数据脚本/event_script_base.gd"

## 原作 Event508.cs：树枝不会在变色龙手里折断（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "这是在做无用功"
const TXT_OPT1_DIS := "我们不支持国际分工方案！"
const TXT_R0_A := "我们宣布将承担贝宁的一切外债，克雷库同志就此对中方表达了感谢。在群众大会上，克雷库表示“贝宁比任何时候都做好了完全按照马克思，列宁和毛泽东的理念来建设祖国”，这公开表示了其对我国的支持。在我们的帮助下，贝宁重新确定了发展方向。贝宁的独特优势是其完善的农业基础，我们愿意为其提供农用机械，化肥和农业干部。在我们的帮助下，贝宁政府终于实现了粮食自给，而我们的钻机也让贝宁过了把“石油土豪”瘾，他们将会用石油赚来的钱来购买我们的工业设备。政治改革也在有条不紊的进行中，贝宁人民革命党再次确定了自己的地位：无产阶级的先锋党，并开始建设完整的党校等机构。部分“人民村”也开始搞直接民主，选举自己的村庄管理委员会成员。达荷美共产党也被合法化了，其中的成员（尽管极少）也被吸纳入贝宁社会主义革命党作为党内的左翼代表，党内的亲法右翼也被清洗。\n不久的将来，“红旗”卷烟火柴厂，“1026革命”体育场和帕拉库水泥厂将会在我们的帮助下落成，这也将为贝宁人民建设祖国添砖加瓦。一条从康迪到科托努的铁路也在建设中。贝宁公开投入了我们的怀抱。"
const TXT_R0_B := "法国总统罗兰·勒罗伊支持了我们的方案，慷慨的免除了贝宁欠下法国的巨额债务。克雷库热情的赞扬勒罗伊总统“是全世界被压迫人民的代言人”，“第三世界和非洲解放运动的旗手”。贝宁和法国的关系显著改善了，与此同时，法国，中国和贝宁合资的“贝宁人民矿业公司”在法国的指导下开始建设。而贝宁经济或多或少稳定下来了。"
const TXT_R1_A := "凭借着我们在经互会内的良好关系，我们提议将贝宁纳入经互会体系中。凭借得天独厚的区位优势，贝宁将为经互会提供足够的矿石和棉花。经互会也将稳定的为其建设工业。很快，贝宁的经济稳定下来了。"
const TXT_R2_A := "随后，克雷库政府开始了大刀阔斧的经济改革。克雷库总统访问了法国以谋求改善和法国的关系，并号召其来贝宁建设工厂，宣布将不对法资企业做过多的限制。效果是立竿见影的：贝宁免除了外债，也爆发了大量劳工运动和抗议，人权组织一边欢迎克雷库放弃强硬的对外路线，一边谴责其暴力镇压工人运动。但只要法国还在，克雷库不会有问题的，对吧？"
const TXT_R2_B := "法国总统罗兰·勒罗伊慷慨的免除了贝宁欠下法国的巨额债务。克雷库热情的赞扬勒罗伊总统“是全世界被压迫人民的代言人”，“第三世界和非洲解放运动的旗手”。贝宁和法国的关系显著改善了，与此同时，法国，中国和贝宁合资的“贝宁人民矿业公司”在法国的指导下开始建设。而贝宁经济或多或少稳定下来了。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.political_line <= 2 and ws.influence_prc >= 600:
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
	var c62 := ws.get_country_by_legacy_index(62)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			if ws.world_political_balance == 2  and  ws.get_flag("YugAgree"):
				context["result_text"] = TXT_R0_B
			_add(8, -(80))
			ws.influence_prc += 20
			_add_relation(1, -(100))
			_add_power(1, -(20))
			if c62 != null: _leave_alliances(c62)
			if c62 != null: c62.set_tag("对华贸易", true)
			if c62 != null: c62.set_tag("亲中", true)
			if c62 != null: c62.government = GameConstants.Government.SOCIALIST
			if c62 != null: c62.sub_government = GameConstants.SubGovernment.MAOIST
			# UNHANDLED: GlobalScript.inst.gameState.allcountries[62].JoinAllOurAlliances(true)
			if ws.world_political_balance == 2  and  ws.get_flag("YugAgree"):
				_add(8, 40)
				if c62 != null: _leave_alliances(c62)
				if c62 != null: c62.set_tag("对华贸易", true)
				if c62 != null: c62.government = GameConstants.Government.REFORMIST
				if c62 != null: c62.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(10))
			if c62 != null: c62.government = GameConstants.Government.SOCIALIST
			if c62 != null: c62.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			if c62 != null: c62.set_tag("对华贸易", true)
			_add_relation(1, 100)
			_add_power(1, 20)
			if c62 != null: c62.set_tag("sev", true)
		2:
			if ws.world_political_balance != 2 or not ws.get_flag("YugAgree"):
				context["result_text"] = TXT_R2_A
			else:
				context["result_text"] = TXT_R2_B
			if ws.world_political_balance != 2 or not ws.get_flag("YugAgree"):
				if c62 != null: c62.government = GameConstants.Government.REFORMIST
				if c62 != null: c62.sub_government = GameConstants.SubGovernment.PRAGMATIST
				if c62 != null: _leave_alliances(c62)
				if c62 != null: c62.puppet_of = GameConstants.LegacySlot.FRANCE
				return
			if c62 != null: c62.government = GameConstants.Government.REFORMIST
			if c62 != null: c62.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			if c62 != null: _leave_alliances(c62)
			if c62 != null: c62.set_tag("亲苏", true)

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
