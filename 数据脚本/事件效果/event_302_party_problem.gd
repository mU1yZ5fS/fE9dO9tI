## 原作 Event302.cs：解决党的问题（对越战败追责，三选项）。
## 触发：全目录搜索无 this_num_event = 302 / Reset(302)；链外 REST 段，原版无自动条件。
## 差异：party_number[0]/[4]→factions[0/4].support；文本来自 Events_text_en 索引 40-49。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "极左派的影响并不明显。"
const TXT_OPT2_DIS := "自由派的影响并不明显"
const TXT_R0 := "在党的下一次会议上，你指责一些虫豸导致了战争的失败。全党上下都明白你不希望发生冲突，但你在各派眼中变得软弱可欺，这对你有什么好处呢？"
const TXT_R1 := "该死的极左分子，依照他们对世界革命的狂想，让我国陷入一场吞噬了所有资源的战争！我国也差点因此陷入另一场危机之中！战争本身和我们的失败都要怪这些虫豸！他们的双手沾满了在他们下达不计后果的进攻命令时牺牲士兵的鲜血！开始清洗这些叛徒！"
const TXT_R2 := "自由派叛徒是失败的罪魁祸首！他们与帝国主义狼狈为奸，我们因此无法赢得战争！他们关于市场社会主义和向世界开放的机会主义思想是以我们人民的生命为代价的！右翼虫豸去死吧！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if world.factions.size() > 0 and world.factions[0] != null and world.factions[0].support > 10:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if world.factions.size() > 4 and world.factions[4] != null and world.factions[4].support > 10:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -100)
			context["result_text"] = TXT_R0
		1:
			if ws.factions.size() > 0 and ws.factions[0] != null:
				ws.factions[0].support = 0
			context["result_text"] = TXT_R1
		2:
			if ws.factions.size() > 4 and ws.factions[4] != null:
				ws.factions[4].support = 0
			context["result_text"] = TXT_R2




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

