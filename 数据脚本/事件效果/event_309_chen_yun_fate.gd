## 原作 Event309.cs：陈云的命运（清算陈云，两选项）。
## 触发：全目录搜索无 this_num_event = 309 / Reset(309)；链外 REST 段，原版无自动条件。
## 差异：KillPerson→game.kill_politician；文本来自 Events_text_en 索引 92-97。
extends "res://数据脚本/event_script_base.gd"

const TXT_R0 := "event.script.event_309_chen_yun_fate.c0"
const TXT_R1 := "event.script.event_309_chen_yun_fate.c1"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	_enable(event_def.options[0], event_def.options[0].text)
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -250)
			context["result_text"] = tr(TXT_R0)
		1:
			var num := _find_politician(10, 16)
			if num < 0:
				num = _find_politician(16, 16)
			if num < 0:
				num = _find_politician(24, 16)
			_add(W.I_BUDGET, -50)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 250
					p.power -= 250
			if num >= 0:
				game.kill_politician(num)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_309_chen_yun_fate.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_309",
	"num": 309,
	"priority": 30900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_309_chen_yun_fate.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
