extends "res://数据脚本/event_script_base.gd"

## 原作 Event443.cs：收复藏南！（1选项）。
## 触发：无自动触发点（trigger_conditions=[]）。TimeScript.cs:2866-2875 中印战争（war==2）胜利分支手动 number_event=443。
## 差异：CBIndia→ws.set_flag("cb_india", false)。




const TXT_R0 := "在解放军的猛烈攻势下，印度军队终究没能守得住战线，开始溃退。解放军在挺进到地图上的国境线后便不再有大规模军事行动，而是开通新的稳定补给路线。印度东北部地区则出现了大规模的叛乱，印度因此忙于平叛，无暇顾及藏南地区。由于这次印军的失利，该届印度政府垮台，新一届的印度政府开始进一步反华，更加亲美亲苏，与美苏订立了更多的军事订单，可能会在中印边境开展新一轮的边境冲突......"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(EmpireData.USSR, -150)
			_add_power(EmpireData.USSR, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_PARTY_SUPPORT, 100)
			ws.influence_prc += 10
			ws.set_flag("cb_india", false)
			# 藏南/阿鲁纳恰尔地块（map_regions.json region 43）归中国 710：
			# 对应原版 ILoveSuckCocks() 的 parts 重绘（data.arunachal_status>=2 分支），
			# 战争胜利已由月度结算转移过一次，此处幂等补执行（读档后覆盖仍在）。
			if GameManager != null:
				GameManager.set_map_region_owner([43], 710)
			context["result_text"] = TXT_R0




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
