extends "res://数据脚本/event_script_base.gd"

const TXT_370_644 := "种族灭绝出口"
const TXT_370_645 := "极其重要的大新闻！本周，土耳其国内的所有主要大城市均发生了爆炸，例如，对安卡拉机场的恐怖袭击导致了超过30人死亡。国家安全委员会政府宣布，库尔德斯坦工人党因对上述事件负全责。尽管该党在土耳其国内的运动已经屡遭打击，但据称，他们依然得到了来自土耳其阿拉伯邻国的援助，以实行其动摇土耳其社会秩序的阴谋。政府领导人凯南·埃夫伦宣称，将对{1}{2}{3}开展“增进和平的特别军事行动”。依照既定计划，该行动将花费6个月的时间，彻底摧毁土耳其边界的库尔德人地下恐怖组织。{4}{5}"
const TXT_370_674 := "被土耳其侵略的国家已经向国际社会寻求援助。"
const TXT_370_675 := "被土耳其侵略的国家们已经向国际社会寻求援助。"
const TXT_370_646 := "我们将不遗余力支持中东国家的反侵略斗争（需要25.0百万{0}、15.0点{1}与40.0点{2}）"
const TXT_370_592 := "预算"
const TXT_370_593 := "特工网络"
const TXT_370_594 := "军事实力"
const TXT_370_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_370_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_370_608 := "军事实力必须强于{0}......"
const TXT_370_647 := "施压美方，将土耳其逐出北约"
const TXT_370_658 := "还未签署中美合作协定......"
const TXT_370_659 := "我们还没有实现与美国中央情报局的合作......"
const TXT_370_648 := "我们对此爱莫能助"
const TXT_370_649 := "用土耳其式铁拳对付国内分离主义者（需要15.0百万{0}与20.0点{2}）"
const TXT_370_661 := "分离主义？我国没有这些东西！"
const TXT_370_660 := "我国现在还不是单一制国家......"
const TXT_370_650 := "在联合国安理会发言，建议对土耳其发起维和行动"
const TXT_370_681 := "希腊应该是北约成员国......"
const TXT_370_662 := "外交声誉应当低于“保守派”......"
const TXT_370_651 := "我们向送去了军事援助，以支援他们对抗土耳其侵略者。现在仍很难预测战争的结果如何。但很显然，双方之间的力量对比并不平衡作为对我国支援上述政权的回应，土耳其宣布与中国断交。"
const TXT_370_676 := "被土耳其侵略的国家"
const TXT_370_677 := "被土耳其侵略的国家们"
const TXT_370_663 := "土耳其-叙利亚之战"
const TXT_370_664 := "土耳其"
const TXT_370_665 := "叙利亚"
const TXT_370_666 := "土耳其-伊拉克之战"
const TXT_370_667 := "伊拉克"
const TXT_370_668 := "土耳其-伊朗之战"
const TXT_370_669 := "伊朗"
const TXT_370_652 := "尽管在北大西洋公约组织的宪章中，并没有关于开除其成员的相关规定，但美国与西欧地区多国已经在北约理事会上提出了一项议案，土耳其“因发动侵略战争并违背民主价值观”而被开除出该联盟。现在仍很难预测战争的结果如何。但很显然，双方之间的力量对比并不平衡。"
const TXT_370_653 := "美国拒绝将土耳其逐出北约，其理由是北约组织的规章中没有相应程序。"
const TXT_370_654 := "现在仍很难预测战争的结果如何。但很显然，双方之间的力量对比并不平衡。"
const TXT_370_655 := "我们打算借题发挥，好好借用土耳其人的方法。我们宣称，{1}的分离主义分子在边界进行了多次挑衅，因此，我国将以“稳定当地局势”为名，向上述地区派出部队。从而迫使那些“割据藩镇”同我们缔结不平等经济协定，并允许我们在当地建立军事基地。至于发生在土耳其的冲突，现在仍很难预测战争的结果如何。但很显然，双方之间的力量对比并不平衡。"
const TXT_370_680 := "西藏与维吾尔斯坦"
const TXT_370_679 := "西藏"
const TXT_370_656 := "联合国安理会同意了实行维和行动的必要性。根据行动计划，苏联将从高加索方向出兵土耳其，而北约将以希腊为入口。对此，土耳其宣布退出北约。"
const TXT_370_657 := "美国与苏联否决了中国要求执行维和行动的决议。"
const TXT_370_673 := "为应对新威胁，先前还在相互交战的伊拉克与伊朗签署了停火协定。"
const TXT_370_670 := "叙利亚"
const TXT_370_671 := "伊拉克"
const TXT_370_672 := "伊朗"


