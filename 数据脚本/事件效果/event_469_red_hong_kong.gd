extends "res://数据脚本/event_script_base.gd"

## 原作 Event469.cs：红色香江（香港左派援助二选项）。
## 触发：ReqEventForDLC02.cs:432-434 —— BritLost && data.hk_macau_status<=0；fire_only_once 承担 !event_done[469]。
## 差异：BritLost→global_flags；names1/names2 拼接→ws.leader.name_display。

const TXT_OPT0_DIS := "event.script.event_469_red_hong_kong.c0"
const TXT_R0_P1 := "event.script.event_469_red_hong_kong.c1"
const TXT_R0_P2 := "event.script.event_469_red_hong_kong.c2"
const TXT_R1 := "event.script.event_469_red_hong_kong.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 2:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var opt := event_def.options
	if line56 <= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0_P1) + _leader_name() + tr(TXT_R0_P2)
			_add_relation(EmpireData.USA, -300)
			_add(W.I_PARTY_SUPPORT, 300)
			_add(W.I_PEOPLE_SUPPORT, 300)
			_add(W.I_BUDGET, -10)
			_add(W.I_AGENTS, -10)
			_add(W.I_ARMY, -30)
		1:
			context["result_text"] = tr(TXT_R1)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_469_red_hong_kong.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_469",
	"num": 469,
	"priority": 46900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_469_red_hong_kong.gd",
	"trigger": [{"t": "HAS_FLAG", "key": "BritLost"}, {"t": "RESOURCE_AT_MOST", "key": "hk_macau_status"}, {"t": "ALL", "c": [{"t": "HAS_FLAG", "key": "BritLost"}, {"t": "RESOURCE_AT_MOST", "key": "hk_macau_status"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
