extends "res://数据脚本/event_script_base.gd"

## 原作 Event527.cs：保革伯仲：第二幕（5选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_TITLE := "保革伯仲：第二幕"
const TXT_DESC := "因为在党总裁竞选中输给了大平正芳，自由民主党首相福田赳夫正式辞去党总裁的职务，其他内阁成员也随之辞职。而福田内阁也成为了日本宪法中唯一一个因执政党领导人选举失败而辞职的内阁。10月7日，新一届众议院选举即将开始。此时的自由民主党依旧深陷洛克希德丑闻之中。伴随着秘密津贴和空跑部委等违规行为的曝光，民众对执政党的批评愈演愈烈。此外大平正芳打着财政重建的旗号主张征收一般消费税，但遭到党内外强烈反对。虽然他本人最终撤回了提案，但这一行为致使许多人对执政党的不满加深了。\n在新的书记长飞鸟田一雄的带领下，社会党开始调整其原有路线，并与公明党和民主社会党正式建立了联系。但后两党对社会党目前的情况仍抱有疑虑。上届选举的结果以及社会党的内部纷争让两党中的一部分人开始尝试与自由民主党组成联盟（尽管他们仍未放弃“社公民路线”）。而日本共产党也积极拉拢城市市民的选票，试图进一步增强自身的实力。\n接下来，我们该选择行动方向了：是支援社会党完成参政交代的目标还是援助共产党扩大它的势力范围，亦或是对其他在野党给予更多帮助。又或者，我们可以继续向自由民主党伸出援手，毕竟现任总裁大平正芳是前田中角荣内阁的外交大臣，他积极参与到了中日邦交正常化的进程中并与我们建立了不错的关系。如果能够帮他一把，不仅可以进一步深化两国贸易关系，也能借此缓和与美国的关系。"
const TXT_DESC_LDP := "因为在党总裁竞选中输给了大平正芳，自由民主党首相福田赳夫正式辞去党总裁的职务，其他内阁成员也随之辞职。而福田内阁也成为了日本宪法中唯一一个因执政党领导人选举失败而辞职的内阁。10月7日，新一届众议院选举即将开始。此时的自由民主党依旧深陷洛克希德丑闻之中。伴随着秘密津贴和空跑部委等违规行为的曝光，民众对执政党的批评愈演愈烈。此外大平正芳打着财政重建的旗号主张征收一般消费税，但遭到党内外强烈反对。虽然他本人最终撤回了提案，但这一行为致使许多人对执政党的不满加深了。\n在新的书记长飞鸟田一雄的带领下，社会党开始调整其原有路线，并与公明党和民主社会党正式建立了联系。但后两党对社会党目前的情况仍抱有疑虑。上届选举的结果以及社会党的内部纷争让两党中的一部分人开始尝试与自由民主党组成联盟（尽管他们仍未放弃“社公民路线”）。而日本共产党也积极拉拢城市市民的选票，试图进一步增强自身的实力。\n接下来，我们该选择行动方向了：是支援社会党完成参政交代的目标还是援助共产党扩大它的势力范围，亦或是对其他在野党给予更多帮助。又或者，我们可以继续向自由民主党伸出援手，毕竟现任总裁大平正芳是前田中角荣内阁的外交大臣，他积极参与到了中日邦交正常化的进程中并与我们建立了不错的关系。如果能够帮他一把，不仅可以进一步深化两国贸易关系，也能借此缓和与美国的关系。"
const TXT_DESC_LEFT := "社会党的内部派系矛盾问题致使它作为革新联合政府的主导者在内外诸多事务上都处于左右摇摆的状态，这又让它与公明党和民主社会党之间的关系愈发疏远，联合政府也变得越来越不稳定。并且因为这是“55年体制”下的第一个非自由民主党政府，各党均缺乏足够的执政经验，使得民众对这一政府的信任度也有所下降。财政界和反对党更是在寻找一切可以用来攻击的点来针对政府。\n最终在1979年7月，反对党对政府的不信任案在民主社会党部分议员反水、共产党部分议员弃权与少量议员缺席的情况下得到通过。当年10月，新一轮大选即将展开。考虑到先前联合政府的矛盾，我们恐怕很难指望这次三党的联盟能继续维持。但如果我们付出的努力足够多，也许还是可以说服它们继续联合执政？不管怎样，选择权在您！"
const TXT_OPT0 := "向社会党伸出援手"
const TXT_OPT0_DIS := "没人对他们有兴趣"
const TXT_OPT1 := "助其他在野党一臂之力"
const TXT_OPT1_DIS := "为什么要玩议会游戏？"
const TXT_OPT2 := "帮助共产党"
const TXT_OPT2_DIS := "日共不会和我们合作"
const TXT_OPT3 := "为自由民主党提供帮助"
const TXT_OPT3_DIS := "他们不会听我们的"
const TXT_OPT4 := "让我们观望局势发展"
const TXT_R0_A := "我们决定全力帮助社会党。在内部矛盾得到一定程度的解决后，社会党得以腾出更多精力应对选举。同时我们向其提供了大量资金和特勤服务，帮助其拿下了多个关键选区。\n最终社会党取得前所未有的大胜，夺得145席。其他党情况如下：公明党57席，民主社会党32席，共产党37席，社会民主联合2席，新自由俱乐部2席，无所属议员19席。自由民主党遭受大败，只拿到217席，失去了半数多数并首次成为了在野党。受此影响，大平正芳辞去了党总裁的职务，前首相福田赳夫再次成为总裁。\n经过谈判，社会党、公明党和民主社会党正式组成了联合政府。新政府由飞鸟田一雄领导，宣布将带领日本走向“非武装积极中立”路线，改组自卫队，保护劳工阶层，推动公有化进程，同时改善市民生活水平。在外交上，新政府表示不久便会与美国开展关于废除《日美安保条约》的谈判，同时开始加强与苏联和社会主义阵营的关系，发展同其他左翼政党的关系，并呼吁推动全球裁军以及无核化。"
const TXT_R0_B := "我们决定同之前一样全力帮助社会党。尽管其内部矛盾尚未得到彻底解决，但大量的资金和物资支持还是让社会党暂时得以腾出更多精力应对选举。同时我们在日本的特工发起了行动：破坏执政党候选人竞选集会、组织受到公害病影响的市民展开集会抗议、派出社会活动家积极开展宣传工作等，成功帮助社会党拿下多个关键选区。\n最终社会党虽未赢得像上次一样多的席位，但仍取得了145席的成绩。其他党情况如下：公明党57席，民主社会党32席，共产党37席，社会民主联合2席，新自由俱乐部2席，无所属议员19席。自由民主党遭受又一次失败，只拿到217席。受此影响，大平正芳辞去了党总裁的职务，前首相福田赳夫再次成为总裁。\n经过艰难的谈判，社会党、公明党和民主社会党再一次组成了联合政府。新政府由飞鸟田一雄领导，宣布将继续坚持“非武装积极中立”路线，改组自卫队，保护劳工阶层，同时改善市民生活水平。而在其他两党的要求下，社会党也同意放缓了对国有化和国家计划委员会的推动。在外交上，新政府将继续推动关于废除《日美安保条约》的谈判，同时加强与苏联和社会主义阵营的关系，发展同其他左翼政党的关系，并呼吁推动全球裁军以及无核化。"
const TXT_R1_A := "考虑到社会党目前的糟糕情况，我们决定将有限的资源投入到对其他在野党上。随即我们向公明党、民主社会党、社会民主联合提供了大量资金和特勤服务，成功帮助其拿下了多个关键选区。\n最终在野党取得大胜，公明党、民主社会党和社会民主联合分别赢下62席、40席和10席。其他党情况如下：社会党102席，共产党39席，新自由俱乐部4席，无所属议员19席。自由民主党遭遇失败，只拿到235席，失去多数的它不得不拉拢无所属议员、新自由俱乐部等力量来凑足半数以上的地位。\n社会党遭遇了又一次挫折后，党内斗争更加剧烈，长期把持党的主导权的社会主义协会遭到了其他各派的一致批评，左派的实力正在不断缩水。而勉强保住地位的自由民主党也并不好过，党内要求大平正芳辞去总裁职务的呼声一浪高过一浪。分析人士认为，在未来数周内执政党内部极有可能发生重大变故。而在野党联盟在此次选举中赢得大量席位，彼此关系也更加紧密。也许不久之后，它们将合并成一个统一的“中道革新政党”。\n新政府由大平正芳领导，宣布将践行“综合安全构想”，从军事和非军事两方面对日本社会进行全面保障。在外交上，新政府将改变前任内阁的“全方位外交”政策，强化《日美安保条约》并加强与北约的联系，以“西方阵营的一员”谋求稳定的全球秩序。同时也试图加强亚太地区的经济区域合作。不久，日本政府宣布抵制1980年莫斯科奥运会。"
const TXT_R2_A := "为了兑现此前两党关系正常化期间作出的承诺，我们向日本共产党提供了大量资金支持与特勤服务，并且动员了大批青年和社会活动家帮助他们吸引城市临时工、钟点工等被封闭性企业工会体系排斥的工人为日共拉票。同时向媒体泄露了诸多自民党内部材料，成功帮助日共拿下了多个关键选区。\n最终共产党获得了史无前例的70个席位，一跃成为众议院第三大党。尽管无法与其他在野党组成联合政府，但这依然彰显了共产党的强大实力。其他党情况如下：社会党102席，公明党55席，民主社会党30席，新自由俱乐部4席，社会民主联合2席，无所属议员19席。自由民主党遭遇失败，只拿到231席，失去多数的它不得不拉拢无所属议员、新自由俱乐部等力量以凑足半数以上的席位。\n社会党遭遇了又一次挫折后，党内斗争更加剧烈，长期把持党的主导权的社会主义协会遭到了其他各派的一致批评，左派的实力正在不断缩水。而勉强保住地位的自由民主党也并不好过，党内要求大平正芳辞去总裁职务的呼声一浪高过一浪。分析人士认为，在未来数周内执政党内部极有可能发生重大变故。\n新政府由大平正芳领导，宣布将践行“综合安全构想”，从军事和非军事两方面对日本社会进行全面保障。在外交上，新政府将改变前任内阁的“全方位外交”政策，强化《日美安保条约》并加强与北约的联系，以“西方阵营的一员”谋求稳定的全球秩序。同时也试图加强亚太地区的经济区域合作。不久，日本政府宣布抵制1980年莫斯科奥运会。"
const TXT_R3_A := "我们最终决定与上次一样继续援助自由民主党，尤其是对其内部的亲华派议员提供了全方位的服务，极大增强了他们的实力，这让他们有机会对党施加更大的影响力。尽管一些人持反对意见，但总归不能让先前付出的努力付诸东流，不是吗？\n最终自由民主党顶住了压力，勉强达到了多数，拿下256席。尽管党内仍有对总裁大平正芳的批评之声，但至少目前为止事情还在掌握之中。其他党情况如下：社会党102席、公明党57席、民主社会党37席、共产党34席、新自由俱乐部4席、社会民主联合2席、无所属议员19席。\n新政府由大平正芳领导，宣布将践行“综合安全构想”，从军事和非军事两方面对日本社会进行全面保障。在外交上，新政府将改变前任内阁的“全方位外交”政策，强化《日美安保条约》并加强与北约的联系，以“西方阵营的一员”谋求稳定的全球秩序。同时也试图加强亚太地区的经济区域合作。不久，日本政府宣布抵制1980年莫斯科奥运会。"
const TXT_R4_A := "我们决定按兵不动，静观局势发展。\n最终社会党遭受挫折，只拿到107席。其他在野党则取得胜利：公明党57席，民主社会党35席，共产党39席，新自由俱乐部4席，社会民主联合2席，无所属议员19席。自由民主党依旧未能拿到多数，只有248席，不得不拉拢无所属议员和新自由俱乐部以凑足半数以上的席位。\n新政府由大平正芳领导，宣布将践行“综合安全构想”，从军事和非军事两方面对日本社会进行全面保障。在外交上，新政府将改变前任内阁的“全方位外交”政策，强化《日美安保条约》并加强与北约的联系，以“西方阵营的一员”谋求稳定的全球秩序。同时也试图加强亚太地区的经济区域合作。不久，日本政府宣布抵制1980年莫斯科奥运会。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	# 原版 TextOfEvents 按 resultOfEvents[522] 二选一；这里在显示前动态改写。
	if int(world.completed_event_ids.get("event_522", 0)) != 0:
		event_def.description = TXT_DESC_LDP
	else:
		event_def.description = TXT_DESC_LEFT
	if ws.数值表[56] < 3:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.数值表[56] == 2 or ws.数值表[56] == 3:
		_enable(opt[1], TXT_OPT1)
	elif ws.数值表[56] < 2:
		_disable(opt[1], "为什么要玩议会游戏？")
	else:
		_disable(opt[1], "我们没必要浪费精力在其他人身上")
	if ws.数值表[56] == 2 and int(ws.completed_event_ids.get("event_524", 0)) == 1:
		_enable(opt[2], TXT_OPT2)
	elif ws.数值表[56] < 2:
		_disable(opt[2], "打倒修正主义者！")
	elif ws.数值表[56] > 2:
		_disable(opt[2], "别和民主之敌走那么近！")
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if ws.数值表[56] > 2 and int(ws.completed_event_ids.get("event_522", 0)) == 2:
		_enable(opt[3], TXT_OPT3)
	elif ws.数值表[56] <= 2:
		_disable(opt[3], "跟美国走狗眉来眼去？")
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], TXT_OPT4)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c44 := ws.get_country_by_legacy_index(44)
	match opt:
		0:
			if int(ws.completed_event_ids.get("event_522", 0))  not = 0:
				context["result_text"] = TXT_R0_A
			else:
				context["result_text"] = TXT_R0_B
			if int(ws.completed_event_ids.get("event_522", 0))  not = 0:
				# UNHANDLED: this.a.allcountries[44].Gosstroy = 2
				# UNHANDLED: this.a.allcountries[44].SubGosstroy = 8
				# UNHANDLED: this.a.allcountries[44].Vyshi = false
				# UNHANDLED: this.a.allcountries[44].Torg = true
				_add(8, -(40))
				_add(9, -(40))
				_add(1, 50)
				_add(3, 50)
				_add(6, 5)
				ws.influence_prc += 30
				_add_relation(0, -(100))
			else:
				# UNHANDLED: this.a.allcountries[44].Gosstroy = 2
				# UNHANDLED: this.a.allcountries[44].SubGosstroy = 8
				# UNHANDLED: this.a.allcountries[44].Vyshi = false
				# UNHANDLED: this.a.allcountries[44].Torg = true
				_add(8, -(80))
				_add(9, -(80))
				_add(1, 50)
				_add(3, 50)
				_add(6, 5)
				ws.influence_prc += 30
				_add_relation(0, -(100))
		1:
			context["result_text"] = TXT_R1_A
			# UNHANDLED: this.a.allcountries[44].Gosstroy = 3
			# UNHANDLED: this.a.allcountries[44].SubGosstroy = 6
			_add(8, -(30))
			_add(9, -(30))
			_add(1, -(50))
			_add(3, 50)
			_add(6, 8)
			_add_relation(0, -(80))
			ws.influence_prc += 20
		2:
			context["result_text"] = TXT_R2_A
			# UNHANDLED: this.a.allcountries[44].Gosstroy = 3
			# UNHANDLED: this.a.allcountries[44].SubGosstroy = 6
			_add(8, -(30))
			_add(9, -(30))
			_add(1, -(50))
			_add(3, 50)
			_add(6, 8)
			_add_relation(0, -(80))
			ws.influence_prc += 20
		3:
			context["result_text"] = TXT_R3_A
			# UNHANDLED: this.a.allcountries[44].Gosstroy = 3
			# UNHANDLED: this.a.allcountries[44].SubGosstroy = 6
			# UNHANDLED: this.a.allcountries[44].prcinfl += 20
			_add(8, -(30))
			_add(9, -(30))
			_add(1, -(50))
			_add(3, 50)
			_add(6, -(15))
			_add_relation(0, 80)
			_add_power(0, 20)
			ws.influence_prc += 20
		4:
			context["result_text"] = TXT_R4_A
			_add_power(0, 20)

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
