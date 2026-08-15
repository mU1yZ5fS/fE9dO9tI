extends "res://数据脚本/event_script_base.gd"

## 原作 Event342.cs：人权委员会。触发：ReqEventForDLC02.cs:597-600 —— 日期>=1979.7.20。

const TXT_TITLE := "人权委员会"

const TXT_DESC := "在我国在联合国获得其应有的地位后，有人提议我国加入人权委员会。当然，人权是很重要，是我们珍视保护之物，但这些国际机构里面大多是亲西方的吹牛皮代表......我们可以简简单单地加入他们，走与西方和解的道路，或者我们可以带有挑衅意味地拒绝该提议，以此博得众多帝国主义暴政受害者的支持！"

const TXT_OPT0 := "用矫饰的言辞拒绝。"
const TXT_OPT1 := "加入。"

const TXT_R0 := "我国代表团对加入该委员会的建议作了发言，谴责了诸如此类的“国际”委员会。在过去的30年里，他们之中没有一个人注意到西方帝国主义在亚洲，尤其是在印度支那犯下的罪行。他们只不过是西方帝国主义的马前卒！我们尊重人权，所以我们不会加入这些组织！"
const TXT_R1 := "当然，中国应该走国际合作的道路，维护和平与稳定。中华人民共和国签署了一切人权公约，并加入了相关国际组织。当然，按照他们的指示去行事有些难度......肃清反对派也变难了......但未来将一帆风顺！"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, 150)
			_add_relation(0, -250)
			_add_relation(1, -300)
			_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, -50)
			_add_relation(0, 50)
			_add_relation(1, 50)
			_set_modifier_active(37)
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
