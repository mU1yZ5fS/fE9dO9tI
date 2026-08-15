extends "res://数据脚本/event_script_base.gd"

## 原作 Event473.cs：经互会的最后一日（二选项）。
## 触发：ReqEventForDLC02.cs:1434-1436 —— 复合条件（含 num2<3 循环计数）用 trigger_script
##   evaluate(world) 表达；fire_only_once 承担 !event_done[473]。
## 差异：empires[1].leaders[6].support-- 按索引守护；isSEV/prosov/econ/proprc→set_tag；
##   resultOfEvents[62] 用项目 event_id=inner_mongolia_problem。

const TXT_TITLE := "经互会的最后一日"
const TXT_DESC := "随着苏联内部危机的进一步加剧，戈尔巴乔夫无力继续担当“社会主义大家庭”的家长这一任务。在宣布苏联军队撤出东欧国家之后，经互会的去留也被提上了日程。在布达佩斯召开的大会上，苏联领导人米哈伊尔·戈尔巴乔夫宣布了惊人的消息：经互会将解散，各个成员国将自行寻找处理未来。也许我们可以趁机做点什么？"
const TXT_OPT0 := "趁机招揽经互会前成员国"
const TXT_OPT1_0 := "这就是和修正主义者沆瀣一气的下场！"
const TXT_OPT1_12 := "我们只能惊恐的看着老朋友的离去"
const TXT_OPT1_3 := "或许他们也和我们一样改革的话就好了"
const TXT_OPT1_4 := "这就是“共惨主义”的下场！"
const TXT_R0_BASE := "在我们的提议下，剩下的经济互助委员会成员国学习了罗马尼亚，波兰和匈牙利的经验，公开转向中华人民共和国的怀抱。中华人民共和国的实力将允许我们接手戈尔巴乔夫无法掌握的力量。我们将提供足够的资金，"
const TXT_R0_A := "为他们的经济去改革计划作准备。"
const TXT_R0_B := "为他们的经济改革计划作准备。"
const TXT_R1 := "很快，东欧国家的经济或多或少陷入了衰退，尤其是那些高度依赖苏联援助的国家。我们和苏联的贸易或多或少受到了些冲击。但这也是他们自找的路。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or event_def.options.size() < 2:
		return
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if line56 <= 0:
		_enable(opt[1], TXT_OPT1_0)
	elif line56 == 1 or line56 == 2:
		_enable(opt[1], TXT_OPT1_12)
	elif line56 == 3:
		_enable(opt[1], TXT_OPT1_3)
	else:
		_enable(opt[1], TXT_OPT1_4)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	_dec_ussr_leader_support()
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var line56 := _res(W.I_POLITICAL_LINE)
			if line56 <= 2:
				context["result_text"] = TXT_R0_BASE + TXT_R0_A
			else:
				context["result_text"] = TXT_R0_BASE + TXT_R0_B
			var res62 := _res_ev("inner_mongolia_problem", 0)
			for c in ws.countries:
				if c == null or not c.has_tag("sev"):
					continue
				c.set_tag("sev", false)
				c.set_tag("亲苏", false)
				var i := c.原版序号
				var excluded := i == 0 or i == 27 or i == 28 or i == 88 or i == 89 or i == 90 or i == 91 or i == 7 or i == 138
				var excl9 := i == 9 and res62 == 2
				if not excluded and not excl9:
					c.set_tag("econ", true)
					c.set_tag("亲中", true)
			for c in ws.countries:
				if c != null and c.has_tag("亲苏") and c.原版序号 != 7:
					c.set_tag("亲苏", false)
			_collapse_soviet_power()
			_add_power(EmpireData.USSR, -500)
			ws.influence_prc += 300
		1:
			context["result_text"] = TXT_R1
			for c in ws.countries:
				if c != null and c.has_tag("sev"):
					c.set_tag("sev", false)
			for c in ws.countries:
				if c != null and c.has_tag("亲苏"):
					c.set_tag("亲苏", false)
			_collapse_soviet_power()
			_add_power(EmpireData.USSR, -500)



func evaluate(world: WorldState) -> bool:

	if world == null or world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	if world.empires[EmpireData.USSR].current_leader != 6:
		return false
	var poland := world.get_country_by_legacy_index(4)
	if poland != null and poland.sub_government == 19:
		return false
	var bulgaria := world.get_country_by_legacy_index(7)
	if bulgaria != null and bulgaria.has_tag("ovd"):
		return false
	var china := world.get_country_by_legacy_index(1)
	if china != null and china.has_tag("sev"):
		return false
	if world.empires[EmpireData.USSR].power > -300:
		return false
	var num2 := 0
	for idx in [0, 27, 28, 88, 89, 90, 91]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.有驻军基地:
			num2 += 1
	if num2 >= 3:
		return false
	return true



func _dec_ussr_leader_support() -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null and ws.empires[EmpireData.USSR].leaders.size() > 6:
		ws.empires[EmpireData.USSR].leaders[6].support -= 1


func _collapse_soviet_power() -> void:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		if ws.empires[EmpireData.USSR].power > 0:
			ws.empires[EmpireData.USSR].power = 0


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _set(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

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

