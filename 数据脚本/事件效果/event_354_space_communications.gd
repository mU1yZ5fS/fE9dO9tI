extends "res://数据脚本/event_script_base.gd"

## 原作 Event354.cs：空间通信。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "在近地轨道上构建一个网络。"
const TXT_OPT0_DIS := "没有这么做的资源。"
const TXT_OPT1 := "发射地球同步卫星。"
const TXT_OPT1_DIS := "没有这种科技。"
const TXT_OPT2 := "连接别国的网络。"

const TXT_R0 := "很快，中国在近地轨道上部署了由许多卫星组成的系统。当然，这并非最佳选择，但它能让我们完成任务。"
const TXT_R1 := "我国成为世界上第四个能够依靠自己的力量将卫星发射到地球静止轨道的国家。很快，几颗卫星便用快速且高质量的通信覆盖了中国全境。"
const TXT_R2 := "不幸的是，我国的技术不允许我们自己发射通信卫星，因此我们最好连接到别人的网络。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _budget_reserve(world) >= 30:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if _budget_reserve(world) >= 50 and (_prev_result(world, "event_353") == 0 or _prev_result(world, "event_353") == 1):
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
			_add(W.I_BUDGET, -20)
			_add(W.I_SCIENCE, 100)
			_add(W.I_INDUSTRY, 100)
			_add(W.I_ARMY, 100)
			_add(W.I_LIVING, 100)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -40)
			_add(W.I_SCIENCE, 300)
			_add(W.I_INDUSTRY, 100)
			_add(W.I_ARMY, 100)
			_add(W.I_LIVING, 100)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_THOUGHT_FREEDOM, 40)
			_add(W.I_SCIENCE, 300)
			_add(W.I_INDUSTRY, 100)
			_add(W.I_ARMY, 100)
			_add(W.I_LIVING, 100)
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

