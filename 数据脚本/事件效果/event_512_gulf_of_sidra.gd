extends "res://数据脚本/event_script_base.gd"

## 原作 Event512.cs：锡德拉湾事件（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_DESC_A := "1969年8月31日，穆阿迈尔·卡扎菲上校发动政变成为利比亚的国家领导人，之后推行敌视美国等西方国家的政策，1970年收回美国在利比亚的惠勒斯空军基地并赶走当中的美军，1972年又宣布废除前政府和美国所有的合作项目并把两国关系由大使级降格为代办级。1973年，第四次中东战争当中美国军事援助以色列，此事进一步激怒卡扎菲，他宣布利比亚以北的锡德拉湾是利比亚领海，外国船只和飞机不得进入，但此事并未得到以美国为首的西方国家认可，而只认可距离利比亚北部沿岸12海里的范围内才是利比亚领海。\n"
const TXT_DESC_B := "同志，据我们外务人事的最新情报，美国将在锡德拉湾开展一次突袭，彻底打消卡扎菲的念头，我们应该做点什么？"
const TXT_R0_0 := "我们组织了一场支持卡扎菲的游行，首都的大量群众举着横幅，高喊着“美帝的黑手滚出阿拉伯！”“刽子手的罪行罄竹难书！”的口号。我们和美国的关系显著恶化了，但卡扎菲上校感谢了革命的中国人民支持利比亚的斗争，并宣布和我们扩大合作关系。\n1981年8月18日，一支以尼米兹号与福莱斯特号两艘航空母舰为首的美军舰队进入锡德拉湾进行实弹演习。8月19日清晨，一架E-2空中预警机侦测出正有两架战斗机接近，故通知两架隶属于“黑王牌”战斗机编队的F-14雄猫式战斗机上前拦截，并发现是利比亚空军的苏-22战斗机。\n美国飞行员示意叫利比亚战机离开，可是利比亚飞行员不但不理会，还向美军战机发射一枚K-13导弹。驾驶座机代号快鹰102（FastEagle102）的F-14飞行员克利曼中校避开来袭的导弹后，发现自己正好对着另一架Su-22战机，于是趁Su-22战机的飞行员尝试脱离冲突空域之际，发射一枚响尾蛇导弹将其击落。至于原本朝克利曼开火的那架苏-22，也在同时被驾驶快鹰107的穆钦斯基上校以响尾蛇导弹击落。空战前后为时不过维持约一分钟时间。\n随后，利比亚公开谴责了美国对其开展的军事行动，并公开强调“锡德拉湾以北200海里是利比亚的合法领土”，“北纬32度30分是不可逾越的死亡线”。他还宣称会对“地中海内所有的美军基地展开报复”。随后他便前往亚的斯亚贝巴"
const TXT_R0_1 := "，和他的好同志门格斯图"
const TXT_R0_2 := "强烈谴责了美帝干涉。"
const TXT_R1_0 := "我们支持了美国的行动，公开表达了对利比亚政府的不满。卡扎菲也很乐于谴责我们背叛第三世界的理论，他甚至在最近公开接见了达赖喇嘛十四世。但我们和美国的关系显著改善了。\n1981年8月18日，一支以尼米兹号与福莱斯特号两艘航空母舰为首的美军舰队进入锡德拉湾进行实弹演习。8月19日清晨，一架E-2空中预警机侦测出正有两架战斗机接近，故通知两架隶属于“黑王牌”战斗机编队的F-14雄猫式战斗机上前拦截，并发现是利比亚空军的苏-22战斗机。\n美国飞行员示意叫利比亚战机离开，可是利比亚飞行员不但不理会，还向美军战机发射一枚K-13导弹。驾驶座机代号快鹰102（FastEagle102）的F-14飞行员克利曼中校避开来袭的导弹后，发现自己正好对着另一架Su-22战机，于是趁Su-22战机的飞行员尝试脱离冲突空域之际，发射一枚响尾蛇导弹将其击落。至于原本朝克利曼开火的那架苏-22，也在同时被驾驶快鹰107的穆钦斯基上校以响尾蛇导弹击落。空战前后为时不过维持约一分钟时间。\n随后，利比亚公开谴责了美国对其开展的军事行动，并公开强调“锡德拉湾以北200海里是利比亚的合法领土”，“北纬32度30分是不可逾越的死亡线”。他还宣称会对“地中海内所有的美军基地展开报复”。随后他便前往亚的斯亚贝巴"
const TXT_R1_1 := "，和他的好同志门格斯图"
const TXT_R1_2 := "强烈谴责了美帝干涉。"
const TXT_R2_0 := "我们决定一劳永逸的解决问题：彻底让这个独裁暴君滚蛋。\n"
const TXT_R2_1 := "清晨，乌压压的机群飞向利比亚。他们的目标有六个：的黎波里的阿奇奇耶兵营，西迪比拉勒港口的突击队训练中心和机场；班加西的贝尼纳机场和民众国兵营，以及苏尔特中心区。空袭在深夜进行，借道卡拉奇起飞的30余架轰-6在短短的一小时内就将上述目标彻底摧毁。利比亚空军已完全瘫痪，卡扎菲本人和三个孩子也在空袭中丧生。随后，巴希尔·哈瓦迪上将所带领的军队乘乱接管了利比亚的各大城市，我们也认可了他的举动，并迅速承认了临时政府。而原先的左翼反对派：马克思主义的利比亚民族民主阵线和复兴主义的利比亚民族运动（由利比亚复兴党的前成员在其被卡扎菲解散后重组而成），也得以正式在这样的一场爬竿政变中确认自己的领导地位，二者对科学社会主义和阿拉伯民族主义仍然抱有浓厚的兴趣。从海外的流亡结束后，他们再度踏上了利比亚的土地，不是反叛者，而是新的革命领军人。首先二者在的黎波里签署了合并协定，双方将合并为统一的利比亚劳动党，这是一个在阿拉伯社会主义的基础上吸纳了前马克思主义者，意大利工人主义和复兴主义元素的左翼组织。乌姆兰·卜尔维斯则被选举为新政府的首脑，阿杜拉希姆·萨利赫博士出任劳动党第一书记。新政府在继续石油国有化的同时也在加大和社会主义国家间的合作，并邀请我们派遣农业专家和政治委员帮助建设新的社会主义利比亚。"
const TXT_R2_2 := "清晨，乌压压的集群飞向利比亚。他们的目标有六个：的黎波里的阿奇奇耶兵营，西迪比拉勒港口的突击队训练中心和机场；班加西的贝尼纳机场和民众国兵营，以及苏尔特中心区。空袭在深夜进行，借道卡拉奇起飞的30余架轰-6在短短的一小时内就将上述目标彻底摧毁。利比亚空军已完全瘫痪，卡扎菲本人也在空袭中丧生。随后，一场起义爆发了。穆斯塔法·贾利勒组织了一场宫廷政变并组建了全国解放委员会。我们迅速承认了临时政府。很快，全国解放委员会正式改组为利比亚民主党，国王得以重新回到他那最忠诚的的黎波里，西方世界也乐于承认这样一个政权。毕竟新政府第一件事便是快速的去国有化，很快，西方石油公司和我们的石油企业也来到了这里，做着和革命前一样的事情……"
const TXT_R2_3 := "清晨，乌压压的集群飞向利比亚。他们的目标有六个：的黎波里的阿奇奇耶兵营，西迪比拉勒港口的突击队训练中心和机场；班加西的贝尼纳机场和民众国兵营，以及苏尔特中心区。空袭在深夜进行，珊瑚海号航空母舰起飞了6架A-6，从英国空军基地远道而来的16架共计30架次的B-52轰炸机在短短的一小时内就将上述目标彻底摧毁。利比亚空军已完全瘫痪，卡扎菲本人也在空袭中丧生。随后，巴希尔·哈瓦迪上将所带领的军队乘乱接管了利比亚的各大城市，西方各国和我们认可了他的举动，并迅速承认了临时政府。很快，一个意料之外但情理之中的选项：伊德里斯一世登上了台面。国王宣布重新回到他那最忠诚的的黎波里，西方世界也乐于承认这样一个君主，毕竟他又老又任人摆布，很快，西方石油公司和我们的石油企业也来到了这里，做着和革命前一样的事情……"
const TXT_R3_0 := "1981年8月18日，一支以尼米兹号与福莱斯特号两艘航空母舰为首的美军舰队进入锡德拉湾进行实弹演习。8月19日清晨，一架E-2空中预警机侦测出正有两架战斗机接近，故通知两架隶属于“黑王牌”战斗机编队的F-14雄猫式战斗机上前拦截，并发现是利比亚空军的苏-22战斗机。\n美国飞行员示意叫利比亚战机离开，可是利比亚飞行员不单不理会，还向美军战机发射一枚K-13导弹。驾驶座机代号快鹰102（FastEagle102）的F-14飞行员克利曼中校避开来袭的导弹后，发现自己正好对着另一架Su-22战机，于是趁Su-22战机的飞行员尝试脱离冲突空域之际，发射一枚响尾蛇导弹将其击落。至于原本朝克利曼开火的那架苏-22，也在同时被驾驶快鹰107的穆钦斯基上校以响尾蛇导弹击落。空战前后为时不过维持约一分钟时间。\n随后，利比亚公开谴责了美国对其开展的军事行动，并公开强调“锡德拉湾以北200海里是利比亚的合法领土”，“北纬32度30分是不可逾越的死亡线”。他还宣称会对“地中海内所有的美军基地展开报复”。随后他便前往亚的斯亚贝巴"
const TXT_R3_1 := "，和他的好同志门格斯图"
const TXT_R3_2 := "强烈谴责了美帝干涉。"
const TXT_OPT0_DIS := "为什么？为什么！"
const TXT_OPT1_DIS := "别和帝国主义者走这么近！"
const TXT_OPT2_DIS := "我们不能这么做"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	event_def.description = TXT_DESC_A + _leader_name() + TXT_DESC_B
	if ws.数值表[56] < 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ws.数值表[56] > 2 and _tag(51, "对华贸易"):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if (_tag(1, "okb") or _tag(1, "seato")) and ws.influence_prc >= 600 and _cf(13, "cw") == 1:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], event_def.options[3].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c13 := ws.get_country_by_legacy_index(13)
	var _c41 := ws.get_country_by_legacy_index(41)
	var c57 := ws.get_country_by_legacy_index(57)
	match opt:
		0:
			var text0 := TXT_R0_0
			if _cf(41, "SubGosstroy") == 10:
				text0 += TXT_R0_1
			text0 += TXT_R0_2
			context["result_text"] = text0
			if c13 != null: c13.set_tag("对华贸易", true)
			if c13 != null: c13.government = GameConstants.Government.AUTHORITARIAN
			if c13 != null: c13.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			ws.influence_prc += 10
			_add_relation(0, -100)
			ws.oil_prod += 150.0  # Event512.cs result0：利比亚扩大合作
		1:
			_add(8, -30)
			var text1 := TXT_R1_0
			if _cf(41, "SubGosstroy") == 10:
				text1 += TXT_R1_1
			text1 += TXT_R1_2
			context["result_text"] = text1
			if c13 != null: c13.set_tag("对华贸易", false)
			if c13 != null: c13.government = GameConstants.Government.AUTHORITARIAN
			if c13 != null: c13.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_add_relation(0, 150)
		2:
			if ws.wars.size() > 20 and ws.wars[20] != null and ws.wars[20].is_going:
				ws.wars[20].infl2 = 1000
				ws.wars[20].infl1 = 0
			if c13 != null: c13.puppet_of = -1
			for c in ws.countries:
				if c != null and c.puppet_of == 13:
					c.puppet_of = -1
			var text2 := TXT_R2_0
			if c57 != null and c57.puppet_of == 13:
				c57.puppet_of = -1
			if ws.数值表[56] < 3 and _tag(1, "okb"):
				text2 += TXT_R2_1
				if c13 != null:
					_leave_alliances(c13)
					c13.government = GameConstants.Government.SOCIALIST
					c13.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
					c13.set_tag("对华贸易", true)
					c13.set_tag("亲中", true)
				if c13 != null:
					if c13.parts.size() <= 0: c13.parts.resize(1)
					c13.parts[0] = false
				ws.influence_prc += 30
			if ws.数值表[56] >= 3 and _tag(1, "okb"):
				text2 += TXT_R2_2
				if c13 != null:
					_leave_alliances(c13)
					c13.government = GameConstants.Government.LIBERAL
					c13.sub_government = GameConstants.SubGovernment.MODERATE
					c13.set_tag("亲中", true)
				if c13 != null:
					if c13.parts.size() <= 0: c13.parts.resize(1)
					c13.parts[0] = false
			if _tag(1, "seato"):
				text2 += TXT_R2_3
				if c13 != null:
					_leave_alliances(c13)
					c13.government = GameConstants.Government.AUTHORITARIAN
					c13.sub_government = GameConstants.SubGovernment.RIGHT_AUTHORITARIAN
					c13.set_tag("亲美", true)
				if c13 != null:
					if c13.parts.size() <= 0: c13.parts.resize(1)
					c13.parts[0] = false
			context["result_text"] = text2
		3:
			var text3 := TXT_R3_0
			if _cf(41, "SubGosstroy") == 10:
				text3 += TXT_R3_1
			text3 += TXT_R3_2
			context["result_text"] = text3
			if c13 != null: c13.government = GameConstants.Government.AUTHORITARIAN
			if c13 != null: c13.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST

