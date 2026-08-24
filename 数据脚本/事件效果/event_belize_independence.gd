extends EventScriptBase

## 伯利兹独立（1981-09-21 起自动触发，Godot 增量事件，原版无对应 C# 事件）。
## 原版 142 号国家开局随英国（world_factory _copy_gs(142, 92) + puppet 92）；
## 本事件按史实让伯利兹独立：脱离英国傀儡、政体沿用英国式社会民主主义，
## 并把地图上英国（200）的伯利兹地块转给伯利兹（80）。

const TXT_RESULT := "event.script.event_belize_independence.c0"

const BELIZE_REGION_IDS: Array[int] = [1265, 1267, 1268, 1635, 2094, 2095]
const BELIZE_GWCODE := 80


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var belize := ws.get_country_by_legacy_index(142)
	if belize != null:
		belize.puppet_of = GameConstants.LegacySlot.NONE
		belize.government = GameConstants.Government.LIBERAL
		belize.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
		if GameManager != null:
			game.set_map_region_owner(BELIZE_REGION_IDS, BELIZE_GWCODE)
	context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_belize_independence.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "belize_independence",
	"num": 1602,
	"priority": 160200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_belize_independence.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1981.9.21"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "puppet_of", "v": 92, "target": "142"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
