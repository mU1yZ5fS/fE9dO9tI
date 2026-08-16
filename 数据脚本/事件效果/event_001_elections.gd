extends "res://数据脚本/event_script_base.gd"

## 原作 Event1.cs：全国人大选举。五党得票权重→3000席归一化→胜负分支。
## 差异：influencePRC→ws.influence_prc；allcountries[51].isNATO(自由派×0.1)跳过(USA 恒 NATO，条件恒假)；
##       data[125]/Debug.Log 跳过；惨败 data[35]=5→queue_ending_after_event(5)「人民的选择」（见 _resolve_branch）。

var _coalition: int = 0


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.factions.size() < 5:
		return
	var opt := int(context.get("option_index", -1))

	d[W.I_SATISFIED] = 0   # data[106]=0（Event1.cs:38）
	var arr := _compute_weights()

	var head := ""
	var suffix := ""
	if opt == 0:
		_normalize_to_seats(arr)
		_living_collapse_override(true)   # 需 factions[0].is_enabled（:197）
		head = _resolve_branch(true)
		suffix = " 席（总3000席位）"             # :240
	elif opt == 1:
		@warning_ignore("integer_division")
		arr[1] += float(d[W.I_PARTY_SUPPORT] / 10)   # :249
		_normalize_to_seats(arr)
		_pre_hold()                                 # :284
		_living_collapse_override(false)       # :288（无 is_enabled 守卫）
		head = _resolve_branch(false)
		suffix = "，总席位3000"                        # :331
		d[W.I_PEOPLE_SUPPORT] -= 100                  # :336-338
		d[W.I_THOUGHT_FREEDOM] += 100
		d[W.I_DIPLO] += 10
	elif opt == 2:
		if d[W.I_AGENTS] < 100:                        # :344-353
			arr[1] += float(d[W.I_AGENTS] * 2)
			d[W.I_AGENTS] = 0
		else:
			arr[1] += 200.0
			d[W.I_AGENTS] -= 100
		_normalize_to_seats(arr)
		_pre_hold()                                 # :387
		_living_collapse_override(false)       # :391
		head = _resolve_branch(false)
		suffix = "，总席位3000"                        # :434
		if ws.empires.size() > 1 and ws.empires[1] != null:   # :439-443
			ws.empires[1].power += 150
		d[W.I_THOUGHT_FREEDOM] += 30
		d[W.I_ARMY] -= 10
		d[W.I_WAR_SUPPORT] -= 10
		if ws.empires.size() > 0 and ws.empires[0] != null:
			ws.empires[0].money = 24

	context["result_text"] = head + "\n选举结果：\n" + _seats_report(suffix)


## 五党得票权重（Event1.cs:40-155），整数除法逐字。
func _compute_weights() -> Array:
	var f := ws.factions
	var ipc: int = ws.influence_prc
	var rel0 := 0
	if ws.empires.size() > 0 and ws.empires[0] != null:
		rel0 = ws.empires[0].relations
	var arr := [0.0, 0.0, 0.0, 0.0, 0.0]

	@warning_ignore("integer_division")
	arr[1] = float((d[W.I_PEOPLE_SUPPORT] * 2 - d[W.I_THOUGHT_FREEDOM] / 2 + d[W.I_LIVING] / 2) / 10)
	if ipc > 500:
		arr[1] *= 1.5
	elif ipc > 300:
		arr[1] *= 1.2

	if f[0].is_enabled:
		@warning_ignore("integer_division")
		arr[0] = float((1000 - d[W.I_PEOPLE_SUPPORT] - d[W.I_THOUGHT_FREEDOM] / 2) / 10)
		if d[W.I_MAO_HISTORY_LINE] == 2:
			arr[0] += 5.0
		if d[W.I_LIVING] <= 500:
			@warning_ignore("integer_division")
			arr[0] += float((2000 - d[W.I_LIVING]) / 20)
		if d[W.I_MANPOWER] <= 500:
			@warning_ignore("integer_division")
			arr[0] += float((1000 - d[W.I_MANPOWER]) / 20)

	if f[2].is_enabled:
		@warning_ignore("integer_division")
		arr[2] = float((1000 - d[W.I_PEOPLE_SUPPORT] + d[W.I_THOUGHT_FREEDOM] / 2 + d[W.I_WAR_SUPPORT] / 10) / 10)
		if d[W.I_ECON_SYSTEM] == 15 and d[W.I_LIVING] <= 700:
			@warning_ignore("integer_division")
			arr[2] += float((2000 - d[W.I_LIVING]) / 20)
		if d[W.I_BUDGET_PROPAGANDA] + d[W.I_BUDGET_WELFARE] >= 900:
			arr[2] *= 1.5

	if f[3].is_enabled:
		if d[W.I_WAR_SUPPORT] >= d[W.I_PEOPLE_SUPPORT]:
			@warning_ignore("integer_division")
			arr[3] = float((1000 - d[W.I_PEOPLE_SUPPORT] + d[W.I_THOUGHT_FREEDOM] / 2 + (d[W.I_WAR_SUPPORT] - d[W.I_PEOPLE_SUPPORT]) / 2) / 10)
		else:
			@warning_ignore("integer_division")
			arr[3] = float((1000 - d[W.I_PEOPLE_SUPPORT] + d[W.I_THOUGHT_FREEDOM] / 2) / 10)
		if d[W.I_LIVING] >= 300 and d[W.I_LIVING] <= 700:
			arr[3] += 20.0
		if d[W.I_ECON_SYSTEM] <= 11:
			arr[3] += 10.0
		if d[W.I_TERRITORY] != 20 and d[W.I_PEOPLE_SUPPORT] <= 700:
			@warning_ignore("integer_division")
			arr[3] += float((700 - d[W.I_PEOPLE_SUPPORT]) / 10)
		if rel0 <= 600:
			@warning_ignore("integer_division")
			arr[3] += float((1000 - rel0) / 100)

	if f[4].is_enabled:
		@warning_ignore("integer_division")
		arr[4] = float((1000 - d[W.I_PEOPLE_SUPPORT] + d[W.I_THOUGHT_FREEDOM] / 2 - d[W.I_WAR_SUPPORT]) / 10)
		if ipc > 200:
			arr[4] -= 15.0
		if rel0 <= 600:
			@warning_ignore("integer_division")
			arr[4] += float((1000 - rel0) / 100)
		if d[W.I_ECON_SYSTEM] != 15 and d[W.I_LIVING] <= 500:
			@warning_ignore("integer_division")
			arr[4] += float((2000 - d[W.I_LIVING]) / 20)
		if d[W.I_MANPOWER] <= 300:
			@warning_ignore("integer_division")
			arr[4] += float((1000 - d[W.I_MANPOWER]) / 20)
		if ipc < 200:
			arr[4] *= 1.5
		# 差异：!allcountries[51].isNATO → ×0.1 跳过（USA 恒 NATO，条件恒假）

	for i in 5:
		if arr[i] <= 0.0:
			arr[i] = 1.0
	return arr


