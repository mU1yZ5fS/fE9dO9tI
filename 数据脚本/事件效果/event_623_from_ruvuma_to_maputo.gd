extends "res://数据脚本/event_script_base.gd"

## 原作 Event623.cs：从鲁乌马到马普托（莫桑比克内战，三选项）。
## 触发：ReqEventForDLC02.cs:939-941 —— DATE_AFTER 1977.5.30；fire_only_once 承担 !event_done[623]。
## 差异：level_of_unstab→level_of_instability。

const TXT_TITLE := "从鲁乌马到马普托"
const TXT_DESC := "经过我们和我们的盟友以及苏东阵营的长期支援，并得益于康乃馨革命，莫桑比克解放阵线终于获得了反殖民斗争的阶段性胜利，在1975年6月25日成立了莫桑比克人民共和国，由有“非洲的切·格瓦拉”之称的萨莫拉·马谢尔担任最高领导人。在争取独立的斗争中，莫桑比克解放阵线的左派战胜了内部的资产阶级民族主义路线的支持者，赢得了路线斗争，该组织也逐渐从亲左翼的民族主义组织转向了支持马克思列宁主义的革命组织。意识形态上，它也更多地受到毛泽东思想的影响，相比亲苏的同样持马列主义的安哥拉人民解放运动而言，他们显得更具革命性——积极支持阶级斗争、政治挂帅等原则。\n然而，独立后的路并不一帆风顺，殖民者留下的是一个千疮百孔的莫桑比克，经济凋敝，被形容为“实际上破产的国家”；周边的种族政权以及莫桑比克本土的白人资本家和地主也不愿意见到一个新的左翼反帝政权——1976年，在罗德西亚和白人南非的支持下，白人叛乱组织“死亡之龙”同被清除出党的莫解阵右翼分子的叛乱组织合并为拥有上万人的“莫桑比克全国抵抗运动”，对人民共和国发起了全国性的战争。对于莫桑比克解放阵线党而而言，他们需要一边同莫抵运作战，一边进行人民民主革命，在严峻的环境下建设国家；对抵运而言，这是莫解阵对全国控制相对薄弱的时期。\n作为我们支援非洲反帝反殖的一个重要节点，我们自然应当帮老朋友莫解阵解决掉莫抵运这个麻烦；不过，为了保住我们在非洲的利益，我们或许应该尝试两头下注？"
const TXT_OPT0 := "我们将继续援助莫桑比克解放阵线党，一直打到完全胜利为止！"
const TXT_OPT0_DIS := "抓到老鼠就是好猫"
const TXT_OPT1 := "秘密给抵运打钱"
const TXT_OPT1_DIS := "我们绝不支持种族主义者和莫桑比克革命的叛徒！"
const TXT_OPT2 := "尝试置身事外"
const TXT_R0 := "我们为莫桑比克政府继续提供武器和经济等援助，以帮助老朋友渡过困难时期。莫解阵在建设莫桑比克人民解放军和民兵的同时，开始逐步进行国有化和建立公社村、建设行政机构和党组织、发展教育和医疗卫生。与此同时，在南非和罗德西亚的袭扰下，莫解阵和莫抵运之间漫长的低烈度战争也开始了。"
const TXT_R1 := "在声援莫解阵反帝斗争的同时，我们利用和美国的关系，将部分援助送到了莫抵运手里（当然，并没有援助中械）。莫解阵在建设莫桑比克人民解放军和民兵的同时，开始逐步进行国有化和建立公社村、建设行政机构和党组织、发展教育和医疗卫生。与此同时，在南非和罗德西亚的袭扰下，莫解阵和莫抵运之间漫长的低烈度战争也开始了。"
const TXT_R2 := "我们没有做出太多的表示。莫解阵在建设莫桑比克人民解放军和民兵的同时，开始逐步进行国有化和建立公社村、建设行政机构和党组织、发展教育和医疗卫生。与此同时，在南非和罗德西亚的袭扰下，莫解阵和莫抵运之间漫长的低烈度战争也开始了。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line < 3:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 1 and world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null \
			and world.empires[EmpireData.USA].relations >= 600:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)



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



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

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
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = -1

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

