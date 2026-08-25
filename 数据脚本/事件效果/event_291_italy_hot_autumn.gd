## 原作 Event291.cs：秋风萧瑟，洪波涌起（意大利极左翼整合，五选项）。
## 触发：全目录搜索无 this_num_event = 291 / Reset(291)；链外 REST 段，原版无自动条件。
## 差异：选项显隐 prepare 动态改写；data.get_data_by_index(172..183) 等原版无命名索引用 raw index + 注释。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT0_DIS := "event.script.event_291_italy_hot_autumn.c0"
const TXT_OPT1_DIS := "event.script.event_291_italy_hot_autumn.c1"
const TXT_OPT2_DIS := "event.script.event_291_italy_hot_autumn.c2"
const TXT_OPT3_DIS := "event.script.event_291_italy_hot_autumn.c3"
const TXT_R2 := "event.script.event_291_italy_hot_autumn.c4"
const TXT_R2_ALB := "event.script.event_291_italy_hot_autumn.c5"
const TXT_R0 := "event.script.event_291_italy_hot_autumn.c6"
const TXT_R1 := "event.script.event_291_italy_hot_autumn.c7"
const TXT_R3 := "event.script.event_291_italy_hot_autumn.c8"
const TXT_R4 := "event.script.event_291_italy_hot_autumn.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var war := world.war_support if world.size() > W.I_WAR_SUPPORT else 0
	var diplo := world.diplomatic_reputation if world.size() > W.I_DIPLO else 0
	var opt := event_def.options
	if line <= 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line <= 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if war > 300 and line <= 3 and diplo >= 900:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -50)
			_add(W.I_ARMY, -50)
			_add(W.I_DIPLO, 10)
			_add(172, 4)
			if italy != null:
				italy.level_of_development -= 20
			_add(134, 40)
			if italy != null:
				italy.内战中 = true
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -60)
			_add(W.I_BUDGET, -100)
			_add(W.I_ARMY, -40)
			_add(W.I_DIPLO, 10)
			_add(173, 2)
			if italy != null:
				italy.level_of_development -= 20
			_add(134, 40)
			if italy != null:
				italy.内战中 = true
			context["result_text"] = tr(TXT_R1)
		2:
			if albania != null and albania.has_tag("亲中"):
				_add(W.I_AGENTS, -100)
				_add(W.I_BUDGET, -100)
				_add(W.I_DIPLO, 20)
				_add(174, 2)
				if italy != null:
					italy.level_of_development -= 15
				_add(134, 30)
				context["result_text"] = tr(TXT_R2_ALB)
			else:
				_add(W.I_AGENTS, -125)
				_add(W.I_BUDGET, -125)
				_add(W.I_ARMY, -50)
				_add(W.I_DIPLO, 20)
				_add(174, 2)
				if italy != null:
					italy.level_of_development -= 15
				_add(134, 30)
				context["result_text"] = tr(TXT_R2)
			if italy != null:
				italy.内战中 = true
		3:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -100)
			_add(W.I_ARMY, -50)
			_add(W.I_DIPLO, 10)
			_add(175, 1)
			_add(177, 2)
			_add(182, 2)
			if italy != null:
				italy.level_of_development -= 10
			_add(134, 40)
			if italy != null:
				italy.政变中 = true
			context["result_text"] = tr(TXT_R3)
		4:
			if italy != null:
				italy.level_of_development += 5
			context["result_text"] = tr(TXT_R4)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_291_italy_hot_autumn.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_291",
	"num": 291,
	"priority": 29100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_291_italy_hot_autumn.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
