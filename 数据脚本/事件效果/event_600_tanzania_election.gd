extends "res://数据脚本/event_script_base.gd"

## 原作 Event600.cs：坦桑尼亚大选（四选项）。
## 触发：ReqEventForDLC02.cs:854-856 —— DATE_AFTER 1985.10.1；fire_only_once 承担 !event_done[600]。
## 差异：描述按 resultOfEvents[599]==0 动态插入巴布回归句；JoinAllOurAlliances(true)→_join_alliances。

const TXT_DESC_A := "event.script.event_600_tanzania_election.c0"
const TXT_DESC_MID := "event.script.event_600_tanzania_election.c1"
const TXT_DESC_B := "event.script.event_600_tanzania_election.c2"
const TXT_OPT0_DIS := "event.script.event_600_tanzania_election.c3"
const TXT_OPT1_DIS := "event.script.event_600_tanzania_election.c4"
const TXT_OPT2_DIS := "event.script.event_600_tanzania_election.c5"
const TXT_R0 := "event.script.event_600_tanzania_election.c6"
const TXT_R1_PRE_A := "event.script.event_600_tanzania_election.c7"
const TXT_R1_PRE_B := "event.script.event_600_tanzania_election.c8"
const TXT_R1_SEV := "event.script.event_600_tanzania_election.c9"
const TXT_R1_NO_SEV := "event.script.event_600_tanzania_election.c10"
const TXT_R2 := "event.script.event_600_tanzania_election.c11"
const TXT_R3 := "event.script.event_600_tanzania_election.c12"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	var desc := tr(TXT_DESC_A)
	if int(world.completed_event_ids.get("event_599", 0)) == 0:
		desc += tr(TXT_DESC_MID)
	desc += tr(TXT_DESC_B)
	event_def.description = desc
	if line < 2 and int(world.completed_event_ids.get("event_599", 0)) == 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line < 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 2 and not world.completed_event_ids.has("event_500"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var tanzania := _country(122)
	var china := _country(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_BUDGET, -50)
			if tanzania != null:
				tanzania.government = GameConstants.Government.SOCIALIST
				tanzania.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				_join_alliances(tanzania)
				tanzania.social_stability = 1000
				tanzania.set_tag("对华贸易", true)
			ws.influence_prc += 50
		1:
			var text := tr(TXT_R1_NO_SEV)
			if tanzania != null and tanzania.has_tag("sev"):
				var pre := tr(TXT_R1_PRE_A)
				if china != null and china.has_tag("sev"):
					pre = tr(TXT_R1_PRE_B)
				text = pre + tr(TXT_R1_SEV)
			context["result_text"] = text
			if tanzania != null:
				_leave_alliances(tanzania)
				if tanzania.has_tag("sev"):
					_establish_prosoviet(tanzania)
					_add_power(EmpireData.USSR, 25)
					_add_relation(EmpireData.USSR, 100)
				else:
					_establish_prochina(tanzania)
			_add(W.I_BUDGET, -50)
			if tanzania != null:
				tanzania.government = GameConstants.Government.SOCIALIST
				tanzania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				tanzania.set_tag("对华贸易", true)
				tanzania.social_stability = 1000
			ws.influence_prc += 5
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -60)
			if tanzania != null:
				tanzania.government = GameConstants.Government.LIBERAL
				tanzania.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.set_tag("对华贸易", true)
				tanzania.social_stability = 1000
			ws.influence_prc += 5
		3:
			context["result_text"] = tr(TXT_R3)
			_add(W.I_BUDGET, -60)
			if tanzania != null:
				tanzania.government = GameConstants.Government.REFORMIST
				tanzania.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.set_tag("对华贸易", true)
				tanzania.social_stability = 1000
			ws.influence_prc += 5






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_600_tanzania_election.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_600",
	"num": 600,
	"priority": 60000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_600_tanzania_election.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1985.10.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
