extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_026_weak_alliance.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_024_026_political_transition.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "weak_alliance",
	"num": 26,
	"priority": 2600,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.11"}, {"t": "RESOURCE_EQUALS", "key": "gang_of_four_path", "v": 3}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 70}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}],
}
