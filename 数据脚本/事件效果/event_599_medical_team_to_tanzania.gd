extends "res://数据脚本/event_script_base.gd"

## 原作 Event599.cs：医疗队员到坦桑（坦桑尼亚战后援助，三选项）。
## 触发：ReqEventForDLC02.cs:849-851 —— event_done[598] && !war53.is_going && !c122.econ。
## 差异：描述按 c118.SubGosstroy==15 动态插入维和经费句；EstablishGovernment(ProChina)→亲中 true。

const TXT_DESC_A := "event.script.event_599_medical_team_to_tanzania.c0"
const TXT_DESC_MID := "event.script.event_599_medical_team_to_tanzania.c1"
const TXT_DESC_B := "event.script.event_599_medical_team_to_tanzania.c2"
const TXT_OPT0_DIS := "event.script.event_599_medical_team_to_tanzania.c3"
const TXT_OPT1_DIS := "event.script.event_599_medical_team_to_tanzania.c4"
const TXT_R0 := "event.script.event_599_medical_team_to_tanzania.c5"
const TXT_R1 := "event.script.event_599_medical_team_to_tanzania.c6"
const TXT_R2 := "event.script.event_599_medical_team_to_tanzania.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var uganda := world.get_country_by_legacy_index(118)
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	var desc := tr(TXT_DESC_A)
	if uganda != null and uganda.sub_government == GameConstants.SubGovernment.PRAGMATIST:
		desc += tr(TXT_DESC_MID)
	desc += tr(TXT_DESC_B)
	event_def.description = desc
	if line < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line < 3 and (world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 700 or (china != null and china.has_tag("sev"))):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var tanzania := _country(122)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_BUDGET, -80)
			if tanzania != null:
				tanzania.government = GameConstants.Government.SOCIALIST
				tanzania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.set_tag("对华贸易", true)
				tanzania.social_stability = 1000
			ws.influence_prc += 10
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -40)
			if tanzania != null:
				tanzania.government = GameConstants.Government.SOCIALIST
				tanzania.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.social_stability = 1000
				tanzania.set_tag("对华贸易", true)
				tanzania.set_tag("sev", true)
			ws.influence_prc += 5
			_add_power(EmpireData.USSR, 25)
			_add_relation(EmpireData.USSR, 100)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -50)
			if tanzania != null:
				tanzania.government = GameConstants.Government.REFORMIST
				tanzania.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				_leave_alliances(tanzania)
				_establish_prochina(tanzania)
				tanzania.social_stability = 1000
				tanzania.set_tag("对华贸易", true)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_599_medical_team_to_tanzania.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_599",
	"num": 599,
	"priority": 59900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_599_medical_team_to_tanzania.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_598"}, {"t": "NOT", "c": [{"t": "WAR_ACTIVE", "v": 53}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "122"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
