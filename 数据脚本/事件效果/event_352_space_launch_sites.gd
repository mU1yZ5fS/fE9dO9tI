extends "res://数据脚本/event_script_base.gd"

## 原作 Event352.cs：航天发射场。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "重建西昌卫星发射中心。"
const TXT_OPT0_DIS := "我们分身乏力"
const TXT_OPT1 := "完成太原卫星发射中心。"
const TXT_OPT1_DIS := "我们分身乏力"
const TXT_OPT2 := "同时建造两个卫星发射中心。"
const TXT_OPT2_DIS := "我们分身乏力"
const TXT_OPT3 := "我们没有足够的资源。"

const TXT_R0 := "西昌卫星发射中心复工了，如今我国可以进行更多的航天发射任务了。此外，监督工地建设的科学家们也得以将预算的一部分用于其他开发。"
const TXT_R1 := "太原卫星发射中心落成了，如今我国可以进行更多的航天发射任务了。此外，监督工地建设的军方也得以将预算的一部分用于其他开发。"
const TXT_R2 := "两个航天中心都已落成，因此我国的航天发射次数将创下记录！"
const TXT_R3 := "比起在航天领域花大笔大笔钱，我国还有别的事要做！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if _budget_reserve(world) >= 30:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _budget_reserve(world) >= 50:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if _budget_reserve(world) >= 70:
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
			_add(W.I_BUDGET, -20)
			_add(W.I_SCIENCE, 100)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -40)
			_add(W.I_ARMY, 100)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_SCIENCE, 100)
			_add(W.I_ARMY, 100)
			_add(W.I_BUDGET, -60)
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

