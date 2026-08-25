extends "res://数据脚本/event_script_base.gd"

## 原作 Event458.cs：拔掉獠牙（马里政变四选项）。
## 触发：ReqEventForDLC02.cs:332-334 —— DATE_AFTER 1978.2.28；fire_only_once 承担 !event_done[458]。
## 差异：Vyshi→亲美、prosov→亲苏、proprc→亲中、Torg→对华贸易；cw→内战中；
##   resultOfEvents[505] 移植说明按 int 默认 0 处理。

const TXT_OPT0_DIS := "event.script.event_458_mali_pull_the_fangs.c0"
const TXT_OPT1_DIS := "event.script.event_458_mali_pull_the_fangs.c1"
const TXT_OPT2_DIS := "event.script.event_458_mali_pull_the_fangs.c2"
const TXT_R0 := "event.script.event_458_mali_pull_the_fangs.c3"
const TXT_R1_KGB := "event.script.event_458_mali_pull_the_fangs.c4"
const TXT_R1_OURS := "event.script.event_458_mali_pull_the_fangs.c5"
const TXT_R2 := "event.script.event_458_mali_pull_the_fangs.c6"
const TXT_R3 := "event.script.event_458_mali_pull_the_fangs.c7"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var mali := world.get_country_by_legacy_index(58)
	var alb := world.get_country_by_legacy_index(20)
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var res505 := int(world.completed_event_ids.get("event_505", 0))
	var opt := event_def.options
	if line56 >= 1 and line56 <= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line56 <= 2 and (mali != null and mali.内战中 or (world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 500)):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line56 <= 1 and mod6 and alb != null and alb.has_tag("对华贸易") and res505 == 0:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var mali := _country(58)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_tag(58, "对华贸易", true)
			_add(W.I_BUDGET, -70)
			_add_relation(EmpireData.USA, 50)
		1:
			if mali != null and not mali.内战中:
				context["result_text"] = tr(TXT_R1_KGB)
				if mali != null:
					mali.government = GameConstants.Government.AUTHORITARIAN
					mali.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					mali.puppet_of = GameConstants.LegacySlot.NONE
					mali.set_tag("亲美", false)
					mali.set_tag("对华贸易", true)
					mali.set_tag("亲苏", true)
			else:
				context["result_text"] = tr(TXT_R1_OURS)
				if mali != null:
					mali.government = GameConstants.Government.AUTHORITARIAN
					mali.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					mali.puppet_of = GameConstants.LegacySlot.NONE
					mali.set_tag("亲美", false)
					mali.set_tag("对华贸易", true)
					mali.set_tag("亲中", true)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -50)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -30)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -50)
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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_458_mali_pull_the_fangs.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_458",
	"num": 458,
	"priority": 45800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_458_mali_pull_the_fangs.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.2.28"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
