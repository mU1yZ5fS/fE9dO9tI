extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_096_taiwan_pressure_step_2.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "event_096",
	"num": 96,
	"priority": 9600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd",
	"trigger": [{"t": "RESOURCE_EQUALS", "key": "afghan_war_path", "v": 1}, {"t": "PREV_EVENT_DONE", "ref": "event_095"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}, {"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_094_096_116_taiwan_chain.gd"}]}],
}
