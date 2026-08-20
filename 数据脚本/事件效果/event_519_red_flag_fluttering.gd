extends "res://数据脚本/event_script_base.gd"

## 原作 Event519.cs：红旗飘舞随风扬（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_DESC := "随着我国工业实力进一步加强。在中央军事委员会上，中国人民解放军海军大将肖劲光提出了应当加强我国海军的实力，以防止美苏，尤其是美军对我国领海的侵犯。此话不假，我国装备的“四大金刚”（即鞍山，抚顺，长春和太原号）实在过于老旧，早在中苏蜜月期就作为两国友好的象征来到了中国。这一待就是二十来年，但这批驱逐舰实在是难以保障我国海军的实力。20世纪60年代末至70年代初，该型号军舰均进行了现代化改装，拆除了原有2座三联装533mm鱼雷发射管，改装了两座双联装上游一号\u00a0(SY-1)反舰导弹发射装置，由火炮鱼雷驱逐舰改装成导弹驱逐舰，1969年5月至1970年2月“抚顺”舰率先进行改装，其余三艘舰在1970年至1974年改装。但相比苏联太平洋舰队来说还是差的太远。因此，肖劲光大将提出特别拨款用来建造一批新的导弹驱逐舰。这是一个很诱人的决定，不仅能为加强我国的海防力量。还能好好利用051型导弹驱逐舰给我们带来的教训。最高领导人同志，中央军委的同志们在等待您投上庄严一票……"
const TXT_R0_A := "现在，我们迫切的需要为战略导弹核潜艇从北方基地出海巡逻提供保护用的反潜护航舰艇；同时，中国海军的使命不再仅仅是守卫大陆近海，还需要深入远离大陆的海域，需要反潜能力较强的水面作战舰艇。西沙海战也暴露了我军海防的薄弱，甚至连越南都敢侵占我们的合法领土。且051型驱逐舰总体上而言没有整体提升自动化作战能力，不能适应远洋作战要求，防空系统也过于薄弱，再加之051型驱逐舰的整体设计已经落后。我们将开始研究052型导弹驱逐舰。他将会有更强大的火力和足够的导弹槽位，为将来我们的舰队走进海洋提供保障。\n而“四大金刚”将在不久之后光荣退役，他们会被改造为博物馆，成为旅顺，威海，连云港和青岛孩子最喜欢的消暑之地。"
const TXT_R1_A := "我们决定改造现有的051型，代号051-D型导弹驱逐舰。武备方面，最主要的改动是以双管37毫米舰炮代替了双管57毫米舰炮。显著增加了射速。而之前建造的051型舰，在后来的返厂维修中，拆除了双管57毫米舰炮，改装双管37毫米炮。除舰炮之外，051D型的改变有40多项，包括雷达系统，反潜电子指挥系统，无线电通讯系统，卫星导航系统和海上补给系统等。后改用“海鹰-1甲”反舰导弹，飞行高度降低到50米，采用频率捷变技术制导雷达，射程提高到95千米（51海里）。在未来的建造计划中打算加装冷气系统等设备用来改善舰员生活条件。至少我们有决心和周围国家的海军对对碰了。\n而“四大金刚”将在不久之后光荣退役，他们会被改造为博物馆，成为旅顺，威海，连云港和青岛孩子最喜欢的消暑之地。"
const TXT_R2_A := "我们决定进行这一项大胆的计划，同时改造和下水051与052导弹驱逐舰。\n现在，我们迫切的需要为战略导弹核潜艇从北方基地出海巡逻提供保护用的反潜护航舰艇；同时，中国海军的使命不再仅仅是守卫大陆近海，还需要深入远离大陆的海域，需要反潜能力较强的水面作战舰艇。西沙海战也暴露了我军海防的薄弱，甚至连越南都敢侵占我们的合法领土。且051型驱逐舰总体上而言没有整体提升自动化作战能力，不能适应远洋作战要求，防空系统也过于薄弱，再加之051型驱逐舰的整体设计已经落后。我们将开始研究052型导弹驱逐舰。他将会有更强大的火力和足够的导弹槽位，为将来我们的舰队走进海洋提供保障。\n同时，我们决定改造现有的051型，代号051-D型导弹驱逐舰。武备方面，最主要的改动是以双管37毫米舰炮代替了双管57毫米舰炮。显著增加了射速。而之前建造的051型舰，在后来的返厂维修中，拆除了双管57毫米舰炮，改装双管37毫米炮。除舰炮之外，051D型的改变有40多项，包括雷达系统，反潜电子指挥系统，无线电通讯系统，卫星导航系统和海上补给系统等。后改用“海鹰-1甲”反舰导弹，飞行高度降低到50米，采用频率捷变技术制导雷达，射程提高到95千米（51海里）。在未来的建造计划中打算加装冷气系统等硬件用来改善舰员生活条件。\n而“四大金刚”将在不久之后光荣退役，他们会被改造为博物馆，成为旅顺，威海，连云港和青岛孩子最喜欢的消暑之地。\n我们的海军正在以前所未有的速度发展。向前进！用我们的战舰守护每一片海洋！"
const TXT_R3_A := "很明显，只要我们有足够优秀的导弹，就能做到“乱拳打死老师父”。美国和苏联的舰队再庞大，也不过两发反舰导弹，如果还是没有效果，那就多来几发！"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	_enable(opt[2], event_def.options[2].text)
	_enable(opt[3], event_def.options[3].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(80))
			_add(12, -(80))
			_add(22, 50)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 30
			# 原版 string[] old_modify_desc = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc[num] += "<color=red>| 新 型 导 弹 驱 逐 舰  ：</color>| 军 力+1.8 ， 人 民 支 持 度+0.5 ， 预 算-0.4"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |新型导弹驱逐舰：|军力+1.8，人民支持度+0.5，预算-0.4
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(50))
			_add(12, -(50))
			_add(22, 40)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 20
			# 原版 string[] old_modify_desc2 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num2 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc2[num2] += "<color=red>| 改 造 导 弹 驱 逐 舰  ：</color>| 军 力+1.5 ， 人 民 支 持 度+0.2 ，预 算-0.3 "；display-only / 修正文案由 Godot 静态维护，跳过。文本: |改造导弹驱逐舰：|军力+1.5，人民支持度+0.2，预算-0.3
		2:
			context["result_text"] = TXT_R2_A
			_add(8, -(100))
			_add(12, -(100))
			_add(22, 100)
			_add(1, 100)
			_add(6, 5)
			_add(3, 100)
			_add(57, 50)
			ws.influence_prc += 50
			# 原版 string[] old_modify_desc3 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num3 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc3[num3] += "<color=red>| 改 造 与 新 型 导 弹 驱 逐 舰  ：</color>| 军 力+3.5 ， 人 民 支 持 度+1.0 ， 预 算-0.5"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |改造与新型导弹驱逐舰：|军力+3.5，人民支持度+1.0，预算-0.5
		3:
			context["result_text"] = TXT_R3_A
			_add(1, -(80))
			_add(22, 80)

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
	if china.government == GameConstants.Government.AUTHORITARIAN:
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
	elif china.government == GameConstants.Government.SOCIALIST:
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
	elif china.government == GameConstants.Government.REFORMIST:
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
	elif china.government != GameConstants.Government.LIBERAL:
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
