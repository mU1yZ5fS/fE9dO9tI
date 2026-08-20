extends "res://数据脚本/event_script_base.gd"

## 原作 Event339.cs：海外同胞。触发：ReqEventForDLC02.cs:587-590 —— 日期>=1983.12.30。




const TXT_R0 := "当然，家人离散、民族破碎是不好。但大量人口的到来不会对经济和生活水平产生什么好的影响......就这样吧。"
const TXT_R1 := "党发表了一份示范性的声明，呼吁海外华人回归祖国。当然，有些人回国了，但那些已经身为其他国家公民的人仍然留在海外。还是那样，光说说是没用的。不过，这样也就足够了。"
const TXT_R2 := "由中华人民共和国政府启动的华侨返乡项目马上就开始运作了。早在第一年，便已有大约10万人回国，依照预期，总共会有几百万人回国。是的，为每个人提供住房和工作是件难事，但我们的劳动力多了。若是我们再考虑到在归国人民中有对我们有用、具有特殊技术专长的公民，这完全是笔合算买卖。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, 15)
			_add(W.I_THOUGHT_FREEDOM, 15)
			_add(W.I_POPULATION, 3)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_SCIENCE, 250)
			_add(W.I_BUDGET, -100)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_POPULATION, 44)
			context["result_text"] = TXT_R2



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
