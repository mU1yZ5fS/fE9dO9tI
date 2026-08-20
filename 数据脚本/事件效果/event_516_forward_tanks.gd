extends "res://数据脚本/event_script_base.gd"

## 原作 Event516.cs：前进，坦克！（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_DESC_VIETNAM := "主席同志，随着中越战争的结束，我们不得不意识到一件事情，我们的坦克：仿制于T-54A的59式坦克实在是过于老旧，而独立研发的69式坦克在战争的表现虽然说不上是糟糕，也可以说是在面对反坦克武器时毫无招架之力，若是用这般的武器很难保证在未来战场上的优势。我们的坦克急需现代化，但问题是：从哪个方面？包头一机的方案为替换原有的火控系统和火炮，换装79型105毫米滑膛炮将会大大提高战斗力；也有人觉得应该借鉴在“二四会战”中的坦克样车，以122工程为蓝本，从而从根本上改进我国坦克；也有少部分人认为应当借助我们和西方国家的关系而购入新坦克。无论如何，中央军事委员会仍然在等待您的意见。"
const TXT_DESC_IRAN_IRAQ := "主席同志，随着两伊战争的结束，我们不得不意识到一件事情，我们的坦克：仿制于T-54A的59式坦克实在是过于老旧，而独立研发的69式坦克在战争的表现虽然说不上是糟糕，也可以说是在面对反坦克武器时毫无招架之力，若是用这般的武器很难保证在未来战场上的优势。我们的坦克急需现代化，但问题是：从哪个方面？包头一机的方案为替换原有的火控系统和火炮，换装79型105毫米滑膛炮将会大大提高战斗力；也有人觉得应该借鉴在“二四会战”中的坦克样车，以122工程为蓝本，从而从根本上改进我国坦克；也有少部分人认为应当借助我们和西方国家的关系而购入新坦克。无论如何，中央军事委员会仍然在等待您的意见。"
const TXT_DESC_KOREA := "主席同志，随着对朝鲜作战的结束，我们不得不意识到一件事情，我们的坦克：仿制于T-54A的59式坦克实在是过于老旧，而独立研发的69式坦克在战争的表现虽然说不上是糟糕，也可以说是在面对反坦克武器时毫无招架之力，若是用这般的武器很难保证在未来战场上的优势。我们的坦克急需现代化，但问题是：从哪个方面？包头一机的方案为替换原有的火控系统和火炮，换装79型105毫米滑膛炮将会大大提高战斗力；也有人觉得应该借鉴在“二四会战”中的坦克样车，以122工程为蓝本，从而从根本上改进我国坦克；也有少部分人认为应当借助我们和西方国家的关系而购入新坦克。无论如何，中央军事委员会仍然在等待您的意见。"
const TXT_DESC_KOREA2 := "主席同志，随着第二次朝鲜战争的结束，我们不得不意识到一件事情，我们的坦克：仿制于T-54A的59式坦克实在是过于老旧，而独立研发的69式坦克在战争的表现虽然说不上是糟糕，也可以说是在面对反坦克武器时毫无招架之力，若是用这般的武器很难保证在未来战场上的优势。我们的坦克急需现代化，但问题是：从哪个方面？包头一机的方案为替换原有的火控系统和火炮，换装79型105毫米滑膛炮将会大大提高战斗力；也有人觉得应该借鉴在“二四会战”中的坦克样车，以122工程为蓝本，从而从根本上改进我国坦克；也有少部分人认为应当借助我们和西方国家的关系而购入新坦克。无论如何，中央军事委员会仍然在等待您的意见。"
const TXT_R0_A := "在您的指令下，代号1037的坦克改进工程开始了。以现有坦克的底盘，我们在其中安装了国产的105毫米滑膛炮，而在内部则有更多改进。我们安装了最新的通讯电台和电子夜视仪，同时列装了最新的自动灭火抑爆和三防系统，以及高压气瓶，用于清洁潜望镜。很快，一部分部队就开始列装这种新型59坦克，在未来，59式将被其完全取代。"
const TXT_R1_A := "我们决定在122工程的基础上，彻底与苏联的传统设计做割裂。在底盘上，我们决定采用自主研发的六负重轮底盘，换装了扭矩和马力更为强大的发动机，相应的，空间略有缩小。而在主炮的选择上，我们选用了120毫米滑膛炮，而非传统的105毫米。同时安装了烟雾弹发射装置和裙甲，以及可隐藏的探照灯与伪装用天线。最后则是在装甲和内部的全面升级：我们采用的新式反应装甲吸足了战争中的经验，至少面对现在的大部分反坦克武器是绰绰有余的；而内部则开创性的使用了自动装弹机和三防系统，夜视仪等装备也进一步升级，最重要的则是安装了空调降温系统，并可以采用炮射导弹。在不久的将来，这辆样车就能完成万公里测试，从而投入量产阶段。"
const TXT_R2_A := "我们决定采购其他国家的主战坦克，法国和联邦德国均愿意向我们出售。德国甚至决定和我们签订豹-2的购买与生产合同，无论如何，问题还是解决了，但是这能持续多久呢？迟早有一天，我们会兵戎相见……"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	# 原版 TextOfEvents 按战争结束情况四选一；这里在显示前动态改写。
	if _is_war_done(1) and ws.completed_event_ids.has("event_56") and not ws.get_flag("vietnampeace"):
		event_def.description = TXT_DESC_VIETNAM
	elif _is_war_done(3) and ws.completed_event_ids.has("event_73"):
		event_def.description = TXT_DESC_IRAN_IRAQ
	elif ws.completed_event_ids.has("event_378") and int(ws.completed_event_ids.get("event_378", 0)) == 2 and _is_war_done(16):
		event_def.description = TXT_DESC_KOREA
	elif _cf(10, "dev") == 1 and _is_war_done(0):
		event_def.description = TXT_DESC_KOREA2
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	_enable(opt[2], event_def.options[2].text)

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
			# 原版 old_modify_desc[num] += "<color=red>| 改 进 坦 克 ：</color>| 军 力+0.3 ， 预 算-0.1"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |改进坦克：|军力+0.3，预算-0.1
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(80))
			_add(22, 80)
			_add(1, 80)
			_add(6, 5)
			_add(3, 100)
			_add(57, 50)
			ws.influence_prc += 50
			# 原版 string[] old_modify_desc2 = GlobalScript.inst.old_modify_desc；display-only / 修正文案由 Godot 静态维护，跳过。文本: 
			# 原版 int num2 = 50；old_modify_desc 辅助变量，跳过
			# 原版 old_modify_desc2[num2] += "<color=red>| 自 研 坦 克 ：</color>| 军 力+0.6 ， 预 算-0.2 ， 凝 聚 力+0.2"；display-only / 修正文案由 Godot 静态维护，跳过。文本: |自研坦克：|军力+0.6，预算-0.2，凝聚力+0.2
		2:
			context["result_text"] = TXT_R2_A
			_add(8, -(20))
			_add(22, 30)
			_add(6, -(15))

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

## 原版 ReqEventForDLC02.cs:167-169 的四战争条件。
func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var done56 := world.completed_event_ids.has("event_56")
	var done73 := world.completed_event_ids.has("event_73")
	var done378 := world.completed_event_ids.has("event_378")
	var c10 := world.get_country_by_legacy_index(10)
	var c10_dev1 := c10 != null and c10.development == 1
	var w1 := world.wars.size() > 1 and world.wars[1] != null and not world.wars[1].is_going
	var w3 := world.wars.size() > 3 and world.wars[3] != null and not world.wars[3].is_going
	var w16 := world.wars.size() > 16 and world.wars[16] != null and not world.wars[16].is_going
	var w0 := world.wars.size() > 0 and world.wars[0] != null and not world.wars[0].is_going
	return (w1 and done56 and not world.get_flag("vietnampeace")) \
		or (w3 and done73) \
		or (done378 and int(world.completed_event_ids.get("event_378", 0)) == 2 and w16) \
		or (c10_dev1 and w0)



func _is_war_done(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.wars.size() and ws.wars[idx] != null and not ws.wars[idx].is_going
