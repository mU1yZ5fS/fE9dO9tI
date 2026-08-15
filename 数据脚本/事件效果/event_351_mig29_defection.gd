extends "res://数据脚本/event_script_base.gd"

## 原作 Event351.cs：机群革新。
## 原版无自动条件（决策/其他事件链手动触发）
## 触发：见 evaluate()（由 ReqEventsDLC02.cs else-if 链照抄）。

const TXT_TITLE := "机群革新"

const TXT_DESC := "苏联将最新的多用途战斗机米格-29投入了使用。我们离研究出这一技术还遥不可及。因此，这飞机对我们很有用......但怎么办呢？你可以购买生产许可证，但中苏关系并没有好到苏联能卖给我们最新武器的程度。因此，也许你应该找找情报部门？"

const TXT_OPT0 := "劫机。"
const TXT_OPT0_DIS := "我们没那个能力。"
const TXT_OPT1 := "窃取蓝图。"
const TXT_OPT1_DIS := "我们没那个能力。"
const TXT_OPT2 := "购买飞机。"
const TXT_OPT2_DIS := "我们一点钱都没有了。"
const TXT_OPT3 := "什么都不做。"

const TXT_R0 := "一名同情中国共产党的苏联飞行员驾驶米格-29战斗机逃往中国。当然，与苏联的关系受到了影响，但我们得到了最新的战机。"
const TXT_R1 := "一群中国特工从一家苏联工厂窃取了最新的米格-29飞机的图纸。与苏联的关系并没有受到影响。他们怎么知道这事？但我们的空军将用上最新的飞机。"
const TXT_R2 := "中国代表团访问了苏联。除了解决许多小问题外，代表团还决定购买最新的米格-29战斗机。事实上，这是自20世纪50年代以来我们收到的第一批苏联军事装备。当然，这只是我国发展的基础罢了。"
const TXT_R3 := "其他问题更为重要。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var dv := world.数值表
	var opt := event_def.options
	if dv.size() > W.I_AGENTS and dv[W.I_AGENTS] >= 20:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if dv.size() > W.I_AGENTS and dv[W.I_AGENTS] >= 30:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if world.empires.size() > 1 and world.empires[1] != null and world.empires[1].relations >= 400 \
			and _budget_reserve(world) >= 20:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(EmpireData.USSR, -70)
			_add(W.I_ARMY, 100)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_ARMY, 100)
			context["result_text"] = TXT_R1
		2:
			_add_relation(EmpireData.USSR, 70)
			_add(W.I_ARMY, 100)
			_add(W.I_BUDGET, -10)
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3


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

