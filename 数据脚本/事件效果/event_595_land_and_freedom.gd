extends "res://数据脚本/event_script_base.gd"

## 原作 Event595.cs：国土与自由（肯尼亚左翼政变，两选项）。
## 触发：TimeScript.cs:10922-10926 —— 日期>=1982.7.15。
## 差异：
##  - 描述由 prepare 按 c42.parts[1/2]、event_594 结果、c119.cw 动态拼接；
##  - c119.parts[1]=true（写前 resize）；TickTime(24) → fortnight_max=24；
##  - SovietSupportDefender.AmericanSupportAttacker → ussr_side = GameConstants.WarSide.SIDE2/usa_side = GameConstants.WarSide.SIDE1。

const TXT_DESC_A := "让我们的视角重新看回肯尼亚。自1963年从英国手中独立以来，肯尼亚处于卢奥人-基库尤人政客的统治之下，对其他民族进行打压，卢奥人政客倾向于接近东方集团，而基库尤人则主张反共亲西方政策。但是在卢奥人政客因被排挤被迫退出政府组建肯尼亚人民联盟之后，肯尼亚政府基本由基库尤人把持。在这之后，打压卢奥人和左翼的政策导致了1969年基苏木大屠杀的发生，肯尼亚人民联盟被政府查禁和解散。1977年肯尼亚与坦桑尼亚的意识形态纠纷等问题最终两国关系破裂，自殖民时期开始互相合作的机构东非共同体解散。1978年肯尼亚国父乔莫·肯雅塔去世之后，他的副手丹尼尔·莫伊随即继任上位。在莫伊的任上，肯尼亚继续了专制和亲西方政策，"
const TXT_DESC_FAIL := "肯索战争的失败加剧了肯尼亚政权的不稳定性。"
const TXT_DESC_WIN := "尽管肯索战争的胜利加大了莫伊的威望，但是肯尼亚长期执行的打压反对派和工业化出现的各种不平等现象导致肯尼亚内部依旧使得肯尼亚具备了潜在的不稳定因素。"
const TXT_DESC_C := "尽管受到肯尼亚非洲民族联盟的镇压，但是肯尼亚左派仍未停止活动，在1974年，以马克思主义历史学家迈纳·瓦·基尼亚蒂为首的地下异见分子组建了毛派组织肯尼亚工人党，就在不久前，肯尼亚人民联盟的建立者奥金加·奥廷加和与前肯尼亚社会主义党领导人乔治·安尼奥那组建了肯尼亚非洲社会主义联盟以对抗执政党"
const TXT_DESC_SUPP := "，但这一组织迅速被肯尼亚政府所镇压"
const TXT_DESC_E := "。根据情报显示1982年7月底，一名名叫希西家·奥丘卡的卢奥人空军一等兵士兵正在策划一场试图推翻莫伊的政变并成立了人民救赎委员会。该委员会包括了肯尼亚人民联盟的建立者奥金加·奥廷加和乔治·安尼奥那，迈纳·瓦·基尼亚蒂在内的肯尼亚左派，串联了数十名军人和军官，并决定在八月初发动政变。我们是否应该借此机会对肯尼亚进行干预，帮助肯尼亚重新与坦桑尼亚和好，或者干脆不管这件事？"

const TXT_OPT0_DIS := "我们对他们内政干预的过于激烈了"

const TXT_R0 := "我们决定对插手干预此事，潜伏在人民救赎委员会内部的肯尼亚安全情报局的情报人员名单被我们列了出来并送给了奥丘卡和奥廷加等人，这些情报人员被单独拉出来集中枪毙。八月一日凌晨，一伙士兵占领了内罗毕的空军基地以及肯尼亚之声广播电台，在那里广播人民救赎委员会继承茅茅运动的精神反对亲西方现任政府，并宣布推翻了肯尼亚政府。为保证政变更加顺利，从坦桑尼亚恩格莱空军基地起飞的三架“坦桑尼亚空军”轰5轰炸机成功轰炸了州议会大厦（即肯尼亚总统府）和总务部队（肯尼亚的特警）总部，莫伊因轰炸身亡。得益于我们之前成功组建了肯尼亚非洲社会主义联盟并将使其与肯尼亚工人党合作，卢奥人被组织起来发动了一场起义，并成功夺取了卢奥人为主的尼扬扎省的控制权。然而，由于此时正好在肯尼亚西北地区有一场演习，大部分军队高层和高级领导人都远离内罗毕。肯尼亚陆军副司令穆罕默德·穆罕默德少将被推举为镇压政变的总指挥，但是由于政变和长期以来潜在的不稳定性造成了全国性动乱，肯尼亚陆军难以快速平叛，肯尼亚内战就此爆发。"
const TXT_R1 := "渗透进人民救赎委员会的肯尼亚安全情报局的情报人员将政变计划上交给了莫伊，但是莫伊最终决定与八月二日让军队内部自行解决。在八月一日，一伙士兵占领了内罗毕附近的两个机场，占领了肯尼亚之声广播电台并广播军队已经推翻肯尼亚政府。人民救赎委员会的三架飞机试图轰炸州议会大厦（即肯尼亚总统府）和总务部队（肯尼亚的特警）总部，但飞行员欺骗了监督员，将炸弹扔进了肯尼亚山的森林里。由于此时正好在肯尼亚西北地区有一场演习，大部分军队高层和高级领导人都远离内罗毕。肯尼亚陆军副司令穆罕默德少将被推举为镇压政变的总指挥。在平叛过程中有一百多名军人和两百多名市民死亡，奥丘卡被捕并判领导政变未遂，于1987年绞刑处死，奥廷加因资助了此次叛乱被软禁。"

const WAR51_NAME := "肯尼亚内战"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	event_def.description = _make_desc(world)
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var kenya := world.get_country_by_legacy_index(119)
	if line < 2 and kenya != null and kenya.内战中:
		_enable(event_def.options[0], event_def.options[0].text)
	else:
		_disable(event_def.options[0], TXT_OPT0_DIS)
	_enable(event_def.options[1], event_def.options[1].text)


func _make_desc(world: WorldState) -> String:
	var somalia := world.get_country_by_legacy_index(42)
	var kenya := world.get_country_by_legacy_index(119)
	var text := TXT_DESC_A
	var somalia_fail := _part(somalia, 1) or _part(somalia, 2)
	if somalia_fail:
		text += TXT_DESC_FAIL
	elif int(world.completed_event_ids.get("event_594", 0)) != 2 and not somalia_fail:
		text += TXT_DESC_WIN
	text += TXT_DESC_C
	if kenya == null or not kenya.内战中:
		text += TXT_DESC_SUPP
	text += TXT_DESC_E
	return text


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var kenya := ws.get_country_by_legacy_index(119)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			GameManager.start_war(51, "肯尼亚军队", "人民救赎委员会", 750, 250, 0, 1)
			if ws.wars.size() > 51 and ws.wars[51] != null:
				ws.wars[51].name_war = WAR51_NAME
				ws.wars[51].fortnight_max = 24
			if kenya != null:
				while kenya.parts.size() <= 1:
					kenya.parts.append(false)
				kenya.parts[1] = true
			_add(W.I_AGENTS, -30)
			_add(W.I_ARMY, -80)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1


func _part(c: CountryData, idx: int) -> bool:
	if c == null:
		return false
	while c.parts.size() <= idx:
		c.parts.append(false)
	return c.parts[idx]



