extends "res://数据脚本/event_script_base.gd"

## 原作 Event676.cs：再见，老总（朱德逝世，单选项）。
## 触发：TimeScript.cs:10052-10057 —— (日>=6 且 月>=7 且 年>=1976) 或 月>=8。
## 效果：data.army（军力）+89。
## 差异：字符间空格排版不保留；show_notification=false（项目约定）。

const TXT_RESULT := "event.script.event_676_zhu_de_funeral.c0"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		# Event676.cs result 0
		if d.size() > W.I_ARMY:
			d.army += 89
		context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_676_zhu_de_funeral.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_676",
	"num": 676,
	"priority": 6760,
	"notify": false,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.7.6"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
