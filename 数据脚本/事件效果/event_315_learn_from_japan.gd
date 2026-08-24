extends "res://数据脚本/event_script_base.gd"

## 原作 Event315.cs：以日为师（2选项）。
## 触发：全目录搜索无 this_num_event = 315 / Reset(315) / StartEvent(315)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 134-139。

const TXT_R0 := "event.script.event_315_learn_from_japan.c0"
const TXT_R1 := "event.script.event_315_learn_from_japan.c1"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 5)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_LIVING, -300)
			_add(W.I_BUDGET, 50)
			_add(W.I_AGRICULTURE, 25)
			_add(W.I_INDUSTRY, 25)
			context["result_text"] = tr(TXT_R1)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_315_learn_from_japan.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_315",
	"num": 315,
	"priority": 31500,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_315_learn_from_japan.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
