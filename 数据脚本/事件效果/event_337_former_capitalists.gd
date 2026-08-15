extends "res://数据脚本/event_script_base.gd"

## 原作 Event337.cs：前资本家。原版 kolvo_variant=3 但仅设置两个按钮，按实际可选项移植为2。原版无自动条件（决策/其他事件链手动触发）。

const TXT_TITLE := "前资本家"

const TXT_DESC := "在文化大革命后，还有许多前资本家活了下来。党需要决定如何对待这类公民。一方面，人们认为他们十分危险，要求对其加以控制，但另一方面，毕竟今时不同往日，我们也能冷静下来了，而且，这种措施并不完全人道......"

const TXT_OPT0 := "让他们接着被监视。"
const TXT_OPT1 := "冷静一下，放他们条生路。"

const TXT_R0 := "前资本家仍然十分危险！忘记过去他们如何组织反革命组织，如何与外国情报机构合作，如何组织叛乱是愚不可及的。近来他们还在那么做。他们太过危险。"
const TXT_R1 := "几十年过去了。指望大多数前资产阶级还抱着老一套的心态是愚蠢的。现在他们只是勤劳的普通公民。是时候冷静下来了。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PEOPLE_SUPPORT, -50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_THOUGHT_FREEDOM, 30)
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
