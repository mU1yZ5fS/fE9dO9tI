## 原作 Event308.cs：大圈（港澳犯罪集团合作，两选项）。
## 触发：全目录搜索无 this_num_event = 308 / Reset(308)；链外 REST 段，原版无自动条件。
## 差异：modifies[3].active→_mod_active(3)；party_number[0]→factions[0].support；
##  禁用项文本按 data[56]>2 / 预算+储备<50 两分支复刻；文本来自 Events_text_en 索引 85-91、122 与 Event308.cs 内联。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "大圈"
const TXT_DESC_INACTIVE := "文革失败后，红卫兵被遣散，其中一些人锒铛入狱。几年来，极左派在现代中国已无立足之地，如今，他们在香港成立了犯罪集团，其在东南亚和北美国家的影响力也愈发强大。我们可以与他们建立合作关系，以更好地影响外国政策。当然，天上不会掉馅饼，黑手党也会想干涉我党事务。"
const TXT_DESC_ACTIVE := "文革的混乱时期，全国一些地区的造反派被大规模镇压，其中就有一批在广州的造反派出逃到了港澳地区。如今，他们在香港成立了犯罪集团，其在东南亚和北美国家的影响力也愈发强大。我们可以与他们建立合作关系，以更好地影响外国政策。当然，天上不会掉馅饼，黑手党也会想干涉我党事务。"
const TXT_OPT0 := "没这个必要。"
const TXT_OPT1 := "开始与麻匪洽谈。"
const TXT_OPT1_DIS_LINE := "这种想法是文明国家无法接受的！"
const TXT_OPT1_DIS_BUDGET := "我们绝对没有那么多钱。"
const TXT_R0 := "我们不能同黑手党同流合污。最好还是把他们成员的名单交给外国警方。"
const TXT_R1 := "中国商务人士通常会在一家香港餐馆里见面。至少从外人看来是这样。事实上，我们在此与犯罪集团的领导人进行了幕后谈判，结果是我们向他们承诺在他们的犯罪活动中给予庇护，并将他们的代表提拔到我们的队伍中，而他们反过来又同意代表我们在美国的利益，并“说服”当地政客相信我们的善意。尽管一些党员对这一决定表示不满，但我们现在有了在海外宣传我们利益的有力工具。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var mod3 := _mod_active(3)
	if mod3:
		event_def.description = TXT_DESC_ACTIVE
	else:
		event_def.description = TXT_DESC_INACTIVE
	var budget := world.数值表[W.I_BUDGET] if world.数值表.size() > W.I_BUDGET else 0
	var reserve := world.数值表[W.I_RESERVE] if world.数值表.size() > W.I_RESERVE else 0
	var line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if budget + reserve >= 50 and line <= 2:
		_enable(opt[1], TXT_OPT1)
	elif line > 2:
		_disable(opt[1], TXT_OPT1_DIS_LINE)
	else:
		_disable(opt[1], TXT_OPT1_DIS_BUDGET)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_INFLUENCE, 100)
			_add(W.I_BUDGET, -30)
			if ws.factions.size() > 0 and ws.factions[0] != null:
				ws.factions[0].support += 50
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

