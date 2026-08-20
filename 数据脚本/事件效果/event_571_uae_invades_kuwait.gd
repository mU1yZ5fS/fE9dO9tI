extends "res://数据脚本/event_script_base.gd"

## 原作 Event571.cs：阿拉伯联合共和国入侵科威特（单选项）。
## 触发：ReqEventForDLC02.cs:774-777 —— !event_done[571] && !event_done[570]
##   && !event_done[417] && c8.proprc && completedDecisions[20]
##   && (c30.parts[0] || c30.parts[1]) && OAR && !IsAuthoritarianism(102)。
##   复杂条件 → trigger_script evaluate。
## 差异：
##  - event_done[571] 由 fire_only_once 覆盖；event_done[570]/[417] 在 evaluate 中检查；
##  - proprc → 亲中；OAR → ws flag "oar"；completedDecisions[20] → ws.decisions.completed[20]；
##  - data.oil_price 无命名键 raw；SovietSupportDefender.AmericanSupportDefender → usa_side = GameConstants.WarSide.SIDE2/ussr_side = GameConstants.WarSide.SIDE2；
##  - TickTime(25) → fortnight_max=25。




const TXT_R0 := "国际社会一致谴责阿联共对科威特的入侵。苏联与美国拒绝承认侯赛因的领土宣称，在对阿联共引入制裁的同时，以联合国的名义建立了国际联合军。然而现在依然难说科威特这个弹丸小国的最终命运，不知能不能扛得住阿联共的百万大军。"

const WAR28_NAME := "阿联共入侵科威特"
const WAR28_SIDE1 := "阿联共"
const WAR28_SIDE2 := "科威特"


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
	GameManager.start_war(28, WAR28_SIDE1, WAR28_SIDE2, 950, 50, 1, 1)
	if ws.wars.size() > 28 and ws.wars[28] != null:
		ws.wars[28].name_war = WAR28_NAME
		ws.wars[28].fortnight_max = 25
	context["result_text"] = TXT_R0
