extends "res://数据脚本/event_script_base.gd"

## 原作 Event880.cs：兰开斯特宫协议（单选项）。
## 触发：TimeScript.cs:10724-10730 —— (月>=12 且 年>=1979 或 年>=1980)。
## 共同效果：c127.name="南罗得西亚"（先于 result 分支）。
## result1/result2 在 kolvo_variant=1 下不可达，按死代码跳过。

const TXT_RESULT := "event.script.event_880_lancaster_house.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var rhodesia := ws.get_country_by_legacy_index(127)
	if rhodesia != null:
		rhodesia.name = "南罗得西亚"
		rhodesia.chinese_name = "南罗得西亚"
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_880_lancaster_house.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_880",
	"num": 880,
	"priority": 8800,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1979.12.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
