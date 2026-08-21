extends "res://数据脚本/event_script_base.gd"

## 原作 Event131.cs：又一次，又一次，又一次（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_R0 := "据投票结果显示，埃尔南·西莱斯和维克多·帕斯之间几乎打成平手。由于没有候选人在有效选票中获得绝对多数，在军方的压力下，国会选举埃尔南·西莱斯为共和国新总统，任期一年，下一次选举也将于次年6月举行。新政府由左派、社会自由派与中间派政党结成的不稳定的临时联盟组成，并由莉迪亚·盖勒担任政府首脑。为避免发生军事政变，临时政府被迫与军方合作，军费被维持在适当的水平，政府也对军方内部事务不加干涉。同时，对审查制度、艺术和学术界的适度自由化进程开始了，通过重订劳动法与引入社会立法，工人与妇女们的劳动权利所得到的保障也更为充分了。但这种不稳定的联盟基本不可能延续到下次选举后。"
const TXT_R1 := "据投票结果显示，埃尔南·西莱斯和维克多·帕斯之间几乎打成平手。由于没有候选人在有效选票中获得绝对多数，在军方的压力下，国会选举埃尔南·西莱斯为共和国新总统，任期一年，下一次选举也将于次年6月举行。新政府由保守派、自由派与中间派政党结成的不稳定的临时联盟组成，并由莉迪亚·盖勒担任政府首脑。为避免发生军事政变，临时政府被迫与军方合作，军费被维持在适当的水平，政府也对军方内部事务不加干涉。与此同时，适度的经济自由化也随之开始：裁撤官僚机构、放宽关税与贸易壁垒，修改税收法规、部分出售国有企业的少量股份并扩大其职权范围。改革的道路已然铺就。"
const TXT_R2 := "据投票结果显示，埃尔南·西莱斯和维克多·帕斯之间几乎打成平手。由于没有候选人在有效选票中获得绝对多数，国会试图由自己选出共和国的新总统，但在几轮投票后，没有候选人能在议员中获得绝对多数，因此，国会决定将总统职位移交给参议院议长担任，为期一年，而后者有义务在1980年组织新的选举。因此，胡安·佩雷达和前军政府的亲密伙伴，瓦尔特·格瓦拉被任命为总统。然而，他的统治只持续了3个月之久，纳图什·布什上校便发动了一场政变，指责瓦尔特·格瓦拉试图篡权夺力。不过，尽管纳图什·布什在街头为祸一方，却也激起了全体玻利维亚人民的抗议浪潮，纳图什辩解说，“他被不择手段的政客欺骗了”，这些政客向他保证，如果他推翻瓦尔特，他将得到各政党的支持，但他并没有如愿以偿。在同意任命莉迪亚·盖勒为总统后，这位失败的政变者便逃往海外。"




func _proprc_suffix(c: CountryData) -> String:
	return TXT_PROPRC_YES if c.has_tag("亲中") else TXT_PROPRC_NO


func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0


## Country.WantToLeave() 逐行移植（GameState.cs:7370-7394）。
## 原版 Event131 在设 proprc=true 后调 WantToLeave，而不是 LeaveAlliances；
## 之前误用 _leave_alliances 会把刚设置的亲中/对华贸易一锅清掉，导致“帮西莱斯也不亲华”。
func _want_to_leave(c: CountryData) -> void:
	if c == null:
		return
	var flag := true
	var sub := c.sub_government
	if sub == 0:
		if _d(W.I_IDEOLOGY) > 2 or _d(W.I_ECON_SYSTEM) >= 13 or _d(W.I_DIPLO) < 700 or _d(W.I_PARTY_SYSTEM) >= 8:
			flag = false
	elif (sub >= 1 and sub <= 3) or sub == 8 or sub == 17:
		if _d(W.I_IDEOLOGY) > 3 or _d(W.I_ECON_SYSTEM) > 13 or _d(W.I_DIPLO) < 500:
			flag = false
	elif sub >= 4 and sub <= 6:
		var china := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) < 2 or _d(W.I_ECON_SYSTEM) < 13 or _d(W.I_DIPLO) > 700 \
				or _d(W.I_PARTY_SYSTEM) < 8 or _d(W.I_PRESS_POLICY) < 18 \
				or (china != null and china.has_tag("ovd")):
			flag = false
	elif sub >= 7:
		var china2 := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) == 1 or _d(W.I_ECON_SYSTEM) <= 11 or _d(W.I_DIPLO) < 300 \
				or (china2 != null and china2.has_tag("sev")):
			flag = false
	if c.has_tag("亲中"):
		c.set_tag("对华贸易", flag)
		c.set_tag("亲中", flag)
		if c.has_tag("亲美"):
			c.set_tag("亲美", not flag)


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
				bolivia.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				_want_to_leave(bolivia)
				context["result_text"] = TXT_R0 + _proprc_suffix(bolivia)
			else:
				bolivia.level_of_instability -= 15
				bolivia.set_tag("亲中", false)
				bolivia.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
		1:
			if ev130 == 0:
				_add(W.I_BUDGET, -25)
				_add(W.I_AGENTS, -25)
				bolivia.level_of_instability -= 20
				bolivia.level_of_development -= 5
				bolivia.set_tag("亲中", true)
				bolivia.sub_government = GameConstants.SubGovernment.MODERATE
				_want_to_leave(bolivia)
				context["result_text"] = TXT_R1 + _proprc_suffix(bolivia)
			else:
				bolivia.level_of_instability -= 15
				bolivia.set_tag("亲中", false)
				bolivia.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
				context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
		_:
			bolivia.level_of_instability -= 15
			bolivia.set_tag("亲中", false)
			bolivia.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
			context["result_text"] = TXT_R2 + _proprc_suffix(bolivia)
	bolivia.government = GameConstants.Government.LIBERAL
	bolivia.next_election_year = 1980
	bolivia.next_election_month = 6
	bolivia.next_election_day = 29

