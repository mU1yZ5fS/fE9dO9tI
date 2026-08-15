extends "res://数据脚本/event_script_base.gd"

const TXT_374_DESC := "阳光、细沙、碧海，这曾是北塞浦路斯的代名词，直到“灰狼”的尖牙再度咬向圣安德烈角。自1963年起，两族的血腥较量已持续十余年，所谓“合作共和国”的构想被现实击碎，几近彻底破产。更糟的是，自1974年土耳其占领北塞浦路斯后，源源不断的安纳托利亚移民从海峡对岸涌入，占据了此前逃亡希族人的房屋与财产。据英国观察家统计，仅1977一年，塞浦路斯土耳其联邦的人口增长率便超过40%，其中可确定半数以上为土耳其本土定居者。安卡拉这一现代版本的“复地运动”让南北塞浦路斯的隔阂愈发难以逾越。而而对土族塞人而言，所谓的“独立自主”不过是片刻欣喜——作为一个未被广泛承认的地区政治实体，北塞浦路斯在国际上举步维艰：除母国土耳其外，鲜有国家愿意与这个新生联邦开展哪怕最基础的外交活动，更遑论贸易往来。北塞浦路斯只能如一叶孤舟，高度依赖地中海上的生命线，这也注定其政治上的一举一动，皆受制于多尔玛巴赫切宫。尽管如此，南北双方均未放弃推动“一国方案”的努力。南方的劳动人民进步党以及其他联邦主义左翼，都要求政府真正贯彻1960宪法的精神，为促成两族和谐，再度踏上重建合作共和国的艰难征程。而北方的土耳其共和党（CTP）和共同解放党（TKP）等一系列在野党则基于务实主义立场，反对登克塔什及民族团结党的“两国方案”政策，呼吁政府尽快与“南方友好政党”达成共识。甚至DISY的领导人克莱里季斯也是南方罕见的鸽派当权派，就私人关系而言，他与登克塔什是朋友。当然，签署《苏黎世-伦敦协定》的三大国，对塞浦路斯的未来亦拥有巨大的影响力。总体而言，我们在塞浦路斯和平进程中的操作空间着实有限，主导局势的仍是南方政权及三大国的外交立场。但，主席同志，不试试怎么知道呢？"
const TXT_374_OPT0 := "让南北塞浦路斯组成一个联邦，实现逐步和解"
const TXT_374_OPT1 := "考虑到历史问题，塞浦路斯还是归希腊人比较好"
const TXT_374_OPT1_DIS := "我们已经向土耳其做出许诺了！"
const TXT_374_OPT2 := "我记得哪份协议里很清楚地土耳其写着具有该岛主权……"
const TXT_374_OPT2_DIS := "我们不能站在伪政权那一边，否则下一次就是我们了"
const TXT_374_OPT3 := "恢复到1963年前的状态就可以了，1960建国宪法实际上没有太大问题"
const TXT_374_OPT3_DIS := "没有大问题？你是说一个只能维持三年的体制没有大问题？"
const TXT_374_OPT4 := "欧共体有这个国家吗？"
const TXT_374_R1_FAIL := "不出所料，北塞浦路斯当局与土耳其政府双双回绝了我们的提议。而由希族人主导的塞浦路斯政府也如往常一般，厉声谴责了北方的所谓“伪政权”，但他们始终对岛屿被割据分裂的残酷现实束手无策。"
const TXT_374_R1_OK := "最终，土耳其彻底放弃了其在塞浦路斯的安全诉求，干脆顺水推舟，将整座塞浦路斯岛拱手让与希腊。从土耳其本土迁徙至此的定居者，绝大多数都撤出了岛屿，这使得岛上的土族人口占比随之大幅锐减。毫无疑问，此消彼长之下，土族人面对拥有绝对人口优势的希族人，彻底陷入了无能为力的境地。理所当然地，相当一部分土族政客对土耳其母国的无情抛弃表示强烈抗议。他们"
const TXT_374_R1_UK := "在英国的秘密支持下，"
const TXT_374_R1_OK2 := "纠集了一众不愿离开的土耳其本土定居者，组建了“土耳其复兴联盟”，试图以此阻挠塞浦路斯回归希腊的进程。但这不过是螳臂当车——最终的全民公投，以高达八成的赞成票，顺利通过了塞浦路斯加入希腊的决议。尽管岛上的土耳其人组织仍将为争取自身权益持续抗争，但整座岛屿彻底走向希腊化的命运几乎已是板上钉钉。"
const TXT_374_R2_OK := "在土耳其政府的一手操控下，全岛范围的归属公投以98%的压倒性同意率，通过了塞浦路斯加入土耳其共和国的决议。其首府尼科西亚亦被正式更名为尼古萨。岛上所有承认土耳其统治的希腊裔公民均可获得在该岛的永久居住权；而那些执意反抗土耳其统治的人，则会遭到土政府的强力镇压，并被一律遣送回希腊本土。国际社会随即对土耳其兼并塞浦路斯的野蛮行径展开普遍谴责，同时亦对我们有失公允的调解工作提出严厉批评。"
const TXT_374_R2_LEAVE := "作为回应，希腊宣布脱离我们的阵营"
const TXT_374_R2_WTO := "并且加入了华约"
const TXT_374_R2_NATO := "并且加入了北约"
const TXT_374_R2_DOT := "。"
const TXT_374_R2_EMPIRE := "更加出人意料的事发生了：在塞浦路斯公投后不到一周，已经被扶持了法西斯主义傀儡政权的伊朗、伊拉克与叙利亚三国执政党几乎在同时举行了内容完全相同的全民公投，以99.9%的的支持率一致决定，为了应对周边国家的威胁（叙利亚认为来自以色列与海湾国家，伊朗认为来自阿富汗与巴基斯坦，而伊拉克认为来自科威特），与土耳其组成平等联邦才能保证自身安全，一个旧日帝国的残影似乎在中东与欧洲的交界处复活了……"
const TXT_374_R2_FAIL := "毫无疑问，希腊与塞浦路斯两国政府，皆对我们支持北方伪政权的行径予以严厉谴责。他们明确宣称：“希、塞两国的纽带只会愈发紧密，绝无可能在外部力量的操控下骤然断裂。”出于报复心态，塞浦路斯政府正式宣布加入"
const TXT_374_R2_WTO2 := "华约"
const TXT_374_R2_NATO2 := "北约"
const TXT_374_R2_FAIL2 := "，以此杜绝国际影响力日益攀升的中国对其内政的干涉。好吧，看来我们这次是真的搞砸了。唯一值得宽慰的是，土耳其方面对我们的提案深表满意，并进一步深化了与我国的双边关系。"
const TXT_374_R3_OK := "在我们的斡旋调停之下，北塞浦路斯当局最终宣告解散，重新回归1960年宪法所确立的两族分立议会旧制。双方原有的政府班底，则继续以平行政府的模式并行运作。希腊、土耳其、英国三国再度出面，成为塞浦路斯旧有体制的担保方，以维系岛内的力量平衡；同时，三方亦牵头推动两族，就部分争议议题展开缓慢的统一化磋商。然而，可以肯定的是，希族在未来很长一段时期内，都不会原谅土族人当年分裂岛屿的行径；而土族民众，亦绝不会对昔日希族施加的制度性压迫一笔勾销、既往不咎。这座暗流涌动的岛屿，正于摇摇欲坠的脆弱平衡之中，静候着下一场政治危机的爆发契机。但至少就当下而言，地中海依旧维持着表面的宁静。"
const TXT_374_R3_FAIL := "然而，我们的种种努力最终还是付诸东流。两国之间极度匮乏政治互信，令塞浦路斯统一进程不得不被无限期搁置；双方的外交官更是不约而同地，对我们提出的和解方案嗤之以鼻。塞浦路斯政府态度强硬，直言“塞浦路斯人本质上就是希腊人”，并厉声斥责这种塞浦路斯民族主义思潮，是“对历史与民族身份的公然背叛”。而北边的土族塞人政治家登克塔什也带着颇为揶揄的语气，：抛出了他的尖锐论调：“没有什么塞浦路斯民族，只有希腊人和土耳其人。不过如果你们把标准降低一点的话，确实有所谓的塞浦路斯原住民——就是这儿的驴。”显然，我们这份天真的和解构想，已遭到双方决策层的一致否决。也罢，就把这种吃力不讨好、又无足轻重的麻烦事，交给伟大的和平捍卫者——联合国去处理吧！"
const TXT_374_R4 := "我们的盈余资源不应该投入这种对我们的外交政策无益的国家。"
const TXT_374_R0_OK_LEFT := "最终，在两大宗主国的政治格局发生重大转变后，其影响不可避免地辐射至南北塞浦路斯的局势走向。南北两地的左翼势力在近期选举中占据压倒性优势，最终成功执掌各自政权。和谈进程也因此大幅减少了民族主义势力的阻挠，令长期停滞的塞浦路斯联邦构想取得了前所未有的突破性进展。在塞浦路斯劳动人民进步党与土耳其共和党的共同推动下，塞浦路斯联邦方案最终在南北双方的公投中高票通过。方案明确，未来五年内将推动南北双方逐步实现全面和解，并稳步推进政治、经济的一体化进程；与此同时，充分保障南北双方政府的独立地位。南方政府将与土耳其一道，助力北塞浦路斯土耳其族改善相对落后的经济状况，以期早日实现双方在经济层面的初步对接与均衡发展。尽管有国际观察家仍然怀疑此次会谈不过是1960宪法的另一个地域性翻版，但今非昔比，既然两大宗主国的矛盾都已经弥合，塞浦路斯岛的伤疤又何尝不能被时光抚平呢……"
const TXT_374_R0_OK_RIGHT := "最终，在两大宗主国的政治格局发生重大转变后，其影响不可避免地辐射至南北塞浦路斯的局势走向。最终，塞浦路斯政府中少见的鸽派领导人克莱里季斯提出了一份“十三点条件”（1962年马卡里奥斯用于调整国家结构的方案）的温和版，并以实行“比例代表制”为重大前提，正式倡议举行南北共同名册选举。受以土族商会为代表的温和派力量支持，以及与克莱里季斯的个人关系影响，登克塔什也罕见地缓和下来，如同在1967年谈判中接受了希族的大部分条件。而这一次，两族背后的宗主国已无意继续加码干预，也不再试图以附加条件塑造谈判结果。对于若干仍具高度争议的条款，双方一致同意采取“先行整合、后续磋商”的过渡性安排，在有限期限内实施合并措施，并将争议留待未来通过政治机制解决。就这样，两国总统共同签订了一份协议书和谅解书，塞浦路斯问题解决了……暂时。国际观察家已经指出，这只是徒有虚名的统一，只不过是一次1960年宪法的地域化翻版，依然没有解决两族之间的经济差距情况，在未来可能造成更大的族裔冲突。但至少此刻，他们之间不需要把隔离墙再修高了……"
const TXT_374_R0_UK_LEFT := "考虑到塞浦路斯已经实现和平统一、希腊与土耳其达成政治和解的大背景下，加之塞浦路斯左翼政府着重声明的去殖民化诉求，英国政府最终识趣地宣布，将永久撤出阿克罗蒂里与泽凯利亚两处主权基地区，主动放弃了这座其经营多年、被誉为“东地中海上永不沉没的航空母舰”的战略要地。实则意味着英国彻底放弃了其在中东地区的重要战略跳板，以及在黎凡特地区苦心构建的庞大情报网络。英国军方对此举表示强烈不满，不知英国左翼政府能否安然度过由此引发的一系列政治危机。"
const TXT_374_R0_UK_RIGHT := "英国试图煽风点火、阻挠塞浦路斯统一的阴谋最终破产。军方原本打算孤注一掷，却在希腊与土耳其的联合军事施压下畏缩不前。最终，陷入进退两难境地的英国政府，只得在北约的斡旋建议下，以屈辱的姿态坐下，与新生的塞浦路斯联邦开启谈判。谈判结果显示，英国被迫放弃腹背受敌的泽凯利亚基地，仅能暂时保留阿克罗蒂里基地的控制权——而该地区在未来还将就是否加入塞浦路斯联邦举行全民公投。昔日的日不落帝国，就这样灰头土脸地放弃了这片经营多年的“岛屿航母”。而保守党的拙劣处理最终必将以本土政治风暴的形式，让其付出应有的代价……"
const TXT_374_R0_UK_OTHER := "驻守塞浦路斯的英国军事人员瞬间草木皆兵，随即启动全面动员，并援引《苏黎世-伦敦协议》，高调宣称自身的“合法权益”。然而，这份充满帝国主义色彩的妥协性协议显然未被希腊、土耳其与塞浦路斯的现任政府放在眼中。三国军队迅速展开联合行动，不仅对英国基地实施全面封锁，更在海上拦截了英国的补给船队。驻守泽凯利亚的英军军官陷入绝境，最终只得选择献城投降，以换取麾下官兵的性命安全。但英国显然不会甘心接受失败的结局，这个日薄西山的帝国决意死守阿克罗蒂里的几处核心据点，随即开始大规模修筑防御工事与储备物资的地下堡垒。只是，这究竟是日不落帝国的荣光重现，还是一头病老虎在做垂死挣扎？让我们拭目以待吧……"
const TXT_374_R0_FAIL_GREAT_IDEAL := "塞浦路斯政府严正回绝了任何“背叛伟大理想”的提议，他们主张土耳其人不仅没有在此地的定居权，甚至没有生存权。这一极具挑衅性的发言直接激怒了土耳其政府和北塞方面，他们同样针锋相对地回应“绝不会与一个丧失理智的政权”相谈判。不到三十分钟，会议就草草结束了。好吧，看来社会主义的草压不过民族主义的苗。至少，英国人很高兴……"
const TXT_374_R0_FAIL_AUTH := "塞浦路斯民族政府拒绝了来自希土两方的一切和谈意向，坚定地将叛国者、左翼分子、穆斯林以及一切希腊民族的敌人都挡在那堵364公里的坚墙之外，塞浦路斯领导人如此宣称：在这片土地上的民族污点、腐败分子以及该死的本土叛徒离开维纳斯的故乡前，我们不会让任何一个野蛮的入侵者进入我们剩下的土地。希腊民族的伟大理想万岁！康斯坦丁二世陛下万岁！"
const TXT_374_R0_FAIL_OTHER := "然而，我们的种种努力最终还是付诸东流。两国之间极度匮乏政治互信，令塞浦路斯统一进程不得不被无限期搁置；双方的外交官更是不约而同地，对我们提出的和解方案嗤之以鼻。塞浦路斯政府态度强硬，直言“塞浦路斯人本质上就是希腊人”，并厉声斥责这种塞浦路斯民族主义思潮，是“对历史与民族身份的公然背叛”。而北边的土族塞人政治家登克塔什也带着颇为揶揄的语气，：抛出了他的尖锐论调：“没有什么塞浦路斯民族，只有希腊人和土耳其人。不过如果你们把标准降低一点的话，确实有所谓的塞浦路斯原住民——就是这儿的驴。”显然，我们这份天真的和解构想，已遭到双方决策层的一致否决。也罢，就把这种吃力不讨好、又无足轻重的麻烦事，交给伟大的和平捍卫者——联合国去处理吧！"


