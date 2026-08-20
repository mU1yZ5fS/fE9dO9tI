## 原作 Event305.cs：小平的辞呈？（打倒邓小平，两选项）。
## 触发：全目录搜索无 this_num_event = 305 / Reset(305)；链外 REST 段，原版无自动条件。
## 差异：KillPerson→GameManager.kill_politician；文本来自 Events_text_en 索引 63-68。
extends "res://数据脚本/event_script_base.gd"

const TXT_R0 := "小平是中国的未来！毛主义的恐怖将留在过去！自由和开放的光明未来在等待着我们！"
const TXT_R1 := "对邓小平的思想和活动的一致批评始于党内会议。极左派指责他是修正主义，而温和派则担心失去权力。总的来说，到会议结束时，小平已经失去了所有的希望，因为就连他以前的盟友也背叛了他。这位雄心勃勃的前政治家失去了所有的职位，被迫离开首都，并对自己的倒台感到震惊，很快就因心脏病悄悄去世了。"


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
			var num := _find_politician(13, 13)
			if num >= 0:
				GameManager.kill_politician(num)
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
	PoliticianSystem.copy_leader_appearance(ws.leader, p)

