extends "res://数据脚本/event_script_base.gd"

## 原作 Event98.cs：非洲的切·格瓦拉（布基纳法索桑卡拉，四选项）。
## 触发：TimeScript.cs:10815-10821 —— (月>=8 且 年>=1983 或 年>=1984)。
## 差异：
##  - 共同效果先执行：data[103]=15；c61 LeaveAlliances、name=布基纳法索
##    （new_events_text[800]）、Gosstroy=2/SubGosstroy=3、三倾向清空、dev=500。
##  - 选项显隐 prepare 动态改写（modifies[41] 激活才可用法国线）。

const TXT_R0 := "我们没必要对这种几乎每天都会发生的政变做出回应，并准备把注意力放在更关键的地方。根据国际组织的消息：布基纳法索境内的军事管制显然没有放松的迹象。不久后，桑卡拉便开始借助人民解放委员会的框架力行集权，在清剿军内异己的同时封杀了多个反对自身执政方针的左翼组织。预计接下来便是依托军政府框架建立无所不包的整合体制，并通过押注全面的紧缩政策为国内公共事务发展提供资金。终于，布基纳法索成为了一个混合古巴式革命委员会基层组织与军方强人统治的民族共产主义政权，其维系仰仗桑卡拉的光环与个人魅力。不过，靠着力行土地改革，大型基础设施与发展社会保障等手段。桑卡拉得以将自己倡导的自力更生哲学落到实处，迈出了改变该国贫困现状的第一步。布基纳法索的识字率稳步提升，粮食得以转向自给满足人民需求，割礼等落后习俗也被系数废除。"

const TXT_R0_EXTRA := "对于布基纳法索的新变化，本就处于优势并试图在非洲发起新一轮进攻的苏联很快便抛出橄榄枝。不久后，来自莫斯科的援助便运抵瓦加杜古，托马斯·桑卡拉得以通过安德烈·葛罗米柯的关系同彼时的苏共总书记建立了密切合作关系。看来”非洲的格瓦拉“一词确实名副其实——如今背后无忧的桑卡拉终于可以大展宏图了。"

const TXT_R0_EXTRA2 := "然而，桑卡拉试图在高度孤立的情况下深入推进社会革新，以及试图挑战法国对传统势力范围霸权的策略注定不会一帆风顺。以至于原本应当作为桑卡拉后盾的人民解放委员会内部都产生要求“放松螺丝”的离心倾向。上述情况只会随着布基纳法索与法国间对抗的火花愈演愈烈。谁知道接下来会如何……"

const TXT_R1 := "我们决定对布基纳法索采取足够灵活的立场，以稳定当地的局势。不久后，中国代表便抵达瓦加杜古会见中国人民的新朋友，在承认新政府的同时提供了该国急需的食物、军械与资金援助。对此，该国领导人托马斯·桑卡拉则深受感动，并顺势同我们达成了多项合作协定。然而这只是一个开始：接下来，我们决定同人民解放委员会内的温和派进行接触，并逐渐在这一过程中架空托马斯·桑卡拉的派系与对其激进主义观点釜底抽薪。结果便是桑卡拉在布基纳法索境内越来越显得像是以清正廉洁闻名的国家级花瓶，而非革命领军人与政权的真正领袖。国内的实权事实上落入了人民解放委员会的二把手布莱斯·孔波雷与同僚巴蒂斯特·林加尼、亨利·宗戈等“桑卡拉亲密战友”手中，他们在人民解放委员会内组建了一个指导转型的顾问委员会奉行所谓“名副其实的集体领导”：国家对社会团体的态度得以放松，并引入了旨在稳固公务员群体的干部名册与薪资等级制，接下来便是对军政府实施有限开门的改革：国内“具有建设意义”的政党均得以加入人民解放委员会，并作为其中成员参与政治生活。布基纳法索的外交也跟着转向平稳航行（即在和平共处的基础上同包括亲法非洲政权在内的国家发展建设性外交关系），甚至为促进经济发展而开设经济特区，吸纳邻国投资与鼓励国内经济作物出口，事实上承认原法非体系下的旧有国际分工关系。如今的布基纳法索已然在我们的指导下走上了条和平巩固社会主义之路，并能在站稳脚跟的基础上充分保存其革命成就。即便这一成果的变异并不一定会使所有人满意。"

const TXT_R2 := "我们决定将布基纳法索的演变作为撬动旧殖民秩序的支点，并以此点燃反殖民主义之火。不久后，中国代表便抵达瓦加杜古会见中国人民的新朋友，在承认新政府的同时提供了该国急需的食物、军械与资金援助。对此，该国领导人托马斯·桑卡拉则深受感动，他在当日庄重的洗尘晚宴对中国同志们表达了感激之情：“有了中国朋友们的协助，帝国主义的残酷统治将会在新千年时彻底消失，所有的人将在一个自由而平等的社会中生活！”，紧接着便顺势同我们达成了多项合作协定。然而这只是一个开始：接下来，我们决定协助桑卡拉推进人民解放委员会与国家政府中的人事改组。一方面大力推进干部年轻化，彻底扫除官僚主义积弊；一方面则试图通过在当地赋权自发人民武装的方式间接为人民革命委员会这一机构开门，并通过军事改革剥离国家部队同区域部族与部分强人领袖之间的强绑定关系。军事雅各宾主义的做法得以开始转变为类似革命委员会的议事-行政合一框架，该国的执政基础也得以从军事团体转变为动员起的成规模基层公民，由此挖掉了依靠军事政变做法夺权的根基。接下来推进的土地改革、公共工程与社会福利事业则只会让桑卡拉的政权得到该国本就实力雄厚的左翼内的热烈欢迎，并切实迈出了改变该国贫困现状的第一步。布基纳法索的识字率稳步提升，粮食得以转向自给满足人民需求，割礼等落后习俗也被系数废除。诚然，试图在一个前殖民地内跳过资本主义发展阶段，从封建主义直接转向社会主义并非易事。布基纳法索需要从零开始打造其工农业基础，并在同时确保人民享有平等、有效又实惠的各项公共服务。可既然我们仍坚持彻底清算旧社会的革命理想，那我们实际上也无需对布基纳法索的未来表示忧虑。毕竟只有帝国主义分子才会恐惧彻底觉醒并决心走向解放的世界各地人民！"

