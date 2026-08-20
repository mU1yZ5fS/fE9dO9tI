## 原作 Event309.cs：陈云的命运（清算陈云，两选项）。
## 触发：全目录搜索无 this_num_event = 309 / Reset(309)；链外 REST 段，原版无自动条件。
## 差异：KillPerson→GameManager.kill_politician；文本来自 Events_text_en 索引 92-97。
extends "res://数据脚本/event_script_base.gd"

const TXT_R0 := "阴谋失败了，陈云受到了其余党员的保护。"
const TXT_R1 := "在下一次党的会议上，陈云被指责要为大跃进政策的失败负责。在那之后，他被拘留了，很快便被立案，该案最后以射杀一个害虫、一个亲西方的机会主义者而告终。"


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
			context["result_text"] = TXT_R0
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
				if p.trait_personality > 0:
					p.loyalty -= 250
					p.power -= 250
			if num >= 0:
				GameManager.kill_politician(num)
			context["result_text"] = TXT_R1


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n




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

