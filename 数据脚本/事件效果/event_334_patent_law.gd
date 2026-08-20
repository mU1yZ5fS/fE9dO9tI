extends "res://数据脚本/event_script_base.gd"

## 原作 Event334.cs：专利法。触发：ReqEventForDLC02.cs:577-580 —— econ_system>12 且日期>=1984.2.11。




const TXT_R0 := "专利法只会妨碍我们。是的，要是我们签署了专利法，我们就可以坐等利润滚滚来，但我们先得为“窃取”来的技术付出巨额代价。是谁提出了这个想法，真是胡说八道！？"
const TXT_R1 := "中华人民共和国很快就加入了世界专利体系。当然，这一开始就引起了诸多冲突，但在头一年，我国的发明就被外国应用，先前的后果是可以接受的。我国的名声也变好了些......"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add_relation(0, -150)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -150)
			_add_relation(0, 150)
			_add(W.I_DIPLO, -50)
			_set_modifier_active(36)
			_add(W.I_SCIENCE, 50)
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
