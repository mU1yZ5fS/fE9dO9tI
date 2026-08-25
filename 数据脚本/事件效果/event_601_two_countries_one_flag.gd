extends "res://数据脚本/event_script_base.gd"

## 原作 Event601.cs：两个国家，一面旗帜（几内亚比绍政变，四选项）。
## 触发：ReqEventForDLC02.cs:859-861 —— DATE_AFTER 1980.11.1；fire_only_once 承担 !event_done[601]。
## 差异：proprc→亲中；Torg→对华贸易；name→chinese_name；names1+names2→_leader_name()。

const TXT_OPT0_DIS := "event.script.event_601_two_countries_one_flag.c0"
const TXT_OPT1_DIS_A := "event.script.event_601_two_countries_one_flag.c1"
const TXT_OPT1_DIS_B := "event.script.event_601_two_countries_one_flag.c2"
const TXT_OPT2_DIS := "event.script.event_601_two_countries_one_flag.c3"
const TXT_R0_A := "event.script.event_601_two_countries_one_flag.c4"
const TXT_R0_B := "event.script.event_601_two_countries_one_flag.c5"
const TXT_NAME_UNION := "event.script.event_601_two_countries_one_flag.c6"
const TXT_R0_FAIL := "event.script.event_601_two_countries_one_flag.c7"
const TXT_R1 := "event.script.event_601_two_countries_one_flag.c8"
const TXT_R2 := "event.script.event_601_two_countries_one_flag.c9"
const TXT_R3 := "event.script.event_601_two_countries_one_flag.c10"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line != 0 and line != 4:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	if line >= 3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var guinea := _country(68)
	var guinea_bissau := _country(114)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if guinea != null and guinea.has_tag("对华贸易") and ws.influence_prc >= 500:
				context["result_text"] = tr(TXT_R0_A) + _leader_name() + tr(TXT_R0_B)
				if guinea_bissau != null:
					guinea_bissau.set_tag("亲中", true)
					guinea_bissau.set_tag("对华贸易", true)
					guinea_bissau.chinese_name = tr(TXT_NAME_UNION)
				# “几内亚佛得角共和国”必须把佛得角岛也并入地图归属（佛得角地图 gwcode=402，
				# 几内亚比绍/联合国家 gwcode=404），否则地图上只有几内亚比绍、没有佛得角。
				if GameManager != null and GameManager.has_method("transfer_map_owner"):
					GameManager.transfer_map_owner(402, 404)
				ws.influence_prc += 10
			else:
				context["result_text"] = tr(TXT_R0_FAIL)
				if guinea_bissau != null:
					guinea_bissau.government = GameConstants.Government.AUTHORITARIAN
					guinea_bissau.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					_leave_alliances(guinea_bissau)
		1:
			context["result_text"] = tr(TXT_R1)
			if guinea_bissau != null:
				guinea_bissau.government = GameConstants.Government.AUTHORITARIAN
				guinea_bissau.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				guinea_bissau.set_tag("亲中", true)
				guinea_bissau.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -50)
		2:
			context["result_text"] = tr(TXT_R2)
			if guinea_bissau != null:
				guinea_bissau.puppet_of = GameConstants.LegacySlot.FRANCE
				guinea_bissau.government = GameConstants.Government.LIBERAL
				guinea_bissau.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				guinea_bissau.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -50)
		3:
			context["result_text"] = tr(TXT_R3)
			if guinea_bissau != null:
				guinea_bissau.government = GameConstants.Government.AUTHORITARIAN
				guinea_bissau.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST






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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_601_two_countries_one_flag.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_601",
	"num": 601,
	"priority": 60100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_601_two_countries_one_flag.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1980.11.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
