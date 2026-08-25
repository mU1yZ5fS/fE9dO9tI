extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_069_little_gang_of_four.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "little_gang_of_four",
	"num": 69,
	"priority": 690,
	"display_script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1980.2"}, {"t": "RESOURCE_AT_LEAST", "key": "reform_stage", "v": 1}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}, {"disabled": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}, {"disabled": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}],
}
