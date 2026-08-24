extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_048_afghan_amin_coup.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_048_052_063_afghanistan.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "afghan_amin_coup",
	"num": 48,
	"priority": 480,
	"trigger": [{"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1980}, {"t": "ALL", "c": [{"t": "RESOURCE_EQUALS", "key": "year", "v": 1979}, {"t": "RESOURCE_AT_LEAST", "key": "month", "v": 9}, {"t": "RESOURCE_AT_LEAST", "key": "day", "v": 16}]}]}, {"t": "NOT", "c": [{"t": "RESOURCE_DIFFERENCE_AT_MOST", "key": "afghan_khalq", "target": "afghan_parcham"}]}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"disabled": true, "cond": {"t": "HAS_FLAG", "key": "relres"}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}],
}