## 原作 Event374.cs：一分为二的苦柠檬（塞浦路斯问题）。
## 只移植数值/国家状态效果；长文本用英文摘要。
## 关键联锁：result2 在伊拉克(14)/伊朗(8)/叙利亚(35) 均 puppet_of==84 时
## 置 allcountries[84].parts[5]（概览.gd 伊朗页「大土耳其的一部分」分支）。


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var option_index := int(context.get("option_index", -1))
	_event_374(option_index, context)
	ws.clamp_empire_relations()
	_sync_empire_mirrors()


func _event_374(option_index: int, context: Dictionary) -> void:
	match option_index:
		0:
			_result_0(context)
		1:
			_result_1(context)
		2:
			_result_2(context)
		3:
			_result_3(context)
		4:
			_result_4(context)


func _result_0(context: Dictionary) -> void:
	var cyprus := _cyprus()
	if _greece_progressive() and _turkey_progressive() and ws.influence_prc >= 500 \
		and cyprus != null and (cyprus.government == 2 or cyprus.government == 3 or cyprus.sub_government == 16):
		# Event374.cs:192-274 成功联邦路径
		_set_data127(100)
		if cyprus != null:
			cyprus.parts.resize(1)
			cyprus.parts[0] = true
			if cyprus.government == 2 or cyprus.sub_government == 16:
				_leave_alliances(cyprus)
				cyprus.sub_government = 15
				_copy_soc_eu_from_spain(cyprus)
			else:
				cyprus.sub_government = 5
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
		ws.influence_prc += 30
		if cyprus != null and (cyprus.government == 2 or cyprus.sub_government == 16):
			context["result_text"] = TXT_374_R0_OK_LEFT + _uk_append_text()
		else:
			context["result_text"] = TXT_374_R0_OK_RIGHT + _uk_append_text()
	else:
		_set_data127(1)
		if cyprus != null and cyprus.sub_government == 1:
			context["result_text"] = TXT_374_R0_FAIL_GREAT_IDEAL
		elif cyprus != null and ws.is_authoritarian(cyprus):
			context["result_text"] = TXT_374_R0_FAIL_AUTH
		else:
			context["result_text"] = TXT_374_R0_FAIL_OTHER


