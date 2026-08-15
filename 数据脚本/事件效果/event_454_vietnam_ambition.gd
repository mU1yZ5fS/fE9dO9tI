extends "res://数据脚本/event_script_base.gd"

## 原作 Event454.cs：越南的野心（印支联邦成立，三选项）。
## 触发：ReqEventForDLC02.cs:387-389 —— allcountries[23].puppetOf==11 && allcountries[22].puppetOf==11；
##   fire_only_once 承担 !event_done[454]。
## 差异：描述按 resultOfEvents[56] 动态（原事件56在项目 event_id=teach_vietnam_lesson）；
##   name 改 chinese_name；isSEV→set_tag("sev")；Torg→set_tag("对华贸易")。

const TXT_TITLE := "越南的野心"
const TXT_DESC_A := "越南成功击溃民主柬埔寨政府并挫败我们的进攻后，野心极度膨胀。在苏联的支持下，黎笋、凯山·丰威汉和韩桑林在胡志明市进行了一周的秘密协商和谈判，最终，三方签订了关于成立印度支那民主共和国联邦的协议。十日后，在印度支那联合人民军（主要是越南人民军）的监督下，三国通过一场超过90%支持率的全民公投，正式宣布成立印度支那民主共和国联邦，首都为胡志明市；同时，越南共产党、柬埔寨人民革命党和老挝人民革命党在一场联合代表大会中再次统一为印度支那共产党。新的“联邦政府“表示，三国的整合是长期性的，要经过从邦联到联邦缓慢整合的过程。苏联承认了联邦，并表示这是解决印度支那民族问题的最佳方案；新的印度支那政府宣布将加快和经互会的一体化，老挝和柬埔寨也正式融入了经互会体系；双方也将开展大规模军事合作，苏联军事基地正在处于筹备过程中，同时苏联将参与”柬埔寨平叛“。我们支持的民主柬埔寨联合政府谴责了这个所谓的联邦，称这是越南对主权国家的公然吞并。除了苏东阵营的国家外，大多国家都未承认这印度支那的合并。这对我国无疑是坏事，这证明，苏联对我们正式完成了南北合围。我们应该对这一“联邦”有所表示了。"
const TXT_DESC_B := "越南成功击溃民主柬埔寨政府后，野心极度膨胀。在苏联的支持下，黎笋、凯山·丰威汉和韩桑林在胡志明市进行了一周的秘密协商和谈判，最终，三方签订了关于成立印度支那民主共和国联邦的协议。十日后，在印度支那联合人民军（主要是越南人民军）的监督下，三国通过一场超过90%支持率的全民公投，正式宣布成立印度支那民主共和国联邦，首都为胡志明市；同时，越南共产党、柬埔寨人民革命党和老挝人民革命党在一场联合代表大会中再次统一为印度支那共产党。新的“联邦政府“表示，三国的整合是长期性的，要经过从邦联到联邦缓慢整合的过程。苏联承认了联邦，并表示这是解决印度支那民族问题的最佳方案；新的印度支那政府宣布将加快和经互会的一体化，老挝和柬埔寨也正式融入了经互会体系；双方也将开展大规模军事合作，苏联军事基地正在处于筹备过程中，同时苏联将参与”柬埔寨平叛“。我们曾经支持的民主柬埔寨联合政府谴责了这个所谓的联邦，称这是越南对主权国家的公然吞并。除了苏东阵营的国家外，大多国家都未承认这印度支那的合并。这对我国无疑是坏事，这证明，苏联对我们正式完成了南北合围。我们应该对这一“联邦”有所表示了。"
const TXT_OPT0 := "谴责这一联邦"
const TXT_OPT1 := "为新联邦欢呼"
const TXT_OPT1_DIS_A := "你还嫌不够丢脸吗？！"
const TXT_OPT1_DIS_B := "我们不可能为修正主义者欢呼！"
const TXT_OPT2 := "保持沉默"
const TXT_R0 := "我国外交部声明：“越南肆意侵略主权国家，支持傀儡政府，践踏国际秩序，应该受到强烈谴责！民主柬埔寨联合政府为民族解放的斗争是完全正义的！“印支方面并未对此做出回应，但是，我们南北边境紧张的局势也并未得到缓和。"
const TXT_NAME_CAMBODIA := "印支联邦柬埔寨区"
const TXT_NAME_FED := "印度支那联邦"
const TXT_NAME_LAOS := "印支联邦老挝区"
const TXT_R1 := "我国外交部表示：“越南推翻了残暴的波尔布特政权，为他们带去了真正的解放和真正的社会主义；联邦的成立合理合法，这是解决印度支那民族问题的最佳方案。”民主柬埔寨联合政府和我们断绝了联系。但是，我们和苏联、越南的关系获得了些许缓和，南北边境的边防压力也稍稍减小了。"
const TXT_R2 := "我们的政府并未对这一行为进行评价，一切如常。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or event_def.options.size() < 3:
		return
	var res56 := int(world.completed_event_ids.get("teach_vietnam_lesson", 0))
	if res56 == 1:
		event_def.description = TXT_DESC_A
	else:
		event_def.description = TXT_DESC_B
	var line56 := 0
	if world.数值表.size() > W.I_POLITICAL_LINE:
		line56 = world.数值表[W.I_POLITICAL_LINE]
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if res56 == 0 and line56 >= 2:
		_enable(opt[1], TXT_OPT1)
	elif res56 == 1:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	_enable(opt[2], TXT_OPT2)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_indochina_names()
			_indochina_torg(false, false, false)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_DIPLO, 50)
			_add(W.I_PARTY_SUPPORT, 100)
			ws.influence_prc -= 20
		1:
			context["result_text"] = TXT_R1
			_indochina_names()
			_indochina_torg(true, false, false)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, -50)
			_add(W.I_PARTY_SUPPORT, -100)
			ws.influence_prc -= 30
		2:
			context["result_text"] = TXT_R2
			_indochina_names()
			_indochina_torg(false, false, false)
			ws.influence_prc -= 50



func _indochina_names() -> void:
	var c11 := _country(11)
	var c22 := _country(22)
	var c23 := _country(23)
	if c11 != null:
		c11.government = 0
		c11.sub_government = 10
		c11.chinese_name = TXT_NAME_FED
		_set_part(c11, 0, true)
		c11.set_tag("sev", true)
	if c22 != null:
		c22.chinese_name = TXT_NAME_LAOS
		c22.set_tag("sev", true)
	if c23 != null:
		c23.chinese_name = TXT_NAME_CAMBODIA
		c23.set_tag("sev", true)


func _indochina_torg(v: bool, l: bool, k: bool) -> void:
	_tag(11, "对华贸易", v)
	_tag(22, "对华贸易", l)
	_tag(23, "对华贸易", k)


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