func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _office_name(pos: int) -> String:
	if ws != null and ws.politics_positions.size() > pos:
		var pi: int = ws.politics_positions[pos]
		if pi >= 0 and pi < ws.politicians.size():
			var p: PoliticianData = ws.politicians[pi]
			if p != null and p.name_display != "":
				return p.name_display
	return "华国锋"


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() 		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data[W.I_PARTY_SYSTEM] == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data[W.I_IDEOLOGY] <= 2 and data[W.I_ECON_SYSTEM] < 13 				and data[W.I_DIPLO] >= 700 and data[W.I_PARTY_SYSTEM] < 8 				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data[W.I_ECON_SYSTEM] >= 13 and data[W.I_WAR_SUPPORT] >= 700 and not _mod_active(6)) 				or _mod_active(38):
			result = 9
		elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_WAR_SUPPORT] >= 700 				and data[W.I_DIPLO] >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data[W.I_ECON_SYSTEM] >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data[W.I_PARTY_SYSTEM] <= 7 				and data[W.I_ECON_SYSTEM] <= 12 and data[W.I_RELIGION] <= 25:
			result = 17
		elif data[W.I_IDEOLOGY] == 1 and not _mod_active(6) and data[W.I_RELIGION] <= 26:
			result = 16
		elif data[W.I_ECON_SYSTEM] < 13 and data[W.I_PRESS_POLICY] >= 17 				and data[W.I_IDEOLOGY] == 1 and data[W.I_RELIGION] <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(40):
			result = 8
		elif data[W.I_IDEOLOGY] >= 2 and data[W.I_ECON_SYSTEM] >= 13 				and data[W.I_DIPLO] <= 700 and data[W.I_PARTY_SYSTEM] >= 8 				and data[W.I_PRESS_POLICY] >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] >= 12 				and data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 300 				and data[W.I_TERRITORY] > 21 and data[W.I_WAR_SUPPORT] >= 700:
			result = 11
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 14 				and data[W.I_DIPLO] >= 500 and data[W.I_ECON_SYSTEM] > 11 				and data[W.I_WAR_SUPPORT] >= 400:
			result = 8
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 13 				and data[W.I_PRESS_POLICY] > 17:
			result = 3
		elif data[W.I_PARTY_SYSTEM] <= 8 				and (data[W.I_ECON_SYSTEM] == 13 or data[W.I_ECON_SYSTEM] == 12) 				and data[W.I_WAR_SUPPORT] < 700 and not _mod_active(3) 				and data[W.I_PRESS_POLICY] >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 500:
		result = 4
	elif (data[W.I_PARTY_SYSTEM] <= 8 and data[W.I_PRESS_POLICY] <= 18) 			or data[W.I_WAR_SUPPORT] >= 700:
		result = 12
	elif data[W.I_ECON_SYSTEM] > 13 and data[W.I_DIPLO] < 700:
		result = 6
	else:
		result = 5
	return result


func _tech(idx: int) -> bool:
	return ws != null and ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _mod(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx].is_active


func _empire_rel(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].relations
	return 0


func _empire_power(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func _cf(idx: int, field: String) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return 0
	match field:
		"Gosstroy": return c.government
		"SubGosstroy": return c.sub_government
		"dev": return c.development
		"spec": return c.special
		"soc_stab": return c.social_stability
		"stab": return c.stab
		"puppetOf": return c.puppet_of
		"prcpower": return c.prc_power
		"prcinfl": return c.prc_influence
		"cw": return 1 if c.内战中 else 0
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)
