extends "res://数据脚本/event_script_base.gd"

## 原作 Event422.cs：欧洲日落（一选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1364-1366 —— ExprNode 组合。
## 差异：isEU→标签 eu；power 直接。

const TXT_TITLE := "欧洲日落"
const TXT_DESC := "显然，在欧洲经济共同体的基础上打造单一经济空间，并构建邦联国家架构的尝试已经落空。因此，实现全面的欧洲一体化的计划已经失败。该组织的主要成员纷纷抛弃了欧洲经济共同体。\n因此，其他仍留在欧共体的国家纷纷宣布取消绝大多数旨在建立单一的政治、货币、经济与关税空间的协定。\n欧洲共同市场实际上已不复存在。"
const TXT_OPT0 := "全球主义计划的落幕！"
const TXT_RESULT := "欧洲的局势更类似于20世纪初的情况......"
const TXT_IDX_1368 := "欧洲日落"
const TXT_IDX_1369 := "显然，在欧洲经济共同体的基础上打造单一经济空间，并构建邦联国家架构的尝试已经落空。因此，实现全面的欧洲一体化的计划已经失败。该组织的主要成员纷纷抛弃了欧洲经济共同体。\n因此，其他仍留在欧共体的国家纷纷宣布取消绝大多数旨在建立单一的政治、货币、经济与关税空间的协定。\n欧洲共同市场实际上已不复存在。"
const TXT_IDX_1370 := "全球主义计划的落幕！"
const TXT_IDX_1371 := "欧洲的局势更类似于20世纪初的情况......"

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
	for c in ws.countries:
		if c != null:
			c.set_tag("eu", false)
	context["result_text"] = TXT_RESULT
