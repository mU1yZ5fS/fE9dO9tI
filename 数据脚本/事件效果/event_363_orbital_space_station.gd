extends "res://数据脚本/event_script_base.gd"

## 原作 Event363.cs：轨道空间站。。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "创建自己的空间站。"
const TXT_OPT0_DIS := "太复杂了。"
const TXT_OPT1 := "我们需要一个中华人民共和国和苏联的联合项目。"
const TXT_OPT1_DIS := "不可能和他们合作。"
const TXT_OPT2 := "我们不需要空间站。"

const TXT_R0 := "不久，中国第一个载人轨道天文台发射了。是的，第一批宇航员面临着许多困难，但迈出了这一步，我们就开启了太空计划的新阶段，其前景不可思议！"
const TXT_R1 := "根据协议，首个国际空间站“黎明号”建成。中国和苏联宇航员的联合工作已经产生了重大的科学成果，该项目对国际关系的影响是无价的。与苏联和中华人民共和国结盟的一些国家已经表示愿意参加空间站的工作，我们的设计局已经在制定进一步扩大空间站的计划。"
const TXT_R2 := "载人空间站需要恒河沙数的资源，而且几乎没什么实际用处。我们有更重要的任务。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var _dv := world.数值表
	var r353 := _prev_result(world, "event_353")
	if (r353 == 0 or r353 == 1) and _budget_reserve(world) >= 30:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if (r353 == 0 or r353 == 1) and _budget_reserve(world) >= 30 \
			and world.empires.size() > 1 and world.empires[1] != null and world.empires[1].relations >= 50:
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
			_add(W.I_BUDGET, -20)
			_add(W.I_DIPLO, 20)
			_add_relation(EmpireData.USSR, 50)
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

