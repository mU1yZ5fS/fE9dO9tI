extends "res://数据脚本/event_script_base.gd"

## 原作 Event350.cs：劫持米格-25。选项0原版按 agents>=50 动态启用/销毁。触发：ReqEventForDLC02.cs:622-625 —— 日期>=1979.6.9。




const TXT_R0 := "在苏联空军基地，两架米格-25截击机在夜间升空，因为一架中国飞机越过了苏联边界。那架不知名的间谍飞机很快就被驱赶回了中国领空。但是，在返回机场时，其中一架苏联飞机却突然转向中国方向，并开始加速飞离。几分钟后，他便进入了中国领空。防空部队没有击落叛逃者飞机，因为他们事先接到了警告，在实际上他们也没有这个能力。着陆后，飞行员向中国当局投降。与苏联的关系受到了很大影响，但军方将能借此改良我们的飞机。"
const TXT_R1 := "没必要劫机，这将破坏与苏联的关系。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	if _dyn_ok(world):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], "我们扎得不够深。")


func _dyn_ok(w: WorldState) -> bool:
	@warning_ignore("shadowed_variable_base_class")
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




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
