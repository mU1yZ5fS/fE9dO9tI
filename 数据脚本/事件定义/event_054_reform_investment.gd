extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_054_reform_investment.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "reform_investment",
	"num": 54,
	"priority": 540,
	"trigger": [{"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "reform_and_openness"}, {"t": "RESOURCE_AT_LEAST", "key": "econ_system", "v": 12}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "political_line", "v": 2}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}],
}