func _result_1(context: Dictionary) -> void:
	var turkey := _turkey()
	if not _is_socialism_or_gov2(turkey) and (turkey == null or turkey.government != 2):
		# Event374.cs:64-67
		_set_data127(1)
		context["result_text"] = TXT_374_R1_FAIL
		return
	# Event374.cs:68-91
	_set_data127(100)
	var greece := _greece()
	if greece != null:
		greece.parts.resize(1)
		greece.parts[0] = true
	var cyprus := _cyprus()
	if cyprus != null and not cyprus.内战中:
		cyprus.set_tag("对华贸易", true)
		if greece != null:
			greece.set_tag("对华贸易", true)
	ws.influence_prc += 10
	var uk := _uk()
	var r1 := TXT_374_R1_OK
	if uk != null and ws.is_socialism(uk, false) and uk.government != 2:
		r1 += TXT_374_R1_UK
	r1 += TXT_374_R1_OK2
	context["result_text"] = r1


func _result_2(context: Dictionary) -> void:
	var cyprus := _cyprus()
	if cyprus != null and cyprus.puppet_of == 84:
		# Event374.cs:75-120 土耳其并岛路径
		_set_data127(100)
		cyprus.parts.resize(1)
		cyprus.parts[0] = true
		cyprus.chinese_name = "塞浦路斯土耳其联邦"
		_leave_alliances(cyprus)
		cyprus.government = 3
		cyprus.sub_government = 5
		cyprus.puppet_of = 84
		ws.influence_prc += 10
		_greece_reaction_to_turkish_cyprus()
		var iraq := ws.get_country_by_legacy_index(14)
		var iran := ws.get_country_by_legacy_index(8)
		var syria := ws.get_country_by_legacy_index(35)
		var all_turkish := iraq != null and iraq.puppet_of == 84 \
			and iran != null and iran.puppet_of == 84 \
			and syria != null and syria.puppet_of == 84
		if all_turkish:
			var turkey := _turkey()
			if turkey != null:
				turkey.parts.resize(6)
				turkey.parts[5] = true
				turkey.chinese_name = "大土耳其"
		var r2 := TXT_374_R2_OK
		var greece2 := _greece()
		if greece2 != null and (greece2.has_tag("econ") or greece2.has_tag("okb") or greece2.has_tag("亲中")):
			r2 += TXT_374_R2_LEAVE
			if _greece_progressive() and _ussr_ovd():
				r2 += TXT_374_R2_WTO
			elif greece2 != null and (ws.is_authoritarian(greece2) or greece2.government == 3) and _usa_nato():
				r2 += TXT_374_R2_NATO
			r2 += TXT_374_R2_DOT
		if all_turkish:
			r2 += TXT_374_R2_EMPIRE
		context["result_text"] = r2
	else:
		# Event374.cs:122-144 未并岛
		_set_data127(1)
		if cyprus != null:
			cyprus.set_tag("亲中", false)
			cyprus.set_tag("对华贸易", false)
		_greece_reaction_to_turkish_cyprus(cyprus)
		var r2c := TXT_374_R2_FAIL
		if _greece_progressive():
			r2c += TXT_374_R2_WTO2
		else:
			r2c += TXT_374_R2_NATO2
		r2c += TXT_374_R2_FAIL2
		context["result_text"] = r2c


