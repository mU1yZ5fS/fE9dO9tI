extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_051_afghan_soviet_intervention.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_048_052_063_afghanistan.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "afghan_soviet_intervention",
	"num": 51,
	"priority": 510,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.1"}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "government", "target": "8"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "31"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "8"}]}, {"t": "ALL", "c": [{"t": "RESOURCE_DIFFERENCE_AT_MOST", "key": "afghan_khalq", "target": "afghan_parcham"}, {"t": "RESOURCE_DIFFERENCE_AT_MOST", "key": "afghan_parcham", "target": "afghan_khalq"}]}, {"t": "PREV_EVENT_NOT_DONE", "ref": "afghan_soviet_plot"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}],
}
