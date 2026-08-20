extends "res://数据脚本/event_script_base.gd"

## 原作 Event518.cs：人民空军，勇敢去闯荡（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "我们的航空器技术还是不太行啊……"
const TXT_OPT1_DIS := "我们的航空器技术还是不太行啊……"
const TXT_OPT2_DIS := "我们的航空器技术还是不太行啊……"
const TXT_R0_A := "中央军事委员会决定研究J-18歼击机。该机型采取了不同以往的布局系统，采用了双发，鸭式气动布局的新格局。最新的航电系统允许其搭载超视距的霹雳10等空空导弹。隐形性能大概在0.0001左右，这已经是相当好的数据了。类似的系统将会被搭载在歼20上，预计在本世纪末之前完成理论实验和风洞测试。"
const TXT_R1_A := "中央军事委员会决定投资轰-15战略轰炸机。和过去轰炸机最大的不同便是其强大的隐身性能，代价便是其载弹量显著小于我们现役的任何一种战略轰炸机。不过我们只要能突破敌人的第一道防线，也算是达成战略目的了。配套的“井冈山”型精确制导炸弹和红鸟-4远程巡航导弹也在研发中。我们的“三位一体”核打击能力大大加强了。"
const TXT_R2_A := "中国空军正在向着超一流的水平发展，其中必不可少的便是全面研发先进航空器。\nJ-18歼击机项目上马了。该机型采取了不同以往的布局系统，采用了双发，鸭式气动布局的新格局。最新的航电系统允许其搭载超视距的霹雳10等空空导弹。隐形性能大概在0.0001左右，这已经是相当好的数据了。类似的系统将会被搭载在歼20上，预计在本世纪末之前完成理论实验和风洞测试。\n轰-15战略轰炸机也是个不可忽视的大项目。和过去轰炸机最大的不同便是其强大的隐身性能，代价便是其载弹量显著小于我们现役的任何一种战略轰炸机。不过我们只要能突破敌人的第一道防线，也算是达成战略目的了。配套的“井冈山”型精确制导炸弹和红鸟-4远程巡航导弹也在研发中。我们的“三位一体”核打击能力大大加强了。\n保卫领空，抵御侵略。迎着新世纪的曙光去飞翔，飞翔，飞翔！"
const TXT_R3_A := "现在的飞机已经足够对付外在的侵略了，我们可以在下次会议上讨论这个问题。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if int(ws.completed_event_ids.get("event_517", 0)) >= 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if int(ws.completed_event_ids.get("event_517", 0)) == 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(50))
			_add(22, 50)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 20
			# 原版 string[] old_modify_desc = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc[num] += "<color=red>| 隐 身 歼 击 机 ：</color>| 军 力+0.2 ， 人 民 支 持 度+0.2 ， 预 算-0.2 ， 干 预 点 数+1.0"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |隐身歼击机：|军力+0.2，人民支持度+0.2，预算-0.2，干预点数+1.0
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(50))
			_add(22, 50)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 30
			# 原版 string[] old_modify_desc2 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num2 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc2[num2] += "<color=red>| 隐 身 轰 炸 机 ：</color>| 军 力+0.3 ， 预 算-0.2 ，与 美 苏 关 系-0.1 ，干 预 点 数+1.0"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |隐身轰炸机：|军力+0.3，预算-0.2，与美苏关系-0.1，干预点数+1.0
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
			# 原版 old_modify_desc3[num3] += "<color=red>| 隐 身 歼 击 机 与 轰 炸 机 ：</color>| 军 力+0.8 ， 人 民 支 持 度+0.2 ， 预 算-0.3 ，与 美 苏 关 系-0.1 ， 干 预 点 数+2.0"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |隐身歼击机与轰炸机：|军力+0.8，人民支持度+0.2，预算-0.3，与美苏关系-0.1，干预点数+2.0
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
