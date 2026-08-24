extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_031_south_korea_election.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_027_032_diplomacy.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "south_korea_election",
	"num": 31,
	"priority": 3100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd",
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_SUM_AT_LEAST", "v": 50, "keys": ["budget", "reserve"]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_SUM_AT_LEAST", "v": 30, "keys": ["budget", "reserve"]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_SUM_AT_LEAST", "v": 30, "keys": ["budget", "reserve"]}, {"t": "RESOURCE_NOT_EQUALS", "key": "political_line"}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_SUM_AT_LEAST", "v": 80, "keys": ["budget", "reserve"]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}],
}
