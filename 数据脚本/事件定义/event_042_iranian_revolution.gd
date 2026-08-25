extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_042_iranian_revolution.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "iranian_revolution",
	"num": 42,
	"priority": 420,
	"display_script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd",
	"trigger": [{"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "year", "v": 1979}, {"t": "ALL", "c": [{"t": "RESOURCE_EQUALS", "key": "year", "v": 1978}, {"t": "RESOURCE_AT_LEAST", "key": "month", "v": 1}, {"t": "RESOURCE_AT_LEAST", "key": "day", "v": 8}]}]}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}, {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}],
}
