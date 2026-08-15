extends "res://数据脚本/event_script_base.gd"

## 原作 Event472.cs：巨熊冬眠（单选项）。
## 触发：ReqEventForDLC02.cs:1429-1431 —— 复合条件（含 num2<3 循环计数）用 trigger_script
##   evaluate(world) 表达；fire_only_once 承担 !event_done[472]。
## 差异：dev→development；isOVD/isSEV/okb/econ/prosov→set_tag。

const TXT_TITLE := "巨熊冬眠"
const TXT_DESC_BASE := "新任苏联领导人米哈伊尔·戈尔巴乔夫上任之初，便遭遇来自中国的巨大压力：在中国的干涉下，罗马尼亚、波兰、匈牙利、保加利亚纷纷选择离开经互会和华沙条约。而最终，他连莫斯科在东欧地区最忠诚的盟友也未能保住：随着"
const TXT_DESC_DEV1 := "确认新国家的完全中立地位的德国统一计划的通过，民主德国就此在政治版图上消失。"
const TXT_DESC_DEV2 := "甚至没有确认新国家的中立地位的德国统一计划的通过，民主德国就此在政治版图上消失。"
const TXT_DESC_DEV3 := "早已选择“背叛”的民主德国主导统一计划的通过，两个德国对立的局面就此结束。"
const TXT_DESC_TAIL := "\n因此，华沙条约组织本身的存在都已经成为了问题。在1985年，原本应当被续签的，延续30余年的《友好合作互助条约》被修订；原本在筹划的相关庆祝活动也被取消。戈尔巴乔夫不得不表示，这只是苏联与美国同中国和解的“善意姿态”，但所有人都知道，莫斯科真正的盟友只剩下与苏维埃乌克兰有些微接壤的捷克斯洛伐克。\n而在美国也解散北约的前提下，我们似乎可以说，持续30年的冷战就此结束了......"
const TXT_OPT0 := "胜利者只有一个！"
const TXT_R0 := "戈尔巴乔夫的“姿态”，被苏联共产党内的保守派政治家给视为对伟大卫国战争时期成就的背叛与亵渎。事实上，正是这一场大战，直接导致了世界社会主义阵营的建立。然而，现在还没有人谈论废除经济互助委员会的事宜，尽管该党已经在为该组织的改革计划做准备，但他们能够改变这种格局吗？"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null:
		return
	var gdr := world.get_country_by_legacy_index(17)
	var west := world.get_country_by_legacy_index(16)
	var text := TXT_DESC_BASE
	if gdr != null and gdr.development == 1:
		text += TXT_DESC_DEV1
	elif gdr != null and gdr.development == 2:
		text += TXT_DESC_DEV2
	elif gdr != null and gdr.development == 3 and (west == null or not west.has_tag("亲苏")):
		text += TXT_DESC_DEV3
	text += TXT_DESC_TAIL
	event_def.description = text



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("ovd") and c.has_tag("亲中"):
					c.set_tag("ovd", false)
					c.set_tag("okb", true)
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("sev") and c.has_tag("亲中"):
					c.set_tag("sev", false)
					c.set_tag("econ", true)
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("ovd"):
					c.set_tag("ovd", false)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null and ws.empires[EmpireData.USSR].power > 0:
				_set_power(EmpireData.USSR, 0)



func evaluate(world: WorldState) -> bool:

	if world == null or world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	if world.completed_event_ids.has("event_433"):
		return false
	if world.empires[EmpireData.USSR].current_leader != 6:
		return false
	for idx in [2, 5, 4, 6]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.has_tag("ovd"):
			return false
	var france := world.get_country_by_legacy_index(21)
	if france != null and france.has_tag("soc_eu"):
		return false
	var gdr := world.get_country_by_legacy_index(17)
	var west := world.get_country_by_legacy_index(16)
	var ok_dev := false
	if gdr != null:
		ok_dev = gdr.development == 1 or gdr.development == 2 or (gdr.development == 3 and (west == null or not west.has_tag("亲苏")))
	if not ok_dev:
		return false
	var uk := world.get_country_by_legacy_index(51)
	if uk != null and uk.has_tag("nato"):
		return false
	var china := world.get_country_by_legacy_index(1)
	if china != null and china.has_tag("sev"):
		return false
	var num2 := 0
	for idx in [0, 27, 28, 88, 89, 90, 91]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.有驻军基地:
			num2 += 1
	if num2 >= 3:
		return false
	var poland := world.get_country_by_legacy_index(4)
	if poland != null and poland.sub_government == 19:
		return false
	return true



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _set_data(index: int, value: int) -> void:
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

