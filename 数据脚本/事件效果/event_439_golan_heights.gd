extends "res://数据脚本/event_script_base.gd"

## 原作 Event439.cs：戈兰高地问题（4选项）。
## 触发：无自动触发点（trigger_conditions=[]）。DiploButtonScript.cs:11392-11394 this_type==1001 手动 number_event=439；3655-3657 为外交按钮条件引用。
## 差异：influencePRC→ws.influence_prc；dev→development；Gosstroy/SubGosstroy→government/sub_government；
##   Torg→对华贸易、prosov→亲苏、proprc→亲中、Vyshi→亲美；puppetOf→puppet_of。




const TXT_R0_OK := "根据我们的方案，以色列承认该地主权归属于叙利亚，由双方共同组织一个自治委员会管理当地的居民。双方发表声明，宣布当地的语言与民族均平等。联合国部队正在撤出该地。双方对这个方案都很满意。"
const TXT_R0_FAIL := "双方拒绝我们解决戈兰高地问题的方案，并拒绝参与谈判。(需要任意除建立联邦的巴以谈判成功，中国影响力大于40；或中国/美国影响力大于50，以色列存在且没有变为法西斯主义，爆发了海湾战争且萨达姆失败)"
const TXT_R1_OK := "根据我们的方案，巴以联邦将戈兰高地归还给叙利亚，尽管这一方案引起了某些国家的不满。当地的犹太移民将被强制迁回他们的国家。叙利亚感谢我们对他们的帮助，并宣布将加强与我们的合作。"
const TXT_R1_FAIL := "双方拒绝我们解决戈兰高地问题的方案，并拒绝参与谈判。（需要巴以联邦成立，叙利亚为社会主义，中国影响力大于40）"
const TXT_R2_OK := "根据我们的方案，叙利亚承认了戈兰高地属于以色列，尽管这一方案引起了某些国家的不满。当地剩余的叙利亚居民正在陆续撤回叙利亚。以色列感谢我们对他们的帮助，并宣布将加强与我们的合作。"
const TXT_R2_FAIL := "双方拒绝我们解决戈兰高地问题的方案，并拒绝参与谈判。（需要黎巴嫩是以色列的傀儡）"
const TXT_R3 := "我们将下次再议。"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var israel := ws.get_country_by_legacy_index(37)
	var iraq := ws.get_country_by_legacy_index(14)
	var syria := ws.get_country_by_legacy_index(35)
	var lebanon := ws.get_country_by_legacy_index(93)
	var usa_power := 0
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		usa_power = ws.empires[EmpireData.USA].power
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var ok0 := ((d.palestine_status == 1 or d.palestine_status == 2) and ws.influence_prc >= 400) \
					or ((ws.influence_prc >= 500 or usa_power >= 500) and israel != null and israel.sub_government != GameConstants.SubGovernment.NEO_FASCIST \
					and iraq != null and iraq.development == 1)
			if ok0:
				ws.influence_prc += 100
				_add_relation(EmpireData.USA, -100)
				_add_relation(EmpireData.USSR, 100)
				_add_power(EmpireData.USA, -100)
				if syria != null:
					syria.set_tag("对华贸易", true)
					syria.set_tag("亲苏", false)
					syria.set_tag("亲中", true)
				if israel != null:
					israel.set_tag("亲美", false)
					israel.set_tag("对华贸易", true)
				context["result_text"] = TXT_R0_OK
			else:
				ws.influence_prc -= 50
				context["result_text"] = TXT_R0_FAIL
		1:
			var ok1 := d.palestine_status == 3 and syria != null and syria.government == GameConstants.Government.SOCIALIST and ws.influence_prc >= 400
			if ok1:
				ws.influence_prc += 100
				_add_relation(EmpireData.USA, -200)
				_add_relation(EmpireData.USSR, -100)
				_add_power(EmpireData.USA, -150)
				if syria != null:
					syria.set_tag("对华贸易", true)
					syria.set_tag("亲苏", false)
					syria.set_tag("亲中", true)
				context["result_text"] = TXT_R1_OK
			else:
				ws.influence_prc -= 50
				context["result_text"] = TXT_R1_FAIL
		2:
			var ok2 := lebanon != null and lebanon.puppet_of == 37
			if ok2:
				ws.influence_prc += 50
				_add_relation(EmpireData.USA, 150)
				_add_relation(EmpireData.USSR, -100)
				_add_power(EmpireData.USA, 150)
				_add_power(EmpireData.USSR, -100)
				if israel != null:
					israel.set_tag("对华贸易", true)
				context["result_text"] = TXT_R2_OK
			else:
				ws.influence_prc -= 50
				context["result_text"] = TXT_R2_FAIL
		3:
			context["result_text"] = TXT_R3




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
