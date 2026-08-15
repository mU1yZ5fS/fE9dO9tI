extends "res://数据脚本/event_script_base.gd"

## 原作 Event509.cs：黄金海岸的再革命？——第一幕（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_TITLE := "黄金海岸的再革命？——第一幕"
const TXT_DESC := "在1966年恩克鲁玛被推翻后，加纳迎来的是一系列不同政治集团的内斗，腐败的军政府和软弱的文官政府交替执政。作为国家经济支撑的可可、黄金产业产量不断走低，官员腐败、黑市横行，导致加纳经济大幅衰退，加纳人用Kalabule（指普遍的官商勾结和腐败、诈骗与囤积居奇）这个词描述国家的状态。伊朗革命带来的石油危机使得该国经济危机进一步加剧，无计可施的阿库福军政府不得不承诺开展选举。\n1979年5月15日，空军中尉杰里·罗林斯与一群年轻军官发起了一场针对军政府的未遂政变，尽管政变失败，但是罗林斯对军政府的指责受到加纳民众和少壮派军人的广泛欢迎。6月4日晚，被营救出狱的罗林斯再次发起了一场政变，成功推翻军政府。新成立的武装部队革命委员会具有强烈的左翼反帝色彩，在国家被整肃完毕后，它将把政权交给大选获胜的政党和文官政府。罗林斯主持清清洗了大量造成Kalabule的官员和投机商，并对掌控经济命脉的印度人和黎巴嫩人的公司进行了国有化，没收了投机者屯聚在秘密仓库中的大量货物。\n9月24日，罗林斯将权力交给了大选获胜的由希拉·利曼博士领导的号称是恩克鲁玛主义的人民民族党。利曼总统宣布实施混合经济，要将加纳建设成社会主义的“福利国家”。希拉·利曼总统将主动交权的少壮派军人集团视作潜在的反对派，并将罗林斯视为最大的隐患。他先后将前武装部队革命委员会的重要成员派遣到国外，使他们与加纳政治脱离直接的接触。11月27日，罗林斯被利曼解除军职，并被勒令从武装部队退役，被任命为有职无权的国务委员会委员。\n与此同时，利曼的文官政府无力继续处理Kalabule问题，经济状况反而在继续恶化，食品的生产、出口量、矿产开采仍在下降，基础设施年久失修，财政混乱，腐败和犯罪并未得到遏制。在这种情况下，罗林斯似乎在为新的“革命”做出准备，加纳仍在酝酿着下一次危机。也许我们能在其中插上一脚，拿回我们曾失去的东西？"
const TXT_OPT0 := "让我们帮恩克鲁玛的“传人”——希拉·利曼博士一把"
const TXT_OPT0_DIS := "我们不会帮助修正主义者！"
const TXT_OPT1 := "利用危机，帮助英美利用科特迪瓦和多哥的雇佣军推翻左翼政府"
const TXT_OPT1_DIS := "为什么要这么做？"
const TXT_OPT2 := "在几内亚同志的帮助下，让恩克鲁玛的好学生卡迈克尔和罗林斯联合起来！"
const TXT_OPT2_DIS := "我们无从下手"
const TXT_OPT3 := "我们没有必要做看不到结果的投资"
const TXT_R0_A := "为了帮助加纳解决经济问题，我们决定向加纳提供一笔无息贷款，并派出顾问团为利曼总统提供帮助。而他也抓住了中国这个救命稻草，决定背靠中国来巩固以他为首的文官政府的统治。作为交换，他也为我们在加纳开采黄金和勘探石油提供了最大的帮助，我们的投资的涌入为加纳经济注入了活力，利曼也决定继续进行一定的国有化和福利建设。在我们的帮助下，加纳第三共和国正在稳定下来，并成功安抚了不满的年轻军官。虽然利曼博士比起恩克鲁玛而言，更像是个打着他旗号的非洲民主社会主义者，不过对于我们而言，能抓到老鼠的就是好猫，不是吗？"
const TXT_R1_A := "加纳再度左转将可能加强苏东阵营的力量投射，我们应该阻止这种事情的发生！我们秘密通知了美国。不久，来自邻国科特迪瓦和多哥的雇佣军便在中情局的帮助下攻破了阿克拉，加纳政府猝不及防，没有组织起像样的抵抗。左翼政府被推翻，新的军政府成立了。"
const TXT_R1_B := "加纳的情报机构发现了来自科特迪瓦和多哥方向的异动。他们宣布全国进入战时状态，并在边界和首都加强了防御，同时向苏联请求援助。最后，加纳政府粉碎了政变阴谋，宣布与美国和我们断绝关系并倒向苏联。"
const TXT_R2_A := "斯托克利·卡迈克尔，另一个名字是夸梅·杜尔，是一位泛非主义者和共产主义者，曾领导美国的黑人解放运动，并参与了黑豹党。1969年，他来到了几内亚，成为了塞古·杜尔的助手和恩克鲁玛的学生。他加入了几内亚民主党，并致力于“将恩克鲁玛带回加纳”。卡迈克尔与恩克鲁玛一起创建了全非人民革命党，该组织是恩克鲁玛晚年思想的实践组织。\n我们为罗林斯和全非人民革命党提供了活动资金，杜尔总统、卡迈克尔和我们的外交人员与罗林斯进行了一番深入交流，他决定与卡迈克尔联合起来，实现不同于利曼的真正的恩克鲁玛主义。之后，罗林斯和他的同志们便在几内亚秘密进行军事训练，并谋划着下一场革命，以终结Kalabule。"
const TXT_R3_A := "我们什么都没做。在被开除军职后，罗林斯就秘密前往利比亚接受军事训练。利曼的文官政府和Kalabule一样，仍继续存在着。只是在民间，不满的民众和下野的年轻军官又会在这片土地擦出什么火花呢？"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if ws.数值表[56] != 0 and ws.数值表[56] != 4:
		_enable(opt[0], TXT_OPT0)
	elif ws.数值表[56] == 4:
		_disable(opt[0], "我们不会帮助左派")
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.数值表[56] > 1 and _cf(51, "dev") == 1:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if ws.数值表[56] <= 1 and ws.completed_event_ids.has("event_505") and int(ws.completed_event_ids.get("event_505", 0)) == 0:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c63 := ws.get_country_by_legacy_index(63)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(50))
			ws.influence_prc += 20
			_add_relation(0, -(50))
			if c63 != null: c63.government = 2
			if c63 != null: c63.sub_government = 3
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
				if c63 != null: c63.government = 2
				if c63 != null: c63.sub_government = 3
				if c63 != null: _leave_alliances(c63)
				if c63 != null: c63.set_tag("亲苏", true)
				if c63 != null: c63.set_tag("对华贸易", false)
		2:
			context["result_text"] = TXT_R2_A
			_add(8, -(60))
			_add(9, -(60))
			_add(22, -(60))
			if c63 != null: c63.government = 2
			if c63 != null: c63.sub_government = 3
			if c63 != null: _leave_alliances(c63)
			if c63 != null: c63.内战中 = true
		3:
			context["result_text"] = TXT_R3_A
			if c63 != null: c63.government = 2
			if c63 != null: c63.sub_government = 3
			if c63 != null: _leave_alliances(c63)

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
