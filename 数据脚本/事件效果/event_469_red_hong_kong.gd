extends "res://数据脚本/event_script_base.gd"

## 原作 Event469.cs：红色香江（香港左派援助二选项）。
## 触发：ReqEventForDLC02.cs:432-434 —— BritLost && data[65]<=0；fire_only_once 承担 !event_done[469]。
## 差异：BritLost→global_flags；names1/names2 拼接→ws.leader.name_display。

const TXT_OPT0_DIS := "我们自己都不放心党内的左派！"
const TXT_R0_P1 := "在"
const TXT_R0_P2 := "主席的直接指示下，我们开始重启对香港左派同志们的援助工作。在深圳河畔，广东的军事基地向香港方面大量输送武器、装备，甚至越境协助香港同志们的斗争。很快，香港就陷入了新一轮的罢工潮，原本稳定下来的形势如今对港英政府而言正在向愈发严重的方向一路狂奔。尽管我们目前还不能举行正式的武装起义彻底夺回香港，但新的斗争无疑证明了我们要收回香港的决心和我们对革命事业的支持。当然，伦敦和华盛顿不会忘记这些武器是从哪里来的……"
const TXT_R1 := "什么都没发生，或许有一天，我们能够通过另一种形式来收回香港，或许吧……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 2:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var opt := event_def.options
	if line56 <= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_P1 + _leader_name() + TXT_R0_P2
			_add_relation(EmpireData.USA, -300)
			_add(W.I_PARTY_SUPPORT, 300)
			_add(W.I_PEOPLE_SUPPORT, 300)
			_add(W.I_BUDGET, -10)
			_add(W.I_AGENTS, -10)
			_add(W.I_ARMY, -30)
		1:
			context["result_text"] = TXT_R1




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


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

