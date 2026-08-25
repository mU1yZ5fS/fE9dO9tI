extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_116_two_chinas.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "event_116",
	"num": 116,
	"priority": 11650,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1985.1"}, {"t": "RESOURCE_EQUALS", "key": "afghan_war_path", "v": 1}, {"t": "PREV_EVENT_DONE", "ref": "event_095"}, {"t": "PREV_EVENT_DONE", "ref": "event_096"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "development", "target": "38"}, {"t": "RESOURCE_AT_MOST", "key": "taiwan_status"}, {"t": "NOT", "c": [{"t": "DECISION_DONE", "key": "6"}]}, {"t": "NOT", "c": [{"t": "DECISION_DONE", "key": "7"}]}, {"t": "PREV_EVENT_NOT_DONE", "ref": "formosa_spring"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "diplo", "v": 500}, {"t": "EMPIRE_RELATION_AT_LEAST", "key": "0", "v": 600}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}],
}
