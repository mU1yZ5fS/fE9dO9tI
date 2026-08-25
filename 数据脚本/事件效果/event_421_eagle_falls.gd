extends "res://数据脚本/event_script_base.gd"

## 原作 Event421.cs：雄鹰陨落（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1359-1361 —— ExprNode 组合。
## 差异：Vyshi→亲美；isASEAN/isSEATO/isSENTO/isNATO→标签；power 直接。

const TXT_RESULT := "event.script.event_421_eagle_falls.c0"
const TXT_IDX_1364 := "event.script.event_421_eagle_falls.c1"
const TXT_IDX_1365 := "event.script.event_421_eagle_falls.c2"
const TXT_IDX_1366 := "event.script.event_421_eagle_falls.c3"
const TXT_IDX_1367 := "event.script.event_421_eagle_falls.c4"



func _raw(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s





func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

## 原作 Event421.cs:18-21：TextOfEvents 显示时 event_done[422] && iron_and_blood → Set(141)
func prepare(_event_def: EventDef, world: WorldState) -> void:
	if world != null and world.completed_event_ids.has("event_422"):
		Achievements.set_achievement(141)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	if usa != null and usa.power > 0:
		usa.power = 0
	var china := ws.get_country_by_legacy_index(1)
	for c in ws.countries:
		if c == null:
			continue
		if c.原版序号 != 51:
			c.set_tag("亲美", false)
		if china == null or not china.has_tag("asean"):
			c.set_tag("asean", false)
		if china == null or not china.has_tag("seato"):
			c.set_tag("seato", false)
		c.set_tag("sento", false)
		c.set_tag("nato", false)
	var canada := ws.get_country_by_legacy_index(137)
	if canada != null:
		canada.set_tag("亲美", true)
	context["result_text"] = tr(TXT_RESULT)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_421_eagle_falls.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_421",
	"num": 421,
	"priority": 42100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_421_eagle_falls.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "87"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "21"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "84"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "86"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "45"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "92"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "7"}]}, {"t": "COUNTRY_FIELD_NOT_EQUALS", "key": "development", "v": 2, "target": "17"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1984.1.1"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "nato", "target": "17"}]}]}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
