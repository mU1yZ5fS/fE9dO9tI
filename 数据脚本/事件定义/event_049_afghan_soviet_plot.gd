extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_049_afghan_soviet_plot.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_048_052_063_afghanistan.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "afghan_soviet_plot",
	"num": 49,
	"priority": 490,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.1"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "target": "12"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 70}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}],
}
