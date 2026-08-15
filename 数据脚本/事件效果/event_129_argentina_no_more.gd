extends "res://数据脚本/event_script_base.gd"

## 原作 Event129.cs：我们不能再忍受了（5 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_TITLE := "我们不能再忍受了"
const TXT_DESC := "随着1981年多党联合参政的政局形成，集会权与言论自由权得以恢复，新任阿根廷央行行长接手了一个在高企利率下挣扎的经济体，并改变了紧缩的货币政策，开始了经济自由化的尝试。6年来，断断续续的工资冻结、产量限制政策与戒严性措施使得人均GDP触底了1968年以来的最低水平，实际工资水平更是仅为约40%。军政府希望无限期推迟选举，而要求举行选举的示威活动迅速进行，1982年12月16日，五月广场举行的抗议活动被警察暴力镇压，造成了一名示威者死亡的流血事件。在销毁了约3万名政治异见者失踪的证据后，军政府开始了向民主化过渡的准备。然而，1983年2月，布宜诺斯艾利斯警察署长拉蒙·坎普斯公开承认了这些事实，并表示“失踪者实际已经死亡”。对坎普斯的采访激起了广泛民愤，迫使当局颁布了一项新法律：取消对政党的绝大多数限制，并恢复人权，同时召开选举。选举基于1957年所谓“解放革命”的军事独裁时期强加的宪法文本，规定总统由间接选举、任期六年、不可连任。选举的主要候选党派如下：社会民主主义的激进公民联盟（CRU）、庇隆主义中间派的正义党（JP）、工会-工团主义的不妥协党（NP）。与此同时，庇隆主义极左派组织“蒙东内罗斯”创建了合法的真庇隆党（APP），挤进了选举的门槛。"
const TXT_OPT0 := "劳尔·阿方辛，激进公民联盟（社会民主主义）"
const TXT_OPT1 := "伊塔洛·卢德尔，正义党（温和主义）"
const TXT_OPT2 := "奥斯卡·阿伦德，不妥协党（民主社会主义）"
const TXT_OPT3 := "马里奥·菲尔梅尼奇，真庇隆党（国控社会主义）"
const TXT_OPT4 := "保持距离"
const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_OPT3_DIS := "庇隆主义极左派已全军覆没"
const TXT_R4 := "阿方辛以“有了民主，然后有所食、有所医、有所学”的口号开启了他的任期。在劳尔·阿方辛执政期间，通胀率居高不下，公共债务大幅增加，工人接连罢工、军方情绪不满。由于财政支出与货币发行的急剧增加，在阿方辛任期的最后一年，阿根廷陷入了严重的经济危机，体现为恶劣的通货膨胀与急性的货币贬值。他以高筑外债推行的经济政策导致了1988年债务违约危机，使高速通胀恶化为了恶性通胀，经济增长怠缓，GDP从1030亿美元下跌到769亿美元，结果是，国有企业不得不转向大规模私有化。与此同时，政府禁止了工资集体谈判，宣布了对庇隆主义工会组织劳工总联盟（CGT）的禁令，同工会爆发了激烈冲突。阿方辛是一名坚定的人权维护者，在对前军政府成员的依法起诉上作出了贡献。在他的任期内，一些普通军官与上层文官被定罪并判处不同刑期。他也是“德里六国协定”的创始人之一，倡导裁剪核军备与缓和世界关系。此外，他还出台了保护人权与私有财产、保护少数民族与原住民的法律。纵观他的任期，一面是社会改革与完善法制民主，一面是私有化与迫害工会运动。"
const TXT_R5 := "卢德尔一向态度温和，这为他赢得了党内党外政界的普遍尊重，也使他同军政府维持着微妙的关系。在1976年政变之前，他曾是取代总统玛丽亚·伊莎贝尔·庇隆夫人呼声最大的潜在候选人。在大选中，卢德尔提出了依靠建设“法治国家”的口号，提出了依靠劳工总联盟（CGT），通过使国家在政治经济中占据主导地位，从而构建各阶级之间的“契约”的概念。卢德尔对伊莎贝尔·庇隆夫人的形象大加赞赏，认为“她的作用被普遍低估了，对国家的功绩被明显忽视了”。在稳固权力后，卢德尔着手重申庇隆主义运动，声称“庇隆主义已经被遗弃，取而代之的是政党官僚体制。为了在有违道德的选举中获胜，庇隆主义者已经忘记了同历史盟友的纽带，致使选举产生的高位填满了骗子和暴徒”。在一系列的集体解职与清洗后，卢德尔以建设“合作国家”的形式开始组织改革。劳总盟被设立为国家工会、工人与雇主强制参会，成立由计划部管辖的半国有企业，在各个经济领域充当龙头，并得到国家的支持与优惠。前极右翼庇隆主义者何塞·洛佩兹·雷加被接纳进入部门的管理岗位。"
const TXT_R3 := "阿伦德是一贯的反庇隆主义者与反共主义者，一方面他全力支持对庇隆主义遗产的清理与禁止，一方面他不念反对庇隆独裁时期与共产党的合作，将马克思主义者排除在执政班底之外。1972年，由于军政府禁止使用旧党名，阿伦德成立了不妥协党（IP）。在1983年国家重建状态结束后，不妥协党再次参加该年的选举，分别提名奥斯卡·阿伦德与利桑德罗·维亚莱为总统与副总统的候选人。阿伦德决定再次组建人民革命联盟，包含了蒙东内罗斯的合法组织真庇隆党（APP)、共产党、阿根廷人民联盟、基督教民主党与一些小型温和左翼与左倾中立政党。在国家全面衰退、贫困加剧的形势下，这一松散的政治联盟赢得了大选，并首先对对庇隆主义的右派与中间派展开了清算。庇隆主义的劳工总联盟（CGT）领导人因涉嫌在伊莎贝尔·庇隆夫人当政期间参与独裁统治和纵容反共联盟（AAA）的恐怖活动而被捕，工会本身也被拆分为数个地区级别的独立组织；“肮脏战争”的所有参与者，包括他们的头目何塞·洛佩兹·雷加，因无数起谋杀罪名遭到通缉；卢德尔与其他正义党（JP）领导人因支持和参与军政府政权的暴政与暴行而被捕，正义党本身被取缔。与此同时所有国有企业被拆分重组为工业综合体，大批国有企业管理者被清洗，军政府统治下膨胀的官僚编制得以减少。国家开始鼓励工会活动，工会有权决定工作条件，雇佣合同须经过工会同意才能成立。作为反通胀政策的一环，阿根廷进行了货币贬值，并紧急补充了黄金储备。"
const TXT_R1 := "1983年，蒙东内罗斯通过散发街头小报与出版《声音报》，影响了庇隆主义的不妥协党、动员运动以及正义党，吸引了部分温和主义与中间派的庇隆主义者与选民。对于左翼政治活动人士的几次特赦也助长了真庇隆党的声望与力量。马里奥·菲尔梅尼奇通过与共产党及左翼运动组建选举联盟，同时掌握了对庇隆主义劳工总联盟（CGT）的控制权，从而得以动员广大选民，赢得了本次选举。在掌权之后，菲尔梅尼奇立即对军政府和阿根廷反共联盟（AAA）的成员、肮脏战争的参与者，以及伊莎贝尔·庇隆夫人展开了清算。在清扫“爬满了杀害诚实工人与积极分子的恐怖暴徒”的政治界后，1957年宪法被宣布废除，取而代之的是一个立宪委员会，其中包括以真庇隆党为核心的真庇隆主义联盟、正义党以及一些无关紧要的组织（以彰显民主实质）。阿根廷转变为了总统共和制国家，议会在单一成员选区的基础上产生，这使得真庇隆党得以通过劳总盟获得多数席位。在经济领域，菲尔梅尼奇宣布劳总盟为国家总工会，全国工人强制参会，所有国有企业被拆分重组为工业综合体，大批国有企业管理者被清洗，军政府统治下膨胀的官僚编制得以减少。计划部宣布将启动一项经济规划，以促进阿根廷工业的发展与繁荣。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var argentina := world.get_country_by_legacy_index(71)
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	_enable(opt[1], TXT_OPT1)
	_enable(opt[2], TXT_OPT2)
	if argentina != null and argentina.government == 3:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], TXT_OPT4)


