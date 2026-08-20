extends "res://数据脚本/event_script_base.gd"

## 原作 Event510.cs：黄金海岸的再革命？——第二幕（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "我们党内还有几个左派？"
const TXT_OPT1_DIS := "我们不是帝国主义者！"
const TXT_R0_A := "我们向加纳派出了大使并援助了他们一批用以解决经济困难的物资，罗林斯回忆到恩克鲁玛时代我国与加纳的深厚友谊，对我们表示感谢，我们同加纳签订了贸易协定。目前，加纳的局势正在向好。"
const TXT_R0_B := "我们继续为加纳提供了大批援助，作为交换，他将为我们提供廉价可可，并为我们在加纳开采黄金和勘探石油提供最大的帮助，我们将为加纳提供农业专家、工业设施和武器。全非人民革命党宣布将准备“非洲的人民战争”，为全非的联合与解放做出最大努力。加纳同几内亚、坦桑尼亚等非洲社会主义国家建立了深入的联系。西方的帝国主义者对“另一个恩克鲁玛的回归”并不高兴。"
const TXT_R1_A := "加纳再度左转将可能加强苏东阵营的力量投射，我们应该阻止这种事情的发生！我们秘密通知了美国。不久，来自邻国科特迪瓦和多哥的雇佣军便在中情局的帮助下攻破了阿克拉，加纳政府猝不及防，没有组织起像样的抵抗。左翼政府被推翻，新的军政府成立了。"
const TXT_R1_B := "加纳的情报机构发现了来自科特迪瓦和多哥方向的异动。他们宣布全国进入战时状态，并在边界和首都加强了防御，同时向苏联请求援助。最后，加纳政府粉碎了政变阴谋，宣布与美国和我们断绝关系并倒向苏联。"
const TXT_R2_A := "罗林斯继续实施他那将社会主义、民族主义和民粹主义混合起来的理念，他积极与古巴和利比亚展开合作，并接待了德西·鲍特瑟（苏里南）、丹尼尔·奥尔特加（桑解阵）和萨姆·乔努马（纳米比亚）等“革命者”的访问。西方的帝国主义者对罗林斯的政府并不高兴。这样的一个进步政权究竟能在非洲坚持多久？"
const TXT_R2_B := "罗林斯与卡迈克尔的革命政权致力于科学社会主义下的泛非主义，新政府与我们开展合作，并同几内亚、坦桑尼亚等非洲社会主义国家建立了深入的联系。西方的帝国主义者对“另一个恩克鲁玛的回归”并不高兴。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.数值表[56] < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.数值表[56] > 1 and _cf(51, "dev") == 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c63 := ws.get_country_by_legacy_index(63)
	match opt:
		0:
			if int(ws.completed_event_ids.get("event_509", 0)) != 2:
				context["result_text"] = TXT_R0_A
			else:
				context["result_text"] = TXT_R0_B
			if int(ws.completed_event_ids.get("event_509", 0)) != 2:
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.government = 0
				if c63 != null: c63.sub_government = 10
				if c63 != null: c63.set_tag("对华贸易", true)
				_add(8, -(50))
			else:
				_add(8, -(50))
				_add(22, -(50))
				if c63 != null: c63.government = 0
				if c63 != null: c63.sub_government = 0
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.set_tag("亲中", true)
				if c63 != null: c63.set_tag("对华贸易", true)
		1:
			if ws.empires[0].relations >= 500:
				context["result_text"] = TXT_R1_A
			else:
				context["result_text"] = TXT_R1_B
			_add(9, -(50))
			if ws.empires[0].relations >= 500:
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.government = 0
				if c63 != null: c63.sub_government = 7
				if c63 != null: c63.set_tag("亲美", true)
				if c63 != null: c63.set_tag("对华贸易", true)
			else:
				if c63 != null: c63.government = 0
				if c63 != null: c63.sub_government = 10
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.set_tag("亲苏", true)
				if c63 != null: c63.set_tag("对华贸易", false)
		2:
			if int(ws.completed_event_ids.get("event_509", 0)) != 2:
				context["result_text"] = TXT_R2_A
			else:
				context["result_text"] = TXT_R2_B
			if int(ws.completed_event_ids.get("event_509", 0)) != 2:
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.government = 0
				if c63 != null: c63.sub_government = 10
				return
			if c63 != null: c63.government = 0
			if c63 != null: c63.sub_government = 0
			if c63 != null: _leave_alliances(c63)
			if c63 != null: c63.set_tag("对华贸易", true)

