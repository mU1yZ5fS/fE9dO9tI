## 原作 Event308.cs：大圈（港澳犯罪集团合作，两选项）。
## 触发：全目录搜索无 this_num_event = 308 / Reset(308)；链外 REST 段，原版无自动条件。
## 差异：modifies[3].active→_mod_active(3)；party_number[0]→factions[0].support；
##  禁用项文本按 data.political_line>2 / 预算+储备<50 两分支复刻；文本来自 Events_text_en 索引 85-91、122 与 Event308.cs 内联。
extends "res://数据脚本/event_script_base.gd"

const TXT_DESC_INACTIVE := "event.script.event_308_big_circle.c0"
const TXT_DESC_ACTIVE := "event.script.event_308_big_circle.c1"
const TXT_OPT1_DIS_LINE := "event.script.event_308_big_circle.c2"
const TXT_OPT1_DIS_BUDGET := "event.script.event_308_big_circle.c3"
const TXT_R0 := "event.script.event_308_big_circle.c4"
const TXT_R1 := "event.script.event_308_big_circle.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var mod3 := _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION)
	if mod3:
		event_def.description = tr(TXT_DESC_ACTIVE)
	else:
		event_def.description = tr(TXT_DESC_INACTIVE)
	var budget := world.budget if world.size() > W.I_BUDGET else 0
	var reserve := world.reserve if world.size() > W.I_RESERVE else 0
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if budget + reserve >= 50 and line <= 2:
		_enable(opt[1], event_def.options[1].text)
	elif line > 2:
		_disable(opt[1], tr(TXT_OPT1_DIS_LINE))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_BUDGET))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_INFLUENCE, 100)
			_add(W.I_BUDGET, -30)
			if ws.factions.size() > 0 and ws.factions[0] != null:
				ws.factions[0].support += 50
			context["result_text"] = tr(TXT_R1)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_308_big_circle.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_308",
	"num": 308,
	"priority": 30800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_308_big_circle.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
