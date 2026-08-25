extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_038_back_to_roots.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_033_041_world_and_party.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "back_to_roots",
	"num": 38,
	"priority": 3800,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.4"}, {"t": "RESOURCE_NOT_EQUALS", "key": "economy_system", "v": 10}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "ANY", "c": [{"t": "RESOURCE_NOT_EQUALS", "key": "post_mao_course", "v": 4}, {"t": "ANY", "c": [{"t": "RESOURCE_EQUALS", "key": "gang_of_four_path", "v": 3}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_NOT_EQUALS", "key": "post_mao_course", "v": 4}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_NOT_EQUALS", "key": "gang_of_four_path", "v": 3}, {"t": "RESOURCE_NOT_EQUALS", "key": "post_mao_course", "v": 2}, {"t": "RESOURCE_NOT_EQUALS", "key": "post_mao_course", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_033_041_world_and_party.gd"}]}],
}
