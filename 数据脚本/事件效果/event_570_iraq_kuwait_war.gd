extends "res://数据脚本/event_script_base.gd"

## 原作 Event570.cs：命运的战争已然开始（伊拉克-科威特，单选项）。 ## 触发：ReqEventForDLC02.cs:769-772 —— !event_done[570] && !event_done[571] ##   && !c14.parts[4] && (c8.proprc c8.prosov) && IsSocialism(true,14) && OAR ##   && (!IsAuthoritarianism(102) ingamewars[43].is_going)。复杂条件 → trigger_script evaluate。 ## 差异： ##  - event_done[570] 由 fire_only_once 覆盖；event_done[571] 在 evaluate 中检查； ##  - parts[4] → c14.parts[4]；proprc/prosov → 亲中/亲苏；OAR → ws flag "oar"； ##  - data.oil_price 无命名键 raw；AmericanSupportDefender → usa_side = GameConstants.WarSide.SIDE2/ussr_side = GameConstants.WarSide.NONE； ##  - TickTime(8) → fortnight_max=8。




const TXT_R0 := "event.script.event_570_iraq_kuwait_war.c0"

const WAR38_NAME := "event.script.event_570_iraq_kuwait_war.c1"
const WAR38_SIDE1 := "event.script.event_570_iraq_kuwait_war.c2"
const WAR38_SIDE2 := "event.script.event_570_iraq_kuwait_war.c3"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	if world.completed_event_ids.has("event_571"):
		return false
	var c14 := world.get_country_by_legacy_index(14)
	var c8 := world.get_country_by_legacy_index(8)
	var c102 := world.get_country_by_legacy_index(102)
	if c14 != null and c14.parts.size() > 4 and c14.parts[4]:
		return false
	if c8 == null or (not c8.has_tag("亲中") and not c8.has_tag("亲苏")):
		return false
	if not world.is_socialism(c14, true):
		return false
	if not world.get_flag("oar"):
		return false
	var w43 := world.wars[43] if world.wars.size() > 43 else null
	if world.is_authoritarian(c102) and (w43 == null or not w43.is_going):
		return false
	return true


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var num := 0
	for c in ws.countries:
		if c == null:
			continue
		if c.government == GameConstants.Government.SOCIALIST and c.has_tag("oar") and c.原版序号 in [13, 14, 30, 18, 40, 54, 55, 35]:
			num += 20
	if d.size() > 143:
		d.oil_price += 3   # 原 data.oil_price（无命名键）
	game.start_war(38, tr(WAR38_SIDE1), tr(WAR38_SIDE2), 700 + num, 300 - num, 1, -1)
	if ws.wars.size() > 38 and ws.wars[38] != null:
		ws.wars[38].name_war = tr(WAR38_NAME)
		ws.wars[38].fortnight_max = 8
	context["result_text"] = tr(TXT_R0)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_570_iraq_kuwait_war.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_570",
	"num": 570,
	"priority": 57000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_570_iraq_kuwait_war.gd",
	"trigger_script": "res://数据脚本/事件效果/event_570_iraq_kuwait_war.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
