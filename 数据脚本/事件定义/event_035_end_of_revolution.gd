extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_035_end_of_revolution.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_033_041_world_and_party.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "end_of_revolution",
	"num": 35,
	"priority": 3500,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.5"}, {"t": "MODIFIER_INACTIVE", "key": "3"}, {"t": "RESOURCE_NOT_EQUALS", "key": "budget", "v": 2}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_NOT_EQUALS", "key": "political_line"}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}],
}
