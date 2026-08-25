extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_064_pan_arabism.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_064_066_international.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "pan_arabism",
	"num": 64,
	"priority": 640,
	"display_script": "res://数据脚本/事件效果/event_064_066_international.gd",
	"trigger": [{"t": "ANY", "c": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1980.8"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 2, "target": "30"}, {"t": "PREV_EVENT_DONE", "ref": "event_707"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "asean", "target": "1"}]}]}, {"t": "ALL", "c": [{"t": "SOCIALIST_COUNT_AT_LEAST", "v": 4, "keys": ["30", "14", "35", "13"]}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_064_066_international.gd"}]}, {"disabled": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_064_066_international.gd"}]}],
}
