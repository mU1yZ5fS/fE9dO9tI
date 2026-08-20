extends "res://数据脚本/event_script_base.gd"

## 原作 Event608.cs：安吉拉行动（塞舌尔反政变，三选项）。
## 触发：ReqEventForDLC02.cs:889-891 —— DATE_AFTER 1981.11.25；fire_only_once 承担 !event_done[608]。
## 差异：JoinECON→set_tag("econ")；proprc→亲中、Torg→对华贸易；puppetOf=131 照抄。

const TXT_OPT0_DIS := "我们不该帮助这个极左独裁政府"
const TXT_OPT1_DIS := "我们不能与南非的白人殖民主义者站在一起！"
const TXT_R0 := "疯子迈克的大量招募雇佣兵的消息在伦敦，巴黎等地的雇佣兵圈子已经广为人知，自然我们的特工也获得了这个消息。11月25日傍晚，疯子迈克和数十名雇佣兵飞抵塞舌尔国际机场，但在经过安检途中，一名雇佣兵的ak步枪被发现，雇佣兵们意识到行动暴露了，随即拿起了武器，一名保安跑向办公室寻求帮助并锁上了门闩，成功拉响了警报。之后在我们脸涂黑的特勤和坦桑尼亚驻军的进攻下部分雇佣兵被击毙，疯子迈克等人被俘获并在审讯中透漏出此次行动为南非政府策划的，疯子迈克等雇佣兵随即便被判处死刑，看来南非雇佣兵的水平不过如此。南非政府本就败坏的国际形象变得更加破败，塞舌尔政府对此次行动中出力的坦桑尼亚和我们表达了感激，勒内政府决定学习坦桑尼亚的乌贾马社会主义，并宣布按照中国模式建设社会主义。"
const TXT_R1 := "11月25日傍晚，疯子迈克和数十名雇佣兵以及部分我们的脸涂黑的特勤飞抵塞舌尔国际机场，成功通过安检并按照原计划分散在马埃岛的各个酒店。在数天之后，当勒内召开内阁会议之时，雇佣兵和我们的特勤占领了议会，机场，军营，广播电台等各战略要地并宣布他们代表曼卡姆对塞舌尔进行政变。勒内和一众塞舌尔高管被关进监狱，流亡在外的曼卡姆虽如愿重新当上总统，但实际则是傀儡，而以疯子迈克和南非雇佣兵为首的南非势力则在幕后掌权，塞舌尔对军队进行了清洗并以参与政变的雇佣兵为骨干进行扩编。塞舌尔实际上已经成为了另一个班图斯坦，而国际上对塞舌尔政变则是普遍的谴责。"
const TXT_R2 := "11月25日傍晚，疯子迈克和数十名雇佣兵飞抵塞舌尔国际机场，但在经过安检途中，一名雇佣兵的ak步枪被发现，雇佣兵们意识到行动暴露了，随即拿起了武器，一名保安跑向办公室寻求帮助并锁上了门闩，成功拉响了警报。这导致了机场一场长达六个小时的枪战，就在此时，一架印度航空客机意外的降落在这座机场上，塞舌尔军队试图中止降落但未能奏效，部分雇佣兵借此机会登上这架客机，大约70名机组人员和乘客被雇佣兵劫持为人质。最终这家飞机被劫持飞往南非的德班市，机组人员和乘客全部释放，塞舌尔逮捕了六名雇佣兵，其余大部分雇佣兵则成功返回南非。\n看起来南非的雇佣兵水平不过如此。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var diplo := d[W.I_DIPLO] if d.size() > W.I_DIPLO else 0
	var seychelles := world.get_country_by_legacy_index(155)
	var opt := event_def.options
	if line <= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if seychelles != null and seychelles.government != 1 and line > 1 and diplo <= 700:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var seychelles := _country(155)
	var china := _country(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			if seychelles != null:
				if seychelles.government == 1:
					seychelles.sub_government = 0
				else:
					seychelles.government = 1
					seychelles.sub_government = 1
				_leave_alliances(seychelles)
				seychelles.set_tag("亲中", true)
				seychelles.set_tag("对华贸易", true)
				if china != null and china.has_tag("econ"):
					seychelles.set_tag("econ", true)
		1:
			context["result_text"] = TXT_R1
			_add(W.I_AGENTS, -30)
			if seychelles != null:
				seychelles.government = 0
				seychelles.sub_government = 7
				_leave_alliances(seychelles)
				seychelles.puppet_of = 131
		2:
			context["result_text"] = TXT_R2
			if seychelles != null:
				seychelles.set_tag("亲中", false)






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


