extends "res://数据脚本/event_script_base.gd"

## 原作 Event338.cs：国民党左翼。原版无自动条件（决策/其他事件链手动触发）。




const TXT_R0 := "他们的条件很诱人......而且，这些宗派主义者明白过去几年来领导班子的一切错误，真正懂得孙中山思想的意义。在台湾分裂分子队伍之中，他们将成为“我们的人”。"
const TXT_R1 := "当然，这些国民党人比别人好得多，但这有什么意义呢？你明白他们正打着接受我们国家的幌子，要我们主动承认分裂分子吧？让他们从哪来回哪去！"
const TXT_R2 := "当然，国民党犯下了很多错误。但是为什么不让这个派系合法运作呢？他们仍然承认社会主义和我党。他们也明白他们的先辈们错在哪。将一个好政党合法化能够改善我国的状况"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_INFLUENCE, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PARTY_SUPPORT, 30)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PARTY_SUPPORT, -30)
			_add(W.I_THOUGHT_FREEDOM, 30)
			for f in ws.factions:
				f.is_enabled = true
			context["result_text"] = TXT_R2





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
