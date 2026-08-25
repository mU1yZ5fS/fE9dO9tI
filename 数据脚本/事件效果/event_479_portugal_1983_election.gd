extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_479_portugal_1983_election.c0"
const S_15 := "event.script.event_479_portugal_1983_election.c1"
const S_23 := "event.script.event_479_portugal_1983_election.c2"
const S_28 := "event.script.event_479_portugal_1983_election.c3"
const S_33 := "event.script.event_479_portugal_1983_election.c4"
const S_35 := "event.script.event_479_portugal_1983_election.c5"
const S_40 := "event.script.event_479_portugal_1983_election.c6"
const S_43 := "event.script.event_479_portugal_1983_election.c7"
const S_52 := "event.script.event_479_portugal_1983_election.c8"


## 原作 Event479.cs：葡萄牙1983年议会选举（两选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1409-1411 ——
##   event_done[419] && 日期>=1983.4.25。
## 差异：Vyshi→亲美；选项0 显隐与门槛文本按原版 if/else 链 prepare 动态改写。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var sum := world.budget + world.reserve
	if sum >= 50 and world.agents >= 50:
		_enable(opt[0], tr(S_23))
	elif sum <= 50:
		_disable(opt[0], tr(S_28))
	else:
		_disable(opt[0], tr(S_33))
	_enable(opt[1], tr(S_35))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var portugal := ws.get_country_by_legacy_index(87)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if portugal != null:
				portugal.government = GameConstants.Government.REFORMIST
				portugal.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
				portugal.set_tag("亲美", false)
			context["result_text"] = tr(S_43)
		1:
			if portugal != null:
				portugal.government = GameConstants.Government.LIBERAL
				portugal.sub_government = GameConstants.SubGovernment.MODERATE
			context["result_text"] = tr(S_52)








# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_479_portugal_1983_election.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_479",
	"num": 479,
	"priority": 47900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_479_portugal_1983_election.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_419"}, {"t": "DATE_AFTER", "key": "1983.4.25"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
