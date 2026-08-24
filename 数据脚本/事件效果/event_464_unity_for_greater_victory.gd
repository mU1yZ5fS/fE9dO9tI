extends "res://数据脚本/event_script_base.gd"

## 原作 Event464.cs：团结起来，争取更大胜利（申根式协议三选项）。
## 触发：ReqEventForDLC02.cs:412-414 —— 欧共体各国 econ 标签链；fire_only_once 承担 !event_done[464]。
## 差异：soc_stab→social_stability；proprc→亲中、sovalliance→苏联盟友、usalliance→美国盟友；
##   isSocEU→soc_eu 标签。

const TXT_OPT0_DIS := "event.script.event_464_unity_for_greater_victory.c0"
const TXT_R0 := "event.script.event_464_unity_for_greater_victory.c1"
const TXT_R1 := "event.script.event_464_unity_for_greater_victory.c2"
const TXT_R2 := "event.script.event_464_unity_for_greater_victory.c3"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	if china != null and china.has_tag("okb"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_shengen_base()
			_shengen_loop(true)
		1:
			context["result_text"] = tr(TXT_R1)
			_shengen_base()
			_shengen_loop(false)
		2:
			context["result_text"] = tr(TXT_R2)



func _shengen_base() -> void:
	_add(W.I_THOUGHT_FREEDOM, 50)
	_add(W.I_PEOPLE_SUPPORT, 80)
	ws.influence_prc += 10
	_add(W.I_CORRUPTION, 30)
	_add(W.I_BUDGET, 30)


func _shengen_loop(military_only: bool) -> void:
	for c in ws.countries:
		if c == null:
			continue
		var joined := c.has_tag("okb")
		if not military_only:
			joined = joined or c.has_tag("econ")
		if not joined:
			continue
		c.social_stability += 200
		_add(W.I_BUDGET, -5)
		if not c.has_tag("亲中") and not c.has_tag("苏联盟友") and not c.has_tag("美国盟友"):
			c.set_tag("亲中", true)
			_add(W.I_BUDGET, -20)
		elif not c.has_tag("亲中") and (c.has_tag("苏联盟友") or c.has_tag("美国盟友")):
			c.set_tag("苏联盟友", false)
			c.set_tag("美国盟友", false)
			_add(W.I_BUDGET, -30)



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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_464_unity_for_greater_victory.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_464",
	"num": 464,
	"priority": 46400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_464_unity_for_greater_victory.gd",
	"trigger": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "21"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "17"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "16"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "development", "v": 3, "target": "17"}, {"t": "ANY", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "17"}, {"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "16"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "development", "v": 3, "target": "17"}]}]}, {"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "16"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "development", "v": 3, "target": "17"}]}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "89"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "88"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "0"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "1"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "soc_eu", "target": "85"}]}, {"t": "COUNTRY_HAS_TAG", "key": "soc_eu", "target": "85"}, {"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "21"}, {"t": "ANY", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "17"}, {"t": "ALL", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "16"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "development", "v": 3, "target": "17"}]}]}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "89"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "88"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "0"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "1"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "soc_eu", "target": "85"}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
