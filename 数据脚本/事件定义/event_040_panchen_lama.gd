extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_040_panchen_lama.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_033_041_world_and_party.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "panchen_lama",
	"num": 40,
	"priority": 4000,
	"trigger": [{"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1978}, {"t": "ALL", "c": [{"t": "RESOURCE_EQUALS", "key": "year", "v": 1977}, {"t": "RESOURCE_AT_LEAST", "key": "month", "v": 10}, {"t": "RESOURCE_AT_LEAST", "key": "day", "v": 22}]}]}, {"t": "RESOURCE_NOT_EQUALS", "key": "religion_policy", "v": 27}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 40}, {"t": "RESOURCE_NOT_EQUALS", "key": "political_line"}, {"t": "RESOURCE_NOT_EQUALS", "key": "political_line", "v": 4}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 70}, {"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "budget", "v": 40}, {"t": "RESOURCE_AT_LEAST", "key": "reserve", "v": 40}]}, {"t": "RESOURCE_NOT_EQUALS", "key": "political_line", "v": 4}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}],
}
