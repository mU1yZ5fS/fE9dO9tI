extends "res://数据脚本/event_script_base.gd"

const TXT_697_OPT1 := "我们需要支援AKEL，还要带上其他社会民主力量"
const TXT_697_OPT1_DIS_A := "他们是一帮盗取共产党名号的大帐篷匪帮，不能支持他们！"
const TXT_697_OPT1_DIS_B := "我们帮助一个无原则支持苏联的组织有什么好处？"


## 原作 Event697.cs：爱神之吻（塞浦路斯大选）。
## 只移植数值/国家状态效果；长文本用英文摘要。
## 触发：ReqEventForDLC02.cs:1024（1983.2.13 起或 1983.3 起或 1984 起）。


func prepare(event_def: EventDef, p_ws: WorldState) -> void:
	_bind_world()
	if event_def == null or p_ws == null or event_def.options.size() < 2:
		return
	var line := p_ws.数值表[W.I_POLITICAL_LINE] if p_ws.数值表.size() > W.I_POLITICAL_LINE else 0
	var opt1 := event_def.options[1]
	if line > 0 and line < 4:
		opt1.text = TXT_697_OPT1
		opt1.disabled_text = ""
	elif line == 0:
		opt1.text = TXT_697_OPT1
		opt1.disabled_text = TXT_697_OPT1_DIS_A
	else:
		opt1.text = TXT_697_OPT1
		opt1.disabled_text = TXT_697_OPT1_DIS_B

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	_event_697(option_index, context)
	ws.set_flag("event_done_697", true)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_697(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_result_0(context)
		1:
			_result_1(context)
		2:
			_result_2(context)
		3:
			_result_3(context)


func _result_0(context: Dictionary) -> void:
	# Event697.cs:91-101
	_add_data(W.I_BUDGET, -50)
	_add_data(W.I_AGENTS, -50)
	_add_data(W.I_ARMY, -50)
	var cyprus := _cyprus()
	if cyprus != null:
		_leave_alliances(cyprus)
		cyprus.government = GameConstants.Government.SOCIALIST
		cyprus.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
		if not cyprus.内战中:
			cyprus.set_tag("对华贸易", true)
			cyprus.set_tag("亲中", true)
	context["result_text"] = "作为1974年反政变的中坚力量，EDEK虽不像AKEL那样拥有深厚的基层组织网络，但其独特优势在于拥有一支合法的武装力量和纪律严明的民兵队伍，这使其在特殊时期尤为关键。1974年政变爆发后不久，EDEK成员便迅速组织起防御与抵抗力量，投入对亲雅典军政府的希腊军官和极端民族主义武装的武装对抗之中。EDEK的多位领导人—譬如其青年组织的重要人物多罗斯·洛佐伊（DorosLoizou）就在护送利萨里德斯的过程中牺牲。因此，在整个1974—1981年间，塞浦路斯社会政治格局经历剧烈震荡、极端民族主义与左翼力量持续冲突之际，EDEK并没有像多数政党那样迅速收兵转向纯议会路线，而是凭借其在反政变和抵抗土耳其入侵中的实绩，吸纳了大量退伍人员、边境家庭以及激进青年。逐渐地，它由一个议会中声势有限的社会民主党派转变为一个武装力量与政治组织兼具的左翼爱国主义集团。由于党内强调反对外来干涉与维护塞浦路斯主权独立的纲领，其军事化队伍在部分地区事实上成为了比肩国民警卫队的“国中之军”。随着南北对峙固化、现政府在北部占领问题上的无力，社会各阶层对于现政府充满愤怒。由于EDEK与我方加强联络并调整战略，积聚力量并展开秘密扩张，不断强化其武装组织与政治动员能力。于今1983年，在全国政治危机与选举临近之际，EDEK以纪念多罗斯·洛佐伊烈士的名义发起代号为“正义复兴行动”的全国性行动。凭借1974反政变期间所积累的军事经验与动员网络，EDEK武装迅速占领尼科西亚、利马索尔和帕福斯等地的关键军政设施，并在不到72小时之内控制了全国主要通讯枢纽与战略要塞。各级军营都出现哗变现象，首都外围防线被迫中断抵抗，风雨飘摇的现政府由于突然袭击顷刻崩溃。EDEK的民兵随即拘捕了逃散的旧官僚集团成员，包括在他们眼中历来以“软弱”著称的AKEL党员。并向全国人民宣布了他们的新纲领：作为塞浦路斯工农群众的先锋队，EDEK将实行全面土地国有化、组建“人民自卫军”取代旧有武装体系，对腐败寡头统治进行全面清算，并废止1960年宪法，以此拒绝一切可能导致分裂的联邦体制方案。新政权尤其强调塞浦路斯领土的统一是该政权的首要目标，无论是十年还是五十年，他们都势必要让入侵者付出血的代价。人常言：血浓于水。|正是这血，将我们相连，|将我们捆绑，|也将我们咒诅。|——塞浦路斯主保圣人圣巴拿巴"


func _result_1(context: Dictionary) -> void:
	# Event697.cs:106-145
	_add_data(W.I_BUDGET, -50)
	_add_data(W.I_AGENTS, -50)
	var cyprus := _cyprus()
	var greece := ws.get_country_by_legacy_index(45)
	if _socialist_count() >= 3 and greece != null and greece.government == GameConstants.Government.REFORMIST:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.SOCIALIST
			cyprus.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
			cyprus.set_tag("亲苏", true)
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
		context["result_text"] = "选举结果正式公布：AKEL-DIKO泛左翼爱国联盟再获全胜：乔治·瓦西利乌成功当选塞浦路斯历史上第三位总统，并兑现竞选承诺，大力扩张社会福利体系，推行针对性税制改革，核心目标在于切实减轻中低收入家庭的生活负担。新政府的首要施政任务之一，便是制定并落地一项全新的社会福利法案。该法案将进一步扩大对弱势群体的扶持范围，具体包括提高养老金发放标准、增加失业救济金额度，以及全面升级公共医疗服务质量。此外，瓦西利乌还计划推出一揽子面向中小企业的税收优惠政策，以此激发就业市场活力，推动本土创新。与此同时，自外部世界席卷而来的革命之风正将AKEL的政策路线不断推向激进。其中，长期负责对外联络事务的国际团结委员会（EPAL）与民主青年联合组织（EDON），其左翼倾向表现得尤为鲜明。二者率先向AKEL中央委员会提出倡议，呼吁其顺应当前国际形势，全力推进社会主义革命，并凭借联盟在议会中占据的绝对优势，将塞浦路斯彻底改造为一个人民共和国。这一倡议随即引发AKEL全党上下的激烈论争，党内迅速分裂为稳健派与国际派两大阵营。最终，中央委员会召开特别代表大会，就党的未来发展方向展开专题研讨。在EDON广泛的基层动员支持下，加之原塞浦路斯共产党老党员集体表态站队激进派，国际派成功掌握了大会的主导权。一份全新的AKEL斗争党纲也应运而生：全面国有化、亲苏外交路线、民主集中制等核心原则，被正式写入素来以“和平社会主义道路”为标榜的AKEL党章。而在塞浦路斯南部各地，土地改革计划已由现政府全面启动实施。曾是不结盟运动重要推手之一的塞浦路斯，最终还是投入了社会主义大家庭的怀抱。这一历史性转变，对于东地中海地区而言究竟是喜是忧呢……"
	elif greece != null and greece.government != GameConstants.Government.REFORMIST:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.LIBERAL
			cyprus.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		context["result_text"] = "选举结果宣布了AKEL-DIKO的泛左翼爱国联盟的大败：DISY党以一己之力，强势碾压AKEL、DIKO、EDEK三党，成功将前临时总统克莱里季斯推上正式总统的宝座。新政府迅速启动施政程序，着手改革国内现有的臃肿官僚体制，具体举措包括合并冗余政府部门、削减不必要的行政层级，以此全面提升政府的行政效率与政务透明度。这些改革的核心目标，一方面在于压缩财政支出，另一方面则是为私营部门营造更为宽松友好的营商环境。新政府同时推出放宽管控与普遍减税的组合政策，尤其着重降低个人所得税与企业税税率，以此刺激国内消费市场，推动本土产业（尤其是旅游业）高质量发展。此外，新政府还将加入欧共体列为施政的首要战略目标，积极追求与欧洲的一体化进程，而非延续前两届政府的施政路线——与第三世界国家加深关系。外界普遍认为，这一战略转向将为塞浦路斯带来更多的经济发展机遇与政治稳定保障。为此，新政府迅速启动与欧盟的入盟谈判，并承诺在国内推行一系列符合欧盟标准的配套改革，包括强化法治建设、改善人权状况，以及完善市场经济运行机制。AKEL-DIKO联盟的失败直接导致二者的政治同盟瓦解，令国家航向从传统泛左翼立场转向更加自由主义的路线。而此次惨败也引发了沦为在野党的两大政党进行反思。首先是AKEL内部，关于政党未来发展路线的争论愈演愈烈：一部分人主张重新调整未来竞选策略，适度向中间立场靠拢，以吸引更多中间选民的支持；另一部分人则主张坚守传统社会主义立场，认为政党应当更加旗帜鲜明地代表工人阶级的根本利益，唯有如此才能实现东山再起的目标。与此同时，DIKO党也试图重新定位自身的政治坐标，开始转向寻求与其他中间派政党的合作，以期在未来的选举中重新夺回政治影响力。不过，无论怎样，泛左联盟在当下塞浦路斯的失败已成定局。由此观之，在马卡里奥斯总统逝世后，失去“先总统政治卫士”的光环的AKEL，终究不过是一个正逐渐边缘化、社民化的共产党组织。而这，恐怕还远非其衰落进程的终点……"
	else:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.REFORMIST
			cyprus.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
			_copy_soc_eu_from_turkey(cyprus)
		context["result_text"] = "选举结果正式公布：AKEL-DIKO泛左翼爱国联盟再获全胜：乔治·瓦西利乌成功当选塞浦路斯历史上第三位总统，并兑现竞选承诺，大力扩张社会福利体系，推行针对性税制改革，核心目标在于切实减轻中低收入家庭的生活负担。新政府的首要施政任务之一，便是制定并落地一项全新的社会福利法案。该法案将进一步扩大对弱势群体的扶持范围，具体包括提高养老金发放标准、增加失业救济金额度，以及全面升级公共医疗服务质量。此外，瓦西利乌还计划推出一揽子面向中小企业的税收优惠政策，以此激发就业市场活力，推动本土创新。在国际事务层面，瓦西利乌政府明确表态，将持续推动塞浦路斯和平进程，致力于通过对话协商解决与北塞浦路斯之间的长期分歧。他同时强调，政府将继续深化与第三世界友好政权的双边关系，尤其是周边的泛阿拉伯政权（如叙利亚、利比亚），以确保塞浦路斯在全球舞台上的正当利益得到充分维护。而瓦西利乌的成功也意味着以AKEL为代表的左翼建制派依旧是塞浦路斯政坛的常青树，更证明其仍具备左右国家政局的影响力。或许这种议会民主鲜明特色的列宁主义道路在这座古铜之国的土地上，确实具备生长土壤？"


func _result_2(context: Dictionary) -> void:
	# Event697.cs:148-180
	_add_data(W.I_BUDGET, -50)
	_add_data(W.I_AGENTS, -50)
	var cyprus := _cyprus()
	var greece := ws.get_country_by_legacy_index(45)
	if greece != null and greece.government == GameConstants.Government.LIBERAL:
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.LIBERAL
			cyprus.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
				cyprus.set_tag("亲中", true)
		context["result_text"] = "选举结果宣布了AKEL-DIKO的泛左翼爱国联盟的大败：DISY党以一己之力，强势碾压AKEL、DIKO、EDEK三党，成功将前临时总统克莱里季斯推上正式总统的宝座。新政府迅速启动施政程序，着手改革国内现有的臃肿官僚体制，具体举措包括合并冗余政府部门、削减不必要的行政层级，以此全面提升政府的行政效率与政务透明度。这些改革的核心目标，一方面在于压缩财政支出，另一方面则是为私营部门营造更为宽松友好的营商环境。新政府同时推出放宽管控与普遍减税的组合政策，尤其着重降低个人所得税与企业税税率，以此刺激国内消费市场，推动本土产业（尤其是旅游业）高质量发展。此外，新政府还将加入欧共体列为施政的首要战略目标，积极追求与欧洲的一体化进程，而非延续前两届政府的施政路线，与第三世界国家加深关系。外界普遍认为，这一战略转向将为塞浦路斯带来更多的经济发展机遇与政治稳定保障。为此，新政府迅速启动与欧盟的入盟谈判，并承诺在国内推行一系列符合欧盟标准的配套改革，包括强化法治建设、改善人权状况，以及完善市场经济运行机制。看来，那些以“先总理政治卫士”自居的政党联盟，终究不过是一只纸老虎。他们所做的不过是打着“政治传统”的幌子，行极权主义之实。幸亏，自由的人民始终是站在民主这一边的。"
	elif _event_result("event_695", 1):
		if cyprus != null:
			_leave_alliances(cyprus)
			cyprus.government = GameConstants.Government.AUTHORITARIAN
			cyprus.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
		context["result_text"] = "选举结果宣布了DISY的大胜而归：DISY以一党之势力压AKEL、DIKO、EDEK三党，成功将前临时总统克莱里季斯推上了正式总统的宝座。新政府迅速着手于改革现有臃肿的官僚体制，包括合并冗余部门、削减不必要的行政层级，以提高政府效率和透明度。这些改革旨在减少财政支出，同时为私营部门创造更加宽松的营商环境。缩小管控并普遍减税，特别是降低个人所得税和企业税以刺激消费和推动产业发展。此外，新政府还明确将加入欧盟作为首要目标，积极追求与欧洲的一体化，而不是像过去两届政府那样和第三世界国家加深关系，这被认为将为塞浦路斯带来更多的经济机会和政治稳定。为此，政府迅速启动了与欧盟的谈判，并承诺在国内推行一系列符合欧盟标准的改革，包括加强法治、改善人权状况以及完善市场机制。与此同时，党内此前日益膨胀的法西斯势力，已逐步掌控了党的管理层与决策核心。大选落幕后，他们最终向党内的保守派与温和派举起屠刀，经过一番激烈的内部斗争，成功夺取了党的绝对主导权。由前进步阵线成员组成的全新核心领导层，很快便开始对那些为“伟大理想”效命的“同志”们颁布特赦令——诸如1974年临时军政府的“前总统”桑普森、政变核心策划者之一的斯卡文蒂斯等人，皆被一一恢复名誉。随后，该国以EOKA创始人格里瓦斯的遗志为最高准则，对现行旧宪法展开了大刀阔斧的修订。修宪的方向极为明确，全面向昔日希腊军政府的统治模式靠拢。带有鲜明法团主义色彩的经济规划、对土耳其族及其他少数群体愈发系统化的残酷迫害、对希腊“伟大理想”这一民族主义目标的重新高举，该组织已经构建起一个微型西班牙国。这一结果显然是土耳其和希腊还有英国政府都不乐意见到的，也许不久，我们便会见证这三个昔日的宗主国就该岛事务的某些层面，开展一场特殊的“重新合作”……"
	else:
		context["result_text"] = "选举结果正式揭晓——DISY遭遇惨败：由AKEL鼎力推举的乔治·瓦西利乌成功当选塞浦路斯历史上第三位总统，并如约兑现竞选承诺，大力扩张社会福利体系，推行针对性税制改革，核心目标在于切实减轻中低收入家庭的生活负担。新政府的首要施政任务之一，便是制定并落地一项全新的社会福利法案。该法案将进一步扩大对弱势群体的扶持范围，具体包括提高养老金发放标准、增加失业救济金额度，以及全面升级公共医疗服务质量。此外，瓦西利乌还计划推出一揽子面向中小企业的税收优惠政策，以此激发就业市场活力，推动本土创新。本着负责原则，克莱里季斯宣布辞去其在DISY党内担任的各项重要职务，以期平息这场本已近在咫尺的胜利最终却化为泡影的败选所引发的党内震荡。然而，分裂早已无可挽回：欧洲主义者与强硬保守派纷纷决裂出走，各自组建新的政党。与此同时，原本围绕竞选策略调整与党章原则的理性讨论，也日益沦为愈演愈烈的派系骂战。这个塞浦路斯最大的反对党目前已彻底陷入内斗的漩涡，难以自拔。看来，即使是民主国家，民主的胜利也并非唾手可得。"


func _result_3(context: Dictionary) -> void:
	context["result_text"] = "毕竟那地方至少没有一堵隔离墙！在政局动荡的情况下，基普里亚努不得不继续从政。大选结果是民主党的斯皮罗斯·基普里亚努获胜（同时也得到了AKEL的支持），他获得了56.5%的选票，继续担任塞浦路斯总统。投票率为95.0%。"


func _socialist_count() -> int:
	var count := 0
	for legacy_idx in [21, 29, 85, 86, 87, 92]:
		var c := ws.get_country_by_legacy_index(legacy_idx)
		if c != null and ws.is_socialism(c, true):
			count += 1
	return count


func _event_result(event_id: String, default: int) -> bool:
	if ws.completed_event_ids.has(event_id):
		return int(ws.completed_event_ids[event_id]) == default
	return ws.global_flags.get("result_%s" % event_id, -1) == default


func _copy_soc_eu_from_turkey(cyprus: CountryData) -> void:
	# Event697.cs:139-143：allcountries[85]（土耳其）是 soc_eu 时，塞浦路斯同步。
	var turkey := ws.get_country_by_legacy_index(85)
	if turkey != null and turkey.has_tag("soc_eu"):
		cyprus.set_tag("soc_eu", true)



func _cyprus() -> CountryData:
	return ws.get_country_by_legacy_index(94)


func _add_data(index: int, delta: int) -> void:
	if index >= 0 and index < d.size():
		d[index] += delta


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		d[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		d[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
