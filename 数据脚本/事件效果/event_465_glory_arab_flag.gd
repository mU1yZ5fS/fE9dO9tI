extends "res://数据脚本/event_script_base.gd"

## 原作 Event465.cs：荣耀归你，阿拉伯之旗（单选项）。
## 触发：GlobalScript.cs:40 的 Decision 链 StartEvent(465)（决议系统移植说明）。
##   按项目约定 trigger_conditions=[]（仅定义，待决策系统接入）。
## 差异：parts[0] 写前 resize；oar/isOVD/isSEV/okb/econ/Torg/prosov/Vyshi/proprc→set_tag。

const TXT_TITLE := "荣耀归你，阿拉伯之旗"
const TXT_DESC := "多亏了我们的帮助，阿拉伯国家之间的合作越发紧密。泛阿拉伯主义从近乎无法实现的幻想，变成了现实。在最近的阿拉伯社会主义同盟代表大会上，阿拉伯共和国联邦主席阿里·萨布里宣布将“把阿拉伯共和国联邦转化为中东地区革命的堡垒，一劳永逸驱逐帝国主义者的干涉”。而我们在中东地区的布局也来到了最为关键的一步——组建一个统一的阿拉伯共和国，这将会对世界革命事业和第三世界的独立献上最好的祝福。"
const TXT_OPT0 := "为我们的国际主义同志们敬一杯！"
const TXT_R0 := "很快，利比亚，叙利亚，伊拉克等阿拉伯共和国联邦成员国齐聚开罗。各地的复兴党，民族解放阵线和革命党就组建一个联邦性质的国家达成了共识：邦联将改组为阿拉伯联合共和国。新生的联邦性政权将会组由阿拉伯革命委员会建统一调度的军队和警察机构，阿拉伯革命委员会大部分成员由各成员国的高层担任，地方保持较高的自治；完善货币体系，就调整各地的发展情况，进行统制经济，对沙特，阿曼等尚未加入联邦的地区进行宣称并宣布未来会进行一系列行动来收复失地。当联邦的成员遭到外界侵犯的时候，将被视为对全体联邦各国的侵犯。当联邦成员无法妥善处理自身危机时，联邦当局有权采取果决的干涉行动。对内将加大学术性的交流，并就敏感话题进行商讨，例如首都问题，对其他阿拉伯国家的态度，以及客观上东西发展的不均衡。|外界对此的态度不同，第三世界国家普遍将其视为一个令人振奋的决定。这是第一次在中东出现了具有支配地位的地区性强国，这无疑会为中东的乱象画上休止符。华盛顿对此的评价是“令人担忧的颠覆性霸权”“潜在的火药桶”。新政权由于具有阿拉伯和非洲国家的双面性，阿拉伯联盟和非洲统一组织仍然接纳其为成员。联合国也在考虑是否要将其与澳大利亚纳入新的联合国常任理事国体系。也有传言称，新生的阿拉伯联合共和国正在谋求加入核俱乐部。|和上次失败的尝试不同，这次阿拉伯各国团结一心。泛阿拉伯主义的旗帜将会在中东世界的上空飘扬，直到永远……对吧？"


func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(W.I_DIPLO, 50)
			ws.influence_prc += 100
			_add_relation(EmpireData.USA, -200)
			var morocco := _country(54)
			if morocco != null:
				_set_part(morocco, 0, true)
			_tag(30, "亲中", false)
			for idx in [18, 54, 55]:
				var c := _country(idx)
				if c == null:
					continue
				c.set_tag("亲苏", false)
				c.set_tag("亲美", false)
				c.set_tag("亲中", false)
				c.set_tag("sev", false)
				c.set_tag("ovd", false)
				c.set_tag("okb", false)
				c.set_tag("econ", false)
				c.set_tag("对华贸易", false)
				c.set_tag("oar", false)



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _set_relation(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(value, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

func _set_power(empire_index: int, value: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power = value

func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

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

