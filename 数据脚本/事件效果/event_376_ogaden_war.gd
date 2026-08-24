extends "res://数据脚本/event_script_base.gd"

## 原作 Event376.cs：欧加登战争（埃塞俄比亚/索马里三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - SOV_PRC_PartiesConnection → I_COMMUNICATIONS（data.communications，见 event_435 约定）；
##  - 描述/选项显隐 prepare 按 c41.Gosstroy / c41.proprc 动态改写；
##  - war 15 按模板覆盖 name_war/fortnight_max。

const TXT_DESC_GOS := "event.script.event_376_ogaden_war.c0"
const TXT_DESC_PROPRC := "event.script.event_376_ogaden_war.c1"
const TXT_OPT0_GOS := "event.script.event_376_ogaden_war.c2"
const TXT_OPT1_GOS := "event.script.event_376_ogaden_war.c3"
const TXT_OPT1_DIS_ELSE := "event.script.event_376_ogaden_war.c4"
const TXT_OPT0_NEUTRAL := "event.script.event_376_ogaden_war.c5"
const TXT_OPT1_NEUTRAL := "event.script.event_376_ogaden_war.c6"
const TXT_R0_GOS := "event.script.event_376_ogaden_war.c7"
const TXT_R1_GOS := "event.script.event_376_ogaden_war.c8"
const TXT_R2_GOS := "event.script.event_376_ogaden_war.c9"
const TXT_R1_PROPRC := "event.script.event_376_ogaden_war.c10"
const TXT_R0_NEUTRAL := "event.script.event_376_ogaden_war.c11"
const TXT_R2_NEUTRAL := "event.script.event_376_ogaden_war.c12"
const TXT_DIS_BUDGET := "event.script.event_376_ogaden_war.c13"
const TXT_DIS_AGENTS := "event.script.event_376_ogaden_war.c14"
const TXT_DIS_ARMY := "event.script.event_376_ogaden_war.c15"
const TXT_LABEL_BUDGET := "event.script.event_376_ogaden_war.c16"
const TXT_LABEL_AGENTS := "event.script.event_376_ogaden_war.c17"
const TXT_LABEL_ARMY := "event.script.event_376_ogaden_war.c18"
const TXT_WAR_NAME := "event.script.event_376_ogaden_war.c19"
const TXT_WAR_ATT := "event.script.event_376_ogaden_war.c20"
const TXT_WAR_DEF := "event.script.event_376_ogaden_war.c21"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var ethiopia := world.get_country_by_legacy_index(41)
	var opt := event_def.options
	if ethiopia != null and ethiopia.government == GameConstants.Government.SOCIALIST:
		event_def.description = tr(TXT_DESC_GOS)
		_prepare_opt0(opt[0], tr(TXT_OPT0_GOS))
		_prepare_opt1(opt[1], tr(TXT_OPT1_GOS))
	elif ethiopia != null and ethiopia.has_tag("亲中"):
		event_def.description = tr(TXT_DESC_PROPRC)
		_prepare_opt0(opt[0], tr(TXT_OPT0_GOS))
		_disable(opt[1], "")
	else:
		_prepare_opt0(opt[0], tr(TXT_OPT0_NEUTRAL))
		_prepare_opt1(opt[1], tr(TXT_OPT1_NEUTRAL))
	_enable(opt[2], event_def.options[2].text)


func _prepare_opt0(opt: EventOption, text: String) -> void:
	if _d(W.I_ARMY) >= 50 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 30:
		_enable(opt, text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt, tr(TXT_DIS_BUDGET).format([3]))
	else:
		_disable(opt, tr(TXT_DIS_ARMY).format([5]))


