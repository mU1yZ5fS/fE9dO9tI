extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_025_gang_of_four.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_024_026_political_transition.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "gang_of_four",
	"num": 25,
	"priority": 2500,
	"trigger": [{"t": "DATE_AFTER", "key": "1976.10"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_024_026_political_transition.gd"}]}],
}
