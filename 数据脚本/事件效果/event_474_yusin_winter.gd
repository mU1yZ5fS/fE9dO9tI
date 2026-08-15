extends "res://数据脚本/event_script_base.gd"

## 原作 Event474.cs：维新之冬（韩国釜马事态三选项）。
## 触发：ReqEventForDLC02.cs:1439-1441 —— DATE_AFTER 1979.10.10；fire_only_once 承担 !event_done[474]。
## 差异：SubGosstroy→sub_government；Torg→对华贸易。

const TXT_TITLE := "维新之冬"
const TXT_DESC := "根据我们和朝鲜特工所知道的消息，韩国的维新政体持续了多年，期间反对声音不断，在1979年9月，因反对党党首金泳三议员被驱逐出国会而导致反对派抗议规模越来越大，釜山和马山的工人，学生和市民开始上街抗议，要求维新政权下台。10月，抗议规模越来越大，甚至有了全国抗议的可能。\n我们是否应该帮釜马的市民们一把，让南朝鲜独裁政权垮台，亦或者是选择支持朴正熙政权？"
const TXT_OPT0 := "给市民们输送武器"
const TXT_OPT0_DIS := "我们有心无力啊"
const TXT_OPT1 := "支持朴正熙政权"
const TXT_OPT1_DIS := "我们不能帮助这个独裁者"
const TXT_OPT2 := "与我无关"
const TXT_R0 := "在我们和朝鲜特工的帮助下，釜马地区的市民拿到了枪，开始反抗维新政权。但是与此同时，南朝鲜伪军第1，3，5空输特战旅团和海军陆战队第一师开始对釜马地区发起进攻，最后被平息，有五百多人被杀害，三千多人被捕。在之后，情报部长金载圭在宫井洞将朴正熙和车智澈杀死，成立以郑升和为首的新政府，但是随后便被保安司令部全斗换发动的政变赶下台。"
const TXT_R1 := "我们选择高调支持韩国。之后维新政权颁布戒严令，并调出1，3，5空输特战旅团和海军陆战队第一师进行镇压，最终有约一千人被捕，釜马事件平息。与此同时，我们提前获悉了韩国情报部长金载圭试图刺杀朴正熙，并提醒了朴正熙，最后金载圭在宫井洞被捕并被处死。韩国很感激我们，并开始与我们进行贸易，我们也顺水推舟，帮助韩国与朝鲜进行联系，并再次进行南北谈判，朝鲜对我们的行为略有不满。"
const TXT_R2 := "10月18日，维新政权颁布戒严令，调出1，3，5空输特战旅团和海军陆战队第一师进行镇压，最终有约一千人被捕，釜马事件平息。10月26日，情报部长金载圭在宫井洞将朴正熙，车智澈杀死，随后被捕并被秘密审判处决，在12月12日，保安司令部长官全斗焕发动政变，夺取了政权。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or event_def.options.size() < 3:
		return
	var d := world.数值表
	var agents := d[W.I_AGENTS] if d.size() > W.I_AGENTS else 0
	var army := d[W.I_ARMY] if d.size() > W.I_ARMY else 0
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var opt := event_def.options
	if agents >= 50 and army >= 50:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if agents >= 50 and line56 >= 2:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var korea := _country(46)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if korea != null:
				korea.sub_government = 7
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -10)
			ws.influence_prc += 10
		1:
			context["result_text"] = TXT_R1
			if korea != null:
				korea.sub_government = 9
				korea.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -100)
		2:
			context["result_text"] = TXT_R2
			if korea != null:
				korea.sub_government = 7



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

