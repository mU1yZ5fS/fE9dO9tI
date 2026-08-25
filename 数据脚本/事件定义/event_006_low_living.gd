extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_006_low_living.tres
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "low_living_standard",
	"num": 6,
	"once": false,
	"trigger": [{"t": "RESOURCE_AT_MOST", "key": "living", "v": 100}],
	"options": [{"result": true, "fx": [{"t": "ADD_RESOURCE", "key": "people_support", "v": 50}, {"t": "ADD_RESOURCE", "key": "money", "v": -100}, {"t": "SET_RESOURCE", "key": "living", "v": 300}]}, {"disabled": true, "result": true, "cond": {"t": "ANY", "c": [{"t": "EMPIRE_RELATION_AT_LEAST", "key": "0", "v": 500}, {"t": "EMPIRE_RELATION_AT_LEAST", "key": "1", "v": 500}]}, "fx": [{"t": "ADD_RESOURCE", "key": "thought_freedom", "v": 200}, {"t": "ADD_RESOURCE", "key": "influence", "v": -100}, {"t": "SET_RESOURCE", "key": "living", "v": 300}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "development", "v": 13}, "fx": [{"t": "ADD_RESOURCE", "key": "thought_freedom", "v": 100}, {"t": "ADD_RESOURCE", "key": "party_support", "v": -500}, {"t": "SET_RESOURCE", "key": "living", "v": 300}, {"t": "ADD_POLITICIAN_LOYALTY_BY_PERSONALITY", "key": "2,3", "v": -100}]}, {"disabled": true, "result": true, "cond": {"t": "RESOURCE_AT_LEAST", "key": "party_support", "v": 500}, "fx": [{"t": "SET_RESOURCE", "key": "party_support"}, {"t": "ADD_RESOURCE", "key": "people_support", "v": 100}, {"t": "SET_RESOURCE", "key": "living", "v": 300}, {"t": "ADD_ALL_POLITICIAN_LOYALTY", "v": -300}]}],
}
