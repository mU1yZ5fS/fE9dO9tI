extends "res://数据脚本/event_script_base.gd"

## 原作 Event81.cs：匈牙利狂想曲（匈牙利债务危机，五选项）。
## 触发：TimeScript.cs:10668-10674 ——
##   (月>=4 且 年>=1982 或 年>=1983) && c4.Gosstroy==2 && (c20.proprc || relres)。
##   relres → Godot global flag "relres"（game_manager.gd:2912）。
## 差异：选项显隐 prepare 动态改写；result3 文本插领导人姓名（原版 names1+" "+names2）。

const TXT_R0 := "你亲自打电话给卡达尔·亚诺什，告诉他全国人民代表大会常务委员会决定以非常低的利率向匈牙利提供35亿美元的贷款。这使得该国能够避免违约，而不是诉诸新的贷款。卡达尔作为匈牙利人民共和国国务委员会首脑，代表匈牙利人民向中国人民表示了巨大的感谢，但苏联和美国对此并不满意，媒体已经在写“中国在欧洲的经济扩张”。"

const TXT_R1 := "中央意识形态部门授权了印刷大量有关匈牙利局势的重要材料。“古拉什社会主义”被宣布为“虚假市场审计”，卡达尔参加1956年的反革命政变，并得到纳吉·伊姆雷集团的支持的经历被重新揭发，匈牙利社会主义工人党被称为“愚蠢的社会主义叛徒的马克思主义党”，匈牙利的社会主义制度被称为“建立在美国货币装饰之上”。在此基础上，得出了所有市场改革都是修正主义，是走向经济深渊的道路的结论。党和人民不接受这已经相当无聊的新宣传攻势，匈牙利表达了坚决的抗议，这得到了苏联的支持。我觉得这不是我们想要的…"

const TXT_R2 := "今天上午，中国驻布达佩斯大使会见了卡达尔，代表我们提供了35亿美元的无息贷款。卡达尔准备立刻同意，但大使随后的话使他清醒起来——作为贷款的交换，匈牙利社会主义工人党中央委员会政治局应为比斯库·贝洛集团平反，恢复他们的党籍和职位，而贝洛加入他们的行列。这引起了匈牙利领导人的强烈抗议，由于长时间的口头争吵，只能达成妥协——比斯库的一些同事被增选为中央委员会成员，匈牙利获得了15亿美元的贷款。这使得该国避免了立即违约，但仍需从国际货币基金组织获得新的贷款。多亏了我们，现在左翼反对派已经在匈社工党内出现了，但最终形成势力需要很多时间…此外，苏联对我们在其影响范围内的干涉非常不满。"

const TXT_R3_A := "召见了匈牙利驻北京大使，让他转交给卡达尔·亚诺什一封信，信中提议中国将承担匈牙利的债务，以避免匈牙利违约，并且还提供45亿美元的无息贷款－条件是为比斯库·贝洛团体平反，将比斯库增选为匈社工党中央委员会政治局委员。同时我们的特工挑起了“人民卫队”（匈社工党的准军事组织，其中左翼保守情绪十分强烈）单位的骚乱，并散播攻击匈牙利改革的意识形态主管－涅尔什·雷热的材料（此人是资深社会民主主义者，曾在纳吉·伊姆雷政府中担任部长）。考虑到拒绝帮助可能会让1956年的形势重演，卡达尔被迫同意。比斯库·贝洛在我们的帮助迅速组织起左翼反对派，捷尔吉也被迫退出政治。看起来社工党内部即将出现新的分裂，只是卡达尔的存在使得局势还在控制之中…\n在左翼反对派压力和至少保存党的外部团结的渴望下，卡达尔宣布了“多重方向”的外交政策，开始与我们建立文化和贸易关系。苏联和美国十分愤怒，我们加强了在欧洲的地位。但我们现在必须得承担匈牙利的债务义务…"

const TXT_R4 := "我们没有以任何方式干涉匈牙利的事务。该国设法通过从国际货币基金组织获得新的贷款来避免违约，这只会推迟负面趋势的发生，但这种情况会持续很长一段时间，因此我们无法对其产生影响。“同时，根据匈牙利同志的说法，匈牙利应该深化参与国际合作，以免发明在其他国家早已发现的东西”。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var stage := data.reform_stage if data.size() > W.I_REFORM_STAGE else -1
	var coal := _coalition_percent(world)
	var left_party := party < 8
	var left_line := line < 3
	var opt := event_def.options
	if ((line == 0 or line == 4) and left_party) or (coal > 66 and party > 7):
		_enable(opt[0], "我们将无条件向匈牙利提供经济援助（需要35百万元预算）")
	else:
		_disable(opt[0], "我们没有足够的钱资助卡达尔主义者")
	if stage == 0 and ((left_line and left_party) or (coal > 66 and party > 7)):
		_enable(opt[1], "我们利用匈牙利人民共和国的问题来诋毁市场改革")
	else:
		_disable(opt[1], "匈牙利的例子并不能证明一切改革的失败")
	if (line < 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[2], "我们将向匈牙利提供经济援助，但交换条件是平反比斯库集团（需要15百万元预算，8特工网络）")
	else:
		_disable(opt[2], "对我们来说不是很好")
	if (line <= 2 and left_party) or (coal > 66 and party > 7):
		_enable(opt[3], "我们将完全承担匈牙利国债，但交换条件是完全平反比斯库集团（需要45百万元预算，10特工）")
	else:
		_disable(opt[3], "对我们来说太激进了！")
	_enable(opt[4], "无视它")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var hungary := ws.get_country_by_legacy_index(4)
	match opt:
		0:
			_add(W.I_BUDGET, -300)
			_add(W.I_DIPLO, -10)
			_add_power(EmpireData.USA, -10)
			_add_relation(EmpireData.USSR, -100)
			_add_relation(EmpireData.USA, -80)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_THOUGHT_FREEDOM, -20)
			_add(W.I_PEOPLE_SUPPORT, -50)
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USA, -30)
			_add_relation(EmpireData.USSR, -80)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -80)
			ws.influence_prc += 10
			_add_relation(EmpireData.USSR, -100)
			context["result_text"] = TXT_R2
		3:
			_add(W.I_BUDGET, -450)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 20
			_add_relation(EmpireData.USA, -100)
			_ussr_leader_add(6, -1)
			_add_relation(EmpireData.USSR, -200)
			if hungary != null:
				hungary.set_tag("亲苏", false)
				hungary.set_tag("对华贸易", true)
			context["result_text"] = _leader_name() + TXT_R3_A
		4:
			_add_power(EmpireData.USA, 10)
			_add_power(EmpireData.USSR, -10)
			context["result_text"] = TXT_R4


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total




func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
