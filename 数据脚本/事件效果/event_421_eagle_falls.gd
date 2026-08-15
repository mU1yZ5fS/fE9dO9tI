extends "res://数据脚本/event_script_base.gd"

## 原作 Event421.cs：雄鹰陨落（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1359-1361 —— ExprNode 组合。
## 差异：Vyshi→亲美；isASEAN/isSEATO/isSENTO/isNATO→标签；power 直接。

const TXT_TITLE := "雄鹰陨落"
const TXT_DESC := "北大西洋公约组织被绝大多数的创始国抛弃，导致该组织内拥有强大军事实力的国家少之又少。只有美国、加拿大与德国还能在其中苟延残喘。\n今天，北大西洋理事会决定废除有关1949年建立北约的协定。北约在布鲁塞尔的总部也在各成员国的降旗仪式结束后被关闭。在此之后，美国退出了其他仿照北约模式建立的地区性联盟。"
const TXT_OPT0 := "美帝国主义的日子到头了！"
const TXT_RESULT := "冷战结束了吗......？"
const TXT_IDX_1364 := "雄鹰陨落"
const TXT_IDX_1365 := "北大西洋公约组织被绝大多数的创始国抛弃，导致该组织内拥有强大军事实力的国家少之又少。只有美国、加拿大与德国还能在其中苟延残喘。\n今天，北大西洋理事会决定废除有关1949年建立北约的协定。北约在布鲁塞尔的总部也在各成员国的降旗仪式结束后被关闭。在此之后，美国退出了其他仿照北约模式建立的地区性联盟。"
const TXT_IDX_1366 := "美帝国主义的日子到头了！"
const TXT_IDX_1367 := "冷战结束了吗......？"

func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

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
