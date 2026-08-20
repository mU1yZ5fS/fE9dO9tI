extends "res://数据脚本/event_script_base.gd"

## 原作 Event653.cs：西非巨人——第一幕（尼日利亚第二共和国大选，五选项）。
## 触发：TimeScript.cs 11042-11046 —— (月>=7 且 年>=1979 或 年>=1980)。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线 / modifies[3] / data31 / modifies[6] / c1 严格社会主义）。
##  - OilProd += 100f 已建模（ws.oil_prod）。
##  - 死代码 result 5 测试分支跳过；result 0-4 均为实际选项。


const TXT_OPT0_DIS := "我们不会支持保守派"
const TXT_OPT1_DIS := "我们没必要把资源浪费在非洲的选举事务上……"
const TXT_OPT2_DIS := "我们不会去找他们！"
const TXT_OPT3_DIS := "他们认为我们是叛徒"
const TXT_OPT4_ALT := "尼日利亚？尼日尔？那是哪里？"

const TXT_R0 := "我们向尼日利亚国民党送去了资金，并扰乱了其他政党的选举。\n在7月7日的参议院选举中，尼日利亚国民党赢得了参议院95个席位中的40席。统一党获得了26席。人民党获得了14席。救国党获得了7席。大尼日利亚人民党获得了8席。7月14日的众议院的选举，国民党也占优势，在总数为449个议席中，国民党得了180席。统一党得了105席,居第二位。人民党居第三位，得了73席。居第四位的是救国党，得了49席。居最后一位的是大尼日利亚人民党，获得了48席。最终，沙加里的尼日利亚国民党与阿齐克韦的尼日利亚人民党经过谈判在议会中达成了联盟，获得了多数席位。\n8月16日，尼日利亚举行全民总统大选的投票，共有1684万选民参加了选举。结果，国民党候选人沙加里获得568万张选票，占总数的33.8%，并在19个州中的12个州里得票率超过了25%，从而达到了宪法所规定的当选新总统的票数。10月1日，在尼日利亚庆祝独立和建国19周年的时候，奥巴桑乔军政府在首都拉各斯举行了规模盛大的“还政于民”政权交接仪式，尼日利亚第二共和国成立，沙加里宣誓就任总统。在非洲大陆军人政权盛行，军事政变不断的时候，尼日利亚还政于民的成功，民选的文官新总统的就职，在非洲产生了重大的影响，奥巴桑乔受到非洲和国际社会的高度赞誉。新政府感谢我们的帮助，同我们达成了一些合作协定。"
const TXT_R1 := "我们向尼日利亚统一党、人民救国党、尼日利亚人民党和大尼日利亚人民党送去了资金，并扰乱了国民党的选举，在我方的施压和说服下，进步派各党达成了一定共识，决定进行更加深度的合作，共同反对国民党。\n在7月7日的参议院选举中，尼日利亚国民党赢得了参议院95个席位中的30席。统一党获得了30席。人民党获得了16席。救国党获得了10席。大尼日利亚人民党获得了9席。7月14日的众议院的选举，国民党也占优势，在总数为449个议席中，国民党得了150席。统一党得了120席,居第二位。人民党居第三位，得了79席。居第四位的是救国党，得了55席。居最后一位的是大尼日利亚人民党，获得了51席。最终，尼日利亚统一党、人民救国党、尼日利亚人民党和大尼日利亚人民党在议会中达成了联盟，获得了多数席位。\n8月16日，尼日利亚举行全民总统大选的投票，共有1684万选民参加了选举。结果，统一党候选人阿沃罗沃获得568万张选票，占总数的33.8%，并在19个州中的12个州里得票率超过了25%，从而达到了宪法所规定的当选新总统的票数。10月1日，在尼日利亚庆祝独立和建国19周年的时候，奥巴桑乔军政府在首都拉各斯举行了规模盛大的“还政于民”政权交接仪式，尼日利亚第二共和国成立，阿沃罗沃宣誓就任总统。在非洲大陆军人政权盛行，军事政变不断的时候，尼日利亚还政于民的成功，民选的文官新总统的就职，在非洲产生了重大的影响，奥巴桑乔受到非洲和国际社会的高度赞誉。新政府感谢我们的帮助，同我们达成了一些合作协定。但是，现在还不是值得高兴的时候，执政阵营的进步派大帐篷特性和阿沃罗沃自身的约鲁巴部族主义倾向不知会将尼日利亚的进步改革政府带向何方……"
const TXT_R2 := "我们的大使馆联系到穆罕默德·马尔瓦，表示我们愿意和扬塔特斯尼组织一起打倒邪恶的西方物质主义的入侵。很快，一批武器和资金便送到了扬塔特斯尼组织中。尼日利亚当局谴责我们干涉他国内政，宣布降低与我国的外交关系。\n在7月7日的参议院选举中，尼日利亚国民党赢得了参议院95个席位中的36席，占37.9%。统一党获得了28席，占29.5%。人民党获得了16席，占16.9%。救国党获得了7席，占7.3%。大尼日利亚人民党获得了8席，占8.4%。7月14日的众议院的选举，国民党也占优势，在总数为449个议席中，国民党得了168席，占37.4%。统一党得了111席，占24.7%,居第二位。人民党居第三位，得了79席，占17.5%。居第四位的是救国党，得了49席，占10.9%。居最后一位的是大尼日利亚人民党，获得了48席，占10.69%。最终，沙加里的尼日利亚国民党与阿齐克韦的尼日利亚人民党经过谈判在议会中达成了联盟，获得了多数席位。\n8月16日，尼日利亚举行全民总统大选的投票，共有1684万选民参加了选举。结果，国民党候选人沙加里获得568万张选票，占总数的33.8%，并在19个州中的12个州里得票率超过了25%，从而达到了宪法所规定的当选新总统的票数。10月1日，在尼日利亚庆祝独立和建国19周年的时候，奥巴桑乔军政府在首都拉各斯举行了规模盛大的“还政于民”政权交接仪式，尼日利亚第二共和国成立，沙加里宣誓就任总统。在非洲大陆军人政权盛行，军事政变不断的时候，尼日利亚还政于民的成功，民选的文官新总统的就职，在非洲产生了重大的影响，奥巴桑乔受到非洲和国际社会的高度赞誉。"
const TXT_R3 := "在外联部同志们的广泛联络下，来自人民救国党“滑坡”派的迈克尔·伊穆杜（人民救国党“滑坡”派领袖和左翼工会运动领导人）、塞缪尔·伊库、阿布巴卡尔·里米和优素福·巴拉·乌斯曼（受弗朗茨·法农影响的思想家）等人，由黑人左翼歌手和活动家费拉·库蒂（我们的老朋友K·兰索迈·库蒂夫人的儿子）建立的恩克鲁玛主义和泛非主义的“人民运动”、由达波·法托贡领导的社会主义劳动人民党、由马克思主义政治经济学家奥拉·奥尼领导的工农青年社会党等小型激进左翼政党以及近期在农村发起了一场公社运动，成立了一个秘密农村公社的马杜纳古夫妇（埃德温·马杜纳古教授和贝内·马杜纳古教授）及其团体、绰号“毛·托约”的毛主义者埃斯科尔·托约、支持人民民主且反对修正主义的尼伊·奥尼奥罗罗、支持过“比夫拉革命”的马克思主义者伊肯纳·恩齐米罗、马克思主义政治经济学家巴德·奥尼莫德和马克思主义的齐克主义老战士莫克乌戈·奥科耶等活动家和思想家在我们的支持下召开了一场全尼日利亚社会主义会议，宣布成立革命政党全尼日利亚革命社会主义联盟。该党宣布将秘密组织农村公社，渗透工会运动、学生运动和人民救国党，广泛吸收工农群众参加，并准备开展人民战争，以进行武装革命斗争，终结奴役尼日利亚的买办、新殖民主义、封建主义和帝国主义。我们向这个新生的革命政党提供了武器和资金援助。尼日利亚当局谴责我们干涉他国内政，宣布降低与我国的外交关系。\n在7月7日的参议院选举中，尼日利亚国民党赢得了参议院95个席位中的36席，占37.9%。统一党获得了28席，占29.5%。人民党获得了16席，占16.9%。救国党获得了7席，占7.3%。大尼日利亚人民党获得了8席，占8.4%。7月14日的众议院的选举，国民党也占优势，在总数为449个议席中，国民党得了168席，占37.4%。统一党得了111席，占24.7%,居第二位。人民党居第三位，得了79席，占17.5%。居第四位的是救国党，得了49席，占10.9%。居最后一位的是大尼日利亚人民党，获得了48席，占10.69%。最终，沙加里的尼日利亚国民党与阿齐克韦的尼日利亚人民党经过谈判在议会中达成了联盟，获得了多数席位。\n8月16日，尼日利亚举行全民总统大选的投票，共有1684万选民参加了选举。结果，国民党候选人沙加里获得568万张选票，占总数的33.8%，并在19个州中的12个州里得票率超过了25%，从而达到了宪法所规定的当选新总统的票数。10月1日，在尼日利亚庆祝独立和建国19周年的时候，奥巴桑乔军政府在首都拉各斯举行了规模盛大的“还政于民”政权交接仪式，尼日利亚第二共和国成立，沙加里宣誓就任总统。在非洲大陆军人政权盛行，军事政变不断的时候，尼日利亚还政于民的成功，民选的文官新总统的就职，在非洲产生了重大的影响，奥巴桑乔受到非洲和国际社会的高度赞誉。"
const TXT_R4 := "在7月7日的参议院选举中，尼日利亚国民党赢得了参议院95个席位中的36席，占37.9%。统一党获得了28席，占29.5%。人民党获得了16席，占16.9%。救国党获得了7席，占7.3%。大尼日利亚人民党获得了8席，占8.4%。7月14日的众议院的选举，国民党也占优势，在总数为449个议席中，国民党得了168席，占37.4%。统一党得了111席，占24.7%,居第二位。人民党居第三位，得了79席，占17.5%。居第四位的是救国党，得了49席，占10.9%。居最后一位的是大尼日利亚人民党，获得了48席，占10.69%。最终，沙加里的尼日利亚国民党与阿齐克韦的尼日利亚人民党经过谈判在议会中达成了联盟，获得了多数席位。\n8月16日，尼日利亚举行全民总统大选的投票，共有1684万选民参加了选举。结果，国民党候选人沙加里获得568万张选票，占总数的33.8%，并在19个州中的12个州里得票率超过了25%，从而达到了宪法所规定的当选新总统的票数。10月1日，在尼日利亚庆祝独立和建国19周年的时候，奥巴桑乔军政府在首都拉各斯举行了规模盛大的“还政于民”政权交接仪式，尼日利亚第二共和国成立，沙加里宣誓就任总统。在非洲大陆军人政权盛行，军事政变不断的时候，尼日利亚还政于民的成功，民选的文官新总统的就职，在非洲产生了重大的影响，奥巴桑乔受到非洲和国际社会的高度赞誉。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 2
	var war_support := data[W.I_WAR_SUPPORT] if data.size() > W.I_WAR_SUPPORT else 0
	var opt := event_def.options
	if line >= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line <= 2 and line >= 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line <= 3 and line >= 1 and not _modifier_active(world, 3) and war_support >= 600:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	var china := world.get_country_by_legacy_index(1)
	if line <= 1 and _modifier_active(world, 6) and world.is_socialism(china, true):
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	if line != 0:
		_enable(opt[4], event_def.options[4].text)
	else:
		_enable(opt[4], TXT_OPT4_ALT)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var nigeria := ws.get_country_by_legacy_index(60)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -40)
			_add(W.I_AGENTS, -40)
			ws.oil_prod += 100.0  # Event653.cs OilProd
			context["result_text"] = TXT_R0
		1:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.SOCIAL_DEMOCRAT
				nigeria.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -160)
			_add(W.I_AGENTS, -160)
			ws.oil_prod += 100.0  # Event653.cs OilProd
			context["result_text"] = TXT_R1
		2:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			if nigeria != null:
				nigeria.prc_power = 20
				nigeria.内战中 = true
			context["result_text"] = TXT_R2
		3:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			_add_relation(EmpireData.USA, -100)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			if nigeria != null:
				nigeria.prc_power = 20
			context["result_text"] = TXT_R3
		4:
			if nigeria != null:
				_leave_alliances(nigeria)
				nigeria.government = GameConstants.Government.LIBERAL
				nigeria.sub_government = GameConstants.SubGovernment.NEOLIBERAL
			context["result_text"] = TXT_R4




func _modifier_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null 			and world.modifiers[index].is_active


