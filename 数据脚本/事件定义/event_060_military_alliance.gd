extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_060_military_alliance.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "military_alliance",
	"num": 60,
	"priority": 600,
	"trigger": [{"t": "DATE_AFTER", "key": "1979.6"}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "1"}],
	"options": [{"disabled": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "army", "v": 300}, {"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 100}, {"t": "RESOURCE_SUM_AT_LEAST", "v": 50, "keys": ["budget", "reserve"]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "1"}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}],
}
