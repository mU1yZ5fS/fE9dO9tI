extends "res://数据脚本/event_script_base.gd"

## 原作 Event602.cs：“南非”意味着攻击（南非问题六选项）。
## 触发：ReqEventForDLC02.cs:864-866 —— DATE_AFTER 1983.11.2；fire_only_once 承担 !event_done[602]。
## 差异：relres→ws.get_flag；now_leader→current_leader；Vyshi→亲美、Torg→对华贸易；
##   string.Format {1}{2}→_foreign_minister_name()。

const TXT_OPT0_DIS := "event.script.event_602_south_africa_means_attack.c0"
const TXT_OPT1_DIS := "event.script.event_602_south_africa_means_attack.c1"
const TXT_OPT2_DIS := "event.script.event_602_south_africa_means_attack.c2"
const TXT_OPT3_DIS := "event.script.event_602_south_africa_means_attack.c3"
const TXT_OPT4_DIS := "event.script.event_602_south_africa_means_attack.c4"
const TXT_R0_A := "event.script.event_602_south_africa_means_attack.c5"
const TXT_WAR_NAME := "event.script.event_602_south_africa_means_attack.c6"
const TXT_WAR_SIDE1 := "event.script.event_602_south_africa_means_attack.c7"
const TXT_WAR_SIDE2 := "event.script.event_602_south_africa_means_attack.c8"
const TXT_R0_B := "event.script.event_602_south_africa_means_attack.c9"
const TXT_R1 := "event.script.event_602_south_africa_means_attack.c10"
const TXT_WAR1_NAME := "event.script.event_602_south_africa_means_attack.c11"
const TXT_WAR1_SIDE1 := "event.script.event_602_south_africa_means_attack.c12"
const TXT_WAR1_SIDE2 := "event.script.event_602_south_africa_means_attack.c13"
const TXT_R2_BASE := "event.script.event_602_south_africa_means_attack.c14"
const TXT_R2_REFORM := "event.script.event_602_south_africa_means_attack.c15"
const TXT_R2_CONSERV := "event.script.event_602_south_africa_means_attack.c16"
const TXT_R3 := "event.script.event_602_south_africa_means_attack.c17"
const TXT_R4_FMT := "event.script.event_602_south_africa_means_attack.c18"
const TXT_R5 := "event.script.event_602_south_africa_means_attack.c19"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 6:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var china := world.get_country_by_legacy_index(1)
	var usa := world.get_country_by_legacy_index(51)
	var south_africa := world.get_country_by_legacy_index(131)
	var lesotho := world.get_country_by_legacy_index(132)
	var zimbabwe := world.get_country_by_legacy_index(127)
	var mozambique := world.get_country_by_legacy_index(126)
	var opt := event_def.options
	if line < 3 and lesotho != null and lesotho.内战中 and south_africa != null and south_africa.内战中 and ws.influence_prc > 600:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line < 2 and world.get_flag("relres") and china != null and china.has_tag("ovd") \
			and south_africa != null and south_africa.内战中 \
			and (zimbabwe == null or zimbabwe.government != GameConstants.Government.LIBERAL) \
			and (mozambique == null or mozambique.government != GameConstants.Government.LIBERAL) \
			and (zimbabwe == null or not zimbabwe.has_tag("亲美")) \
			and (mozambique == null or not mozambique.has_tag("亲美")):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if china != null and china.government == GameConstants.Government.LIBERAL and south_africa != null and south_africa.内战中 \
			and usa != null and usa.development == 1 \
			and (zimbabwe == null or zimbabwe.puppet_of < 0) \
			and world.empires.size() > EmpireData.USA and world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USA] != null and world.empires[EmpireData.USSR] != null \
			and world.empires[EmpireData.USA].power > world.empires[EmpireData.USSR].power \
			and ws.influence_prc > 500:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if line > 0 and south_africa != null and south_africa.内战中 \
			and world.empires.size() > EmpireData.USA and world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USA] != null and world.empires[EmpireData.USSR] != null \
			and world.empires[EmpireData.USA].relations >= 650 and world.empires[EmpireData.USSR].relations >= 650 \
			and ws.influence_prc > 500:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	if line > 1 and china != null and china.government != GameConstants.Government.SOCIALIST and ws.influence_prc > 500:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))
	_enable(opt[5], event_def.options[5].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var south_africa := _country(131)
	var namibia := _country(153)
	var opt := int(context.get("option_index", -1))
	var num := 0
	if _res_ev("event_609") == 0:
		num = 50
	match opt:
		0:
			if namibia != null and namibia.government == GameConstants.Government.SOCIALIST:
				context["result_text"] = tr(TXT_R0_A)
				_start_war(54, tr(TXT_WAR_NAME), tr(TXT_WAR_SIDE1), tr(TXT_WAR_SIDE2), 400 + num, 600 - num, 1, -1, 24)
			else:
				context["result_text"] = tr(TXT_R0_B)
				_start_war(54, tr(TXT_WAR_NAME), tr(TXT_WAR_SIDE1), tr(TXT_WAR_SIDE2), 500 + num, 500 - num, 1, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 0, true)
				south_africa.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -120)
			_add_relation(EmpireData.USA, -150)
		1:
			context["result_text"] = tr(TXT_R1)
			_start_war(55, tr(TXT_WAR1_NAME), tr(TXT_WAR1_SIDE1), tr(TXT_WAR1_SIDE2), 500 + num, 500 - num, 1, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 1, true)
				south_africa.sub_government = GameConstants.SubGovernment.NEO_FASCIST
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -60)
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, 150)
		2:
			var text2 := _leader_name() + tr(TXT_R2_BASE)
			if world_empire_leader_is(0, 1):
				text2 += tr(TXT_R2_REFORM)
				if south_africa != null:
					south_africa.government = GameConstants.Government.LIBERAL
					south_africa.sub_government = GameConstants.SubGovernment.NEOLIBERAL
					south_africa.set_tag("亲美", true)
					south_africa.set_tag("对华贸易", true)
			else:
				text2 += tr(TXT_R2_CONSERV)
				if south_africa != null:
					south_africa.set_tag("亲美", true)
					south_africa.set_tag("对华贸易", true)
			context["result_text"] = text2
		3:
			context["result_text"] = tr(TXT_R3)
			if south_africa != null:
				south_africa.government = GameConstants.Government.LIBERAL
				south_africa.sub_government = GameConstants.SubGovernment.MODERATE
				south_africa.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -100)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, 150)
		4:
			context["result_text"] = tr(TXT_R4_FMT).replace("{1}{2}", _foreign_minister_name())
			for c in ws.countries:
				if c == null:
					continue
				var i := int(c.原版序号)
				if ((i >= 52 and i < 69) or (i > 105 and i < 109) or (i > 111 and i < 134) \
						or i == 41 or i == 42 or i == 52 or i == 99 or i == 100 or i == 150 or i == 151) \
						and i != 128 and (c.government == GameConstants.Government.SOCIALIST or c.government == GameConstants.Government.REFORMIST or c.sub_government == GameConstants.SubGovernment.LEFT_RADICAL):
					c.set_tag("亲中", false)
					c.set_tag("econ", false)
					c.set_tag("okb", false)
					c.set_tag("对华贸易", false)
			if south_africa != null:
				south_africa.government = GameConstants.Government.REFORMIST
				south_africa.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				_leave_alliances(south_africa)
				_establish_prochina(south_africa)
				south_africa.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -250)
			_add(W.I_PEOPLE_SUPPORT, -150)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add(W.I_AGRICULTURE, 100)
			ws.influence_prc -= 100
		5:
			context["result_text"] = tr(TXT_R5)






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



func world_empire_leader_is(empire_index: int, leader_value: int) -> bool:
	return ws.empires.size() > empire_index and ws.empires[empire_index] != null \
			and ws.empires[empire_index].current_leader == leader_value



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_602_south_africa_means_attack.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_602",
	"num": 602,
	"priority": 60200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_602_south_africa_means_attack.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.11.2"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
