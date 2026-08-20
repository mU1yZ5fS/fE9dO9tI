extends "res://数据脚本/event_script_base.gd"

## 原作 Event341.cs：公民权问题。触发：ReqEventForDLC02.cs:592-595 —— 日期>=1980.9.10。




const TXT_R0 := "只有具有中国血统的中国人才能成为中华人民共和国的公民！毕竟，我国是中国人的国家，也是为中国人服务的国家！"
const TXT_R1 := "凡在我国领土上出生的人，均可被视为中华人民共和国公民。还是那样，不要忘了国际主义......并且正因如此，我们才能更牢固地将外国专家与我们的国家捆绑在一起！"
const TXT_R2 := "中华人民共和国公民既可以是在我国境内出生的人，也可以是一般意义上的华裔。因此，在不忘国际主义和我国境内外国人的情况下，我们在实际上对所有我们人民居住的领土都拥有了权力。台独势力没几天好日子过了！"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_MANPOWER, -150)
			_add(W.I_WAR_SUPPORT, 300)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PEOPLE_SUPPORT, 25)
			_add(W.I_MANPOWER, 25)
			_add(W.I_WAR_SUPPORT, -50)
			_add(W.I_POPULATION, 1)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_MANPOWER, 50)
			_add(W.I_WAR_SUPPORT, -150)
			_add(W.I_POPULATION, 5)
			_add_relation(0, -150)
			context["result_text"] = TXT_R2





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
