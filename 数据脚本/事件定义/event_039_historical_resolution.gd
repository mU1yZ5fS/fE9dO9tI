extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_039_historical_resolution.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_033_041_world_and_party.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "historical_resolution",
	"num": 39,
	"priority": 3900,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.3"}, {"t": "RESOURCE_NOT_EQUALS", "key": "post_mao_course", "v": 2}, {"t": "MODIFIER_INACTIVE", "key": "3"}],
	"options": [{"disabled": true, "result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}],
}
