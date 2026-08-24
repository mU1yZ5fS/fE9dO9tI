extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_029_pressure_north_korea.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_027_032_diplomacy.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "pressure_north_korea",
	"num": 29,
	"priority": 2900,
	"notify": false,
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "economy_system", "v": 13}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}],
}
