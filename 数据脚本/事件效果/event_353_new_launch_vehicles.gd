extends "res://数据脚本/event_script_base.gd"

## 原作 Event353.cs：新型运载火箭。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "开始研制长征三号和长征四号。"
const TXT_OPT0_DIS := "没有这么做的资源。"
const TXT_OPT1 := "开始进行所有项目。"
const TXT_OPT1_DIS := "总之，没有资源。"
const TXT_OPT2 := "只使用系列中的长征二号。"

const TXT_R0 := "我国不仅需要向近地轨道发射火箭的能力。我们马上就能研制出到新型的、更重的运载火箭，它的有效载荷和轨道都来得更高！"
const TXT_R1 := "世界对我们的最新发展感到惊讶。直到最近，中国似乎还是个第三世界国家，而现在，它已成功将一枚有效载荷20多吨的重型火箭射入太空。中国将走向星辰大海！"
const TXT_R2 := "除了新导弹项目的开发，我们还有其他问题。对军用或民用领域来说，长征二号就够用了。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
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
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -40)
			_add(W.I_SCIENCE, 200)
			_add(W.I_INDUSTRY, 200)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_INDUSTRY, 50)
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

