extends "res://数据脚本/event_script_base.gd"

## 原作 Event111.cs：在幽灵般的灯光下（IECS 反扑，四选项）。
## 触发：TimeScript.cs:10972-10978 —— science[15] && 年>=1983 && modifies[11].active。
## 差异：
##  - 选项显隐 prepare 动态改写；r0 的 load_scene_after_click → Ending6：
##    Godot 设 d.ending_route=6（结局界面后续读取）。
##  - 忠诚<300 杀 3 人循环逐字保留（毛保护/姓名2-2/同领袖性格跳过）。

const TXT_R0 := "event.script.event_111_ghostly_light.c0"

const TXT_R1 := "event.script.event_111_ghostly_light.c1"

const TXT_R2 := "event.script.event_111_ghostly_light.c2"

const TXT_R3 := "event.script.event_111_ghostly_light.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var people := data.people_support if data.size() > W.I_PEOPLE_SUPPORT else 0
	var living := data.living_standard if data.size() > W.I_LIVING else 0
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	_enable(opt[0], "放弃斗争和辞职")
	if people >= 900 and living >= 900 and mod3:
		_enable(opt[1], "号召人民群众反对党阀的统治")
	else:
		_disable(opt[1], "人民已经受够了大鸣大放，你想复辟文革余毒？")
	if agents >= 400:
		_enable(opt[2], "逮捕阴谋者并开始迫害最积极主动的合伙人（需要40特工网络）")
	else:
		_disable(opt[2], "国安部不会支持我们!")
	if (line < 3 and party < 8) or (coal > 66 and party > 7):
		_enable(opt[3], "动员忠诚的军官反对阴谋家")
	else:
		_disable(opt[3], "军官不会拯救我们")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if d.size() > W.I_ENDING_ROUTE:
				d.ending_route = 6
			# 原 Event111.cs:162：load_scene_after_click → data.ending_route=6。
			game.queue_ending_after_event(6)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_DIPLO, 70)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, -400)
			_kill_3_low_loyalty()
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_AGENTS, -400)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_DIPLO, 50)
			_add(W.I_PARTY_SUPPORT, -500)
			_kill_3_low_loyalty()
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_ARMY, -300)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_PARTY_SUPPORT, -500)
			_add(W.I_DIPLO, 50)
			_kill_3_low_loyalty()
			context["result_text"] = tr(TXT_R3).replace("{0}", _leader_name())


## Event111.cs 三结果共同的忠诚<300 杀 3 循环（逐字条件）。
func _kill_3_low_loyalty() -> void:
	var killed := 0
	for i in ws.politicians.size():
		if killed >= 3:
			break
		var p: PoliticianData = ws.politicians[i]
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.loyalty < 300 \
				and not (p.name_first == 2 and p.name_last == 2) \
				and (ws.leader == null or p.trait_personality != ws.leader.trait_personality):
			PoliticianSystem.kill_politician(i)
			killed += 1


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




func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_111_ghostly_light.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_111",
	"num": 111,
	"priority": 11100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_111_ghostly_light.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1983.1.1"}, {"t": "TECH_UNLOCKED", "v": 15}, {"t": "MODIFIER_ACTIVE", "key": "11"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
