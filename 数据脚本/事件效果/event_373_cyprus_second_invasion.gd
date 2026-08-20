extends "res://数据脚本/event_script_base.gd"

## 原作 Event373.cs：祖先，祖父。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。



const TXT_OPT0 := "我们支持土耳其政府的行动"
const TXT_OPT1 := "我们反对土耳其政府的行动"
const TXT_OPT2 := "我们漠不关心"
const TXT_WAR14_NAME := "土耳其入侵塞浦路斯"
const TXT_WAR14_SIDE1 := "土耳其"
const TXT_WAR14_SIDE2 := "希腊-塞浦路斯"

const TXT_R0 := "针对土耳其对塞浦路斯发起军事行动一事，我国外交部发言人发表声明称：“土耳其方面对塞浦路斯提出的相关诉求，具有其合理之处。塞浦路斯岛上土耳其族裔的人权状况确实令人深感忧虑。但中方始终强调，相关各方应秉持对话协商的原则，积极开展合作，推动问题得到和平解决。我们衷心希望，各方能够在充分考虑彼此核心关切、进行平等协商的基础上，作出必要的妥协与让步，早日实现地区的和平与稳定。”这一声明被国际社会普遍解读为我方对土耳其入侵行动的默许。各国纷纷对我方的这一立场提出谴责，而土耳其政府则对我方的支持态度表示赞赏。"
const TXT_R1 := "针对土耳其对塞浦路斯发起军事行动一事，我国外交部发言人发表声明称：“土耳其对塞浦路斯发动的军事行动，是明目张胆的武装入侵行为，严重践踏了国际法基本准则与塞浦路斯的国家主权和领土完整。我方对此表示强烈谴责，并严正要求土耳其立即停止一切军事行动，无条件撤出其派往塞浦路斯的所有军队，尽快与塞浦路斯方面回到谈判桌前，达成公平合理的和平协议。”"
const TXT_R2 := "针对土耳其对塞浦路斯发起军事行动一事，我国外交部发言人发表声明称：“我们高度关注塞浦路斯问题的最新发展态势。中方始终认为，塞浦路斯问题本质上是相关参与方的内部事务，其他任何国家与国际组织均无权随意插手干涉。中方在这一国际问题上，将始终秉持客观公正立场，发挥自身应有的建设性作用，并正积极着手向整个塞浦路斯岛提供人道主义援助。”"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	_enable(opt[1], TXT_OPT1)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_start_war(14, TXT_WAR14_SIDE1, TXT_WAR14_SIDE2, 700, 300, 1, 1, TXT_WAR14_NAME, 10)
			_add(W.I_PARTY_SUPPORT, -250)
			_add_relation(EmpireData.USA, -200)
			_add_relation(EmpireData.USSR, -200)
			context["result_text"] = TXT_R0
		1:
			_start_war(14, TXT_WAR14_SIDE1, TXT_WAR14_SIDE2, 700, 300, 1, 1, TXT_WAR14_NAME, 10)
			_add_relation(EmpireData.USA, 200)
			_add_relation(EmpireData.USSR, 200)
			context["result_text"] = TXT_R1
		2:
			_start_war(14, TXT_WAR14_SIDE1, TXT_WAR14_SIDE2, 700, 300, 1, 1, TXT_WAR14_NAME, 10)
			context["result_text"] = TXT_R2


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








func _prev_result(world: WorldState, event_id: String) -> int:
	return int(world.completed_event_ids.get(event_id, 0))


func _budget_reserve(world: WorldState) -> int:
	var total := 0
	var dv := world.数值表
	if dv.size() > W.I_BUDGET:
		total += dv[W.I_BUDGET]
	if dv.size() > W.I_RESERVE:
		total += dv[W.I_RESERVE]
	return total


func _faction_leading(i: int) -> bool:
	return GameManager != null and GameManager.is_faction_leading(i)


func _faction_leading_0_1_2() -> bool:
	return _faction_leading(0) or _faction_leading(1) or _faction_leading(2)


func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)


func _establish_proamerican(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", false)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", true)


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, war_name: String, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = tick_time

