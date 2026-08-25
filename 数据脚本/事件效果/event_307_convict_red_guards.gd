## 原作 Event307.cs：定罪红卫兵（红卫兵平反，三选项）。
## 触发：全目录搜索无 this_num_event = 307 / Reset(307)；链外 REST 段，原版无自动条件。
## 差异：modifies[3].active→_mod_active(3)，动态 description 在 prepare 切换；party_number[0]→factions[0].support；
##  traits[0]→trait_personality；文本来自 Events_text_en 索引 77-84 与 Event307.cs 内联。
extends "res://数据脚本/event_script_base.gd"

const TXT_DESC_INACTIVE := "event.script.event_307_convict_red_guards.c0"
const TXT_DESC_ACTIVE := "event.script.event_307_convict_red_guards.c1"
const TXT_OPT2_DIS := "event.script.event_307_convict_red_guards.c2"
const TXT_R0 := "event.script.event_307_convict_red_guards.c3"
const TXT_R1 := "event.script.event_307_convict_red_guards.c4"
const TXT_R2 := "event.script.event_307_convict_red_guards.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var mod3 := _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION)
	if mod3:
		event_def.description = tr(TXT_DESC_ACTIVE)
	else:
		event_def.description = tr(TXT_DESC_INACTIVE)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	if mod3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 15)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, -15)
			_add(W.I_THOUGHT_FREEDOM, 50)
			context["result_text"] = tr(TXT_R1)
		2:
			if ws.factions.size() > 0 and ws.factions[0] != null:
				ws.factions[0].support += 300
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, 100)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT and p.trait_personality != GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty -= 500
					p.power -= 500
				elif p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty -= 100
			_set_mod_active(32, true)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_307_convict_red_guards.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_307",
	"num": 307,
	"priority": 30700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_307_convict_red_guards.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
