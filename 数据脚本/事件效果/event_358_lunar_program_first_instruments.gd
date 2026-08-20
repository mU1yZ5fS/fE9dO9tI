extends "res://数据脚本/event_script_base.gd"

## 原作 Event358.cs：月球计划——第一批仪器。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "也发射登陆站。"
const TXT_OPT0_DIS := "太复杂了。"
const TXT_OPT1 := "只发射飞行器。"

const TXT_R0 := "中国在太空研究方面的成功并没有被忽视。在过去5年世界没有任何登月任务的背景下，我们的登月任务在某种程度上震惊了航天界。当世界其他国家都在艳羡不已的时候，中国开始了探月计划的新阶段。"
const TXT_R1 := "中国的探月计划包括向月球发射飞行和进行轨道任务，摄影和一些科学测量任务包括其中。在发展中国家之外，这引起了轰动。但由于其复杂性和无意义性，该项目在中国国内被关闭。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	if _prev_result(world, "event_353") == 0 or _prev_result(world, "event_353") == 1:
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
			_add(W.I_SCIENCE, 200)
			_add(W.I_DIPLO, 40)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_SCIENCE, 50)
			_add(W.I_DIPLO, 50)
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
	return GameManager != null and game.is_faction_leading(i)


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
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = tick_time

