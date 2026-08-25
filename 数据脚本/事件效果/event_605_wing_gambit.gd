extends "res://数据脚本/event_script_base.gd"

## 原作 Event605.cs：后翼弃车？（阿扎尼亚温妮·曼德拉，三选项）。
## 触发：ReqEventForDLC02.cs:879-881 —— c131.SubGosstroy==10 && DATE_AFTER 1985.12.1。
## 差异：Torg→对华贸易、proprc→亲中；结果2 文本按原版逐字。

const TXT_OPT2_DIS := "event.script.event_605_wing_gambit.c0"
const TXT_R0 := "event.script.event_605_wing_gambit.c1"
const TXT_R1 := "event.script.event_605_wing_gambit.c2"
const TXT_R2 := "event.script.event_605_wing_gambit.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	if china != null and china.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var south_africa := _country(131)
	var lesotho := _country(132)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if south_africa != null:
				south_africa.set_tag("亲中", true)
				south_africa.set_tag("对华贸易", true)
			if lesotho != null:
				lesotho.set_tag("对华贸易", true)
			_add(W.I_DIPLO, 30)
			_add_relation(EmpireData.USA, -50)
		1:
			context["result_text"] = tr(TXT_R1)
			if south_africa != null:
				south_africa.set_tag("对华贸易", false)
			if lesotho != null:
				lesotho.set_tag("对华贸易", false)
			_add(W.I_DIPLO, -20)
			_add_relation(EmpireData.USA, 50)
		2:
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -100)
			context["result_text"] = tr(TXT_R2)
			if south_africa != null:
				south_africa.government = GameConstants.Government.AUTHORITARIAN
				south_africa.sub_government = GameConstants.SubGovernment.FEUDAL_SOCIALIST
				south_africa.set_tag("亲中", true)
				south_africa.set_tag("对华贸易", true)






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_605_wing_gambit.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_605",
	"num": 605,
	"priority": 60500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_605_wing_gambit.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "131"}, {"t": "DATE_AFTER", "key": "1985.12.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
