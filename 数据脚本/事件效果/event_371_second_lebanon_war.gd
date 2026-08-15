extends "res://数据脚本/event_script_base.gd"

## 原作 Event371.cs：复仇战争？。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。

const TXT_TITLE := "复仇战争？"

const TXT_DESC := "在以色列于黎巴嫩战争战败后，巴勒斯坦地区的局势便没有发生什么大变化。巴解组织与以色列之间的谈判仍停滞不前，穆斯林与基督教徒的冲突仍在继续，叙利亚在黎巴嫩的军事存在也无法使当地恢复和平。\n在近期事件的大背景下，被战争战败所激怒的以色列，又一次以反恐之名对黎巴嫩发动了入侵。彼时叙利亚仍身陷与土耳其冲突的泥潭，这次冲突将如何发展？"

const TXT_OPT0 := "战争即地狱"
const TXT_WAR4_NAME := "第二次黎巴嫩战争"
const TXT_WAR4_SIDE1 := "以色列"
const TXT_WAR4_SIDE2 := "黎巴嫩"

const TXT_R0 := "希望这一切都将在不久后结束......"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 1:
		return
	_enable(event_def.options[0], TXT_OPT0)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.set_flag("israellost", false)
			_start_war(4, TXT_WAR4_SIDE1, TXT_WAR4_SIDE2, 600, 400, 0, 1, TXT_WAR4_NAME, 12)
			context["result_text"] = TXT_R0


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


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _prev_result(world: WorldState, event_id: String) -> int:
	return int(world.completed_event_ids.get(event_id, 0))


func _budget_reserve(world: WorldState) -> int:
	var total := 0
	var dv := world.数值表
	if dv.size() > W.I_BUDGET:
		total += dv[W.I_BUDGET]
	if dv.size() > W.I_RESERVE:
		total += dv[W.I_RESERVE]
	return total


func _faction_leading(i: int) -> bool:
	return GameManager != null and GameManager.is_faction_leading(i)


func _faction_leading_0_1_2() -> bool:
	return _faction_leading(0) or _faction_leading(1) or _faction_leading(2)


func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _establish_proamerican(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", false)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", true)


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = tick_time

