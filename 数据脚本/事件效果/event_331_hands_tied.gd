extends "res://数据脚本/event_script_base.gd"

## 原作 Event331.cs：“束手束脚”。触发：ReqEventForDLC02.cs:567-570 —— econ_system>12 且日期>=1984.10.27。




const TXT_R0 := "这个问题毫无意义。一切都按部就班地运转着，过火行为的发生是因为个别管理者的愚蠢。让我们转而处理更重要的问题吧。"
const TXT_R1 := "私营企业主被判有罪，因为正是他们利用着自己的自由，拒绝为国家的利益工作。因此，有必要处理掉一批最失败的企业，并加强企业与国家间的融合。"
const TXT_R2 := "当然，国家有罪，它阻止了商业的蓬勃发展！我们应该取消限制，让企业家自己解决企业的问题！让人民对物价上涨不满去吧......"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, -150)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, 100)
			_add(W.I_PARTY_SUPPORT, -250)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_ECON_SYSTEM, -1)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, -50)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, -250)
			_add_relation(0, 50)
			if d.size() > W.I_ECON_SYSTEM and d[W.I_ECON_SYSTEM] < 15:
				_add(W.I_ECON_SYSTEM, 1)
			context["result_text"] = TXT_R2





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
