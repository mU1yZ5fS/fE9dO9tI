extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_050_afghan_civil_war.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_048_052_063_afghanistan.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "afghan_civil_war",
	"num": 50,
	"priority": 500,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.1"}, {"t": "PREV_EVENT_DONE", "ref": "afghan_soviet_plot"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 1, "target": "12"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "HAS_FLAG", "key": "relres"}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}],
}
