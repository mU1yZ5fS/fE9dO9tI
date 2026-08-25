extends EventScriptBase

## 自动迁移自 场景/事件界面/events/event_sino_soviet_split_eastern_europe.tres
## 文案见 资产/本地化/events_zh_CN.csv

const META := {
	"id": "sino_soviet_split_eastern_europe",
	"options": [{"result": true, "fx": [{"t": "SET_RESOURCE", "key": "war_state"}, {"t": "SET_RESOURCE", "key": "war_pressure", "v": 5}, {"t": "JOIN_ALLIANCE", "key": "ovd", "target": "KOR"}, {"t": "JOIN_ALLIANCE", "key": "sev", "target": "KOR"}]}, {"disabled": true, "result": true, "cond": {"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST"}]}, "fx": [{"t": "ADD_EMPIRE_RELATION", "key": "1", "v": -200}, {"t": "SET_RESOURCE", "key": "war_state"}, {"t": "SET_RESOURCE", "key": "war_pressure", "v": 1000}, {"t": "JOIN_ALLIANCE", "key": "sev", "target": "KOR"}]}],
}
