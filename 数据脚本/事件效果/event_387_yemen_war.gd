extends "res://数据脚本/event_script_base.gd"

## 原作 Event387.cs：两个也门间的战争？（四选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DESC_PROPRC := "event.script.event_387_yemen_war.c0"
const TXT_DIS_AGENTS := "event.script.event_387_yemen_war.c1"
const TXT_DIS_ARMY := "event.script.event_387_yemen_war.c2"
const TXT_DIS_BETRAY_N := "event.script.yemen_war.txt_dis_betray_n"
const TXT_DIS_BETRAY_S := "event.script.yemen_war.txt_dis_betray_s"
const TXT_DIS_TALK := "event.script.event_387_yemen_war.c3"
const TXT_R0 := "event.script.event_387_yemen_war.c4"
const TXT_R1 := "event.script.event_387_yemen_war.c5"
const TXT_R2 := "event.script.event_387_yemen_war.c6"
const TXT_R3 := "event.script.event_387_yemen_war.c7"
const TXT_NAME_YEMEN := "event.script.event_387_yemen_war.c8"
const TXT_WAR_NAME := "event.script.event_387_yemen_war.c9"
const TXT_WAR_ATT := "event.script.event_387_yemen_war.c10"
const TXT_WAR_DEF := "event.script.event_387_yemen_war.c11"


const TXT_LABEL_BUDGET := "event.script.event_387_yemen_war.c12"
const TXT_LABEL_AGENTS := "event.script.event_387_yemen_war.c13"
const TXT_LABEL_ARMY := "event.script.event_387_yemen_war.c14"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var south := world.get_country_by_legacy_index(24)
	var north := world.get_country_by_legacy_index(25)
	if south != null and south.has_tag("亲中"):
		event_def.description = tr(TXT_DESC_PROPRC)
	var opt := event_def.options
	_prepare_yemen(opt[0], event_def.options[0].text, south != null and south.has_tag("亲中"), tr(TXT_DIS_BETRAY_N))
	_prepare_yemen(opt[1], event_def.options[1].text, north != null and north.has_tag("亲中"), tr(TXT_DIS_BETRAY_S))
	if north != null and north.has_tag("亲中") and south != null and south.has_tag("亲中"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_DIS_TALK))
	_enable(opt[3], event_def.options[3].text)


func _prepare_yemen(opt: EventOption, text: String, is_proprc: bool, dis_betray: String) -> void:
	if _d(W.I_AGENTS) >= 50 and _d(W.I_ARMY) >= 100:
		if not is_proprc:
			_enable(opt, text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
		else:
			_disable(opt, dis_betray)
	elif _d(W.I_AGENTS) < 50:
		_disable(opt, tr(TXT_DIS_AGENTS).format([5]))
	else:
		_disable(opt, tr(TXT_DIS_ARMY).format([10]))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var south := ws.get_country_by_legacy_index(24)
	var north := ws.get_country_by_legacy_index(25)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(143, 1)  # 原版 data.oil_price
			_start_war_387(600, 400)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_DIPLO, 10)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(143, 1)  # 原版 data.oil_price
			_start_war_387(400, 600)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, 10)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
		2:
			context["result_text"] = tr(TXT_R2)
			if north != null:
				_leave_alliances(north)
			if south != null:
				if south.parts.size() < 1:
					south.parts.resize(1)
				south.parts[0] = true
				south.set_tag("亲中", true)
				south.government = GameConstants.Government.SOCIALIST
				south.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				south.set_tag("对华贸易", true)
				south.name = tr(TXT_NAME_YEMEN)
				south.chinese_name = tr(TXT_NAME_YEMEN)
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -40)
			ws.influence_prc += 20
			# 也门已统一（建成联邦）：置标志，供事件 498/437 的触发守卫读取（.tres NOT_HAS_FLAG）
			ws.set_flag("yemen_unified", true)
		_:
			context["result_text"] = tr(TXT_R3)


func _start_war_387(infl1: int, infl2: int) -> void:
	game.start_war(21, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), infl1, infl2, 0, 1)
	if ws.wars.size() > 21 and ws.wars[21] != null:
		ws.wars[21].name_war = tr(TXT_WAR_NAME)
		ws.wars[21].fortnight_max = 20



func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0








# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_387_yemen_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_387",
	"num": 387,
	"priority": 38700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_387_yemen_war.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