func _enable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = ""
	opt.enable_condition = null


func _disable(opt: EventOption, text: String) -> void:
	opt.text = text
	opt.disabled_text = text
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _proprc_suffix(c: CountryData) -> String:
	return TXT_PROPRC_YES if c.has_tag("亲中") else TXT_PROPRC_NO

func _get_winner_in_america(country: CountryData, ideo: Array, sup: Array, coef: float, party: int) -> int:
	if country == null:
		return -1
	var sg := country.sub_government
	if sg >= 0 and sg < 10 and ideo[sg]:
		sup[sg] -= float(country.level_of_instability)
		sup[sg] += float(country.level_of_development)
	if sg - 1 >= 0 and sg - 1 < 10 and ideo[sg - 1]:
		sup[sg - 1] -= float(country.level_of_instability) / 4.0
		sup[sg - 1] += float(country.level_of_development) / 2.0
	if sg + 1 <= 9 and sg + 1 < 10 and ideo[sg + 1]:
		sup[sg + 1] -= float(country.level_of_instability) / 4.0
		sup[sg + 1] += float(country.level_of_development) / 2.0
	if not ideo[sg]:
		if sg >= 1 and sg <= 3:
			if ideo[1]:
				sup[1] -= float(country.level_of_instability) / 4.0
				sup[1] += float(country.level_of_development) / 2.0
			elif ideo[2]:
				sup[2] -= float(country.level_of_instability) / 4.0
				sup[2] += float(country.level_of_development) / 2.0
			elif ideo[3]:
				sup[3] -= float(country.level_of_instability) / 4.0
				sup[3] += float(country.level_of_development) / 2.0
		elif sg >= 4 and sg <= 6:
			if ideo[4]:
				sup[4] -= float(country.level_of_instability) / 4.0
				sup[4] += float(country.level_of_development) / 2.0
			elif ideo[5]:
				sup[5] -= float(country.level_of_instability) / 4.0
				sup[5] += float(country.level_of_development) / 2.0
			elif ideo[6]:
				sup[6] -= float(country.level_of_instability) / 4.0
				sup[6] += float(country.level_of_development) / 2.0
	if sg <= 3:
		if 9 - sg >= 0 and 9 - sg < 10 and ideo[9 - sg]:
			sup[9 - sg] += float(country.level_of_instability)
			sup[9 - sg] -= float(country.level_of_development)
		elif ideo[5]:
			sup[5] += float(country.level_of_instability)
			sup[5] -= float(country.level_of_development)
		elif ideo[4]:
			sup[4] -= float(country.level_of_instability) / 2.0
			sup[4] += float(country.level_of_development) / 2.0
		if 8 - sg >= 0 and 8 - sg < 10 and ideo[8 - sg]:
			sup[8 - sg] += float(country.level_of_instability) / 2.0
			sup[8 - sg] -= float(country.level_of_development) / 4.0
		if 10 - sg <= 9 and 10 - sg >= 0 and ideo[sg]:
			sup[10 - sg] += float(country.level_of_instability) / 2.0
			sup[10 - sg] -= float(country.level_of_development) / 4.0
	elif sg >= 6:
		if 9 - sg >= 0 and 9 - sg < 10 and ideo[9 - sg]:
			sup[9 - sg] += float(country.level_of_instability)
			sup[9 - sg] -= float(country.level_of_development)
		elif ideo[4]:
			sup[4] += float(country.level_of_instability)
			sup[4] -= float(country.level_of_development)
		elif ideo[5]:
			sup[5] -= float(country.level_of_instability) / 2.0
			sup[5] += float(country.level_of_development) / 2.0
		if 8 - sg >= 0 and 8 - sg < 10 and ideo[8 - sg]:
			sup[8 - sg] += float(country.level_of_instability) / 2.0
			sup[8 - sg] -= float(country.level_of_development) / 4.0
		if 10 - sg <= 9 and 10 - sg >= 0 and ideo[10 - sg]:
			sup[10 - sg] += float(country.level_of_instability) / 2.0
			sup[10 - sg] -= float(country.level_of_development) / 4.0
	elif sg == 4:
		for i in [0, 1, 2, 6, 7, 8, 9]:
			if ideo[i]:
				sup[i] += float(country.level_of_instability) / 2.0
				sup[i] -= float(country.level_of_development) / 4.0
	elif sg == 5:
		for i in [0, 1, 2, 6, 7, 8, 9]:
			if ideo[i]:
				sup[i] += float(country.level_of_instability) / 2.0
				sup[i] -= float(country.level_of_development) / 4.0
	if coef > 0.0:
		coef *= 3.0
		if party >= 0 and party < 10:
			if sup[party] > 1.0:
				sup[party] *= coef
			else:
				sup[party] += coef
	for i in sup.size():
		if i >= 0 and i < 10 and ideo[i]:
			sup[i] += 100.0
	var best := 0
	var best_val := -1e30
	for i in sup.size():
		if sup[i] > best_val:
			best_val = sup[i]
			best = i
	return best


