extends "res://数据脚本/event_script_base.gd"

## 原作 Event1999.cs：测试事件（6 选项，各把中国 SubGosstroy 设为 0-5）。
## 触发：全目录 grep 无任何自动触发点，原版无自动条件（测试事件，手动触发），
##   故 trigger_conditions=[]。

const TXT_OPT := "event.script.event_1999_test.c0"
const TXT_R := "event.script.event_1999_test.c1"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	context["result_text"] = tr(TXT_R)
	if china != null and opt >= 0 and opt <= 5:
		china.sub_government = opt



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_1999_test.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_1999",
	"num": 1999,
	"priority": 199900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_1999_test.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
