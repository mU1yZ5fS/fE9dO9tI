extends "res://数据脚本/event_script_base.gd"

## 原作 Event501.cs：西方-81演习（5选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_R0_A := "外交部长"
const TXT_R0_B := "同志强烈谴责了苏修帝国主义明晃晃的破坏世界和平的举动。称其为极不明智的举动，穷兵黩武只会埋葬了苏联。\n苏军出动了十个以上的诸兵种合成集团军和近卫坦克军，在前线航空兵、远程航空兵以及国土防空军的伴随下，进行了大纵深装甲合成突击战术的演练。苏军首次出动由新式T80和T72组成的坦克军对假想敌进行装甲冲击，辅以集团军属地地火箭营进行精确战术打击，掩护后继的摩托化步兵继续前进，演习中大量出现空降强击旅，OMG集群等多种苏军新式战役建制，同时波罗的海舰队还出动了基辅号重型载机巡洋舰掩护海军步兵重装突击上陆。苏军在演习中也大量进行复杂条件下大规模诸兵种快速推进训练，总兵力超过五十万人。这无疑震撼了全世界的观察家，苏联即使遭受了不少挫折，依然有能力当社会主义大家庭的家长。"
const TXT_R1_A := "出于对抗苏联的威胁，我们决定在华北平原展开一场军事演习，目标直指苏联的威胁。中国人民解放军高级干部战役集训班全体军官、中共中央、国务院各部委和各省、直辖市、自治区主要领导人，解放军师以上和北京军区团以上军官及当地地方干部和民兵共3万2千余人观摩了演习。"
const TXT_R1_B := "\n在整场演习中，东方红二号军用卫星的运用更是令人惊讶。红军在演习中，运用最新的太空侦查和拦截系统，截获并摧毁了蓝军发射的一枚东风-2型弹道导弹。这象征着我国有能力处理来自外太空的一切危险，也极大的刺激了美苏双方研究军事卫星的速度。"
const TXT_R1_C := "\n在盛大的阅兵式上，第二炮兵方阵带来了压箱底的家什—东风26远程战术弹道导弹。这枚导弹据估计有能力达到关岛甚至更远。美国人再也不能高枕无忧了！"
const TXT_R1_D := "\n在演习中，一部分观察家注意到了一批样貌奇怪的飞机。他们没有特殊的作战手段却频频起飞，身旁辅助的两架歼轰-7搭载的导弹却能准确的击中蓝军雷达等设施。近乎无效化了蓝军的防空措施。在阅兵式中，这作为空军的最新项目：青云-1型电子支援机和歼轰-7E型电子歼击机，以及搭载的言鸟通信对抗系统。我们可以自豪的说，再也没有雷达可以抓住我们的飞机了！"
const TXT_R1_E := "\n演习期间，参演部队连同保障部队共出动11.4万余人，动用坦克、装甲车1327辆，火炮1541门，飞机475架，汽车10606辆。华北大演习的消耗约占当年军费的十六分之一，国务院特批拨款。演习结束后，于9月19日上午在张家口机场进行，被称为“1981年华北大阅兵”，"
const TXT_R1_F := "中国共产党中央军事委员会主席"
const TXT_R1_H := "和最高领导人"
const TXT_R1_I := ""
const TXT_R1_J := "共同检阅了解放军和民兵，并发表了讲话。"
const TXT_R1_K := "中国共产党中央军事委员会主席兼最高领导人"
const TXT_R2 := "我们作为苏联社会主义阵营的一位成员，自然有义务和家长走在一起，苏联欣然同意。我们派出了有“铁军”美称的中国人民解放军第127师参与演习。他们将作为演习的特别嘉宾出席。\n苏军出动了十个以上的诸兵种合成集团军和近卫坦克军，在前线航空兵、远程航空兵以及国土防空军的伴随下，进行了大纵深装甲合成突击战术的演练。苏军首次出动由新式T80和T72组成的坦克军对假想敌进行装甲冲击，辅以集团军属地地火箭营进行精确战术打击，掩护后继的摩托化步兵继续前进，演习中大量出现空降强击旅，OMG集群等多种苏军新式战役建制，同时波罗的海舰队还出动了基辅号重型载机巡洋舰掩护海军步兵重装突击上陆。苏军在演习中也大量进行复杂条件下大规模诸兵种快速推进训练，总兵力超过五十万人。这无疑震撼了全世界的观察家，苏联即使遭受了不少挫折，依然有能力当社会主义大家庭的家长。"
const TXT_R3_A := "我们决定向苏联派出军事观察员，苏联方面欣然接受。以"
const TXT_R3_B := "为首的中国人民解放军代表团参与了对军演的欣赏。\n苏军出动了十个以上的诸兵种合成集团军和近卫坦克军，在前线航空兵、远程航空兵以及国土防空军的伴随下，进行了大纵深装甲合成突击战术的演练。苏军首次出动由新式T80和T72组成的坦克军对假想敌进行装甲冲击，辅以集团军属地地火箭营进行精确战术打击，掩护后继的摩托化步兵继续前进，演习中大量出现空降强击旅，OMG集群等多种苏军新式战役建制，同时波罗的海舰队还出动了基辅号重型载机巡洋舰掩护海军步兵重装突击上陆。苏军在演习中也大量进行复杂条件下大规模诸兵种快速推进训练，总兵力超过五十万人。这无疑震撼了全世界的观察家，苏联即使遭受了不少挫折，依然有能力当社会主义大家庭的家长。"
const TXT_R4 := "在中央军委的提议下，我们决定和美国等自由世界国家开展一场规模接近的军事行动反向威胁苏联。这一决定获得了美国鹰派和强硬反苏派，尤其是布热津斯基的支持。\n最后，我们和美国在亚太地区召开了“神射手”行动，旨在模拟苏联和朝鲜对韩国发动的第二次朝鲜战争。韩国和日本积极的参与了作战演习。我们和美国的关系更紧密了。苏联也不得不把远东和中亚的防卫等级再次提高。"
const TXT_OPT1_DIS := "我们为什么要耗费那么大的力气？"
const TXT_OPT2_DIS := "没人会欢迎我们的介入"
const TXT_OPT3_DIS := "苏联人不欢迎我们"
const TXT_OPT4_DIS := "不能把祖国卖给美国！"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if ws.数值表[56] < 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if _tag(1, "ovd"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if _empire_rel(1) >= 590:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	if _tag(1, "seato") and _tag(51, "对华贸易"):
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], TXT_OPT4_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			var fm := _office_name(2)
			context["result_text"] = TXT_R0_A + fm + TXT_R0_B
			_add_relation(1, -80)
			_add_power(1, 100)
		1:
			var text1 := TXT_R1_A
			if _tech(29):
				text1 += TXT_R1_B
			if _tech(21):
				text1 += TXT_R1_C
			if _tech(22):
				text1 += TXT_R1_D
			text1 += TXT_R1_E
			if ws.politics_positions[1] != 150 and ws.politics_positions[1] != 200:
				text1 += TXT_R1_F + _office_name(1) + TXT_R1_H + _leader_name() + TXT_R1_I
			else:
				text1 += TXT_R1_J + _leader_name() + TXT_R1_K
			context["result_text"] = text1
			_add(6, 200)
			_add(8, -60)
			_add(22, -150)
			ws.influence_prc += 150
			_add_relation(0, -50)
			_add_relation(1, -150)
		2:
			context["result_text"] = TXT_R2
			_add(6, 100)
			ws.influence_prc -= 100
			_add_relation(0, -200)
			_add_relation(1, 200)
			_add_power(1, 200)
		3:
			var text3 := TXT_R3_A
			if ws.politics_positions[1] != 150 and ws.politics_positions[1] != 200:
				text3 += _office_name(1) + TXT_R3_B
			else:
				text3 += _leader_name() + TXT_R3_B
			context["result_text"] = text3
			_add(6, 80)
			_add(22, 30)
			ws.influence_prc -= 50
			_add_relation(0, -100)
			_add_relation(1, 100)
			_add_power(1, 150)
		4:
			context["result_text"] = TXT_R4
			_add(6, 100)
			ws.influence_prc -= 100
			_add_relation(1, -100)
			_add_relation(0, 200)
			_add_power(0, 200)

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
	if china.government == 0:
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
	elif china.government == 1:
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
	elif china.government == 2:
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
	elif china.government != 3:
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
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)
