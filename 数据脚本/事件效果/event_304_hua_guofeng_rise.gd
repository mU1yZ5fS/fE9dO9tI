## 原作 Event304.cs：华国锋的崛起（逼华国锋下台，两选项）。
## 触发：全目录搜索无 this_num_event = 304 / Reset(304)；链外 REST 段，原版无自动条件。
## 差异：faction_leader[1..3]→factions[i].leader_index；KillPerson→GameManager.kill_politician；
##  LeaderAsset/MoneyLevel/ServeRMB 显示字段跳过；文本来自 Events_text_en 索引 57-62。
extends "res://数据脚本/event_script_base.gd"

const TXT_R0 := "针对国锋的阴谋在党内没有得到支持。"
const TXT_R1 := "在下一次党的会议上，提出了关于华国锋主席辞职的议题，这个国家的所有失败都归咎于他。在投票中，大家一致支持辞职，很快国锋就失去了职位，被送到他的别墅，几周后他很快就会死去。当然，是由于自然原因。"


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
			context["result_text"] = TXT_R0
		1:
			var num := -1
			if ws.factions.size() > 1 and ws.factions[1] != null and ws.factions[1].leader_index < 100:
				num = ws.factions[1].leader_index
			elif ws.factions.size() > 2 and ws.factions[2] != null and ws.factions[2].leader_index < 100:
				num = ws.factions[2].leader_index
			elif ws.factions.size() > 3 and ws.factions[3] != null and ws.factions[3].leader_index < 100:
				num = ws.factions[3].leader_index
			if num >= 0 and num < ws.politicians.size():
				var p := ws.politicians[num]
				if p != null:
					_set_leader_from(p)
					GameManager.kill_politician(num)
					_set_mod_active(65, false)
			# LeaderAsset/MoneyLevel/ServeRMB 为显示字段，跳过
			context["result_text"] = TXT_R1




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






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
	ws.leader.face_type = p.face_type
	if p.face_parts.size() >= 8:
		ws.leader.face_parts = p.face_parts.duplicate()
	ws.leader.jacket = p.jacket

