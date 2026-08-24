extends "res://数据脚本/event_script_base.gd"

## 原作 Event912.cs：奥林匹斯山的诸神们（革命国际筹备，两选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:77-79 ——
##   !event_done[912] && event_done[503] && resultOfEvents[503]==0 && resultOfEvents[378]==0
##   && allcountries[10].SubGosstroy==10 && allcountries[10].Torg && allcountries[10].puppetOf<0
##   && leader.name_1==2 && leader.name_2==2
##   && allcountries[5].SubGosstroy==10 && allcountries[5].proprc。
##   因 ExprNode 无领导人姓名字段，使用 trigger_script = 本脚本 evaluate()。
## 差异：
##  - 结果0 的 string.Format 伊拉克分支用 GDScript String.format([iraq_text])；
##  - ChineseSubGosstroy() 完整移植为 _chinese_sub_government()（同 Event713）；
##  - 死代码 doctr[6..24] 赋值（modifies[6].active 刚被置 false 后判断，恒走 else 分支）
##    为 display-only，跳过并注释；
##  - isBALECON→set_tag("balecon", false)；Torg/proprc/econ/okb 循环按严格社会主义清标签。

const TXT_R0 := "event.script.event_912_olympus_gods.c0"
const TXT_R0_IRAQ := "event.script.event_912_olympus_gods.c1"
const TXT_R1 := "event.script.event_912_olympus_gods.c2"


## 复杂触发钩子（EventDef.trigger_script 调用）。
func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if not world.completed_event_ids.has("event_503"):
		return false
	if world.completed_event_ids.get("event_503", -1) != 0:
		return false
	if world.completed_event_ids.get("event_378", -1) != 0:
		return false
	var korea := world.get_country_by_legacy_index(10)
	if korea == null or korea.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST or not korea.has_tag("对华贸易") or korea.puppet_of >= 0:
		return false
	if world.leader == null or world.leader.name_first != 2 or world.leader.name_last != 2:
		return false
	var mongolia := world.get_country_by_legacy_index(5)
	if mongolia == null or mongolia.sub_government != GameConstants.SubGovernment.LEFT_NATIONALIST or not mongolia.has_tag("亲中"):
		return false
	return true


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var iraq := ws.get_country_by_legacy_index(14)
			var iraq_text := ""
			if iraq != null and iraq.sub_government == GameConstants.SubGovernment.LEFT_NATIONALIST and iraq.puppet_of < 0:
				iraq_text = tr(TXT_R0_IRAQ)
			context["result_text"] = tr(TXT_R0).format([iraq_text])
			_add(W.I_PARTY_SUPPORT, 1000)
			_add(W.I_PEOPLE_SUPPORT, 1000)
			_add(W.I_THOUGHT_FREEDOM, -1000)
			_set_data(W.I_WAR_SUPPORT, 1000)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_set_data(W.I_PARTY_SYSTEM, 6)
			_set_data(W.I_ECON_SYSTEM, 10)
			_set_data(W.I_PRESS_POLICY, 16)
			_set_data(W.I_TERRITORY, 20)
			_set_data(W.I_RELIGION, 29)
			_set_modifier_active(6, false)
			var china := ws.get_country_by_legacy_index(1)
			var korea := ws.get_country_by_legacy_index(10)
			var mongolia := ws.get_country_by_legacy_index(5)
			if china != null:
				china.government = GameConstants.Government.AUTHORITARIAN
				china.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			if korea != null:
				korea.government = GameConstants.Government.AUTHORITARIAN
				korea.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
			if mongolia != null:
				mongolia.government = GameConstants.Government.AUTHORITARIAN
				mongolia.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				mongolia.set_tag("balecon", false)
			for c in ws.countries:
				if c == null:
					continue
				if c.government == GameConstants.Government.SOCIALIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
					c.set_tag("对华贸易", false)
					c.set_tag("亲中", false)
					c.set_tag("econ", false)
					c.set_tag("okb", false)
			# 原版此处在 modifies[6].active=false 后判断其真假，恒走 else 分支的
			# doctr[6..24] 赋值，属 display-only，跳过。
			_set_modifier_active(3, true)
			_add_relation(EmpireData.USA, -500)
			_add_relation(EmpireData.USSR, -500)
			# 原版最后再次把中国 SubGosstroy 覆盖为 ChineseSubGosstroy()
			if china != null:
				china.government = GameConstants.Government.AUTHORITARIAN
				china.sub_government = _chinese_sub_government()
		1:
			context["result_text"] = tr(TXT_R1)


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif d.party_system == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif d.ideology <= 2 and d.econ_system < 13 and d.diplomatic_reputation >= 700 and d.party_system < 8 and _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
			result = 0
		elif (d.econ_system >= 13 and d.war_support >= 700 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK)) or _mod_active(GameConstants.Modifier.PRESIDENT_FOR_LIFE):
			result = 9
		elif d.econ_system <= 13 and d.war_support >= 700 and d.diplomatic_reputation >= 700 and (_mod_active(GameConstants.Modifier.MAOIST_BULWARK) or _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION)):
			result = 10
		elif d.econ_system >= 13 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(GameConstants.Modifier.FOURTH_INTERNATIONAL):
			result = 18
		elif _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and d.party_system <= 7 and d.econ_system <= 12 and d.religion_policy <= 25:
			result = 17
		elif d.ideology == 1 and not _mod_active(GameConstants.Modifier.MAOIST_BULWARK) and d.religion_policy <= 26:
			result = 16
		elif d.econ_system < 13 and d.press_policy >= 17 and d.ideology == 1 and d.religion_policy <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(GameConstants.Modifier.RETURN_TO_AGRARIAN_CIVILIZATION):
			result = 8
		elif d.ideology >= 2 and d.econ_system >= 13 and d.diplomatic_reputation <= 700 and d.party_system >= 8 and d.press_policy >= 18 and not china.has_tag("ovd"):
			result = 14
		elif d.ideology <= 3 and d.econ_system >= 12 and d.econ_system <= 13 and d.diplomatic_reputation >= 300 and d.territory_policy > 21 and d.war_support >= 700:
			result = 11
		elif d.ideology <= 3 and d.econ_system <= 14 and d.diplomatic_reputation >= 500 and d.econ_system > 11 and d.war_support >= 400:
			result = 8
		elif d.ideology <= 3 and d.econ_system <= 13 and d.press_policy > 17:
			result = 3
		elif d.party_system <= 8 and (d.econ_system == 13 or d.econ_system == 12) and d.war_support < 700 and not _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION) and d.press_policy >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif d.econ_system <= 13 and d.diplomatic_reputation >= 500:
		result = 4
	elif (d.party_system <= 8 and d.press_policy <= 18) or d.war_support >= 700:
		result = 12
	elif d.econ_system > 13 and d.diplomatic_reputation < 700:
		result = 6
	else:
		result = 5
	return result


func _event_result(event_id: String) -> int:
	return int(ws.completed_event_ids.get(event_id, 0))


func _mod_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, value: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = value




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_912_olympus_gods.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_912",
	"num": 912,
	"priority": 91200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_912_olympus_gods.gd",
	"trigger_script": "res://数据脚本/事件效果/event_912_olympus_gods.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
