## 原作 Event310.cs：彭真的命运（平反/处决彭真，两选项）。
## 触发：全目录搜索无 this_num_event = 310 / Reset(310)；链外 REST 段，原版无自动条件。
## 差异：KillPerson 后原版直接改 politics[num] 字段；Godot kill_politician 会替换槽位，
##  因此先 kill 再写槽位字段以对齐；文本来自 Events_text_en 索引 98-103。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "彭真的命运"
const TXT_DESC := "在下一次党的会议上，关于彭真的问题浮出水面：他曾是毛的支持者，在大跃进失败后便背弃了他，转而批评毛主义，因此他被打为走资派并被下放。一些人仍然视他为自由派修正主义者和中国的敌人。但他并没有犯什么弥天大罪，哪怕他正和可疑的人合作，也许还是应该让这个老党员自个待着，反正他也活不了多久了......"
const TXT_OPT0 := "平反彭真"
const TXT_OPT1 := "一劳永逸地将其处理掉"
const TXT_R0 := "党认为对彭真的指控太过牵强，毫无根据。平反期间，他被任命为第五届全国人民代表大会立法工作委员会代理主任。"
const TXT_R1 := "事实证明，指责其为自由派对彭真的事业和健康的打击都太过沉重了。在受到严厉批评后，他离开了会议，不久就去世了。当然，他死于自然原因。自由派是不高兴，但谁在乎呢？"


func prepare(event_def: EventDef, world: WorldState) -> void:
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
			_add(W.I_PARTY_SUPPORT, -150)
			var num := 0
			for i in ws.politicians.size():
				var p := ws.politicians[i]
				var minp := ws.politicians[num] if ws.politicians.size() > 0 else null
				if p != null and minp != null and p.power < minp.power:
					num = i
			if num >= 0 and num < ws.politicians.size():
				GameManager.kill_politician(num)
				var p2 := ws.politicians[num]
				if p2 != null:
					p2.name_first = 27
					p2.name_last = 48
					p2.age = d[W.I_YEAR] - 1902
					p2.trait_personality = 1
					p2.trait_background = 21
					p2.trait_alignment = 6
					p2.trait_special = 11
					p2.power = 1500
					p2.loyalty = 500
			context["result_text"] = TXT_R0
		1:
			var num2 := _find_politician(27, 17)
			_add(W.I_ARMY, 50)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality > 1:
					p.loyalty -= 250
					p.power -= 250
			if num2 >= 0:
				GameManager.kill_politician(num2)
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

