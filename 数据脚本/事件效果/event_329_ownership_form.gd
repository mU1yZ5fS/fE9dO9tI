extends "res://数据脚本/event_script_base.gd"

## 原作 Event329.cs：所有权形式问题（3选项）。
## 触发：全目录搜索无 this_num_event = 329 / Reset(329) / StartEvent(329)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 258-265。

const TXT_R0 := "event.script.event_329_ownership_form.c0"
const TXT_R1 := "event.script.event_329_ownership_form.c1"
const TXT_R2 := "event.script.event_329_ownership_form.c2"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PEOPLE_SUPPORT, 70)
			_add(W.I_BUDGET, 150)
			_add(W.I_INDUSTRY, 70)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_PEOPLE_SUPPORT, -30)
			_add(W.I_THOUGHT_FREEDOM, 150)
			context["result_text"] = tr(TXT_R2)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_329_ownership_form.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_329",
	"num": 329,
	"priority": 32900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_329_ownership_form.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
