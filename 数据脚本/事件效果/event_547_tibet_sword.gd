extends "res://数据脚本/event_script_base.gd"

## 原作 Event547.cs：高原上巍峨利剑（西藏革命，1选项）。
## 触发：无自动触发（GlobalScript.cs:22 决议 StartEvent(547)）。

const TXT_R0 := "event.script.event_547_tibet_sword.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if int(context.get("option_index", -1)) == 0:
		_add(W.I_PARTY_SUPPORT, 100)
		_add(W.I_PEOPLE_SUPPORT, 100)
		context["result_text"] = tr(TXT_R0)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_547_tibet_sword.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_547",
	"num": 547,
	"priority": 54700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_547_tibet_sword.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
