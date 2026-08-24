extends "res://数据脚本/event_script_base.gd"

## 原作 Event608.cs：安吉拉行动（塞舌尔反政变，三选项）。
## 触发：ReqEventForDLC02.cs:889-891 —— DATE_AFTER 1981.11.25；fire_only_once 承担 !event_done[608]。
## 差异：JoinECON→set_tag("econ")；proprc→亲中、Torg→对华贸易；puppetOf=131 照抄。

const TXT_OPT0_DIS := "event.script.event_608_operation_angela.c0"
const TXT_OPT1_DIS := "event.script.event_608_operation_angela.c1"
const TXT_R0 := "event.script.event_608_operation_angela.c2"
const TXT_R1 := "event.script.event_608_operation_angela.c3"
const TXT_R2 := "event.script.event_608_operation_angela.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var diplo := d.diplomatic_reputation if d.size() > W.I_DIPLO else 0
	var seychelles := world.get_country_by_legacy_index(155)
	var opt := event_def.options
	if line <= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if seychelles != null and seychelles.government != GameConstants.Government.SOCIALIST and line > 1 and diplo <= 700:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var seychelles := _country(155)
	var china := _country(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			if seychelles != null:
				if seychelles.government == GameConstants.Government.SOCIALIST:
					seychelles.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				else:
					seychelles.government = GameConstants.Government.SOCIALIST
					seychelles.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(seychelles)
				seychelles.set_tag("亲中", true)
				seychelles.set_tag("对华贸易", true)
				if china != null and china.has_tag("econ"):
					seychelles.set_tag("econ", true)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_AGENTS, -30)
			if seychelles != null:
				seychelles.government = GameConstants.Government.AUTHORITARIAN
				seychelles.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				_leave_alliances(seychelles)
				seychelles.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
		2:
			context["result_text"] = tr(TXT_R2)
			if seychelles != null:
				seychelles.set_tag("亲中", false)






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_608_operation_angela.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_608",
	"num": 608,
	"priority": 60800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_608_operation_angela.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1981.11.25"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