func _result_3(context: Dictionary) -> void:
	if _greece_progressive() and _turkey_progressive():
		# Event374.cs:147-169
		var cyprus := _cyprus()
		if cyprus != null:
			if not cyprus.内战中:
				cyprus.set_tag("对华贸易", true)
			cyprus.parts.resize(1)
			cyprus.parts[0] = true
			_leave_alliances(cyprus)
			cyprus.government = 2
			cyprus.sub_government = 8
			_copy_soc_eu_from_spain(cyprus)
		_set_data127(100)
		ws.influence_prc += 10
		context["result_text"] = TXT_374_R3_OK
	else:
		_set_data127(1)
		context["result_text"] = TXT_374_R3_FAIL


func _result_4(context: Dictionary) -> void:
	_set_data127(1)
	context["result_text"] = TXT_374_R4


func _greece_reaction_to_turkish_cyprus(cyprus_for_join: CountryData = null) -> void:
	var greece := _greece()
	var ussr := ws.get_country_by_legacy_index(7)
	var usa := ws.get_country_by_legacy_index(51)
	if greece != null and (greece.has_tag("econ") or greece.has_tag("okb") or greece.has_tag("亲中")):
		_leave_alliances(greece)
	if _greece_progressive() and ussr != null and ussr.has_tag("ovd"):
		var target := cyprus_for_join if cyprus_for_join != null else greece
		if target != null:
			target.set_tag("sev", true)
			target.set_tag("ovd", true)
	elif greece != null and (ws.is_authoritarian(greece) or greece.government == 3) \
			and usa != null and usa.has_tag("nato"):
		var target := cyprus_for_join if cyprus_for_join != null else greece
		if target != null:
			target.set_tag("nato", true)


