extends "res://数据脚本/event_script_base.gd"

## 原作 Event1000.cs：开张圣听（民主化后的舆论来信展示事件，纯文案）。
## 触发：TimeScript.cs:10027-10032 —— data.party_system >= 8 且 !event_done[1000]
## （fire_only_once 由 EventDef 统一负责）。
## 差异记录：
##  - 原版 result 0/1/2 三个选项均无效果、同一结果文案；原样保留三分支。
##  - result 3/4/5 为不可达“测试”分支（kolvo_variant=3），跳过。
##  - <color> 标签去除（UI 未开 bbcode）；字符间空格排版不保留；show_notification=false。

const TXT_RESULT := "显然，改革永远在路上。建设现代国家的事业，仍任重而道远……"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	# Event1000.cs result 0/1/2：无任何数值效果
	if opt == 0 or opt == 1 or opt == 2:
		context["result_text"] = TXT_RESULT
