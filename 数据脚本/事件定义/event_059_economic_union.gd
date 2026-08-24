extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_059_economic_union.tres
## 共享效果脚本（未合并进本文件）：
##   res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "economic_union",
	"num": 59,
	"priority": 590,
	"trigger": [{"t": "DATE_AFTER", "key": "1979.5"}, {"t": "ANY", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "23"}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "34"}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "20"}, {"t": "COUNTRY_HAS_TAG", "key": "亲中", "target": "31"}]}],
	"options": [{"result": true, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"disabled": true, "cond": {"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "cw", "v": 1, "target": "15"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "1"}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "HAS_FLAG", "key": "relres"}, {"t": "NOT", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "cw", "v": 1, "target": "15"}]}, {"t": "RESOURCE_AT_MOST", "key": "political_line", "v": 2}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "对华贸易", "target": "51"}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_EQUALS", "key": "war_state"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "okb", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "亲美", "target": "1"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_FIELD_EQUALS", "key": "cw", "v": 1, "target": "15"}]}]}, "fx": [{"t": "CUSTOM_SCRIPT", "script": "res://数据脚本/事件效果/event_053_062_reform_and_alliances.gd"}]}],
}
