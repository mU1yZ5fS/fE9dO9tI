extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_012_agriculture_decline.tres
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "agriculture_decline",
	"num": 12,
	"notify": false,
	"once": false,
	"trigger": [{"t": "RESOURCE_AT_MOST", "key": "agriculture"}],
	"options": [{"result": true, "fx": [{"t": "ADD_RESOURCE", "key": "agriculture", "v": 100}, {"t": "ADD_RESOURCE", "key": "money", "v": -100}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "EMPIRE_RELATION_AT_LEAST", "key": "0", "v": 60}, {"t": "ANY", "c": [{"t": "RESOURCE_AT_LEAST", "key": "economy_system", "v": 13}, {"t": "HAS_FLAG", "key": "sez"}]}]}, "fx": [{"t": "ADD_RESOURCE", "key": "agriculture", "v": 100}, {"t": "ADD_RESOURCE", "key": "living", "v": -50}, {"t": "ADD_RESOURCE", "key": "thought_freedom", "v": -50}, {"t": "ADD_EMPIRE_RELATION", "key": "0", "v": -50}]}, {"disabled": true, "result": true, "cond": {"t": "ANY", "c": [{"t": "EMPIRE_RELATION_AT_LEAST", "key": "1", "v": 70}, {"t": "HAS_FLAG", "key": "relres"}]}, "fx": [{"t": "ADD_RESOURCE", "key": "agriculture", "v": 100}, {"t": "ADD_EMPIRE_POWER", "key": "1", "v": 10}, {"t": "ADD_EMPIRE_RELATION", "key": "1", "v": -50}, {"t": "ADD_EMPIRE_RELATION", "key": "0", "v": -100}, {"t": "ADD_POLITICIAN_LOYALTY_BY_PERSONALITY", "key": "3,2", "v": -100}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "industry", "v": 500}, "fx": [{"t": "ADD_RESOURCE", "key": "agriculture", "v": 100}, {"t": "ADD_RESOURCE", "key": "industry", "v": -100}]}],
}
