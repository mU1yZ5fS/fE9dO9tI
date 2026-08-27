extends "res://数据脚本/event_script_base.gd"

## 原作 Event501.cs：西方-81演习（5选项）。 ## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/ 换行/剥 color）。 ## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_R0_A := "event.script.event_501_western_81_exercise.c0"
const TXT_R0_B := "event.script.event_501_western_81_exercise.c1"
const TXT_R1_A := "event.script.event_501_western_81_exercise.c2"
const TXT_R1_B := "event.script.event_501_western_81_exercise.c3"
const TXT_R1_C := "event.script.event_501_western_81_exercise.c4"
const TXT_R1_D := "event.script.event_501_western_81_exercise.c5"
const TXT_R1_E := "event.script.event_501_western_81_exercise.c6"
const TXT_R1_F := "event.script.event_501_western_81_exercise.c7"
const TXT_R1_H := "event.script.event_501_western_81_exercise.c8"
const TXT_R1_I := "event.script.event_501_western_81_exercise.c9"
const TXT_R1_J := "event.script.event_501_western_81_exercise.c10"
const TXT_R1_K := "event.script.event_501_western_81_exercise.c11"
const TXT_R2 := "event.script.event_501_western_81_exercise.c12"
const TXT_R3_A := "event.script.event_501_western_81_exercise.c13"
const TXT_R3_B := "event.script.event_501_western_81_exercise.c14"
const TXT_R4 := "event.script.event_501_western_81_exercise.c15"
const TXT_OPT1_DIS := "event.script.event_501_western_81_exercise.c16"
const TXT_OPT2_DIS := "event.script.event_501_western_81_exercise.c17"
const TXT_OPT3_DIS := "event.script.event_501_western_81_exercise.c18"
const TXT_OPT4_DIS := "event.script.event_501_western_81_exercise.c19"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if ws.political_line < 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if _tag(1, "ovd"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if _empire_rel(1) >= 590:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	if _tag(1, "seato") and _tag(51, "对华贸易"):
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var fm := _office_name(2)
			context["result_text"] = tr(TXT_R0_A) + fm + tr(TXT_R0_B)
			_add_relation(1, -80)
			_add_power(1, 100)
		1:
			var text1 := tr(TXT_R1_A)
			if _tech(29):
				text1 += tr(TXT_R1_B)
			if _tech(21):
				text1 += tr(TXT_R1_C)
			if _tech(22):
				text1 += tr(TXT_R1_D)
			text1 += tr(TXT_R1_E)
			if ws.politics_positions[1] != 150 and ws.politics_positions[1] != 200:
				text1 += tr(TXT_R1_F) + _office_name(1) + tr(TXT_R1_H) + _leader_name() + tr(TXT_R1_I)
			else:
				text1 += tr(TXT_R1_J) + _leader_name() + tr(TXT_R1_K)
			context["result_text"] = text1
			_add(6, 200)
			_add(8, -60)
			_add(22, -150)
			ws.influence_prc += 150
			_add_relation(0, -50)
			_add_relation(1, -150)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(6, 100)
			ws.influence_prc -= 100
			_add_relation(0, -200)
			_add_relation(1, 200)
			_add_power(1, 200)
		3:
			var text3 := tr(TXT_R3_A)
			if ws.politics_positions[1] != 150 and ws.politics_positions[1] != 200:
				text3 += _office_name(1) + tr(TXT_R3_B)
			else:
				text3 += _leader_name() + tr(TXT_R3_B)
			context["result_text"] = text3
			_add(6, 80)
			_add(22, 30)
			ws.influence_prc -= 50
			_add_relation(0, -100)
			_add_relation(1, 100)
			_add_power(1, 150)
		4:
			context["result_text"] = tr(TXT_R4)
			_add(6, 100)
			ws.influence_prc -= 100
			_add_relation(1, -100)
			_add_relation(0, 200)
			_add_power(0, 200)

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



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_501_western_81_exercise.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_501",
	"num": 501,
	"priority": 50100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_501_western_81_exercise.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.9.4"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "puppet_of", "v": 7, "target": "2"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
