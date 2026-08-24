extends "res://数据脚本/event_script_base.gd"

## 原作 Event624.cs：不让暴君再蹂躏你（莫桑比克路线，五选项）。
## 触发：ReqEventForDLC02.cs:944-946 —— c126.parts[0] && DATE_AFTER 1983.4.1；parts ExprNode 不支持 → trigger_script。
## 差异：modifies[7].active→modifiers[7]；proprc→亲中、prosov→亲苏、Torg→对华贸易、isSEV→sev。

const TXT_OPT0_DIS := "event.script.event_624_no_tyrant_tramples_you.c0"
const TXT_OPT1_DIS := "event.script.event_624_no_tyrant_tramples_you.c1"
const TXT_OPT2_DIS := "event.script.event_624_no_tyrant_tramples_you.c2"
const TXT_OPT3_DIS := "event.script.event_624_no_tyrant_tramples_you.c3"
const TXT_R0 := "event.script.event_624_no_tyrant_tramples_you.c4"
const TXT_R1 := "event.script.event_624_no_tyrant_tramples_you.c5"
const TXT_R2 := "event.script.event_624_no_tyrant_tramples_you.c6"
const TXT_R3 := "event.script.event_624_no_tyrant_tramples_you.c7"
const TXT_R4 := "event.script.event_624_no_tyrant_tramples_you.c8"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 5:
		return
	_bind_world()
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if china != null and china.has_tag("sev") and world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 600:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 1 and line != 4 and _mod_active(GameConstants.Modifier.BLACK_CAT_WHITE_CAT):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if _res_ev("event_623") == 1 and d.war_support >= 700:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var mozambique := _country(126)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if mozambique != null:
				mozambique.level_of_instability += 50
				_leave_alliances(mozambique)
				mozambique.set_tag("对华贸易", true)
				mozambique.set_tag("亲中", true)
			ws.influence_prc += 25
			_add(W.I_ARMY, -100)
			_add(W.I_BUDGET, -200)
		1:
			context["result_text"] = tr(TXT_R1)
			if mozambique != null:
				mozambique.level_of_instability += 70
				mozambique.set_tag("sev", true)
			_add(W.I_BUDGET, -50)
			ws.influence_prc += 5
			_add_power(EmpireData.USSR, 20)
		2:
			context["result_text"] = tr(TXT_R2)
			if mozambique != null:
				mozambique.government = GameConstants.Government.REFORMIST
				mozambique.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				_leave_alliances(mozambique)
				mozambique.set_tag("对华贸易", true)
				mozambique.set_tag("亲中", true)
			ws.influence_prc += 15
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -150)
		3:
			context["result_text"] = tr(TXT_R3)
			if mozambique != null:
				mozambique.level_of_instability -= 50
				_leave_alliances(mozambique)
				mozambique.set_tag("对华贸易", true)
				mozambique.set_tag("亲苏", true)
			ws.influence_prc += 25
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -100)
		4:
			context["result_text"] = tr(TXT_R4)
			if mozambique != null:
				mozambique.level_of_instability += 20



func evaluate(world: WorldState) -> bool:

	if world == null:
		return false
	var mozambique := world.get_country_by_legacy_index(126)
	if mozambique == null or not (mozambique.parts.size() > 0 and mozambique.parts[0]):
		return false
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	if d.size() <= W.I_YEAR or d.size() <= W.I_MONTH:
		return false
	return d.year >= 1984 or (d.year == 1983 and d.month >= 4)






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_624_no_tyrant_tramples_you.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_624",
	"num": 624,
	"priority": 62400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_624_no_tyrant_tramples_you.gd",
	"trigger_script": "res://数据脚本/事件效果/event_624_no_tyrant_tramples_you.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
