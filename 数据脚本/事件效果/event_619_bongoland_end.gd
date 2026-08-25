extends "res://数据脚本/event_script_base.gd"

## 原作 Event619.cs：“邦戈兰”的终结？（加蓬干预，五选项）。
## 触发：无自动触发点——原版由 DiploButtonScript.cs:4656-4658（this_type 外交按钮）手动 number_event=619。
## 差异：based→有驻军基地；OilProd 已建模（ws.oil_prod），result1三路/2/3/4 各 +100；IsSocialism/IsAuthoritarianism→ws 谓词；name→chinese_name。

const TXT_OPT1_DIS := "event.script.event_619_bongoland_end.c0"
const TXT_OPT2_DIS := "event.script.event_619_bongoland_end.c1"
const TXT_OPT3_DIS := "event.script.event_619_bongoland_end.c2"
const TXT_OPT4_DIS := "event.script.event_619_bongoland_end.c3"
const TXT_R0_INTRO := "event.script.event_619_bongoland_end.c4"
const TXT_R0_LEFT := "event.script.event_619_bongoland_end.c5"
const TXT_R0_ELSE := "event.script.event_619_bongoland_end.c6"
const TXT_R1 := "event.script.event_619_bongoland_end.c7"
const TXT_R2 := "event.script.event_619_bongoland_end.c8"
const TXT_R3 := "event.script.event_619_bongoland_end.c9"
const TXT_R4 := "event.script.event_619_bongoland_end.c10"
const TXT_NAME_R4 := "event.script.event_619_bongoland_end.c11"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 5:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var budget := d.budget if d.size() > W.I_BUDGET else 0
	var reserve := d.reserve if d.size() > W.I_RESERVE else 0
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	var army := d.army if d.size() > W.I_ARMY else 0
	var gabon := world.get_country_by_legacy_index(116)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if budget + reserve >= 50 and agents >= 80:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line >= 3 and budget + reserve >= 50 and agents >= 80:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if line <= 2 and budget + reserve >= 100 and agents >= 100:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	if line <= 1 and budget + reserve >= 150 and agents >= 150 and army >= 150 \
			and gabon != null and gabon.有驻军基地:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], tr(TXT_OPT4_DIS))



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var gabon := _country(116)
	var france := _country(21)
	var china := _country(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := tr(TXT_R0_INTRO)
			if france != null and (france.sub_government == GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST or france.sub_government == GameConstants.SubGovernment.EUROCOMMUNIST):
				text += tr(TXT_R0_LEFT)
				if gabon != null:
					gabon.government = GameConstants.Government.REFORMIST
					gabon.sub_government = GameConstants.SubGovernment.PRAGMATIST
					gabon.puppet_of = GameConstants.LegacySlot.FRANCE
			else:
				text += tr(TXT_R0_ELSE)
				if gabon != null:
					gabon.government = GameConstants.Government.AUTHORITARIAN
					gabon.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					gabon.puppet_of = GameConstants.LegacySlot.FRANCE
			context["result_text"] = text
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -80)
			if gabon != null:
				_leave_alliances(gabon)
				gabon.set_tag("对华贸易", true)
			if _empire_power(0) > ws.influence_prc:
				if gabon != null:
					gabon.government = GameConstants.Government.AUTHORITARIAN
					gabon.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					gabon.set_tag("亲美", true)
				_add_power(EmpireData.USA, 20)
			elif ws.is_socialism(china, true) or (china != null and china.government == GameConstants.Government.REFORMIST):
				if gabon != null:
					gabon.government = GameConstants.Government.REFORMIST
					gabon.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
					gabon.set_tag("亲中", true)
				ws.influence_prc += 10
				ws.oil_prod += 100.0  # Event619.cs result1 社会主义分支：加蓬石油合作
			elif ws.is_authoritarian(china):
				if gabon != null:
					gabon.government = GameConstants.Government.AUTHORITARIAN
					gabon.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					gabon.set_tag("亲中", true)
				ws.influence_prc += 10
				ws.oil_prod += 100.0  # Event619.cs result1 威权分支
			else:
				if gabon != null:
					gabon.government = GameConstants.Government.LIBERAL
					gabon.sub_government = GameConstants.SubGovernment.MODERATE
					gabon.set_tag("亲中", true)
				ws.influence_prc += 10
				ws.oil_prod += 100.0  # Event619.cs result1 其他分支
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -80)
			if gabon != null:
				gabon.government = GameConstants.Government.LIBERAL
				gabon.sub_government = GameConstants.SubGovernment.LIBERAL
				_leave_alliances(gabon)
				gabon.set_tag("对华贸易", true)
				gabon.set_tag("亲中", true)
			ws.influence_prc += 10
			ws.oil_prod += 100.0  # Event619.cs result2
		3:
			context["result_text"] = tr(TXT_R3)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if gabon != null:
				gabon.government = GameConstants.Government.REFORMIST
				gabon.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				_leave_alliances(gabon)
				gabon.set_tag("对华贸易", true)
				gabon.set_tag("亲中", true)
			ws.influence_prc += 20
			ws.oil_prod += 100.0  # Event619.cs result3
		4:
			context["result_text"] = tr(TXT_R4)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			if gabon != null:
				gabon.government = GameConstants.Government.SOCIALIST
				gabon.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(gabon)
				gabon.set_tag("对华贸易", true)
				gabon.set_tag("亲中", true)
				gabon.chinese_name = tr(TXT_NAME_R4)
			ws.influence_prc += 20
			ws.oil_prod += 100.0  # Event619.cs result4






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



func _empire_power(idx: int) -> int:
	if ws.empires.size() > idx and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_619_bongoland_end.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_619",
	"num": 619,
	"priority": 61900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_619_bongoland_end.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
