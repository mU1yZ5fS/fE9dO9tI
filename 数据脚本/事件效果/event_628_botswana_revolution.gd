extends "res://数据脚本/event_script_base.gd"

## 原作 Event628.cs：保佑这高尚的土地（博茨瓦纳革命，单选项）。
## 触发：DiploButtonScript.cs:12117 —— 外交按钮 1032，selected_country==129（博茨瓦纳），
##   入口扣 data.agents-=100（在 _def_1032 中已移植），随后 StartEvent(628)。
## 本 .tres trigger_conditions 为空：仅由外交按钮手动触发。
## 差异：原版按 politics_dolshnost[0]（150/200 哨兵）选择总理槽姓名或领袖姓名；
##   Godot politics_positions[0] 同哨兵语义（150/200），姓名用 PoliticianData.name_display 全文。

const TXT_R_FAIL := "event.script.event_628_botswana_revolution.c0"
const TXT_SUCCESS_PRE_PM := "event.script.event_628_botswana_revolution.c1"
const TXT_SUCCESS_PRE_CHAIRMAN := "event.script.event_628_botswana_revolution.c2"
const TXT_SUCCESS_PRE_PM_LEADER := "event.script.event_628_botswana_revolution.c3"
const TXT_SUCCESS_POST := "event.script.event_628_botswana_revolution.c4"
const TXT_R_NEUTRAL := "event.script.event_628_botswana_revolution.c5"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var botswana := ws.get_country_by_legacy_index(129)  # 博茨瓦纳
	var south_africa := ws.get_country_by_legacy_index(131)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# 原版 :29-40：南非 SubGosstroy==7/9 → 失败分支
			if south_africa != null and (south_africa.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN or south_africa.sub_government == GameConstants.SubGovernment.NEO_FASCIST):
				context["result_text"] = tr(TXT_R_FAIL)
				if botswana != null:
					botswana.government = GameConstants.Government.AUTHORITARIAN
					botswana.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					_leave_alliances(botswana)
					botswana.chinese_name = "贝专兰合众邦"
					botswana.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
				ws.influence_prc -= 20
				_add_power(EmpireData.USA, 20)
				return
			# 原版 :41-65：level_of_unstab==200 && modifies[6] && cw → 左翼夺权
			var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
			if botswana != null and botswana.level_of_instability == 200 and mod6 and botswana.内战中:
				context["result_text"] = _success_text()
				if botswana != null:
					botswana.government = GameConstants.Government.SOCIALIST
					botswana.sub_government = GameConstants.SubGovernment.MAOIST
					_leave_alliances(botswana)
					botswana.set_tag("亲中", true)
					botswana.set_tag("对华贸易", true)
					botswana.chinese_name = "博茨瓦纳民主共和国"
				ws.influence_prc += 20
				_add_relation(EmpireData.USA, -100)
				_add_power(EmpireData.USA, -20)
				return
			# 原版 :66-77：其余 → 亲苏左翼大帐篷
			context["result_text"] = tr(TXT_R_NEUTRAL)
			if botswana != null:
				botswana.government = GameConstants.Government.SOCIALIST
				botswana.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				_leave_alliances(botswana)
				botswana.set_tag("亲苏", true)
				botswana.set_tag("对华贸易", true)
				botswana.chinese_name = "博茨瓦纳社会主义共和国"
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -20)
			_add_relation(EmpireData.USSR, 100)
			_add_power(EmpireData.USSR, 15)


## 原版 :43-54 的国务院总理/国家主席分支。
func _success_text() -> String:
	if ws.politics_positions.size() > 0:
		var idx := ws.politics_positions[0]
		if idx != 150 and idx != 200:
			return tr(TXT_SUCCESS_PRE_PM) + _slot_name(idx) + tr(TXT_SUCCESS_POST)
		if idx == 200:
			return tr(TXT_SUCCESS_PRE_CHAIRMAN) + _leader_name() + tr(TXT_SUCCESS_POST)
		return tr(TXT_SUCCESS_PRE_PM_LEADER) + _leader_name() + tr(TXT_SUCCESS_POST)
	return tr(TXT_SUCCESS_PRE_PM_LEADER) + _leader_name() + tr(TXT_SUCCESS_POST)


func _slot_name(politician_index: int) -> String:
	if politician_index >= 0 and politician_index < ws.politicians.size():
		var p: PoliticianData = ws.politicians[politician_index]
		if p != null and p.name_display != "":
			return p.name_display
	return _leader_name()


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_628_botswana_revolution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_628",
	"num": 628,
	"priority": 62800,
	"notify": false,
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
