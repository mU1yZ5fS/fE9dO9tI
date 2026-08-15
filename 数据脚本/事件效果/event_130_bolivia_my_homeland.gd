extends "res://数据脚本/event_script_base.gd"

## 原作 Event130.cs：玻利维亚，我的祖国，你已坠入火海（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_TITLE := "玻利维亚，我的祖国，你已坠入火海"
const TXT_DESC := "自1966年以来，在60年代末与70年代初发生的几次军事政变后，玻利维亚于1978年7月9日首次举行了大选。逐鹿选举舞台的首先有胡安·佩雷达，他是一名空军将领，也是前独裁者乌戈·班泽尔的心腹，在竞选中得到了民族主义人民联盟和民族主义人民革命运动（奉行社会保守主义的民族主义政党）的支持；其次是埃尔南·西莱斯，他得到了民主和人民联盟的提名，这是一个囊括了各左翼民族主义、社会主义和共产主义政党的联盟，就严格意义上说，他们都是坚定的民主人士与社会改革派。其他的候选人则毫无机会获得过半选票，而这是玻利维亚选举胜选的标准，这让第一次选举正处于岌岌可危的情况之中，但各党也有机会在其中争取未来的议会多数地位。"
const TXT_OPT0 := "胡安·佩雷达，民族主义人民联盟（右翼独裁主义）"
const TXT_OPT1 := "埃尔南·西莱斯，民主和人民联盟（右翼独裁主义）"
const TXT_OPT2 := "保持距离"
const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_R0 := "尽管民族主义联盟的胡安·佩雷达·阿斯本在总统大选中胜选，但人们发现总票数大于登记选民的人数（倘若重新计票，胡安便不会获得所需的过半选票）。人们作出了一系列有关选举欺诈及其他违规行为的指控，包括在选民数目上的欺诈、窃取投票箱及为资助佩雷达·阿斯本的竞选活动而进行的政治献金。在对此类指控进行审查后，选举法院于7月20日作出裁决，宣布选举结果无效。而在选举结果因欺诈行为被宣布无效的次日，在一场军事政变后，佩雷达成为了总统。同一天，根据总统令，玻利维亚全国进入戒严状态，一切公共集会被禁止，清洗军队、镇压人民和迫害工会的行动也纷至沓来。如此这般，再加上经济衰退、繁荣不再，大规模的骚乱和集会因此而起，而佩雷达仍企图延续他的任期，最终引发了11月24日的军事反政变，之后，大卫·帕迪利亚将军成为了总统。新的选举定于明年7月举行。"
const TXT_R1 := "尽管各自竭尽全力，但没有一个候选人能获得过半选票，又因为没有候选人在有效选票中获得绝对多数，不得不由国会决定谁将成为共和国的新任总统。根据现行宪法，得票数最多的三位候选人将在次年再度参与竞选。经过几轮投票，没有候选人在议员中获得绝对多数，雨果·班塞尔将其任期延长了一年，并要求在明年7月举行新的选举，在此之前，他保证将继续与民选议会合作，还承诺在1979年7月最终退出政坛，民主派与反对派也因此得到了安抚。"

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


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _proprc_suffix(c: CountryData) -> String:
	return TXT_PROPRC_YES if c.has_tag("亲中") else TXT_PROPRC_NO

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bolivia := ws.get_country_by_legacy_index(72)
	if bolivia == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			bolivia.level_of_instability -= 5
			bolivia.level_of_development -= 10
			bolivia.set_tag("对华贸易", true)
			context["result_text"] = TXT_R0 + _proprc_suffix(bolivia)
		1:
			bolivia.set_tag("对华贸易", true)
			bolivia.level_of_instability -= 15
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			context["result_text"] = TXT_R1 + _proprc_suffix(bolivia)
		_:
			bolivia.level_of_instability -= 5
			bolivia.level_of_development -= 5
			context["result_text"] = TXT_R0 + _proprc_suffix(bolivia)
	bolivia.government = 3
	bolivia.sub_government = 7
	bolivia.next_election_year = 1979
	bolivia.next_election_month = 7
	bolivia.next_election_day = 1

