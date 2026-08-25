extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_036_iraqi_coalition.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_033_041_world_and_party.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "iraqi_coalition",
	"num": 36,
	"priority": 3600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.7"}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "RESOURCE_NOT_EQUALS", "key": "political_line", "v": 4}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_NOT_EQUALS", "key": "political_line"}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}, {"t": "RESOURCE_AT_LEAST", "key": "influence", "v": 50}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}],
}
