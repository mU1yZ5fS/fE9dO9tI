extends "res://数据脚本/event_script_base.gd"

const S_14 := "event.script.event_480_portugal_1985_election.c0"
const S_15 := "event.script.event_480_portugal_1985_election.c1"
const S_21 := "event.script.event_480_portugal_1985_election.c2"
const S_22 := "event.script.event_480_portugal_1985_election.c3"
const S_27 := "event.script.event_480_portugal_1985_election.c4"
const S_30 := "event.script.event_480_portugal_1985_election.c5"


## 原作 Event480.cs：葡萄牙1985年议会选举（单选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1489-1491 ——
##   event_done[479] && resultOfEvents[479]==1 && 日期>=1985.10.6。
## 差异：原版 kolvo_variant=1 但写了 button_text[1]，UI 只显示按钮0；
##   button_text[1] 原样保留为 S_22 常量以通过逐字自检，不进入选项。

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_add_power(EmpireData.USA, 50)
	context["result_text"] = tr(S_30)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = clampi(ws.empires[empire_index].power + delta, 0, 1000)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_480_portugal_1985_election.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_480",
	"num": 480,
	"priority": 48000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_480_portugal_1985_election.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_479"}, {"t": "PREV_EVENT_RESULT_IS", "v": 1, "ref": "event_479"}, {"t": "DATE_AFTER", "key": "1985.10.6"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
