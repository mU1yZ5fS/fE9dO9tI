extends "res://数据脚本/event_script_base.gd"

## 原作 Event333.cs：外国企业。触发：ReqEventForDLC02.cs:572-575 —— SEZ 标记且日期>=1981.8.24。

const TXT_TITLE := "外国企业"

const TXT_DESC := "不久前，我们便允许外国企业在我国活动，现在一些党员要改变他们的经营条件。我们要怎么做？是为了国家和人民的利益，大幅提高对外企尊重工人权利的要求，并令其为国家工作，还是为了外交政策的成功而与国际资本达成合作，完全对其免税？"

const TXT_OPT0 := "对其征税便可。"
const TXT_OPT1 := "收紧要求。"
const TXT_OPT2 := "对其免税。"

const TXT_R0 := "没有必要用奇奇怪怪的要求把外国人吓跑。只要让他们在法律框架内，按照自己认为合适的方式纳税和做生意就行了。"
const TXT_R1 := "不，我国的利益要比外国公司的贪欲重要得多。因此，我们应当为他们指定生产规章制度、对员工设定较高的劳动保障标准，并要求其强制分担国家责任。"
const TXT_R2 := "外国人越多越好！为此，我们甚至会免征他们未来20年的税收，对他们提出任何要求都是不可接受的！"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(0, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_LIVING, 50)
			_add_relation(0, -250)
			_add(W.I_DIPLO, 100)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, -100)
			_add_relation(0, 150)
			_add(W.I_BUDGET, 50)
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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set(index: int, value: int) -> void:
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
