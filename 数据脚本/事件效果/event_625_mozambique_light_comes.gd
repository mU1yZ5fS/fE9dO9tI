extends "res://数据脚本/event_script_base.gd"

## 原作 Event625.cs：莫桑比克，光明到来？（莫桑比克内战结算，单选项）。 ## 触发：TimeScript.cs:7160 —— (c126.level_of_unstab>=1000 c126.level_of_unstab<=0) && !event_done[625] && c126.parts[0]； ##  parts/level_of_unstab ExprNode 不支持 → trigger_script。 ## 差异：描述与结果按 level_of_instability 分支；TextOfEvents 的 parts[0]=false 在 prepare 中复刻。

const TXT_DESC_A := "event.script.event_625_mozambique_light_comes.c0"
const TXT_DESC_B := "event.script.event_625_mozambique_light_comes.c1"
const TXT_R0_A := "event.script.event_625_mozambique_light_comes.c2"
const TXT_R0_MID := "event.script.event_625_mozambique_light_comes.c3"
const TXT_R0_B := "event.script.event_625_mozambique_light_comes.c4"
const TXT_R0_FAIL := "event.script.event_625_mozambique_light_comes.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null:
		return
	_bind_world()
	var mozambique := world.get_country_by_legacy_index(126)
	if mozambique == null:
		return
	if mozambique.level_of_instability >= 1000:
		event_def.description = tr(TXT_DESC_A)
	else:
		event_def.description = tr(TXT_DESC_B)
	_set_part(mozambique, 0, false)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var mozambique := _country(126)
	var china := _country(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if mozambique != null and mozambique.level_of_instability >= 1000:
				var text := tr(TXT_R0_A)
				if ws.is_socialism(china, true) and _res_ev("event_623") != 1:
					text += tr(TXT_R0_MID)
				text += tr(TXT_R0_B)
				context["result_text"] = text
				if mozambique != null:
					mozambique.government = GameConstants.Government.SOCIALIST
					mozambique.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
				if ws.is_socialism(china, true) and _res_ev("event_623") != 1:
					if mozambique != null:
						_leave_alliances(mozambique)
						mozambique.set_tag("对华贸易", true)
						mozambique.set_tag("亲中", true)
					ws.influence_prc += 30
					_add_relation(EmpireData.USA, -50)
				_add_relation(EmpireData.USA, -50)
				_add_power(EmpireData.USA, -30)
			else:
				context["result_text"] = tr(TXT_R0_FAIL)
				if mozambique != null:
					mozambique.government = GameConstants.Government.AUTHORITARIAN
					mozambique.sub_government = GameConstants.SubGovernment.NEO_FASCIST
					_leave_alliances(mozambique)
					mozambique.puppet_of = GameConstants.LegacySlot.SOUTH_AFRICA
				if _res_ev("event_623") == 1:
					if mozambique != null:
						mozambique.set_tag("对华贸易", true)
					_add_relation(EmpireData.USA, 100)
				_add_power(EmpireData.USA, 30)



func evaluate(world: WorldState) -> bool:

	if world == null:
		return false
	var mozambique := world.get_country_by_legacy_index(126)
	if mozambique == null or not (mozambique.parts.size() > 0 and mozambique.parts[0]):
		return false
	return mozambique.level_of_instability >= 1000 or mozambique.level_of_instability <= 0






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





# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_625_mozambique_light_comes.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_625",
	"num": 625,
	"priority": 62500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_625_mozambique_light_comes.gd",
	"trigger_script": "res://数据脚本/事件效果/event_625_mozambique_light_comes.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
