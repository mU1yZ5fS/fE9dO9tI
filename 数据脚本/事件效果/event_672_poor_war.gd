extends "res://数据脚本/event_script_base.gd"

## 原作 Event672.cs：穷人战争（马里-布基纳法索边境战争，四选项）。
## 触发：ReqEventsDLC02.cs:339-341 —— c58.SubGosstroy==7 && IsSocialism(true,61) && DATE_AFTER 1985.9.1
##   复合条件 → trigger_script evaluate。
## 差异：ingamewars[85] 已有 war_85 WarDef，仍按 start_war 参数覆盖；
##   AmericanSupportAttacker → usa_side=1、SovietSupportDefender → ussr_side=2。

const TXT_TITLE := "穷人战争"
const TXT_DESC := "马里与布基纳法索两国长期存在边境争端，在殖民地时期，法国并未对两地边界进行准确的划界，使得阿加彻地带的边境问题一直遗留到两国独立后。马里方面基于人文地理主张对该领土的所有权，称该地区至少在季节性层面上由图阿雷格族和贝拉族居住，这些族群被视为马里人，在此定居以放牧牲畜。马里认为，这一人种因素以及马里行政当局在该地区的存在，足以构成其对争议地带的领土主张依据。而布基纳法索则依据殖民时期划定的边界和颁布的法令提出领土主张。阿加彻地带的水源和矿产也是两国争议的关键。1968年，两国成立了一个上沃尔特-马里联合委员会，试图达成协议，但该组织没有取得任何进展。气候条件进一步加剧了紧张局势。两国在20世纪70年代遭遇连续干旱，导致马里牧民被迫前往布基纳法索北部的水源地和牧场，超出了往常活动范围，引发了争议阿加彻地区农民与牧民之间的冲突。早在1974年11月，两国之间就因边界争端爆发了短暂的武装冲突，当时还是军人的托马斯·桑卡拉便参与到这次战争中。针对这次边境冲突，非统组织成立了一个调解委员会，尝试调解。1977年，两国还签订了互不侵犯协定。但是，桑卡拉领导的革命搅动了法非秩序，特拉奥雷并不喜欢这个激进的政权，而桑卡拉也不喜欢邻国的亲法独裁者，两国之间的关系逐渐降温。1984年马里降雨量稀少，引发严重干旱，迫使马里牧民驱赶牲畜南下进入布基纳法索北部，以寻找水源和充足的牧场，这引发了与当地种植农户的冲突。1985年7月，西非经济共同体马里秘书长德里萨·凯塔批评桑卡拉政权后，布基纳法索宣布其为不受欢迎的人。9月，桑卡拉发表演讲，呼吁马里开展革命。马里领导层对这一煽动性言论尤为敏感，因其国家正遭遇罢工和社会动荡的威胁。西非多国和阿尔及利亚都呼吁和平解决冲突，尝试调解矛盾。但是，特拉奥雷准备通过一场战争来巩固统治，同时武力解决掉邻国的“麻烦人物”；而桑卡拉也不介意通过战争凝聚起革命的力量，甚至是把革命之火烧到邻近的国家。据信，特拉奥雷已经开始动员军队，采取“先下手为强”的行动了……"
const TXT_OPT0 := "把革命之火烧到马里去！"
const TXT_OPT0_DIS := "我们不是什么战争贩子！"
const TXT_OPT1 := "敲打敲打上沃尔特的刺头"
const TXT_OPT1_DIS := "你怎么下得去手？"
const TXT_OPT2 := "呼吁两国和平，尝试调解矛盾"
const TXT_OPT3 := "非洲的寻常冲突管我们什么事？"
const TXT_R0 := "我们决定向布基纳法索提供援助，在我方的情报支持下，布基纳法索动员军队和民兵布防，并制定了反击计划，我们的武器援助也正通过非洲盟友运抵该国。黎明，约150辆马里坦克越过边境，向布基纳法索多个地点发动袭击。马里军队试图以钳形攻势包围博博-迪乌拉索，但是在早有准备的布基纳法索军面前难以达成有效战果，只成功进行了轰炸，而布基纳法索也对马里进行了报复性空袭……\n非洲的又一场战争开始了。"
const TXT_R1 := "我们决定向马里提供援助，向马里提供武器和情报支持。黎明，约150辆马里坦克越过边境，向布基纳法索多个地点发动袭击。马里军队试图以钳形攻势包围博博-迪乌拉索，凭借火力优势迅速攻占阿加彻地带多个城镇，还出动米格-21战斗机轰炸了吉博、瓦希古亚等地。\n布基纳法索政府当日下达动员令，部队在迪奥努加地区重新集结反击，采用游击战术对抗马里坦克，同时派遣警察、保卫革命委员会武装和民兵增援。\n非洲的又一场战争开始了……"
const TXT_R2 := "我国外交部发表声明，呼吁非洲人民争取和平，以对话解决冲突，求同存异，共谋发展。\n黎明，约150辆马里坦克越过边境，向布基纳法索多个地点发动袭击。马里军队试图以钳形攻势包围博博-迪乌拉索，凭借火力优势迅速攻占阿加彻地带多个城镇，还出动米格-21战斗机轰炸了吉博、瓦希古亚等地。\n布基纳法索政府当日下达动员令，部队在迪奥努加地区重新集结反击，采用游击战术对抗马里坦克，同时派遣警察、保卫革命委员会武装和民兵增援。该国随后出动唯一一架米格-17应对马里空袭，并对锡卡索发动报复性空袭，还突袭了马里城镇泽古阿。期间布基纳法索部队在马洪截获一支马里车队，马里则再次空袭布基纳法索多地作为回应。\n五天后，马里与布基纳法索在我国与非洲多国的斡旋下达成停火。此时马里已占领阿加彻地带大部分区域。这场冲突造成超百名布基纳法索军民和约40名马里军民丧生，双方均有战俘被处决，布基纳法索多座城镇遭重创。后续两国完成战俘交换，1986年3月西非经济共同体峰会促成双方和解，6月恢复正式外交关系。\n停火后两国均向国际法院申请临时措施，法院建议双方继续调解并避免冲突。1986年12月，国际法院将争议领土划分给两国，马里获得西部人口密集区，布基纳法索获得以贝利河为中心的东部地区，两国均对裁决表示满意。这场被布基纳法索称为“圣诞战争”的冲突，是西非非殖民化后唯一一场因领土爆发的全面国家间战争。"
const TXT_R3 := "黎明，约150辆马里坦克越过边境，向布基纳法索多个地点发动袭击。马里军队试图以钳形攻势包围博博-迪乌拉索，凭借火力优势迅速攻占阿加彻地带多个城镇，还出动米格-21战斗机轰炸了吉博、瓦希古亚等地。\n布基纳法索政府当日下达动员令，部队在迪奥努加地区重新集结反击，采用游击战术对抗马里坦克，同时派遣警察、保卫革命委员会武装和民兵增援。该国随后出动唯一一架米格-17应对马里空袭，并对锡卡索发动报复性空袭，还突袭了马里城镇泽古阿。期间布基纳法索部队在马洪截获一支马里车队，马里则再次空袭布基纳法索多地作为回应。\n五天后，马里与布基纳法索在非洲多国斡旋下达成停火。此时马里已占领阿加彻地带大部分区域。这场冲突造成超百名布基纳法索军民和约40名马里军民丧生，双方均有战俘被处决，布基纳法索多座城镇遭重创。后续两国完成战俘交换，1986年3月西非经济共同体峰会促成双方和解，6月恢复正式外交关系。\n停火后两国均向国际法院申请临时措施，法院建议双方继续调解并避免冲突。1986年12月，国际法院将争议领土划分给两国，马里获得西部人口密集区，布基纳法索获得以贝利河为中心的东部地区，两国均对裁决表示满意。这场被布基纳法索称为“圣诞战争”的冲突，是西非非殖民化后唯一一场因领土爆发的全面国家间战争。"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line <= 2:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 2:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var mali := ws.get_country_by_legacy_index(58)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			if mali != null:
				_set_part(mali, 0, true)
			_start_war(500, 500)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add_relation(EmpireData.USA, -50)
		1:
			context["result_text"] = TXT_R1
			if mali != null:
				_set_part(mali, 0, true)
			_start_war(600, 400)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add_relation(EmpireData.USA, 50)
		2:
			context["result_text"] = TXT_R2
			_add(W.I_DIPLO, -20)
			_add_relation(EmpireData.USA, 50)
			_add_relation(EmpireData.USSR, 50)
		3:
			context["result_text"] = TXT_R3


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19850901:
		return false
	var mali := world.get_country_by_legacy_index(58)
	var upper_volta := world.get_country_by_legacy_index(61)
	return mali != null and mali.sub_government == 7 \
		and upper_volta != null and world.is_socialism(upper_volta, true)


func _start_war(infl1: int, infl2: int) -> void:
	GameManager.start_war(85, "马里", "布基纳法索", infl1, infl2, 1, 2)
	if ws.wars.size() > 85 and ws.wars[85] != null:
		ws.wars[85].name_war = "马里-布基纳法索战争"


func _set_part(c: CountryData, index: int, value: bool) -> void:
	if c == null:
		return
	while c.parts.size() <= index:
		c.parts.append(false)
	c.parts[index] = value
