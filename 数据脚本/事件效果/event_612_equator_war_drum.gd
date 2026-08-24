extends "res://数据脚本/event_script_base.gd"

## 原作 Event612.cs：赤道战鼓（刚果革命战争，单选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:4980-4982（this_type 外交按钮）手动 number_event=612。
## 差异：描述按 resultOfEvents[610]==2 动态插入书记名；AmericanSupportAttacker.SovietSupportAttacker→usa_side = GameConstants.WarSide.SIDE1/ussr_side = GameConstants.WarSide.SIDE1。

const TXT_DESC_A := "event.script.event_612_equator_war_drum.c0"
const TXT_NAME_KISASE := "event.script.event_612_equator_war_drum.c1"
const TXT_NAME_KABILA := "event.script.event_612_equator_war_drum.c2"
const TXT_DESC_B := "event.script.event_612_equator_war_drum.c3"
const TXT_R0 := "event.script.event_612_equator_war_drum.c4"
const TXT_WAR_NAME := "event.script.event_612_equator_war_drum.c5"
const TXT_WAR_SIDE1 := "event.script.event_612_equator_war_drum.c6"
const TXT_WAR_SIDE2 := "event.script.event_612_equator_war_drum.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null:
		return
	if int(world.completed_event_ids.get("event_610", 0)) == 2:
		event_def.description = tr(TXT_DESC_A) + tr(TXT_NAME_KISASE) + tr(TXT_DESC_B)
	else:
		event_def.description = tr(TXT_DESC_A) + tr(TXT_NAME_KABILA) + tr(TXT_DESC_B)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var zaire := _country(117)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if zaire != null:
				_set_part(zaire, 1, true)
				zaire.set_tag("对华贸易", false)
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, -150)
			_start_war(62, tr(TXT_WAR_NAME), tr(TXT_WAR_SIDE1), tr(TXT_WAR_SIDE2), 700, 300, 0, 0, 24)






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_612_equator_war_drum.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_612",
	"num": 612,
	"priority": 61200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_612_equator_war_drum.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
