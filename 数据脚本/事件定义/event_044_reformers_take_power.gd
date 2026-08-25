extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_044_reformers_take_power.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "reformers_take_power",
	"num": 44,
	"priority": 440,
	"display_script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd",
	"trigger": [{"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1978}, {"t": "RESOURCE_EQUALS", "key": "reform_stage"}, {"t": "POLITICIAN_POWER_DIFFERENCE_AT_LEAST", "key": "2", "target": "0"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}, {"disabled": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 150}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_NOT_EQUALS", "key": "post_mao_course", "v": 1}, {"t": "RESOURCE_NOT_EQUALS", "key": "post_mao_course", "v": 2}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}],
}
