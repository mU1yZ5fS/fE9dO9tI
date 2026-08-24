extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_447_save_iran_uprising.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_446_449_iran_chain.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "event_447",
	"num": 447,
	"priority": 65,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_446"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1980.7.11"}, {"t": "DATE_AFTER", "key": "1980.8.1"}, {"t": "DATE_AFTER", "key": "1981.1"}]}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 300}, "fx": [{"t": "TRIGGER_EVENT", "key": "event_448", "if": {"t": "RESOURCE_AT_MOST", "key": "iran_islamist_support", "v": 300}}, {"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 200}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}],
}
