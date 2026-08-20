extends "res://数据脚本/event_script_base.gd"

## 原作 Event360.cs：月球计划——载人登月。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。
## 说明：原版触发中的 (resultOfEvents[361]<=1 || resultOfEvents[358]<=1 || resultOfEvents[359]<=1)
## 恒为真（358/359 各只有 0/1 两个选项，<=1 必真），故 .tres 仅保留日期条件。



const TXT_OPT0 := "我们要在20世纪80年代末登上月球！"
const TXT_OPT0_DIS := "登月没有必要。"
const TXT_OPT1 := "我们押宝于一个长期项目。"

const TXT_R0 := "因此，在1990年之前的登上月球的计划被采纳。工业和科技企业已经开始加班加点。但很多人怀疑这样做的必要性......"
const TXT_R1 := "急着让一个人着陆月球被认为是没有希望的。相反，工程师和科学家的任务是在2030年之前在月球表面建设一个长期定居点。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	if _prev_result(world, "event_353") == 1 and _budget_reserve(world) >= 200:
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
			_add(W.I_SCIENCE, 40)
			_add(W.I_BUDGET, -180)
			_add(W.I_DIPLO, 70)
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

