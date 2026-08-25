extends "res://数据脚本/event_script_base.gd"

## 原作 Event474.cs：维新之冬（韩国釜马事态三选项）。
## 触发：ReqEventForDLC02.cs:1439-1441 —— DATE_AFTER 1979.10.10；fire_only_once 承担 !event_done[474]。
## 差异：SubGosstroy→sub_government；Torg→对华贸易。

const TXT_OPT0_DIS := "event.script.event_474_yusin_winter.c0"
const TXT_OPT1_DIS := "event.script.event_474_yusin_winter.c1"
const TXT_R0 := "event.script.event_474_yusin_winter.c2"
const TXT_R1 := "event.script.event_474_yusin_winter.c3"
const TXT_R2 := "event.script.event_474_yusin_winter.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	var army := d.army if d.size() > W.I_ARMY else 0
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var opt := event_def.options
	if agents >= 50 and army >= 50:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if agents >= 50 and line56 >= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var korea := _country(46)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if korea != null:
				korea.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -10)
			ws.influence_prc += 10
		1:
			context["result_text"] = tr(TXT_R1)
			if korea != null:
				korea.sub_government = GameConstants.SubGovernment.NEO_FASCIST
				korea.set_tag("对华贸易", true)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, -100)
		2:
			context["result_text"] = tr(TXT_R2)
			if korea != null:
				korea.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_474_yusin_winter.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_474",
	"num": 474,
	"priority": 47400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_474_yusin_winter.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.10.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
