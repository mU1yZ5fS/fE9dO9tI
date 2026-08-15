## 原作 Event305.cs：小平的辞呈？（打倒邓小平，两选项）。
## 触发：全目录搜索无 this_num_event = 305 / Reset(305)；链外 REST 段，原版无自动条件。
## 差异：KillPerson→GameManager.kill_politician；文本来自 Events_text_en 索引 63-68。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "小平的辞呈？"
const TXT_DESC := "近年来，邓小平在党内的呼声越来越高。他和他的支持者正为自己获得了越来越多的政府职位。如果他的观点不是很可疑的话，我们也可以对此视而不见。是的，他的想法仍然很温和，但在与志同道合的人交谈时，他已在讨论国家的完全自由化。一些有关他与西方情报机构合作的信息也正在收到。值得组织一个阴谋来对抗崛起的密谋自由主义分子吗？"
const TXT_OPT0 := "让小平留任。"
const TXT_OPT1 := "打倒修正主义者！"
const TXT_R0 := "小平是中国的未来！毛主义的恐怖将留在过去！自由和开放的光明未来在等待着我们！"
const TXT_R1 := "对邓小平的思想和活动的一致批评始于党内会议。极左派指责他是修正主义，而温和派则担心失去权力。总的来说，到会议结束时，小平已经失去了所有的希望，因为就连他以前的盟友也背叛了他。这位雄心勃勃的前政治家失去了所有的职位，被迫离开首都，并对自己的倒台感到震惊，很快就因心脏病悄悄去世了。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	_enable(event_def.options[0], TXT_OPT0)
	_enable(event_def.options[1], TXT_OPT1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			var num := _find_politician(13, 13)
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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _mod_active(idx: int) -> bool:
	var w := ws if ws != null else GameManager.world
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

