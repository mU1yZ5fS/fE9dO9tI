extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_713_revolutionary_international.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_713_revolutionary_international.gd
##   res://数据脚本/事件效果/event_713_trigger.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "event_713",
	"nodesc": true,
	"num": 713,
	"priority": 7130,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_713_revolutionary_international.gd",
	"trigger_script": "res://数据脚本/事件效果/event_713_trigger.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_713_revolutionary_international.gd"}]}, {"cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 1000}, {"t": "RESOURCE_AT_LEAST", "key": "diplo", "v": 901}, {"t": "RESOURCE_SUM_AT_LEAST", "v": 1000, "keys": ["budget", "money_reserve"]}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 1000}, {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 1000}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_540"}, {"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_545"}, {"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_521"}, {"t": "NOT", "c": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_503"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_503"}]}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_713_revolutionary_international.gd"}]}],
}
