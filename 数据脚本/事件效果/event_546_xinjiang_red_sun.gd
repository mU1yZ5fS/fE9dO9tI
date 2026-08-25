extends "res://数据脚本/event_script_base.gd"

## 原作 Event546.cs：塞上赤日耀玉关（新疆革命，1选项）。
## 触发：无自动触发（GlobalScript.cs:24 决议 StartEvent(546)）。

const TXT_R0 := "event.script.event_546_xinjiang_red_sun.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if int(context.get("option_index", -1)) == 0:
		_add(W.I_PARTY_SUPPORT, 100)
		_add(W.I_PEOPLE_SUPPORT, 100)
		context["result_text"] = tr(TXT_R0)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_546_xinjiang_red_sun.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_546",
	"num": 546,
	"priority": 54600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_546_xinjiang_red_sun.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
