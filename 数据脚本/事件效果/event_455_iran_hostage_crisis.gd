extends "res://数据脚本/event_script_base.gd"

## 原作 Event455.cs：伊朗人质危机（四选项）。
## 触发：ReqEventForDLC02.cs:317-319 —— allcountries[8].SubGosstroy==8
##   && DATE_AFTER 1979.11.4；fire_only_once 承担 !event_done[455]。

const TXT_OPT0_DIS_A := "event.script.event_455_iran_hostage_crisis.c0"
const TXT_OPT0_DIS_B := "event.script.event_455_iran_hostage_crisis.c1"
const TXT_OPT0_DIS_C := "event.script.event_455_iran_hostage_crisis.c2"
const TXT_OPT1_DIS_A := "event.script.event_455_iran_hostage_crisis.c3"
const TXT_OPT1_DIS_B := "event.script.event_455_iran_hostage_crisis.c4"
const TXT_OPT1_DIS_C := "event.script.event_455_iran_hostage_crisis.c5"
const TXT_OPT2_DIS_A := "event.script.event_455_iran_hostage_crisis.c6"
const TXT_OPT2_DIS_C := "event.script.event_455_iran_hostage_crisis.c7"
const TXT_R0 := "event.script.event_455_iran_hostage_crisis.c8"
const TXT_R1 := "event.script.event_455_iran_hostage_crisis.c9"
const TXT_R2 := "event.script.event_455_iran_hostage_crisis.c10"
const TXT_R3 := "event.script.event_455_iran_hostage_crisis.c11"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var diplo := d.diplomatic_reputation if d.size() > W.I_DIPLO else 0
	var budget := d.budget if d.size() > W.I_BUDGET else 0
	var reserve := d.reserve if d.size() > W.I_RESERVE else 0
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	var army := d.army if d.size() > W.I_ARMY else 0
	var opt := event_def.options
	if ((line56 >= 1 and line56 <= 3) or (diplo >= 700 and diplo <= 900)) and budget + reserve >= 100 and agents >= 100:
		_enable(opt[0], event_def.options[0].text)
	elif line56 == 0 or diplo > 900:
		_disable(opt[0], tr(TXT_OPT0_DIS_A))
	elif line56 == 4 or diplo < 700:
		_disable(opt[0], tr(TXT_OPT0_DIS_B))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_C))
	if line56 >= 3 and diplo <= 700 and army >= 150 and agents >= 100:
		_enable(opt[1], event_def.options[1].text)
	elif line56 == 0 or diplo > 900:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	elif line56 < 3 or diplo > 700:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_C))
	if line56 < 2 and agents >= 100:
		_enable(opt[2], event_def.options[2].text)
	elif line56 >= 2:
		_disable(opt[2], tr(TXT_OPT2_DIS_A))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_C))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			ws.influence_prc += 50
			_add(W.I_DIPLO, -50)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
		1:
			context["result_text"] = tr(TXT_R1)
			ws.influence_prc += 80
			_add(W.I_DIPLO, -100)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -150)
			_add(W.I_ARMY, -150)
			_add(W.I_AGENTS, -100)
		2:
			context["result_text"] = tr(TXT_R2)
			ws.influence_prc += 50
			_add(W.I_DIPLO, 100)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_AGENTS, -100)
		3:
			context["result_text"] = tr(TXT_R3)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)


func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)


func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

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





# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_455_iran_hostage_crisis.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_455",
	"num": 455,
	"priority": 45500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_455_iran_hostage_crisis.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 8, "target": "8"}, {"t": "DATE_AFTER", "key": "1979.11.4"}, {"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 8, "target": "8"}, {"t": "DATE_AFTER", "key": "1979.11.4"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
