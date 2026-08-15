extends "res://数据脚本/event_script_base.gd"

## 原作 Event344.cs：兵役制度。触发：ReqEventForDLC02.cs:602-605 —— 日期>=1984.5.5。

const TXT_TITLE := "兵役制度"

const TXT_DESC := "有人提议改变解放军的服役期限。但如今的问题是应征士兵应当服役多长时间。一方面，就训练一个士兵而言，服役一年并不算多，而且还不够，但另一方面，哪怕是两到三年的服役期限也已经对经济造成了沉重的打击，减缓了我们的发展速度。那么，我们是否可以完全取消征兵制度呢？"

const TXT_OPT0 := "职业军队便可。"
const TXT_OPT1 := "一年兵役制。"
const TXT_OPT2 := "三年兵役制。"
const TXT_OPT3 := "社会军事化。"

const TXT_R0 := "经过党内讨论，我们决定取消军队的征兵制度。取而代之的是，年轻人将在教育机构中接受最低限度的军事训练，保卫国家的重任将由配备先进武器和军事装备的专业且训练有素的军队担负。"
const TXT_R1 := "当然，一年兵役尚且不够，许多军方人士也是这么说的。但我们要明白，如今对我国来说，在工业和一般行业中工作的工人更为重要。军队会毁掉年轻人，许多人在此之后将无法回归正常生活。"
const TXT_R2 := "当然，三年兵役将会严重打击国家经济，并使其失去一批劳动力。但实业家将被迫下一番力气提高劳动力质量并解决自动化问题。而经过多年的服役，一位青年可以成为一名职业军人，为战场上一切可能出现的任务与困难做好准备。"
const TXT_R3 := "我们先得明白我国周边群狼环伺的现实情况。在北边西边——是苏修分子，在东边——是美帝傀儡，在南边——是印度，他们都妄想夺走我们的土地，印度支那之上零零碎碎的独立政权也包括在内。我们的国家亟需保护，而这只能通过全社会的全面动员和建立朝鲜模式的人民军队来解决！"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_set(W.I_MIL_DOCTRINE, 33)
			_add(W.I_PARTY_SUPPORT, -150)
			_add(W.I_BUDGET, -50)
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_ARMY, 50)
			context["result_text"] = TXT_R0
		1:
			_set(W.I_MIL_DOCTRINE, 32)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_BUDGET, -20)
			_add(W.I_PEOPLE_SUPPORT, -25)
			_add(W.I_ARMY, 50)
			context["result_text"] = TXT_R1
		2:
			_set(W.I_MIL_DOCTRINE, 31)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_BUDGET, -5)
			_add(W.I_PEOPLE_SUPPORT, -50)
			_add(W.I_ARMY, 50)
			context["result_text"] = TXT_R2
		3:
			_set(W.I_MIL_DOCTRINE, 30)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, -75)
			_add(W.I_ARMY, 50)
			context["result_text"] = TXT_R3



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
