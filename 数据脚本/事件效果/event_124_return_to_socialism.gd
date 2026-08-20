extends "res://数据脚本/event_script_base.gd"

## 原作 Event124.cs：回归社会主义（2 选项）。
## 触发：由 Decision(GlobalScript.cs:33) 手动触发（回归社会主义），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻结果效果。


const TXT_R0 := "当如今的前领导人到达时，大会已经结束了，他已被解雇，并且获得了荣誉养老金，正如其他许多反对者一样。王明的道路是成功的，而只有时间能告诉我们，他的亲戚们是能原汁原味地保留他的想法，还是会让党利用他们，将其作为木偶来实现自己的梦想。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	_kill_faction_leader_if_valid(0)
	_kill_faction_leader_if_valid(4)
	var mid_idx := _faction_leader_or(2, 16)
	var reform_idx := _faction_leader_or(3, 15)
	_set_politician_by_slot(mid_idx, 3, 42, [1, 5, 17, 26], d.year - 1932,
		[0, 0, 0, 0, 0, 0, 0, 0], 2, 0,
		[3, 6, 6, 1, 6, 3, 6, 1])
	_set_politician_by_slot(reform_idx, 3, 44, [2, 5, 14, 26], d.year - 1945,
		[0, 0, 0, 0, 0, 0, 0, 0], 3, 0,
		[3, 6, 6, 4, 6, 3, 6, 4])
	_add(W.I_AGENTS, -25)
	_add(W.I_BUDGET, -25)
	var cons_idx := _faction_leader_or(1, 14)
	if opt == 0:
		_set_politician(ws.leader, 41, 45, [0, 4, 13, 21], d.year - 1911,
			[0, 0, 0, 0, 0, 0, 0, 0], 0, 0,
			[3, 6, 6, 1, 6, 3, 6, 1])
		_set_politician_by_slot(cons_idx, 3, 43, [1, 7, 17, 26], d.year - 1939,
			[0, 0, 0, 0, 0, 0, 0, 0], 1, 0,
			[3, 6, 6, 4, 6, 3, 6, 4])
		_add(W.I_LIVING, 50)
		_add(W.I_PEOPLE_SUPPORT, 50)
	else:
		_set_politician(ws.leader, 3, 43, [1, 7, 17, 26], d.year - 1939,
			[0, 0, 0, 0, 0, 0, 0, 0], 1, 0,
			[3, 6, 6, 4, 6, 3, 6, 4])
		_set_politician_by_slot(cons_idx, 41, 45, [0, 4, 13, 21], d.year - 1911,
			[0, 0, 0, 0, 0, 0, 0, 0], 0, 0,
			[3, 6, 6, 1, 6, 3, 6, 1])
		_add(W.I_AGENTS, 50)
		_add(W.I_BUDGET, 50)
	# LeaderAsset / MoneyLevel / ServeRMB 为 display-only 字段，端口跳过。
	_set_modifier_active(65, false)
	context["result_text"] = TXT_R0
	for i in ws.politicians.size():
		WorldFactory._calc_rel(ws, i)
		WorldFactory._calc_rel2(ws, i)
		WorldFactory._calc_rel_leader(ws, i)


func _kill_faction_leader_if_valid(faction_index: int) -> void:
	if faction_index >= ws.factions.size():
		return
	var idx := ws.factions[faction_index].leader_index
	if idx >= 0 and idx < ws.politicians.size():
		GameManager.kill_politician(idx)


func _faction_leader_or(faction_index: int, fallback: int) -> int:
	if faction_index < ws.factions.size():
		var idx := ws.factions[faction_index].leader_index
		if idx >= 0 and idx < ws.politicians.size():
			return idx
	return fallback


func _ensure_slot(idx: int) -> void:
	while ws.politicians.size() <= idx:
		ws.politicians.append(PoliticianData.new())


func _set_politician_by_slot(idx: int, name_first: int, name_last: int, traits: Array, age: int,
		face_bounds: Array, jacket: int, face_type: int, face_max: Array) -> void:
	_ensure_slot(idx)
	_set_politician(ws.politicians[idx], name_first, name_last, traits, age, face_bounds, jacket, face_type, face_max)


func _set_politician(p: PoliticianData, name_first: int, name_last: int, traits: Array, age: int,
		_face_bounds: Array, jacket: int, face_type: int, face_max: Array) -> void:
	if p == null:
		return
	p.name_first = name_first
	p.name_last = name_last
	p.trait_personality = traits[0]
	p.trait_alignment = traits[1]
	p.trait_special = traits[2]
	p.trait_background = traits[3]
	p.age = age
	while p.face_parts.size() < 8:
		p.face_parts.append(0)
	p.face_parts[0] = randi_range(0, face_max[0] - 1) if face_max[0] > 1 else 0
	p.face_parts[1] = randi_range(0, face_max[1] - 1) if face_max[1] > 1 else 0
	p.face_parts[2] = randi_range(0, face_max[2] - 1) if face_max[2] > 1 else 0
	p.face_parts[3] = randi_range(0, face_max[3] - 1) if face_max[3] > 1 else 0
	p.face_parts[4] = randi_range(0, face_max[4] - 1) if face_max[4] > 1 else 0
	p.face_parts[5] = randi_range(0, face_max[5] - 1) if face_max[5] > 1 else 0
	p.face_parts[6] = randi_range(0, face_max[6] - 1) if face_max[6] > 1 else 0
	p.face_parts[7] = randi_range(0, face_max[7] - 1) if face_max[7] > 1 else 0
	p.jacket = jacket
	p.face_type = face_type




func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active

