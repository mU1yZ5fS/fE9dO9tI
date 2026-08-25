extends "res://数据脚本/event_script_base.gd"

## 原作 Event614.cs：叛徒去死（加丹加收复，单选项）。 ## 触发：ReqEventForDLC02.cs:914-916 —— c163.parts[0] && (c117.SubGosstroy==15 c117.SubGosstroy==17)。 ##  parts[0] ExprNode 不支持 → trigger_script=evaluate()（同文件）。

const TXT_R0_A := "event.script.event_614_traitor_die.c0"
const TXT_R0_B := "event.script.event_614_traitor_die.c1"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var zaire := _country(117)
	var katanga := _country(163)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if zaire != null and zaire.government == GameConstants.Government.SOCIALIST:
				context["result_text"] = tr(TXT_R0_A)
			else:
				context["result_text"] = tr(TXT_R0_B)
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





# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_614_traitor_die.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_614",
	"num": 614,
	"priority": 61400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_614_traitor_die.gd",
	"trigger_script": "res://数据脚本/事件效果/event_614_traitor_die.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
