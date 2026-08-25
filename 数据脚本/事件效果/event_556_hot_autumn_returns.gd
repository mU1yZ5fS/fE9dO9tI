extends "res://数据脚本/event_script_base.gd"

## 原作 Event556.cs：“火热之秋”的重临（意大利内战，1选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1219-1221 —— 复杂条件见 evaluate()。
## 差异：ingamewars[23] → game.start_war；inflNATO→usa_influence；
##   YugAgree→ws.get_flag("YugAgree")；spec→special；IsSocialism→is_socialism。

const TXT_R0_WORKER := "event.script.event_556_hot_autumn_returns.c0"
const TXT_R0_ORTHO := "event.script.event_556_hot_autumn_returns.c1"
const TXT_R0_MAO := "event.script.event_556_hot_autumn_returns.c2"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var c85 := world.get_country_by_legacy_index(85)
	if c85 == null:
		return false
	if c85.level_of_development >= 20:
		return false
	var dd := world
	if dd.size() <= 134:
		return false
	if dd.italian_radical_left_power < 200:
		return false
	if c85.influence_china > 0:
		return false
	return c85.内战中


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c1 := ws.get_country_by_legacy_index(1)
	var c20 := ws.get_country_by_legacy_index(20)
	var c85 := ws.get_country_by_legacy_index(85)
	var c87 := ws.get_country_by_legacy_index(87)
	if d.press_policy > 17:
		d.italy_power_172 += 1
	if not ws.modifiers[3].is_active:
		d.italy_power_172 -= 1
		d.italy_power_174 -= 999
	if d.mao_history_line == 0 and ws.completed_event_ids.has("event_74"):
		d.italy_power_174 -= 1
	elif d.mao_history_line != 0:
		d.italy_power_174 -= 999
	if ws.modifiers[28].is_active:
		d.italy_power_172 += 1
	# 改版：意大利毛派分数（174）仅在“无产阶级宪法”（极左宪法）下加成，普通75宪法不加。
	if ModifierCatalog._is_proletarian_constitution(ws):
		d.italy_power_174 += 1
	if c85 != null and c85.usa_influence > 0:
		d.italy_power_173 += 2
	if c87 != null and c87.sub_government == GameConstants.SubGovernment.STATE_SOCIALIST:
		d.italy_power_173 += 1
	elif c87 != null and c87.sub_government == GameConstants.SubGovernment.LEFT_RADICAL:
		d.italy_power_172 += 1
	if ws.modifiers[43].is_active:
		d.italy_power_172 += 1
	if ws.modifiers[44].is_active and ws.get_flag("YugAgree"):
		d.italy_power_173 += 1
	elif ws.modifiers[44].is_active:
		d.italy_power_172 -= 2
		d.italy_power_173 -= 1
	if ws.modifiers[49].is_active:
		d.italy_power_173 += 2
	if c1 != null and c1.has_tag("rim") and ws.modifiers[3].is_active and ws.modifiers[6].is_active 			and ws.is_socialism(c1, true):
		d.italy_power_174 += 2
	if ws.completed_event_ids.has("event_500"):
		d.italy_power_174 += 2
	if c20 != null and c20.has_tag("亲中"):
		d.italy_power_174 += 1
	if c20 != null and c20.special == 1:
		d.italy_power_174 += 1
	if ws.influence_prc > 800:
		d.italy_power_174 += 1
	var num := 0
	for idx in [21, 86, 87, 17, 92]:
		var cc := ws.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("eu"):
			num += 20
	for idx in [21, 86, 87, 17, 92]:
		var cc := ws.get_country_by_legacy_index(idx)
		if cc != null and cc.has_tag("nato"):
			num += 100
	for idx in [92, 17, 87, 86, 21]:
		var cc := ws.get_country_by_legacy_index(idx)
		if cc != null and ws.is_socialism(cc, true):
			num -= 50
	num -= (d.italian_radical_left_power - 200) * 5
	if c87 != null:
		c87.special -= 15
	var ussr_side := -1
	if c1 == null or not c1.has_tag("sev"):
		ussr_side = GameConstants.WarSide.SIDE2
	if d.italy_power_172 >= d.italy_power_173 and d.italy_power_172 >= d.italy_power_174:
		d.italy_hot_autumn_route = 1
		_add_power(EmpireData.USA, -10)
		_start_war23(num, ussr_side)
		context["result_text"] = tr(TXT_R0_WORKER)
	elif d.italy_power_173 >= d.italy_power_172 and d.italy_power_173 >= d.italy_power_174:
		d.italy_hot_autumn_route = 2
		_add_power(EmpireData.USA, -10)
		_start_war23(num, ussr_side)
		context["result_text"] = tr(TXT_R0_ORTHO)
	else:
		d.italy_hot_autumn_route = 3
		_add_power(EmpireData.USA, -10)
		_start_war23(num, ussr_side)
		context["result_text"] = tr(TXT_R0_MAO)


func _start_war23(num: int, ussr_side: int) -> void:
	game.start_war(23, "左翼激进派", "民族团结政府", 300 - num, 700 + num, 1, ussr_side)
	if ws.wars.size() > 23 and ws.wars[23] != null:
		ws.wars[23].name_war = "意大利内战"
		ws.wars[23].fortnight_max = 30



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_556_hot_autumn_returns.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_556",
	"num": 556,
	"priority": 55600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_556_hot_autumn_returns.gd",
	"trigger_script": "res://数据脚本/事件效果/event_556_hot_autumn_returns.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
