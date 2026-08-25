extends "res://数据脚本/event_script_base.gd"

## 原作 Event571.cs：阿拉伯联合共和国入侵科威特（单选项）。 ## 触发：ReqEventForDLC02.cs:774-777 —— !event_done[571] && !event_done[570] ##   && !event_done[417] && c8.proprc && completedDecisions[20] ##   && (c30.parts[0] c30.parts[1]) && OAR && !IsAuthoritarianism(102)。 ##   复杂条件 → trigger_script evaluate。 ## 差异： ##  - event_done[571] 由 fire_only_once 覆盖；event_done[570]/[417] 在 evaluate 中检查； ##  - proprc → 亲中；OAR → ws flag "oar"；completedDecisions[20] → ws.decisions.completed[20]； ##  - data.oil_price 无命名键 raw；SovietSupportDefender.AmericanSupportDefender → usa_side = GameConstants.WarSide.SIDE2/ussr_side = GameConstants.WarSide.SIDE2； ##  - TickTime(25) → fortnight_max=25。




const TXT_R0 := "event.script.event_571_uae_invades_kuwait.c0"

const WAR28_NAME := "event.script.event_571_uae_invades_kuwait.c1"
const WAR28_SIDE1 := "event.script.event_571_uae_invades_kuwait.c2"
const WAR28_SIDE2 := "event.script.event_571_uae_invades_kuwait.c3"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.completed_event_ids.has("event_570") or world.completed_event_ids.has("event_417"):
		return false
	var c8 := world.get_country_by_legacy_index(8)
	if c8 == null or not c8.has_tag("亲中"):
		return false
	if world.decisions == null or world.decisions.completed.size() <= 20 or not world.decisions.completed[20]:
		return false
	var c30 := world.get_country_by_legacy_index(30)
	var part0 := c30 != null and c30.parts.size() > 0 and c30.parts[0]
	var part1 := c30 != null and c30.parts.size() > 1 and c30.parts[1]
	if not (part0 or part1):
		return false
	if not world.get_flag("oar"):
		return false
	var c102 := world.get_country_by_legacy_index(102)
	if world.is_authoritarian(c102):
		return false
	return true


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	if d.size() > 143:
		d.oil_price += 3   # 原 data.oil_price（无命名键）
	game.start_war(28, tr(WAR28_SIDE1), tr(WAR28_SIDE2), 950, 50, 1, 1)
	if ws.wars.size() > 28 and ws.wars[28] != null:
		ws.wars[28].name_war = tr(WAR28_NAME)
		ws.wars[28].fortnight_max = 25
	context["result_text"] = tr(TXT_R0)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_571_uae_invades_kuwait.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_571",
	"num": 571,
	"priority": 57100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_571_uae_invades_kuwait.gd",
	"trigger_script": "res://数据脚本/事件效果/event_571_uae_invades_kuwait.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
