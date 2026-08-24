extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_055_burmese_socialism.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "burmese_socialism",
	"num": 55,
	"priority": 550,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.8.10"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 10, "target": "33"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_663"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 40}, {"t": "COUNTRY_FIELD_EQUALS", "key": "stab", "v": 1, "target": "33"}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}],
}
