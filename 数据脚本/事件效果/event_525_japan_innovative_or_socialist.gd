extends "res://数据脚本/event_script_base.gd"

## 原作 Event525.cs：革新政权还是社会主义？（3选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "和修正主义和解？你也想开修了？"
const TXT_OPT1_DIS := "左派的社会实践太多了！"
const TXT_R0_A := "我们很快与佐佐木派、改革派等大小派系建立了联系（江田三郎与佐佐木更三都曾多次访华，这让我们的介入更加顺利），并参与到它们的矛盾调解中。\n不久在社会党的中央会议上，社会主义协会遭到其他各派别联合起来的猛烈攻击，最终不得不“承认自身错误”并同意展开自我整肃。社会党长期的左派优位体制终于得到了改变。而另一方面，在我们的斡旋下，原先改革派的激进主张也得到了修改。现在的社会党开始与英国工党对标，开始向民主社会主义进行转型。但需要指出的是，该党并未完全切断与科学社会主义的联系，《日本通向社会主义之路》的党纲也在一定程度上得到了保留。且社会主义协会依旧掌握着大量的基层活动家。\n无论如何，社会党的内部危机暂时得到了解决。数月后的党大会上，社会党正式宣布解散派阀。公明党与民主社会党对社会党的改变表示欢迎，并宣布将根据社会党的新情况对自身的纲领路线也展开调整。就这样，联合政权更加稳固了。"
const TXT_R1_A := "我们选择支持社会主义协会。尽管该派别所坚持的并非真正的马克思列宁主义，但支持它总比支持伯恩施坦路线要好，对吧？\n不久在社会党的中央会议上，社会主义协会遭到各派系的猛烈攻击。但凭借着对社会党中基层组织与相关青年活跃组织的强有力掌控，该派系还是挺过了这次攻击。而江田三郎本人更是被几个激进的社会主义协会成员骂道：“老东西，去死吧。”这也宣布了各派之间的彻底决裂。不久改革派成员宣布退出社会党，并筹划组建社会民主联合。而社会主义协会借此机会对党内其他派系进行了进一步打击，巩固了自身的地位。同时在我们的帮助下，协会派扩大了基层组织，开始进一步深入工会、农村之中。\n社会主义协会的举措遭到了党内外的许多责难，特别是当江田三郎这位社会党老党员在退党不久就因肺癌去世后。为了稳住局面，社会主义协会一方面进行了一定让步，同意展开自我整肃。另一方面也强调这是维护“革命路线”的无奈之举。为了更好地发挥力量，数月后的党大会上，社会党正式宣布解散派阀。同时在左派的支持下，成田知巳继续担任社会党的书记长。\n公明党和民主社会党对社会党的内部纷争感到失望，联合政府的不稳定因素有所增加。但相对的，我们对社会党的影响力也得到了增强。且地位愈发巩固的社会党左派已经准备好在今后的选举中进一步动员劳工阶层以实现其目标了。"
const TXT_R2_A := "我们与社会党内部的各个派系均取得了联系，希望他们能互相妥协并提出了一份方案。但由于他们在关键问题上的互不让步，谈判最终不了了之。\n不久在社会党的中央会议上，社会主义协会遭到各派系的猛烈攻击。但凭借着对社会党中基层组织与相关青年活跃组织的强有力掌控，该派系还是挺过了这次攻击。而江田三郎本人更是被几个激进的社会主义协会成员骂道：“老东西，去死吧。”这也宣布了各派之间的彻底决裂。不久改革派成员宣布退出社会党，并筹划组建社会民主联合。\n社会主义协会的行为遭到了党内外的一致谴责，特别是当江田三郎这位社会党老党员在退党不久就因肺癌去世后。为了稳住局面，社会主义协会不得不有所退让，同意展开自我整肃。同时一直支持社会主义协会的书记长成田知巳也饱受质疑，最终他宣布辞职。曾任横滨市市长的飞鸟田一雄接替了他的位置。\n公明党和民主社会党对社会党的内部纷争感到失望，一些人已经开始尝试探索与自由民主党建立联系的尝试，而这个联合政府也愈发摇摇欲坠了。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if ws.数值表[56] > 0 and ws.数值表[56] < 3:
		_enable(opt[0], event_def.options[0].text)
	elif ws.数值表[56] == 0:
		_disable(opt[0], "和修正主义和解？你也想开修了？")
	else:
		_disable(opt[0], "和一群死不接受民主观念的人合作？")
	if ws.数值表[56] < 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			_add(8, -(80))
			_add(9, -(80))
			_add(1, 50)
			_add(3, 50)
			_add(6, -(10))
			_add_relation(0, 50)
		1:
			context["result_text"] = TXT_R1_A
			_add(8, -(80))
			_add(9, -(80))
			_add(1, 50)
			_add(3, 50)
			_add(6, 10)
			_add_relation(0, -(50))
			ws.influence_prc += 10
		2:
			context["result_text"] = TXT_R2_A

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
