extends "res://数据脚本/event_script_base.gd"

## 原作 Event615.cs：红狮（塞内加尔大选，三选项）。
## 触发：ReqEventForDLC02.cs:919-921 —— DATE_AFTER 1983.2.27；fire_only_once 承担 !event_done[615]。
## 差异：c112.parts[1]/war52 显隐原版不 Destroy 的选项用 _enable 双文案；level_of_unstab→level_of_instability。

const TXT_OPT0_ALT := "event.script.event_615_red_lion.c0"
const TXT_OPT1_DIS := "event.script.event_615_red_lion.c1"
const TXT_OPT2_DIS := "event.script.event_615_red_lion.c2"
const TXT_R0 := "event.script.event_615_red_lion.c3"
const TXT_R0_FAIL := "event.script.event_615_red_lion.c4"
const TXT_R1 := "event.script.event_615_red_lion.c5"
const TXT_R2 := "event.script.event_615_red_lion.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	_bind_world()
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var _senegal := world.get_country_by_legacy_index(112)
	var guinea := world.get_country_by_legacy_index(68)
	var opt := event_def.options
	var cond := int(world.completed_event_ids.get("event_597", 0)) == 1 \
			and not _part(112, 1) and not _war_going(52)
	if cond:
		_enable(opt[0], event_def.options[0].text)
	else:
		_enable(opt[0], tr(TXT_OPT0_ALT))
	if cond and line > 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line < 2 and guinea != null and guinea.has_tag("对华贸易"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var senegal := _country(112)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if _res_ev("event_597") == 1 and not _part(112, 1) and not _war_going(52):
				context["result_text"] = tr(TXT_R0)
				if senegal != null:
					senegal.government = GameConstants.Government.LIBERAL
					senegal.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				_add(W.I_THOUGHT_FREEDOM, -20)
				_add(W.I_ARMY, -50)
				_add(W.I_BUDGET, -20)
			else:
				context["result_text"] = tr(TXT_R0_FAIL)
		1:
			context["result_text"] = tr(TXT_R1)
			if senegal != null:
				senegal.government = GameConstants.Government.LIBERAL
				senegal.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				senegal.set_tag("对华贸易", true)
			ws.influence_prc += 10
			_add(W.I_BUDGET, -50)
		2:
			context["result_text"] = tr(TXT_R2)
			ws.influence_prc += 20
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if senegal != null:
				senegal.level_of_instability = 300






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_615_red_lion.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_615",
	"num": 615,
	"priority": 61500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_615_red_lion.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1983.2.27"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
