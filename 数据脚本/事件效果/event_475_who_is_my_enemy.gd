extends "res://数据脚本/event_script_base.gd"

## 原作 Event475.cs：谁是我的敌人？（埃塞俄比亚安排三选项）。
## 触发：ReqEventForDLC02.cs:1444-1446 —— 复合条件（parts 数组）用 trigger_script
##   evaluate(world) 表达；fire_only_once 承担 !event_done[475]。
## 差异：based→有驻军基地；EstablishGovernment(ProChina) 在 Godot 侧以亲中/对华贸易标签近似。

const TXT_TITLE := "谁是我的敌人？"
const TXT_DESC := "在军委政权倒台后，新生的埃塞俄比亚就两个在推翻门格斯图武装斗争中的少数民族武装：提人阵和厄人阵的未来进行了长时间的讨论。在新生的政权中，有人认为应当组建一个民主的联邦，也有人支持列宁式的民族自决。作为推翻门格斯图政权的始作俑者，我们应当有始有终的解决埃塞俄比亚问题。"
const TXT_OPT0 := "我们希望他们能组建一个联邦"
const TXT_OPT1 := "两地应当得到自由—独立建国的自由！"
const TXT_OPT2 := "厄立特里亚值得独立，但提人阵将会进入新政府"
const TXT_R0 := "在武汉，埃塞俄比亚人民革命党，厄立特里亚人民解放阵线和提格雷人民解放阵线就组建统一的埃塞俄比亚联邦民主共和国达成了协议。埃塞俄比亚的各个少数民族得到了极大的自治权。民族谅解协定将会给埃塞俄比亚创造新的未来。尽管有些极端民族主义者拒绝这一协定，但大部分人都很满意，这也就够了，美苏对我们的行为很满意。"
const TXT_R1 := "在武汉，埃塞俄比亚人民革命党，厄立特里亚人民解放阵线和提格雷人民解放阵线就各自成立单独的国家达成了协定。各国确定了自己的领土实际控制范围。这似乎给埃塞俄比亚造成了不小的麻烦，毕竟厄立特里亚是他们为数不多的港口，而现在，埃塞俄比亚很明显失去了海岸线……\n埃塞俄比亚境内对这一“卖国”决定感到非常不满，但我们的新盟友会解决这些问题的，对吧？"
const TXT_R2 := "在武汉，埃塞俄比亚人民革命党和提格雷人民解放阵线就组建统一的埃塞俄比亚联邦民主共和国达成了协议。埃塞俄比亚的各个少数民族得到了极大的自治权。而厄立特里亚人民解放阵线则在埃塞政府的同意下脱离埃塞而独立。各国确定了自己的领土实际控制范围。这似乎给埃塞俄比亚造成了不小的麻烦，毕竟厄立特里亚是他们为数不多的港口，而现在，埃塞俄比亚很明显失去了海岸线……"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var ethiopia := _country(41)
	var eritrea := _country(99)
	var tigray := _country(100)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, 50)
			ws.influence_prc += 20
		1:
			context["result_text"] = TXT_R1
			if ethiopia != null:
				_setup_breakaway(eritrea, ethiopia)
				_setup_breakaway(tigray, ethiopia)
			ws.influence_prc += 10
		2:
			context["result_text"] = TXT_R2
			if ethiopia != null:
				_setup_breakaway(eritrea, ethiopia)
			ws.influence_prc += 10



func evaluate(world: WorldState) -> bool:

	if world == null:
		return false
	var ethiopia := world.get_country_by_legacy_index(41)
	if ethiopia == null or not ethiopia.has_tag("亲中") or ethiopia.government == 2:
		return false
	if world.wars.size() <= 24 or world.wars[24] == null:
		return false
	if world.wars[24].infl2 < 900:
		return false
	if ethiopia.parts.size() > 0 and ethiopia.parts[0]:
		return false
	if ethiopia.parts.size() > 1 and ethiopia.parts[1]:
		return false
	return true



func _setup_breakaway(c: CountryData, ethiopia: CountryData) -> void:
	if c == null or ethiopia == null:
		return
	_set_part(c, 0, true)
	c.government = ethiopia.government
	c.sub_government = ethiopia.sub_government
	c.set_tag("亲中", true)
	c.set_tag("对华贸易", true)
	c.有驻军基地 = true


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

