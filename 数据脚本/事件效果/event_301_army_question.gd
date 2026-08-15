## 原作 Event301.cs：军队问题？（中越战争后军队现代化，三选项）。
## 触发：全目录搜索无 this_num_event = 301 / Reset(301)；链外 REST 段，原版无自动条件。
## 差异：data[28] 用 W.I_USA_RELATIONS；文本来自 Events_text_en 索引 30-39。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "军队问题？"
const TXT_DESC := "在与越南的战争中，解放军展示了自己远不是最好的一面。不幸的是，我们不能再否认事实了，因此，军队现代化已刻不容缓。当然，我们可以自力更生，但有些党员建议我们寻求旧敌的帮助......"
const TXT_OPT0 := "军队没有问题。要为战败负责的是党内的叛徒，我们得处理他们！"
const TXT_OPT1 := "确实，我们需要重整武备。下令紧急启动军队现代化和新型武器的研制。"
const TXT_OPT1_DIS := "真是不幸，我们没有现代化军队的力量。"
const TXT_OPT2 := "让我们转而向美国寻求帮助。"
const TXT_OPT2_DIS := "帝国主义者的帮助绝不可接受！"
const TXT_R0 := "很明显，我们的军队已表现出了最好的一面，他们英勇地同敌人作战。但是，对失败负有责任的人就藏在党内，他们需要被加急处理！"
const TXT_R1 := "我们决定紧急开始军队现代化建设。几个月后，79式坦克和歼8截击机便进入了测试阶段。军队内部也开始了人事变动，所有表现不佳的部队指挥官都被降职或送去再培训。"
const TXT_R2 := "与美国就我军现代化问题的谈判是通过封闭渠道展开的，在几个月之内，美国最新的坦克和作战飞机开始服役。士兵们现在正在西方教官的帮助下接受训练。我们的军队将为下一场战争做好更充分的准备，即使在苏联眼里我们现在看起来像帝国主义的走狗。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var budget := world.数值表[W.I_BUDGET] if world.数值表.size() > W.I_BUDGET else 0
	var reserve := world.数值表[W.I_RESERVE] if world.数值表.size() > W.I_RESERVE else 0
	var industry := world.数值表[W.I_INDUSTRY] if world.数值表.size() > W.I_INDUSTRY else 0
	var usa_rel := world.数值表[W.I_USA_RELATIONS] if world.数值表.size() > W.I_USA_RELATIONS else 0
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if budget + reserve >= 50 and industry >= 500:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if usa_rel >= 700 and budget + reserve >= 80:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -300)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -30)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -60)
			_add_relation(EmpireData.USA, 120)
			_add_relation(EmpireData.USSR, -200)
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


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _mod_active(idx: int) -> bool:
	var w := ws if ws != null else GameManager.world
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	ws.leader.face_type = p.face_type
	if p.face_parts.size() >= 8:
		ws.leader.face_parts = p.face_parts.duplicate()
	ws.leader.jacket = p.jacket

