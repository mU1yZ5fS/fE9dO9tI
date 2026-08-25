extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_094_taiwan_pressure_path.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "event_094",
	"num": 94,
	"priority": 9400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd",
	"trigger": [{"t": "RESOURCE_AT_LEAST", "key": "reform_momentum", "v": 90}, {"t": "DATE_AFTER", "key": "1983.1"}, {"t": "NOT", "c": [{"t": "PREV_EVENT_RESULT_IS", "ref": "event_444"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}],
}
