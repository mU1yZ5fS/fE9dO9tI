extends "res://数据脚本/event_script_base.gd"

## 原作 Event492.cs：狂风怒吼，巴尔干咆哮（保加利亚变天，四选项）。
## 触发：ReqEventForDLC02.cs:1524-1526 ——
##   c6.SubGosstroy==16 && !c2.prosov && !c5.prosov && !c4.prosov
##   && !c1.isSEV && !c1.isOVD && !c1.isASEAN && !c1.isSEATO
##   && ((年>=1984 月>=9 日>=9) || (年>=1984 月>=10) || 年>=1985)。
## 差异：
##  - Gosstroy/SubGosstroy → government/sub_government；cw → 内战中；
##  - prosov/isSEV/isOVD/isASEAN/isSEATO/Torg/proprc/isBALECON → has_tag/set_tag；
##  - spec → special；relres → ws.get_flag("relres")；IsSocialism(true,1) → ws.is_socialism(c1, true)。



const TXT_OPT0_DIS := "没人会听我们的话"
const TXT_OPT1_DIS := "我们在巴尔干没有话语权"
const TXT_OPT2_DIS := "我们不想也不可能联络修正主义者"

const TXT_R0_WIN := "在我们的支持下，驻扎在索非亚的保加利亚人民军发生了哗变。由于事先的打点，大部分军队没有对此作出回应。支持政变的部队切断了所有通往首都的桥梁与道路，广播电台和电视塔被占领，机场也被封锁。而佩塔尔本人亲自率领了一支部队，他们冲进了保加利亚共产党中央委员会的办公室，一举抓获了日夫科夫和其余的政治局常委。在一场迅速的审判后，日夫科夫和他的亲属被判贪污与通敌罪。他本人被用从他家中抄出的黄金砸死，他的尸体被丢入黑海中。日夫科夫就这样被遗忘了，而他的子女将被下放到林场中劳动改造。\n佩塔尔·潘切夫斯基宣布对保加利亚实施军事管制，并开始着手清除苏联影响力。他宣布将会在保加利亚重建最符合季米特洛夫，斯大林与毛泽东的共产主义保加利亚。首当其冲的便是退出华沙条约组织与经济互助委员会。1965年的政变也被平反，政变的参与者被无罪释放，托多罗夫被当作民族英雄而纪念，四月七日改为国家假日。工业方面，以工人委员会为核心的企业管理系统也被介绍进来，专门为经互会设立的企业也被“保加利亚化”了。由于苏联援助的撤离，新领导层希望中华人民共和国能为新保加利亚提供必要的援助。\n"

const TXT_R0_BALECON := "新生的保加利亚积极谋求和巴尔干国家的友好关系，并获得了巴尔干国家联盟的观察员席位。\n"

const TXT_R0_USSR := "苏联谴责了这一行为，并宣布对我们进行制裁。"

const TXT_R0_LOSE := "在我们的支持下，驻扎在索非亚的保加利亚人民军发生了哗变。由于事先的打点，大部分军队没有对此作出回应。支持政变的部队切断了所有通往首都的桥梁与道路，广播电台和电视塔被占领，机场也被封锁。而佩塔尔本人亲自率领了一支部队，他们冲进了保加利亚共产党中央委员会的办公室，一举抓获了日夫科夫和其余的政治局常委。在一场迅速的审判后，日夫科夫和他的亲属被判贪污与通敌罪。他本人被用从他家中抄出的黄金砸死，而他的子女将被判处有期徒刑。\n但我们的人没能夺权，失势的保加利亚内政部长安吉尔·索拉科夫乘机发动了反政变。一举夺走了革命果实。他假借革命者之手除掉了日夫科夫后，又立刻以潜在反革命的名义处决了不忠诚于他的革命委员会成员。一个新的“保共”诞生了，但完全是为了一个独裁政权而服务的。索拉科夫宣布将从苏联人手中解放祖国，并构建“有保加利亚特色的社会主义”。保加利亚立刻驱逐了全部的驻保加利亚苏联武装部队，并扣留了R-46导弹井与发射钥匙。电视台也无限期停播。保加利亚似乎成为了欧洲的孤儿。南斯拉夫与保加利亚接壤的部分传来了交火的新闻，我们希望未来不会发生太糟糕的事情。"

