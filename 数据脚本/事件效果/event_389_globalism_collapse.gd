extends "res://数据脚本/event_script_base.gd"

## 原作 Event389.cs：全球主义的崩溃？（法国经济路线，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DIS_INFLUENCE := "中国的国际影响力应高于{0}......"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_R0 := "法国总统弗朗西斯·密特朗宣布，该国准备实行“严格审计”的财政政策：因此公共支出将被缩减150亿法郎，并引入新的税种与消费税。\n社会经济政策的巨变令那些认为弗朗西斯·密特朗与皮埃尔·莫鲁瓦政府将采用非资本主义发展道路，以非自由主义替代方案恢复经济增长，解决1979年危机的左翼选民大失所望。\n作为对新政的抗议，共产主义者选择离开该政府。"
const TXT_R1 := "法国总统弗朗西斯·密特朗宣布，该国准备实行“第二阶段的社会主义改革”。法国宣布减少本国对欧洲货币体系与欧洲经济共同体的活动，并称后者的政策“触及原则底线问题，并与国家的社会经济发展方向背道而驰”。\n国内已经开始就建立统一公共与私人部门的教育系统开始进行讨论，同时引入了对大型企业的第二轮国有化，针对大资产所有者与高收入群体的“团结税”制度也被引入。"


const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if world.influence_prc >= 450 and _d(W.I_AGENTS) >= 150:
		_enable(opt[0], event_def.options[0].text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif world.influence_prc < 450:
		_disable(opt[0], TXT_DIS_INFLUENCE.format([45]))
	else:
		_disable(opt[0], TXT_DIS_AGENTS.format([15]))
	if world.influence_prc >= 450 and _d(W.I_AGENTS) >= 150:
		_enable(opt[1], event_def.options[1].text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
	elif world.influence_prc < 450:
		_disable(opt[1], TXT_DIS_INFLUENCE.format([45]))
	else:
		_disable(opt[1], TXT_DIS_AGENTS.format([15]))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var num := 0
	var britain := ws.get_country_by_legacy_index(92)
	var italy := ws.get_country_by_legacy_index(85)
	var greece := ws.get_country_by_legacy_index(45)
	var usa := ws.get_country_by_legacy_index(51)
	if britain == null or not britain.has_tag("eu"):
		num += 1
	if italy == null or not italy.has_tag("eu"):
		num += 1
	if greece == null or not greece.has_tag("eu"):
		num += 1
	if usa != null and usa.has_tag("对华贸易"):
		num -= 1
	if usa != null and usa.development > 0:
		num -= 1
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null 			and ws.empires[EmpireData.USA].current_leader == 1:
		num += 1
	else:
		num -= 1
	var num2 := 0
	var china := ws.get_country_by_legacy_index(1)
	for c in ws.countries:
		if c != null and (c.has_tag("econ") or (china != null and china.has_tag("sev") and c.has_tag("sev"))):
			num2 += 1
	if num2 > 4:
		num += 1
	elif num2 > 9:
		num += 2
	elif num2 > 14:
		num += 3
	if _d(W.I_INFLUENCE) > ws.empires[EmpireData.USA].power:
		num += 1
	else:
		num -= 1
	var france := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	if opt == 0:
		num -= 2
		_add(W.I_AGENTS, -150)
	elif opt == 1:
		num += 1
		_add(W.I_AGENTS, -150)
	if num > 5:
		context["result_text"] = TXT_R1
		if france != null:
			france.government = 2
			france.sub_government = 3
			france.set_tag("eu", false)
		_add_power(EmpireData.USA, -30)
	else:
		context["result_text"] = TXT_R0
		if france != null:
			france.sub_government = 12
		_add_power(EmpireData.USA, 30)




func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0




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
