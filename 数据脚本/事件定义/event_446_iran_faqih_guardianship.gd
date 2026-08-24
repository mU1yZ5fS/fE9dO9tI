extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_446_iran_faqih_guardianship.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_446_449_iran_chain.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "event_446",
	"num": 446,
	"priority": 64,
	"notify": false,
	"trigger": [{"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 8, "target": "8"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1979.12.11"}, {"t": "DATE_AFTER", "key": "1980.1"}]}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 150}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 200}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "political_line"}, {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 100}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}],
}
