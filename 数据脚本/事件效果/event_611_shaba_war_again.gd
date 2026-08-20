extends "res://数据脚本/event_script_base.gd"

## 原作 Event611.cs：沙巴战争，又一次？（第二次沙巴战争，单选项）。
## 触发：ReqEventForDLC02.cs:904-906 —— DATE_AFTER 1978.5.11；fire_only_once 承担 !event_done[611]。
## 差异：描述/结果按 c163.parts[0] 分支；AmericanSupportAttacker→usa_side=0；TickTime(9)→fortnight_max。

const TXT_DESC_A := "在第一次沙巴战争惨痛的失败后，FNLC的成员痛定思痛，决心攻占科卢维齐这一重地作为前进的跳板。在古巴的支持下，6500名FNLC士兵又一次越过边界突袭该国。起义军已经攻下了边境的数个军火库和哨站，似乎这次他们的赢面很大？"
const TXT_DESC_B := "在刚果民族解放阵线站稳了脚跟后，加丹加人民共和国一直尽力渗透着扎伊尔政权。而今天，塔纳尔·姆奔巴宣布发起又一次冲锋，他们将会彻底击溃孱弱的扎伊尔政权。很明显，一边是士气高昂的解放战士，另一边是依赖巫医，金钱和外国人的国防军，胜利的天平似乎已经开始倾斜了。"
const TXT_R0_A := "我们像过去的那样呼吁各方冷静下来并停火，但谁会在乎我们的话呢？古巴人仍然在一波又一波的开往加丹加地区。"
const TXT_WAR_A_NAME := "第二次沙巴战争"
const TXT_WAR_A_SIDE1 := "扎伊尔"
const TXT_WAR_A_SIDE2 := "刚果民族解放阵线"
const TXT_R0_B := "在古巴人的大力支持下，如潮水般的刚果民族解放阵线士兵开始冲向北方，他们的主要目标是拿下金沙萨和基桑加尼。当然，具体问题仍然需要具体分析。如果他们有这般武勇，为什么没有趁蒙博托政权不稳之时就推翻他呢？"
const TXT_WAR_B_NAME := "第二次沙巴战争"
const TXT_WAR_B_SIDE1 := "扎伊尔"
const TXT_WAR_B_SIDE2 := "刚果民族解放阵线"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null:
		return
	_bind_world()
	if not _part(163, 0):
		event_def.description = TXT_DESC_A
	else:
		event_def.description = TXT_DESC_B



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var zaire := _country(117)
	var katanga := _country(163)
	var opt := int(context.get("option_index", -1))
	if zaire != null:
		_set_part(zaire, 0, true)
	match opt:
		0:
			if katanga == null or not (katanga.parts.size() > 0 and katanga.parts[0]):
				context["result_text"] = TXT_R0_A
				_start_war(61, TXT_WAR_A_NAME, TXT_WAR_A_SIDE1, TXT_WAR_A_SIDE2, 700, 300, 0, 1, 9)
			else:
				context["result_text"] = TXT_R0_B
				_start_war(61, TXT_WAR_B_NAME, TXT_WAR_B_SIDE1, TXT_WAR_B_SIDE2, 500, 500, 0, 1, 9)






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