## 归一化到 3000 席（Event1.cs:159-196）。total=Σ(int)arr（先截断再求和）。
func _normalize_to_seats(arr: Array) -> void:
	var total := 0
	for v in arr:
		total += int(v)
	if total <= 0:
		total = 1
	_coalition = 0
	for l in 5:
		var seats := int(3000.0 * (arr[l] / float(total)))
		ws.factions[l].support = seats
		ws.factions[l].ideology = seats
		if l == 1:
			_coalition += seats
		elif ws.factions[l].is_ally:
			_coalition += seats
			if ws.factions[l].support >= ws.factions[1].support:
				ws.factions[l].is_ally = false


## data[5]<=300 → 极左派横扫3000席（Event1.cs:197-206/288-297/391-400）
func _living_collapse_override(guard_enabled: bool) -> void:
	if d[W.I_LIVING] > 300:
		return
	if guard_enabled and not ws.factions[0].is_enabled:
		return
	ws.factions[0].is_ally = false
	ws.factions[0].support = 3000
	ws.factions[1].support = 0
	ws.factions[2].support = 0
	ws.factions[3].support = 0
	ws.factions[4].support = 0
	_coalition = 0


## 选项1/2：归一化后不足半数且 modifier[6] 激活 → 先抬到1500（Event1.cs:284/387）
func _pre_hold() -> void:
	if ws.factions[1].support < 1500 and _mod6_active():
		ws.factions[1].support = 1500


## 胜负分支（Event1.cs:207-227/298-318/401-421）。opt0 用<=1500、opt1/2 用<1500。
func _resolve_branch(opt0: bool) -> String:
	var mine: int = ws.factions[1].support
	if mine > 1500:
		d[W.I_PEOPLE_SUPPORT] += 10
		d[W.I_THOUGHT_FREEDOM] -= 20
		d[W.I_PARTY_SUPPORT] += 50
		return "我们大胜一场，横扫议席，向全中国与世界证明人民依然支持我们带领他们！"
	var hold: bool = (mine <= 1500) if opt0 else (mine < 1500)
	if hold and _mod6_active():
		ws.factions[1].support = 1501
		return "我们在选举中表现不佳，可那又如何？看看咱们的国号，瞧瞧建在连队内的党支部。只要红旗仍不倒，政权归属就不足以被视为问题……"
	if _coalition > 1500:
		return "我们的党派联盟在人大选举中获胜，向全中国与世界证明人民依然支持我们的领导！"
	GameManager.queue_ending_after_event(5)   # 原 Event1.cs:451 load_scene_after_click → data[35]=5「人民的选择」
	return "我们不止失去了议会多数，还没能赢得过半议席！真是耻辱！"


func _mod6_active() -> bool:
	return ws.modifiers.size() > 6 and ws.modifiers[6] != null and ws.modifiers[6].is_active


## 选举结果列表（Event1.cs:228-244）。名称用 FACTION_NAMES（原 party_name[i+5]）。
func _seats_report(suffix: String) -> String:
	var lines := PackedStringArray()
	for i in 5:
		if ws.factions[i].is_enabled:
			lines.append("%s: %d%s" % [FactionData.FACTION_NAMES[i], ws.factions[i].support, suffix])
	return "\n".join(lines)
