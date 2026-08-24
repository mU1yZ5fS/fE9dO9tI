extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_033_pakistan_coup.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_033_041_world_and_party.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "pakistan_coup",
	"num": 33,
	"priority": 3300,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.7"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 60}, {"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "budget", "v": 30}, {"t": "RESOURCE_AT_LEAST", "key": "reserve", "v": 30}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}],
}
