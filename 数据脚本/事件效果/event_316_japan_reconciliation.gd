extends "res://数据脚本/event_script_base.gd"

## 原作 Event316.cs：与日本和解？（2选项）。
## 触发：全目录搜索无 this_num_event = 316 / Reset(316) / StartEvent(316)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 140-145。

const TXT_R0 := "event.script.event_316_japan_reconciliation.c0"
const TXT_R1 := "event.script.event_316_japan_reconciliation.c1"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_INFLUENCE, 30)
			_add_power(0, -50)
			context["result_text"] = tr(TXT_R1)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_316_japan_reconciliation.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_316",
	"num": 316,
	"priority": 31600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_316_japan_reconciliation.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
