extends "res://数据脚本/event_script_base.gd"

## 原作 Event494.cs：防患于未然？（IECS 防火墙，二选项）。
## 触发：ReqEventForDLC02.cs:1534-1536 ——
##   !event_done[112] && event_done[97] && science[16]。
## 差异：science[16] → ExprNode TECH_UNLOCKED(16)；data.budget+data.reserve → 预算+外汇。



const TXT_OPT0_DIS := "event.script.event_494_firewall.c0"

const TXT_R0 := "event.script.event_494_firewall.c1"

const TXT_R1 := "event.script.event_494_firewall.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var budget := world.budget if world.size() > W.I_BUDGET else 0
	var reserve := world.reserve if world.size() > W.I_RESERVE else 0
	var opt := event_def.options
	if budget + reserve >= 100:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_SCIENCE, 300)
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_494_firewall.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_494",
	"num": 494,
	"priority": 49400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_494_firewall.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_NOT_DONE", "ref": "event_112"}, {"t": "PREV_EVENT_DONE", "ref": "event_097"}, {"t": "TECH_UNLOCKED", "v": 16}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
