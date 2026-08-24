extends "res://数据脚本/event_script_base.gd"

const TXT_697_OPT1 := "event.script.event_697_cyprus_election.c0"
const TXT_697_OPT1_DIS_A := "event.script.event_697_cyprus_election.c1"
const TXT_697_OPT1_DIS_B := "event.script.event_697_cyprus_election.c2"


## 原作 Event697.cs：爱神之吻（塞浦路斯大选）。
## 只移植数值/国家状态效果；长文本用英文摘要。
## 触发：ReqEventForDLC02.cs:1024（1983.2.13 起或 1983.3 起或 1984 起）。


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null or event_def.options.size() < 2:
		return
	var line := p_ws.political_line if p_ws.size() > W.I_POLITICAL_LINE else 0
	var opt1 := event_def.options[1]
	if line > 0 and line < 4:
		opt1.text = tr(TXT_697_OPT1)
		opt1.disabled_text = ""
	elif line == 0:
		opt1.text = tr(TXT_697_OPT1)
		opt1.disabled_text = tr(TXT_697_OPT1_DIS_A)
	else:
		opt1.text = tr(TXT_697_OPT1)
		opt1.disabled_text = tr(TXT_697_OPT1_DIS_B)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	_event_697(option_index, context)
	ws.set_flag("event_done_697", true)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_697(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_result_0(context)
		1:
			_result_1(context)
		2:
			_result_2(context)
		3:
			_result_3(context)


func _result_0(context: Dictionary) -> void:
	# Event697.cs:91-101
	_add_data(W.I_BUDGET, -50)
	_add_data(W.I_AGENTS, -50)
	_add_data(W.I_ARMY, -50)
	var cyprus := _cyprus()
	if cyprus != null:
		_leave_alliances(cyprus)
		cyprus.government = GameConstants.Government.SOCIALIST
		cyprus.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		if not cyprus.内战中:
			cyprus.set_tag("对华贸易", true)
			cyprus.set_tag("亲中", true)
	context["result_text"] = tr("event.script.event_697_cyprus_election.i0")


func _result_1(context: Dictionary) -> void:
	# Event697.cs:106-145
	_add_data(W.I_BUDGET, -50)
	_add_data(W.I_AGENTS, -50)
	var cyprus := _cyprus()
	var greece := ws.get_country_by_legacy_index(45)
	if _socialist_count() >= 3 and greece != null and greece.government == GameConstants.Government.REFORMIST:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.SOCIALIST
			cyprus.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
			cyprus.set_tag("亲苏", true)
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
		context["result_text"] = tr("event.script.event_697_cyprus_election.i1")
	elif greece != null and greece.government != GameConstants.Government.REFORMIST:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.LIBERAL
			cyprus.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		context["result_text"] = tr("event.script.event_697_cyprus_election.i2")
	else:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.REFORMIST
			cyprus.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
			_copy_soc_eu_from_turkey(cyprus)
		context["result_text"] = tr("event.script.event_697_cyprus_election.i3")


func _result_2(context: Dictionary) -> void:
	# Event697.cs:148-180
	_add_data(W.I_BUDGET, -50)
	_add_data(W.I_AGENTS, -50)
	var cyprus := _cyprus()
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null and greece.government == GameConstants.Government.LIBERAL:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.LIBERAL
			cyprus.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
				cyprus.set_tag("亲中", true)
		context["result_text"] = tr("event.script.event_697_cyprus_election.i4")
	elif _event_result(GameConstants.EventId.MAKARIOS_DEATH, 1):
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.AUTHORITARIAN
			cyprus.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		context["result_text"] = tr("event.script.event_697_cyprus_election.i5")
	else:
		context["result_text"] = tr("event.script.event_697_cyprus_election.i6")


func _result_3(context: Dictionary) -> void:
	context["result_text"] = tr("event.script.event_697_cyprus_election.i7")


func _socialist_count() -> int:
	var count := 0
	for legacy_idx in [21, 29, 85, 86, 87, 92]:
		var c := ws.get_country_by_legacy_index(legacy_idx)
		if c != null and ws.is_socialism(c, true):
			count += 1
	return count


func _event_result(event_id: String, default: int) -> bool:
	if ws.completed_event_ids.has(event_id):
		return int(ws.completed_event_ids[event_id]) == default
	return ws.global_flags.get("result_%s" % event_id, -1) == default


func _copy_soc_eu_from_turkey(cyprus: CountryData) -> void:
	# Event697.cs:139-143：allcountries[85]（土耳其）是 soc_eu 时，塞浦路斯同步。
	var turkey := ws.get_country_by_legacy_index(85)
	if turkey != null and turkey.has_tag("soc_eu"):
		cyprus.set_tag("soc_eu", true)



func _cyprus() -> CountryData:
	return ws.get_country_by_legacy_index(94)


func _add_data(index: int, delta: int) -> void:
	if index >= 0 and index < d.size():
		d.add_data_by_index(index, delta)


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d.usa_relations = ws.empires[EmpireData.USA].relations
		d.usa_influence = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d.ussr_relations = ws.empires[EmpireData.USSR].relations
		d.soviet_influence = ws.empires[EmpireData.USSR].power



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_697_cyprus_election.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_697",
	"num": 697,
	"priority": 186,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_697_cyprus_election.gd",
	"trigger": [{"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1983.2.13"}, {"t": "DATE_AFTER", "key": "1983.3.1"}, {"t": "DATE_AFTER", "key": "1984.1"}]}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 500}, {"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_695"}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "20"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 2, "target": "45"}, {"t": "SOCIALIST_COUNT_AT_LEAST", "v": 3, "keys": ["21", "29", "85", "86", "87", "92"]}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 3}]}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_EQUALS", "key": "political_line", "v": 4}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
