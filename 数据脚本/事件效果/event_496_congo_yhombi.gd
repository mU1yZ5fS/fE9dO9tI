extends "res://数据脚本/event_script_base.gd"

## 原作 Event496.cs：恩古瓦比的大会？——第一幕（刚果两派斗争，四选项）。
## 触发：TimeScript.cs:10999-11007 —— (月>=2 且 年>=1979 或 年>=1980)
##   && event_done[696] && resultOfEvents[696]==2。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线 + modifies[3]）。
##  - LeaveAlliances() 逐项清标签；puppetOf=21 → puppet_of=21（法国）。



const TXT_OPT0_DIS := "为什么要支持一伙叛徒？"
const TXT_OPT1_DIS := "我们是不会让法国人回去的！"
const TXT_OPT2_DIS := "为什么要支持一伙教条主义者？"

const TXT_R0 := "在我们的支持下，雍比召集了一批支持他的军官以及一批劳动党的改革派成员，对萨苏派进行武力的突袭，并引发了两派的街头火并。由于雍比对帝国主义的较好态度，美、法和扎伊尔也决定支持雍比。在各方支持下，雍比成功清理了保守派成员，树立了刚果劳动党改革派的领导地位。他没有忘记是谁支持了他，刚果决定与和中国和西方展开更大规模的合作，并继续进行经济改革。在这一情况下，刚果劳动党军事委员会的专制仍将继续。"

const TXT_R1 := "我们的大使在和法国外长的交谈中，暗示了我们对刚果问题的关注。我们也指出，法国作为一个在中部非洲地区拥有巨大影响力的国家，无论如何都不应该对雍比急切的需求坐视不管。\n法国人立刻理解了我们的暗示（或者说他们早有此意？）。很快，法国特工同扎伊尔雇佣兵一起进入了布拉柴维尔。他们麻利地按照名单对萨苏派的各个成员实施了一番清洗，萨苏本人也在枪战中被击毙。在法国人和扎伊尔人的帮助下，雍比清理了他的反对者，刚果劳动党及其军事委员会完全成了他实施独裁的橡皮图章，法军和扎伊尔部队顺理成章地驻扎在了刚果，来自法国的援助和资本也涌入了刚果。苏联谴责法国和扎伊尔的暴行。"

const TXT_R2 := "面对国内日益加剧的动荡和不满情绪的与日俱增，雍比被迫召开刚果劳动党中央委员会全体会议。1979年2月5日，刚果劳动党召开中央全会，迫使犯“右倾偏差”错误的雍比交权，一致选举劳动党军委会副主席德尼·萨苏-恩格索为刚果劳动党第三次特别代表大会筹备委员会主席兼共和国总统。同年3月，刚果劳动党举行了被称为“恩古瓦比的大会”的第三次全国特别代表大会，萨苏当选为劳动党主席、国家元首和共和国总统。随后的全民公决通过了刚果的新宪法。\n萨苏上台后，萨苏感谢了我们的支持，同我们签订了一批合作协议。他强调继承恩古瓦比的遗志，增进党内团结。1979年3月22日至23日，萨苏主持召开刚果劳动党中央委员会会议，对1972年“二月二十二日运动”和1976年“三月二十四日运动”（即“刚果社会主义青年联盟”第一书记奥卡班德和刚果工会主席孔多等人，在党中央书记皮埃尔·恩泽的支持下，煽动工人罢工，反对彻底化运动的事件）进行重新评价，认为这两次运动是“积极的”，参与者的目的是“为了表明革命的愿望”。因此，在“左派团结起来”的口号下，曾因为参加了这两次运动而被开除出中央委员会或被解除职务的大部分前中央委员又重新回到了中央委员会，其中有些人还得到重用，被选进政治局和书记处。对雍比派的处理也较宽容，大多分配工作；举行了第二届全国人民议会，并通过了新宪法，民主选举了各大区、市、县的地方各级人民议会。在党、政机构的人事安排上，也注意照顾不同部族和地区的利益，从而逐渐实现了“党内和人民内部的团结”，使长期动荡的刚果政局开始稳定下来，团结一致向前看。"

const TXT_R3 := "面对国内日益加剧的动荡和不满情绪的与日俱增，雍比被迫召开刚果劳动党中央委员会全体会议。1979年2月5日，刚果劳动党召开中央全会，迫使犯“右倾偏差”错误的雍比交权，一致选举劳动党军委会副主席德尼·萨苏-恩格索为刚果劳动党第三次特别代表大会筹备委员会主席兼共和国总统。同年3月，刚果劳动党举行了被称为“恩古瓦比的大会”的第三次全国特别代表大会，萨苏当选为劳动党主席、国家元首和共和国总统。随后的全民公决通过了刚果的新宪法。\n萨苏上台后，强调继承恩古瓦比的遗志，增进党内团结。1979年3月22日至23日，萨苏主持召开刚果劳动党中央委员会会议，对1972年“二月二十二日运动”和1976年“三月二十四日运动”（即“刚果社会主义青年联盟”第一书记奥卡班德和刚果工会主席孔多等人，在党中央书记皮埃尔·恩泽的支持下，煽动工人罢工，反对彻底化运动的事件）进行重新评价，认为这两次运动是“积极的”，参与者的目的是“为了表明革命的愿望”。因此，在“左派团结起来”的口号下，曾因为参加了这两次运动而被开除出中央委员会或被解除职务的大部分前中央委员又重新回到了中央委员会，其中有些人还得到重用，被选进政治局和书记处。对雍比派的处理也较宽容，大多分配工作；举行了第二届全国人民议会，并通过了新宪法，民主选举了各大区、市、县的地方各级人民议会。在党、政机构的人事安排上，也注意照顾不同部族和地区的利益，从而逐渐实现了“党内和人民内部的团结”，使长期动荡的刚果政局开始稳定下来，团结一致向前看。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	if line >= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line > 2 and not mod3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line < 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var congo := ws.get_country_by_legacy_index(52)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = 2
				congo.sub_government = 15
				_leave_alliances(congo)
				congo.set_tag("亲中", true)
				congo.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, -50)
			ws.influence_prc += 20
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = 2
				congo.sub_government = 15
				_leave_alliances(congo)
				congo.puppet_of = 21
				congo.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.set_tag("对华贸易", true)
			ws.influence_prc += 20
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3


## Country.LeaveAlliances() 逐项映射（同 Event587 约定）。
