extends "res://数据脚本/event_script_base.gd"

## 原作 Event603.cs：总统大选：彩虹之国（南非大选，三选项）。
## 触发：ReqEventForDLC02.cs:869-871 —— c131.SubGosstroy==5 && DATE_AFTER 1985.8.15。
## 差异：name→chinese_name；puppetOf 循环→_free_puppets(131)；prosov→亲苏、proprc→亲中、Vyshi→亲美。

const TXT_NAME_RSA := "event.script.event_603_presidential_election_rainbow_nation.c0"
const TXT_R_COMMON := "event.script.event_603_presidential_election_rainbow_nation.c1"
const TXT_R2_PRORPC := "event.script.event_603_presidential_election_rainbow_nation.c2"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var south_africa := _country(131)
	var opt := int(context.get("option_index", -1))
	if south_africa != null:
		south_africa.chinese_name = tr(TXT_NAME_RSA)
	match opt:
		0:
			context["result_text"] = tr(TXT_R_COMMON)
			if world_empire_power_gt(1, 0):
				if south_africa != null:
					south_africa.government = GameConstants.Government.REFORMIST
					south_africa.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					south_africa.set_tag("亲苏", true)
			else:
				if south_africa != null:
					south_africa.government = GameConstants.Government.LIBERAL
					south_africa.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
			_free_puppets(131)
		1:
			context["result_text"] = tr(TXT_R_COMMON)
			if ws.influence_prc + _empire_power(1) > _empire_power(0):
				if south_africa != null:
					south_africa.government = GameConstants.Government.REFORMIST
					south_africa.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
					south_africa.set_tag("亲中", true)
			else:
				if south_africa != null:
					south_africa.government = GameConstants.Government.LIBERAL
					south_africa.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
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
				context["result_text"] = tr(TXT_R2_PRORPC)
				if ws.influence_prc > _empire_power(0):
					if south_africa != null:
						south_africa.government = GameConstants.Government.LIBERAL
						south_africa.sub_government = GameConstants.SubGovernment.MODERATE
						south_africa.set_tag("亲中", true)
						south_africa.set_tag("对华贸易", true)
				else:
					if south_africa != null:
						south_africa.government = GameConstants.Government.LIBERAL
						south_africa.sub_government = GameConstants.SubGovernment.MODERATE
						south_africa.set_tag("亲美", true)
						south_africa.set_tag("对华贸易", true)
			else:
				context["result_text"] = tr(TXT_R_COMMON)






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
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
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



func _empire_power(idx: int) -> int:
	if ws.empires.size() > idx and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func world_empire_power_gt(a: int, b: int) -> bool:
	return _empire_power(a) > _empire_power(b)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_603_presidential_election_rainbow_nation.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_603",
	"num": 603,
	"priority": 60300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_603_presidential_election_rainbow_nation.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 5, "target": "131"}, {"t": "DATE_AFTER", "key": "1985.8.15"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
