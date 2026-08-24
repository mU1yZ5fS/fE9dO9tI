extends "res://数据脚本/event_script_base.gd"

## 原作 Event471.cs：毛泽东思想在……苏联？（苏联左翼异见者三选项）。
## 触发：ReqEventForDLC02.cs:437-439 —— DATE_AFTER 1980.9.1；fire_only_once 承担 !event_done[471]。
## 差异：relres→ws.get_flag("relres")；proprc→亲中、Torg→对华贸易；
##   SOV_PRC_PartiesConnection 未出现在本事件，data.science 直接按原版。

const TXT_OPT0_DIS := "event.script.event_471_maoism_in_soviet.c0"
const TXT_OPT1_DIS_A := "event.script.event_471_maoism_in_soviet.c1"
const TXT_OPT1_DIS_B := "event.script.event_471_maoism_in_soviet.c2"
const TXT_R0 := "event.script.event_471_maoism_in_soviet.c3"
const TXT_R1_BASE := "event.script.event_471_maoism_in_soviet.c4"
const TXT_R1_ALB := "event.script.event_471_maoism_in_soviet.c5"
const TXT_R2 := "event.script.event_471_maoism_in_soviet.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var albania := world.get_country_by_legacy_index(20)
	var sov := world.get_country_by_legacy_index(7)
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var mod53 := world.modifiers.size() > 53 and world.modifiers[53] != null and world.modifiers[53].is_active
	var opt := event_def.options
	if line56 < 2 and albania != null and albania.has_tag("亲中") and world.influence_prc >= 500 and mod6:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if not mod3 and line56 != 0 and world.get_flag("relres") and sov != null and sov.has_tag("对华贸易") and mod53:
		_enable(opt[1], event_def.options[1].text)
	elif line56 == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	_enable(opt[2], event_def.options[2].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			ws.influence_prc += 20
			_add_power(EmpireData.USSR, -10)
		1:
			var text := tr(TXT_R1_BASE)
			var albania := _country(20)
			if albania != null and albania.has_tag("亲中"):
				text += tr(TXT_R1_ALB)
				albania.set_tag("亲中", false)
				albania.set_tag("对华贸易", false)
				albania.set_tag("econ", false)
				albania.set_tag("okb", false)
			context["result_text"] = text
			_add_relation(EmpireData.USSR, 150)
			_add(W.I_BUDGET, 100)
			_add(W.I_SCIENCE, 100)
			_add(W.I_DIPLO, -100)
			ws.influence_prc -= 50
			_add_power(EmpireData.USSR, 50)
		2:
			context["result_text"] = tr(TXT_R2)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_471_maoism_in_soviet.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_471",
	"num": 471,
	"priority": 47100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_471_maoism_in_soviet.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1980.9.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
