extends "res://数据脚本/event_script_base.gd"

## 原作 Event602.cs：“南非”意味着攻击（南非问题六选项）。
## 触发：ReqEventForDLC02.cs:864-866 —— DATE_AFTER 1983.11.2；fire_only_once 承担 !event_done[602]。
## 差异：relres→ws.get_flag；now_leader→current_leader；Vyshi→亲美、Torg→对华贸易；
##   string.Format {1}{2}→_foreign_minister_name()。

const TXT_OPT0_DIS := "阿扎尼亚？那是哪个国家？"
const TXT_OPT1_DIS := "怎能支持反华的南非共产党？怎么支持反华的南非共产党？"
const TXT_OPT2_DIS := "指望洋基佬发善心？你想发扬甘地的阿Q精神？"
const TXT_OPT3_DIS := "冷战摧毁了美苏两国在南非问题上合作的可能"
const TXT_OPT4_DIS := "真的吗？就算我们无耻至极，也不排除热脸贴冷屁股的可能！"
const TXT_R0_A := "由于阿扎尼亚泛非主义大会与西南非洲民族联盟内部的毛主义派系早已在我国支持下就位，我们得以将阿扎尼亚人民解放军（阿扎尼亚泛非主义大会的军事翼）、阿扎尼亚民族解放军（阿扎尼亚人民组织的军事翼）和西南非洲民族联盟的游击队组织在统一战线下迅捷出击，打敌人个措手不及：莱索托国王收到了阿扎尼亚人民解放军勒令其退位的最后通牒；P·W·博塔总统、国防部长马格努斯·马兰与康斯坦德·维尔容将军等军政高层人物也在汽车炸弹袭击内被完全消灭。因此，阿扎尼亚人民解放军、阿扎尼亚民族解放军和西南非洲民族联盟得以利用政府内部的混乱与我国情报协助发起对南非武装部队的全线进攻；非洲国民大会党、南非共产党的非洲之矛与西南非洲人民解放军（西南非洲人民组织的军事翼）也在不久后加入混战，形成了针对种族隔离政权的多路诸侯。全世界都正关注南非内战局势：黑人对白人的种族复仇，白人对黑人的报复回击等场景充斥各地；紧急状态下的南非成为了一个大型难民营。联合国试图派遣维和部队并在南非调停局势的努力也宣告失效，该国就此陷入内战泥潭。"
const TXT_WAR_NAME := "南非内战"
const TXT_WAR_SIDE1 := "阿扎尼亚联军"
const TXT_WAR_SIDE2 := "南非"
const TXT_R0_B := "由于阿扎尼亚泛非主义大会的民族主义者早已在我国支持下就位，我们得以将阿扎尼亚人民解放军（阿扎尼亚泛非主义大会的军事翼）、阿扎尼亚民族解放军（阿扎尼亚人民组织的军事翼）和西南非洲民族联盟的游击队组织在统一战线下迅捷出击，打敌人个措手不及：莱索托国王收到了阿扎尼亚人民解放军勒令其退位的最后通牒；P·W·博塔总统、国防部长马格努斯·马兰与康斯坦德·维尔容将军等军政高层人物也在汽车炸弹袭击内被完全消灭。因此，阿扎尼亚人民解放军、阿扎尼亚民族解放军和西南非洲民族联盟得以利用政府内部的混乱与我国情报协助发起对南非武装部队的全线进攻；非国大、南非共产党的非洲之矛与西南非洲人民解放军（西南非洲人民组织的军事翼）也在不久后加入混战，形成了针对种族隔离政权的多路诸侯。全世界都正关注南非内战局势：黑人对白人的种族复仇，白人对黑人的报复回击等场景充斥各地；紧急状态下的南非成为了一个大型难民营。联合国试图派遣维和部队并在南非调停局势的努力也宣告失效，该国就此陷入内战泥潭。"
const TXT_R1 := "由于亲苏力量早在南非外围取得完胜，我们得以更好地武装三方联盟：非洲之矛与非国大武装力量开始在安哥拉与莫桑比克接受苏联军事训练并武装苏械。P·W·博塔总统、国防部长马格努斯·马兰与康斯坦德·维尔容将军等军政高层人物也在古巴人谋划的汽车炸弹袭击内被完全消灭。因此，非国大、南非共产党的非洲之矛与西南非洲人民解放军（西南非洲人民组织的军事翼）得以利用政府内部的混乱与中苏两国情报协助发起对南非武装部队的全线进攻；阿扎尼亚泛非主义大会、阿扎尼亚人民组织和西南非洲民族联盟也在不久后加入混战，形成了针对种族隔离政权的多路诸侯。全世界都正关注南非内战局势：黑人对白人的种族复仇，白人对黑人的报复回击等场景充斥各地；紧急状态下的南非成为了一个大型难民营。联合国试图派遣维和部队并在南非调停局势的努力也宣告失效，该国就此陷入内战泥潭。"
const TXT_WAR1_NAME := "南部非洲混战"
const TXT_WAR1_SIDE1 := "非国大联军"
const TXT_WAR1_SIDE2 := "南非"
const TXT_R2_BASE := "就南非问题特意致电美国总统，认定该国目前的混乱局势与其管理层的无能无助于遏制非洲“共产主义麻风病”，且南非本身也极可能在五年内沦陷。卡特总统勉为其难地赞同了我国的立场，并委托中央情报局“好好办”。"
const TXT_R2_REFORM := "比勒陀利亚在不久后便进入戒严。人们本以为这是种族隔离政权的惯常镇压，然而事实很快便跑过了传言：南非内部的“激进改革派”推翻了博塔总统。新政府将由约翰内斯·赫尔登赫伊斯将军牵头，与被中情局收买的国防部长马格努斯·马兰一同“拨乱反正”。他们宣布将纠正“国民党选举中的舞弊行为”，邀请了矿业大亨哈利·奥本海默与祖鲁国王参与组阁与实施改革，“真相与和解委员会”也随之成立。尽管政变上位这一举措本身遭到了左翼势力的谴责，但南非当局很快便通过“释放曼德拉”的信号将其——要求非国大出卖共产党达成和解的提议确实得到了前者的芳心。似乎南非正以退为进，实施本土特色的解冻时刻。一切都在往好的方向发展，对吗？"
const TXT_R2_CONSERV := "比勒陀利亚在不久后便进入戒严。人们本以为这是种族隔离政权的惯常镇压，然而事实很快便跑过了传言：南非内部的“保守派”推翻了博塔总统。新政府将由陆军总帅康斯坦德·维尔容将军牵头进行“拨乱反正”，并搜查“博塔总统修宪当中的违宪行为”与138条腐败指控。政变立即遭到了左翼势力的谴责，而维尔容将军对此毫不手软，做了两手准备：一面让一批黑人反对派蹲牢房，一面则指定“民主人士”，同样支持隔离政策的安德里斯·佩特鲁斯·特鲁尼希特充当临时政府花瓶领导人。维尔容在出访华盛顿期间许诺进一步改革种族隔离制度——这话当然只对美国选民有用。接下来便是实施本土特色的解冻时刻：不久后，反抗种族隔离的斗士纳尔逊·曼德拉于被特赦之日突遭激进派黑人民族主义者刺杀的消息传遍全国……\n变革的声音传达到了华盛顿，而他们做出了“最好的安排”。"
const TXT_R3 := "通过中国外交官的协调，美苏两国得以在南非问题上达成共识并通力合作：不久后，美国便在外交照会上加强对南非政权的制裁——其中包括限制军备出售；“自由之家”对南非的评级也从“部分自由”改为“不自由”——理由是博塔总统试图通过修宪实现独裁，从而终结南非民主事业。与此同时，苏联也带领东方集团各国正式谴责南非政权，并宣布将制裁一切与南非有商贸往来的国家。曾驻列宁格勒的南非喷气机开发小组被遣返，苏东诸国同南非的”秘密合同“也被以史塔西为代表的安全机构叫停。博塔总统不久后便因内忧外患而遭弹劾，为改革派政客F·W·德克勒克取代，德克勒克一上任即宣布开启民主改革，并将就改革细则同与以黑人为主的非洲人国民大会进行政治协商。南非共产党也将在此后获得合法地位。对于南非的“洗心革面”，全世界都正拭目以待……"
const TXT_R4_FMT := "我们为博塔政权释放了友好信号，并派遣{1}{2}私访南非打探口风。然而”南非的鳄鱼”博塔却声称合作的关键在“我方诚意如何”——只要中国能批准有利于南非贸易顺差的歧视性贸易条款，在“民用核技术”达成合作，以及做出停止支持南部非洲左派势力的保证；那么南非必将改弦更张：一方面彻底断绝同台湾国民党政权与海外反华势力的合作关系，一方面则与我国达成使用南非雇佣兵的长期军事合同，最终形成外交上的中南共进退格局。综合评估效益后，我们愉快地达成了协定。代价自然是非洲诸国的集体谴责与公报断交，乃至各地“进步主义”对中南邪恶联盟的敌意。国际社会上有关中国与种族主义分子合作的传言四起……"
const TXT_R5 := "无事发生，虽说南非政权每日江河日下，但却死而不僵。摇摇欲坠的种族隔离政权短期内毫无垮台的迹象，所谓“自由世界”依然在制裁与撤资的同时发展同南非的“建设性关系”，为其无望地输血。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 6:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var china := world.get_country_by_legacy_index(1)
	var usa := world.get_country_by_legacy_index(51)
	var south_africa := world.get_country_by_legacy_index(131)
	var lesotho := world.get_country_by_legacy_index(132)
	var zimbabwe := world.get_country_by_legacy_index(127)
	var mozambique := world.get_country_by_legacy_index(126)
	var opt := event_def.options
	if line < 3 and lesotho != null and lesotho.内战中 and south_africa != null and south_africa.内战中 and ws.influence_prc > 600:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line < 2 and world.get_flag("relres") and china != null and china.has_tag("ovd") \
			and south_africa != null and south_africa.内战中 \
			and (zimbabwe == null or zimbabwe.government != 3) \
			and (mozambique == null or mozambique.government != 3) \
			and (zimbabwe == null or not zimbabwe.has_tag("亲美")) \
			and (mozambique == null or not mozambique.has_tag("亲美")):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if china != null and china.government == 3 and south_africa != null and south_africa.内战中 \
			and usa != null and usa.development == 1 \
			and (zimbabwe == null or zimbabwe.puppet_of < 0) \
			and world.empires.size() > EmpireData.USA and world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USA] != null and world.empires[EmpireData.USSR] != null \
			and world.empires[EmpireData.USA].power > world.empires[EmpireData.USSR].power \
			and ws.influence_prc > 500:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if line > 0 and south_africa != null and south_africa.内战中 \
			and world.empires.size() > EmpireData.USA and world.empires.size() > EmpireData.USSR \
			and world.empires[EmpireData.USA] != null and world.empires[EmpireData.USSR] != null \
			and world.empires[EmpireData.USA].relations >= 650 and world.empires[EmpireData.USSR].relations >= 650 \
			and ws.influence_prc > 500:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	if line > 1 and china != null and china.government != 1 and ws.influence_prc > 500:
		_enable(opt[4], event_def.options[4].text)
	else:
		_disable(opt[4], TXT_OPT4_DIS)
	_enable(opt[5], event_def.options[5].text)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var south_africa := _country(131)
	var namibia := _country(153)
	var opt := int(context.get("option_index", -1))
	var num := 0
	if _res_ev("event_609") == 0:
		num = 50
	match opt:
		0:
			if namibia != null and namibia.government == 1:
				context["result_text"] = TXT_R0_A
				_start_war(54, TXT_WAR_NAME, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 400 + num, 600 - num, 1, -1, 24)
			else:
				context["result_text"] = TXT_R0_B
				_start_war(54, TXT_WAR_NAME, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 500 + num, 500 - num, 1, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 0, true)
				south_africa.sub_government = 9
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -120)
			_add_relation(EmpireData.USA, -150)
		1:
			context["result_text"] = TXT_R1
			_start_war(55, TXT_WAR1_NAME, TXT_WAR1_SIDE1, TXT_WAR1_SIDE2, 500 + num, 500 - num, 1, 0, 24)
			if south_africa != null:
				_set_part(south_africa, 1, true)
				south_africa.sub_government = 9
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -60)
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, 150)
		2:
			var text2 := _leader_name() + TXT_R2_BASE
			if world_empire_leader_is(0, 1):
				text2 += TXT_R2_REFORM
				if south_africa != null:
					south_africa.government = 3
					south_africa.sub_government = 12
					south_africa.set_tag("亲美", true)
					south_africa.set_tag("对华贸易", true)
			else:
				text2 += TXT_R2_CONSERV
				if south_africa != null:
					south_africa.set_tag("亲美", true)
					south_africa.set_tag("对华贸易", true)
			context["result_text"] = text2
		3:
			context["result_text"] = TXT_R3
			if south_africa != null:
				south_africa.government = 3
				south_africa.sub_government = 5
				south_africa.set_tag("对华贸易", true)
			_add(W.I_AGENTS, -100)
			_add(W.I_BUDGET, -100)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, 150)
		4:
			context["result_text"] = TXT_R4_FMT.replace("{1}{2}", _foreign_minister_name())
			for c in ws.countries:
				if c == null:
					continue
				var i := int(c.原版序号)
				if ((i >= 52 and i < 69) or (i > 105 and i < 109) or (i > 111 and i < 134) \
						or i == 41 or i == 42 or i == 52 or i == 99 or i == 100 or i == 150 or i == 151) \
						and i != 128 and (c.government == 1 or c.government == 2 or c.sub_government == 0):
					c.set_tag("亲中", false)
					c.set_tag("econ", false)
					c.set_tag("okb", false)
					c.set_tag("对华贸易", false)
			if south_africa != null:
				south_africa.government = 2
				south_africa.sub_government = 8
				_leave_alliances(south_africa)
				_establish_prochina(south_africa)
				south_africa.set_tag("对华贸易", true)
			_add(W.I_BUDGET, -250)
			_add(W.I_PEOPLE_SUPPORT, -150)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add(W.I_AGRICULTURE, 100)
			ws.influence_prc -= 100
		5:
			context["result_text"] = TXT_R5