## 原作 Event370.cs：土耳其危机（1984.12）。启动 ingamewars 10/11/12，
## 战争 12 结算会写伊朗 puppet_of=84（GameState.cs:676-695）。
## 结果文案按项目英文风格写摘要；数值效果逐项对齐 ResultsOfEvents。


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	if event_def == null or p_ws == null:
		return
	if event_def.event_id != "event_370":
		return
	var d2 := p_ws.数值表
	var syria := p_ws.get_country_by_legacy_index(35)
	var iraq := p_ws.get_country_by_legacy_index(14)
	var iran := p_ws.get_country_by_legacy_index(8)
	var syria_neutral := syria != null and not syria.has_tag("亲苏") and not syria.has_tag("oar") \
		and not syria.has_tag("亲美") and not syria.has_tag("okb") and not syria.has_tag("seato")
	var iraq_neutral := iraq != null and not iraq.has_tag("亲苏") and not iraq.has_tag("oar") \
		and not iraq.has_tag("okb") and not iraq.has_tag("ovd") and not iraq.has_tag("seato")
	var iran_neutral := iran != null and not iran.has_tag("亲美") and not iran.has_tag("okb") \
		and not iran.has_tag("ovd") and not iran.has_tag("seato")
	var neutral_count := 0
	if syria_neutral:
		neutral_count += 1
	if iraq_neutral:
		neutral_count += 1
	if iran_neutral:
		neutral_count += 1
	var war3_going := p_ws.wars.size() > 3 and p_ws.wars[3] != null and p_ws.wars[3].is_going
	var desc := TXT_370_645
	desc = desc.replace("{1}", TXT_370_670 if syria_neutral else "")
	desc = desc.replace("{2}", TXT_370_671 if iraq_neutral else "")
	desc = desc.replace("{3}", TXT_370_672 if iran_neutral else "")
	desc = desc.replace("{4}", TXT_370_673 if war3_going else "")
	desc = desc.replace("{5}", TXT_370_674 if neutral_count == 1 else TXT_370_675)
	event_def.description = desc
	if event_def.options.size() < 5:
		return
	var budget_sum: int = d2[W.I_BUDGET] + d2[W.I_RESERVE]
	var agents: int = d2[W.I_AGENTS]
	var army: int = d2[W.I_ARMY]
	var usa := p_ws.get_country_by_legacy_index(51)
	var greece := p_ws.get_country_by_legacy_index(45)
	var opt := event_def.options
	# 选项 0
	opt[0].text = TXT_370_646.replace("{0}", TXT_370_592).replace("{1}", TXT_370_593).replace("{2}", TXT_370_594)
	if budget_sum >= 250 and agents >= 150 and army >= 400:
		opt[0].disabled_text = ""
	elif budget_sum < 200:
		opt[0].disabled_text = TXT_370_566.replace("{0}", "20")
	elif agents < 150:
		opt[0].disabled_text = TXT_370_567.replace("{0}", "15")
	else:
		opt[0].disabled_text = TXT_370_608.replace("{0}", "40")
	# 选项 1
	opt[1].text = TXT_370_647
	if usa != null and usa.has_tag("对华贸易") and usa.development > 0:
		opt[1].disabled_text = ""
	elif usa == null or not usa.has_tag("对华贸易"):
		opt[1].disabled_text = TXT_370_658
	else:
		opt[1].disabled_text = TXT_370_659
	# 选项 2
	opt[2].text = TXT_370_648
	# 选项 3
	opt[3].text = TXT_370_649.replace("{0}", TXT_370_592).replace("{2}", TXT_370_594)
	var xinjiang := d2[W.I_XINJIANG_POLICY] > 0 if d2.size() > W.I_XINJIANG_POLICY else false
	var tibet := d2[W.I_TIBET_POLICY] > 0 if d2.size() > W.I_TIBET_POLICY else false
	if (xinjiang or tibet) and budget_sum >= 150 and army >= 200 and d2[W.I_TERRITORY] == 20:
		opt[3].disabled_text = ""
	elif not xinjiang and not tibet:
		opt[3].disabled_text = TXT_370_661
	elif d2[W.I_TERRITORY] == 20:
		opt[3].disabled_text = TXT_370_660
	elif budget_sum < 150:
		opt[3].disabled_text = TXT_370_566.replace("{0}", "15")
	else:
		opt[3].disabled_text = TXT_370_608.replace("{0}", "20")
	# 选项 4
	opt[4].text = TXT_370_650
	if d2[W.I_DIPLO] < 800 and greece != null and greece.has_tag("nato"):
		opt[4].disabled_text = ""
	elif greece == null or not greece.has_tag("nato"):
		opt[4].disabled_text = TXT_370_681
	else:
		opt[4].disabled_text = TXT_370_662


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	_event_370(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_370(option_index: int, context: Dictionary) -> void:
	# Event370.cs:112-113：两伊战争(war3)若进行中则停战。
	if ws.wars.size() > 3 and ws.wars[3] != null:
		ws.wars[3].is_going = false
	# Event370.cs:114-126：中立国判定与 data[143] 增量。
	var syria_neutral := _syria_neutral()
	var iraq_neutral := _iraq_neutral()
	var iran_neutral := _iran_neutral()
	if iraq_neutral and d.size() > 143:
		d[143] += 3
	if iran_neutral and d.size() > 143:
		d[143] += 3
	var war3_bonus := 0
	if ws.wars.size() > 3 and ws.wars[3] != null and ws.wars[3].is_going:
		war3_bonus = 150

	match option_index:
		0:
			_result_0(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)
		1:
			_result_1(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)
		2:
			_result_2(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)
		3:
			_result_3(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)
		4:
			_result_4(context, syria_neutral, iraq_neutral, iran_neutral, war3_bonus)


func _result_0(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_turkey_torg_false()
	_add_data(W.I_DIPLO, 20)
	_add_data(W.I_THOUGHT_FREEDOM, -50)
	_add_empire_relation(EmpireData.USA, -300)
	_add_empire_relation(EmpireData.USSR, 100)
	_add_data(W.I_BUDGET, -250)
	_add_data(W.I_AGENTS, -150)
	_add_data(W.I_ARMY, -400)
	_add_data(W.I_PARTY_SUPPORT, 50 if _faction_0_1_2_leading() else -50)
	_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 0)
	context["result_text"] = TXT_370_651


func _result_1(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_turkey_torg_false()
	if ws.influence_prc > _usa_power():
		# Event370.cs:169-180
		_turkey_leave_nato_and_usa()
		_add_data(W.I_PARTY_SUPPORT, 100)
		_add_empire_relation(EmpireData.USA, -100)
		_add_empire_relation(EmpireData.USSR, -100)
		_add_data(W.I_DIPLO, -20)
		_add_empire_power(EmpireData.USA, -50)
		ws.influence_prc += 20
		_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, true, 0)
		context["result_text"] = TXT_370_652
	else:
		# Event370.cs:184-198
		_add_data(W.I_PARTY_SUPPORT, -300)
		_add_empire_relation(EmpireData.USA, -500)
		_add_empire_relation(EmpireData.USSR, -100)
		_add_data(W.I_DIPLO, 20)
		_add_empire_power(EmpireData.USA, 50)
		ws.influence_prc -= 80
		_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 0)
		context["result_text"] = TXT_370_653


