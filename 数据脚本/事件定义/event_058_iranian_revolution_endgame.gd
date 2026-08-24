extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_058_iranian_revolution_endgame.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "iranian_revolution_endgame",
	"num": 58,
	"priority": 580,
	"trigger": [{"t": "DATE_AFTER", "key": "1979.2"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}],
}
