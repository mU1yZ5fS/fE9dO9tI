extends "res://数据脚本/event_script_base.gd"

## 原作 Event522.cs：保革伯仲：第一幕（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT0_DIS := "美国会怎么想？"
const TXT_OPT1_DIS := "社会运动不符合民主自由原则！"
const TXT_OPT2_DIS := "和资本主义和解？你是认真的？"
const TXT_R0_A := "我们最终决定给予社会党全方位的帮助。不仅向其在各地的竞选组织提供了资金援助，并且指示我们在日本的特工发起一系列行动，包括破坏自由民主党候选人竞选集会、向媒体提供更多现政府内幕与丑闻、组织城市市民集会抗议等，这对执政党的声誉造成了连环打击。\n最终我们的努力得到了回报。社会党赢得了史无前例的170席。其他党情况如下：公明党60席，民主社会党30席、新自由俱乐部12席、共产党22席，无所属议员21席。自由民主党迎来空前惨败，只获得196席，失去了半数多数并首次成为在野党。\n尽管党内依旧质疑声不断，但社会党高层最终还是决定与公明党、民主社会党建立联合政权。新政府由成田知巳领导，宣布将带领日本走向非武装积极中立路线，改组自卫队，推动公有化进程，筹备国家计划委员会、保护劳工阶层。在外交上，新政府表示不久便会与美国开展废除《日美安保条约》的谈判，同时开始加强与苏联和社会主义阵营的关系，发展同其他左翼政党的关系，并呼吁推动全球裁军以及无核化。"
const TXT_R1_A := "我们向日本社会主义青年同盟、日本民主青年同盟等青年组织、左翼工会和其他社会组织提供援助，包括头盔、横幅、海报，以及最重要的资金。在我们的大力支持下，它们开展了一系列新的社会运动，对自由民主党的支持率造成了一定打击，也让社会党内“社共共斗”的呼声再次出现（尽管共产党对此兴趣不大且多次批评社会党是中派政党），而公明党、民主社会党和社会党之间的关系也变得更加微妙。\n最终社会党赢得150席，数量为历史第二多，但依旧不够打破自由民主党的垄断。其他党情况如下：公明党55席，民主社会党29席、新自由俱乐部17席、共产党17席，无所属议员21席。自由民主党席位则下跌至222席，不得不通过与无所属议员和新自由俱乐部组成联合政府来凑足半数以上的席位。\n新政府由福田赳夫领导，宣布将推行以平衡预算为导向的经济稳定增长理论，扩大基础投资，通过国内需求主导的经济管理来增加进口并进一步开放市场。在外交上，新政府将推动“全方位外交”，维持对美关系的同时也积极与其他国家维系往来并强调亚洲外交，包括开始向中国提供官方发展援助，并积极向东南亚提供支援。这一立场在次年8月福田赳夫访问东南亚期间得到鲜明体现：他强调日本将在不成为军事强国的情况下为世界和平与繁荣做出贡献。"
const TXT_R2_A := "考虑到来之不易的外交成果，我们决定转向自由民主党，对该党在选举战况胶着地区的候选人提供大量帮助。并且依靠之前两国邦交正常化留下的人脉关系，我们进一步与自由民主党内部的亲华派议员取得了联系。由于自由民主党的大帐篷特性，想要保持与他们的联系并壮大其实力并不难做到。很快这些人便形成了一股新的派阀力量。为了更好地发展，他们正式注册了“政党政策研究会”这一名号并以此为掩护进行各种活动。不过请注意：我们需要经常性地为他们提供支持，这样才能在关键时刻发挥作用。\n同时得益于我们在当地人员的出色服务，执政党成功保住了多个地区的议员席位。不久我们收到了对方的电报，向我们表示感谢，并提出希望促成双方新的贸易合作。\n最终社会党获得115席，几乎没有变化。其他党情况如下：公明党50席，民主社会党24席，新自由俱乐部30席，共产党12席，无所属议员21席。自由民主党虽有所下滑但仍保住了半数以上的席位，获得258席。\n新政府由福田赳夫领导，宣布将推行以平衡预算为导向的经济稳定增长理论，扩大基础投资，通过国内需求主导的经济管理来增加进口并进一步开放市场。在外交上，新政府将推动“全方位外交”，维持对美关系的同时也积极与其他国家维系往来并强调亚洲外交，包括开始向中国提供官方发展援助，并积极向东南亚提供支援。这一立场在次年8月福田赳夫访问东南亚期间得到鲜明体现：他强调日本将在不成为军事强国的情况下为世界和平与繁荣做出贡献。"
const TXT_R3_A := "考虑到我们自己还有问题需要处理，我们最终决定暂时不采取行动，积攒实力。\n不久选举结果正式公布：社会党获得123席，仅有小幅上涨。其他党情况如下：公明党55席，民主社会党29席，新自由俱乐部17席，共产党17席，无所属议员21席。自由民主党失去了半数多数，只有249席，不得不吸引无所属议员来保住半数以上的席位。\n新政府由福田赳夫领导，宣布将推行以平衡预算为导向的经济稳定增长理论，扩大基础投资，通过国内需求主导的经济管理来增加进口并进一步开放市场。在外交上，新政府将推动“全方位外交”，维持对美关系的同时也积极与其他国家维系往来并强调亚洲外交，包括开始向中国提供官方发展援助，并积极向东南亚提供支援。这一立场在次年8月福田赳夫访问东南亚期间得到鲜明体现：他强调日本将在不成为军事强国的情况下为世界和平与繁荣做出贡献。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if ws.数值表[56] <= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.数值表[56] <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if ws.数值表[56] > 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var _c44 := ws.get_country_by_legacy_index(44)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			# UNHANDLED: this.a.allcountries[44].Gosstroy = 2
			# UNHANDLED: this.a.allcountries[44].SubGosstroy = 8
			_add(6, 5)
			# UNHANDLED: GlobalScript.inst.gameState.data[1] += 50
			# UNHANDLED: GlobalScript.inst.gameState.influencePRC += 5
			# UNHANDLED: GlobalScript.inst.gameState.empires[0].relations -= 50
			# UNHANDLED: GlobalScript.inst.gameState.data[8] -= 40
			# UNHANDLED: GlobalScript.inst.gameState.data[9] -= 40
		1:
			context["result_text"] = TXT_R1_A
			# UNHANDLED: this.a.allcountries[44].Gosstroy = 3
			# UNHANDLED: this.a.allcountries[44].SubGosstroy = 6
			_add(6, 5)
			# UNHANDLED: GlobalScript.inst.gameState.data[1] += 50
			# UNHANDLED: GlobalScript.inst.gameState.influencePRC += 5
			# UNHANDLED: GlobalScript.inst.gameState.data[8] -= 30
			# UNHANDLED: GlobalScript.inst.gameState.data[9] -= 30
		2:
			context["result_text"] = TXT_R2_A
			# UNHANDLED: this.a.allcountries[44].Gosstroy = 3
			# UNHANDLED: this.a.allcountries[44].SubGosstroy = 6
			# UNHANDLED: this.a.allcountries[44].prcinfl = 10
			_add(6, -(5))
			# UNHANDLED: GlobalScript.inst.gameState.data[1] += 50
			# UNHANDLED: GlobalScript.inst.gameState.influencePRC += 5
			# UNHANDLED: GlobalScript.inst.gameState.empires[0].relations += 50
			# UNHANDLED: GlobalScript.inst.gameState.data[8] -= 30
			# UNHANDLED: GlobalScript.inst.gameState.data[9] -= 30
		3:
			context["result_text"] = TXT_R3_A
			# UNHANDLED: this.a.allcountries[44].Gosstroy = 3
			# UNHANDLED: this.a.allcountries[44].SubGosstroy = 6

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
