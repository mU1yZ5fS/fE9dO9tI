extends "res://数据脚本/event_script_base.gd"

## 原作 Event610.cs：沙巴战争（扎伊尔/安哥拉干预，四选项）。
## 触发：ReqEventForDLC02.cs:899-901 —— DATE_AFTER 1977.3.8；fire_only_once 承担 !event_done[610]。
## 差异：names1+names2→_foreign_minister_name()；AmericanSupportAttacker→usa_side = GameConstants.WarSide.SIDE1；TickTime(9/6)→fortnight_max。

const TXT_OPT0_DIS_A := "event.script.event_610_shaba_war.c0"
const TXT_OPT0_DIS_B := "event.script.event_610_shaba_war.c1"
const TXT_OPT1_DIS := "event.script.event_610_shaba_war.c2"
const TXT_OPT2_DIS := "event.script.event_610_shaba_war.c3"
const TXT_R0_A := "event.script.event_610_shaba_war.c4"
const TXT_R0_B := "event.script.event_610_shaba_war.c5"
const TXT_WAR0_NAME := "event.script.event_610_shaba_war.c6"
const TXT_WAR0_SIDE1 := "event.script.event_610_shaba_war.c7"
const TXT_WAR0_SIDE2 := "event.script.event_610_shaba_war.c8"
const TXT_R1 := "event.script.event_610_shaba_war.c9"
const TXT_WAR1_NAME := "event.script.event_610_shaba_war.c10"
const TXT_WAR1_SIDE1 := "event.script.event_610_shaba_war.c11"
const TXT_WAR1_SIDE2 := "event.script.event_610_shaba_war.c12"
const TXT_R2 := "event.script.event_610_shaba_war.c13"
const TXT_WAR2_NAME := "event.script.event_610_shaba_war.c14"
const TXT_WAR2_SIDE1 := "event.script.event_610_shaba_war.c15"
const TXT_WAR2_SIDE2 := "event.script.event_610_shaba_war.c16"
const TXT_R3 := "event.script.event_610_shaba_war.c17"
const TXT_WAR3_NAME := "event.script.event_610_shaba_war.c18"
const TXT_WAR3_SIDE1 := "event.script.event_610_shaba_war.c19"
const TXT_WAR3_SIDE2 := "event.script.event_610_shaba_war.c20"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line != 0 and line != 4:
		_enable(opt[0], event_def.options[0].text)
	elif line == 0:
		_disable(opt[0], tr(TXT_OPT0_DIS_A))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_B))
	if line < 3 and line > 0 and world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations > 500:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line < 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var zaire := _country(117)
	var angola := _country(123)
	var opt := int(context.get("option_index", -1))
	if zaire != null:
		_set_part(zaire, 0, true)
	var num := 0
	if opt != 3:
		num = 100
	match opt:
		0:
			context["result_text"] = tr(TXT_R0_A) + _foreign_minister_name() + tr(TXT_R0_B)
			if zaire != null:
				_leave_alliances(zaire)
				zaire.set_tag("亲中", true)
				zaire.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, -50)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 10)
			ws.influence_prc += 10
			_add(W.I_THOUGHT_FREEDOM, -20)
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -20)
			_start_war(60, tr(TXT_WAR0_NAME), tr(TXT_WAR0_SIDE1), tr(TXT_WAR0_SIDE2), 600 + num, 400 - num, 0, 1, 9)
		1:
			context["result_text"] = tr(TXT_R1)
			if zaire != null:
				zaire.set_tag("对华贸易", false)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USSR, 10)
			if angola != null:
				angola.set_tag("对华贸易", true)
			_start_war(60, tr(TXT_WAR1_NAME), tr(TXT_WAR1_SIDE1), tr(TXT_WAR1_SIDE2), 600 - num, 400 + num, 0, 1, 9)
			_add(W.I_BUDGET, -20)
		2:
			context["result_text"] = tr(TXT_R2)
			if zaire != null:
				zaire.set_tag("对华贸易", false)
			_add_relation(EmpireData.USSR, -100)
			_add_relation(EmpireData.USA, -100)
			ws.influence_prc += 20
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -50)
			_start_war(60, tr(TXT_WAR2_NAME), tr(TXT_WAR2_SIDE1), tr(TXT_WAR2_SIDE2), 600 - num, 400 + num, 0, 1, 9)
		3:
			context["result_text"] = tr(TXT_R3)
			_start_war(60, tr(TXT_WAR3_NAME), tr(TXT_WAR3_SIDE1), tr(TXT_WAR3_SIDE2), 600 - num, 400 + num, 0, 1, 6)






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_610_shaba_war.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_610",
	"num": 610,
	"priority": 61000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_610_shaba_war.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.3.8"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
