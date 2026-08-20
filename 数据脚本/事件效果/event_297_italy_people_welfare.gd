## 原作 Event297.cs：人民的福祉是最高的法律（意大利北约“短剑”线，四选项）。
## 触发：全目录搜索无 this_num_event = 297 / Reset(297)；链外 REST 段，原版无自动条件。
## 差异：allcountries[51]=美国（world_factory 行 51），[87]=葡萄牙；原版即如此；
##  now_leader→current_leader；inflCh→influence_china；isNATO/isEU/isSocEU 映射为 nato/eu/soc_eu。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT0_DIS := "我们可不能给战略合作伙伴背后一刀"
const TXT_OPT1_DIS := "苏联人可不会听我们的"
const TXT_OPT2_DIS := "意大利激进主义者已全军覆没"
const TXT_OPT1_DIS_A := "苏联人可不会听我们的"
const TXT_OPT1_DIS_B := "我们可不能给战略合作伙伴背后一刀"
const TXT_OPT2_DIS_A := "意大利激进主义者已全军覆没"
const TXT_OPT2_DIS_B := "我们可不能给战略合作伙伴背后一刀"
const TXT_R0_A := "意大利社会内保守-进步两强并立的格局，以及该国社会对于安全部门滥权广泛不满的政治现实注定了来自该国情报内线的猛料与文奇格拉口供必然会大有市场。很快，作为该国进步派门面的《浓缩精华》与以政治讽刺闻名的《宣言》便刊登了题为《短剑，针对意大利的背后一刀》的系列文章，并在其中系统性揭露了北大西洋联盟出于反共产主义政治目的设立“后备防御计划”，并借此深度渗透意大利政界，事实上参与破坏社会改革议程与威胁民主生态的各项事实：丰塔纳广场爆炸、针对前总理阿尔多·莫罗的绑架案与近期的博洛尼亚惨案皆是相关政策的畸形产儿。出于将以意大利共产党为代表的政治左翼与革新阵营孤立在外的需要，以天主教民主党为首的意大利国内建制派不惜诉诸政治暴力，一面将国内新法西斯主义者作为自身打击左翼阵营的政治黑手套；一面则积极采取暴力弹压措施打击社会运动家，加剧社会紧张局势的同时促成前者向恐怖主义转向。最终起到加剧社会对立，让该国公民不得不将自身安全诉诸于国家权威与日趋收拢的警察体制的作用。与此同时，这一计划亦涉及相当规模的密室决策与内部交易（自然包括60-70年代期间军方试图针对阿尔多·莫罗政府组织的一系列未遂政变，洛克希德公司为推广自身装备而向意大利军方支付巨额贿赂的行径，以及意大利资产阶级为履行“国际义务”而同黑手党、安全部门、乃至国际反共恐怖网络合谋组织恐怖主义活动的大规模政治操作）。上述猛料的揭露自然而然地引爆了意大利社会热点，并直接促成了约有百万人参与的“打倒寡头求公义，北约基地滚出去”全国示威运动：就连共产党控制下的工会与青年团们亦纷纷选择加入其中，试图借此机会让昔日的保守主义巨头与核心角色天民党名誉扫地。而他们很快便如偿所愿——后者的政治影响力正以肉眼可见的速度衰退，组织亦在党内大佬尝试逃避司法调查的过程中自我解体，事实上宣告了其作为一股成建制政治势力的终结。然而，试图倒逼意大利退出北大西洋联盟的做法则招致了强烈反弹。考虑到“后卫计划”恰是为意大利政治乱局而准备，针对意大利的背后一刀很快便降临全国。前内务部长弗朗切斯科·科西加在美国的支持下宣布建立临时政府并引入全国戒严，意大利陆军与北约武装力量则在随后迅速开入罗马、米兰、都灵等主要城市实施清场并宵禁，仅以付出数千人流血与多处城区化作瓦砾的代价便果断地重建了秩序。接下来自然是对借题发挥者的清算……"
const TXT_R0_B := "意大利社会内保守-进步两强并立的格局，以及该国社会对于安全部门滥权广泛不满的政治现实注定了来自该国情报内线的猛料与文奇格拉口供必然会大有市场。很快，作为该国进步派门面的《浓缩精华》与以政治讽刺闻名的《宣言》便刊登了题为《短剑，针对意大利的背后一刀》的系列文章，并在其中系统性揭露了北大西洋联盟出于反共产主义政治目的设立“后备防御计划”，并借此深度渗透意大利政界，事实上参与破坏社会改革议程与威胁民主生态的各项事实：丰塔纳广场爆炸、针对前总理阿尔多·莫罗的绑架案与近期的博洛尼亚惨案皆是相关政策的畸形产儿。出于将以意大利共产党为代表的政治左翼与革新阵营孤立在外的需要，以天主教民主党为首的意大利国内建制派不惜诉诸政治暴力，一面将国内新法西斯主义者作为自身打击左翼阵营的政治黑手套；一面则积极采取暴力弹压措施打击社会运动家，加剧社会紧张局势的同时促成前者向恐怖主义转向。最终起到加剧社会对立，让该国公民不得不将自身安全诉诸于国家权威与日趋收拢的警察体制的作用。与此同时，这一计划亦涉及相当规模的密室决策与内部交易（自然包括60-70年代期间军方试图针对阿尔多·莫罗政府组织的一系列未遂政变，洛克希德公司为推广自身装备而向意大利军方支付巨额贿赂的行径，以及意大利资产阶级为履行“国际义务”而同黑手党、安全部门、乃至国际反共恐怖网络合谋组织恐怖主义活动的大规模政治操作）。上述猛料的揭露自然而然地引爆了意大利社会热点，并直接促成了约有百万人参与的“打倒寡头求公义，北约基地滚出去”全国示威运动：就连共产党控制下的工会与青年团们亦纷纷选择加入其中，试图借此机会让昔日的保守主义巨头与核心角色天民党名誉扫地。而他们很快便如偿所愿——后者的政治影响力正以肉眼可见的速度衰退，组织亦在党内大佬尝试逃避司法调查的过程中自我解体，事实上宣告了其作为一股成建制政治势力的终结。意识到民意难违，亦不想重蹈天民党覆辙。幸存的意大利政客们在汹涌的游行与抗议潮前，乃至国际社会的压力下自然选择如其所愿：以捍卫国家主权，重申历史正义为名。意大利直截了当地驱逐了外国基地，并退出了北大西洋联盟与西方一体化架构。"
const TXT_R1_A := "意大利社会内保守-进步两强并立的格局，以及该国社会对于安全部门滥权广泛不满的政治现实注定了来自该国情报内线的猛料与文奇格拉口供必然会大有市场。意识到这将成为在西方阵营内制造不和的良机，我们很快便与社会主义阵营达成了共识：不久后，作为意大利共产党喉舌的《统一报》与以政治讽刺闻名的《宣言》便刊登了题为《短剑，针对意大利的背后一刀》的系列文章，并在其中系统性揭露了北大西洋联盟出于反共产主义政治目的设立“后备防御计划”，并借此深度渗透意大利政界，事实上参与破坏社会改革议程与威胁民主生态的各项事实：丰塔纳广场爆炸、针对前总理阿尔多·莫罗的绑架案与近期的博洛尼亚惨案皆是相关政策的畸形产儿。出于将以意大利共产党为代表的政治左翼与革新阵营孤立在外的需要，以天主教民主党为首的意大利国内建制派不惜诉诸政治暴力，一面将国内新法西斯主义者作为自身打击左翼阵营的政治黑手套；一面则积极采取暴力弹压措施打击社会运动家，加剧社会紧张局势的同时促成前者向恐怖主义转向。最终起到加剧社会对立，让该国公民不得不将自身安全诉诸于国家权威与日趋收拢的警察体制的作用。与此同时，这一计划亦涉及相当规模的密室决策与内部交易（自然包括60-70年代期间军方试图针对阿尔多·莫罗政府组织的一系列未遂政变，洛克希德公司为推广自身装备而向意大利军方支付巨额贿赂的行径，以及意大利资产阶级为履行“国际义务”而同黑手党、安全部门、乃至国际反共恐怖网络合谋组织恐怖主义活动的大规模政治操作）。上述猛料的揭露自然而然地引爆了意大利社会热点，并直接促成了约有百万人参与的“打倒寡头求公义，北约基地滚出去”全国示威运动：就连共产党控制下的工会与青年团们亦纷纷选择加入其中，试图借此机会让昔日的保守主义巨头与核心角色天民党名誉扫地。而他们很快便如偿所愿——后者的政治影响力正以肉眼可见的速度衰退，组织亦在党内大佬尝试逃避司法调查的过程中自我解体，事实上宣告了其作为一股成建制政治势力的终结。然而，试图倒逼意大利退出北大西洋联盟的做法则招致了强烈反弹。考虑到“后卫计划”恰是为意大利政治乱局而准备，针对意大利的背后一刀很快便降临全国。前内务部长弗朗切斯科·科西加在美国的支持下宣布建立临时政府并引入全国戒严，意大利陆军与北约武装力量则在随后迅速进入罗马、米兰、都灵等主要城市实施清场并宵禁，仅以付出数千人流血与多处城区化作瓦砾的代价便果断地重建了秩序。接下来自然是对借题发挥者的清算……"
const TXT_R1_B := "意大利社会内保守-进步两强并立的格局，以及该国社会对于安全部门滥权广泛不满的政治现实注定了来自该国情报内线的猛料与文奇格拉口供必然会大有市场。意识到这将成为在西方阵营内制造不和的良机，我们很快便与社会主义阵营达成了共识：不久后，作为意大利共产党喉舌的《统一报》与以政治讽刺闻名的《宣言》便刊登了题为《短剑，针对意大利的背后一刀》的系列文章，并在其中系统性揭露了北大西洋联盟出于反共产主义政治目的设立“后备防御计划”，并借此深度渗透意大利政界，事实上参与破坏社会改革议程与威胁民主生态的各项事实：丰塔纳广场爆炸、针对前总理阿尔多·莫罗的绑架案与近期的博洛尼亚惨案皆是相关政策的畸形产儿。出于将以意大利共产党为代表的政治左翼与革新阵营孤立在外的需要，以天主教民主党为首的意大利国内建制派不惜诉诸政治暴力，一面将国内新法西斯主义者作为自身打击左翼阵营的政治黑手套；一面则积极采取暴力弹压措施打击社会运动家，加剧社会紧张局势的同时促成前者向恐怖主义转向。最终起到加剧社会对立，让该国公民不得不将自身安全诉诸于国家权威与日趋收拢的警察体制的作用。与此同时，这一计划亦涉及相当规模的密室决策与内部交易（自然包括60-70年代期间军方试图针对阿尔多·莫罗政府组织的一系列未遂政变，洛克希德公司为推广自身装备而向意大利军方支付巨额贿赂的行径，以及意大利资产阶级为履行“国际义务”而同黑手党、安全部门、乃至国际反共恐怖网络合谋组织恐怖主义活动的大规模政治操作）。上述猛料的揭露自然而然地引爆了意大利社会热点，并直接促成了约有百万人参与的“打倒寡头求公义，北约基地滚出去”全国示威运动：就连共产党控制下的工会与青年团们亦纷纷选择加入其中，试图借此机会让昔日的保守主义巨头与核心角色天民党名誉扫地。而他们很快便如偿所愿——后者的政治影响力正以肉眼可见的速度衰退，组织亦在党内大佬尝试逃避司法调查的过程中自我解体，事实上宣告了其作为一股成建制政治势力的终结。意识到民意难违，亦不想重蹈天民党覆辙。幸存的意大利政客们在汹涌的游行与抗议潮前，乃至国际社会的压力下自然选择如其所愿：以捍卫国家主权，重申历史正义为名。意大利直截了当地驱逐了外国基地，并退出了北大西洋联盟与西方一体化架构。"
const TXT_R2 := "我们送来的消息可说是正中该国激进活动家的下怀——自“火热之秋”与“铅色岁月”以来，为争取意大利社会革新而战者便苦于该国安保体制与层峦叠嶂的反恐措施久矣。如今，随着策划意大利低烈度内战的司令部伙同其在国内各处设立的触须暴露，激进派们（尤其是同“红色旅”这般热心直接攻打帝国主义心脏的城市游击队）终于取得直捣黄龙的机会。于是，新的斗争至此开始：针对军事基地的纵火、爆炸等破坏事件层出不穷；数位政府部长与北约驻意大利军官惨遭刺杀，其尸体则被悬挂在吊灯前公开示众；意大利情报部门总部更是被内部潜伏的大鼹鼠给付之一炬，成就了20世纪版本的“罗马大火”。上述行为得以沉重打击该国建制派的嚣张气焰，并在官僚队伍中种下混乱与恐惧种子。借助意大利国内乱作一团的良机，自管社会中心与占领社会运动得以迎来全新高潮，发起了对该国公务员的左勾拳；反对派们亦发现了当局的弱点而积极登台亮相，试图借助游行示威交换其心仪的政治提案；有关国家安全的讨论亦开始持续升温，事实上成为当前该国的核心议题；现行政府则因其无法在政治暴力中捍卫民众安全而民心尽失，不得不将相关事务予以同样因袭击而颜面无光，但靠着“专业户”身份保存最后尊严的安全部门。考虑到局势已然无法收拾，后者自然而然地拉来了老朋友弗朗切斯科·科西加与大西洋对岸的联合武装部队下猛药。很快，“后卫计划”便在加上苏联驻匈经验的基础上取得了用武之地——政治自由被“暂时”封存；群众团体们宣告自我解散；自管社会中心在炮击下被迅速净空；格杀勿论成为执法基本准则；活动家将同恐怖分子等量齐观的政治公式实现广泛推广。“以暴制暴”的策略就这样开始实行……"
const TXT_R3 := "考虑到这一“后卫计划”的规模巨大，且同意大利的传统盟友高度绑定。以及意大利安全部门深度干预国家内政的政治生态。贸然公布并借此引爆社会热点极有可能导致该国建制派选择直接复刻“土耳其模式”（即在民主制度遭受威胁的情况下引入作为“民主制度的捍卫者”的军方直截了当地取缔政治自由，以军事当局主导下的文官政府取而代之）。况且，既然我们已能通过得知该计划的内幕把握意大利的深层国家运转机制，并借机将暗线插入其中。我们大可以尝试选择相对更“安全妥当”的办法——比如说密室政治与内幕交易等直接打击该国政治公信力的线报。相较于那些直接将意大利卷入冷战前线的要闻，它们显然更加地无害……或者说只是多了层保护色……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var usa := world.get_country_by_legacy_index(51)
	var italy := world.get_country_by_legacy_index(85)
	var usa_free := usa != null and not usa.has_tag("对华贸易") and not usa.has_tag("asean")
	var relres := world.get_flag("relres")
	var italy_radical := italy != null and (italy.内战中 or italy.政变中)
	var opt := event_def.options
	if usa_free:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if usa_free and relres:
		_enable(opt[1], event_def.options[1].text)
	elif not relres:
		_disable(opt[1], TXT_OPT1_DIS_A)
	else:
		_disable(opt[1], TXT_OPT1_DIS_B)
	if usa_free and italy_radical:
		_enable(opt[2], event_def.options[2].text)
	elif not italy_radical:
		_disable(opt[2], TXT_OPT2_DIS_A)
	else:
		_disable(opt[2], TXT_OPT2_DIS_B)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	var usa_hard := usa != null and (usa.current_leader == 2 or usa.current_leader == 0) \
			and ussr != null and usa.power > ussr.power + ws.influence_prc
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if usa_hard:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, 10)
				ws.influence_prc -= 5
				_set_data(182, 0)
				_add(175, -999)
				if italy != null:
					italy.government = GameConstants.Government.AUTHORITARIAN
					italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					italy.influence_china = 0
					italy.set_tag("亲美", true)
					italy.set_tag("对华贸易", false)
					italy.set_tag("soc_eu", false)
				if portugal != null:
					portugal.special -= 5
				context["result_text"] = TXT_R0_A
			else:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, -50)
				ws.influence_prc += 20
				_add(179, 2)
				_add(175, -999)
				if italy != null:
					italy.set_tag("亲美", false)
					italy.set_tag("nato", false)
					italy.set_tag("eu", false)
				if portugal != null:
					portugal.special -= 5
				context["result_text"] = TXT_R0_B
		1:
			if usa_hard:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, 10)
				ws.influence_prc -= 5
				_set_data(182, 0)
				_add(175, -999)
				if italy != null:
					italy.government = GameConstants.Government.AUTHORITARIAN
					italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					italy.set_tag("亲美", true)
					italy.set_tag("对华贸易", false)
					italy.influence_china = 0
					italy.set_tag("soc_eu", false)
				if portugal != null:
					portugal.special -= 5
				context["result_text"] = TXT_R1_A
			else:
				_add(W.I_BUDGET, -80)
				_add(W.I_AGENTS, -80)
				_add_relation(EmpireData.USA, -250)
				_add_relation(EmpireData.USSR, 150)
				_add_power(EmpireData.USA, -50)
				_add_power(EmpireData.USSR, 20)
				ws.influence_prc += 10
				_add(178, 2)
				_add(175, -999)
				if italy != null:
					italy.set_tag("亲美", false)
					italy.set_tag("nato", false)
					italy.set_tag("eu", false)
				if portugal != null:
					portugal.special -= 5
				context["result_text"] = TXT_R1_B
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 20
			_add_power(EmpireData.USA, -50)
			_add_relation(EmpireData.USA, -250)
			_add(134, 100)
			_add(W.I_SERVICES, 10)
			if italy != null:
				if italy.level_of_development > 25:
					italy.level_of_development = 25
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				italy.set_tag("亲美", true)
				italy.set_tag("对华贸易", false)
				italy.influence_china = 0
				italy.set_tag("soc_eu", false)
			if portugal != null:
				portugal.special -= 5
			context["result_text"] = TXT_R2
		3:
			_set_data(183, 3)
			context["result_text"] = TXT_R3




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	PoliticianSystem.copy_leader_appearance(ws.leader, p)

