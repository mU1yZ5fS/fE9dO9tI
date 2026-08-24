## 原作 Event292.cs：“萨莱诺转向”对“意大利社会主义”（意大利社会党/共产党论战，四选项）。
## 触发：全目录搜索无 this_num_event = 292 / Reset(292)；链外 REST 段，原版无自动条件。
## 差异：选项3 原版条件 IsAuthoritarianism(55)/puppetOf<0 按原样复刻（55=突尼斯，原版如此）。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "event.script.event_292_italy_salerno_turn.c0"
const TXT_OPT2_DIS := "event.script.event_292_italy_salerno_turn.c1"
const TXT_OPT3_DIS := "event.script.event_292_italy_salerno_turn.c2"
const TXT_R0 := "event.script.event_292_italy_salerno_turn.c3"
const TXT_R1 := "event.script.event_292_italy_salerno_turn.c4"
const TXT_R2 := "event.script.event_292_italy_salerno_turn.c5"
const TXT_R3 := "event.script.event_292_italy_salerno_turn.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var tunisia := world.get_country_by_legacy_index(55)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if line >= 2 and line <= 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line <= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if tunisia != null and world.is_authoritarian(tunisia) and tunisia.puppet_of < 0 and line >= 3:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -40)
			_add(W.I_BUDGET, -80)
			_add(176, 1)
			_add(179, 1)
			_add(172, -1)
			_add(173, -2)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -20)
			_add(176, -2)
			_add(172, 1)
			_add(173, 2)
			_add(134, 20)
			if italy != null:
				italy.内战中 = true
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_BUDGET, -100)
			_add(176, -2)
			_add(181, 1)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_292_italy_salerno_turn.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_292",
	"num": 292,
	"priority": 29200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_292_italy_salerno_turn.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
