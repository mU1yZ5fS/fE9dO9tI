extends "res://数据脚本/event_script_base.gd"

## 原作 Event497.cs：恩古瓦比的大会？——第二幕（刚果党代会，四选项）。
## 触发：TimeScript.cs:11006-11012 —— (日>=17 且 月>=10 且 年>=1984
##   或 月>=11 年>=1984 / 年>=1985) && c52.Gosstroy==1 && c52.SubGosstroy!=16。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 + relres flag + c1.sev + c52.对华贸易）。
##  - IsSocialism(true, 1) → ws.is_socialism(china, true)（严格社会主义判定）。
##  - LeaveAlliances() 逐项清标签（同 Event587 约定）。

const TXT_TITLE := "恩古瓦比的大会？——第二幕"

const TXT_DESC := "尽管萨苏被视为刚果劳动党保守派的代表，但他既不是激进派，也不是理论家，他的政策通常以实用主义为标志——刚果仍与西方关系密切，经济领域的和法国保持了深入联系，萨苏表示，刚果和法国之间“没有乌云”。刚果通过法国发展并保持牢固的关系来维持经济的高速增长。在经济调整中，国企开始实行经理负责制和厂长负责制，鼓励物质刺激，一批绩效不良的国营企业被改组为刚果-法国的合资企业，法方派专家帮助管理。萨苏同国际货币基金组织谈判贷款，并允许来自法国和美国的外国投资者进行石油和矿产开采。他于1979年10月和1981年7月访问法国，寻求经济支持。法国的石油公司在刚果油田的开采中发挥了重要作用，他们使石油产量翻了一番，并通过预融资贷款支持刚果政府开支。1980年5月，萨苏与苏联签署了一项为期20年的友好协议，并于同年派出两个代表团访问中国，而中国政府的部长则回访了布拉柴维尔。然而，这些关系的经济影响仍然微乎其微：法国为该国提供了高达50%的对外援助，苏联和中国对刚果的援助比起法国而言更是微不足道。\n在这一情况下，刚果劳动党党内仍然存在反对派系。尽管这随着萨苏巩固权力和党内团结政策的推行，劳动党的宗派主义在80年代不那么明显，但其内部权力斗争仍在继续。萨苏将劳动党的第二号人物与党内理论家让-皮埃尔·蒂斯特雷·契卡雅视为眼中钉，他计划除掉这位令他头疼的人物；与此同时，党内还存在一个由弗朗索瓦·格扎维埃·卡塔利领导的强硬亲苏派，希望刚果与苏东阵营进行更深入的合作。在这场党代会上，劳动党各派将决出胜者。"

const TXT_OPT0 := "帮助契卡雅夺取权力，扭转刚果的政策"
const TXT_OPT0_DIS := "我们没必要把手伸到非洲去"
const TXT_OPT1 := "支持卡塔利的亲苏强硬派夺权，刚果不应该和法国人眉来眼去！"
const TXT_OPT1_DIS := "我们没必要为苏联人做事"
const TXT_OPT2 := "支持萨苏的当权派"
const TXT_OPT2_DIS := "我们不会支持他"
const TXT_OPT3 := "我们不关心刚果的局势"

const TXT_R0 := "我们的人适时地点醒了契卡雅同志。萨苏食用了苏联人送的鱼子酱，这导致他因食物中毒“意外”身亡。我们设法争取到部分军事派系、部分党代会代表、甚至是前M-22成员和八月革命元老克洛德-欧内斯特·恩达拉及其背后的南方人的支持，萨苏派的成员成功被排除在权力之外，让-皮埃尔·蒂斯特雷·契卡雅成功成为了新的领导人。他没有忘记是谁帮助了他，在大会上，前M-22的成员被大幅提拔。契卡雅总统宣布，刚果将彻底与新殖民主义决裂，回到真正的马列主义和由恩古瓦比同志指引的道路上，并站在以中国为首的革命阵营一边，这场党代会被称为“又一次恩古瓦比的大会”。我们将为刚果提供帝国主义离开后的经济支持。"

