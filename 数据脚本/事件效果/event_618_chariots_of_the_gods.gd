extends "res://数据脚本/event_script_base.gd"

## 原作 Event618.cs：众神之战车（喀麦隆政变，四选项）。
## 触发：ReqEventForDLC02.cs:924-926 —— !event_done[617] && c66.SubGosstroy==7 && DATE_AFTER 1984.4.5。
## 差异：OilProd 已建模（ws.oil_prod），result0成功线/1/2 各 +100；IsSocialism(true,61)→ws.is_socialism(c61,true)；proprc→亲中。

const TXT_OPT0_DIS := "event.script.event_618_chariots_of_the_gods.c0"
const TXT_OPT1_DIS := "event.script.event_618_chariots_of_the_gods.c1"
const TXT_OPT2_DIS := "event.script.event_618_chariots_of_the_gods.c2"
const TXT_R0_SUC := "event.script.event_618_chariots_of_the_gods.c3"
const TXT_R0_SOC := "event.script.event_618_chariots_of_the_gods.c4"
const TXT_R0_NON := "event.script.event_618_chariots_of_the_gods.c5"
const TXT_R0_LEAK := "event.script.event_618_chariots_of_the_gods.c6"
const TXT_R0_FAIL := "event.script.event_618_chariots_of_the_gods.c7"
const TXT_R1 := "event.script.event_618_chariots_of_the_gods.c8"
const TXT_R2 := "event.script.event_618_chariots_of_the_gods.c9"
const TXT_R3 := "event.script.event_618_chariots_of_the_gods.c10"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line <= 2 and ws.influence_prc >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var cameroon := _country(66)
	var burkina := _country(61)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			if burkina != null and (burkina.sub_government == GameConstants.SubGovernment.LEFT_RADICAL or burkina.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST or burkina.sub_government == GameConstants.SubGovernment.PRAGMATIST) \
					and _done("event_680") and _res_ev("event_680") == 1:
				if cameroon != null:
					_leave_alliances(cameroon)
					cameroon.set_tag("亲中", true)
					cameroon.set_tag("对华贸易", true)
				ws.influence_prc += 20
				_add_relation(EmpireData.USA, -50)
				_add_power(EmpireData.USA, -20)
				ws.oil_prod += 100.0  # Event618.cs result0 成功线：喀麦隆石油合作
				var text := tr(TXT_R0_SUC)
				if burkina != null and ws.is_socialism(burkina, true):
					text += tr(TXT_R0_SOC)
					if cameroon != null:
						cameroon.government = GameConstants.Government.SOCIALIST
						cameroon.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				else:
					text += tr(TXT_R0_NON)
					if cameroon != null:
						cameroon.government = GameConstants.Government.REFORMIST
						cameroon.sub_government = GameConstants.SubGovernment.PRAGMATIST
				context["result_text"] = text
			elif _done("event_680") and _res_ev("event_680") == 0 and not _done("event_617"):
				context["result_text"] = tr(TXT_R0_LEAK)
				if cameroon != null:
					cameroon.level_of_instability += 10
				_add_relation(EmpireData.USA, -25)
			else:
				context["result_text"] = tr(TXT_R0_FAIL)
				_add_relation(EmpireData.USA, -25)
		1:
			context["result_text"] = tr(TXT_R1)
			if cameroon != null:
				cameroon.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_ARMY, -100)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -5)
			ws.oil_prod += 100.0  # Event618.cs result1：阿希乔石油协议
		2:
			context["result_text"] = tr(TXT_R2)
			if cameroon != null:
				cameroon.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_AGENTS, -30)
			ws.oil_prod += 100.0  # Event618.cs result2：比亚石油协议
		3:
			context["result_text"] = tr(TXT_R3)






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_618_chariots_of_the_gods.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_618",
	"num": 618,
	"priority": 61800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_618_chariots_of_the_gods.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_NOT_DONE", "ref": "event_617"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 7, "target": "66"}, {"t": "DATE_AFTER", "key": "1984.4.5"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
