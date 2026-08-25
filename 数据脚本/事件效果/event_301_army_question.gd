## 原作 Event301.cs：军队问题？（中越战争后军队现代化，三选项）。
## 触发：全目录搜索无 this_num_event = 301 / Reset(301)；链外 REST 段，原版无自动条件。
## 差异：data.usa_relations 用 W.I_USA_RELATIONS；文本来自 Events_text_en 索引 30-39。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "event.script.event_301_army_question.c0"
const TXT_OPT2_DIS := "event.script.event_301_army_question.c1"
const TXT_R0 := "event.script.event_301_army_question.c2"
const TXT_R1 := "event.script.event_301_army_question.c3"
const TXT_R2 := "event.script.event_301_army_question.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var budget := world.budget if world.size() > W.I_BUDGET else 0
	var reserve := world.reserve if world.size() > W.I_RESERVE else 0
	var industry := world.industry if world.size() > W.I_INDUSTRY else 0
	var usa_rel := world.usa_relations if world.size() > W.I_USA_RELATIONS else 0
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if budget + reserve >= 50 and industry >= 500:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if usa_rel >= 700 and budget + reserve >= 80:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -300)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -30)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -60)
			_add_relation(EmpireData.USA, 120)
			_add_relation(EmpireData.USSR, -200)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_301_army_question.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_301",
	"num": 301,
	"priority": 30100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_301_army_question.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
