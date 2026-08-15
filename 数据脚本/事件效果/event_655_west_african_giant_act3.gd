extends "res://数据脚本/event_script_base.gd"

## 原作 Event655.cs：西非巨人——第三幕（尼日利亚1983政变，三选项）。
## 触发：TimeScript.cs 11056-11060 —— (月>=12 且 日>=31 且 年>=1983 或 年>=1984)。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线）。
##  - 结果1/2 的布哈里声明按 c60.sub_government==12 动态拼接（原版 ?: 字符串）。
##  - OilProd += 100f：项目未建模，跳过（modifier_catalog.gd:1037）。
##  - 死代码 result 5 测试分支跳过。

const TXT_TITLE := "西非巨人——第三幕"
const TXT_DESC := "尼日利亚经济在20世纪80年代进入了严重的衰退期。生活水平降到比以前更糟糕的地步，外债增加。70年代着重强调提供人民生活所需的发展计划，因为国家支持出口导向战略而被放弃。这也是一个冲突的时代，穷人抗议政府的政策，宗教冲突也不断增加，在经济衰退和政治上管理不善的刺激下进一步激化。自尼日利亚第二共和国的第二届政府上任三个月以来，国家的状况并未好转，局势反而更加尖锐和对立。此届文官政府也并未对此视而不见，他们制定了新的改革计划，并成立了一个新的部门——国家指导部，以遏制政府内部的腐败现象，他们制定了一个名为“道德革命”的新计划，以进行“反违纪战争”，但我们似乎要看不到他们的落地了——近期在尼日利亚与乍得的边境冲突中，文官政府同军方的意见分歧使得尼日利亚国内本就不算乐观的局势更加火上浇油。根据情报，陆军参谋易卜拉欣·巴班吉达少将和负责对乍得的军事行动的穆罕默杜·布哈里少将在尼日利亚商业大亨莫斯胡德·阿比奥拉的资助下拉起了一个军方的阴谋圈子，准备对文官政府发起政变。当然，文官政府方面也不缺少仍然支持政权的军事力量。\n我们是否要做些什么？毕竟，第二共和国的民主来之不易，但话又说回来，这也只不过是这片大陆无处不在的一场政变罢了……或许，这次也会有开明的军事政权？"

const TXT_OPT0 := "支持文官政府"
const TXT_OPT0_DIS := "非洲的民主制也不过是买办的游戏……"
const TXT_OPT1 := "支持军官集团"
const TXT_OPT1_DIS := "我们不会去支持一个军政府！"
const TXT_OPT2 := "不过是非洲的一场政变罢了"

const TXT_R0 := "我们决定帮助文官政府，保护非洲的民主化成果。在我们的特勤支持下，文官政府逮捕了阴谋集团，在随后的审判中，军官们被判处叛国罪。尼日利亚政府感谢我们的支持，与我们达成了一些有利的合作，我们也向他们发送了援助。意识到了局势的严峻性，他们决定大力改进新制定的改革计划和加速“道德革命”的落实，以稳定政权。希望局势会好转吧。"
const TXT_R1_BASE := "我们向军官集团提供了支持。深夜，在与总统卫队进行交火后，全副武装的士兵控制了首都拉各斯，在清除腐败、改革政府无能和制止经济衰退等口号下，军人们发动了军事政变。他们封锁机场，关闭边境，切断国际国内通讯联系，随后，政府军人在国家广播电台宣布：武装部队已接管了政权，文官总统职务被解除。在这次政变中，军人们逮捕了总统和副总统、众议院议长及各部部长，成立了最高军事委员会，富拉尼人穆罕默杜·布哈里少将出任国家元首和武装部队总司令，巴班吉达出任陆军参谋长。这是尼日利亚建国以来的第五次军事政变。布哈里上台后就下令禁止所有政党的活动，解散议会并终止1979年宪法的执行。对于这次军事政变，上台后的布哈里军政府解释是：由于国家政治的行为规则被公然破坏，国家的法律被有意识地引导为某些个人和集团服务，所有的政党几乎都不遵守国家的选举法。"
const TXT_R1_COND := "布哈里还指出，在沙加里腐败无能的文官政府的统治下，国家政治与经济生活的动荡已成为一种手段或机会，被腐败的政治家们用来犯罪。"
const TXT_R1_SUFFIX := "所有这些都是由于竞争中的政治偏见和缺少公正引起的，国家经济因此遭到巨大的破坏。布哈里的这次军事政变在尼日利亚得到了广泛的支持，当政府被推翻的消息传来时，尼日利亚人举杯庆贺。新政府感谢我们的支持，与我们达成了一些有利的合作。"
const TXT_R2_BASE := "深夜，在与总统卫队进行交火后，全副武装的士兵控制了首都拉各斯，在清除腐败、改革政府无能和制止经济衰退等口号下，军人们发动了军事政变。他们封锁机场，关闭边境，切断国际国内通讯联系，随后，政府军人在国家广播电台宣布：武装部队已接管了政权，文官总统职务被解除。在这次政变中，军人们逮捕了总统和副总统、众议院议长及各部部长，成立了最高军事委员会，富拉尼人穆罕默杜·布哈里少将出任国家元首和武装部队总司令，巴班吉达出任陆军参谋长。这是尼日利亚建国以来的第五次军事政变。布哈里上台后就下令禁止所有政党的活动，解散议会并终止1979年宪法的执行。对于这次军事政变，上台后的布哈里军政府解释是：由于国家政治的行为规则被公然破坏，国家的法律被有意识地引导为某些个人和集团服务，所有的政党几乎都不遵守国家的选举法。"
const TXT_R2_COND := "布哈里还指出，在沙加里腐败无能的文官政府的统治下，国家政治与经济生活的动荡已成为一种手段或机会，被腐败的政治家们用来犯罪。"
const TXT_R2_SUFFIX := "所有这些都是由于竞争中的政治偏见和缺少公正引起的，国家经济因此遭到巨大的破坏。布哈里的这次军事政变在尼日利亚得到了广泛的支持，当政府被推翻的消息传来时，尼日利亚人举杯庆贺。希望这次还能有第一共和国那样的开明军官吧……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	event_def.title = TXT_TITLE
	event_def.description = TXT_DESC
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var opt := event_def.options
	if line >= 1:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 2:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	var is_sub12 := nigeria != null and nigeria.sub_government == 12
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			# OilProd += 100f：项目未建模，跳过
			context["result_text"] = TXT_R0
		1:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = 0
				nigeria.sub_government = 7
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			# OilProd += 100f：项目未建模，跳过
			var text1 := TXT_R1_BASE
			if is_sub12:
				text1 += TXT_R1_COND
			text1 += TXT_R1_SUFFIX
			context["result_text"] = text1
		2:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = 0
				nigeria.sub_government = 7
			var text2 := TXT_R2_BASE
			if is_sub12:
				text2 += TXT_R2_COND
			text2 += TXT_R2_SUFFIX
			context["result_text"] = text2


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


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta
