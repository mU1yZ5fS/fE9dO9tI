extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_024_post_mao_course.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_024_026_political_transition.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "post_mao_course",
	"num": 24,
	"priority": 2400,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1976.12"}, {"t": "RESOURCE_NOT_EQUALS", "key": "gang_of_four_path", "v": 3}]}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_EQUALS", "key": "gang_of_four_path", "v": 3}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}, {"result": true, "cond": {"t": "RESOURCE_NOT_EQUALS", "key": "gang_of_four_path", "v": 3}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}, {"result": true, "cond": {"t": "RESOURCE_NOT_EQUALS", "key": "gang_of_four_path", "v": 3}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}],
}
