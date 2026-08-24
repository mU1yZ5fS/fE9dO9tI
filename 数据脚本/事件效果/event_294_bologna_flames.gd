## 原作 Event294.cs：博洛尼亚烈火（博洛尼亚惨案，四选项）。
## 触发：全目录搜索无 this_num_event = 294 / Reset(294)；链外 REST 段，原版无自动条件。
## 差异：result0/1 原版 string.Format 但未使用 {0}{1}，按无占位符逐字处理。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "event.script.event_294_bologna_flames.c0"
const TXT_OPT2_DIS := "event.script.event_294_bologna_flames.c1"
const TXT_R0 := "event.script.event_294_bologna_flames.c2"
const TXT_R1 := "event.script.event_294_bologna_flames.c3"
const TXT_R2 := "event.script.event_294_bologna_flames.c4"
const TXT_R3 := "event.script.event_294_bologna_flames.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var diplo := world.diplomatic_reputation if world.size() > W.I_DIPLO else 0
	var war := world.war_support if world.size() > W.I_WAR_SUPPORT else 0
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if line < 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line <= 3 and diplo >= 900 and war > 300:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -30)
			_add(182, 1)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -40)
			_add(W.I_AGENTS, -60)
			_add(176, 1)
			_add(177, -999)
			_add(182, 2)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -80)
			if italy != null:
				italy.level_of_development -= 5
			_add(134, 10)
			_add(177, 1)
			_add(182, 2)
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	PoliticianSystem.copy_leader_appearance(ws.leader, p)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_294_bologna_flames.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_294",
	"num": 294,
	"priority": 29400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_294_bologna_flames.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
