extends "res://数据脚本/event_script_base.gd"

## 原作 Event452.cs：印度支那的和平？（柬越和解，二选项）。
## 触发：ReqEventForDLC02.cs:382-384 —— event_done[451] && resultOfEvents[451]==0
##   && DATE_AFTER 1978.6.1；fire_only_once 承担 !event_done[452]。
## 差异：vietnampeace→global_flags；SOV_PRC_PartiesConnection→I_COMMUNICATIONS。

const TXT_TITLE := "印度支那的和平？"
const TXT_DESC := "主席同志！波尔布特被成功推翻后，印度支那的和平有了很大的希望。起义的其中一位密谋者索平在过去是柬共亲越派的一位重要成员，越南人曾希望他能领导一场反对波尔布特的起义——而这件事已经在我们和越南的共同支持下做到了。新的柬埔寨领导层已经结束了过激政策，两国正在开始尝试寻求真正的和解。而在推翻波尔布特的政策上，我们与越南在此前已经达成共识并进行过合作，这或许也是解决我们和越南之间冲突的机会？"
const TXT_OPT0 := "尝试开展推进印支和平谈判"
const TXT_OPT1 := "我们无能为力"
const TXT_R0_A := "由于新的柬埔寨政府有不少成员与越南方面有良好关系，以及我们同苏联关系的回暖，在我们的斡旋下，新柬埔寨政府和越南最终达成了和解，并签订了边界协定和几项合作条约，两国关系得以正常化，柬埔寨真正开始了恢复和发展。同时由于越共亲华派的努力和苏联寻求解冻中苏关系的施压，我们和越南之间也成功达成了和平，越南的排华政策和双方的边境冲突都结束了，华人被允许自愿回国，越南也同我们签订了几项合作协定。"
const TXT_R0_B := "虽然新的柬埔寨政府有不少成员与越南方面有良好关系，但是我们在柬越之间组织的谈判并未成功——新柬埔寨的领导人是亲中的毛派分子，越共认为这还是会威胁到他们；以及越南统治集团的亲苏路线和我们同苏联的恶劣关系不容。我们和越南的缓和谈判也因为缺乏谈判基础而失败了。柬埔寨真正开始了恢复和发展，但是战争的阴云仍未散去。"
const TXT_R1 := "虽然新的柬埔寨政府有不少成员与越南方面有良好关系，但是柬越之间的自行组织的谈判并未成功——新柬埔寨的领导人是亲中的毛派分子，越共认为这还是会威胁到他们；以及越南统治集团的亲苏路线和柬共新领导层的毛主义路线不容。柬埔寨真正开始了恢复和发展，但是战争的阴云仍未散去。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var vietnam := _country(11)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null and ws.empires[EmpireData.USSR].relations >= 500:
				context["result_text"] = TXT_R0_A
				_add(W.I_PARTY_SUPPORT, -100)
				ws.influence_prc += 10
				_add_relation(EmpireData.USSR, 200)
				_tag(11, "对华贸易", true)
				ws.set_flag("vietnampeace", true)
				_add(W.I_COMMUNICATIONS, 40)
			else:
				context["result_text"] = TXT_R0_B
				ws.influence_prc -= 10
		1:
			context["result_text"] = TXT_R1
			ws.influence_prc -= 10



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