func _make_ideo(active: Array) -> Array:
	var ideo: Array[bool] = []
	ideo.resize(10)
	for i in active:
		if i >= 0 and i < 10:
			ideo[i] = true
	return ideo


func _make_sup() -> Array:
	var sup: Array[float] = []
	sup.resize(10)
	for i in sup.size():
		sup[i] = 0.0
	return sup

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var argentina := ws.get_country_by_legacy_index(71)
	if argentina == null:
		return
	var opt := int(context.get("option_index", -1))
	var ideo := _make_ideo([4, 5, 3, 1])
	var sup := _make_sup()
	var winner := -1
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(argentina, ideo, sup, 2.0 if argentina.government == 3 else 1.5, 4)
			argentina.set_tag("亲中", winner == 4)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(argentina, ideo, sup, 2.0 if argentina.government == 3 else 1.5, 5)
			argentina.set_tag("亲中", winner == 5)
		2:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(argentina, ideo, sup, 2.0 if argentina.government == 3 else 1.5, 3)
			argentina.set_tag("亲中", winner == 3)
		3:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			winner = _get_winner_in_america(argentina, ideo, sup, 2.0 if argentina.government == 3 else 1.5, 1)
			argentina.set_tag("亲中", winner == 1)
		_:
			winner = _get_winner_in_america(argentina, ideo, sup, 0.0, -1)
			if winner != argentina.sub_government:
				argentina.set_tag("亲中", false)
	argentina.government = 3
	argentina.sub_government = winner
	_leave_alliances(argentina)
	argentina.next_election_year = 1989
	argentina.next_election_month = 7
	argentina.next_election_day = 8
	if winner == 4:
		argentina.level_of_instability -= 20
		argentina.level_of_development -= 5
		_add_power(EmpireData.USA, -5)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R4 + _proprc_suffix(argentina)
	elif winner == 5:
		argentina.level_of_instability -= 15
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, -5)
		context["result_text"] = TXT_R5 + _proprc_suffix(argentina)
	elif winner == 3:
		argentina.level_of_instability -= 5
		argentina.level_of_development += 10
		_add_power(EmpireData.USA, -10)
		argentina.set_tag("亲美", false)
		context["result_text"] = TXT_R3 + _proprc_suffix(argentina)
	elif winner == 1:
		argentina.level_of_instability -= 10
		argentina.level_of_development += 5
		_add_power(EmpireData.USA, -15)
		_add_power(EmpireData.USSR, 5)
		argentina.set_tag("亲美", false)
		context["result_text"] = TXT_R1 + _proprc_suffix(argentina)

