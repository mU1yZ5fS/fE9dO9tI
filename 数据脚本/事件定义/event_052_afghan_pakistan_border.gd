extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_052_afghan_pakistan_border.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_048_052_063_afghanistan.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "afghan_pakistan_border",
	"num": 52,
	"priority": 520,
	"trigger": [{"t": "DATE_AFTER", "key": "1980.1"}, {"t": "WAR_ACTIVE", "v": 5}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "31"}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "WAR_FIELD_EQUALS", "key": "ussr_side", "v": 1, "target": "5"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "1"}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "WAR_FIELD_EQUALS", "key": "ussr_side", "v": 1, "target": "5"}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_048_052_063_afghanistan.gd"}]}],
}
