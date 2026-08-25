extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_032_mongolia_reform.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_027_032_diplomacy.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "mongolia_reform",
	"num": 32,
	"priority": 3200,
	"notify": false,
	"options": [{"disabled": true, "result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 40}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}],
}