func _prepare_opt1(opt: EventOption, text: String) -> void:
	if _d(W.I_ARMY) >= 50 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 30 			and int(ws.completed_event_ids.get("event_585", 0)) != 2:
		_enable(opt, text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt, tr(TXT_DIS_BUDGET).format([3]))
	elif _d(W.I_AGENTS) < 150:
		_disable(opt, tr(TXT_DIS_AGENTS).format([15]))
	elif _d(W.I_ARMY) < 50:
		_disable(opt, tr(TXT_DIS_ARMY).format([5]))
	else:
		_disable(opt, tr(TXT_OPT1_DIS_ELSE))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var ethiopia := ws.get_country_by_legacy_index(41)
	var somalia := ws.get_country_by_legacy_index(42)
	var num := 0
	if int(ws.completed_event_ids.get("event_587", 0)) == 2:
		num = 100
	var opt := int(context.get("option_index", -1))
	if ethiopia != null and ethiopia.government == GameConstants.Government.SOCIALIST:
		match opt:
			0:
				context["result_text"] = tr(TXT_R0_GOS)
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USA, 10)
				_add_relation(EmpireData.USA, 120)
				_add_relation(EmpireData.USSR, -150)
				d.communications -= 20
				_add(W.I_PARTY_SUPPORT, 100)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", true)
				_start_war_376(400, 600, 0, 1)
			1:
				context["result_text"] = tr(TXT_R1_GOS)
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USSR, 10)
				_add_relation(EmpireData.USSR, 120)
				_add_relation(EmpireData.USA, -150)
				d.communications += 20
				_add(W.I_PARTY_SUPPORT, 100)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", false)
				if somalia != null:
					somalia.set_tag("对华贸易", true)
				_start_war_376(600, 400, 0, 1)
			2:
				context["result_text"] = tr(TXT_R2_GOS)
				_start_war_376(550, 450, 0, 1)
	elif ethiopia != null and ethiopia.has_tag("亲中"):
		match opt:
			0:
				context["result_text"] = tr(TXT_R0_GOS)
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USA, 10)
				_add_relation(EmpireData.USA, 120)
				_add_relation(EmpireData.USSR, -150)
				d.communications -= 20
				_add(W.I_PARTY_SUPPORT, 100)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", true)
				_start_war_376(400, 600, 0, 1)
			1:
				context["result_text"] = tr(TXT_R1_PROPRC)
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USSR, 10)
				_add_relation(EmpireData.USSR, 120)
				_add_relation(EmpireData.USA, -150)
				d.communications += 20
				_add(W.I_PARTY_SUPPORT, 100)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", false)
				if somalia != null:
					somalia.set_tag("对华贸易", true)
				_start_war_376(550, 450, 1, 0)
			2:
				context["result_text"] = tr(TXT_R2_GOS)
				_start_war_376(550, 450, 0, 1)
	else:
		if somalia != null:
			somalia.set_tag("亲苏", false)
		match opt:
			0:
				context["result_text"] = tr(TXT_R0_NEUTRAL)
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USSR, 10)
				_add_relation(EmpireData.USSR, 120)
				_add_relation(EmpireData.USA, -150)
				d.communications += 20
				_add(W.I_PARTY_SUPPORT, 100)
				if somalia != null:
					somalia.set_tag("对华贸易", false)
				if ethiopia != null:
					ethiopia.set_tag("对华贸易", true)
				_start_war_376(300 + num, 700 - num, 1, 0)
			1:
				context["result_text"] = tr(TXT_R1_PROPRC)
				_add(W.I_DIPLO, 10)
				_add(W.I_BUDGET, -30)
				_add(W.I_ARMY, -30)
				_add_power(EmpireData.USA, 10)
				_add_relation(EmpireData.USA, 120)
				_add_relation(EmpireData.USSR, -150)
				d.communications -= 20
				_add(W.I_PARTY_SUPPORT, 100)
				if somalia != null:
					somalia.set_tag("对华贸易", true)
				_start_war_376(550 + num, 450 - num, 1, 0)
			2:
				context["result_text"] = tr(TXT_R2_NEUTRAL)
				_start_war_376(400 + num, 600 - num, 1, 0)


func _start_war_376(infl1: int, infl2: int, usa_side: int, ussr_side: int) -> void:
	game.start_war(15, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > 15 and ws.wars[15] != null:
		ws.wars[15].name_war = tr(TXT_WAR_NAME)
		ws.wars[15].fortnight_max = 16




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0










# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_376_ogaden_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_376",
	"num": 376,
	"priority": 37600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_376_ogaden_war.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
