extends EventScriptBase

## 所罗门群岛独立（1978-07-07 起自动触发，Godot 增量事件，原版无对应 C# 事件）。
## 原版 161 号国家开局随英国（world_factory _copy_gs(161, 92) + puppet 92）；
## 本事件按史实让所罗门独立：脱离英国傀儡、政体沿用英国式社会民主主义，
## 并把地图上英国（200）的所罗门地块转给所罗门群岛（940）。

const TXT_RESULT := "event.script.event_solomon_independence.c0"

const SOLOMON_REGION_IDS: Array[int] = [
	2946, 2948, 2949, 2950, 2951, 2952, 2953, 2955, 2957, 3060,
]
const SOLOMON_GWCODE := 940


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var solomon := ws.get_country_by_legacy_index(161)
	if solomon != null:
		_leave_alliances(solomon)
		solomon.government = GameConstants.Government.LIBERAL
		solomon.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
		if GameManager != null:
			game.set_map_region_owner(SOLOMON_REGION_IDS, SOLOMON_GWCODE)
	context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_solomon_independence.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "solomon_independence",
	"num": 1601,
	"priority": 160100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_solomon_independence.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1978.7.7"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 92, "target": "161"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
