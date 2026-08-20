extends "res://数据脚本/event_script_base.gd"

## 原作 Event366.cs：土耳其国父的遗产。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "与左派势力建立联系"
const TXT_OPT0_DIS := "巧妇难为无米之炊，我们手头得有5百万才能干活......"
const TXT_OPT1 := "与极右翼势力建立联系"
const TXT_OPT1_DIS := "巧妇难为无米之炊，我们手头得有5百万才能干活......"
const TXT_OPT2 := "不闻不问"
const TXT_OPT0_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有5百万才能干活......"
const TXT_OPT0_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有3支特工网络才能干活......"
const TXT_OPT1_DIS_BUDGET := "巧妇难为无米之炊，我们手头得有5百万才能干活......"
const TXT_OPT1_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有3支特工网络才能干活......"

const TXT_R0 := "通过向土耳其国内输送资金与顾问支持，我们与土耳其工人党和多个激进的共产主义组织建立了联系。因此，土耳其工人党自觉有了靠山，决定参与1977年选举。最终，该党拿下10%的选票。而其他政党的战果如下：共和人民党赢得超过35%的选票，正义党-30%，救国党-10%,民族行动党-5%。\n穆斯塔法·比伦特·埃杰维特再度当选土耳其总理。然而，该国左翼游击队与反游击队武装的冲突仍在继续，发生在5月的塔克西姆广场事件便是一个典例。"
const TXT_R1 := "通过向土耳其国内输送资金与顾问支持，我们已经与右翼的民族行动党建立了联系。而在1977年选举中，各党的战果如下：共和人民党赢得超过35%的选票，正义党-30%，救国党-10%，民族行动党-15%。\n土耳其工人党则决定抵制选举。\n穆斯塔法·比伦特·埃杰维特再度当选土耳其总理。然而，他没能获得议会多数。执政党的成功也没能妨碍右翼的攻势，相当数量的右翼党派尝试阻挠政府的政策。除此之外，该国激进主义游击队与反游击队武装的冲突仍在继续，发生在5月的塔克西姆广场事件便是一个典例。"
const TXT_R2 := "选举已经结束，各党的战果如下：共和人民党赢得超过45%的选票，正义党-37%，救国党-10%，极右翼组织民族行动党-6%。\n土耳其工人党则决定抵制选举。\n穆斯塔法·比伦特·埃杰维特再度当选土耳其总理。然而，他没能获得议会多数。执政党的成功也没能妨碍右翼的攻势，相当数量的右翼党派尝试阻挠政府的政策。除此之外，该国激进主义游击队与反游击队武装的冲突仍在继续，发生在5月的塔克西姆广场事件便是一个典例。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var dv := world
	var agents := dv.agents if dv.size() > W.I_AGENTS else 0
	if agents > 30 and _budget_reserve(world) >= 50:
		_enable(opt[0], TXT_OPT0)
	else:
		if _budget_reserve(world) < 50:
			_disable(opt[0], TXT_OPT0_DIS_BUDGET)
		else:
			_disable(opt[0], TXT_OPT0_DIS_AGENTS)
	if agents > 30 and _budget_reserve(world) >= 50:
		_enable(opt[1], TXT_OPT1)
	else:
		if _budget_reserve(world) < 50:
			_disable(opt[1], TXT_OPT1_DIS_BUDGET)
		else:
			_disable(opt[1], TXT_OPT1_DIS_AGENTS)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, 20)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -30)
			if _faction_leading(0) or _faction_leading(1):
				_add(W.I_PARTY_SUPPORT, 50)
			else:
				_add(W.I_PARTY_SUPPORT, -50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, 20)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -30)
			if _faction_leading(0):
				_add(W.I_PARTY_SUPPORT, 50)
			else:
				_add(W.I_PARTY_SUPPORT, -50)
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2




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

