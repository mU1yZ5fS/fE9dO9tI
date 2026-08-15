extends "res://数据脚本/event_script_base.gd"

## 原作 Event355.cs：卫星导航网络。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。

const TXT_TITLE := "卫星导航网络"

const TXT_DESC := "一年多前，美国开始构建自己的卫星全球定位系统——GPS。情报部门还报告说，在今后几年里，苏联也将开始进行一个类似的项目。在大势所趋下，有些人建议我们构建一个属于我们中国自己的系统。当然，这需要资源，但回报将无可估计......"

const TXT_OPT0 := "开始发射北斗系统！"
const TXT_OPT0_DIS := "没有这么做的资源。"
const TXT_OPT1 := "这一系统不在优先考虑范围内。或许过十年再说吧。"

const TXT_R0 := "不久，构成中国自己的卫星导航系统的第一颗卫星就发射了。因此，我国成为第二个部署这一系统的国家，超越了以前在技术上领先我们的苏联。"
const TXT_R1 := "部署该系统被认为过于昂贵且冒险，因此该项目的实施推迟了几个五年计划。"


func prepare(event_def: EventDef, world: WorldState) -> void:
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
			_add(W.I_BUDGET, -20)
			_add(W.I_SCIENCE, 100)
			_add(W.I_INDUSTRY, 100)
			_add(W.I_ARMY, 200)
			_add(W.I_DIPLO, 100)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1


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

