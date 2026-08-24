extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_461_formosa_spring.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_460_461_formosa.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "formosa_spring",
	"num": 461,
	"priority": 46100,
	"notify": false,
	"options": [{"disabled": true, "result": true, "cond": {"t": "PREV_EVENT_RESULT_IS", "ref": "formosa_winter"}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_460_461_formosa.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_460_461_formosa.gd"}]}],
}
