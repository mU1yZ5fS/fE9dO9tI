extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_045_reform_and_openness.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "reform_and_openness",
	"num": 45,
	"priority": 450,
	"trigger": [{"t": "DATE_AFTER", "key": "1978.1"}, {"t": "RESOURCE_EQUALS", "key": "reform_stage", "v": 1}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}],
}
