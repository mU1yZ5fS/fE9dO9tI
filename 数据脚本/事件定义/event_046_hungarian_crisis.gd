extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_046_hungarian_crisis.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "hungarian_crisis",
	"num": 46,
	"priority": 460,
	"trigger": [{"t": "DATE_AFTER", "key": "1977.11"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 80}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 30}, {"t": "RESOURCE_AT_LEAST", "key": "army", "v": 10}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 1}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, {"t": "RESOURCE_AT_MOST", "key": "party_system", "v": 7}]}, {"t": "ALL", "c": [{"t": "COALITION_SUPPORT_AT_LEAST", "v": 67}, {"t": "RESOURCE_AT_LEAST", "key": "party_system", "v": 8}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_042_047_revolution_and_reform.gd"}]}],
}
