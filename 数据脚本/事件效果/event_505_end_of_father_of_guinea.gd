extends "res://数据脚本/event_script_base.gd"

## 原作 Event505.cs：几内亚之父的终结（3选项）。 ## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/ 换行/剥 color）。 ## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "event.script.event_505_end_of_father_of_guinea.c0"
const TXT_OPT1_DIS := "event.script.event_505_end_of_father_of_guinea.c1"
const TXT_R0_A := "event.script.event_505_end_of_father_of_guinea.c2"
const TXT_R1_A := "event.script.event_505_end_of_father_of_guinea.c3"
const TXT_R1_B := "event.script.event_505_end_of_father_of_guinea.c4"
const TXT_R2_A := "event.script.event_505_end_of_father_of_guinea.c5"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.political_line <= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if ws.political_line > 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c68 := ws.get_country_by_legacy_index(68)
	match opt:
		0:
			context["result_text"] = tr(TXT_R0_A)
			_add(8, -(50))
			ws.influence_prc += 20
			if c68 != null: c68.government = GameConstants.Government.SOCIALIST
			if c68 != null: c68.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			if c68 != null: _leave_alliances(c68)
			if c68 != null: c68.set_tag("对华贸易", true)
		1:
			if ws.empires[0].relations >= 500:
				context["result_text"] = tr(TXT_R1_A)
			else:
				context["result_text"] = tr(TXT_R1_B)
			_add(9, -(40))
			if ws.empires[0].relations >= 500:
				if c68 != null: c68.government = GameConstants.Government.AUTHORITARIAN
				if c68 != null: c68.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				if c68 != null: _leave_alliances(c68)
				if c68 != null: c68.puppet_of = GameConstants.LegacySlot.FRANCE
				if c68 != null: c68.set_tag("对华贸易", true)
				_add_power(0, 20)
				_add_relation(1, 80)
			else:
				if c68 != null: c68.government = GameConstants.Government.REFORMIST
				if c68 != null: c68.sub_government = GameConstants.SubGovernment.PRAGMATIST
				if c68 != null: _leave_alliances(c68)
				if c68 != null: c68.set_tag("亲苏", true)
				_add_power(1, 20)
		2:
			context["result_text"] = tr(TXT_R2_A)
			if c68 != null: c68.government = GameConstants.Government.REFORMIST
			if c68 != null: c68.sub_government = GameConstants.SubGovernment.PRAGMATIST
			if c68 != null: _leave_alliances(c68)

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
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_505_end_of_father_of_guinea.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_505",
	"num": 505,
	"priority": 50500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_505_end_of_father_of_guinea.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.8.27"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