func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _office_name(pos: int) -> String:
	if ws != null and ws.politics_positions.size() > pos:
		var pi: int = ws.politics_positions[pos]
		if pi >= 0 and pi < ws.politicians.size():
			var p: PoliticianData = ws.politicians[pi]
			if p != null and p.name_display != "":
				return p.name_display
	return "华国锋"


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() 		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == 0:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data[W.I_PARTY_SYSTEM] == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data[W.I_IDEOLOGY] <= 2 and data[W.I_ECON_SYSTEM] < 13 				and data[W.I_DIPLO] >= 700 and data[W.I_PARTY_SYSTEM] < 8 				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data[W.I_ECON_SYSTEM] >= 13 and data[W.I_WAR_SUPPORT] >= 700 and not _mod_active(6)) 				or _mod_active(38):
			result = 9
		elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_WAR_SUPPORT] >= 700 				and data[W.I_DIPLO] >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data[W.I_ECON_SYSTEM] >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == 1:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data[W.I_PARTY_SYSTEM] <= 7 				and data[W.I_ECON_SYSTEM] <= 12 and data[W.I_RELIGION] <= 25:
			result = 17
		elif data[W.I_IDEOLOGY] == 1 and not _mod_active(6) and data[W.I_RELIGION] <= 26:
			result = 16
		elif data[W.I_ECON_SYSTEM] < 13 and data[W.I_PRESS_POLICY] >= 17 				and data[W.I_IDEOLOGY] == 1 and data[W.I_RELIGION] <= 26:
			result = 2
		else:
			result = 1
	elif china.government == 2:
		if _mod_active(40):
			result = 8
		elif data[W.I_IDEOLOGY] >= 2 and data[W.I_ECON_SYSTEM] >= 13 				and data[W.I_DIPLO] <= 700 and data[W.I_PARTY_SYSTEM] >= 8 				and data[W.I_PRESS_POLICY] >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] >= 12 				and data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 300 				and data[W.I_TERRITORY] > 21 and data[W.I_WAR_SUPPORT] >= 700:
			result = 11
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 14 				and data[W.I_DIPLO] >= 500 and data[W.I_ECON_SYSTEM] > 11 				and data[W.I_WAR_SUPPORT] >= 400:
			result = 8
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 13 				and data[W.I_PRESS_POLICY] > 17:
			result = 3
		elif data[W.I_PARTY_SYSTEM] <= 8 				and (data[W.I_ECON_SYSTEM] == 13 or data[W.I_ECON_SYSTEM] == 12) 				and data[W.I_WAR_SUPPORT] < 700 and not _mod_active(3) 				and data[W.I_PRESS_POLICY] >= 17:
			result = 21
		else:
			result = 15
	elif china.government != 3:
		result = 13
	elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 500:
		result = 4
	elif (data[W.I_PARTY_SYSTEM] <= 8 and data[W.I_PRESS_POLICY] <= 18) 			or data[W.I_WAR_SUPPORT] >= 700:
		result = 12
	elif data[W.I_ECON_SYSTEM] > 13 and data[W.I_DIPLO] < 700:
		result = 6
	else:
		result = 5
	return result


func _tech(idx: int) -> bool:
	return ws != null and ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _mod(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx].is_active


func _empire_rel(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].relations
	return 0


func _empire_power(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func _cf(idx: int, field: String) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return 0
	match field:
		"Gosstroy": return c.government
		"SubGosstroy": return c.sub_government
		"dev": return c.development
		"spec": return c.special
		"soc_stab": return c.social_stability
		"stab": return c.stab
		"puppetOf": return c.puppet_of
		"prcpower": return c.prc_power
		"prcinfl": return c.prc_influence
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)
