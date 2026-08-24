extends "res://数据脚本/event_script_base.gd"

## 原作 Event383.cs：新查梅尼亚（阿尔巴尼亚-希腊，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DIS_BUDGET := "event.script.event_383_new_chameria.c0"
const TXT_DIS_AGENTS := "event.script.event_383_new_chameria.c1"
const TXT_DIS_MOD := "event.script.event_383_new_chameria.c2"
const TXT_DIS_INFLUENCE := "event.script.event_383_new_chameria.c3"
const TXT_R0 := "event.script.event_383_new_chameria.c4"
const TXT_R1 := "event.script.event_383_new_chameria.c5"
const TXT_R2 := "event.script.event_383_new_chameria.c6"
const TXT_WAR_NAME := "event.script.event_383_new_chameria.c7"
const TXT_WAR_ATT := "event.script.event_383_new_chameria.c8"
const TXT_WAR_DEF := "event.script.event_383_new_chameria.c9"


const TXT_LABEL_BUDGET := "event.script.event_383_new_chameria.c10"
const TXT_LABEL_AGENTS := "event.script.event_383_new_chameria.c11"
const TXT_LABEL_ARMY := "event.script.event_383_new_chameria.c12"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if _d(W.I_AGENTS) >= 350:
		_enable(opt[1], event_def.options[1].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	else:
		_disable(opt[1], tr(TXT_DIS_AGENTS).format([20]))
	var mod6: bool = ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active
	if _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 250 and _d(W.I_AGENTS) >= 150 and _d(W.I_INFLUENCE) >= 700 			and (mod6 or game.is_faction_leading(0)):
		_enable(opt[2], event_def.options[2].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif not mod6 and not game.is_faction_leading(0):
		_disable(opt[2], tr(TXT_DIS_MOD))
	elif _d(W.I_INFLUENCE) < 700:
		_disable(opt[2], tr(TXT_DIS_INFLUENCE).format([30]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt[2], tr(TXT_DIS_BUDGET).format([25]))
	else:
		_disable(opt[2], tr(TXT_DIS_AGENTS).format([15]))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_start_war_383(500, 500, -1, -1)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_DIPLO, -50)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, 50)
			_add(W.I_AGENTS, -350)
			if albania != null:
				_leave_alliances(albania)
				albania.set_tag("亲中", false)
				albania.set_tag("对华贸易", false)
		_:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_DIPLO, 100)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, -250)
			_add_power(EmpireData.USA, -50)
			_add_power(EmpireData.USSR, -50)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -250)
			_start_war_383(600, 400, 1, 1)


func _start_war_383(infl1: int, infl2: int, usa_side: int, ussr_side: int) -> void:
	game.start_war(19, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > 19 and ws.wars[19] != null:
		ws.wars[19].name_war = tr(TXT_WAR_NAME)
		ws.wars[19].fortnight_max = 11



func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0










# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_383_new_chameria.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_383",
	"num": 383,
	"priority": 38300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_383_new_chameria.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
