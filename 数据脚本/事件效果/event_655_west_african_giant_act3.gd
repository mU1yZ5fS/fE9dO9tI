extends "res://数据脚本/event_script_base.gd"

## 原作 Event655.cs：西非巨人——第三幕（尼日利亚1983政变，三选项）。
## 触发：TimeScript.cs 11056-11060 —— (月>=12 且 日>=31 且 年>=1983 或 年>=1984)。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线）。
##  - 结果1/2 的布哈里声明按 c60.sub_government==12 动态拼接（原版 ?: 字符串）。
##  - OilProd += 100f 已建模（ws.oil_prod）。
##  - 死代码 result 5 测试分支跳过。


const TXT_OPT0_DIS := "非洲的民主制也不过是买办的游戏……"
const TXT_OPT1_DIS := "我们不会去支持一个军政府！"

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
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var opt := event_def.options
	if line >= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)


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
			ws.oil_prod += 100.0  # Event655.cs OilProd
			context["result_text"] = TXT_R0
		1:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = 0
				nigeria.sub_government = 7
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.oil_prod += 100.0  # Event655.cs OilProd
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


