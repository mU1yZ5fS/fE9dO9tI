extends "res://数据脚本/event_script_base.gd"

## 原作 Event521.cs：840工程（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_TITLE := "840工程"
const TXT_DESC := "同志，如你所知，建造一支强大的蓝水海军一直是我国的梦想。而现在，这个梦想在我们强大的工业水平下得以实现。但是，在开香槟前还有一个重要的问题。我们的舰队未来的方向应该是什么？大多数军事委员会的成员建议我们研发像苏联那样的导弹巡洋舰，类比比我们曾经提出过的055方案，建造一款大型远洋导弹驱逐舰，抑或是追赶英法，建造航母。这每一项都将花费不少资金，但对于一支强大的水军来说，这没有什么难的。"
const TXT_OPT0 := "进行055型导弹驱逐舰的研发"
const TXT_OPT1 := "进行航母的研发"
const TXT_OPT2 := "英国人做不到的事，我们可以！"
const TXT_OPT3 := "我们押宝于长期计划"
const TXT_R0_A := "我们在大量的手稿中找出了055型驱逐舰的设计草图，尽管已经过去了数十年，但其理念仍然不输时代。很快，就有眼尖的摄影爱好者在上海的长兴岛发现了一款巨大的“货轮”建造设施。很快就传来了激动的消息，055已经完成了下水。采用全燃动力、射频综合集成及舰载通用垂直发射系统，由中国人民解放军海军701研究所设计、江南造船厂103基地与大连船舶812工厂承建。055型导弹驱逐舰是全亚洲，乃至全世界都排得上号的大型水面舰艇。此型舰的服役标志着中国驱逐舰已经跻身于全球先进军舰的行列，055型导弹驱逐舰亦有充足的空间进行动力与武器的升级，如高空反导系统，激光近防炮设施，电磁动力炮和超远程雷达等大型装备的升级正在逐步推进。首舰则被命名为“上海号”，用于纪念上海对于这艘船和共和国的独特地位。\n美国观察家指出，若美国海军进一步节约经费用去买可乐，就要连中国佬的海军都比不过了。"
const TXT_R1_A := "我们开始尝试常规动力航母的研发，这是个困难的事情，因为这是个从无到有的过程。在借鉴了美国的“福莱斯特”号，"
const TXT_R1_B := "“圣伊丽莎白”号"
const TXT_R1_C := "“共和号”"
const TXT_R1_D := "的经验之后，一个初步的方案得到了通过。这艘航母采用大量新设计、新材料，工程量巨大，建造总量超过20艘超大型油轮工程量总和。3000多个舱室，上万个零部件，上万台套各种设备遍布全船，许多特种装置属首次研制和安装，施工难度巨大。我们在这艘航母上搭载了（我国）最先进的蒸汽弹射系统，专门为海军研制的重型歼击机J-13I也得以列装。而核动力的版本与电磁弹射仍然在慢慢的摸索之中。\n其次，在航母上还首次实现了社区化管理。所谓社区化管理就是航母内部分成不同的功能单元，平时每个单元各司其职，各就其位，不相互串岗，只有在吃饭和集体活动时才会聚集在一起，这样做的好处就是提升了工作效率。江苏舰配置了内部即时通讯系统和个人移动通讯终端，如果有工作需要也可以随时进行联系，这也是我国电子工业进步的体现。\n在1984年4月23日，人民海军35周年之时，舷号10的中国首艘航母“江苏”完成了下水，"
const TXT_R1_E := ""
const TXT_R1_F := "同志也观摩了这一伟大的时刻。下一艘代号广东的航母也在计划中，预计会装有电弹射系统从而获得更大的推力。"
const TXT_R2_A := "我们在大量的手稿中找出了055型驱逐舰的设计草图，尽管已经过去了数十年，但其理念仍然不输时代。很快，就有眼尖的摄影爱好者在上海的长兴岛发现了一款巨大的“货轮”建造设施。很快就传来了激动的消息，055已经完成了下水。采用全燃动力、射频综合集成及舰载通用垂直发射系统，由中国人民解放军海军701研究所设计、江南造船厂103基地与大连船舶812工厂承建。055型导弹驱逐舰是全亚洲，乃至全世界都排得上号的大型水面舰艇。此型舰的服役标志着中国驱逐舰已经跻身于全球先进军舰的行列，055型导弹驱逐舰亦有充足的空间进行动力与武器的升级，如高空反导系统，激光近防炮设施，电磁动力炮和超远程雷达等大型装备的升级正在逐步推进。首舰则被命名为“上海号”，用于纪念上海对于这艘船和共和国的独特地位。\n我们开始尝试常规动力航母的研发，这是个困难的事情，因为这是个从无到有的过程。在借鉴了美国的“福莱斯特”号，"
const TXT_R2_B := "“圣伊丽莎白”号"
const TXT_R2_C := "“共和号”"
const TXT_R2_D := "的经验之后，一个初步的方案得到了通过。这艘航母采用大量新设计、新材料，工程量巨大，建造总量超过20艘超大型油轮工程量总和。3000多个舱室，上万个零部件，上万台套各种设备遍布全船，许多特种装置属首次研制和安装，施工难度巨大。我们在这艘航母上搭载了（我国）最先进的蒸汽弹射系统，专门为海军研制的重型歼击机J-13I也得以列装。而核动力的版本与电磁弹射仍然在慢慢的摸索之中。\n其次，在航母上还首次实现了社区化管理。所谓社区化管理就是航母内部分成不同的功能单元，平时每个单元各司其职，各就其位，不相互串岗，只有在吃饭和集体活动时才会聚集在一起，这样做的好处就是提升了工作效率。江苏舰配置了内部即时通讯系统和个人移动通讯终端，如果有工作需要也可以随时进行联系，这也是我国电子工业进步的体现。下一艘代号广东的航母也在计划中，预计会装有电弹射系统从而获得更大的推力。\n在1984年4月23日，人民海军35周年之时，舷号10的中国首艘航母“江苏”完成了下水实验，一并下水的还有055型导弹驱逐舰。"
const TXT_R2_E := ""
const TXT_R2_F := "同志也观摩了这一伟大的时刻。谁敢来侵犯我们，我们就叫他们灭亡！"
const TXT_R3_A := "现在的舰船，我想也够了。未来是导弹的时代，而不是把游艇开出去当靶子的。但一系列宏伟的计划仍然得到了资金，我们预计在本世纪末可以和法国与英国的海军扳手腕，不过超过美国则仍然是一个遥远的梦想……"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	event_def.description = _leader_name() + TXT_DESC
	_enable(opt[0], TXT_OPT0)
	_enable(opt[1], TXT_OPT1)
	_enable(opt[2], TXT_OPT2)
	_enable(opt[3], TXT_OPT3)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(100))
			_add(12, -(100))
			_add(22, 50)
			_add(1, 50)
			_add(3, 50)
			_add(6, 5)
			ws.influence_prc += 50
			# 原版 string[] old_modify_desc = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc[num] += "<color=red>| 导 弹 驱 逐 舰 ：</color>| 军 力+3.0 ， 人 民 支 持 度+1.0 ， 影 响 力+0.5 "；display-only / 修正文案由 Godot 静态维护，跳过。文本: |导弹驱逐舰：|军力+3.0，人民支持度+1.0，影响力+0.5
		1:
			context["result_text"] = TXT_R1_A
			if _cf(92, "Gosstroy") == 0  or  _cf(92, "Gosstroy") == 3:
				context["result_text"] += TXT_R1_B
			else:
				context["result_text"] += TXT_R1_C
			context["result_text"] += TXT_R1_D
			context["result_text"] += _leader_name()
			context["result_text"] += TXT_R1_F
			_add(8, -(120))
			_add(12, -(120))
			_add(22, 80)
			_add(1, 100)
			_add(3, 100)
			_add(6, 8)
			ws.influence_prc += 80
			# 原版 string[] old_modify_desc2 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num2 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc2[num2] += "<color=red>| 航 空 母 舰 ：</color>| 军 力+3.0 ， 干 涉 点 数+2.0 ， 人 民 支 持 度+1.0 ， 影 响 力+0.5 ， 军 武 支 援 效 果+1"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |航空母舰：|军力+3.0，干涉点数+2.0，人民支持度+1.0，影响力+0.5，军武支援效果+1
		2:
			context["result_text"] = TXT_R2_A
			if _cf(92, "Gosstroy") == 0  or  _cf(92, "Gosstroy") == 3:
				context["result_text"] += TXT_R2_B
			else:
				context["result_text"] += TXT_R2_C
			context["result_text"] += TXT_R2_D
			context["result_text"] += _leader_name()
			context["result_text"] += TXT_R2_F
			_add(8, -(150))
			_add(12, -(150))
			_add(22, 150)
			_add(1, 150)
			_add(3, 150)
			_add(6, 10)
			_add(57, 50)
			ws.influence_prc += 100
			# 原版 string[] old_modify_desc3 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num3 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc3[num3] += "<color=red>| 导 弹 驱 逐 舰 与 航 空 母 舰 ：</color>| 军 力+5.0 ， 人 民 支 持 度+2.5 ， 干 涉 点 数+3.0 ， 影 响 力+1.0 ， 军 武 支 援 效 果+2"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |导弹驱逐舰与航空母舰：|军力+5.0，人民支持度+2.5，干涉点数+3.0，影响力+1.0，军武支援效果+2
		3:
			context["result_text"] = TXT_R3_A
			_add(8, -(30))
			_add(22, 30)
			_add(1, 50)
			_add(6, 5)
			_add(3, 50)
			_add(57, 50)
			ws.influence_prc += 50

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
