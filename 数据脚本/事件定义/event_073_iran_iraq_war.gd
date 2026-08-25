extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_073_iran_iraq_war.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "iran_iraq_war",
	"num": 73,
	"priority": 730,
	"trigger": [{"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "day", "v": 15}, {"t": "RESOURCE_AT_LEAST", "key": "month", "v": 9}, {"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1980}]}, {"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1981}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "8"}]}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "8"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd"}]}],
}
