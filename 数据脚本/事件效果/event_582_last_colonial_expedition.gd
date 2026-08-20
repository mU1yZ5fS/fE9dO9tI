extends "res://数据脚本/event_script_base.gd"

## 原作 Event582.cs：最后的殖民地远征（中非博卡萨，六选项）。
## 触发：ReqEventForDLC02.cs:819-822 —— (日>=20 且 月>=9 且 年>=1979) || (月>=10 且 年>=1979) || 年>=1980
##   → DATE_AFTER 1979.9.20。
## 差异：
##  - 选项显隐 prepare 动态改写；science[23] → ws.techs.unlocked[23]；
##  - modifies[3]/[6].active → ws.modifiers[3]/[6].is_active；
##  - Torg → 对华贸易；proprc → 亲中；name → chinese_name；puppetOf → puppet_of。



const TXT_OPT0_DIS := "不能接受这一极左冒进计划！"
const TXT_OPT1_DIS := "我们不会做这种费力不讨好的事"
const TXT_OPT2_DIS := "我们不能支持那个暴君！"
const TXT_OPT3_DIS := "我们没必要为了这点小事得罪法国人！"
const TXT_OPT4_DIS := "我们不能支持帝国主义者！"

const TXT_R0_A := "我们通过布拉柴维尔向乌班吉爱国阵线/劳动党提供了军事支援，并帮助他们联系了来自前非洲民主联盟-乌班吉沙里支部的希莱尔·科塔林博拉和他的关系网，以及中非出身的几内亚民主党和非洲团结党员、卢蒙巴政府的礼宾总管安德蕾·玛德琳·布鲁安，扩充了革命力量。1979年1月17日，通过发动总罢工和组建武装民兵，乌班吉爱国阵线/劳动党在班吉发动了武装起义，爱国阵线的民兵和“帝国”军队在班吉直接进行了巷战。"
const TXT_R0_CONGO := "|由于刚果同乌班吉爱国阵线/劳动党和我们的盟友关系，在班吉的巷战进行的同时，刚果国家人民军也直接越过边境，开入了班吉，同革命民兵一起作战。最终，乌班吉爱国阵线/劳动党的武装革命民兵和刚果国家人民军一起推翻了班吉的反动政权，博卡萨也在行动中被俘，并被公审判处死刑。阿贝尔·贡巴宣告了中非人民共和国的成立。克劳德-理查德·古昂加被选为中非新总统，阿贝尔·贡巴当选人民议会主席并继续作为乌班吉爱国阵线/劳动党的领导人，希莱尔·科塔林博拉则被选为政府总理，被称为“卢蒙巴的缪斯”的安德蕾·玛德琳·布鲁安被选为副总理，负责妇女革命工作。新政府宣布将在马克思列宁主义和泛非主义的道路上建设新中非，结束法帝国主义在中非肆意妄为的历史，扩大与我们的合作。\n社会主义阵营很快承认了中非的新政权。革命在中非的胜利也令法国猝不及防——在广泛的压力下，法国也放弃了对中非的干预计划，事实上承认了新政权。至少又有一个国家投入了社会主义的怀抱！"
const TXT_R0_FAIL := "|最终，仓促而缺乏足够力量的起义还是被镇压了。在1979年1月17-20日的起义以及同年4月18-20日抗议博卡萨强制中非学生强制穿博卡萨夫人公司的校服的斗争中，乌班吉爱国阵线/劳动党发挥了决定性作用。尽管动摇了博卡萨政权，但也使博卡萨用大规模逮捕和屠杀作为报复，这使得乌班吉爱国阵线/劳动党损失了大批的党员。在屠杀事件之后，博卡萨几乎失去了所有来自外部的支持和援助。\n法国人终于决定驱逐这位暴君了，法国人决定开展“梭鱼行动”，武力推翻博卡萨，扶持新代理人。1979年9月20日，法国士兵经乍得飞往班吉，推翻了博卡萨的“帝国”。亲法的戴维·达科通过操纵选举重新担任中非共和国总统。达科表示“如有必要”，法国军队将在中非维持军事占领长达十年。他未能重建一党制，在法国政府的压力下，他恢复了表面上的民主和多党制度。博卡萨当时正在利比亚进行国事访问，他逃往了科特迪瓦，并在当地流亡。"
const TXT_R1 := "我们通过布拉柴维尔向乌班吉爱国阵线/劳动党提供了军事支援，并帮助他们联系了来自前非洲民主联盟-乌班吉沙里支部的希莱尔·科塔林博拉和他的关系网，以及中非出身的几内亚民主党和非洲团结党员、卢蒙巴政府的礼宾总管安德蕾·玛德琳·布鲁安，扩充了革命力量。在1979年1月17-20日的粮食骚乱以及同年4月18-20日抗议博卡萨强制中非学生强制穿博卡萨夫人公司的校服的斗争中，乌班吉爱国阵线/劳动党发挥了决定性作用。从中吸收了一批青年志士。与此同时，我们也直接支持乌班吉爱国阵线/劳动党在军队和政府机构中进行渗透。\n在屠杀事件之后，博卡萨几乎失去了所有来自外部的支持和援助。法国人终于决定驱逐这位暴君了，法国人决定开展“梭鱼行动”，武力推翻博卡萨，扶持新代理人。1979年9月20日，法国士兵经乍得飞往班吉，推翻了博卡萨的“帝国”。亲法的戴维·达科通过操纵选举重新担任中非共和国总统。达科表示“如有必要”，法国军队将在中非维持军事占领长达十年。他未能重建一党制，在法国政府的压力下，他恢复了表面上的民主和多党制度。博卡萨当时正在利比亚进行国事访问，他逃往了科特迪瓦，并在当地流亡。"
const TXT_R2 := "在1979年1月17-20日的粮食骚乱以及同年4月18-20日抗议博卡萨强制中非学生强制穿博卡萨夫人公司的校服的暴乱中，我们向博卡萨政权直接提供了经济和军事援助。在博卡萨的屠杀事件之后，博卡萨几乎失去了所有来自外部的支持和援助，我们成为了他唯一的支持者。\n利用同法国的友好关系，我们获知了法国将发动“梭鱼行动”推翻博卡萨政权的消息，很快电话就被打到了博卡萨和他的好朋友卡扎菲那里。我们决定在利比亚和苏丹的帮助下对博卡萨进行支援。中共中央警卫团以军事考察团的名义经苏丹抵达中非；而卡扎菲也向中非派出了军队，并在乍得扰乱了法国军队的部署计划。我们的行动使得法国的颠覆行动完全失败，保住了博卡萨政权。\n博卡萨向我们表达了深刻的感激，为我们提供了钻石、铀、铁和黄金等资源开采的特许权。他将国内的所有法国人都赶出了中非，并宣布他将重启“博卡萨运动”和他曾放弃的“科学社会主义”，进行君主社会主义的建设。国号“中非帝国”也被他改为“中非人民帝国”。博卡萨宣布他将进行土地改革和并进行农业合作化的尝试，同时将开展工业化和国有化（特别是法国企业，它们被直接无偿没收）而我们将为他的政权提供稳定所需的援助和工业化资金。当然，博卡萨也继续用他的“老方法”来镇压和处决异见者——现在他们成为了“现行反革命分子”，不过这又与我们有什么关系呢？"
const TXT_R3 := "在1979年1月17-20日的粮食骚乱以及同年4月18-20日抗议博卡萨强制中非学生强制穿博卡萨夫人公司的校服的斗争中，乌班吉爱国阵线/劳动党发挥了决定性作用。尽管动摇了博卡萨政权，但也使博卡萨用大规模逮捕和屠杀作为报复。在与博卡萨政权的战斗和被关押在监狱期间，乌班吉爱国阵线/劳动党共有144名成员牺牲。在屠杀事件之后，博卡萨几乎失去了所有来自外部的支持和援助。\n法国人终于决定驱逐这位暴君了，法国人决定开展“梭鱼行动”，武力推翻博卡萨，扶持新代理人。1979年9月20日，法国士兵经乍得飞往班吉，推翻了博卡萨的“帝国”。亲法的戴维·达科通过操纵选举重新担任中非共和国总统。达科表示“如有必要”，法国军队将在中非维持军事占领长达十年。他未能重建一党制，在法国政府的压力下，他恢复了表面上的民主和多党制度。博卡萨当时正在利比亚进行国事访问，他逃往了科特迪瓦，并在当地流亡。\n我国谴责了“法非特殊关系”和法帝国主义公然干涉非洲国家的内政的行径，并号召非洲人民联合起来抵抗帝国主义的入侵，并打倒本国买办！"
const TXT_R4 := "在1979年1月17-20日的粮食骚乱以及同年4月18-20日抗议博卡萨强制中非学生强制穿博卡萨夫人公司的校服的斗争中，乌班吉爱国阵线/劳动党发挥了决定性作用。尽管动摇了博卡萨政权，但也使博卡萨用大规模逮捕和屠杀作为报复。在与博卡萨政权的战斗和被关押在监狱期间，乌班吉爱国阵线/劳动党共有144名成员牺牲。在屠杀事件之后，博卡萨几乎失去了所有来自外部的支持和援助。\n法国人终于决定驱逐这位暴君了，法国人决定开展“梭鱼行动”，武力推翻博卡萨，扶持新代理人。1979年9月20日，法国士兵经乍得飞往班吉，推翻了博卡萨的“帝国”。亲法的戴维·达科通过操纵选举重新担任中非共和国总统。达科表示“如有必要”，法国军队将在中非维持军事占领长达十年。他未能重建一党制，在法国政府的压力下，他恢复了表面上的民主和多党制度。博卡萨当时正在利比亚进行国事访问，他逃往了科特迪瓦，并在当地流亡。\n我国外交部发言人发表声明：“我国支持法国的正义行动。法国的正义行动，推翻了骑在非洲人民头上的暴君，推动了非洲社会的进步。我们欢迎达科总统的回归，并期待两国关系发展的新时代！”\n法国感谢我们对他们行动的支持，达科对我们承认了新政府很高兴，中非与我们达成了几项合作协定。"
const TXT_R5 := "在1979年1月17-20日的粮食骚乱以及同年4月18-20日抗议博卡萨强制中非学生强制穿博卡萨夫人公司的校服的斗争中，乌班吉爱国阵线/劳动党发挥了决定性作用。尽管动摇了博卡萨政权，但也使博卡萨用大规模逮捕和屠杀作为报复。在与博卡萨政权的战斗和被关押在监狱期间，乌班吉爱国阵线/劳动党共有144名成员牺牲。在屠杀事件之后，博卡萨几乎失去了所有来自外部的支持和援助。\n法国人终于决定驱逐这位暴君了，法国人决定开展“梭鱼行动”，武力推翻博卡萨，扶持新代理人。1979年9月20日，法国士兵经乍得飞往班吉，推翻了博卡萨的“帝国”。亲法的戴维·达科通过操纵选举重新担任中非共和国总统。达科表示“如有必要”，法国军队将在中非维持军事占领长达十年。他未能重建一党制，在法国政府的压力下，他恢复了表面上的民主和多党制度。博卡萨当时正在利比亚进行国事访问，他逃往了科特迪瓦，并在当地流亡。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var c21 := world.get_country_by_legacy_index(21)
	var opt := event_def.options
	if line <= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line <= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line != 0 and line != 4 and (not _mod_active(3) or not _mod_active(6)) \
			and c21 != null and c21.has_tag("对华贸易") and _tech(23):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if line <= 1:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	if line >= 2:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], TXT_OPT4_DIS)
	_enable(opt[5], event_def.options[5].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c65 := ws.get_country_by_legacy_index(65)
	var c52 := ws.get_country_by_legacy_index(52)
	var c21 := ws.get_country_by_legacy_index(21)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			if c52 != null and c52.has_tag("亲中") and _tech(23):
				var text := TXT_R0_A + TXT_R0_CONGO
				if c65 != null:
					c65.government = GameConstants.Government.SOCIALIST
					c65.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					_leave_alliances(c65)
					c65.set_tag("对华贸易", true)
					c65.set_tag("亲中", true)
				_add(W.I_DIPLO, 20)
				ws.influence_prc += 50
				if c65 != null:
					c65.chinese_name = "中非人民共和国"
				_add_relation(EmpireData.USA, -100)
				context["result_text"] = text
			else:
				var text := TXT_R0_A + TXT_R0_FAIL
				if c65 != null:
					c65.government = GameConstants.Government.AUTHORITARIAN
					c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					_leave_alliances(c65)
					c65.chinese_name = "中非共和国"
				_add_relation(EmpireData.USA, -100)
				if c65 != null:
					c65.puppet_of = GameConstants.LegacySlot.FRANCE
				context["result_text"] = text
		1:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				c65.chinese_name = "中非共和国"
				_leave_alliances(c65)
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			_add(W.I_DIPLO, 20)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
				_leave_alliances(c65)
				c65.set_tag("亲中", true)
				c65.set_tag("对华贸易", true)
			if c21 != null:
				c21.set_tag("对华贸易", false)
			if c65 != null:
				c65.chinese_name = "中非人民帝国"
			ws.influence_prc += 20
			_add(W.I_DIPLO, 20)
			context["result_text"] = TXT_R2
		3:
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				_leave_alliances(c65)
				c65.chinese_name = "中非共和国"
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			_add(W.I_DIPLO, -20)
			_add(W.I_DIPLO, 20)
			context["result_text"] = TXT_R3
		4:
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				_leave_alliances(c65)
				c65.chinese_name = "中非共和国"
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			_add(W.I_DIPLO, -20)
			if c65 != null:
				c65.set_tag("对华贸易", true)
			context["result_text"] = TXT_R4
		5:
			if c65 != null:
				c65.government = GameConstants.Government.AUTHORITARIAN
				c65.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				_leave_alliances(c65)
				c65.chinese_name = "中非共和国"
				c65.puppet_of = GameConstants.LegacySlot.FRANCE
			context["result_text"] = TXT_R5


func _mod_active(id: int) -> bool:
	return ws.modifiers.size() > id and ws.modifiers[id] != null and ws.modifiers[id].is_active


func _tech(idx: int) -> bool:
	return ws.techs != null and ws.techs.unlocked.size() > idx and ws.techs.unlocked[idx]
