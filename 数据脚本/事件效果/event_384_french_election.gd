extends "res://数据脚本/event_script_base.gd"

## 原作 Event384.cs：法国选举（五选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - YugAgree → ws.get_flag("YugAgree")；
##  - 描述与选项按 YugAgree 动态改写；result<4 扣除资源后返回对应文本。

const TXT_DESC_YUG := "event.script.event_384_french_election.c0"
const TXT_OPT1_YUG := "event.script.event_384_french_election.c1"
const TXT_DIS_BUDGET := "event.script.event_384_french_election.c2"
const TXT_DIS_AGENTS := "event.script.event_384_french_election.c3"
const TXT_R0 := "event.script.event_384_french_election.c4"
const TXT_R1 := "event.script.event_384_french_election.c5"
const TXT_R2 := "event.script.event_384_french_election.c6"
const TXT_R3 := "event.script.event_384_french_election.c7"
const TXT_R4 := "event.script.event_384_french_election.c8"
const TXT_R1_YUG := "event.script.event_384_french_election.c9"


const TXT_LABEL_BUDGET := "event.script.event_384_french_election.c10"
const TXT_LABEL_AGENTS := "event.script.event_384_french_election.c11"
const TXT_LABEL_ARMY := "event.script.event_384_french_election.c12"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	if world.get_flag("YugAgree"):
		event_def.description = tr(TXT_DESC_YUG)
	_prepare_cost(opt[0], event_def.options[0].text)
	if world.get_flag("YugAgree"):
		_prepare_cost(opt[1], tr(TXT_OPT1_YUG))
	else:
		_prepare_cost(opt[1], event_def.options[1].text)
	_prepare_cost(opt[2], event_def.options[2].text)
	_prepare_cost(opt[3], event_def.options[3].text)
	_enable(opt[4], event_def.options[4].text)


func _prepare_cost(opt: EventOption, text: String) -> void:
	if _d(W.I_AGENTS) >= 50 and _d(W.I_BUDGET) + _d(W.I_RESERVE) >= 30:
		_enable(opt, text)
	elif _d(W.I_BUDGET) + _d(W.I_RESERVE) < 30:
		_disable(opt, tr(TXT_DIS_BUDGET).format([3]))
	else:
		_disable(opt, tr(TXT_DIS_AGENTS).format([5]))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt < 4:
		_add(W.I_AGENTS, -50)
		_add(W.I_BUDGET, -30)
	if ws.get_flag("YugAgree") and opt == 1:
		context["result_text"] = tr(TXT_R1_YUG)
		return
	match opt:
		0: context["result_text"] = tr(TXT_R0)
		1: context["result_text"] = tr(TXT_R1)
		2: context["result_text"] = tr(TXT_R2)
		3: context["result_text"] = tr(TXT_R3)
		_: context["result_text"] = tr(TXT_R4)




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_384_french_election.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_384",
	"num": 384,
	"priority": 38400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_384_french_election.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
