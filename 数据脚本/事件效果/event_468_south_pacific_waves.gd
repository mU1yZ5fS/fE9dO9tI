extends "res://数据脚本/event_script_base.gd"

## 原作 Event468.cs：南太平洋海涛翻腾（马来亚内战二选项）。
## 触发：ReqEventForDLC02.cs:427-429 —— allcountries[34].cw && DATE_AFTER 1981.2.1；
##   fire_only_once 承担 !event_done[468]。
## 差异：usa_place=1→usa_side=1；开战按项目约定 GameManager.start_war(34,...) 后覆盖
##   name_war/fortnight_max（TickTime 20）；button_text[5]/result_num==5 死代码跳过。

const TXT_TITLE := "南太平洋海涛翻腾"
const TXT_DESC := "主席同志，随着泰国革命的胜利，马来亚问题也摆在了我们眼前：原本因为“新村政策”力量大幅削弱的马来亚共产党、马来亚民族解放军和北加里曼丹共产党、北加里曼丹人民军在我们和泰国革命政权的协助下愈发壮大，马来西亚和新加坡政府不断敦促泰国革命政府停止对马来亚共产党和北加里曼丹共产党的援助。东南亚各个国家革命的成功以及他们对马来西亚的经济封锁使得马来西亚的经济陷入困境。加上马来西亚和新加坡对左翼运动的猎巫式镇压（大量温和派议会党甚至被直接查禁）使得民众越发不满——这些国家的左翼思潮像68运动时期一样再次流行起来了。学生运动、工人罢工和民众游行引来了政府的镇压，马来西亚像50年代一样开始实行紧急状态。现在，马来亚共产党主席陈平同志向中央委员会亲自发电，请泰国革命政府给马来亚民族解放阵线北马来半岛作为革命根据地，并恢复马来亚共产党对南泰马来族为主体地区的统治，泰国共产党中央委员会大部分人认同了这个提案。但这样的行为，基本等于让新生的革命政权走向新的战争。现在，主席同志，面对两边的压力，我们该如何抉择？"
const TXT_OPT0 := "是时候了，马来亚和北加里曼丹的人民已经盼了很久了"
const TXT_OPT0_DIS := "他们根本没有这样的势力基础"
const TXT_OPT1 := "让他们在议会斗吧，保全势力也好"
const TXT_R0 := "世界各国人民的解放一直都是我们的夙愿，我们的兄弟党即将迎来自己民族的解放，我们怎么可能撒手不管！我们积极辅助了泰马两党的北马来根据地政权的转移工作。马来政府对我们的行为十分恼火，已经对我们的行为下了最后通牒，但是这又如何呢？一个买办政府是挡不住人民战争的汪洋大海的！新生的泰人民政权已经准备好投入进这一场兄弟民族的革命中去了，我们更应该履行无产阶级国际主义。同志们，向吉隆坡，进攻！"
const TXT_WAR_NAME := "马来亚内战"
const TXT_WAR_SIDE1 := "马来亚民族解放同盟"
const TXT_WAR_SIDE2 := "马来西亚政府"
const TXT_R1_BASE := "经过权衡，我们还是认为维持与现在马来西亚政府的友谊更好。为此，我们让马来亚民族解放军和马来西亚现政府签订《合艾和约》。泰国的人民政权对我国完全失望，转而加入了经济互助委员会，失去了一个这样的盟友也没有什么挽留的，天要下雨，娘要嫁人，随他去吧。而马来西亚现政府与我们现在的关系也变好了，"
const TXT_R1_ASEAN := "我们与东盟的合作也深入了下去，"
const TXT_R1_TAIL := "但愿这对我们的全球战略有好的影响。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 2:
		return
	var done467 := world.completed_event_ids.has("event_467")
	var res467 := int(world.completed_event_ids.get("event_467", 0))
	var opt := event_def.options
	if done467 and res467 == 0:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var malaysia := _country(49)
	var thai := _country(34)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if malaysia != null:
				malaysia.government = 0
				malaysia.sub_government = 7
			GameManager.start_war(34, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 300, 700, 1)
			var war := _get_war(34)
			if war != null:
				war.name_war = TXT_WAR_NAME
				war.fortnight_max = 20
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -100)
			_add_relation(EmpireData.USA, -300)
			ws.influence_prc += 20
		1:
			var text := TXT_R1_BASE
			var asean := _country(51)
			if asean != null and asean.has_tag("对华贸易"):
				text += TXT_R1_ASEAN
			text += TXT_R1_TAIL
			context["result_text"] = text
			_add_relation(EmpireData.USA, 150)
			if thai != null:
				thai.set_tag("对华贸易", false)
				if thai.has_tag("okb"):
					thai.set_tag("亲中", false)
				if thai.has_tag("econ") and not thai.has_tag("okb"):
					thai.set_tag("econ", false)
					thai.set_tag("sev", true)
					thai.set_tag("亲中", false)
					_add_power(EmpireData.USSR, 50)
			_tag(49, "对华贸易", true)



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

