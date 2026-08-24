extends "res://数据脚本/event_script_base.gd"

## 原作 Event112.cs：来自0和1的冲击（IECS 网络攻击，三选项）。
## 触发：TimeScript.cs:10971-10977 —— modifies[11].active && c1.okb
##   && 年>=1984 && event_done[110]。
## 差异：
##  - 文案与选项按 event_done[494] && resultOfEvents[494]==0 双分支（prepare/结果）。
##  - r2 的 load_scene_after_click → Ending6：Godot 设 d.ending_route=6。
##  - relres → global flag；modifies[3]/[11] → modifiers 槽 active。
##  - data12/13/68 → 工业/农业/服务业产值。


const TXT_DESC_494 := "event.script.event_112_cyber_attack.c0"

const TXT_DESC_OTHER := "event.script.event_112_cyber_attack.c1"

const TXT_OPT0_494 := "event.script.event_112_cyber_attack.c2"
const TXT_OPT0_OTHER := "event.script.event_112_cyber_attack.c3"
const TXT_OPT1_494 := "event.script.event_112_cyber_attack.c4"
const TXT_OPT1_OTHER := "event.script.event_112_cyber_attack.c5"
const TXT_OPT1_DIS := "event.script.event_112_cyber_attack.c6"
const TXT_OPT2_DIS := "event.script.event_112_cyber_attack.c7"

const TXT_R0_494 := "event.script.event_112_cyber_attack.c8"
const TXT_R0_OTHER := "event.script.event_112_cyber_attack.c9"
const TXT_R1_494 := "event.script.event_112_cyber_attack.c10"
const TXT_R1_OTHER := "event.script.event_112_cyber_attack.c11"
const TXT_R2 := "event.script.event_112_cyber_attack.c12"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var is_494 := _is_494_route(world)
	event_def.description = tr(TXT_DESC_494) if is_494 else tr(TXT_DESC_OTHER)

	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var ussr_rel := world.empires[EmpireData.USSR].relations if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null else 0
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	_enable(opt[0], tr(TXT_OPT0_494) if is_494 else tr(TXT_OPT0_OTHER))
	if ussr_rel >= 800 and world.get_flag("relres") and mod3:
		_enable(opt[1], tr(TXT_OPT1_494) if is_494 else tr(TXT_OPT1_OTHER))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if (line > 0 and party < 8) or (coal > 66 and party > 7):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var is_494 := _is_494_route(ws)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if is_494:
				_add(W.I_BUDGET, -10)
				_add(W.I_PEOPLE_SUPPORT, -50)
				_add(W.I_THOUGHT_FREEDOM, 100)
				_add(W.I_PARTY_SUPPORT, -300)
				_add(W.I_LIVING, -30)
				_add(W.I_INDUSTRY, -50)
				_add(W.I_AGRICULTURE, -50)
				_add(W.I_SERVICES, -50)
				context["result_text"] = tr(TXT_R0_494)
			else:
				_add(W.I_BUDGET, -250)
				_add(W.I_PEOPLE_SUPPORT, -150)
				_add(W.I_THOUGHT_FREEDOM, 300)
				_add(W.I_PARTY_SUPPORT, -300)
				_add(W.I_LIVING, -100)
				_add(W.I_INDUSTRY, -200)
				_add(W.I_AGRICULTURE, -200)
				_add(W.I_SERVICES, -200)
				context["result_text"] = tr(TXT_R0_OTHER)
		1:
			if is_494:
				_add(W.I_BUDGET, -10)
				_add(W.I_PEOPLE_SUPPORT, -50)
				_add(W.I_THOUGHT_FREEDOM, 100)
				_add(W.I_PARTY_SUPPORT, -300)
				_add(W.I_LIVING, -30)
				context["result_text"] = tr(TXT_R1_494)
			else:
				_add(W.I_BUDGET, -250)
				_add(W.I_PEOPLE_SUPPORT, -150)
				_add(W.I_THOUGHT_FREEDOM, 300)
				_add(W.I_PARTY_SUPPORT, -300)
				_add(W.I_LIVING, -100)
				context["result_text"] = tr(TXT_R1_OTHER)
		2:
			_add(W.I_BUDGET, -250)
			_add(W.I_PEOPLE_SUPPORT, -300)
			_add(W.I_THOUGHT_FREEDOM, 500)
			if d.size() > W.I_ECON_SYSTEM:
				d.econ_system = 10
			_add(W.I_LIVING, -100)
			_add(W.I_INDUSTRY, -200)
			_add(W.I_AGRICULTURE, -200)
			_add(W.I_SERVICES, -200)
			if ws.modifiers.size() > 11 and ws.modifiers[11] != null:
				ws.modifiers[11].is_active = false
			if d.size() > W.I_PARTY_SUPPORT:
				d.party_support = 0
			if d.size() > W.I_PEOPLE_SUPPORT:
				d.people_support = 0
			if d.size() > W.I_ENDING_ROUTE:
				d.ending_route = 6
			# 原 Event112.cs:164：data.ending_route=6 + load_scene_after_click。
			game.queue_ending_after_event(6)
			context["result_text"] = tr(TXT_R2)


func _is_494_route(world: WorldState) -> bool:
	if world == null:
		return false
	return world.completed_event_ids.has("event_494") and int(world.completed_event_ids.get("event_494", -1)) == 0


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_112_cyber_attack.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_112",
	"num": 112,
	"priority": 11200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_112_cyber_attack.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "MODIFIER_ACTIVE", "key": "11"}, {"t": "COUNTRY_HAS_TAG", "key": "okb", "target": "1"}, {"t": "DATE_AFTER", "key": "1984.1.1"}, {"t": "PREV_EVENT_DONE", "ref": "event_110"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
