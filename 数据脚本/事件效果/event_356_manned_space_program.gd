extends "res://数据脚本/event_script_base.gd"

## 原作 Event356.cs：载人航天计划。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "自行改装卫星。"
const TXT_OPT0_DIS := "太危险，又没用"
const TXT_OPT1 := "在“联盟号”的基础上创造。"
const TXT_OPT1_DIS := "行动的风险太大了。我们的技术也不允许我们做模拟。"
const TXT_OPT2 := "再次取消项目。"

const TXT_R0 := "总的来说，我们决定制造载人版本的FSW卫星。当然，这一飞行比起加加林来说算不了什么，也没有必要谈论基于这一太空舱的严肃项目，但这仍是通往太空之路的第一步！"
const TXT_R1 := "要复制“联盟号”是很困难的。在一些地方，原有设计不得不被改变，在另一些地方，工程师们提出了改进建议。“神舟”系列就是这样出现的。这次飞行在宣传上取得了巨大的成功——一个第三世界国家能够制造出一种现代的多座宇宙飞船，甚至还超过了苏联“原型”。但这影响了与苏联的关系。"
const TXT_R2 := "载人航天计划是没有希望的。复制“联盟”号是行不通的。一个太空舱也是没用的。我们还有别的事要干。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var dv := world.数值表
	if _budget_reserve(world) >= 40:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _budget_reserve(world) >= 70 and dv.size() > W.I_AGENTS and dv[W.I_AGENTS] >= 20 \
			and (_prev_result(world, "event_353") == 0 or _prev_result(world, "event_353") == 1):
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
			_add(W.I_BUDGET, -30)
			_add(W.I_DIPLO, 10)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -60)
			_add(W.I_SCIENCE, 200)
			_add_relation(EmpireData.USSR, -25)
			_add(W.I_DIPLO, 40)
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

