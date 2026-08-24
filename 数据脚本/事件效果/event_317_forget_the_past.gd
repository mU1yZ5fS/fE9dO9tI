extends "res://数据脚本/event_script_base.gd"

## 原作 Event317.cs：忘却过去？（2选项）。
## 触发：全目录搜索无 this_num_event = 317 / Reset(317) / StartEvent(317)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 146-151。

const TXT_R0 := "event.script.event_317_forget_the_past.c0"
const TXT_R1 := "event.script.event_317_forget_the_past.c1"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PEOPLE_SUPPORT, -50)
			_add(W.I_DIPLO, -50)
			_add(W.I_MANPOWER, -50)
			_add_power(0, -30)
			context["result_text"] = tr(TXT_R1)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_317_forget_the_past.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_317",
	"num": 317,
	"priority": 31700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_317_forget_the_past.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
