extends "res://数据脚本/event_script_base.gd"

## 原作 Event373.cs：祖先，祖父。
## 触发：见 .tres trigger_conditions（由 ReqEventsDLC02.cs else-if 链照抄）。

const TXT_TITLE := "祖先，祖父"

const TXT_DESC := "土耳其国家安全委员会于今日清晨，代表土耳其政府发布官方外交公告。公告中，土方措辞强硬地谴责塞浦路斯政府对其傀儡政权——所谓的“塞浦路斯土耳其联邦”实施的长期封锁与打压，并严厉指责塞浦路斯及希腊政府“再次公然违背《苏黎世-伦敦协定》的核心原则”。土耳其方面宣称，依据《担保协定》的规定，他们有权对塞浦路斯采取特别军事行动，以保护岛上土耳其族裔的合法权益与生命安全。\n对此，塞浦路斯政府迅速作出反应，当即动员国民警卫队预备役，并紧急加强绿线沿线所有防御工事的部署与警戒级别。与此同时，塞浦路斯正式向希腊提出请求，希望希方能增加其在塞岛的驻军力量——即希腊驻塞浦路斯部队（ELDYK），以协助塞方应对随时可能爆发的军事冲突。而土耳其军政府领导人凯南·埃夫伦，则在随后的记者招待会上公开发表极具煽动性的讲话：“我们必须彻底控制整个塞浦路斯岛。否则，岛上的土耳其族民众，必将在希腊与塞浦路斯政府的系统性迫害下，遭遇灭顶之灾。”\n国际社会对土耳其的第二次塞浦路斯入侵计划普遍予以强烈谴责。联合国依据安理会第367号决议，明确驳斥了土耳其的军事恫吓与扩张野心，并正式宣布对其实施一系列制裁措施。然而，尽管国际舆论一边倒地对土方表示反对，土耳其凭借其压倒性的军事优势，仍极有可能迅速击溃塞浦路斯的防御力量，进而将整座岛屿完全纳入自身的势力范围。\n面对这一复杂局势，我方是与国际社会一道谴责土耳其的行为，还是支持土耳其以换取一个潜在的盟友？"

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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


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

