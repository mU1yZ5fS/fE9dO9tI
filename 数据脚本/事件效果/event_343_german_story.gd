extends "res://数据脚本/event_script_base.gd"

## 原作 Event343.cs：德国结局（EndingsSecond，德国——民主德国的故事）。
## 原版无自动条件（结局系统手动触发）：trigger_conditions=[]。
## 差异：
##  - 原版 TextOfEnding 依据 is_gkchp / 两德政府形态 / 国家发展度 / parts[0] / 标签与阵营动态选择结局文本；
##    这里在 prepare 中复刻同一分支链并写回 event_def.description（空选项事件 UI 直接展示描述）。
##  - is_gkchp 端口建模说明 → 用 global_flags 同名键近似（项目既有约定）。
##  - 原版 GameObject.Find("Ach(Clone)") 是死代码，移植说明。


# 原版 GameObject.Find("Ach(Clone)") 死代码字符串（仅保留原文供溯源）：
# Ach(Clone)

const TXT_GKCHP := "event.script.event_343_german_story.c0"
const TXT_GKCHP_APPEND := "event.script.event_343_german_story.c1"
const TXT_VIETNAM := "event.script.event_343_german_story.c2"
const TXT_ROMANIA := "event.script.event_343_german_story.c3"
const TXT_DRAGON := "event.script.event_343_german_story.c4"
const TXT_RUINS := "event.script.event_343_german_story.c5"
const TXT_DRAGON_G1 := "event.script.event_343_german_story.c6"
const TXT_RUINS_G1 := "event.script.event_343_german_story.c7"
const TXT_AUTOCRAT := "event.script.event_343_german_story.c8"
const TXT_STABILITY := "event.script.event_343_german_story.c9"
const TXT_DEMOCRACY := "event.script.event_343_german_story.c10"
const TXT_OPPORTUNIST := "event.script.event_343_german_story.c11"
const TXT_WE_STILL_HERE := "event.script.event_343_german_story.c12"
const TXT_PROLETARIAT := "event.script.event_343_german_story.c13"
const TXT_FEDERAL_DEM := "event.script.event_343_german_story.c14"
const TXT_FEDERAL_NATO := "event.script.event_343_german_story.c15"
const TXT_FEDERAL_TAIL := "event.script.event_343_german_story.c16"
const TXT_GOODBYE_LENIN := "event.script.event_343_german_story.c17"
const TXT_FRG_WINS := "event.script.event_343_german_story.c18"
const TXT_EAST_LEARNS_WEST := "event.script.event_343_german_story.c19"
const TXT_RATS_2 := "event.script.event_343_german_story.c20"
const TXT_APPEND_G0 := "event.script.event_343_german_story.c21"
const TXT_APPEND_G1 := "event.script.event_343_german_story.c22"
const TXT_APPEND_G1_PROPRC := "event.script.event_343_german_story.c23"

const TXT_1594 := "event.script.event_343_german_story.c24"
const TXT_1595 := "event.script.event_343_german_story.c25"
const TXT_1596 := "event.script.event_343_german_story.c26"
const TXT_1597 := "event.script.event_343_german_story.c27"
const TXT_1598 := "event.script.event_343_german_story.c28"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	event_def.description = _text_of_ending(world)


