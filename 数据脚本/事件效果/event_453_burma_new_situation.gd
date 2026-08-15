extends "res://数据脚本/event_script_base.gd"

## 原作 Event453.cs：缅甸的新局势（单选项）。
## 触发：全目录无 this_num_event=453 / StartEvent(453) / event_done[453] 自动触发点；
##   按项目约定 trigger_conditions=[]（仅定义，待外部入口接入）。

const TXT_TITLE := "缅甸的新局势"
const TXT_DESC := "过去，我们在中缅边境援助了缅甸共产党（即白旗派）和部分民族地方武装以支持缅甸的共产主义运动。如今，我们对他们的支持已经越来越保守化——为了维持与缅甸政府的关系，对缅共的支持逐渐让步于现实外交。但是，1976年以来，缅甸进入了一个新的较为动荡的时期——在社会上，学校再次爆发了学生运动；在执政党内，吸纳的左翼分子逐渐与军事派系不和；军队内，反对派军官酝酿了对奈温的未遂阴谋。主席同志，或许这是一次新的机会！"
const TXT_OPT0 := "让我们在缅甸布下些许暗线"
const TXT_R0 := "在我们的干预下，左翼民族地方武装、红旗共产党余部最终达成了和解，同缅甸共产党合并，他们使用我们的新支援的武器挫败了缅军的围剿，并新占领了一些根据地；同时，我们的特工也为学生运动送去了武器支持，并帮助他们将学生运动与工人运动联合起来；我们也秘密与处于地下活动的民主派建立了联系，为他们送去了援助。更多的反对派加入了缅共领导的民族民主团结阵线。军政府对局势的恶化很不高兴。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0



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

