extends "res://数据脚本/event_script_base.gd"

## 原作 Event467.cs：我爱你金星红旗（马共统一三选项）。
## 触发：ReqEventForDLC02.cs:422-424 —— DATE_AFTER 1980.6.1；fire_only_once 承担 !event_done[467]。
## 差异：cw→内战中；button_text[5]/result_num==5 死代码跳过。

const TXT_TITLE := "我爱你金星红旗"
const TXT_DESC := "马共（马列）和马共（革命派）的代表来到了我们国家，找上了中共中央对外联络部，表达了与由于马来亚共产党再次统一的愿望。过去，由于马共北马来亚局肃反扩大化的错误与投机分子的影响，共产党内部也发生了分裂，原第八支队与第十二支队二区在70年代初分裂出去，分别建立了马来亚共产党（革命派）和马来亚共产党（马列），在为数不多的根据地上兄弟阋墙。再说说马来西亚国内的情况，作为亚洲四小龙之一，马来西亚迎来了自身经济的腾飞，但与绝大多数的新兴资本主义经济体一样，腾飞的代价便是贫富分化的极大加剧，这促使一度销声匿迹的左派力量重新壮大：合法范围内，马来西亚人民社会主义党等议会左翼政党正积极进行着宪制斗争；而非法范围内，马来亚共产党、北加里曼丹共产党及其武装部队和统战组织不断袭扰政府，马来亚民族解放军长征后一度失联的旧地下组织残余成员与前议会左翼政党成员们在受到文化大革命影响并激进化后组建的各地下组织也在秘密的协助马共进行斗争，但是这些组织与马共是平行关系，马共对他们缺乏有效的领导。主席同志，我们是否该帮他们一把？"
const TXT_OPT0 := "马共的问题必须解决，不过我们需要清除一些障碍"
const TXT_OPT0_DIS := "鞭长莫及，鞭长莫及啊……"
const TXT_OPT1 := "劝说他们重新达成统一"
const TXT_OPT2 := "还是不掺和的好"
const TXT_R0 := "在我们和泰国同志的秘密联络下，双方的领导人达成了协定：马来西亚人民社会主义党秘密加入民族解放同盟，作为代价，马来亚共产党必须维护全马的统一，为此，人民社会主义党作为桥梁加强了马来亚和砂捞越党、军的联系。在来到中国与陈平进行和谈后，马共分裂出去的两派被平反，马列派与革命派回到了马来亚共产党的队伍中，革命派领导人黄一江还在和谈过程中“主动”将一切权力让出，虽然不太厚道，但他的隐退确实让谈判顺利了许多。在马共的领导下，与马来亚共产党建立联系的地下组织在吉隆坡进行会谈，统一合并到马来亚民族解放同盟中。在全新血液的输入下，文莱人民党，新加坡社会主义阵线也加入了马来亚民族解放同盟。一个全马来西亚的左派组织正冉冉升起，马来西亚的解放指日可待。"
const TXT_R1 := "对外联络部努力劝说并没有使他们达成统一。马共（马列）和马共（革命派）希望以平等的方式与马共会谈，但是马共方面并不同意。革命派领导人黄一江出于他的投机立场和对丧失领导地位的担心，也没有同意统一。马来亚共产党始终是苦守马泰边区根据地，革命派与马列派跟马来亚共产党后来又产生了多次武装冲突，不过我们已经管不了了……"
const TXT_R2 := "左派无限可分，这点果真是没错，直到人民社会主义党开始分裂，马来亚共产党也没与它联合。分裂后的人民社会主义党又上演了一遍逼上梁山的戏码，马来亚共产党始终是苦守马泰边区根据地，革命派与马列派跟马来亚共产党产生了多次武装冲突。好吧，的确是这样，属于革命的时代大概已经结束了……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	var d := world.数值表
	var line56 := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var thai := world.get_country_by_legacy_index(34)
	var opt := event_def.options
	if thai != null and thai.内战中 and line56 < 2:
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
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USSR, -100)
			var brunei := _country(49)
			if brunei != null:
				brunei.内战中 = true
			ws.influence_prc += 30
		1:
			context["result_text"] = TXT_R1
			ws.influence_prc -= 20
		2:
			context["result_text"] = TXT_R2
			ws.influence_prc -= 30



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