func _result_2(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 1)
	context["result_text"] = TXT_370_654


func _result_3(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_add_data(W.I_BUDGET, -150)
	_add_data(W.I_ARMY, -200)
	_add_data(W.I_PARTY_SUPPORT, 350)
	_add_empire_relation(EmpireData.USA, -250)
	_add_empire_relation(EmpireData.USSR, -250)
	ws.influence_prc -= 50
	_add_data(W.I_DIPLO, 100)
	_reward_separatist_states()
	_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 1)
	var region := TXT_370_680
		if d.size() > W.I_XINJIANG_POLICY and d.size() > W.I_TIBET_POLICY:
			if d[W.I_XINJIANG_POLICY] > 0 and d[W.I_TIBET_POLICY] > 0:
				region = TXT_370_680
			elif d[W.I_TIBET_POLICY] > 0:
				region = TXT_370_679
			else:
				region = TXT_370_680
		else:
			region = TXT_370_680
		context["result_text"] = TXT_370_655.replace("{1}", region)


func _result_4(
		context: Dictionary, syria_neutral: bool, iraq_neutral: bool,
		iran_neutral: bool, war3_bonus: int
) -> void:
	_turkey_torg_false()
	if ws.influence_prc > _usa_power() + _ussr_power() or ws.influence_prc > 800:
		# Event370.cs:306-317
		ws.influence_prc += 50
		_add_data(W.I_DIPLO, -50)
		_add_data(W.I_PARTY_SUPPORT, -300)
		_add_empire_relation(EmpireData.USA, -100)
		_add_empire_relation(EmpireData.USSR, -100)
		if d.size() > 126:
			d[126] = 1
		_turkey_leave_nato_and_usa()
		_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, true, 2)
		context["result_text"] = TXT_370_656
	else:
		# Event370.cs:327-340
		ws.influence_prc -= 10
		_add_empire_power(EmpireData.USA, 50)
		_add_empire_power(EmpireData.USSR, 50)
		_add_data(W.I_PARTY_SUPPORT, -300)
		_add_empire_relation(EmpireData.USA, -100)
		_add_empire_relation(EmpireData.USSR, -100)
		_start_neutral_wars(syria_neutral, iraq_neutral, iran_neutral, war3_bonus, false, 1)
		context["result_text"] = TXT_370_657


