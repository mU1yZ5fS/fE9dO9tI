extends "res://数据脚本/event_script_base.gd"

## 原作 Event520.cs：水下没有龙宫（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_TITLE := "水下没有龙宫"
const TXT_DESC := "最高领导人同志，如你所知，我国核潜艇已经步入了一个新阶段，一个从无到有的阶段。我们已经列装了三艘091型核潜艇和一艘092型核潜艇。虽然难以和美苏等国匹敌，但我们已经领先了周围绝大多数国家。问题在于：091的实力实在是难以和我们的预期匹配。该型艇配备6具533毫米鱼雷发射管，携带约20枚鱼雷，包括鱼-3、鱼-1和鱼-4等。也可携带36枚水雷。电子设备方面，包括多用途战斗数据和指挥系统、I波段搜索雷达、中频声纳和DUUX-5型低频声纳，并携带921-A型雷达预警系统。动力来自一台90兆瓦压水反应堆，只能做到在我国近海活动。而092因此，海军希望再批一组经费用来建造符合战略目标的战略核潜艇。它将会携带更多的潜射导弹，从而更好的达成我们三位一体核打击能力的目标。\n军事委员会正在期待您的意见……"
const TXT_OPT0 := "批准建造093型核潜艇"
const TXT_OPT1 := "开始着手研发094与巨浪-2"
const TXT_OPT2 := "有092我们就可以偷着乐了。"
const TXT_R0_A := "我们决定批准海军建造093核潜艇的方案。这将会为我们对抗苏联和美国提供帮助。经费主要用于研究如船壳、推进系统、静音设计、战斗系统、武器系统和反侦察设备等。观察家认为认为09III型核潜艇的静音水平据信依旧低于苏联1970年代中期建造的维克托III型核潜艇，但在电子设备达到美国洛杉矶级核动力攻击潜艇中期型号的水准，但经过军方长时间改良之后的09IIIA/B型核潜艇在水下噪音水平据信能够达到110分贝（距离1码），这已经相当于洛杉矶级改进型核潜艇基本型的水准。很明显，有的好让美帝忙活的了！"
const TXT_R1_A := "我们的野心震撼了整个世界，我们同时也开始了研究下一代核潜艇，目标是赶上美帝的俄亥俄级，甚至是苏联的台风级战略核潜艇。这对我们的技术提出了极大的考验。\n我们决定批准海军建造093核潜艇的方案。这将会为我们对抗苏联和美国提供帮助。经费主要用于研究如船壳、推进系统、静音设计、战斗系统、武器系统和反侦察设备等。观察家认为认为09III型核潜艇的静音水平据信依旧低于苏联1970年代中期建造的维克托III型核潜艇，但在电子设备达到美国洛杉矶级核动力攻击潜艇中期型号的水准，但经过军方长时间改良之后的09IIIA/B型核潜艇在水下噪音水平据信能够达到110分贝（距离1码），这已经相当于洛杉矶级改进型核潜艇基本型的水准。\n094型核潜艇与093型核潜艇都采用了水滴形船体，安装有四个水平舵。在外形特征上分析094型艇体与092型艇体有延续关系，艇体中段弹道导弹舱尺寸增大，可搭载中国巨浪-1A型潜射弹道导弹，并能接受装载更新的潜射导弹。据估计该艇的水面排水量为8000-9000吨，水下排水量达到11000吨（另说10000-12000吨），是我国所有潜艇中第一款突破万吨级大关的潜艇；。在装备该型艇后，中国人民解放军海军的海基核打击能力将会到很大的提升，并将淘汰老旧的09II型核潜艇。\n同时，中国航天正在研究巨浪-2型潜射导弹。这将为我们的潜艇提供可怕的威力。相当于一枚搭载在潜水艇中的东风4型固体燃料弹道导弹。射程约在7000km到8000km左右。\n美国佬和毛子们，快快挖个洞躲起来吧！你们的核威慑就要到头了！"
const TXT_R2_A := "092已经是一款足够先进的攻击型核潜艇了，我们只要能妥善运用即可。要是想要海基发射弹道导弹，那我们可以把导弹发射车装上货轮嘛，货轮我们有很多条的嘛！"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	_enable(opt[1], TXT_OPT1)
	_enable(opt[2], TXT_OPT2)

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
			ws.influence_prc += 30
			# 原版 string[] old_modify_desc = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc[num] += "<color=red>| 0 9 3 核 潜 艇 ：</color>| 军 力+2.0 ， 人 民 支 持 度+0.5 ， 美 苏 关 系-0.3 "；display-only / 修正文案由 Godot 静态维护，跳过。文本: |093核潜艇：|军力+2.0，人民支持度+0.5，美苏关系-0.3
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(150))
			_add(12, -(150))
			_add(22, 40)
			_add(1, 50)
			_add(3, 50)
			ws.influence_prc += 20
			# 原版 string[] old_modify_desc2 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num2 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc2[num2] += "<color=red>| 0 9 4 核 潜 艇 与 巨 浪 - 2 型 潜 射 导 弹  ：</color>| 军 力+4.0 ， 人 民 支 持 度+0.8 ， 美 苏 关 系-0.4 ， 预 算-0.5 "；display-only / 修正文案由 Godot 静态维护，跳过。文本: |094核潜艇与巨浪-2型潜射导弹：|军力+4.0，人民支持度+0.8，美苏关系-0.4，预算-0.5
		2:
			context["result_text"] = TXT_R2_A
			_add(8, -(70))
			_add(22, 80)
			_add(1, 100)
			_add(6, 5)
			_add(3, 100)
			_add(57, 50)
			ws.influence_prc += 50
			# 原版 string[] old_modify_desc3 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num3 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc3[num3] += "<color=red>| 0 9 2 核 潜 艇 ：</color>| 军 力+1.0 ， 人 民 支 持 度+1.0 ， 美 苏 关 系-0.2"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |092核潜艇：|军力+1.0，人民支持度+1.0，美苏关系-0.2

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
