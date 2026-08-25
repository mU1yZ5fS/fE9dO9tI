extends "res://数据脚本/event_script_base.gd"

## 原作 Event88.cs：那是怎样的时光啊（罗得西亚内部解决方案，三选项）。
## 触发：TimeScript.cs:10717-10723 ——
##   (日>=10 且 月>=3 且 年>=1978 或 月>=4 且 年>=1978 或 年>=1979)。
## 差异：选项显隐 prepare 动态改写；<color> 标签去除（UI 未开 bbcode）。

const TXT_R0 := "event.script.event_088_rhodesia.c0"

const TXT_R1 := "event.script.event_088_rhodesia.c1"

const TXT_R2 := "event.script.event_088_rhodesia.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var left_party := party < 8
	var opt := event_def.options
	if (line < 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[0], "继续支持他们的武装斗争")
	else:
		_disable(opt[0], "他们？他们连保险都不会开！")
	if (line >= 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[1], "和新政府做朋友")
	else:
		_disable(opt[1], "你看不出他们是在演戏？")
	_enable(opt[2], "什么都不做")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var rhodesia := ws.get_country_by_legacy_index(127)
	if rhodesia != null:
		rhodesia.name = "津巴布韦罗得西亚"
		rhodesia.chinese_name = "津巴布韦罗得西亚"
		rhodesia.puppet_of = GameConstants.LegacySlot.NONE
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			context["result_text"] = tr(TXT_R0)
		1:
			if rhodesia != null:
				rhodesia.set_tag("对华贸易", true)
			ws.influence_prc -= 40
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_088_rhodesia.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_088",
	"num": 88,
	"priority": 880,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_088_rhodesia.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.3.10"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
