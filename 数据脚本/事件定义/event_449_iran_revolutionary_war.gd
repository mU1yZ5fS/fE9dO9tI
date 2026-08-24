extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_449_iran_revolutionary_war.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_446_449_iran_chain.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "event_449",
	"num": 449,
	"priority": 66,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd",
	"trigger": [{"t": "PREV_EVENT_DONE", "ref": "event_447"}, {"t": "PREV_EVENT_NOT_DONE", "ref": "event_448"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 20, "target": "8"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1981.6.20"}, {"t": "DATE_AFTER", "key": "1981.7.1"}, {"t": "DATE_AFTER", "key": "1982.1"}]}],
	"options": [{"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}],
}
