extends "res://数据脚本/event_script_base.gd"

## 原作 Event330.cs：对葡谈判（3选项）。
## 触发：全目录搜索无 this_num_event = 330 / Reset(330) / StartEvent(330)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 266-273。

const TXT_R0 := "event.script.event_330_portugal_talks.c0"
const TXT_R1 := "event.script.event_330_portugal_talks.c1"
const TXT_R2 := "event.script.event_330_portugal_talks.c2"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, 10)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, 50)
			_add(W.I_INFLUENCE, 70)
			_add_power(0, -70)
			_add_relation(0, -70)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_DIPLO, -30)
			_add(W.I_INFLUENCE, 70)
			_add_power(0, -110)
			_add_relation(0, -110)
			context["result_text"] = tr(TXT_R2)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_330_portugal_talks.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_330",
	"num": 330,
	"priority": 33000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_330_portugal_talks.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
