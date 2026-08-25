extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_071_naxalite_endgame.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "naxalite_endgame",
	"num": 71,
	"priority": 710,
	"trigger": [{"t": "RESOURCE_AT_LEAST", "key": "naxalite_power", "v": 500}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "global_influence", "v": 100}, {"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "19"}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "19"}]}, {"t": "RESOURCE_EQUALS", "key": "war_state"}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_071_073_india_and_iran_war.gd"}]}],
}
