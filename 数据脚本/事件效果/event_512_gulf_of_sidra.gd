extends "res://数据脚本/event_script_base.gd"

## 原作 Event512.cs：锡德拉湾事件（4选项）。 ## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/ 换行/剥 color）。 ## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_DESC_A := "event.script.event_512_gulf_of_sidra.c0"
const TXT_DESC_B := "event.script.event_512_gulf_of_sidra.c1"
const TXT_R0_0 := "event.script.event_512_gulf_of_sidra.c2"
const TXT_R0_1 := "event.script.event_512_gulf_of_sidra.c3"
const TXT_R0_2 := "event.script.event_512_gulf_of_sidra.c4"
const TXT_R1_0 := "event.script.event_512_gulf_of_sidra.c5"
const TXT_R1_1 := "event.script.event_512_gulf_of_sidra.c6"
const TXT_R1_2 := "event.script.event_512_gulf_of_sidra.c7"
const TXT_R2_0 := "event.script.event_512_gulf_of_sidra.c8"
const TXT_R2_1 := "event.script.event_512_gulf_of_sidra.c9"
const TXT_R2_2 := "event.script.event_512_gulf_of_sidra.c10"
const TXT_R2_3 := "event.script.event_512_gulf_of_sidra.c11"
const TXT_R3_0 := "event.script.event_512_gulf_of_sidra.c12"
const TXT_R3_1 := "event.script.event_512_gulf_of_sidra.c13"
const TXT_R3_2 := "event.script.event_512_gulf_of_sidra.c14"
const TXT_OPT0_DIS := "event.script.event_512_gulf_of_sidra.c15"
const TXT_OPT1_DIS := "event.script.event_512_gulf_of_sidra.c16"
const TXT_OPT2_DIS := "event.script.event_512_gulf_of_sidra.c17"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	event_def.description = tr(TXT_DESC_A) + _leader_name() + tr(TXT_DESC_B)
	if ws.political_line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if ws.political_line > 2 and _tag(51, "对华贸易"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if (_tag(1, "okb") or _tag(1, "seato")) and ws.influence_prc >= 600 and _cf(13, "cw") == 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c13 := ws.get_country_by_legacy_index(13)
	var _c41 := ws.get_country_by_legacy_index(41)
	var c57 := ws.get_country_by_legacy_index(57)
	match opt:
		0:
			var text0 := tr(TXT_R0_0)
			if _cf(41, "SubGosstroy") == 10:
				text0 += tr(TXT_R0_1)
			text0 += tr(TXT_R0_2)
			context["result_text"] = text0
			if c13 != null: c13.set_tag("对华贸易", true)
			if c13 != null: c13.government = GameConstants.Government.AUTHORITARIAN
			if c13 != null: c13.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			ws.influence_prc += 10
			_add_relation(0, -100)
			ws.oil_prod += 150.0  # Event512.cs result0：利比亚扩大合作
		1:
			_add(8, -30)
			var text1 := tr(TXT_R1_0)
			if _cf(41, "SubGosstroy") == 10:
				text1 += tr(TXT_R1_1)
			text1 += tr(TXT_R1_2)
			context["result_text"] = text1
			if c13 != null: c13.set_tag("对华贸易", false)
			if c13 != null: c13.government = GameConstants.Government.AUTHORITARIAN
			if c13 != null: c13.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_add_relation(0, 150)
		2:
			if ws.wars.size() > 20 and ws.wars[20] != null and ws.wars[20].is_going:
				ws.wars[20].infl2 = 1000
				ws.wars[20].infl1 = 0
			if c13 != null: c13.puppet_of = GameConstants.LegacySlot.NONE
			for c in ws.countries:
				if c != null and c.puppet_of == 13:
					c.puppet_of = GameConstants.LegacySlot.NONE
			var text2 := tr(TXT_R2_0)
			if c57 != null and c57.puppet_of == 13:
				c57.puppet_of = GameConstants.LegacySlot.NONE
			if ws.political_line < 3 and _tag(1, "okb"):
				text2 += tr(TXT_R2_1)
				if c13 != null:
					_leave_alliances(c13)
					c13.government = GameConstants.Government.SOCIALIST
					c13.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					c13.set_tag("对华贸易", true)
					c13.set_tag("亲中", true)
				if c13 != null:
					if c13.parts.size() <= 0: c13.parts.resize(1)
					c13.parts[0] = false
				ws.influence_prc += 30
			if ws.political_line >= 3 and _tag(1, "okb"):
				text2 += tr(TXT_R2_2)
				if c13 != null:
					_leave_alliances(c13)
					c13.government = GameConstants.Government.LIBERAL
					c13.sub_government = GameConstants.SubGovernment.MODERATE
					c13.set_tag("亲中", true)
				if c13 != null:
					if c13.parts.size() <= 0: c13.parts.resize(1)
					c13.parts[0] = false
			if _tag(1, "seato"):
				text2 += tr(TXT_R2_3)
				if c13 != null:
					_leave_alliances(c13)
					c13.government = GameConstants.Government.AUTHORITARIAN
					c13.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					c13.set_tag("亲美", true)
				if c13 != null:
					if c13.parts.size() <= 0: c13.parts.resize(1)
					c13.parts[0] = false
			context["result_text"] = text2
		3:
			var text3 := tr(TXT_R3_0)
			if _cf(41, "SubGosstroy") == 10:
				text3 += tr(TXT_R3_1)
			text3 += tr(TXT_R3_2)
			context["result_text"] = text3
			if c13 != null: c13.government = GameConstants.Government.AUTHORITARIAN
			if c13 != null: c13.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST

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
		elif data.party_system == GameConstants.PartySystem.PEOPLE_DEMOCRACY:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data.ideology <= 2 and data.econ_system < 13 				and data.diplomatic_reputation >= 700 and data.party_system < GameConstants.PartySystem.PEOPLE_DEMOCRACY 				and _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
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
		elif _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and data.party_system <= GameConstants.PartySystem.NEW_DEMOCRACY 				and data.econ_system <= 12 and data.religion_policy <= 25:
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
		elif data.ideology >= 2 and data.econ_system >= 13 				and data.diplomatic_reputation <= 700 and data.party_system >= GameConstants.PartySystem.PEOPLE_DEMOCRACY 				and data.press_policy >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data.ideology <= 3 and data.econ_system >= 12 				and data.econ_system <= 13 and data.diplomatic_reputation >= 300 				and data.territory_policy > 21 and data.war_support >= 700:
			result = 11
		elif data.ideology <= 3 and data.econ_system <= 14 				and data.diplomatic_reputation >= 500 and data.econ_system > 11 				and data.war_support >= 400:
			result = 8
		elif data.ideology <= 3 and data.econ_system <= 13 				and data.press_policy > 17:
			result = 3
		elif data.party_system <= GameConstants.PartySystem.PEOPLE_DEMOCRACY 				and (data.econ_system == 13 or data.econ_system == 12) 				and data.war_support < 700 and not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) 				and data.press_policy >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data.econ_system <= 13 and data.diplomatic_reputation >= 500:
		result = 4
	elif (data.party_system <= GameConstants.PartySystem.PEOPLE_DEMOCRACY and data.press_policy <= 18) 			or data.war_support >= 700:
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
		"cw": return 1 if c.内战中 else 0
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_512_gulf_of_sidra.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_512",
	"num": 512,
	"priority": 51200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_512_gulf_of_sidra.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.8.18"}, {"t": "ANY", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 15, "target": "13"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "13"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
