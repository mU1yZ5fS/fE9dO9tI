## 原作 Event307.cs：定罪红卫兵（红卫兵平反，三选项）。
## 触发：全目录搜索无 this_num_event = 307 / Reset(307)；链外 REST 段，原版无自动条件。
## 差异：modifies[3].active→_mod_active(3)，动态 description 在 prepare 切换；party_number[0]→factions[0].support；
##  traits[0]→trait_personality；文本来自 Events_text_en 索引 77-84 与 Event307.cs 内联。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "定罪红卫兵"
const TXT_DESC_INACTIVE := "文革失败后，许多红卫兵被送进监狱以稳定局势。但那么多年过去了，放了他们也没什么了，毕竟我们已牢牢掌握了权力，以前的激进分子中也有有用的专家，人民对镇压红卫兵的态度也不是很好，释放他们会让我们更受支持。但先得记住，让他们回归原位会让这个国家大大回到激进的过去。"
const TXT_DESC_ACTIVE := "文革前十年的后期，由于保守势力的反扑，许多造反派红卫兵被送进了监狱。但在文革局势逐渐稳定下来之后，一些党员提出要为之前蒙冤入狱的造反派平反，这些造反派中也不乏有用的专家，人民对造反派的看法也早有改观，释放他们会让我们更受支持。但是，我们是应该不带有色眼镜把他们当作正常人去对待并给他们分配工作，还是仅仅做个“人道”的样子但在暗中仍然排挤他们？这决定了我们是把文化大革命当作一场真正的人民运动还是被粉饰成“人民运动”的清洗活动。"
const TXT_OPT0 := "让他们继续在监狱里服刑。"
const TXT_OPT1 := "放了他们。"
const TXT_OPT2 := "放了他们，让他们回到党内和岗位上。"
const TXT_OPT2_DIS := ""
const TXT_R0 := "没必要把他们放了。他们已使这个国家坠入深渊，造成数百万人死亡。我们需要稳定，而不是革命狂热。"
const TXT_R1 := "红卫兵们被释放了，但他们毫无权力。全党平静地面对了这一事实，毕竟已时过境迁了，但许多家庭得以团圆，人民对您的支持也增加了，所以在以前的激进派中也有一些人改换门庭，转而支持您。"
const TXT_R2 := "红卫兵们被从监狱释放，官复原职。在党内的右翼派系中，针对您的批评呼声不绝于耳，但作为补偿，您得到了红卫兵和左翼的支持。当然，极左派是有所增加，但跟让市场主义者和右翼修正主义者占据主流，继而将国家推入帝国主义的怀抱比起来，这可好得多了！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var mod3 := _mod_active(3)
	if mod3:
		event_def.description = TXT_DESC_ACTIVE
	else:
		event_def.description = TXT_DESC_INACTIVE
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	_enable(opt[1], TXT_OPT1)
	if mod3:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 15)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, -15)
			_add(W.I_THOUGHT_FREEDOM, 50)
			context["result_text"] = TXT_R1
		2:
			if ws.factions.size() > 0 and ws.factions[0] != null:
				ws.factions[0].support += 300
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_DIPLO, 100)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality > 0 and p.trait_personality != 20:
					p.loyalty -= 500
					p.power -= 500
				elif p.trait_personality == 20:
					p.loyalty -= 100
			_set_mod_active(32, true)
			context["result_text"] = TXT_R2


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
	var w: WorldState = ws if ws != null else GameManager.world
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

