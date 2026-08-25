extends "res://数据脚本/event_script_base.gd"

## 原作 Event314.cs：被击落的韩国波音（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:514-517 —— 日>=1 月>=9 年>=1983 且 苏联(7)非北约 且 朝鲜(10)!parts[0] 且 战争90未进行。
## 差异：isNATO→has_tag("nato")，parts 字段映射 CountryData.parts；文本来自 Events_text_en 索引 126-133。

const TXT_R0 := "event.script.event_314_korean_boeing_shot_down.c0"
const TXT_R1 := "event.script.event_314_korean_boeing_shot_down.c1"
const TXT_R2 := "event.script.event_314_korean_boeing_shot_down.c2"

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var data := world
	if data.size() <= W.I_YEAR:
		return false
	var date_ok := data.day >= 1 and data.month >= 9 and data.year >= 1983
	var ussr := world.get_country_by_legacy_index(7)
	var north_korea := world.get_country_by_legacy_index(10)
	var nato_ok := ussr == null or not ussr.has_tag("nato")
	var parts_ok := north_korea == null or north_korea.parts.size() == 0 or not north_korea.parts[0]
	var war_ok := world.wars.size() <= 90 or world.wars[90] == null or not world.wars[90].is_going
	return date_ok and nato_ok and parts_ok and war_ok

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add_relation(1, -150)
			_add_relation(0, 100)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_relation(1, 100)
			_add_relation(0, -150)
			context["result_text"] = tr(TXT_R2)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_314_korean_boeing_shot_down.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_314",
	"num": 314,
	"priority": 31400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_314_korean_boeing_shot_down.gd",
	"trigger_script": "res://数据脚本/事件效果/event_314_korean_boeing_shot_down.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
