extends "res://数据脚本/event_script_base.gd"

## 原作 Event451.cs：中南半岛的独裁者（柬埔寨波尔布特，二选项）。
## 触发：ReqEventForDLC02.cs:377-379 —— allcountries[23].SubGosstroy==10
##   && DATE_AFTER 1977.3.1；fire_only_once 承担 !event_done[451]。

const TXT_OPT0_DIS := "event.script.event_451_indochina_dictator.c0"
const TXT_OPT1_DIS := "event.script.event_451_indochina_dictator.c1"
const TXT_R0 := "event.script.event_451_indochina_dictator.c2"
const TXT_R1 := "event.script.event_451_indochina_dictator.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 2:
		return
	var line56 := 0
	if world.size() > W.I_POLITICAL_LINE:
		line56 = world.political_line
	var opt := event_def.options
	if line56 < 2 or line56 > 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line56 == 1 or line56 == 2 or line56 == 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var kampuchea := _country(23)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_AGENTS, -30)
			_add(W.I_BUDGET, -30)
			if kampuchea != null:
				kampuchea.government = GameConstants.Government.SOCIALIST
				kampuchea.sub_government = GameConstants.SubGovernment.MAOIST
				kampuchea.stab = 1
				kampuchea.prc_power = 1000
			ws.influence_prc += 50
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_451_indochina_dictator.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_451",
	"num": 451,
	"priority": 45100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_451_indochina_dictator.gd",
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "23"}, {"t": "DATE_AFTER", "key": "1977.3.1"}, {"t": "ALL", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "23"}, {"t": "DATE_AFTER", "key": "1977.3.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