func _syria_neutral() -> bool:
	var syria := ws.get_country_by_legacy_index(35)
	if syria == null:
		return false
	return not syria.has_tag("亲苏") and not syria.has_tag("oar") \
		and not syria.has_tag("亲美") and not syria.has_tag("okb") \
		and not syria.has_tag("seato")


func _iraq_neutral() -> bool:
	var iraq := ws.get_country_by_legacy_index(14)
	if iraq == null:
		return false
	return not iraq.has_tag("亲苏") and not iraq.has_tag("oar") \
		and not iraq.has_tag("okb") and not iraq.has_tag("ovd") \
		and not iraq.has_tag("seato")


func _iran_neutral() -> bool:
	var iran := ws.get_country_by_legacy_index(8)
	if iran == null:
		return false
	return not iran.has_tag("亲美") and not iran.has_tag("okb") \
		and not iran.has_tag("ovd") and not iran.has_tag("seato")


func _faction_0_1_2_leading() -> bool:
	if ws.factions == null:
		return false
	for i in range(3):
		if i >= ws.factions.size() or ws.factions[i] == null:
			continue
		var leader_index: int = ws.factions[i].leader_index
		if leader_index == WorldFactory.LEADER_POSITION_SENTINEL:
			return true
		if leader_index >= 0 and leader_index < ws.politicians.size() \
				and ws.politicians[leader_index] != null:
			return true
	return false


## 启动中立国战争。style:
##   0 = Event370 result0/1 美国支持土耳其，非亲中胜利（infl 组合按分支传入 base）
##   1 = 美国支持土耳其的常规进攻档
##   2 = 美苏共同支持防守方
func _start_neutral_wars(
		syria_neutral: bool, iraq_neutral: bool, iran_neutral: bool,
		war3_bonus: int, _soviet_only: bool, style: int
) -> void:
	var infl_base := 500
	match style:
		0:
			infl_base = 400 if _soviet_only else 500
		1:
			infl_base = 600
		2:
			infl_base = 300
	var usa_side := 0
	if style == 2:
		usa_side = 1          # Event370 result4 分支：AmericanSupportDefender
	elif style == 0 and _soviet_only:
		usa_side = -1         # Event370 result1 亲中胜利分支：仅 SovietSupportDefender
	var ussr_side := 1
	if syria_neutral:
		GameManager.start_war(10, TXT_370_664, TXT_370_665, infl_base, 1000 - infl_base, usa_side, ussr_side)
	if iraq_neutral:
		var infl1 := infl_base + war3_bonus
		GameManager.start_war(11, TXT_370_664, TXT_370_667, infl1, 1000 - infl1, usa_side, ussr_side)
	if iran_neutral:
		var infl1 := infl_base + war3_bonus
		GameManager.start_war(12, TXT_370_664, TXT_370_669, infl1, 1000 - infl1, usa_side, ussr_side)


func _turkey_torg_false() -> void:
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey != null:
		turkey.set_tag("对华贸易", false)


func _turkey_leave_nato_and_usa() -> void:
	var turkey := ws.get_country_by_legacy_index(84)
	if turkey == null:
		return
	turkey.set_tag("亲美", false)
	turkey.set_tag("nato", false)


func _reward_separatist_states() -> void:
	if d.size() > W.I_XINJIANG_POLICY and d[W.I_XINJIANG_POLICY] > 0:
		var uyghuristan := ws.get_country_by_legacy_index(70)
		if uyghuristan != null:
			uyghuristan.development = 100
			uyghuristan.set_tag("对华贸易", true)
			uyghuristan.set_tag("亲中", true)
			uyghuristan.set_tag("亲美", false)
			uyghuristan.set_tag("亲苏", false)
	if d.size() > W.I_TIBET_POLICY and d[W.I_TIBET_POLICY] > 0:
		var tibet := ws.get_country_by_legacy_index(69)
		if tibet != null:
			tibet.development = 100
			tibet.set_tag("对华贸易", true)
			tibet.set_tag("亲中", true)
			tibet.set_tag("亲美", false)
			tibet.set_tag("亲苏", false)


func _usa_power() -> int:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		return ws.empires[EmpireData.USA].power
	return 0


func _ussr_power() -> int:
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		return ws.empires[EmpireData.USSR].power
	return 0


func _add_data(index: int, delta: int) -> void:
	if index >= 0 and index < d.size():
		d[index] += delta


func _add_empire_relation(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations += delta


func _add_empire_power(empire_index: int, delta: int) -> void:
	if empire_index >= 0 and empire_index < ws.empires.size() and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		d[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		d[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
