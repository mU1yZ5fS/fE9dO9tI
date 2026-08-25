extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_043_vietnam_cmea.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "vietnam_cmea",
	"num": 43,
	"priority": 430,
	"display_script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.11"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 30}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 1, "target": "23"}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}],
}
