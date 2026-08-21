extends "res://数据脚本/event_script_base.gd"

## 原作 Event386.cs：为了乍得人的乍得（一选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_R0 := "五国组建了一支统一调度的武装部队，代号“乍得湖”的行动一触即发。联军同东南西北四个方向攻入了乍得，喀麦隆人民军迅速开入了恩贾梅纳，在该国国内的乍得团结与社会主义行动以及FROLINAT残存的马克思主义派系的帮助下顺利击溃了乍得南北的两个政府，并号召全体人民起义，开展人民革命。而法国和美国拒绝武装介入这一问题，仅仅对这一事件表达了“强烈谴责”。\n乍得人民联邦共和国成立了，乍得\t团结与社会主义行动吸收了FROLINAT的马克思主义派系，并邀请来自前非洲社会主义运动-乍得的反殖民主义领袖艾哈迈德·库拉马拉加入，该党正式成为了该国的领导力量，总书记菲德勒·蒙加尔成为了该国的新领导人。随后，在特别法庭上，哈布雷被宣判犯有战争罪、反人类罪、强奸罪、性侵罪、故意杀人罪、叛国罪和种族灭绝罪而被判处死刑。新政府宣布要继承易卜拉欣·阿巴查的遗志，以马克思列宁主义为指导，建立各民族完全平等的社会主义和泛非主义新乍得。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	_add(143, 1)  # 原版 data.oil_price
	var chad := ws.get_country_by_legacy_index(57)
	var war80 := ws.wars[80] if ws.wars.size() > 80 else null
	if war80 != null:
		war80.is_going = false
	if chad != null:
		if chad.parts.size() < 1:
			chad.parts.resize(1)
		chad.parts[0] = false
		chad.government = GameConstants.Government.SOCIALIST
		chad.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
		_leave_alliances(chad)
		chad.set_tag("对华贸易", true)
		chad.set_tag("亲中", true)
		_join_alliances(chad)
	context["result_text"] = TXT_R0



func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)


