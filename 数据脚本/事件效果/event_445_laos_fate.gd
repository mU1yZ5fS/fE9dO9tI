extends "res://数据脚本/event_script_base.gd"

## 原作 Event445.cs：老挝的命运（2选项）。
## 触发：无自动触发点（trigger_conditions=[]）。DiploButtonScript.cs:9260-9264 this_type==35 手动 number_event=445。
## 差异：stab→stab（CountryData.stab）；isSEV→sev、prosov→亲苏、proprc→亲中；prcpower→prc_power。




const TXT_R0 := "在我们和越南的施压下，凯山·丰威汉承认在过去他的政策“有重大的失误”后辞去了老挝人民革命党总书记和政府总理的的职务，仅保留了政治局委员职务。苏发努冯被选为新的老挝人民革命党总书记和政府总理，富米·冯维希当选为新的老挝国家主席和最高人民议会主席。老挝新领导层同我们和越南重新签订了合作协议。原本老挝政府中大量的越南顾问撤回了越南国内；同时，我们给老挝发放了大批无息贷款，转让了一批工业设施，他们的社会主义经济正在稳步发展。"
const TXT_R1 := "有了越南，我们已经在中南半岛有了立足之地，所以我们可以先把目光放在别处，暂时不管老挝的事......"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var china := ws.get_country_by_legacy_index(1)
	var laos := ws.get_country_by_legacy_index(22)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.influence_prc += 10
			_add(W.I_AGENTS, -30)
			if laos != null:
				laos.stab = 1
				laos.puppet_of = -1
				laos.set_tag("sev", false)
				laos.set_tag("亲苏", false)
				laos.set_tag("亲中", true)
				if china != null:
					laos.government = china.government
					laos.sub_government = china.sub_government
				laos.prc_power = 1000
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1


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


func _disable_blank(opt: EventOption) -> void:
	opt.text = ""
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)
