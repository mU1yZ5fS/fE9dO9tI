extends "res://数据脚本/event_script_base.gd"

## 原作 Event617.cs：四月九日的复仇（第二次喀麦隆战争，单选项）。
## 触发：ReqEventForDLC02.cs:929-931 —— event_done[680] && c66.level_of_unstab>=100 && c66.SubGosstroy==7
##   && resultOfEvents[618]!=1 && resultOfEvents[618]!=2。
## 差异：描述按 c66.puppet_of == GameConstants.LegacySlot.FRANCE 动态插入“和法国外籍兵团”；AmericanSupportAttacker→usa_side = GameConstants.WarSide.SIDE1。

const TXT_R0_A := "依托于地下网络，UPC已经在城市中组织起总罢工和工人民兵部队，和JOSE的城市游击队一起发动起义同喀麦隆民族解放军配合作战。政府军"
const TXT_R0_MID := "和法国外籍兵团"
const TXT_R0_B := "采取了同上次一样的措施，大规模暴力镇压革命分子。第二次喀麦隆战争就此打响。"
const TXT_WAR_NAME := "第二次喀麦隆战争"
const TXT_WAR_SIDE1 := "喀麦隆政府"
const TXT_WAR_SIDE2 := "喀麦隆人民联盟"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var cameroon := _country(66)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0_A
			if cameroon != null and cameroon.puppet_of == GameConstants.LegacySlot.FRANCE:
				text += TXT_R0_MID
			text += TXT_R0_B
			context["result_text"] = text
			if cameroon != null:
				_set_part(cameroon, 0, true)
				cameroon.set_tag("对华贸易", false)
			_add_relation(EmpireData.USA, -150)
			_start_war(63, TXT_WAR_NAME, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 600, 400, 0, 1, 24)






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


