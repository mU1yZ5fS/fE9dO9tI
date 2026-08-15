extends "res://数据脚本/event_script_base.gd"

## 原作 Event513.cs：我们未来的武器（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_TITLE := "我们未来的武器"
const TXT_DESC := "同志！最近的军事委员会会议上提出了要研发并改进我们军事装备的问题。我军仍然大量装备56式半自动步枪和56式冲锋枪等落后的武器，而六三式质量过于难以保障从而被拒绝。54式重机枪，69式火箭筒甚至不能做到大量列装。很明显，如果我们卷入大规模的战争，我们很难相信中国人民解放军有能力打赢。因此我们迫切的需要最新的武器装备。一部分的方案是继续模仿并改进苏联的军事装备，就如现在一样，我们可以仿制更为先进的AK-74和PKM通用机枪。另一个方案则是开始研制小口径武器。早在1970年，中央军委常规兵器工业领导小组第六次会议上就明确指出要研制一种初速大、重量轻、杀伤威力大的步枪。\n最高领导人同志，我们正在期待您的意见……"
const TXT_OPT0 := "我们可以“借鉴”苏联的装备"
const TXT_OPT0_DIS := "那么，钱从哪来？"
const TXT_OPT1 := "让我们着手研发自己的武器"
const TXT_OPT1_DIS := "自力更生是好事，但我们显然没有这个能力"
const TXT_OPT2 := "造不如买！"
const TXT_R0_A := "通过我们和伊拉克的秘密协议，我们从萨达姆手上拿到了大量AK-74自动步枪。在中国轻武器研究所的不懈努力下，76式自动步枪诞生了。相比AK-74，它更加耐保存，短导气管防止了火药燃气进入机闸的可能性。而且它的另一项优势便是它的简单，只需要三分钟，下至初中生，上至六旬老人，只要能拿得动这杆枪，都能学会拆解，组装和使用这把武器。很快这些武器就会取代老旧的56式冲锋枪，成为民兵和解放军士兵的主流武器。而相对应的PKM班用机枪也被引入我国，用于补齐我国缺少班用火力压制武器的空缺。小口径的自研武器还是再等等吧……"
const TXT_R1_A := "我们决定研制一款口径更小的自研轻武器来逐步取代现役装备。在中国国家兵工厂研究部的数位工程师和设计师热烈的讨论后，由朵英贤团队设计的QBZ-76自动步枪得到了一致好评。该枪看起来和传统苏式武器别无二样。但它采用了杀伤力更为巨大的5.8mm子弹，在打入伤口之后不会贯穿，而是在体内“爆”开。5.8mm子弹也防止了美国等西方国家缴获了我们的武器之后直接使用。工程塑料也创造性的在这件武器上得到了运用。很快这些武器就会投入量产，并在不久的将来取代56式自动步枪。而相对应的，带有弹鼓的机枪型号也在紧锣密鼓的研制中。"
const TXT_R2_A := "我们决定向超级大国购买武器以填补空缺，武器的问题得到了解决。苏联和美国的军工集团都感谢我们的订单。但未来的武器该怎么办？恐怕没人知道……"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	event_def.description = _leader_name() + TXT_DESC
	if ws.数值表[8] + ws.数值表[36] > 20:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.数值表[8] + ws.数值表[36] > 40:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(20))
			_add(22, 50)
			ws.influence_prc += 10
			_add_relation(1, -(50))
			# 原版 string[] old_modify_desc = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc[num] += "<color=red>| 仿 制 苏 械 ：</color>| 军 力+0.1"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |仿制苏械：|军力+0.1
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(40))
			ws.influence_prc += 15
			_add(22, 80)
			# 原版 string[] old_modify_desc2 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num2 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc2[num2] += "<color=red>| 自 研 军 械 ：</color>| 军 力+0.2"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |自研军械：|军力+0.2
		2:
			context["result_text"] = TXT_R2_A
			_add(8, -(5))
			_add(22, 20)

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
