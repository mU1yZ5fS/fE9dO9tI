## 原作 Event298.cs：回扣之国（意大利净手行动，单选项）。
## 触发：全目录搜索无 this_num_event = 298 / Reset(298)；链外 REST 段，原版无自动条件。
## 差异：VasilyisGay→ws.get_flag("VasilyisGay")；load_scene_after_click+number_event=299
##  改为 EventEngine.enqueue_chain(["event_299"])；spec→special；inflCh→influence_china。
extends "res://数据脚本/event_script_base.gd"

const TXT_R0_BASE := "event.script.event_298_italy_kickbacks.c0"
const TXT_R0_INFL := "event.script.event_298_italy_kickbacks.c1"
const TXT_R0_VASILY := "event.script.event_298_italy_kickbacks.c2"
const TXT_R0_NEUTRAL := "event.script.event_298_italy_kickbacks.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 1:
		return
	_enable(event_def.options[0], event_def.options[0].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	if portugal != null:
		portugal.special -= 5
	_add(175, -999)
	var text := tr(TXT_R0_BASE)
	if italy != null and italy.influence_china > 0:
		text += tr(TXT_R0_INFL)
		if italy != null:
			italy.government = GameConstants.Government.REFORMIST
			italy.sub_government = GameConstants.SubGovernment.PRAGMATIST
			italy.set_tag("亲美", false)
			italy.set_tag("eu", false)
			italy.set_tag("nato", false)
	elif ws.get_flag("VasilyisGay"):
		text += tr(TXT_R0_VASILY)
		_add(177, 3)
		EventEngine.enqueue_chain(["event_299"])
	else:
		text += tr(TXT_R0_NEUTRAL)
		_add(177, 3)
		EventEngine.enqueue_chain(["event_299"])
	context["result_text"] = text




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_298_italy_kickbacks.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_298",
	"num": 298,
	"priority": 29800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_298_italy_kickbacks.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
