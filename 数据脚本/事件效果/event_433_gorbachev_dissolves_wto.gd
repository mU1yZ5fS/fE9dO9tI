extends "res://数据脚本/event_script_base.gd"

## 原作 Event433.cs：戈尔巴乔夫解散华沙条约组织（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1424-1426 —— ExprNode 组合。
## 差异：now_leader→current_leader（ExprNode EMPIRE_LEADER_IS）；isOVD→标签 ovd；influencePRC→influence_prc。

const TXT_TITLE := "戈尔巴乔夫解散华沙条约组织"
const TXT_DESC := "新任苏联领导人米哈伊尔·戈尔巴乔夫上任之初，便遭遇了空前的外交挫败。在美国、中国与欧洲公众的联合压力下，他不得不批准“统一德国”的方案，然而这一计划甚至没有确认新国家的中立地位。莫斯科在东欧地区最忠诚的盟友，就此在政治版图上消失。\n因此，华沙条约组织本身的存在都已经成为了问题，尤其是在维谢格拉德圈子已脱离苏联影响力的情况下。在1985年，原本应当被续签的，延续30余年的《友好合作互助条约》被修订；原本在筹划的相关庆祝活动也被取消。戈尔巴乔夫不得不表示，这只是苏联与美国和解的“善意姿态”，但所有人都知道，莫斯科真正的盟友只剩下捷克斯洛伐克与保加利亚：前者只与苏维埃乌克兰有些微接壤、后者则同华约国家在陆路上完全隔绝。\n持续30年的冷战就此结束了......"
const TXT_OPT0 := "冷战真的结束了吗？！"
const TXT_RESULT := "戈尔巴乔夫的“姿态”，被苏联共产党内的保守派政治家给视为对伟大卫国战争时期成就的背叛与亵渎。事实上，正是这一场大战，直接导致了世界社会主义阵营的建立。然而，现在还没有人谈论废除经济互助委员会的事宜，尽管该党已经在为该组织的改革计划做准备，但他们能够改变这种格局吗？"
const TXT_IDX_1492 := "戈尔巴乔夫解散华沙条约组织"
const TXT_IDX_1493 := "新任苏联领导人米哈伊尔·戈尔巴乔夫上任之初，便遭遇了空前的外交挫败。在美国、中国与欧洲公众的联合压力下，他不得不批准“统一德国”的方案，然而这一计划甚至没有确认新国家的中立地位。莫斯科在东欧地区最忠诚的盟友，就此在政治版图上消失。\n因此，华沙条约组织本身的存在都已经成为了问题，尤其是在维谢格拉德圈子已脱离苏联影响力的情况下。在1985年，原本应当被续签的，延续30余年的《友好合作互助条约》被修订；原本在筹划的相关庆祝活动也被取消。戈尔巴乔夫不得不表示，这只是苏联与美国和解的“善意姿态”，但所有人都知道，莫斯科真正的盟友只剩下捷克斯洛伐克与保加利亚：前者只与苏维埃乌克兰有些微接壤、后者则同华约国家在陆路上完全隔绝。\n持续30年的冷战就此结束了......"
const TXT_IDX_1494 := "冷战真的结束了吗？！"
const TXT_IDX_1495 := "戈尔巴乔夫的“姿态”，被苏联共产党内的保守派政治家给视为对伟大卫国战争时期成就的背叛与亵渎。事实上，正是这一场大战，直接导致了世界社会主义阵营的建立。然而，现在还没有人谈论废除经济互助委员会的事宜，尽管该党已经在为该组织的改革计划做准备，但他们能够改变这种格局吗？"

func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s


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


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
			and ws.empires[EmpireData.USSR].leaders.size() > 6:
		ws.empires[EmpireData.USSR].leaders[6].support -= 1
	for c in ws.countries:
		if c != null and c.has_tag("ovd"):
			c.set_tag("ovd", false)
	_add_power(EmpireData.USSR, -350)
	_add_power(EmpireData.USA, 100)
	ws.influence_prc += 100
	context["result_text"] = TXT_RESULT