const TXT_R1 := "我们决定向保加利亚施压，以脱离经济互助委员会和华约为要求，我们将为保加利亚承担债务，而且保加利亚将在巴尔干联邦中取得一席之地。巴尔干邦联将为保加利亚提供急需的面向亚得里亚的出海口，而且得以使他们在充斥着中国影响力的巴尔干中不被边缘化。很明显这符合保加利亚的需要。而日夫科夫将赢得身前身后名。因此，在下一届巴尔干国家代表大会上，保加利亚的牌子和希腊的一样，出现在了观察员国席上。\n但苏联对我们的所作所为非常不满意，如果朝鲜突然亲苏，我们也会这么做的。"

const TXT_R2 := "我们邀请保加利亚的改革派代表姆拉德诺夫来我国参观，货架上玲琅满目的各国商品让这位领导人印象深刻。在苏联人的默许和我们的支持下，姆拉德诺夫发动了一场不流血的政变，日夫科夫被开除党籍。保加利亚建立了类似于我国的经济特区，原先的企业也被改制为“工人自发管理”，即选拔一批有领导力的工人替代厂长。而农业上，保加利亚也组建了自己的小岗村。保共也为一大批前政治犯平反，其中包括了1965年的军事政变。苏联对保加利亚的改革与解冻很是满意。美国也不再公开攻击保加利亚支持恐怖主义。\n尽管经济看上去有所回升，但只有我们知道这一切的后果。"

const TXT_R3 := "日夫科夫的统治依然像从前一般稳定，在苏联的帮助下，他继续稳坐钓鱼台。我们还是不能下定决心拔掉苏联的牙齿。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var bulgaria := world.get_country_by_legacy_index(6)
	var china := world.get_country_by_legacy_index(1)
	var albania := world.get_country_by_legacy_index(20)
	var line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	var econ := world.数值表[W.I_ECON_SYSTEM] if world.数值表.size() > W.I_ECON_SYSTEM else 11
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var opt := event_def.options
	if bulgaria != null and bulgaria.内战中 and world.is_socialism(china, true) and mod6:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if albania != null and albania.special == 1 and world.influence_prc >= 800:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line >= 2 and econ >= 13 and world.get_flag("relres"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var bulgaria := ws.get_country_by_legacy_index(6)
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			if ws.influence_prc >= 600:
				var text := TXT_R0_WIN
				if bulgaria != null:
					bulgaria.government = GameConstants.Government.SOCIALIST
					bulgaria.sub_government = GameConstants.SubGovernment.MAOIST
					_leave_alliances(bulgaria)
					bulgaria.set_tag("对华贸易", true)
					bulgaria.set_tag("亲中", true)
					_join_alliances(bulgaria)
				_add_relation(EmpireData.USSR, -400)
				_add_power(EmpireData.USSR, -100)
				ws.influence_prc += 100
				if albania != null and albania.special == 1:
					text += TXT_R0_BALECON
					if bulgaria != null:
						bulgaria.set_tag("balecon", true)
				text += TXT_R0_USSR
				context["result_text"] = text
			else:
				context["result_text"] = TXT_R0_LOSE
				if bulgaria != null:
					bulgaria.government = GameConstants.Government.AUTHORITARIAN
					bulgaria.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
					_leave_alliances(bulgaria)
				_add_relation(EmpireData.USSR, -200)
				_add_power(EmpireData.USSR, -150)
		1:
			_add(W.I_BUDGET, -150)
			if bulgaria != null:
				_leave_alliances(bulgaria)
				bulgaria.set_tag("对华贸易", true)
				bulgaria.set_tag("balecon", true)
			_add_relation(EmpireData.USSR, -250)
			_add_power(EmpireData.USSR, -100)
			ws.influence_prc += 80
			context["result_text"] = TXT_R1
		2:
			_add(W.I_AGENTS, -100)
			if bulgaria != null:
				bulgaria.government = GameConstants.Government.REFORMIST
				bulgaria.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
				bulgaria.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, 300)
			_add_power(EmpireData.USSR, -100)
			ws.influence_prc += 80
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3



func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)



