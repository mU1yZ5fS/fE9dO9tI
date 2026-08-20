extends "res://数据脚本/event_script_base.gd"

## 原作 Event421.cs：雄鹰陨落（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1359-1361 —— ExprNode 组合。
## 差异：Vyshi→亲美；isASEAN/isSEATO/isSENTO/isNATO→标签；power 直接。

const TXT_RESULT := "冷战结束了吗......？"
const TXT_IDX_1364 := "雄鹰陨落"
const TXT_IDX_1365 := "北大西洋公约组织被绝大多数的创始国抛弃，导致该组织内拥有强大军事实力的国家少之又少。只有美国、加拿大与德国还能在其中苟延残喘。\n今天，北大西洋理事会决定废除有关1949年建立北约的协定。北约在布鲁塞尔的总部也在各成员国的降旗仪式结束后被关闭。在此之后，美国退出了其他仿照北约模式建立的地区性联盟。"
const TXT_IDX_1366 := "美帝国主义的日子到头了！"
const TXT_IDX_1367 := "冷战结束了吗......？"



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
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
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
	context["result_text"] = TXT_RESULT
