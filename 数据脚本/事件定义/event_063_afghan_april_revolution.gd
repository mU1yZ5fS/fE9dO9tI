extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_063_afghan_april_revolution.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_048_052_063_afghanistan.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "afghan_april_revolution",
	"num": 63,
	"priority": 475,
	"trigger": [{"t": "DATE_AFTER", "key": "1978.5"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 30}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 60}, {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 1}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}],
}
