extends "res://数据脚本/event_script_base.gd"

## 原作 Event340.cs：地方自治。原版无自动条件（决策/其他事件链手动触发）。




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





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
