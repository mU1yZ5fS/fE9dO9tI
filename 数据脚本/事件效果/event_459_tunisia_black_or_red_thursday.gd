extends "res://数据脚本/event_script_base.gd"

## 原作 Event459.cs：黑色星期四？红色星期四？（突尼斯干预四选项）。
## 触发：ReqEventForDLC02.cs:342-344 —— DATE_AFTER 1978.1.20；fire_only_once 承担 !event_done[459]。
## 差异：Vyshi→亲美、prosov→亲苏、Torg→对华贸易；cw→内战中；
##   结果3文本中 <color=red>...</color> 按项目规则剥除。

const TXT_OPT0_DIS := "event.script.event_459_tunisia_black_or_red_thursday.c0"
const TXT_OPT1_DIS := "event.script.event_459_tunisia_black_or_red_thursday.c1"
const TXT_OPT2_DIS := "event.script.event_459_tunisia_black_or_red_thursday.c2"
const TXT_R0 := "event.script.event_459_tunisia_black_or_red_thursday.c3"
const TXT_R1 := "event.script.event_459_tunisia_black_or_red_thursday.c4"
const TXT_R2 := "event.script.event_459_tunisia_black_or_red_thursday.c5"
const TXT_R3 := "event.script.event_459_tunisia_black_or_red_thursday.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()

	if event_def == null or event_def.options.size() < 4:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line56 := d.political_line if d.size() > W.I_POLITICAL_LINE else 0
	var ideology := d.ideology if d.size() > W.I_IDEOLOGY else 0
	var france := world.get_country_by_legacy_index(21)
	var opt := event_def.options
	if ideology <= 3 and line56 <= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null and world.empires[EmpireData.USSR].relations >= 600:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line56 > 0 and france != null and france.has_tag("对华贸易") and france.government != GameConstants.Government.SOCIALIST:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var tunisia := _country(55)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			if tunisia != null:
				tunisia.government = GameConstants.Government.REFORMIST
				tunisia.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				tunisia.set_tag("亲美", false)
				tunisia.set_tag("亲苏", false)
				tunisia.set_tag("对华贸易", true)
				tunisia.内战中 = true
			ws.influence_prc += 20
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add_relation(EmpireData.USA, -100)
			_add_power(EmpireData.USA, -30)
			_add_relation(EmpireData.USSR, 50)
			_add_power(EmpireData.USSR, 10)
		1:
			context["result_text"] = tr(TXT_R1)
			if tunisia != null:
				tunisia.government = GameConstants.Government.REFORMIST
				tunisia.sub_government = GameConstants.SubGovernment.PRAGMATIST
				tunisia.set_tag("亲美", false)
				tunisia.set_tag("对华贸易", true)
				tunisia.set_tag("亲苏", true)
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -20)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USSR, 50)
			_add_power(EmpireData.USSR, 10)
		2:
			context["result_text"] = tr(TXT_R2)
			if tunisia != null:
				tunisia.government = GameConstants.Government.AUTHORITARIAN
				tunisia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				tunisia.puppet_of = GameConstants.LegacySlot.FRANCE
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 50)
		3:
			context["result_text"] = tr(TXT_R3)
			if tunisia != null:
				tunisia.government = GameConstants.Government.AUTHORITARIAN
				tunisia.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
				tunisia.set_tag("亲美", true)
			_add_power(EmpireData.USA, 50)




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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_459_tunisia_black_or_red_thursday.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_459",
	"num": 459,
	"priority": 45900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_459_tunisia_black_or_red_thursday.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.1.20"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
