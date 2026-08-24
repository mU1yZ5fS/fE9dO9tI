extends "res://数据脚本/event_script_base.gd"

## 原作 Event389.cs：全球主义的崩溃？（法国经济路线，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DIS_INFLUENCE := "event.script.event_389_globalism_collapse.c0"
const TXT_DIS_AGENTS := "event.script.event_389_globalism_collapse.c1"
const TXT_R0 := "event.script.event_389_globalism_collapse.c2"
const TXT_R1 := "event.script.event_389_globalism_collapse.c3"


const TXT_LABEL_BUDGET := "event.script.event_389_globalism_collapse.c4"
const TXT_LABEL_AGENTS := "event.script.event_389_globalism_collapse.c5"
const TXT_LABEL_ARMY := "event.script.event_389_globalism_collapse.c6"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if world.influence_prc >= 450 and _d(W.I_AGENTS) >= 150:
		_enable(opt[0], event_def.options[0].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif world.influence_prc < 450:
		_disable(opt[0], tr(TXT_DIS_INFLUENCE).format([45]))
	else:
		_disable(opt[0], tr(TXT_DIS_AGENTS).format([15]))
	if world.influence_prc >= 450 and _d(W.I_AGENTS) >= 150:
		_enable(opt[1], event_def.options[1].text.format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif world.influence_prc < 450:
		_disable(opt[1], tr(TXT_DIS_INFLUENCE).format([45]))
	else:
		_disable(opt[1], tr(TXT_DIS_AGENTS).format([15]))
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
		context["result_text"] = tr(TXT_R1)
		if france != null:
			france.government = GameConstants.Government.REFORMIST
			france.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			france.set_tag("eu", false)
		_add_power(EmpireData.USA, -30)
	else:
		context["result_text"] = tr(TXT_R0)
		if france != null:
			france.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		_add_power(EmpireData.USA, 30)




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0