const TXT_R3 := "考虑到布基纳法索的情况大有愈演愈烈，一发不可收拾之势。出于维护当地稳定的需要，我们决定直接同法国对接，对当地开展特别军事行动。也就在某天深夜，由鲍勃·德纳尔率领的雇佣兵奇袭瓦加杜古，并与我特种部队一道夺下首都多处交通要地，为接下来的全面干预做足了准备。虽说布基纳法索当局已引入戒严并做好了备战准备，可革命者们还是力不能敌——包括桑卡拉，孔波雷，林加尼等在内的布基纳法索实权人物均在这次袭击中丧命。在雇佣兵的簇拥下，国父之子热拉尔·坎戈·韦德拉奥果将临危受命，宣誓要让民主回归上沃尔特，所谓的布基纳法索就这样终结了……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var opt := event_def.options
	_enable(opt[0], "无视军事政变")
	if line != 0 and line != 4:
		_enable(opt[1], "支持布基纳法索的革新，并推动人民解放委员会内温和派扭转唯意志论实践")
	elif line == 0:
		_disable(opt[1], "天下大乱，局势大好。怎能不乘胜追击！")
	else:
		_disable(opt[1], "没必要玩两害相择取其轻的把戏")
	if world.influence_prc >= 100 and line < 2:
		_enable(opt[2], "支持布基纳法索的革新，并推动人民解放委员会选择更坚决的革命立场")
	else:
		_disable(opt[2], "更强硬的社会主义军政府？难道你打算在西非制造个黑人版奈温？")
	if _mod_active(world, 41):
		_enable(opt[3], "联系法国人，我们应当给当地畸形的“不断政变”生态画上休止符")
	else:
		_disable(opt[3], "我们鞭长莫及")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	# 共同效果（先于 result 分支）
	if d.size() > 103:
		d[103] = 15
	var bf := ws.get_country_by_legacy_index(61)
	if bf != null:
		_leave_alliances(bf)
		bf.name = "布基纳法索"
		bf.chinese_name = "布基纳法索"
		bf.government = 2
		bf.sub_government = 3
		bf.set_tag("对华贸易", false)
		bf.set_tag("亲美", false)
		bf.set_tag("亲中", false)
		bf.set_tag("亲苏", false)
		bf.development = 500
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var text := TXT_R0
			if bf != null:
				bf.sub_government = 1
				bf.government = 1
			var ussr_power := ws.empires[EmpireData.USSR].power if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null else 0
			var china := ws.get_country_by_legacy_index(1)
			if (ussr_power > _usa_power() and ussr_power > ws.influence_prc) \
					or (china != null and (china.has_tag("sev") or china.has_tag("ovd"))):
				text += TXT_R0_EXTRA
				if bf != null:
					bf.set_tag("亲苏", true)
				_add_power(EmpireData.USSR, 5)
			elif not _mod_active(ws, 44):
				text += TXT_R0_EXTRA2
			context["result_text"] = text
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -30)
			ws.influence_prc += 5
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 10)
			if bf != null:
				bf.government = 2
				bf.sub_government = 15
				bf.set_tag("对华贸易", true)
				bf.set_tag("亲中", true)
			context["result_text"] = TXT_R1
		2:
			_add_relation(EmpireData.USSR, 100)
			ws.influence_prc += 15
			_add_relation(EmpireData.USA, -200)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add(W.I_DIPLO, 20)
			if bf != null:
				bf.sub_government = 0
				bf.government = 1
				bf.set_tag("对华贸易", true)
				bf.set_tag("亲中", true)
			context["result_text"] = TXT_R2
		3:
			ws.influence_prc += 10
			_add_power(EmpireData.USA, 10)
			_add_power(EmpireData.USSR, -10)
			if bf != null:
				bf.puppet_of = 21
			_add(W.I_AGENTS, -20)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -50)
			if bf != null:
				bf.government = 3
				bf.sub_government = 12
				bf.set_tag("对华贸易", true)
				bf.name = "上沃尔特"
				bf.chinese_name = "上沃尔特"
			context["result_text"] = TXT_R3


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "asean",
			"seato", "oar", "oil", "sento", "fxseu", "nazimao", "balecon",
			"rim", "au", "亲苏", "亲美", "亲中", "对华贸易"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _mod_active(world: WorldState, index: int) -> bool:
	return index >= 0 and index < world.modifiers.size() \
		and world.modifiers[index] != null and world.modifiers[index].is_active


func _usa_power() -> int:
	if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null:
		return ws.empires[EmpireData.USA].power
	return 0


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
