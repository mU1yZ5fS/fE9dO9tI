extends "res://数据脚本/event_script_base.gd"

## 原作 Event350.cs：劫持米格-25。选项0原版按 agents>=50 动态启用/销毁。触发：ReqEventForDLC02.cs:622-625 —— 日期>=1979.6.9。

const TXT_TITLE := "劫持米格-25"

const TXT_DESC := "不久前，一名苏联叛逃者成功地劫持了一架最新的米格-25截击机，将其运到了日本。考虑到我们的工程师正在开发我国的歼-8截击机，对苏联飞机进行研究将对我们大有裨益。我们在苏联境内的特工可以说服那些对体制不满的人飞往中国境内。但这将恶化与苏联的关系，这架飞机值得我们的特工公开行动么？"

const TXT_OPT0 := "组织一次劫机。"
const TXT_OPT1 := "对苏关系更重要。"

const TXT_R0 := "在苏联空军基地，两架米格-25截击机在夜间升空，因为一架中国飞机越过了苏联边界。那架不知名的间谍飞机很快就被驱赶回了中国领空。但是，在返回机场时，其中一架苏联飞机却突然转向中国方向，并开始加速飞离。几分钟后，他便进入了中国领空。防空部队没有击落叛逃者飞机，因为他们事先接到了警告，在实际上他们也没有这个能力。着陆后，飞行员向中国当局投降。与苏联的关系受到了很大影响，但军方将能借此改良我们的飞机。"
const TXT_R1 := "没必要劫机，这将破坏与苏联的关系。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	if _dyn_ok(world):
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], "我们扎得不够深。")


func _dyn_ok(w: WorldState) -> bool:
	var d := w.数值表
	return d.size() > W.I_AGENTS and d[W.I_AGENTS] >= 50

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			_add_relation(1, -200)
			if not ws.techs.unlocked[18]:
				ws.techs.unlocked[18] = true
			elif not ws.techs.unlocked[23]:
				ws.techs.unlocked[23] = true
			else:
				_add(W.I_ARMY, 100)
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


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
