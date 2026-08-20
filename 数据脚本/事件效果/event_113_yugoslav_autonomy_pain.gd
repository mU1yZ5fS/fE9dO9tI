extends "res://数据脚本/event_script_base.gd"

## 原作 Event113.cs：南斯拉夫社会主义自治的痛苦（五选项）。
## 触发：TimeScript.cs:10936-10941 ——
##   日期>=1983.2.1 && !c15.eu && c15.SubGosstroy==11 && c20.SubGosstroy!=11。
## 差异：
##  - result 5 为死代码（button_text[5]=""）→ 跳过；
##  - data[86] 无 W.I_* 常量 → 直接 d[86] + 注释；result0/2 的 data[86] 读写是局部 no-op，跳过；
##  - Vyshi→亲美、isSEV→sev、Torg→对华贸易、dev→development。


const TXT_OPT1_DIS := "为什么我们需要重组他们的债务？"
const TXT_OPT2_DIS := "我们没有足够的影响力让苏联和南斯拉夫听我们的"
const TXT_OPT3_DIS := "支持军政府？在南斯拉夫？胡说八道！"
const TXT_OPT4_DIS := "我们没有足够的影响力让美国和南斯拉夫听我们的"

const TXT_R0 := "接任南斯拉夫主席团主席职务的佩塔尔·斯坦鲍利奇（塞尔维亚族）和米尔卡·什皮利亚克（克罗地亚族）都不敢通过克拉伊盖尔委员会的改革提议。南斯拉夫从国际货币基金组织和苏联那里获得了新的贷款，这只不过是南斯拉夫经济再痛苦一段时间罢了……"
const TXT_R1 := "我们的主席亲自与佩塔尔·斯坦鲍利奇（塞尔维亚族）和米卡·什皮利亚克（克罗地亚族）通话，让他们拒绝市场改革，从而通过了我们重建南斯拉夫公债的提议。一瞬间南斯拉夫人自己都不知道欠了谁的债或者欠了多少债——他们的债务数都数不清。我们不得不为南斯拉夫在联合国说情，并动用国安部的力量对国际货币基金组织和IBER施压，以“确定”南斯拉夫的债务规模。最终债权人们放出了最终账单——530亿美元年利率8％，并同意抹去其余部分。我们作为协议的保障者，归还了部分债务，剩下的要靠南斯拉夫自己了。南斯拉夫的领导人对我们将他们从经济崩溃中拯救出来表示了感谢，南斯拉夫已经与我们开展了新的盈利的贸易合同，并加强了其共和国和我们的自治区间的文化联系。当然，拯救南斯拉夫的财政对我们的经济显然没什么好处……"
const TXT_R2 := "华沙条约国家的领导人对“克拉伊盖尔委员会”的提案非常警惕，向南斯拉夫提供了巨额的财政援助以阻止其施行市场改革。我们也对这一提议表示支持。南斯拉夫领导人担心自己的经济会变得完全依赖苏联和中国，拒绝了帮助——然而“克拉伊盖尔委员会”却解散了，其部分委员被开除出南斯拉夫共产主义者联盟，谢尔盖·克拉伊盖尔也被迫退休。但是在此之后南斯拉夫扩大了其在经互会内的活动，并向组织提交了成为经互会正式成员的申请。与经互会成员国的合作使得南斯拉夫能够复兴自己的经济，但是或早或晚债务还是要还的……"
const TXT_R3_DEV1 := "“克拉伊盖尔委员会”的提案以及军费将被首先削减的新闻，在南斯拉夫人民军将领内引起了强烈的不满。我们决定利用这一机会支持不满者，将他们推上公开舞台。3月1日，南斯拉夫人民军第252装甲旅、第1无产阶级机械化师和第453机械化旅发起兵变，迅速占领了贝尔格莱德。人民军的反情报部门迅速监禁了南斯拉夫政府和共产主义者联盟的所有地区领导人。“保卫南斯拉夫人民军事委员会”现在掌握了权力，领导者是韦利科·卡迪耶维奇将军（克罗地亚塞族南斯拉夫人）和海军司令布兰科·马穆拉（支持南斯拉夫统一的斯洛文尼亚族），他们宣称“忠于马克思、恩格斯、列宁和铁托同志的事业”，并“与叛徒坚决对抗到底，保护南斯拉夫各民族的友谊和团结”。\n不久，新的南斯拉夫共产主义者联盟大会召开，在大会上通过了《建国以来历史问题决议》问题，平反了“弗拉多”·达普切维奇与安德烈·赫尔布兰格为首的反修正主义者，在大会一致同意下选举前国安局成员，来自波黑的保守派外交官拉伊夫·迪兹达雷维奇为总书记。新领导层决定在全国范围内对腐败官员、民族主义者、自由派和新资产阶级进行清洗，并改组各地企业，实施再集体化，重建中央集权制度和中央计划经济，以及撤销了共产主义者联盟各支部的自治权。南斯拉夫宣布终止“不结盟”政策，并倒向由“苏联和中国平等领导”的社会主义阵营，同时也拒绝归还任何债务。美国威胁事情不会这样简单过去的……"
const TXT_R3_OTHER := "“克拉伊盖尔委员会”的提案以及军费将被首先削减的新闻，在南斯拉夫人民军将领内引起了强烈的不满。我们决定利用这一机会支持不满者，将他们推上公开舞台。3月1日，南斯拉夫人民军第252装甲旅、第1无产阶级机械化师和第453机械化旅发起兵变，迅速占领了贝尔格莱德。政变的领导者是韦利科·卡迪耶维奇将军和海军司令布兰科·马穆拉，他们宣称“忠于马克思、恩格斯、列宁和铁托同志的事业”，并“与叛徒坚决对抗到底，保护南斯拉夫各民族的友谊和团结”。\n然而，政变在短暂的两天后遭到了以塞尔维亚民族主义者拉特科·姆拉迪奇为首的地区防卫军的青年军官的反政变——贝尔格莱德的地区防卫军在贝尔格莱德市长米洛舍维奇鼓动市民对“反南斯拉夫行为”示威转移注意力的情况下的配合下迅速集结，逮捕了军政府领导人，以莫须有的罪名指控新的军政府意图将国家出卖给阿尔巴尼亚。现在，取代被解散的南斯拉夫共产主义者联盟的是“南斯拉夫革命救国运动”，该组织完全由军队掌控。该组织掌握全国后，便宣布拒绝偿还任何债务，发动“反官僚主义文化革命”，鼓动不满者，特别是塞族青年夺取各地政府机关。南斯拉夫依然宣布“不结盟”政策，但言论转向了强烈的反西方外交路线，驱逐了欧共体与美国的外交官，宣布支持“不结盟世界对帝国主义的正义斗争”。美国威胁事情不会这样简单过去的。同时在塞尔维亚和黑山以外的全国，分离主义情绪极度增强了……"
const TXT_R4 := "美国一得知委员会的提案，南斯拉夫就收到了向其提供优惠贷款的提议——前提是南斯拉夫接受市场改革方案。在我们为克拉伊盖尔提供支持并通过非正式渠道对南斯拉夫领导人做出建议后，他们同意了——佩塔尔·斯坦鲍利奇（塞尔维亚族）提早辞去主席团主席一职，并且米卡·普拉宁茨（克罗地亚族）也辞去了执行委员会主席的职务。支持改革的米尔卡·什皮利亚克和安特·马尔科维奇（均为克族）接任空位，开始实施委员会的改革计划。国有财产的私有化开始了，合作社彻底取消了，农场得到许可，自由经济区也在杜布罗夫尼克和斯普利特设立起来。当然，联邦财政的清算在落后共和国和自治区造成了严重不满，人民军将领对军费大幅削减十分愤怒，斯洛文尼亚和克罗地亚向完全成本核算的转型也引起了民族主义和分离主义的迅速抬头……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var agents := data[W.I_AGENTS] if data.size() > W.I_AGENTS else 0
	var coal := _coalition_percent(world)
	var policy_left := (line < 3 and party < 8) or (coal > 66 and party > 7)
	var china := world.get_country_by_legacy_index(1)
	var china_sev := china != null and china.has_tag("sev")
	var relres := world.get_flag("relres")
	var usa := world.get_country_by_legacy_index(51)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if agents >= 50 and policy_left:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if ((world.influence_prc >= 150 and china_sev) or (relres and world.influence_prc >= 250)) and policy_left:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if world.influence_prc >= 300 and agents >= 50 and ((line < 2 and party < 8) or (coal > 66 and party > 7)):
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	if (world.influence_prc >= 200 or (usa != null and usa.development > 0)) and agents >= 50 and ((line >= 3 and party < 8) or (coal > 66 and party > 7)):
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], TXT_OPT4_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var yugoslavia := ws.get_country_by_legacy_index(15)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			# 原版 result0 的 data[86] 读写是局部 no-op（未写回数组）→ 跳过。
			context["result_text"] = TXT_R0
		1:
			ws.influence_prc += 20
			_add(W.I_AGENTS, -50)
			_add(W.I_DIPLO, -10)
			_add(W.I_BUDGET, -200)
			if d.size() > 86:
				d[86] += 2
			_set_torg_or_agents(yugoslavia)
			context["result_text"] = TXT_R1
		2:
			_add_relation(EmpireData.USSR, 200)
			_add_relation(EmpireData.USA, -50)
			_add(W.I_DIPLO, -10)
			_add(W.I_PARTY_SUPPORT, 50)
			if yugoslavia != null:
				yugoslavia.set_tag("sev", true)
			_set_torg_or_agents(yugoslavia)
			context["result_text"] = TXT_R2
		3:
			var dev1: bool = yugoslavia != null and yugoslavia.development == 1
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 20
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_DIPLO, 30)
			_add_power(EmpireData.USSR, 20)
			_add_power(EmpireData.USA, -30)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, 200)
			if d.size() > 86:
				d[86] += 2
			_set_torg_or_agents(yugoslavia)
			if yugoslavia != null:
				yugoslavia.government = GameConstants.Government.AUTHORITARIAN
				yugoslavia.sub_government = GameConstants.SubGovernment.LEFT_RADICAL if dev1 else 10
			context["result_text"] = TXT_R3_DEV1 if dev1 else TXT_R3_OTHER
		4:
			_add(W.I_AGENTS, -50)
			_add_power(EmpireData.USA, 20)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_DIPLO, -30)
			_add_power(EmpireData.USSR, -20)
			_add_relation(EmpireData.USA, 200)
			_add_relation(EmpireData.USSR, -250)
			if d.size() > 86:
				d[86] -= 3
			if yugoslavia != null:
				yugoslavia.set_tag("亲美", true)
			context["result_text"] = TXT_R4


func _set_torg_or_agents(c: CountryData) -> void:
	if c == null:
		return
	if not c.has_tag("对华贸易"):
		c.set_tag("对华贸易", true)
	else:
		_add(W.I_AGENTS, 30)


## 原版 summa_3_2 复算：仅 party_system>7 时计算执政党(1)+盟友席位数 ×100 / 五党总席位数。
func _coalition_percent(world: WorldState) -> int:
	var data := world.数值表
	if data.size() <= W.I_PARTY_SYSTEM or data[W.I_PARTY_SYSTEM] <= 7:
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



