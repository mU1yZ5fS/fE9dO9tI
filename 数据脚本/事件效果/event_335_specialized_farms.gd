extends "res://数据脚本/event_script_base.gd"

## 原作 Event335.cs：“专业化农场”。触发：ReqEventForDLC02.cs:582-585 —— econ_system>12 且日期>=1984.6.13。

const TXT_TITLE := "“专业化农场”"

const TXT_DESC := "农民群体中开始出现分化，或者说白了，就是阶层分化。目前，约20%的农场归富有的公民所有。由于这些农场大多与农业领域的特别部门有关，党决定将这些农场称为“专业化农场”。党需要决定如何处理这个问题，或是是否有必要处理这一问题？"

const TXT_OPT0 := "就这样吧，反正他们也剥削不了别人。"
const TXT_OPT1 := "为他们减税，给他们雇佣工人和向国外销售产品的机会。"
const TXT_OPT2 := "进行检查，增加税收。"

const TXT_R0 := "嗯，有就有吧。这个问题并没有认真讨论的必要。这些农场占比挺高，这证明它们的存在是绝对正常的！这些人都是老实人，他们的一切是通过劳动挣得的。"
const TXT_R1 := "我们得明白，这些农场的主人是我们国家的未来。即勤劳、进取、熟练的所有者。他们将对我们的农业企业起支撑作用。他们需要我们的帮助，以保护他们摆脱野蛮竞争的问题和其他农民的攻击。"
const TXT_R2 := "我们可以看到农村出现了新的阶级分化。我们得放弃“专业化农场”的委婉说法，更直截了当地称呼他们。有必要对他们进行全面检查，至少得有三分之一的农场要被淘汰，其余的也不能让他们积累这么多财富。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_PEOPLE_SUPPORT, -50)
			_add(W.I_DIPLO, -50)
			_add(W.I_AGRICULTURE, 30)
			_add_power(0, -15)
			_add_power(1, -15)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, 20)
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_PARTY_SUPPORT, -150)
			_add(W.I_ECON_SYSTEM, -1)
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