const TXT_R1 := "在党代会上，在卡塔利派、契卡雅派甚至是前M-22成员的支持下，萨苏因“右倾、向帝国主义投降”而被刚果劳动党全国代表大会罢免。弗朗索瓦·格扎维埃·卡塔利被选举为新的总书记。卡塔利宣布，刚果将彻底与殖民主义决裂，站在以苏联为首的社会主义阵营一边。经济互助委员会将为其提供帝国主义离开后的经济支持，许多刚果和法国合资的企业已经开始改为同包括苏联在内的经互会国家合资。"

const TXT_R2_FR_NEUTRAL := "我们的特工提前在刚果劳动党的中央委员会进行了打点，萨苏感谢了我们的支持，同我们签订了一批合作协议。在党代会上，契卡雅遭到了萨苏的突然袭击，他指控契卡雅应该为1982年在布拉柴维尔发生的炸弹袭击事件负责，这导致他被免职。于此同时，卡塔利派也在大会上被边缘化，卡塔利被降职到一个清水衙门。萨苏就这样巩固了他的地位，并将继续他的统治。"

const TXT_R2_FR_PROSU := "得益于我们的支持，萨苏在党代会上顶住了有法国和苏联撑腰的卡塔利派的挑战，调动军队“平息”了党内的异议，契卡雅以及卡塔利派的成员都被解职了。萨苏就这样巩固了他的地位，并将继续他的统治。萨苏谴责法国和苏联“是社会帝国主义，干涉刚果内政”。他感谢我们的支持，宣布倒向我国，并和我们扩大了合作。"

const TXT_R3_FR_NEUTRAL := "在党代会上，契卡雅遭到了萨苏的突然袭击，他指控契卡雅应该为1982年在布拉柴维尔发生的炸弹袭击事件负责，这导致他被免职。于此同时，卡塔利派也在大会上被边缘化，卡塔利被降职到一个清水衙门。萨苏就这样巩固了他的地位，并将继续他的统治。"

const TXT_R3_FR_PROSU := TXT_R1


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var congo := world.get_country_by_legacy_index(52)
	var china := world.get_country_by_legacy_index(1)
	var torg := congo != null and congo.has_tag("对华贸易")
	var sev := china != null and china.has_tag("sev")
	var opt := event_def.options
	if line < 2 and torg:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if world.get_flag("relres") and sev and line < 3:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line != 0 and line != 4:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var congo := ws.get_country_by_legacy_index(52)
	var france := ws.get_country_by_legacy_index(21)
	var china := ws.get_country_by_legacy_index(1)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = 1
				congo.sub_government = 2
				_leave_alliances(congo)
				congo.set_tag("亲中", true)
				congo.set_tag("对华贸易", true)
			ws.influence_prc += 20
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = 1
				congo.sub_government = 16
				_leave_alliances(congo)
				congo.set_tag("亲苏", true)
				congo.set_tag("对华贸易", true)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			var fr_prosu := france != null and france.has_tag("亲苏")
			if congo != null:
				_leave_alliances(congo)
				congo.set_tag("对华贸易", true)
			if not fr_prosu:
				if congo != null:
					congo.government = 2
					congo.sub_government = 21
				ws.influence_prc += 20
				context["result_text"] = TXT_R2_FR_NEUTRAL
			else:
				if congo != null:
					if ws.is_socialism(china, true):
						congo.set_tag("亲中", true)
						congo.government = 1
						congo.sub_government = 1
					elif china != null and china.government == 2:
						congo.set_tag("亲中", true)
						congo.government = 2
						congo.sub_government = 21
				ws.influence_prc += 20
				context["result_text"] = TXT_R2_FR_PROSU
		3:
			if france != null and france.has_tag("亲苏"):
				if congo != null:
					_leave_alliances(congo)
					congo.set_tag("亲苏", true)
					congo.government = 1
					congo.sub_government = 16
				context["result_text"] = TXT_R3_FR_PROSU
			else:
				if congo != null:
					_leave_alliances(congo)
					congo.government = 2
					congo.sub_government = 21
				context["result_text"] = TXT_R3_FR_NEUTRAL


## Country.LeaveAlliances() 逐项映射（同 Event587 约定）。
func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


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
