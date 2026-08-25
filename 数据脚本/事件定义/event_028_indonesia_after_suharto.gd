extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_028_indonesia_after_suharto.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_027_032_diplomacy.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "indonesia_after_suharto",
	"num": 28,
	"priority": 2800,
	"notify": false,
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 3}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 3}, {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 1}, {"t": "ANY", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "government", "v": 1, "target": "49"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "target": "49"}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_027_032_diplomacy.gd"}]}],
}
