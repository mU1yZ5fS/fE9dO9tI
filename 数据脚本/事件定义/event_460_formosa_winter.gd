extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_460_formosa_winter.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_460_461_formosa.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "formosa_winter",
	"num": 460,
	"priority": 71,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_460_461_formosa.gd",
	"trigger": [{"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1979.12.10"}, {"t": "DATE_AFTER", "key": "1980.1"}]}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}, {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 100}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_460_461_formosa.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_460_461_formosa.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_460_461_formosa.gd"}]}],
}
