extends "res://数据脚本/event_script_base.gd"

## 原作 Event361.cs：中国的月球计划——先进任务。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "启动两个任务。"
const TXT_OPT0_DIS := "这太冒险了。"
const TXT_OPT1 := "启动两个任务。"
const TXT_OPT1_DIS := "这太冒险了。"
const TXT_OPT2 := "只发射月球车。"

const TXT_R0 := "中国探月计划的成功继续令国际社会惊叹——中国已成为继苏联之后第二个有能力制造月球车并实现月球土壤自动输送的国家。当所有人都在猜测中国的技术时，我们的探月计划的第三阶段即将到来。"
const TXT_R1 := "中国探月计划的成功继续令国际社会惊叹——中国已成为继苏联之后第二个有能力制造月球车并实现月球土壤自动输送的国家。当所有人都在猜测中国的技术时，我们的探月计划的第三阶段即将到来。"
const TXT_R2 := "中国探月计划的成功继续令国际社会惊叹——中国已成为继苏联之后第二个有能力制造月球车的国家。但是，不幸的是，后续项目的复杂性迫使我们终止这一项目。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var r353 := _prev_result(world, "event_353")
	if r353 == 0 and _budget_reserve(world) >= 30:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if r353 == 1 and _budget_reserve(world) >= 50:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_SCIENCE, 150)
			_add(W.I_BUDGET, -20)
			_add(W.I_DIPLO, 10)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_SCIENCE, 300)
			_add(W.I_BUDGET, -40)
			_add(W.I_DIPLO, 20)
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2




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

