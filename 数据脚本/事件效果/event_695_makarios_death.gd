extends "res://数据脚本/event_script_base.gd"

## 原作 Event695.cs：圣徒与罪人之国（马卡里奥斯逝世，塞浦路斯政治干预）。
## 只移植数值/国家状态效果；长文本用英文摘要。
## 触发：ReqEventForDLC02.cs:1019 —— 1977.8.3 起。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	match option_index:
		0:
			# Event695.cs:49-55
			_add_data(W.I_BUDGET, -30)
			_add_data(W.I_AGENTS, -30)
			_set_torg_94()
			context["result_text"] = tr("event.script.event_695_makarios_death.i0")
		1:
			# Event695.cs:57-62
			_add_data(W.I_BUDGET, -40)
			_add_data(W.I_AGENTS, -40)
			context["result_text"] = tr("event.script.event_695_makarios_death.i1")
		2:
			# Event695.cs:64-69
			_add_data(W.I_BUDGET, -50)
			_add_data(W.I_AGENTS, -50)
			context["result_text"] = tr("event.script.event_695_makarios_death.i2")
		3:
			context["result_text"] = tr("event.script.event_695_makarios_death.i3")
		_:
			pass
	ws.set_flag("event_done_695", true)
	_sync_empire_mirrors()


func _set_torg_94() -> void:
	var cyprus := ws.get_country_by_legacy_index(94)
	if cyprus != null:
		cyprus.set_tag("对华贸易", true)


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
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_695_makarios_death.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_695",
	"num": 695,
	"priority": 185,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.8.3"}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 1}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 3}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
