extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_072_janata_crisis.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "janata_crisis",
	"num": 72,
	"priority": 720,
	"trigger": [{"t": "DATE_AFTER", "key": "1979.7"}, {"t": "RESOURCE_AT_LEAST", "key": "india_election", "v": 1}, {"t": "RESOURCE_AT_MOST", "key": "india_election", "v": 2}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd"}]}, {"disabled": true, "cond": {"t": "RESOURCE_EQUALS", "key": "india_election", "v": 1}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd"}]}, {"disabled": true, "cond": {"t": "RESOURCE_EQUALS", "key": "india_election", "v": 1}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd"}]}],
}
