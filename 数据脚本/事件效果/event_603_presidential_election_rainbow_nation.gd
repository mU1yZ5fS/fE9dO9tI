extends "res://数据脚本/event_script_base.gd"

## 原作 Event603.cs：总统大选：彩虹之国（南非大选，三选项）。
## 触发：ReqEventForDLC02.cs:869-871 —— c131.SubGosstroy==5 && DATE_AFTER 1985.8.15。
## 差异：name→chinese_name；puppetOf 循环→_free_puppets(131)；prosov→亲苏、proprc→亲中、Vyshi→亲美。

const TXT_NAME_RSA := "南非共和国"
const TXT_R_COMMON := "为期四天的大选热闹非凡，有数百万人排队投票，而结果正如普遍预期：非洲人国民大会、南非工会大会及南非共产党的三方联盟赢得全面胜利。新国民议会推选非洲人国民大会领导人纳尔逊·曼德拉为总统，黑人为主的国家也终于有了自己的黑人领袖。\n崭新的时代就此到来……\n\n“年月把拥有变做失去，疲倦的双眼带着期望——今天只有残留的躯壳，迎接光辉岁月，风雨中抱紧自由！”——黄家驹《光辉岁月》"
const TXT_R2_PRORPC := "为期四天的大选热闹非凡，有数百万人排队投票，而结果却出人意料：由于阿扎尼亚泛非主义大会等激进左翼组织的参选分化了黑人选民，导致非国大选票分流。德克勒克、因卡蒂自由党和独立候选人的保守联盟由此险胜非国大取得胜利！尽管如此，德克勒克依然出于“稳定转型需要”，将曼德拉及非国大温和派纳入到民族团结政府中。美国对选举结果表示热烈祝贺，看起来南非终于可以翻过种族隔离的篇章，成为自由世界在非洲最大最亮的钻石……"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var south_africa := _country(131)
	var opt := int(context.get("option_index", -1))
	if south_africa != null:
		south_africa.chinese_name = TXT_NAME_RSA
	match opt:
		0:
			context["result_text"] = TXT_R_COMMON
			if world_empire_power_gt(1, 0):
				if south_africa != null:
					south_africa.government = 2
					south_africa.sub_government = 3
					south_africa.set_tag("亲苏", true)
			else:
				if south_africa != null:
					south_africa.government = 3
					south_africa.sub_government = 4
			_free_puppets(131)
		1:
			context["result_text"] = TXT_R_COMMON
			if ws.influence_prc + _empire_power(1) > _empire_power(0):
				if south_africa != null:
					south_africa.government = 2
					south_africa.sub_government = 3
					south_africa.set_tag("亲中", true)
			else:
				if south_africa != null:
					south_africa.government = 3
					south_africa.sub_government = 4
					south_africa.set_tag("亲中", true)
			if south_africa != null:
				south_africa.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -100)
			_add_relation(EmpireData.USA, -150)
			_free_puppets(131)
		2:
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -100)
			_free_puppets(131)
			if ws.influence_prc > 700:
				context["result_text"] = TXT_R2_PRORPC
				if ws.influence_prc > _empire_power(0):
					if south_africa != null:
						south_africa.government = 3
						south_africa.sub_government = 5
						south_africa.set_tag("亲中", true)
						south_africa.set_tag("对华贸易", true)
				else:
					if south_africa != null:
						south_africa.government = 3
						south_africa.sub_government = 5
						south_africa.set_tag("亲美", true)
						south_africa.set_tag("对华贸易", true)
			else:
				context["result_text"] = TXT_R_COMMON






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



func _empire_power(idx: int) -> int:
	if ws.empires.size() > idx and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func world_empire_power_gt(a: int, b: int) -> bool:
	return _empire_power(a) > _empire_power(b)

