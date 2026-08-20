extends "res://数据脚本/event_script_base.gd"

## 原作 Event346.cs：在军委会中任职的平民。触发：ReqEventForDLC02.cs:612-615 —— 日期>=1981.6.11。




const TXT_R0 := "当然，这些公民的意见是非常重要的，但不要忘记，军事问题还是要归军委会解决。其余领域有其他机构去决定：军事工业联合体的雇员可以在其企业的理事会上发言，士兵的家属们也可以在妇委会上发言。如果我们允许在军队中进行这种选举，那么我们将一无所获，到头来只能招来士兵们闲谈中的不满。"
const TXT_R1 := "军队对我们很重要。但军队不仅包括武器和士兵。若是没有数百万人奋力生产最为普通的机关枪，军队便无法存在，更不用说更为复杂的武器了。军队也离不开军人的家庭，因为并非所有军人都一心为国。倘若没有一个协调所有与军队有关问题的委员会，我们就会左支右绌，毫无办法可言。要是为了避免风言风语，你可以干脆禁止讨论与军队无关的问题。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_BUDGET, 50)
			_add(W.I_ARMY, -250)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_DIPLO, -20)
			_add(W.I_LIVING, 25)
			if d.size() > W.I_MIL_DOCTRINE and d[W.I_MIL_DOCTRINE] < 33:
				_add(W.I_MIL_DOCTRINE, 1)
			_set_modifier_active(33)
			context["result_text"] = TXT_R1





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
