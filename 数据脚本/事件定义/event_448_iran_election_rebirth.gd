extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_448_iran_election_rebirth.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_446_449_iran_chain.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "event_448",
	"num": 448,
	"priority": 44800,
	"notify": false,
	"options": [{"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 300}, {"t": "RESOURCE_AT_MOST", "key": "iran_islamist_support", "v": 300}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_LEAST", "key": "influence_prc", "v": 200}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_446_449_iran_chain.gd"}]}],
}
