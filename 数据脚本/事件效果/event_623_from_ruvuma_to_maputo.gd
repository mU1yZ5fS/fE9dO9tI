extends "res://数据脚本/event_script_base.gd"

## 原作 Event623.cs：从鲁乌马到马普托（莫桑比克内战，三选项）。
## 触发：ReqEventForDLC02.cs:939-941 —— DATE_AFTER 1977.5.30；fire_only_once 承担 !event_done[623]。
## 差异：level_of_unstab→level_of_instability。

const TXT_OPT0_DIS := "抓到老鼠就是好猫"
const TXT_OPT1_DIS := "我们绝不支持种族主义者和莫桑比克革命的叛徒！"
const TXT_R0 := "我们为莫桑比克政府继续提供武器和经济等援助，以帮助老朋友渡过困难时期。莫解阵在建设莫桑比克人民解放军和民兵的同时，开始逐步进行国有化和建立公社村、建设行政机构和党组织、发展教育和医疗卫生。与此同时，在南非和罗德西亚的袭扰下，莫解阵和莫抵运之间漫长的低烈度战争也开始了。"
const TXT_R1 := "在声援莫解阵反帝斗争的同时，我们利用和美国的关系，将部分援助送到了莫抵运手里（当然，并没有援助中械）。莫解阵在建设莫桑比克人民解放军和民兵的同时，开始逐步进行国有化和建立公社村、建设行政机构和党组织、发展教育和医疗卫生。与此同时，在南非和罗德西亚的袭扰下，莫解阵和莫抵运之间漫长的低烈度战争也开始了。"
const TXT_R2 := "我们没有做出太多的表示。莫解阵在建设莫桑比克人民解放军和民兵的同时，开始逐步进行国有化和建立公社村、建设行政机构和党组织、发展教育和医疗卫生。与此同时，在南非和罗德西亚的袭扰下，莫解阵和莫抵运之间漫长的低烈度战争也开始了。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 1 and world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null \
			and world.empires[EmpireData.USA].relations >= 600:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var mozambique := _country(126)
	var opt := int(context.get("option_index", -1))
	if mozambique != null:
		mozambique.level_of_instability = 700
		_set_part(mozambique, 0, true)
	match opt:
		0:
			context["result_text"] = TXT_R0
			if mozambique != null:
				mozambique.level_of_instability += 20
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -60)
		1:
			context["result_text"] = TXT_R1
			if mozambique != null:
				mozambique.level_of_instability -= 20
			_add(W.I_ARMY, -100)
			_add(W.I_AGENTS, -50)
		2:
			context["result_text"] = TXT_R2






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

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = GameConstants.LegacySlot.NONE


