extends "res://数据脚本/event_script_base.gd"

## 原作 Event472.cs：巨熊冬眠（单选项）。
## 触发：ReqEventForDLC02.cs:1429-1431 —— 复合条件（含 num2<3 循环计数）用 trigger_script
##   evaluate(world) 表达；fire_only_once 承担 !event_done[472]。
## 差异：dev→development；isOVD/isSEV/okb/econ/prosov→set_tag。

const TXT_DESC_BASE := "event.script.event_472_bear_hibernation.c0"
const TXT_DESC_DEV1 := "event.script.event_472_bear_hibernation.c1"
const TXT_DESC_DEV2 := "event.script.event_472_bear_hibernation.c2"
const TXT_DESC_DEV3 := "event.script.event_472_bear_hibernation.c3"
const TXT_DESC_TAIL := "event.script.event_472_bear_hibernation.c4"
const TXT_R0 := "event.script.event_472_bear_hibernation.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null:
		return
	var gdr := world.get_country_by_legacy_index(17)
	var west := world.get_country_by_legacy_index(16)
	var text := tr(TXT_DESC_BASE)
	if gdr != null and gdr.development == 1:
		text += tr(TXT_DESC_DEV1)
	elif gdr != null and gdr.development == 2:
		text += tr(TXT_DESC_DEV2)
	elif gdr != null and gdr.development == 3 and (west == null or not west.has_tag("亲苏")):
		text += tr(TXT_DESC_DEV3)
	text += tr(TXT_DESC_TAIL)
	event_def.description = text



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("ovd") and c.has_tag("亲中"):
					c.set_tag("ovd", false)
					c.set_tag("okb", true)
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("sev") and c.has_tag("亲中"):
					c.set_tag("sev", false)
					c.set_tag("econ", true)
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("ovd"):
					c.set_tag("ovd", false)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null and ws.empires[EmpireData.USSR].power > 0:
				_set_power(EmpireData.USSR, 0)



func evaluate(world: WorldState) -> bool:

	if world == null or world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	if world.completed_event_ids.has("event_433"):
		return false
	if world.empires[EmpireData.USSR].current_leader != 6:
		return false
	for idx in [2, 5, 4, 6]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.has_tag("ovd"):
			return false
	var france := world.get_country_by_legacy_index(21)
	if france != null and france.has_tag("soc_eu"):
		return false
	var gdr := world.get_country_by_legacy_index(17)
	var west := world.get_country_by_legacy_index(16)
	var ok_dev := false
	if gdr != null:
		ok_dev = gdr.development == 1 or gdr.development == 2 or (gdr.development == 3 and (west == null or not west.has_tag("亲苏")))
	if not ok_dev:
		return false
	var uk := world.get_country_by_legacy_index(51)
	if uk != null and uk.has_tag("nato"):
		return false
	var china := world.get_country_by_legacy_index(1)
	if china != null and china.has_tag("sev"):
		return false
	var num2 := 0
	for idx in [0, 27, 28, 88, 89, 90, 91]:
		var c := world.get_country_by_legacy_index(idx)
		if c != null and c.有驻军基地:
			num2 += 1
	if num2 >= 3:
		return false
	var poland := world.get_country_by_legacy_index(4)
	if poland != null and poland.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		return false
	return true




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_472_bear_hibernation.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_472",
	"num": 472,
	"priority": 47200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_472_bear_hibernation.gd",
	"trigger_script": "res://数据脚本/事件效果/event_472_bear_hibernation.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
