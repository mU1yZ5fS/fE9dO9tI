extends "res://数据脚本/event_script_base.gd"

## 原作 Event357.cs：载人计划的进一步发展。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "开始发展。"
const TXT_OPT0_DIS := "没有这么做的资源。"
const TXT_OPT1 := "有人上太空就够了。"

const TXT_R0 := "研究开始了，几年后，第一批由几人组成的中国宇航员进入了太空。世界为我们的成就感到惊讶，我国的科技前景也豁然开朗。"
const TXT_R1 := "更先进的飞船的好处可以忽略不计，不值得认真对待。这是工程师与科学家们对发展一个类似苏联“联盟”号飞船计划的结论。中国应该关注无人驾驶汽车。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	if _budget_reserve(world) >= 40:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -30)
			_add(W.I_SCIENCE, 200)
			_add(W.I_DIPLO, 40)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1




func _prev_result(world: WorldState, event_id: String) -> int:
	return int(world.completed_event_ids.get(event_id, 0))


func _budget_reserve(world: WorldState) -> int:
	var total := 0
	var dv := world
	if dv.size() > W.I_BUDGET:
		total += dv.budget
	if dv.size() > W.I_RESERVE:
		total += dv.reserve
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

