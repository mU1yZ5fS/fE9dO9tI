extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_056_teach_vietnam_lesson.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "teach_vietnam_lesson",
	"num": 56,
	"priority": 560,
	"trigger": [{"t": "DATE_AFTER", "key": "1979.2"}, {"t": "NOT_HAS_FLAG", "key": "vietnampeace"}, {"t": "WAR_ACTIVE", "v": 1}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "1"}]}, {"t": "RESOURCE_EQUALS", "key": "war_state"}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}],
}
