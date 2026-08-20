extends "res://数据脚本/event_script_base.gd"

## 原作 Event430.cs：社会主义联盟的勃兴（三选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1179-1181 —— ExprNode 组合。
## 差异：cw→内战中；perevorot→政变中；isNATO/isSocEU/isEU/isSEV/okb/econ→标签；
##  - LeaveAlliances→_leave_alliances；Torg→对华贸易；empires[1].leaders[6]→leaders[6]；
##  - 原版 num/flag/flag2 死代码跳过；result_num 2 无额外效果。

const TXT_IDX_1438 := "社会主义联盟的勃兴"
const TXT_IDX_1440 := "支持社会主义联盟的建立，并与之签订贸易协定"
const TXT_IDX_1441 := "谴责这一联盟在意识形态上的短视"
const TXT_IDX_1442 := "静观其变"
const TXT_IDX_1446 := "上述各国均退出了北约组织。"
const TXT_IDX_1447 := "中国外交部祝贺欧洲各国打造了全新的联盟组织形式，并考虑与其确立新的贸易合作关系。\n{2}\n{1}"
const TXT_IDX_1448 := "中国外交部谴责这一新联盟的“意识形态短视”，并认为“这将在其他政治力量参与其中时，导致欧洲局势不稳”。\n{2}\n{1}"
const TXT_IDX_1449 := "我想知道这样的联盟将如何告终......\n{2}\n{1}"
const TXT_APPEND_PT := "此外，在葡萄牙，不久前刚刚上台的社会党与联合人民联盟组成社会主义联合政府也表示，决定申请加入社会主义联盟。鉴于其最近宣布的政策和道路与社会主义联盟的理念十分贴近，申请很快就会通过。"
const TXT_APPEND_UK := "刚刚赢得大选的英国工党政府看到了新兴社会主义联盟潜力，为更好贯彻“重建福利国家”的政策，主动申请加入社会主义联盟以寻求经济帮助。"



func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0






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
	var opt := int(context.get("option_index", -1))
	var italy := ws.get_country_by_legacy_index(85)
	var france := ws.get_country_by_legacy_index(21)
	var spain := ws.get_country_by_legacy_index(86)
	var portugal := ws.get_country_by_legacy_index(87)
	var turkey := ws.get_country_by_legacy_index(84)
	var uk := ws.get_country_by_legacy_index(92)
	if italy != null:
		italy.内战中 = false
		italy.政变中 = false
	# 原版 flag/flag2 恒为 false，num 恒为 0，1443-1445 死代码，跳过。
	var flag3 := (france != null and france.has_tag("nato")) \
			or (spain != null and spain.has_tag("nato")) \
			or (italy != null and italy.has_tag("nato"))
	# 原作 Event430.cs:56：iron_and_blood → achievements.Set(127)
	Achievements.set_achievement(127)
	if france != null:
		_leave_alliances(france)
	if spain != null:
		_leave_alliances(spain)
	if italy != null:
		_leave_alliances(italy)
	if italy != null:
		italy.set_tag("soc_eu", true)
	if france != null:
		france.set_tag("soc_eu", true)
	if spain != null:
		spain.set_tag("soc_eu", true)
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
			and ws.empires[EmpireData.USSR].leaders.size() > 6:
		ws.empires[EmpireData.USSR].leaders[6].support += 999
	if portugal != null and portugal.sub_government == 3 and not portugal.has_tag("econ") \
			and not portugal.has_tag("eu") and not portugal.has_tag("okb") and not portugal.has_tag("sev"):
		_leave_alliances(portugal)
		portugal.set_tag("soc_eu", true)
	if turkey != null and turkey.sub_government == 3 and not turkey.has_tag("econ") \
			and not turkey.has_tag("eu") and not turkey.has_tag("okb") and not turkey.has_tag("sev"):
		_leave_alliances(turkey)
		turkey.set_tag("soc_eu", true)
	_add_power(EmpireData.USA, -100)
	var base := ""
	if opt == 0:
		base = TXT_IDX_1447
	elif opt == 1:
		base = TXT_IDX_1448
	else:
		base = TXT_IDX_1449
	var text := base.replace("{1}", "").replace("{2}", TXT_IDX_1446 if flag3 else "")
	if portugal != null and portugal.has_tag("soc_eu"):
		text += TXT_APPEND_PT
	if italy != null and italy.has_tag("soc_eu") and _raw(147) == 3:
		text += "\n" + TXT_APPEND_UK
		if uk != null:
			uk.set_tag("soc_eu", true)
			uk.set_tag("nato", false)
	context["result_text"] = text
	if opt == 0:
		_add_relation(EmpireData.USA, -500)
		for c in ws.countries:
			if c != null and c.has_tag("soc_eu"):
				c.set_tag("对华贸易", true)
		return
	if opt == 1:
		_add_relation(EmpireData.USA, 300)
