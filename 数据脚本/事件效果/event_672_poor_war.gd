extends "res://数据脚本/event_script_base.gd"

## 原作 Event672.cs：穷人战争（马里-布基纳法索边境战争，四选项）。
## 触发：ReqEventsDLC02.cs:339-341 —— c58.SubGosstroy==7 && IsSocialism(true,61) && DATE_AFTER 1985.9.1
##   复合条件 → trigger_script evaluate。
## 差异：ingamewars[85] 已有 war_85 WarDef，仍按 start_war 参数覆盖；
##   AmericanSupportAttacker → usa_side=1、SovietSupportDefender → ussr_side=2。

const TXT_OPT0_DIS := "我们不是什么战争贩子！"
const TXT_OPT1_DIS := "你怎么下得去手？"
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
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line >= 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)
	_enable(opt[3], event_def.options[3].text)


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
	return mali != null and mali.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN \
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
