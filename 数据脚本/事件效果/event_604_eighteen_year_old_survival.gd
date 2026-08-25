extends "res://数据脚本/event_script_base.gd"

## 原作 Event604.cs：十八岁的我只想活下去（南非人民邦特别军事行动，单选项）。
## 触发：ReqEventForDLC02.cs:874-876 —— c131.SubGosstroy==9 && !war54.is_going && DATE_AFTER 1984.1.1。
## 差异：描述按 c127.puppet_of<0 动态插入“、津巴布韦”；AmericanSupportAttacker→usa_side = GameConstants.WarSide.SIDE1。

const TXT_DESC_A := "event.script.event_604_eighteen_year_old_survival.c0"
const TXT_DESC_MID := "event.script.event_604_eighteen_year_old_survival.c1"
const TXT_DESC_B := "event.script.event_604_eighteen_year_old_survival.c2"
const TXT_R0 := "event.script.event_604_eighteen_year_old_survival.c3"
const TXT_WAR0_NAME := "event.script.event_604_eighteen_year_old_survival.c4"
const TXT_WAR0_SIDE1 := "event.script.event_604_eighteen_year_old_survival.c5"
const TXT_WAR0_SIDE2 := "event.script.event_604_eighteen_year_old_survival.c6"
const TXT_WAR1_NAME := "event.script.event_604_eighteen_year_old_survival.c7"
const TXT_WAR1_SIDE1 := "event.script.event_604_eighteen_year_old_survival.c8"
const TXT_WAR1_SIDE2 := "event.script.event_604_eighteen_year_old_survival.c9"
const TXT_WAR2_NAME := "event.script.event_604_eighteen_year_old_survival.c10"
const TXT_WAR2_SIDE1 := "event.script.event_604_eighteen_year_old_survival.c11"
const TXT_WAR2_SIDE2 := "event.script.event_604_eighteen_year_old_survival.c12"
const TXT_WAR3_NAME := "event.script.event_604_eighteen_year_old_survival.c13"
const TXT_WAR3_SIDE1 := "event.script.event_604_eighteen_year_old_survival.c14"
const TXT_WAR3_SIDE2 := "event.script.event_604_eighteen_year_old_survival.c15"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null:
		return
	var zimbabwe := world.get_country_by_legacy_index(127)
	var desc := tr(TXT_DESC_A)
	if zimbabwe != null and zimbabwe.puppet_of < 0:
		desc += tr(TXT_DESC_MID)
	desc += tr(TXT_DESC_B)
	event_def.description = desc



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var south_africa := _country(131)
	var zimbabwe := _country(127)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_start_war(56, tr(TXT_WAR0_NAME), tr(TXT_WAR0_SIDE1), tr(TXT_WAR0_SIDE2), 300, 700, 1, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 2, true)
			_start_war(57, tr(TXT_WAR1_NAME), tr(TXT_WAR1_SIDE1), tr(TXT_WAR1_SIDE2), 300, 700, 1, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 3, true)
			_start_war(58, tr(TXT_WAR2_NAME), tr(TXT_WAR2_SIDE1), tr(TXT_WAR2_SIDE2), 300, 700, 1, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 4, true)
			_start_war(59, tr(TXT_WAR3_NAME), tr(TXT_WAR3_SIDE1), tr(TXT_WAR3_SIDE2), 300, 700, 1, 0, 24)
			if zimbabwe != null:
				_set_part(zimbabwe, 0, true)






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





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_604_eighteen_year_old_survival.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_604",
	"num": 604,
	"priority": 60400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_604_eighteen_year_old_survival.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 9, "target": "131"}, {"t": "NOT", "c": [{"t": "WAR_ACTIVE", "v": 54}]}, {"t": "DATE_AFTER", "key": "1984.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
