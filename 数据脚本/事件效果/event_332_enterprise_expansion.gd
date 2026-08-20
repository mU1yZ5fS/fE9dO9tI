extends "res://数据脚本/event_script_base.gd"

## 原作 Event332.cs：企业扩张。原版无自动条件（决策/其他事件链手动触发）。




const TXT_R0 := "不，这么做百害无一利。是的，我们是有一些经济部门，其中的现有企业无法向人民提供充足的产品。但重要的是，我们要搞清楚，倘若让其他行业的巨头进入这些领域，那些正经营着这些行业的小公司就会倒闭，垄断便会产生。私营经济活动的扩大也将不可避免地导致主要经济领域的生产能力的减弱......"
const TXT_R1 := "是的，这个问题应当解决。不过，人民与国家的需要比市场竞争的思想更重要。尽管有一些企业被迫关门，但情况不久就稳定下来了。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_LIVING, 50)
			_add(W.I_INDUSTRY, -20)
			context["result_text"] = TXT_R1





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
