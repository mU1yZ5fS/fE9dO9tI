extends "res://数据脚本/event_script_base.gd"

## 原作 Event506.cs：从1922到1984（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "我们没有能力做这样的事"
const TXT_OPT1_DIS := "我们做不到背叛盟友！"
const TXT_R0_A := "我们联络了内政部长阿卜杜拉耶·杜尔（杜尔的胞弟）和贝阿沃吉总统。表示了愿意为他们提供军事支持以促成反政变。二人欣然接受。很快，一批脸上涂着棕色迷彩的中国人民解放军士兵出现在了康康的街头，并与政变军发生了交火。几内亚人民军的六三式坦克攻入了反抗军据点，工人民兵也走上街头反抗军事管理。在我们的帮助下，几内亚人民军彻底打败了政变军官，他们要么逃入塞内加尔寻求政治避难，要么束手就擒期待政府的宽大处理。孔戴上校被当众处死，而群众为这一行为拍手叫好。经此一役，工人卫队的地位大大的提高了。几内亚人民反抗帝国主义干涉的伟业将会写入几内亚的历史书中，而杜尔的遗产也保住了。几内亚民主党宣布改为几内亚劳动党，党纲里不再宣称简单的“泛非主义”和科学社会主义，而是要在走马克思，列宁，毛泽东指出的路线的同时，继续致力于非洲国家的统一与解放。\n新政府宣布将扩大和我们的合作。尤其是在构建完善的工人阶级来对抗国家内部潜在的阶级敌人，防止资产阶级复辟。"
const TXT_R1_A := "我们公开承认了孔戴上校的军政府，这招来了全非洲进步国家，甚至是扎伊尔的谴责。\n很快，政变军队攻占了全国，兰萨纳·孔戴上校组建了国家军事复兴委员会。并开始着手进行“去杜尔化”。大量谴责杜尔的或真或假的黑材料被大量公布，他的坟墓也从革命烈士陵园内迁出。"
const TXT_R2_A := "很快，政变军队攻占了全国，兰萨纳·孔戴上校组建了国家军事复兴委员会。并开始着手进行“去杜尔化”。大量谴责杜尔的或真或假的黑材料被大量公布，他的坟墓也从革命烈士陵园内迁出。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.political_line <= 2 and _tech(24) and _tag(68, "对华贸易"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.political_line > 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c68 := ws.get_country_by_legacy_index(68)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(20))
			_add(22, -(100))
			ws.influence_prc += 50
			_add_relation(0, -(100))
			_add_power(0, -(50))
			if c68 != null: c68.government = GameConstants.Government.SOCIALIST
			if c68 != null: c68.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			if c68 != null: _leave_alliances(c68)
			if c68 != null: c68.set_tag("对华贸易", true)
			if c68 != null: c68.set_tag("亲中", true)
			if ws.completed_event_ids.has("event_500")  and  int(ws.completed_event_ids.get("event_500", 0)) == 0:
				if c68 != null: c68.set_tag("econ", true)
				if c68 != null: c68.set_tag("au", true)
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(10))
			if c68 != null: c68.government = GameConstants.Government.AUTHORITARIAN
			if c68 != null: c68.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			if c68 != null: _leave_alliances(c68)
			if c68 != null: c68.puppet_of = GameConstants.LegacySlot.FRANCE
			if c68 != null: c68.set_tag("对华贸易", true)
			_add_relation(0, 80)
			_add_power(0, 50)
		2:
			context["result_text"] = TXT_R2_A
			if c68 != null: c68.government = GameConstants.Government.AUTHORITARIAN
			if c68 != null: c68.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			if c68 != null: _leave_alliances(c68)
			if c68 != null: c68.puppet_of = GameConstants.LegacySlot.FRANCE

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
