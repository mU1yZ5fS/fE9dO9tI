extends "res://数据脚本/event_script_base.gd"

## 原作 Event340.cs：地方自治。原版无自动条件（决策/其他事件链手动触发）。

const TXT_TITLE := "地方自治"

const TXT_DESC := "党被要求增加人民大会和其他区域机构的地方自治权力。一方面，这能让党少负一些问题的责任，也能赢得渴望变革的人民们的拥护，但另一方面，这对那些治理的没那么好的地区是个问题......"

const TXT_OPT0 := "增加自治权。"
const TXT_OPT1 := "保持原样。"

const TXT_R0 := "我们的人民已接受了充分的教育，能够处理自己的问题。您也可以随时从中央派遣特派员来恢复秩序。总的来说，改革得到了落实。即使一些地区不得不处理他们堆压的问题，但总的来说，情况大体没什么改变，甚至有所改善。总之，人民高兴就好。"
const TXT_R1 := "我们不需要改革。不是所有的行政单位都有妥善管理这个国家的能力......那些治理不善的地区会引发国内问题，从而波及国家的其它地区，这是我们所能得到的最坏结果！"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_THOUGHT_FREEDOM, 30)
			_add(W.I_AGRICULTURE, -30)
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
