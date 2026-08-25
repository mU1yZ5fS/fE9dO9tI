extends "res://数据脚本/event_script_base.gd"

## 原作 Event382.cs：南阿战争（阿尔巴尼亚-南斯拉夫，四选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DIS_BUDGET := "event.script.event_382_albania_yugoslavia.c0"
const TXT_DIS_AGENTS := "event.script.event_382_albania_yugoslavia.c1"
const TXT_DIS_INFLUENCE := "event.script.event_382_albania_yugoslavia.c2"
const TXT_DIS_ALBANIA := "event.script.event_382_albania_yugoslavia.c3"
const TXT_DIS_ECON := "event.script.event_382_albania_yugoslavia.c4"
const TXT_DIS_COND := "event.script.event_382_albania_yugoslavia.c5"
const TXT_R0 := "event.script.event_382_albania_yugoslavia.c6"
const TXT_R1_OK := "event.script.event_382_albania_yugoslavia.c7"
const TXT_R1_BAD := "event.script.event_382_albania_yugoslavia.c8"
const TXT_R2 := "event.script.event_382_albania_yugoslavia.c9"
const TXT_R3 := "event.script.event_382_albania_yugoslavia.c10"
const TXT_WAR_NAME := "event.script.event_382_albania_yugoslavia.c11"
const TXT_WAR_ATT := "event.script.event_382_albania_yugoslavia.c12"
const TXT_WAR_DEF := "event.script.event_382_albania_yugoslavia.c13"


const TXT_LABEL_BUDGET := "event.script.event_382_albania_yugoslavia.c14"
const TXT_LABEL_AGENTS := "event.script.event_382_albania_yugoslavia.c15"
const TXT_LABEL_ARMY := "event.script.event_382_albania_yugoslavia.c16"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var albania := world.get_country_by_legacy_index(20)
	var china := world.get_country_by_legacy_index(1)
	var usa := world.get_country_by_legacy_index(51)
	var opt := event_def.options
	if world.influence_prc >= 300 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 200 and _d(W.I_AGENTS) >= 200:
		_enable(opt[0], event_def.options[0].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 200:
		_disable(opt[0], tr(TXT_DIS_BUDGET).format([20]))
	elif _d(W.I_AGENTS) < 200:
		_disable(opt[0], tr(TXT_DIS_AGENTS).format([20]))
	else:
		_disable(opt[0], tr(TXT_DIS_INFLUENCE).format([30]))
	if albania != null and albania.has_tag("亲中") and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 30 and _d(W.I_AGENTS) >= 30:
		_enable(opt[1], event_def.options[1].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt[1], tr(TXT_DIS_BUDGET).format([3]))
	elif _d(W.I_AGENTS) < 30:
		_disable(opt[1], tr(TXT_DIS_AGENTS).format([3]))
	else:
		_disable(opt[1], tr(TXT_DIS_ALBANIA))
	if world.influence_prc >= 300 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 150 and _d(W.I_AGENTS) >= 300 			and china != null and china.has_tag("econ") 			and (world.get_flag("relres") or (usa != null and usa.has_tag("对华贸易"))) 			and albania != null and albania.has_tag("亲中"):
		_enable(opt[2], event_def.options[2].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif china == null or not china.has_tag("econ"):
		_disable(opt[2], tr(TXT_DIS_ECON))
	elif world.influence_prc < 300:
		_disable(opt[2], tr(TXT_DIS_INFLUENCE).format([30]))
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 150:
		_disable(opt[2], tr(TXT_DIS_BUDGET).format([15]))
	elif _d(W.I_AGENTS) < 300:
		_disable(opt[2], tr(TXT_DIS_AGENTS).format([30]))
	else:
		_disable(opt[2], tr(TXT_DIS_COND))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_start_war_382(300, 700, 1, -1)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
		1:
			if _d(W.I_INFLUENCE) >= 300:
				context["result_text"] = tr(TXT_R1_OK)
				_add(W.I_DIPLO, -50)
				_add_relation(EmpireData.USSR, -50)
				_add_relation(EmpireData.USA, 100)
				_add(W.I_AGENTS, -30)
				_add(W.I_BUDGET, -30)
				_add(W.I_INFLUENCE, 10)
			else:
				context["result_text"] = tr(TXT_R1_BAD)
				_add(W.I_DIPLO, -50)
				_add_relation(EmpireData.USSR, -150)
				_add_relation(EmpireData.USA, -150)
				_add(W.I_BUDGET, -30)
				_add(W.I_AGENTS, -30)
				_add(W.I_INFLUENCE, -10)
				_start_war_382(200, 800, 1, 1, 8)  # 原版 TickTime(4)，但 TimeScript WorldWarsDone 对 result382==1 的有效阈值是 8
		2:
			context["result_text"] = tr(TXT_R2)
			var romania := ws.get_country_by_legacy_index(5)
			var albania := ws.get_country_by_legacy_index(20)
			var yugo := ws.get_country_by_legacy_index(15)
			if romania != null:
				romania.set_tag("亲中", true)
			if albania != null:
				albania.set_tag("亲中", true)
			_add(W.I_INFLUENCE, 50)
			_add_power(EmpireData.USSR, -100)
			_add_power(EmpireData.USA, -100)
			_add(W.I_AGENTS, -300)
			_add(W.I_BUDGET, -150)
			_add(W.I_DIPLO, 100)
			if albania != null:
				albania.special = 1
				albania.set_tag("balecon", true)
			if yugo != null:
				yugo.set_tag("balecon", true)
			if romania != null:
				romania.set_tag("balecon", true)
			_add_relation(EmpireData.USA, -200)
			_add_relation(EmpireData.USSR, -200)
		_:
			context["result_text"] = tr(TXT_R3)


func _start_war_382(infl1: int, infl2: int, usa_side: int, ussr_side: int, tick: int = 20) -> void:
	game.start_war(18, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > 18 and ws.wars[18] != null:
		ws.wars[18].name_war = tr(TXT_WAR_NAME)
		ws.wars[18].fortnight_max = tick




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0










# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_382_albania_yugoslavia.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_382",
	"num": 382,
	"priority": 38200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_382_albania_yugoslavia.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
