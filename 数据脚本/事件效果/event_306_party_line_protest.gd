## 原作 Event306.cs：对党的领导路线的抗议（抗议路线，三选项）。
## 触发：全目录搜索无 this_num_event = 306 / Reset(306)；链外 REST 段，原版无自动条件。
## 差异：NumberOfPolitician(15,15)→_find_politician；event_done/resultOfEvents[444]→completed_event_ids；
##  modifies[3/65].active→_set_mod_active；显示字段跳过；文本来自 Events_text_en 索引 69-76（禁用项复用 index 52）。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT2_DIS := "event.script.event_306_party_line_protest.c0"
const TXT_R0 := "event.script.event_306_party_line_protest.c1"
const TXT_R1 := "event.script.event_306_party_line_protest.c2"
const TXT_R2 := "event.script.event_306_party_line_protest.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var p15 := _find_politician(15, 15)
	var ev444_done := world.completed_event_ids.has("event_444")
	var ev444_res := int(world.completed_event_ids.get("event_444", 0))
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	if p15 >= 0 and (not ev444_done or ev444_res != 0):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PEOPLE_SUPPORT, -100)
			context["result_text"] = tr(TXT_R0)
		1:
			var num := _find_politician(15, 15)
			if num >= 0:
				game.kill_politician(num)
			context["result_text"] = tr(TXT_R1)
		2:
			var num2 := _find_politician(15, 15)
			_add(W.I_PARTY_SUPPORT, -250)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 250)
			_add(W.I_AGENTS, -50)
			_add(W.I_DIPLO, -150)
			_set_mod_active(3, false)
			_add_relation(EmpireData.USA, 100)
			if num2 >= 0 and num2 < ws.politicians.size():
				var p := ws.politicians[num2]
				if p != null:
					_set_leader_from(p)
					game.kill_politician(num2)
					_set_mod_active(65, false)
			# LeaderAsset/MoneyLevel/ServeRMB 为显示字段，跳过
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_306_party_line_protest.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_306",
	"num": 306,
	"priority": 30600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_306_party_line_protest.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
