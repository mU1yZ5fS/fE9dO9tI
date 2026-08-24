extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_478_portugal_hot_summer_continues.c0"
const S_15 := "event.script.event_478_portugal_hot_summer_continues.c1"
const S_23 := "event.script.event_478_portugal_hot_summer_continues.c2"
const S_24 := "event.script.event_478_portugal_hot_summer_continues.c3"
const S_25 := "event.script.event_478_portugal_hot_summer_continues.c4"
const S_32 := "event.script.event_478_portugal_hot_summer_continues.c5"
const S_33 := "event.script.event_478_portugal_hot_summer_continues.c6"
const S_34 := "event.script.event_478_portugal_hot_summer_continues.c7"
const S_36 := "event.script.event_478_portugal_hot_summer_continues.c8"
const S_41 := "event.script.event_478_portugal_hot_summer_continues.c9"
const S_44 := "event.script.event_478_portugal_hot_summer_continues.c10"
const S_50 := "event.script.event_478_portugal_hot_summer_continues.c11"
const S_57 := "event.script.event_478_portugal_hot_summer_continues.c12"
const S_63 := "event.script.event_478_portugal_hot_summer_continues.c13"


## 原作 Event478.cs：燥热之夏的延续？（四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1484-1486 ——
##   !event_done[420] && !event_done[419] && c87.spec<=20 && 日期>=1980.4.20。
## 差异：spec→special；选项0-2 显隐 prepare 动态改写；选项3 无效果但有结果文本。

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var can := world.budget + world.reserve >= 50 \
			and world.agents >= 50
	if can:
		_enable(opt[0], tr(S_23))
		_enable(opt[1], tr(S_24))
		_enable(opt[2], tr(S_25))
	else:
		_disable(opt[0], tr(S_32))
		_disable(opt[1], tr(S_33))
		_disable(opt[2], tr(S_34))
	_enable(opt[3], tr(S_36))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(S_44)
		1:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(S_50)
		2:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			context["result_text"] = tr(S_57)
		3:
			context["result_text"] = tr(S_63)








# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_478_portugal_hot_summer_continues.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_478",
	"num": 478,
	"priority": 47800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_478_portugal_hot_summer_continues.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_NOT_DONE", "ref": "event_419"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_420"}, {"t": "COUNTRY_FIELD_AT_MOST", "key": "special", "v": 20, "target": "87"}, {"t": "DATE_AFTER", "key": "1980.4.20"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
