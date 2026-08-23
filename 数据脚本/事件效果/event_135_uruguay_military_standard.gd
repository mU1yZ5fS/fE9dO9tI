extends "res://数据脚本/event_script_base.gd"

## 原作 Event135.cs：军事标准（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_PROPRC_YES := "[color=red]新政府决心和我们做朋友。[/color]"
const TXT_PROPRC_NO := "[color=red]新政府不想和我们做朋友。[/color]"
const TXT_R0 := "为了为新一轮多余的清洗做辩护，德米切利批准了1972年博达贝里政府制定的《国家发展计划》。这是一套实用主义的经济政策，旨在于技术官僚的领导下，对国家经济及其运作的基础进行彻底地重新规划。改革则是为了将对外贸易的生产结构、国民收入分配、市场需求与相对价格转化为广泛的经济自由化与对外开放的框架。在1973年至1985年间统治乌拉圭的文官或军政府之中，德米切利较为温和，哪怕他执政期间推行的措施被民主派支持者视为对反政府人士的压制，但在禁止前政治家从事政治活动的程度上，他并不同意其军方同行的意见。他编写的法学书籍多年来也一直是共和国大学法学系的教学与参考资料。"
const TXT_R1 := "1976年，阿帕里西奥·门德斯被国家委员会（一个由武装部队控制的机构）任命为共和国总统，他于9月1日其担任这一职位，并签署了《四号组织法》，该法规剥夺了15000名公民在15年内参政的权力。此外，甫一上任，他便颁布了一项法令，剥夺了所有政党领导人的政治权利。1980年，他举行了修改宪法并使现政府合法化的公民投票，但大多数选民投反对票。他是军方的提线木偶，在他统治期间，人权遭到践踏，数千人被逮捕与流放。军政府试图为正在发生的事披上一层合法性的外衣，并制定了一份宪法草案，但大多数人民对此持抵制态度。门德斯是行政法专家，也曾在大学从事法律教学工作。1934年至1955年，他任共和国大学行政法教授，但由于与学生会发生冲突而离开了大学，学生会指责他试图推广意大利的墨索里尼的法西斯政权。"




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0


## Country.WantToLeave() 逐行移植（GameState.cs:7370-7394）。
## 只调整亲中/对华贸易/亲美，不整体清空联盟。
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
		if _d(W.I_IDEOLOGY) < 2 or _d(W.I_ECON_SYSTEM) < 13 or _d(W.I_DIPLO) > 700 or _d(W.I_PARTY_SYSTEM) < 8 or _d(W.I_PRESS_POLICY) < 18 or (china != null and china.has_tag("ovd")):
			flag = false
	elif sub >= 7:
		var china2 := ws.get_country_by_legacy_index(1)
		if _d(W.I_IDEOLOGY) == 1 or _d(W.I_ECON_SYSTEM) <= 11 or _d(W.I_DIPLO) < 300 or (china2 != null and china2.has_tag("sev")):
			flag = false
	if c.has_tag("亲中"):
		c.set_tag("对华贸易", flag)
		c.set_tag("亲中", flag)
		if c.has_tag("亲美"):
			c.set_tag("亲美", not flag)


func _proprc_suffix(c: CountryData) -> String:
	return TXT_PROPRC_YES if c.has_tag("亲中") else TXT_PROPRC_NO

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var uruguay := ws.get_country_by_legacy_index(82)
	if uruguay == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			uruguay.next_election_year = 1980
			uruguay.next_election_month = 10
			uruguay.next_election_day = 12
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			uruguay.level_of_instability -= 10
			uruguay.level_of_development += 5
			uruguay.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
			uruguay.set_tag("亲中", true)
			_want_to_leave(uruguay)
			context["result_text"] = TXT_R0 + _proprc_suffix(uruguay)
		1:
			uruguay.next_election_year = 1981
			uruguay.next_election_month = 9
			uruguay.next_election_day = 1
			_add(W.I_BUDGET, -5)
			_add(W.I_AGENTS, -5)
			uruguay.level_of_instability -= 15
			uruguay.set_tag("对华贸易", true)
			_want_to_leave(uruguay)
			context["result_text"] = TXT_R1 + _proprc_suffix(uruguay)
		_:
			uruguay.next_election_year = 1981
			uruguay.next_election_month = 9
			uruguay.next_election_day = 1
			uruguay.level_of_instability -= 15
			context["result_text"] = TXT_R1 + _proprc_suffix(uruguay)