func _get_war(war_id: int) -> WarData:
	if ws == null or war_id < 0 or war_id >= ws.wars.size():
		return null
	return ws.wars[war_id]

func _country(idx: int) -> CountryData:
	return ws.get_country_by_legacy_index(idx)

func _tag(idx: int, tag: String, value: bool) -> void:
	var c := _country(idx)
	if c != null:
		c.set_tag(tag, value)

func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value

func _part(idx: int, index: int) -> bool:
	var c := _country(idx)
	if c == null:
		return false
	return c.parts.size() > index and c.parts[index]

func _done(ev: String) -> bool:
	return ws != null and ws.completed_event_ids.has(ev)

func _res_ev(ev: String, default: int = 0) -> int:
	if ws == null:
		return default
	return int(ws.completed_event_ids.get(ev, default))

func _mod_active(idx: int) -> bool:
	return ws != null and ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active

func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"

func _foreign_minister_name() -> String:
	if ws != null and ws.politics_positions.size() > 2:
		var idx: int = ws.politics_positions[2]
		if idx >= 0 and idx < ws.politicians.size() and ws.politicians[idx] != null \
				and ws.politicians[idx].name_display != "":
			return ws.politicians[idx].name_display
	return "黄华"

func _war_going(war_id: int) -> bool:
	var war := _get_war(war_id)
	return war != null and war.is_going

func _establish_prochina(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲中", true)
	c.set_tag("亲苏", false)
	c.set_tag("亲美", false)

func _establish_prosoviet(c: CountryData) -> void:
	if c == null:
		return
	c.set_tag("亲苏", true)
	c.set_tag("亲中", false)
	c.set_tag("亲美", false)

func _start_war(war_id: int, war_name: String, side1: String, side2: String, infl1: int, infl2: int, usa_side: int, ussr_side: int, tick_time: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = -1



func world_empire_leader_is(empire_index: int, leader_value: int) -> bool:
	return ws.empires.size() > empire_index and ws.empires[empire_index] != null \
			and ws.empires[empire_index].current_leader == leader_value
