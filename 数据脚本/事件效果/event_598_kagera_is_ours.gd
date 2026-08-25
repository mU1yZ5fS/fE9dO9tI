extends "res://数据脚本/event_script_base.gd"

## 原作 Event598.cs：卡盖拉是我们的！（乌坦战争，三选项）。
## 触发：ReqEventForDLC02.cs:844-846 —— DATE_AFTER 1978.11.2；fire_only_once 承担 !event_done[598]。
## 差异：SovietSupportAttacker→ussr_side = GameConstants.WarSide.SIDE1；TickTime(15)→fortnight_max=15。

const TXT_OPT0_DIS := "event.script.event_598_kagera_is_ours.c0"
const TXT_OPT2_DIS := "event.script.event_598_kagera_is_ours.c1"
const TXT_R0 := "event.script.event_598_kagera_is_ours.c2"
const TXT_WAR_NAME := "event.script.event_598_kagera_is_ours.c3"
const TXT_WAR_SIDE1 := "event.script.event_598_kagera_is_ours.c4"
const TXT_WAR_SIDE2 := "event.script.event_598_kagera_is_ours.c5"
const TXT_R1 := "event.script.event_598_kagera_is_ours.c6"
const TXT_R2 := "event.script.event_598_kagera_is_ours.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line < 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)
	if line > 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var tanzania := _country(122)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_start_war(53, tr(TXT_WAR_NAME), tr(TXT_WAR_SIDE1), tr(TXT_WAR_SIDE2), 400, 600, -1, 0, 15)
			if tanzania != null:
				_set_part(tanzania, 0, true)
			_add(W.I_ARMY, -80)
		1:
			context["result_text"] = tr(TXT_R1)
			_start_war(53, tr(TXT_WAR_NAME), tr(TXT_WAR_SIDE1), tr(TXT_WAR_SIDE2), 450, 550, -1, 0, 15)
			if tanzania != null:
				_set_part(tanzania, 0, true)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USSR, 100)
		2:
			context["result_text"] = tr(TXT_R2)
			_start_war(53, tr(TXT_WAR_NAME), tr(TXT_WAR_SIDE1), tr(TXT_WAR_SIDE2), 550, 450, -1, 0, 15)
			if tanzania != null:
				_set_part(tanzania, 0, true)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, 50)
			_add(W.I_DIPLO, -50)






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_598_kagera_is_ours.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_598",
	"num": 598,
	"priority": 59800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_598_kagera_is_ours.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.11.2"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
