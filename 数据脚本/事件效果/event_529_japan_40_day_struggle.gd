extends "res://数据脚本/event_script_base.gd"

## 原作 Event529.cs：四十日抗争（2选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "没人对他们有兴趣"
const TXT_R0_A := "在难以弥合内部派系矛盾的情况下，我们所能做的就是确保各个在野党不会借此机会联合起来统一提名一位新的候选人以扰乱首相指名选举。因此我们迅速派出大批人员秘密前往东京，通过放出假消息、制造小型事故、泄露材料等方式扰乱在野党的注意力，使得它们无法完全团结一致。同时自由民主党内部的亲华派也开始四处走动，凭借他们的影响力劝住了一批摇摆派议员（为了防止有人与社会党等在野党私下串联，一些人不惜把个别立场十分不坚定的议员骗到酒店房间然后反锁屋子，直到投票即将开始的时候才放他们出来）。\n11月6日，国会正式举行内阁总理大臣指名选举。众议院第一轮投票中，大平和福田在第一轮投票（大平135票，福田125票）中顺利通过进入第二轮，在野党都投了自己政党的党首。虽然在第一轮投票中，福田的得票稍微落后，但是他寄望于和他关系不错的民主社会党会投票支持，不过其在第二轮投票中和其他在野党一样退席弃权；而大平和田中则早就策反了一些反主流派的议员，导致福田、三木、中曾根三派都有议员投票支持大平，连福田派的长老园田直也支持大平；此外，大平还从第一轮投票起就获得了关键小党新自由俱乐部的支持。\n最终结果是大平获得138票，福田获得121票，大平正芳得以继续担任首相。反主流派的倒大平运动失败。不久我们便收到了大平本人的亲笔信，感谢我们对他和对党的帮助。而亲华派也成功超越了自由民主党内的其他势力成为最大派阀。在他们的操纵下，自由民主党与美国的关系愈发疏远，与我们的关系更近了。不久，日本政府便就更改《日美安保条约》问题与美国开始谈判，最终签署了一份新协议。根据协议内容，驻日美军将在未来五年内分批次撤出日本。"
const TXT_R1_A := "11月6日，国会正式举行内阁总理大臣指名选举。众议院第一轮投票中，大平和福田在第一轮投票（大平135票，福田125票）中顺利通过进入第二轮，在野党都投了自己政党的党首。虽然在第一轮投票中，福田的得票稍微落后，但是他寄望于和他关系不错的民主社会党会投票支持，不过其在第二轮投票中和其他在野党一样退席弃权；而大平和田中则早就策反了一些反主流派的议员，导致福田、三木、中曾根三派都有议员投票支持大平，连福田派的长老园田直也支持大平；此外，大平还从第一轮投票起就获得了关键小党新自由俱乐部的支持。\n最终结果是大平获得138票，福田获得121票，大平正芳得以继续担任首相。反主流派的倒大平运动失败。而亲华派没能进一步巩固自己的势力，我们对它的援助也越发困难。最终在其他派阀的压力下，“政党政策研究会”正式解散。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	if ws.数值表[56] >= 3 and _cf(44, "prcinfl") >= 50:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var _c44 := ws.get_country_by_legacy_index(44)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			# UNHANDLED: this.a.allcountries[44].Gosstroy = 3
			# UNHANDLED: this.a.allcountries[44].SubGosstroy = 6
			# UNHANDLED: this.a.allcountries[44].Vyshi = false
			# UNHANDLED: this.a.allcountries[44].Torg = true
			_add(8, -(100))
			_add(9, -(100))
			_add(1, 100)
			_add(3, 50)
			_add(4, 50)
			_add(6, -(100))
			_add_relation(0, -(100))
			_add_power(0, -(50))
			ws.influence_prc += 50
		1:
			context["result_text"] = TXT_R1_A
			_add_power(0, 30)
			ws.influence_prc -= 30

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
