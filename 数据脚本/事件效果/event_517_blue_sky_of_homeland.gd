extends "res://数据脚本/event_script_base.gd"

## 原作 Event517.cs：我爱祖国的蓝天（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_TITLE := "我爱祖国的蓝天"
const TXT_DESC := "最高领导人同志，正如你所知，1964年航空研究院就提出了要在米格-21基础上研制高空高速歼击机。1965年5月17日，罗瑞卿同志就批准新歼的战技指标和研制任务，并正式命名为歼-8。由沈阳飞机设计研究所承担具体任务。1968年7月，首批2架歼-8总装完毕。1969年7月5日，原型机由尹玉焕驾驶首飞成功。但是由于未能满足创立之初的目标：超视距空战而长期被搁置。随着我们技术的进一步提升，列装这类飞机已变为可能。但问题也在于此，美国空军早在1976年就开始列装更为先进的F-15战斗机，如果我们想要和他们做好竞争的准备，应该现在就研发更好更新的歼击机。同时，空军也在抱怨强-5过于老旧，而轰-六又是个十足的油老虎，应当对这些机型进行改进。这肯定会是项漫长的工程，无论如何，中央军事委员会希望听听您的意见。"
const TXT_OPT0 := "我们应当开始研发新的歼击机"
const TXT_OPT0_DIS := "我们的工业水平不支持我们做这些"
const TXT_OPT1 := "别忘了研发轰炸机！"
const TXT_OPT1_DIS := "我们的工业水平不支持我们做这些"
const TXT_OPT2 := "我全都要！"
const TXT_OPT2_DIS := "我们的工业水平不支持我们做这些"
const TXT_OPT3 := "用我们现在的就够了。"
const TXT_R0_A := "在中央军事委员会的特别会议上，会议决定开始研发新型的第三代战斗机，假想敌为美军的F-15和苏联的mig-29战斗机。中国航空研究院606所紧锣密鼓的为其研制了涡扇-10型轮扇发动机和配套的全权数字发动机控制系统。能提供惊人的89.17千牛顿力。更大的弹仓和更快的速度决定了它的优势。该型飞机被命名为歼10。在不久的将来，也许会彻底取代歼8在中国人民解放军空军中的地位，但这都是后话了。"
const TXT_R0_B := "可惜的是，我们尊敬的"
const TXT_R0_C := ""
const TXT_R0_D := "同志因为身高原因不能够亲自试着驾驶而只能作为乘客体验这架飞机，试飞过程中他一言不发，看上去好像很不高兴。"
const TXT_R0_E := "令人意外的是，"
const TXT_R0_F := ""
const TXT_R0_G := "同志也试着驾驶了这架飞机，“太快了！”是他唯一的评语。"
const TXT_R1_A := "在中央军事委员会的特别会议上，会议决定要研究更新更好的战略轰炸机和战术轰炸机用来满足战略目标。早在七十年代早期就有了关于研发高速战术轰炸机的计划。该类飞机要具有良好的飞行性能、在现代防空兵器对抗下有较强的战场生存能力、在战术战役纵深内完成轰炸任务，达到欧洲“龙卷风”式战斗轰炸机的性能，不仅要能投掷常规航空炸弹，还要能发射制导武器与战术核武器。对此，南昌制造厂的强-6型歼击轰炸机赢得了竞标。而西安603研究所的轰10型超音速战略轰炸机得到了军委的青睐。早在上个十年西安军工厂就提出了一款取代轰-6的新设计方案，这个设计案也获得我国空军指战员的大力支持。设计案的需求为航程至少5000公里，高空速率最少2马赫，低空穿透速率至少1马赫，载弹量20公吨，并且能够在刚刚整备完成的前进机场操作。这个方案得到了我们的倾力支持，配套的空射导弹系统也被提上了日程。"
const TXT_R2_A := "在中央军事委员会的特别会议上，会议决定开始全面升级空中力量，谋求赶上苏联，争取和美国的差距不超过五年。新式战斗机的假想敌为美军的F-15和苏联的mig-29战斗机。中国航空研究院606所紧锣密鼓的为其研制了涡扇-10型轮扇发动机和配套的全权数字发动机控制系统。能提供惊人的89.17千牛顿力。更大的弹仓和更快的速度决定了它的优势。该型飞机被命名为歼10。在不久的将来，也许会彻底取代歼8在中国人民解放军空军中的地位，但这都是后话了。\n早在七十年代早期就有了关于研发高速战术轰炸机的计划。该类飞机要具有良好的飞行性能、在现代防空兵器对抗下有较强的战场生存能力、在战术战役纵深内完成轰炸任务，达到欧洲“龙卷风”式战斗轰炸机的性能，不仅要能投掷常规航空炸弹，还要能发射制导武器与战术核武器。对此，南昌制造厂的强-6型歼击轰炸机赢得了竞标。而西安603研究所的轰10型超音速战略轰炸机得到了军委的青睐。早在上个十年西安军工厂就提出了一款取代轰-6的新设计方案，这个设计案也获得我国空军指战员的大力支持。设计案的需求为航程至少5000公里，高空速率最少2马赫，低空穿透速率至少1马赫，载弹量20公吨，并且能够在刚刚整备完成的前进机场操作。这个方案得到了我们的倾力支持，配套的空射导弹系统也被提上了日程。"
const TXT_R3_A := "我们有歼八就够了，大不了再研究些空空导弹就行了嘛！"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if ws.数值表[12] >= 600:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.数值表[12] >= 600:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if ws.数值表[12] >= 800:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0_A
			if ws.leader != null and ws.leader.name_first == 13 and ws.leader.name_last == 13:
				text += TXT_R0_B + _leader_name() + TXT_R0_D
			else:
				text += TXT_R0_E + _leader_name() + TXT_R0_G
			context["result_text"] = text
			_add(8, -(50))
			_add(22, 50)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 20
			# 原版 string[] old_modify_desc = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc[num] += "<color=red>| 新 式 歼 击 机 ：</color>| 军 力+0.3 ， 人 民 支 持 度+0.2 ， 预 算-0.2 ， 军 武 援 助 效 果+1"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |新式歼击机：|军力+0.3，人民支持度+0.2，预算-0.2，军武援助效果+1
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(50))
			_add(22, 50)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 30
			# 原版 string[] old_modify_desc2 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num2 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc2[num2] += "<color=red>| 新 式 轰 炸 机 ：</color>| 军 力+0.5 ， 预 算-0.2 ，与 美 苏 关 系-0.2 ， 军 武 援 助 效 果+1"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |新式轰炸机：|军力+0.5，预算-0.2，与美苏关系-0.2，军武援助效果+1
		2:
			context["result_text"] = TXT_R2_A
			_add(8, -(80))
			_add(22, 80)
			_add(1, 100)
			_add(6, 5)
			_add(3, 100)
			_add(57, 50)
			ws.influence_prc += 50
			# 原版 string[] old_modify_desc3 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num3 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc3[num3] += "<color=red>| 新 式 歼 击 机 与 轰 炸 机 ：</color>| 军 力+1.0 ， 人 民 支 持 度+0.2 ， 预 算-0.3 ，与 美 苏 关 系-0.2 ， 军 武 援 助 效 果+2"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |新式歼击机与轰炸机：|军力+1.0，人民支持度+0.2，预算-0.3，与美苏关系-0.2，军武援助效果+2
		3:
			context["result_text"] = TXT_R3_A

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
