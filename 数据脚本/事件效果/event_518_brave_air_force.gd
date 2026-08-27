extends "res://数据脚本/event_script_base.gd"

## 原作 Event518.cs：人民空军，勇敢去闯荡（4选项）。 ## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/ 换行/剥 color）。 ## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "event.script.event_518_brave_air_force.c0"
const TXT_OPT1_DIS := "event.script.event_518_brave_air_force.c1"
const TXT_OPT2_DIS := "event.script.event_518_brave_air_force.c2"
const TXT_R0_A := "event.script.event_518_brave_air_force.c3"
const TXT_R1_A := "event.script.event_518_brave_air_force.c4"
const TXT_R2_A := "event.script.event_518_brave_air_force.c5"
const TXT_R3_A := "event.script.event_518_brave_air_force.c6"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if int(ws.completed_event_ids.get("event_517", 0)) >= 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if int(ws.completed_event_ids.get("event_517", 0)) == 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0_A)
			_add(8, -(50))
			_add(22, 50)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 20
			# 原版 string[] old_modify_desc = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。
			# 原版 int num = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc[num] += "<color=red>| 隐 身 歼 击 机 ：</color>| 军 力+0.2 ， 人 民 支 持 度+0.2 ， 预 算-0.2 ， 干 预 点 数+1.0"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |隐身歼击机：|军力+0.2，人民支持度+0.2，预算-0.2，干预点数+1.0
		1:
			context["result_text"] = tr(TXT_R1_A)
			_add(8, -(50))
			_add(22, 50)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 30
			# 原版 string[] old_modify_desc2 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。
			# 原版 int num2 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc2[num2] += "<color=red>| 隐 身 轰 炸 机 ：</color>| 军 力+0.3 ， 预 算-0.2 ，与 美 苏 关 系-0.1 ，干 预 点 数+1.0"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |隐身轰炸机：|军力+0.3，预算-0.2，与美苏关系-0.1，干预点数+1.0
		2:
			context["result_text"] = tr(TXT_R2_A)
			_add(8, -(80))
			_add(22, 80)
			_add(1, 100)
			_add(6, 5)
			_add(3, 100)
			_add(57, 50)
			ws.influence_prc += 50
			# 原版 string[] old_modify_desc3 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。
			# 原版 int num3 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc3[num3] += "<color=red>| 隐 身 歼 击 机 与 轰 炸 机 ：</color>| 军 力+0.8 ， 人 民 支 持 度+0.2 ， 预 算-0.3 ，与 美 苏 关 系-0.1 ， 干 预 点 数+2.0"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |隐身歼击机与轰炸机：|军力+0.8，人民支持度+0.2，预算-0.3，与美苏关系-0.1，干预点数+2.0
		3:
			context["result_text"] = tr(TXT_R3_A)

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



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_518_brave_air_force.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_518",
	"num": 518,
	"priority": 51800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_518_brave_air_force.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_517"}, {"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1983}, {"t": "RESOURCE_AT_LEAST", "key": "industry", "v": 1000}, {"t": "TECH_UNLOCKED", "v": 16}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
