extends "res://数据脚本/event_script_base.gd"

## 原作 Event571.cs：阿拉伯联合共和国入侵科威特（单选项）。
## 触发：ReqEventForDLC02.cs:774-777 —— !event_done[571] && !event_done[570]
##   && !event_done[417] && c8.proprc && completedDecisions[20]
##   && (c30.parts[0] || c30.parts[1]) && OAR && !IsAuthoritarianism(102)。
##   复杂条件 → trigger_script evaluate。
## 差异：
##  - event_done[571] 由 fire_only_once 覆盖；event_done[570]/[417] 在 evaluate 中检查；
##  - proprc → 亲中；OAR → ws flag "oar"；completedDecisions[20] → ws.decisions.completed[20]；
##  - data[143] 无命名键 raw；SovietSupportDefender.AmericanSupportDefender → usa_side=1/ussr_side=1；
##  - TickTime(25) → fortnight_max=25。

const TXT_TITLE := "阿拉伯联合共和国入侵科威特"

const TXT_DESC := "数年前在伊拉克上台的穆希·阿卜杜勒--侯赛因·马什哈迪，几乎是在掌权同时便将自己打扮为新的艾哈迈德·贝克尔，并试图将伊拉克打造为阿拉伯世界的领头羊。在1979年时，他甚至保证提供与世界油价挂钩的无息贷款。\n而在阿拉伯联合共和国成立后，穆希被自己国内外的巨大声望冲昏了头脑。为了进一步巩固自己的地位，他对邻国科威特的油田动了歪脑筋。因此，他谴责科威特政府在临近两国边界的的鲁米利亚地区内盗采石油，并以此为由在阿拉伯国家国务委员会议上提出了为维护新生共和国利益而向科威特进行特别军事行动的议题，议题被全票通过，很快，阿联共便向与科威特的边界派出部队并要求科威特政府谈判。在第二天举行的谈判失败后，阿联共便开始向科威特领土进发。"

const TXT_OPT0 := "出乎意料！"

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
		d[143] += 3   # 原 data[143]（无命名键）
	GameManager.start_war(28, WAR28_SIDE1, WAR28_SIDE2, 950, 50, 1, 1)
	if ws.wars.size() > 28 and ws.wars[28] != null:
		ws.wars[28].name_war = WAR28_NAME
		ws.wars[28].fortnight_max = 25
	context["result_text"] = TXT_R0
