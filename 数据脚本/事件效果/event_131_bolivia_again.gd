extends "res://数据脚本/event_script_base.gd"

## 原作 Event131.cs：又一次，又一次，又一次（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_TITLE := "又一次，又一次，又一次"
const TXT_DESC := "在确定新的选举日期时，《1967年宪法》被宣布适用于此次选举，其中规定的参选候选人的条件自然也得以沿用。1979年选举中所采用的选举制度是简单的个人及选区制度。在此次选举中，有关于选票的最大创新便是采用了彩色多选项的选票（DL.16095）。在此之前，所有政党都能印发自己的选票，这给他们操纵选举留下了可乘之机。目前，最受欢迎的候选人是：埃尔南·西莱斯·祖阿索，来自民主和人民联盟，各玻利维亚左派政党都被囊括在联盟之中，而候选人本人将坚持温和的民主左派立场；以及维克托·帕斯·埃斯登索罗，来自革命民族主义运动联盟，一个右翼民族主义保守集团。在军事政变前，维克多本人曾先后三次担任玻利维亚总统（并非连任），早些时候还担任过财政部长，恪守自由保守主义原则。如果没有一个候选人获得过半选票，那么将由议会选择总统，而议会的决定将取决于去年议会选举的情况。"
const TXT_OPT0 := "埃尔南·西莱斯·祖阿索，民主和人民联盟（社会民主主义）"
const TXT_OPT1 := "维克托·帕斯·埃斯登索罗，革命民族主义运动联盟(温和主义)"
const TXT_OPT2 := "保持距离"
const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_R0 := "据投票结果显示，埃尔南·西莱斯和维克多·帕斯之间几乎打成平手。由于没有候选人在有效选票中获得绝对多数，在军方的压力下，国会选举埃尔南·西莱斯为共和国新总统，任期一年，下一次选举也将于次年6月举行。新政府由左派、社会自由派与中间派政党结成的不稳定的临时联盟组成，并由莉迪亚·盖勒担任政府首脑。为避免发生军事政变，临时政府被迫与军方合作，军费被维持在适当的水平，政府也对军方内部事务不加干涉。同时，对审查制度、艺术和学术界的适度自由化进程开始了，通过重订劳动法与引入社会立法，工人与妇女们的劳动权利所得到的保障也更为充分了。但这种不稳定的联盟基本不可能延续到下次选举后。"
const TXT_R1 := "据投票结果显示，埃尔南·西莱斯和维克多·帕斯之间几乎打成平手。由于没有候选人在有效选票中获得绝对多数，在军方的压力下，国会选举埃尔南·西莱斯为共和国新总统，任期一年，下一次选举也将于次年6月举行。新政府由保守派、自由派与中间派政党结成的不稳定的临时联盟组成，并由莉迪亚·盖勒担任政府首脑。为避免发生军事政变，临时政府被迫与军方合作，军费被维持在适当的水平，政府也对军方内部事务不加干涉。与此同时，适度的经济自由化也随之开始：裁撤官僚机构、放宽关税与贸易壁垒，修改税收法规、部分出售国有企业的少量股份并扩大其职权范围。改革的道路已然铺就。"
const TXT_R2 := "据投票结果显示，埃尔南·西莱斯和维克多·帕斯之间几乎打成平手。由于没有候选人在有效选票中获得绝对多数，国会试图由自己选出共和国的新总统，但在几轮投票后，没有候选人能在议员中获得绝对多数，因此，国会决定将总统职位移交给参议院议长担任，为期一年，而后者有义务在1980年组织新的选举。因此，胡安·佩雷达和前军政府的亲密伙伴，瓦尔特·格瓦拉被任命为总统。然而，他的统治只持续了3个月之久，纳图什·布什上校便发动了一场政变，指责瓦尔特·格瓦拉试图篡权夺力。不过，尽管纳图什·布什在街头为祸一方，却也激起了全体玻利维亚人民的抗议浪潮，纳图什辩解说，“他被不择手段的政客欺骗了”，这些政客向他保证，如果他推翻瓦尔特，他将得到各政党的支持，但他并没有如愿以偿。在同意任命莉迪亚·盖勒为总统后，这位失败的政变者便逃往海外。"

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
	var ev130 := int(ws.completed_event_ids.get("event_130", 0))
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if ev130 == 1:
				_add(W.I_BUDGET, -25)
				_add(W.I_AGENTS, -25)
				bolivia.level_of_instability -= 10
				bolivia.level_of_development += 5
				bolivia.set_tag("亲中", true)
				bolivia.sub_government = 4
				_leave_alliances(bolivia)
				context["result_text"] = TXT_R0 + _proprc_suffix(bolivia)
			else:
				bolivia.level_of_instability -= 15
				bolivia.set_tag("亲中", false)
				bolivia.sub_government = 8
				context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
		1:
			if ev130 == 0:
				_add(W.I_BUDGET, -25)
				_add(W.I_AGENTS, -25)
				bolivia.level_of_instability -= 20
				bolivia.level_of_development -= 5
				bolivia.set_tag("亲中", true)
				bolivia.sub_government = 5
				_leave_alliances(bolivia)
				context["result_text"] = TXT_R1 + _proprc_suffix(bolivia)
			else:
				bolivia.level_of_instability -= 15
				bolivia.set_tag("亲中", false)
				bolivia.sub_government = 8
				context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
		_:
			bolivia.level_of_instability -= 15
			bolivia.set_tag("亲中", false)
			bolivia.sub_government = 8
			context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
	bolivia.government = 3
	bolivia.next_election_year = 1980
	bolivia.next_election_month = 6
	bolivia.next_election_day = 29

