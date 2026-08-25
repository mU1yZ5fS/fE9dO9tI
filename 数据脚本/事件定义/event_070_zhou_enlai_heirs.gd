extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_070_zhou_enlai_heirs.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "zhou_enlai_heirs",
	"num": 70,
	"priority": 700,
	"display_script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1980.2"}, {"t": "RESOURCE_EQUALS", "key": "reform_stage"}, {"t": "MODIFIER_ACTIVE", "key": "14"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}, {"disabled": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}, {"disabled": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_067_070_crises_and_plenums.gd"}]}],
}