func _text_of_ending(world: WorldState) -> String:
	var c16 := world.get_country_by_legacy_index(16)
	var c17 := world.get_country_by_legacy_index(17)
	var c1 := world.get_country_by_legacy_index(1)
	var c2 := world.get_country_by_legacy_index(2)
	var c4 := world.get_country_by_legacy_index(4)
	var c5 := world.get_country_by_legacy_index(5)
	var c7 := world.get_country_by_legacy_index(7)
	var c51 := world.get_country_by_legacy_index(51)
	var c92 := world.get_country_by_legacy_index(92)
	var text := ""
	var dev17 := c17.development if c17 != null else 0
	var _dev16 := c16.development if c16 != null else 0
	var g16 := c16.government if c16 != null else 0
	var sg16 := c16.sub_government if c16 != null else 0
	var g17 := c17.government if c17 != null else 0
	var parts16 := c16 != null and c16.parts.size() > 0 and c16.parts[0]
	var parts17 := c17 != null and c17.parts.size() > 0 and c17.parts[0]
	var proprc16 := c16 != null and c16.has_tag("亲中")
	var prosov16 := c16 != null and c16.has_tag("亲苏")
	var leader6 := world.empires.size() > 1 and world.empires[1] != null and world.empires[1].current_leader == 6
	var res488 := int(world.completed_event_ids.get("event_488", 0))

	if world.get_flag("is_gkchp"):
		text = tr(TXT_GKCHP)
		if c92 != null and c92.sub_government != GameConstants.SubGovernment.NEO_FASCIST:
			text += tr(TXT_GKCHP_APPEND)
	elif dev17 <= 0 and not prosov16 and not proprc16 and g16 == 1:
		if leader6:
			text = tr(TXT_VIETNAM)
		else:
			text = tr(TXT_ROMANIA)
	elif dev17 <= 0 and proprc16 and sg16 == 2:
		text = tr(TXT_DRAGON)
	elif parts16 and dev17 == 3 and proprc16 and sg16 == 2:
		text = tr(TXT_RUINS)
	elif dev17 <= 0 and proprc16 and g16 == 1:
		text = tr(TXT_DRAGON_G1)
	elif parts16 and dev17 == 3 and proprc16 and g16 == 1:
		text = tr(TXT_RUINS_G1)
	elif dev17 <= 0 and sg16 == 10:
		text = tr(TXT_AUTOCRAT)
	elif parts16 and dev17 == 3 and proprc16 and sg16 == 10:
		text = tr(TXT_STABILITY)
	elif dev17 <= 0 and sg16 == 15:
		text = tr(TXT_DEMOCRACY)
	elif dev17 <= 0 and sg16 == 8:
		text = tr(TXT_OPPORTUNIST)
	elif dev17 <= 0 and g16 == 2:
		text = tr(TXT_WE_STILL_HERE)
	elif parts17 and dev17 == 1 and g17 == 1:
		text = tr(TXT_PROLETARIAT)
	elif parts17 and dev17 == 1:
		text = tr(TXT_FEDERAL_DEM)
		if c51 != null and c51.has_tag("nato"):
			text += tr(TXT_FEDERAL_NATO)
		text += tr(TXT_FEDERAL_TAIL)
	elif c16 != null and c16.内战中 and dev17 <= 0:
		text = tr(TXT_GOODBYE_LENIN)
	elif parts17 and dev17 == 2:
		text = tr(TXT_FRG_WINS)
	elif parts16 and dev17 == 3 and prosov16:
		text = tr(TXT_EAST_LEARNS_WEST)
	elif c7 != null and c7.has_tag("nato"):
		if not c7.has_tag("eu"):
			text = tr(TXT_RATS_2)
		else:
			text = tr(TXT_1598)
	elif (c1 != null and c1.has_tag("sev") and c1.has_tag("ovd")) or (c5 != null and c5.has_tag("对华贸易") and (c2 == null or not c2.has_tag("亲苏")) and (c4 == null or not c4.has_tag("亲苏")) and (c1 != null and (c1.has_tag("ovd") or c1.has_tag("sev")))):
		text = tr(TXT_1594)
	elif leader6:
		text = tr(TXT_1595)
	else:
		text = tr(TXT_1594)

	if res488 != 3 and g17 == 0 and dev17 <= 0:
		text += tr(TXT_APPEND_G0)
		return text
	if res488 != 3 and g17 == 1 and dev17 <= 0 and (not proprc16 or sg16 == 10 or g16 == 2):
		text += tr(TXT_APPEND_G1)
		return text
	if res488 != 3 and g17 == 1 and dev17 <= 0 and proprc16 and g16 == 1:
		text += tr(TXT_APPEND_G1_PROPRC)
	return text


# 原版 string.Format(TXT_1598, "\n", TXT_1596/TXT_1597)：TXT_1598 无占位符，故 1596/1597 不显示，仅保留原文供溯源。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	context["result_text"] = _text_of_ending(ws)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_343_german_story.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_343",
	"nodesc": true,
	"num": 343,
	"priority": 34300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_343_german_story.gd",
}
