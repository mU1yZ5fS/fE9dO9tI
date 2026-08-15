extends "res://数据脚本/event_script_base.gd"

const T_663_0 := "远东斯巴达的终结"
const T_663_1 := "自1948年以来，缅甸国内便大小冲突不断：从共产党到民族分离武装你方唱罢我登场，共同撕裂着这个新生的政权。然而，由于缅甸政府的强力镇压，该国多少能维持一种“散而不倒”的状态。可如今，时代变了：反政府武装甚至打入了缅甸古都曼德勒，并逼迫该国政府不得不援引全国紧急状态。以“国家统一”为招牌的缅甸政府陷入了全面危机，缅甸内战也将迎来其最高峰。"
const T_663_2 := "火药桶的最终结局都是如此……"
const T_663_4 := "远东斯巴达的终结"
const T_663_5 := "缅甸内战"
const T_663_6 := "塔马刀"
const T_663_7 := "克伦民族联盟"
const T_663_8 := "缅甸内战"
const T_663_9 := "塔马刀"
const T_663_10 := "缅共"
const T_663_11 := "缅甸内战"
const T_663_12 := "塔马刀"
const T_663_13 := "缅共"
const T_663_14 := "亚洲的巴尔干前途未明……"


## 原作 Event663.cs：远东斯巴达的终结（缅甸，一选项）。
## 触发：TimeScript.cs:11114-11118 —— allcountries[33].inflCh>=100。
## 差异：
##  - inflCh → CountryData.influence_china；ExprNode 暂不支持，触发走 trigger_script（本脚本 evaluate）。
##  - 死代码 result_num==5 跳过。

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var burma := world.get_country_by_legacy_index(33)
	if burma == null:
		return false
	return burma.influence_china >= 100


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 1:
		return
	event_def.title = T_663_0
	event_def.description = T_663_1
	_enable(event_def.options[0], T_663_2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var r662 := int(ws.completed_event_ids.get("event_662", 0))
	if r662 == 2:
		_start_war(82, T_663_6, T_663_7, 600, 400, 1, 0, T_663_5)
	elif r662 == 4:
		_start_war(82, T_663_9, T_663_10, 700, 300, 0, 0, T_663_8)
	else:
		_start_war(82, T_663_12, T_663_13, 600, 400, 0, 0, T_663_11)
	context["result_text"] = T_663_14


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, fortnight: int = -1) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		if fortnight >= 0:
			ws.wars[war_id].fortnight_max = fortnight
