extends "res://数据脚本/event_script_base.gd"

## 占位：原版逆向中 Event691.cs 缺失，仅 DiploButtonScript 1073 会触发 number_event=691。
## 这里先提供可运行的数据入口；后续拿到原版 Event691 完整演出后可替换。

const TXT_R0 := "event.script.event_691_trotsky.c0"
const TXT_R1 := "event.script.event_691_trotsky.c1"
const TXT_R2 := "event.script.event_691_trotsky.c2"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)
		_:
			context["result_text"] = tr(TXT_R0)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_691_trotsky.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_691",
	"num": 691,
	"priority": 69100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_691_trotsky.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
