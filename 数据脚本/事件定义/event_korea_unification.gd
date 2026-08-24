extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_korea_unification.tres
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "korea_unification",
	"options": [{"result": true, "fx": [{"t": "SET_COUNTRY_VAR", "key": "special_ending", "target": "KOR"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 250}, {"t": "RESOURCE_AT_LEAST", "key": "money", "v": 250}]}, "fx": [{"t": "ADD_RESOURCE", "key": "agents", "v": -250}, {"t": "ADD_RESOURCE", "key": "money", "v": -250}, {"t": "ADD_RESOURCE", "key": "political", "v": 5}, {"t": "SET_COUNTRY_VAR", "key": "special_ending", "v": 1, "target": "KOR"}, {"t": "JOIN_ALL_ALLIANCES", "target": "KOR"}]}, {"result": true, "fx": [{"t": "ADD_RESOURCE", "key": "diplo", "v": 50}, {"t": "SET_COUNTRY_VAR", "key": "special_ending", "v": 2, "target": "KOR"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "agents", "v": 50}, {"t": "MODIFIER_INACTIVE", "key": "6"}, {"t": "MODIFIER_INACTIVE", "key": "3"}]}, "fx": [{"t": "ADD_RESOURCE", "key": "diplo", "v": -50}, {"t": "ADD_RESOURCE", "key": "agents", "v": -50}, {"t": "SET_COUNTRY_VAR", "key": "special_ending", "v": 3, "target": "KOR"}, {"t": "JOIN_ECONOMIC_ALLIANCE", "target": "KOR"}]}],
}
