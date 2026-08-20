extends "res://数据脚本/event_script_base.gd"

## 原作 Event642.cs：红星照我去战斗（伟大复兴军事决策，六选项）。
## 触发：GlobalScript.cs:57 Decision d37 → decision_catalog.gd:703 start_event(642)，手动触发。
## 差异：puppetOf→puppet_of；proprc/okb→亲中/okb；战争 70-74/90 无 WarDef → 兜底创建后补名；
##   选项5 completedDecisions[37]=false → ws.decisions.completed[37]=false。

const TXT_OPT0_DIS := "我们用四百亿买到了值得的东西"
const TXT_OPT1_DIS := "我们不再有关于天池的问题了"
const TXT_OPT2_NANYANG := "下南洋，再一次"
const TXT_OPT2_JAPAN := "我们必须做好全国总动员，挽弓射日！"
const TXT_OPT2_DIS_0 := "我们无能为力"
const TXT_OPT2_DIS_1 := "我们已经夺回了过去本来就属于中华的传统势力范围——东瀛和南洋"
const TXT_OPT3_DIS_0 := "1962只是撞大运了！"
const TXT_OPT3_DIS_1 := "南亚是我们的老朋友"
const TXT_OPT4_DIS := "卧薪尝胆……苏联会为自己的轻率付出代价！"
const TXT_WAR_TAIL := "\n我会给军区首长们传达您的指令，各个军工厂已经开始全速运转，各地民兵，入伍和复员工作也在有条不紊的进行中。但是我还是想提醒您，由于先军政策及民族主义宣传的影响，我们的战争机器一旦开动起来，就很难再刹得住车。\n[color=red]我们再见了亲爱的妈妈，请你吻别您的儿子吧……[/color]"
const TXT_R0_PRE := "华国锋同志，如您所料，越南黎笋修正主义集团贼心不死，胃口堪比沙皇。他们在将老挝、柬埔寨纳入其势力范围，拼凑其所谓“印度支那联邦”后便得陇望蜀，抛出了组建东南亚版苏联的狼子野心，"
const TXT_R0_THAI_SOC := "而在不久前背叛我们的白眼狼泰国共产党也深受与越南的边境冲突之扰，"
const TXT_R0_THAI_GOV := "泰国政府也深受与越南的边境冲突之扰；"
const TXT_R0_BURMA_SOC := "缅共在我们的支持下获得了缅甸的控制权，但很快他们也和泰共一样变成了白眼狼。"
const TXT_R0_BURMA_GOV := "另一方面，缅甸军政府仍然在其东北部山区与我们支持的缅共以及民地武进行作战。"
const TXT_R0_TAIL := "我们是时候给他们屁股上狠狠来一脚了！"
const TXT_R1 := "华国锋同志，现在让我们将目光移到我国东部，放向我们的“盟友”——朝鲜。自从金日成清洗掉国内的亲苏派、亲华派，独掌大权之后，朝鲜国内对他的个人崇拜也愈发高涨。基于对其“白头山天降血脉”的建构，朝鲜不止一次通过或官方或私下的途径向我国索取整个长白山的控制权，并以退出同盟相要挟。此举堪称忘恩负义、贪得无厌：1962年，为了中朝两国友好，伟大领袖毛泽东同志就已经将半个天池让与朝鲜。1964年，“刘邓叶许反革命集团”的大头目，叛徒邓小平跟随代表团赶赴朝鲜，他与朝鲜阴谋串联，泄露我方试图收回整个天池的战略意图，最终导致此事不了了之。看来朝鲜已经忘记了是谁在联合国军的威胁下将其拖出火海了。小孩子不听话，是时候让他们得到些许教训了！"
const TXT_R2_NANYANG := "华国锋同志，让我们将目光移到我国南方，放向南洋诸国。长期以来，南洋诸国背信弃义，屡次侵犯我们的利益：他们垄断海上贸易航线，对我国商船征收高额关税，甚至放任海盗劫掠我们的货物，残害我们的同胞；他们还公然侵占我们的领土和资源，强占我们的岛屿，掠夺我们的矿产。这种赤裸裸的侵略行为，已经威胁到我们的国家主权和未来发展！"
const TXT_R2_JAPAN_PRE := "华国锋同志，如您所知的那样，二战结束后，东京审判根本没有起到根除法西斯的作用。您的名字的来源也和抗日救国先锋队有关。日本法西斯的最大头目——裕仁仍然堂而皇之地担任着日本天皇，一大批战犯也被高高举起轻轻放下。况且，日本人根本不思悔过，他们将战犯们贡入所谓“靖国神社”之中，显然，此举就是对我国和无数被其荼毒的受难者的挑衅。而在我国对朝鲜的决定性军事行动之后，美国对我国进攻日本韩国早有预案，因此其早已联合北约盟友加强对日本的武装，并动员韩国陆军协助捍卫所谓自由民主政体。《和平宪法》迅速被废除，日本自卫队被改组为日本国防军。\n我们的宣战消息一经发布，便获得了朝鲜兄弟国家的热烈拥护，朝鲜人民军将派出其东部海军和西部海军协助我们的登陆计划。作为回报，我们将会直接参与朝鲜的战争，助力该国的统一大业。要战便战！"
const TXT_R2_JAPAN_PRE_ALT := "华国锋同志，如您所知的那样，二战结束后，东京审判根本没有起到根除法西斯的作用。您的名字的来源也和抗日救国先锋队有关。日本法西斯的最大头目——裕仁仍然堂而皇之地担任着日本天皇，一大批战犯也被高高举起轻轻放下。况且，日本人根本不思悔过，他们将战犯们贡入所谓“靖国神社”之中，显然，此举就是对我国和无数被其荼毒的受难者的挑衅。而在我国对朝鲜的决定性军事行动之后，美国对我国进攻日本早有预案，因此其早已联合北约盟友加强对日本的武装。《和平宪法》迅速被废除，日本自卫队被改组为日本国防军。\n我们的宣战消息一经发布，便获得了朝鲜兄弟国家的热烈拥护，朝鲜人民军将派出其东部海军和西部海军协助我们的登陆计划。要战便战！"
const TXT_R3 := "华国锋同志，印度和我国素有间隙，与我国的友好邻邦巴基斯坦更是冲突不断。更何况，印度曾以《西姆拉条约》为由占领着我国的神圣领土藏南，这片富饶的西藏江南，虽然我们已经夺回藏南，但印度曾犯下的罪行不容忽视！此外，印度在1975年吞并了锡金，并把持着不丹的外交。我想要提醒您，这两地与藏区素有联系，甚至可以说是西藏的分支。印度虽然现在势力不强，但仍有成为一个强国的潜质，这对于我们实现伟大复兴的计划是一个不小的隐患。印度素有散装之称，在英国到来之前甚至没有一个统一国家的概念，所以我们的计划是彻底废掉印度！"
const TXT_R4 := "华国锋同志，让我们看看我们北方的邻居，我们的“老大哥”，苏联吧。自从斯大林同志去世，赫鲁晓夫上台以来，中苏关系就陷入冰点。原本我们是好同志，自然可以搁置所有的领土争端，但今时不同往日，苏联已经变成了社会帝国主义国家，甚至有时与美帝国主义狼狈为奸。再加上蒙古问题，苏联的坦克只需要几个小时就能从中蒙边界杀到北京，卧榻之侧岂容他人酣睡，这对我国的国防安全是极大的威胁。现在是时候让这群老毛子们见识一下我们的厉害了！"
const TXT_R5 := "我会让服务生同志给您送上一杯茶的，希望您真的没有想到去做什么疯狂的事情……"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 6:
		return
	var opt := event_def.options
	var vietnam := ws.get_country_by_legacy_index(11)
	var korea := ws.get_country_by_legacy_index(10)
	var philippines := ws.get_country_by_legacy_index(47)
	var indonesia := ws.get_country_by_legacy_index(50)
	var png := ws.get_country_by_legacy_index(134)
	var thailand := ws.get_country_by_legacy_index(34)
	var japan := ws.get_country_by_legacy_index(44)
	var india := ws.get_country_by_legacy_index(19)
	var pakistan := ws.get_country_by_legacy_index(31)
	if vietnam == null or vietnam.puppet_of != GameConstants.LegacySlot.CHINA:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if korea == null or korea.puppet_of != GameConstants.LegacySlot.CHINA:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	var sea_free := (philippines == null or philippines.puppet_of != GameConstants.LegacySlot.CHINA) \
		and (indonesia == null or indonesia.puppet_of != GameConstants.LegacySlot.CHINA) \
		and (png == null or png.puppet_of != GameConstants.LegacySlot.CHINA)
	var thai_ok := thailand != null and thailand.has_tag("亲中") and thailand.has_tag("okb")
	if sea_free and thai_ok:
		_enable(opt[2], TXT_OPT2_NANYANG)
	elif (philippines != null and philippines.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (indonesia != null and indonesia.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (png != null and png.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (japan == null or japan.puppet_of != GameConstants.LegacySlot.CHINA):
		_enable(opt[2], TXT_OPT2_JAPAN)
	elif not thai_ok:
		_disable(opt[2], TXT_OPT2_DIS_0)
	else:
		_disable(opt[2], TXT_OPT2_DIS_1)
	var pak_ok := pakistan != null and pakistan.has_tag("亲中")
	if (india == null or india.puppet_of != GameConstants.LegacySlot.CHINA) and pak_ok:
		_enable(opt[3], event_def.options[3].text)
	elif not pak_ok:
		_disable(opt[3], TXT_OPT3_DIS_0)
	else:
		_disable(opt[3], TXT_OPT3_DIS_1)
	var china := ws.get_country_by_legacy_index(1)
	var parts_ok := china != null and not (china.parts.size() > 11 and china.parts[11])
	if (india != null and india.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (philippines != null and philippines.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (korea != null and korea.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (vietnam != null and vietnam.puppet_of == GameConstants.LegacySlot.CHINA) \
			and (japan != null and japan.puppet_of == GameConstants.LegacySlot.CHINA) \
			and parts_ok and _res(W.I_ARMY) >= 5000:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], TXT_OPT4_DIS)
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var thailand := ws.get_country_by_legacy_index(34)
			var burma := ws.get_country_by_legacy_index(33)
			var text := TXT_R0_PRE
			text += TXT_R0_THAI_SOC if ws.is_socialism(thailand, true) else TXT_R0_THAI_GOV
			text += TXT_R0_BURMA_SOC if ws.is_socialism(burma, true) else TXT_R0_BURMA_GOV
			context["result_text"] = text + TXT_R0_TAIL + TXT_WAR_TAIL
			_start_war(71, "中华人民共和国", "东南亚诸国", "东南亚之征")
			_war_stats()
		1:
			context["result_text"] = TXT_R1 + TXT_WAR_TAIL
			_start_war(72, "中华人民共和国", "朝鲜", "中朝之战")
			_war_stats()
		2:
			var philippines := ws.get_country_by_legacy_index(47)
			var indonesia := ws.get_country_by_legacy_index(50)
			var png := ws.get_country_by_legacy_index(134)
			var korea := ws.get_country_by_legacy_index(10)
			var sea_free := (philippines == null or philippines.puppet_of != GameConstants.LegacySlot.CHINA) \
				and (indonesia == null or indonesia.puppet_of != GameConstants.LegacySlot.CHINA) \
				and (png == null or png.puppet_of != GameConstants.LegacySlot.CHINA)
			if sea_free:
				context["result_text"] = TXT_R2_NANYANG + TXT_WAR_TAIL
				_start_war(73, "中华人民共和国", "南洋诸国", "南洋之征")
			else:
				var parts0 := korea != null and korea.parts.size() > 0 and korea.parts[0]
				if not parts0:
					context["result_text"] = TXT_R2_JAPAN_PRE + TXT_WAR_TAIL
					_start_war(90, "中国—朝鲜", "日本—韩国", "落日战争", 600, 400)
				else:
					context["result_text"] = TXT_R2_JAPAN_PRE_ALT + TXT_WAR_TAIL
					_start_war(90, "中国—朝鲜", "日本", "落日战争", 700, 300)
			_war_stats()
		3:
			context["result_text"] = TXT_R3 + TXT_WAR_TAIL
			_start_war(74, "中华人民共和国", "印度及其卫星国", "南亚之征")
			_war_stats()
		4:
			context["result_text"] = TXT_R4 + TXT_WAR_TAIL
			_start_war(70, "中华人民共和国", "苏联及蒙古", "雪耻之战")
			_war_stats()
		5:
			context["result_text"] = TXT_R5
			if ws.decisions != null and ws.decisions.completed.size() > 37:
				ws.decisions.completed[37] = false


func _war_stats() -> void:
	_add(W.I_PARTY_SUPPORT, 300)
	_add(W.I_PEOPLE_SUPPORT, 300)
	_add(W.I_THOUGHT_FREEDOM, -200)
	_add(W.I_DIPLO, 150)
	_add(W.I_BUDGET, -50)
	_add(W.I_AGENTS, -100)
	_add(W.I_ARMY, -200)
	_add(W.I_POPULATION, 2)
	_add_relation(EmpireData.USSR, -500)
	_add_power(EmpireData.USSR, -15)
	_add_relation(EmpireData.USA, -500)
	_add_power(EmpireData.USA, -15)
	ws.influence_prc += 15


func _start_war(war_id: int, side1: String, side2: String, war_name: String, infl1: int = 500, infl2: int = 500) -> void:
	# 原版全部为 SovietSupportDefender.AmericanSupportDefender → usa_side=2、ussr_side=2
	GameManager.start_war(war_id, side1, side2, infl1, infl2, 2, 2)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		# Event641 的 war70 TickTime(4) 与 Event642 的 TickTime(12) 不同源；
		# WarCatalog 默认 4 对齐 Event641，这里覆盖为 Event642 的 12。
		if war_id == 70:
			ws.wars[war_id].fortnight_max = 12
