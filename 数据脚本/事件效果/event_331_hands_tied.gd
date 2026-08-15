extends "res://数据脚本/event_script_base.gd"

## 原作 Event331.cs：“束手束脚”。触发：ReqEventForDLC02.cs:567-570 —— econ_system>12 且日期>=1984.10.27。

const TXT_TITLE := "“束手束脚”"

const TXT_DESC := "在中央委员会定期全体会议上，规范城市企业活动的问题被提了出来。据称，由于国家的不断干预，这些企业“束手束脚”，无法正常运作。但也许恰恰相反，他们效率低下的原因是他们太过自由了？群众也这么觉得，与之相对，他们要求最终将小资产阶级处理掉，因为小资产阶级拒绝充分履行自己的义务，但同时又常常侵犯雇工的权利。"

const TXT_OPT0 := "什么都不做。"
const TXT_OPT1 := "加强监管。"
const TXT_OPT2 := "在未来不加干涉。"

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
