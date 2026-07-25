extends RefCounted

## 原作事件 71–73：纳萨尔派终局、人民党危机与两伊战争爆发。
## 来源：TimeScript.cs:3972-3995，doneventscript.cs:1767-1823，
##       Results_text.cs:5413-5428,6168-6241。
const W = preload("res://数据脚本/world_state.gd")


func execute(context: Dictionary) -> void:
	var ws: WorldState = GameManager.world
	if ws == null:
		return
	var option_index := int(context.get("option_index", -1))
	match str(context.get("event_id", "")):
		"naxalite_endgame": _event_71(ws, option_index)
		"janata_crisis": _event_72(ws, option_index)
		"iran_iraq_war": _event_73(ws)
	ws.clamp_empire_relations()
	_sync_empire_mirrors(ws)


func _event_71(ws: WorldState, option_index: int) -> void:
	match option_index:
		0:
			ws.set_flag("cb_india", true)
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 80, W.I_INFLUENCE: 10, W.I_DIPLO: -10})
			_add_empire_relation(ws, EmpireData.USSR, 50)
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: -50, W.I_DIPLO: 50,
				W.I_INDIA_WAR_PRESSURE: 200})
			_add_empire_relation(ws, EmpireData.USA, -150)
			_add_empire_relation(ws, EmpireData.USSR, -250)
			ws.war_state = 2


func _event_72(ws: WorldState, option_index: int) -> void:
	var india := ws.get_country_by_legacy_index(19)
	match option_index:
		0:
			ws.数值表[W.I_INFLUENCE] -= 10
			if india != null:
				india.set_tag("对华贸易", false)
				india.set_tag("亲苏", true)
		1:
			_add_data(ws, {W.I_PARTY_SUPPORT: 80, W.I_AGENTS: -60, W.I_BUDGET: -100})
			_add_empire_relation(ws, EmpireData.USA, -80)
		2:
			_add_data(ws, {W.I_PARTY_SUPPORT: 80, W.I_AGENTS: -60, W.I_BUDGET: -100})
			_add_empire_relation(ws, EmpireData.USA, -80)
			_add_empire_power(ws, EmpireData.USA, 20)
			if india != null:
				india.government = 3


func _event_73(ws: WorldState) -> void:
	GameManager.start_war(3, "Iraq", "Iran", 500, 500, 0, 0)


func _add_data(ws: WorldState, changes: Dictionary) -> void:
	for raw_index in changes:
		var index := int(raw_index)
		if index >= 0 and index < ws.数值表.size():
			ws.数值表[index] += int(changes[raw_index])


func _add_empire_relation(ws: WorldState, empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(ws: WorldState, empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors(ws: WorldState) -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		ws.数值表[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		ws.数值表[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		ws.数值表[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		ws.数值表[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
