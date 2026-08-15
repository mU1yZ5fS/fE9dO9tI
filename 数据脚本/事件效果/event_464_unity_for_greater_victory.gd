extends "res://数据脚本/event_script_base.gd"

## 原作 Event464.cs：团结起来，争取更大胜利（申根式协议三选项）。
## 触发：ReqEventForDLC02.cs:412-414 —— 欧共体各国 econ 标签链；fire_only_once 承担 !event_done[464]。
## 差异：soc_stab→social_stability；proprc→亲中、sovalliance→苏联盟友、usalliance→美国盟友；
##   isSocEU→soc_eu 标签。

const TXT_TITLE := "团结起来，争取更大胜利"
const TXT_DESC := "主席同志！在布鲁塞尔的前欧洲共同体办公处中，我们找到了一项名为“申根协定”的秘密协定，其中包括在协定签字国之间不再对公民进行边境检查；外国人一旦获准进入“协议领土”内，即可在协定签字国领土上自由通行；设立警察合作与司法互助的制度，建立统一电脑系统，建立有关各类非法活动分子情况的共用档案库。我们现在的科技水平足够发达，而我们同盟内的国家也足够多，签发签证是一个巨大的问题。这个方案足够大胆，但或许会有很好的成效。不过定夺权在您手上。"
const TXT_OPT0 := "建立一个类似于该申根协议的协议，只适用于我们军事联盟的成员"
const TXT_OPT0_DIS := "我们没有军事联盟"
const TXT_OPT1 := "为我们所有联盟的成员建立一个类似于该申根协议的协议"
const TXT_OPT2 := "我们可以稍后再议"
const TXT_R0 := "我们与军事联盟国家之间的会议在上海举行，结束时签署了所谓的上海协定，这意味着创建一个我们联盟国家之间的简化的护照和签证控制空间的前景，并完全排斥外国护照的需要。协议逐渐开始生效，人民满意了，但也开始被外国文化冲昏头脑，对我们的国家原则产生了怀疑。现在，罪犯和持不同政见者更容易逃离中国，走私者也更容易把他们的货物走私到我们这里。但我们的盟友国家之间的联系已经进一步加强，旅游业的利润将补充我们的预算。"
const TXT_R1 := "我们与所有联盟国家之间的会议在上海举行，结束时签署了所谓的上海协定，这意味着创建一个我们联盟国家之间的简化的护照和签证控制空间的前景，并完全排斥外国护照的需要。协议逐渐开始生效，人民满意了，但也开始被外国文化冲昏头脑，对我们的国家原则产生了怀疑。现在，罪犯和持不同政见者更容易逃离中国，走私者也更容易把他们的货物走私到我们这里。但我们的盟友国家之间的联系已经进一步加强，旅游业的利润将补充我们的预算。"
const TXT_R2 := "既然除了我们的情报人员没人知道这件事，我们可以暂且搁置，日后再讨论"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or event_def.options.size() < 3:
		return
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if china != null and china.has_tag("okb"):
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)
	_enable(opt[2], TXT_OPT2)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_shengen_base()
			_shengen_loop(true)
		1:
			context["result_text"] = TXT_R1
			_shengen_base()
			_shengen_loop(false)
		2:
			context["result_text"] = TXT_R2



func _shengen_base() -> void:
	_add(W.I_THOUGHT_FREEDOM, 50)
	_add(W.I_PEOPLE_SUPPORT, 80)
	ws.influence_prc += 10
	_add(W.I_CORRUPTION, 30)
	_add(W.I_BUDGET, 30)


func _shengen_loop(military_only: bool) -> void:
	for c in ws.countries:
		if c == null:
			continue
		var joined := c.has_tag("okb")
		if not military_only:
			joined = joined or c.has_tag("econ")
		if not joined:
			continue
		c.social_stability += 200
		_add(W.I_BUDGET, -5)
		if not c.has_tag("亲中") and not c.has_tag("苏联盟友") and not c.has_tag("美国盟友"):
			c.set_tag("亲中", true)
			_add(W.I_BUDGET, -20)
		elif not c.has_tag("亲中") and (c.has_tag("苏联盟友") or c.has_tag("美国盟友")):
			c.set_tag("苏联盟友", false)
			c.set_tag("美国盟友", false)
			_add(W.I_BUDGET, -30)


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

