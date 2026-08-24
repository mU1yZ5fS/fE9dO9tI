extends "res://数据脚本/event_script_base.gd"

## 原作 Event621.cs：一个独裁者将会被另一个独裁者杀死（赤道几内亚政变，四选项）。
## 触发：ReqEventForDLC02.cs:934-936 —— IsAuthoritarianism(115) && DATE_AFTER 1979.8.1。
## 差异：Torg→对华贸易、proprc→亲中；puppetOf=21 照抄。

const TXT_OPT0_DIS := "event.script.event_621_dictator_killed_by_another.c0"
const TXT_OPT1_DIS := "event.script.event_621_dictator_killed_by_another.c1"
const TXT_OPT2_DIS := "event.script.event_621_dictator_killed_by_another.c2"
const TXT_R0 := "event.script.event_621_dictator_killed_by_another.c3"
const TXT_R1 := "event.script.event_621_dictator_killed_by_another.c4"
const TXT_R2 := "event.script.event_621_dictator_killed_by_another.c5"
const TXT_R3 := "event.script.event_621_dictator_killed_by_another.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var war_support := d.war_support if d.size() > W.I_WAR_SUPPORT else 0
	var france := world.get_country_by_legacy_index(21)
	var cameroon := world.get_country_by_legacy_index(66)
	var gabon := world.get_country_by_legacy_index(116)
	var opt := event_def.options
	if line > 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 0 and war_support >= 700:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if france != null and france.has_tag("对华贸易") \
			and cameroon != null and cameroon.puppet_of == GameConstants.LegacySlot.FRANCE \
			and gabon != null and gabon.puppet_of == GameConstants.LegacySlot.FRANCE:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var eq_guinea := _country(115)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if eq_guinea != null:
				eq_guinea.government = GameConstants.Government.AUTHORITARIAN
				eq_guinea.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(eq_guinea)
				eq_guinea.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_ARMY, -50)
			_add(W.I_AGENTS, -50)
		1:
			context["result_text"] = tr(TXT_R1)
			if eq_guinea != null:
				_leave_alliances(eq_guinea)
				eq_guinea.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_ARMY, -70)
			_add(W.I_AGENTS, -50)
		2:
			context["result_text"] = tr(TXT_R2)
			if eq_guinea != null:
				eq_guinea.government = GameConstants.Government.AUTHORITARIAN
				eq_guinea.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(eq_guinea)
				eq_guinea.set_tag("对华贸易", true)
				eq_guinea.puppet_of = GameConstants.LegacySlot.FRANCE
			_add(W.I_AGENTS, -50)
		3:
			context["result_text"] = tr(TXT_R3)
			if eq_guinea != null:
				eq_guinea.government = GameConstants.Government.AUTHORITARIAN
				eq_guinea.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_621_dictator_killed_by_another.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_621",
	"num": 621,
	"priority": 62100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_621_dictator_killed_by_another.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "115"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "sub_government", "target": "115"}, {"t": "DATE_AFTER", "key": "1979.8.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
