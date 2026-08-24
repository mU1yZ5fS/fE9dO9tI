## 原作 Event295.cs：复仇女神（莫罗新政府，三选项）。
## 触发：全目录搜索无 this_num_event = 295 / Reset(295)；链外 REST 段，原版无自动条件。
## 差异：结果前全局 allcountries[85].Vyshi=false 已复刻；resultOfEvents[291] 缺省按原版 int 0 处理。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "event.script.event_295_italy_nemesis.c0"
const TXT_OPT2_DIS := "event.script.event_295_italy_nemesis.c1"
const TXT_R0 := "event.script.event_295_italy_nemesis.c2"
const TXT_R1 := "event.script.event_295_italy_nemesis.c3"
const TXT_R2 := "event.script.event_295_italy_nemesis.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var budget := world.budget if world.size() > W.I_BUDGET else 0
	var reserve := world.reserve if world.size() > W.I_RESERVE else 0
	var agents := world.agents if world.size() > W.I_AGENTS else 0
	var army := world.army if world.size() > W.I_ARMY else 0
	var italy := world.get_country_by_legacy_index(85)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if budget + reserve >= 80 and agents >= 50:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if budget + reserve >= 40 and army >= 35 and italy != null and italy.内战中:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	if italy != null:
		italy.set_tag("亲美", false)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -50)
			_add(182, 2)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_AGENTS, -40)
			_add(W.I_ARMY, -35)
			if italy != null:
				italy.level_of_development -= 5
			_add(134, 15)
			var res291 := int(ws.completed_event_ids.get("event_291", 0))
			if ws.completed_event_ids.has("event_291") and res291 < 3:
				_add(172 + res291, 1)
				if res291 == 0:
					_add(172 + res291, 1)
			_add(182, 1)
			context["result_text"] = tr(TXT_R2)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_295_italy_nemesis.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_295",
	"num": 295,
	"priority": 29500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_295_italy_nemesis.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
