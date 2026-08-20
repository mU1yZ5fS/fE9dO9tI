extends "res://数据脚本/event_script_base.gd"

## 原作 Event614.cs：叛徒去死（加丹加收复，单选项）。
## 触发：ReqEventForDLC02.cs:914-916 —— c163.parts[0] && (c117.SubGosstroy==15 || c117.SubGosstroy==17)。
##  parts[0] ExprNode 不支持 → trigger_script=evaluate()（同文件）。

const TXT_R0_A := "得益于坦桑尼亚和卢旺达联军的支持，刚果政府如同秋风扫落叶般击溃了弱小的“加丹加人民共和国”。午夜，共计2000名卢旺达和刚果的伞兵空降在了“首都”卢本巴希，一举夺下了“阿格施蒂纽·内图国际机场”。在中心城区，联军同叛乱者展开了交火，尽管加丹加人民军的抵抗力度比预想的要强大，最终还是被攻破。与此同时，近一万名刚果人民革命军精锐乘坐重型装甲车从北部。在卢旺达和坦桑尼亚的压倒性优势下，姆奔巴和他的军队自然不会有任何翻盘的机会。几天之内，“加丹加人民共和国”总统蒙古亚宣布辞职并呼吁军队停止抵抗，姆奔巴也已自杀。而试图最后捞一笔的苏联人则损失惨重，不得不坐在谈判桌前签署了和约，并施压安哥拉和古巴人不再干涉刚果内政。\n刚果给予了加丹加地区的自治权，并开始了社会主义改造。丰富的资源定能为刚果的发展添一把柴。原先的加丹加宪兵成员也因为叛国罪而被处死。再也没有也不会有红色冲伯了！"
const TXT_R0_B := "得益于坦桑尼亚和卢旺达联军的支持，刚果政府如同秋风扫落叶般击溃了弱小的“加丹加人民共和国”。午夜，共计2000名卢旺达和刚果的伞兵空降在了“首都”卢本巴希，一举夺下了“阿格施蒂纽·内图·国际机场”。在中心城区，他们同叛乱者展开了交火，尽管加丹加人民军的抵抗力度比预想的要强大，最终还是被攻破。与此同时，近一万名刚果人民革命军精锐乘坐重型装甲车从北部。在卢旺达和坦桑尼亚的压倒性优势下，姆奔巴和他的支持者自然不会有任何翻盘的机会。几天之内，“加丹加人民共和国”总统蒙古亚宣读了辞职书和投降信，姆奔巴也已自杀。而试图最后捞一笔的苏联人则损失惨重，不得不坐在谈判桌前签署了和约，并施压安哥拉和古巴人不再干涉刚果内政。\n为了征收合理的“军费”，出兵的两个国家决定帮卡比拉政府实行为其20年的“托管”。大量的钻石，铀矿，钴和铜被运出加丹加省。卢旺达一年的出口量比自己本土的产量还高！卡比拉被反对派指责为“又一个冲伯”，“背叛了先总理的理想”。但只要詹姆斯太上皇一日坐阵金沙萨，这些都不过是无关痛痒的小问题。"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var zaire := _country(117)
	var katanga := _country(163)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if zaire != null and zaire.government == GameConstants.Government.SOCIALIST:
				context["result_text"] = TXT_R0_A
			else:
				context["result_text"] = TXT_R0_B
			if katanga != null:
				_set_part(katanga, 0, false)
			_add_relation(EmpireData.USSR, -50)
			_add_relation(EmpireData.USA, -50)



func evaluate(world: WorldState) -> bool:

	if world == null:
		return false
	var katanga := world.get_country_by_legacy_index(163)
	var zaire := world.get_country_by_legacy_index(117)
	if katanga == null or zaire == null:
		return false
	if not (katanga.parts.size() > 0 and katanga.parts[0]):
		return false
	return zaire.sub_government == GameConstants.SubGovernment.PRAGMATIST or zaire.sub_government == GameConstants.SubGovernment.MAOIST






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
			c.puppet_of = GameConstants.LegacySlot.NONE


