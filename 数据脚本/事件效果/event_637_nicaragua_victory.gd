extends "res://数据脚本/event_script_base.gd"

## 原作 Event637.cs：在胜利的门前（尼加拉瓜革命结局，四选项）。
## 触发：ReqEventsDLC02.cs:991-994 —— DATE_AFTER 1979.5.10。
## 差异：Destroy(button) → _disable；modifies[3]/[6] → ws.modifiers；
##   resultOfEvents[636]/[637] 在 execute 内读 completed_event_ids（本事件完成标记在 execute 之后）。

const TXT_OPT1_DIS := "event.script.event_637_nicaragua_victory.c0"
const TXT_OPT2_DIS := "event.script.event_637_nicaragua_victory.c1"
const TXT_OPT3_DIS := "event.script.event_637_nicaragua_victory.c2"
const TXT_R2_PRE := "event.script.event_637_nicaragua_victory.c3"
const TXT_R2_POST := "event.script.event_637_nicaragua_victory.c4"
const TXT_R3 := "event.script.event_637_nicaragua_victory.c5"
const TXT_V_FONSECA := "event.script.event_637_nicaragua_victory.c6"
const TXT_V_SANDINISTA := "event.script.event_637_nicaragua_victory.c7"
const TXT_V_PASTORA := "event.script.event_637_nicaragua_victory.c8"
const TXT_V_PROSOV_A := "event.script.event_637_nicaragua_victory.c9"
const TXT_V_PROSOV_B := "event.script.event_637_nicaragua_victory.c10"
const TXT_V_PROSOV_A_ALT := "event.script.event_637_nicaragua_victory.c11"
const TXT_V_PROSOV_B_ALT := "event.script.event_637_nicaragua_victory.c12"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var r636 := int(ws.completed_event_ids.get("event_636", 0))
	var r637 := int(ws.completed_event_ids.get("event_637", 0))
	var usa_rel := ws.empires[0].relations if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if r636 == 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if _res(W.I_POLITICAL_LINE) > 2 and usa_rel >= 500:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if r637 != 0 and usa_rel >= 500:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nic := ws.get_country_by_legacy_index(147)
	if nic == null:
		return
	var opt := int(context.get("option_index", -1))
	if opt == 2:
		context["result_text"] = tr(TXT_R2_PRE) + _leader_name() + tr(TXT_R2_POST)
		nic.level_of_instability += 50
		nic.government = GameConstants.Government.LIBERAL
		nic.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -50)
		_add(W.I_ARMY, -50)
		ws.influence_prc += 5
		_add_power(EmpireData.USA, 15)
		_add_relation(EmpireData.USA, 150)
		return
	if opt == 3:
		context["result_text"] = tr(TXT_R3)
		_add(W.I_BUDGET, -50)
		_add(W.I_AGENTS, -50)
		_add_relation(EmpireData.USSR, -50)
		nic.level_of_instability -= 50
		_add_power(EmpireData.USA, 5)
		ws.influence_prc -= 5
	elif opt == 1:
		nic.level_of_instability += 50
	if opt != 3:
		context["result_text"] = tr("event.script.event_637_nicaragua_victory.i0")
	var r636 := int(ws.completed_event_ids.get("event_636", 0))
	# 原版 Results_text.cs:12 在选择后先把 resultOfEvents[637] 写成当前选项，再调用
	# ResultsOfEvents；所以这里 alt 分支必须用当前 opt（选项3=支持索摩查），
	# 不能用上一次完成记录（首次触发时恒 0，会让选项3错误走进非 alt 链）。
	_run_victory_chain(context, nic, r636, opt == 3)


func _run_victory_chain(context: Dictionary, nic: CountryData, r636: int, alt: bool) -> void:
	var china := ws.get_country_by_legacy_index(1)
	var pro_soviet := r636 == 1 or (china != null and china.has_tag("sev")) \
		or alt
	var mod3 := ws.modifiers.size() > 3 and ws.modifiers[3] != null and ws.modifiers[3].is_active
	var mod6 := ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if not alt and r636 == 0 and mod3 and mod6 and nic.level_of_instability >= 500:
		context["result_text"] = str(context.get("result_text", "")) + tr(TXT_V_FONSECA)
		nic.government = GameConstants.Government.SOCIALIST
		nic.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
		_leave_alliances(nic)
		nic.set_tag("对华贸易", true)
		nic.set_tag("亲中", true)
		ws.influence_prc += 15
		_add_power(EmpireData.USA, -15)
		_add_relation(EmpireData.USA, -80)
		nic.level_of_instability += 300
		return
	if not alt and r636 == 0:
		context["result_text"] = str(context.get("result_text", "")) + tr(TXT_V_SANDINISTA)
		nic.government = GameConstants.Government.REFORMIST
		nic.sub_government = GameConstants.SubGovernment.PRAGMATIST
		_leave_alliances(nic)
		nic.set_tag("对华贸易", true)
		nic.set_tag("亲中", true)
		ws.influence_prc += 10
		_add_power(EmpireData.USA, -15)
		_add_relation(EmpireData.USA, -80)
		nic.level_of_instability += 300
		return
	if not alt and _res(W.I_POLITICAL_LINE) == 4:
		context["result_text"] = str(context.get("result_text", "")) + tr(TXT_V_PASTORA)
		nic.government = GameConstants.Government.LIBERAL
		nic.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
		_leave_alliances(nic)
		nic.set_tag("对华贸易", true)
		nic.set_tag("亲中", true)
		nic.level_of_instability -= 400
		ws.influence_prc += 10
		_add_power(EmpireData.USA, -15)
		_add_relation(EmpireData.USA, -80)
		nic.level_of_instability += 300
		return
	if pro_soviet and nic.level_of_instability >= 500:
		context["result_text"] = str(context.get("result_text", "")) + (tr(TXT_V_PROSOV_A_ALT) if alt else tr(TXT_V_PROSOV_A))
		nic.government = GameConstants.Government.SOCIALIST
		nic.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		_leave_alliances(nic)
		nic.set_tag("对华贸易", true)
		nic.set_tag("亲苏", true)
		nic.level_of_instability += 300
		ws.influence_prc += 10
		_add_power(EmpireData.USSR, 15)
		_add_relation(EmpireData.USSR, 80)
		_add_power(EmpireData.USA, -15)
		_add_relation(EmpireData.USA, -80)
		return
	if pro_soviet:
		context["result_text"] = str(context.get("result_text", "")) + (tr(TXT_V_PROSOV_B_ALT) if alt else tr(TXT_V_PROSOV_B))
		nic.government = GameConstants.Government.REFORMIST
		nic.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
		_leave_alliances(nic)
		nic.set_tag("对华贸易", true)
		nic.set_tag("亲苏", true)
		nic.level_of_instability += 300
		ws.influence_prc += 10
		_add_power(EmpireData.USSR, 15)
		_add_relation(EmpireData.USSR, 80)
		_add_power(EmpireData.USA, -15)
		_add_relation(EmpireData.USA, -80)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_637_nicaragua_victory.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_637",
	"num": 637,
	"priority": 63700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_637_nicaragua_victory.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.5.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
