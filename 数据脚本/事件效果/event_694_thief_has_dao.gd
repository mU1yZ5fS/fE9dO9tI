extends "res://数据脚本/event_script_base.gd"

## 原作 Event694.cs：盗亦有道（窃国者侯 Decision 触发，六选项）。
## 触发：GlobalScript.cs:70 Decision「窃国者侯」→ decision_catalog.gd d50
##   （HasLeaderAsset(50)+非毛主义+非第四国际+非农联+每月一次），d50.effects 已 start_event(694)。
## 差异：MoneyLevel→ws.money_level、LeaderAsset→ws.leader_asset；
##   completedDecisions[50]=false → ws.decisions.completed[50]=false（result5）。

const TXT_OPT0_A := "event.script.event_694_thief_has_dao.c0"
const TXT_OPT0_B := "event.script.event_694_thief_has_dao.c1"
const TXT_OPT1_A := "event.script.event_694_thief_has_dao.c2"
const TXT_OPT1_B := "event.script.event_694_thief_has_dao.c3"
const TXT_R0 := "event.script.event_694_thief_has_dao.c4"
const TXT_R1_FMT := "event.script.event_694_thief_has_dao.c5"
const TXT_R2_FMT := "event.script.event_694_thief_has_dao.c6"
const TXT_R3_FMT := "event.script.event_694_thief_has_dao.c7"
const TXT_R4_FMT := "event.script.event_694_thief_has_dao.c8"
const TXT_R5 := "event.script.event_694_thief_has_dao.c9"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 6:
		return
	var econ := _res(W.I_ECON_SYSTEM)
	var opt := event_def.options
	_enable(opt[0], tr(TXT_OPT0_A) if econ < 14 else tr(TXT_OPT0_B))
	_enable(opt[1], tr(TXT_OPT1_A) if econ < 15 else tr(TXT_OPT1_B))
	_enable(opt[2], event_def.options[2].text)
	_enable(opt[3], event_def.options[3].text)
	_enable(opt[4], event_def.options[4].text)
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader := "华国锋"
	if ws.leader != null and ws.leader.name_display != "":
		leader = ws.leader.name_display
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			ws.money_level += 1
			ws.leader_asset += 50
			_add(W.I_LIVING, -150)
			_add(W.I_AGRICULTURE, -100)
			_add(W.I_INDUSTRY, -50)
			_add(W.I_SERVICES, -50)
			_add(W.I_CORRUPTION, 50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_set_mod_active(65)
		1:
			context["result_text"] = tr(TXT_R1_FMT).replace("{0}{1}", leader)
			ws.money_level += 2
			ws.leader_asset += 100
			_add(W.I_LIVING, -100)
			_add(W.I_AGRICULTURE, -150)
			_add(W.I_INDUSTRY, -150)
			_add(W.I_SERVICES, -100)
			_add(W.I_CORRUPTION, 100)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, -150)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_set_mod_active(65)
		2:
			context["result_text"] = tr(TXT_R2_FMT).replace("{0}{1}", leader)
			ws.money_level += 3
			ws.leader_asset += 150
			_add(W.I_LIVING, -250)
			_add(W.I_AGRICULTURE, -150)
			_add(W.I_INDUSTRY, -150)
			_add(W.I_SERVICES, -150)
			_add(W.I_CORRUPTION, 150)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -250)
			_add(W.I_THOUGHT_FREEDOM, 200)
			_set_mod_active(65)
		3:
			context["result_text"] = tr(TXT_R3_FMT).replace("{0}{1}", leader)
			ws.money_level += 4
			ws.leader_asset += 200
			_add(W.I_LIVING, -100)
			_add(W.I_AGRICULTURE, -250)
			_add(W.I_INDUSTRY, -250)
			_add(W.I_SERVICES, -250)
			_add(W.I_CORRUPTION, 250)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -300)
			_add(W.I_THOUGHT_FREEDOM, 250)
			_set_mod_active(65)
		4:
			context["result_text"] = tr(TXT_R4_FMT).replace("{0}{1}", leader)
			ws.money_level += 5
			ws.leader_asset += 250
			_add(W.I_LIVING, -250)
			_add(W.I_AGRICULTURE, -250)
			_add(W.I_INDUSTRY, -250)
			_add(W.I_SERVICES, -250)
			_add(W.I_CORRUPTION, 300)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -350)
			_add(W.I_THOUGHT_FREEDOM, 300)
			_set_mod_active(65)
		5:
			context["result_text"] = tr(TXT_R5)
			# 原版 completedDecisions[50]=false：允许决议再次出现。
			if ws.decisions != null:
				while ws.decisions.completed.size() <= 50:
					ws.decisions.completed.append(false)
				ws.decisions.completed[50] = false


func _set_mod_active(index: int) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_694_thief_has_dao.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_694",
	"num": 694,
	"priority": 69400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_694_thief_has_dao.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