func _greece_progressive() -> bool:
	var greece := _greece()
	if greece == null:
		return false
	return ws.is_socialism(greece, true) or greece.government == 2


func _turkey_progressive() -> bool:
	var turkey := _turkey()
	if turkey == null:
		return false
	return ws.is_socialism(turkey, true) or turkey.government == 2


func _is_socialism_or_gov2(c: CountryData) -> bool:
	if c == null:
		return false
	return ws.is_socialism(c, true) or c.government == 2


func _copy_soc_eu_from_spain(cyprus: CountryData) -> void:
	var spain := ws.get_country_by_legacy_index(85)
	if spain != null and spain.has_tag("soc_eu"):
		cyprus.set_tag("soc_eu", true)


func _set_data127(v: int) -> void:
	if d.size() > 127:
		d[127] = v


func _leave_alliances(c: CountryData) -> void:
	if c == null:
		return
	for t in WorldFactory.START_CLEAR_TAGS:
		c.set_tag(t, false)
	c.puppet_of = -1


func _cyprus() -> CountryData:
	return ws.get_country_by_legacy_index(94)


func _greece() -> CountryData:
	return ws.get_country_by_legacy_index(45)


func _turkey() -> CountryData:
	return ws.get_country_by_legacy_index(84)


func _uk() -> CountryData:
	return ws.get_country_by_legacy_index(92)


func _uk_append_text() -> String:
	var uk := _uk()
	if uk == null:
		return "\n" + TXT_374_R0_UK_OTHER
	if ws.is_socialism(uk, true) or uk.government == 2:
		return "\n" + TXT_374_R0_UK_LEFT
	if uk.government == 3:
		return "\n" + TXT_374_R0_UK_RIGHT
	return "\n" + TXT_374_R0_UK_OTHER

func _ussr_ovd() -> bool:
	var ussr := ws.get_country_by_legacy_index(7)
	return ussr != null and ussr.has_tag("ovd")


func _usa_nato() -> bool:
	var usa := ws.get_country_by_legacy_index(51)
	return usa != null and usa.has_tag("nato")


func _sync_empire_mirrors() -> void:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		d[W.I_USA_RELATIONS] = ws.empires[EmpireData.USA].relations
		d[W.I_USA_INFLUENCE] = ws.empires[EmpireData.USA].power
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
		d[W.I_USSR_RELATIONS] = ws.empires[EmpireData.USSR].relations
		d[W.I_SOVIET_INFLUENCE] = ws.empires[EmpireData.USSR].power
