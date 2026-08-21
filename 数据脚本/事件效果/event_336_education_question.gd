extends "res://数据脚本/event_script_base.gd"

## 原作 Event336.cs：教育问题。原版无自动条件（决策/其他事件链手动触发）。




const TXT_R0 := "不久，中国科学院便与西方国家和苏联的大学和研究机构缔结了若干协定。根据协定，最重要的科学期刊将会在中华人民共和国的领土上出版，我们的科学家也能借此跟上世界科学的大势。当然，这不算太有用，但至少有点用。"
const TXT_R1 := "9月份，我们第一次派遣学生去国外大学学习。当然，在此之前，他们得突击学习外语——英语、俄语、日语、德语等。当然，结出硕果得等几年，但学生们对此非常高兴，不过我们也冒着风险，学生们回归时可能不仅带回了知识，也可能带回了资本主义的宣传。"
const TXT_R2 := "我们在教育与科学方面投入了巨额资金，许多来自其他国家的专家对我们的国际项目展露了兴趣。事实证明，从资本主义国家和苏联以更高的工资与稳定的保证吸引科学家和工程师并不算难事。当然，由于我们不同寻常的生活方式而产生的问题仍是不可避免的。但结果将是惊人的！"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_SCIENCE, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -20)
			_add(W.I_THOUGHT_FREEDOM, 30)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_INDUSTRY, 30)
			_add(W.I_SCIENCE, 350)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_INDUSTRY, 60)
			_add(W.I_SCIENCE, 600)
			context["result_text"] = TXT_R2





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
