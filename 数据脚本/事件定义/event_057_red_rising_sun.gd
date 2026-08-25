extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_057_red_rising_sun.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "red_rising_sun",
	"num": 57,
	"priority": 5700,
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 60}, {"t": "COUNTRY_FIELD_EQUALS", "key": "stab", "v": 1, "target": "44"}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}],
}
