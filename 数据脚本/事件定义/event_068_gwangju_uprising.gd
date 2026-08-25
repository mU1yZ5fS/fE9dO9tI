extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_068_gwangju_uprising.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "gwangju_uprising",
	"num": 68,
	"priority": 680,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.5.18"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 80}, {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 80}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}],
}
