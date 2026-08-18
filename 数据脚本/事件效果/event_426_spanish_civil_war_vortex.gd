extends "res://数据脚本/event_script_base.gd"

## 原作 Event426.cs：西班牙内战的漩涡（六选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1389-1391 —— DATE_AFTER + resultOfEvents[424]==0 + event_done[424] + war30 进行。
## 差异：Gosstroy→government；SubGosstroy→sub_government；soc_stab→social_stability；stab→stability；
##  - Torg→对华贸易；AttackerInfluence/DefenderInfluence→infl1/infl2；TickTime 缺省 999。

const TXT_TITLE := "西班牙内战的漩涡"
const TXT_DESC := "随着西班牙内战的进行，原本就暗流涌动的西班牙政治局势变得更加混乱了。\n在长枪党赢得第一次内战后，佛朗哥便决定“清洗”少数民主群体内的共和国支持者，并在国内建立了单一制：自治区被彻底废除，西班牙语成为了该国唯一官方语言，学校与媒体内禁止出现民族地区的语言。上述政策的长期实行增进了民族地区的分离主义情绪。20世纪70年代以来，西班牙的左翼民族武装团体（如加泰罗尼亚的“自由之地”，巴斯克的埃塔，加利西亚的“革命武装斗争”，安达卢西亚的2月28日武装团体和阿斯图里亚斯的AndechaObrera等等）开始变得越加活跃，并成为了西班牙政府的心头大患。而在1977-1978年赋予各地区自治权的举措并没有削弱他们的分离情绪。现在，在内战席卷西班牙的情况下，分离主义力量最强大的巴斯克和加泰罗尼亚借机宣布独立。在意识到内战各方的军队都会回击分离主义势力的情况下，他们依托于左翼分离主义的武装团体，建立了自己的国防军。超级大国谴责了上述地区的分离主义。\n西班牙的反修派的两大游击队——西共（马列）领导的革命反法西斯和爱国阵线（因为内战爆发，该游击队并未解散）、西共（重建）领导的10月1日反法西斯抵抗组织——也在内战时期加强了活动，于此同时，西班牙工人党也利用它与工会运动的联系，加强了反法西斯活动。"
const TXT_OPT0_EN := "向加泰罗尼亚与巴斯克国送去军事与人道主义援助（需要10.0百万{0}、5.0点{1}与15.0点{2}）"
const TXT_OPT1 := "承认加泰罗尼亚与巴斯克国的独立"
const TXT_OPT2 := "谴责分离主义者"
const TXT_OPT5 := "不闻不问"
const TXT_WAR31 := "巴斯克独立战争"
const TXT_ATT31 := "巴斯克国"
const TXT_DEF31 := "政府军"
const TXT_WAR32 := "加泰罗尼亚独立战争"
const TXT_ATT32 := "加泰罗尼亚"
const TXT_R0 := "我们向巴斯克国与加泰罗尼亚政府送去了人道主义与军事援助。在我们的支持下，他们得以阻止国民政府军队的前进，并取得立足之地。超级大国谴责我们干预西班牙内政。"
const TXT_R1 := "中国外交部称：“中国支持各地民族的自决权。因此，我们承认巴斯克国与加泰罗尼亚的独立。”超级大国谴责我们的声明，称其“搅乱世界局势”。西班牙国民政府则已对分离主义者发起进攻。"
const TXT_R2 := "中国外交部称：“我们不承认西班牙领土的分离主义政权，并支持该国的统一与领土完整。”西班牙国民政府则已对分离主义者发起进攻。"
const TXT_R5 := "西班牙国民政府已对分离主义者发起进攻。"
const TXT_IDX_1402 := "西班牙内战的漩涡"
const TXT_IDX_1403 := "随着西班牙内战的进行，原本就暗流涌动的西班牙政治局势变得更加混乱了。\n在长枪党赢得第一次内战后，佛朗哥便决定“清洗”少数民主群体内的共和国支持者，并在国内建立了单一制：自治区被彻底废除，西班牙语成为了该国唯一官方语言，学校与媒体内禁止出现民族地区的语言。上述政策的长期实行增进了民族地区的分离主义情绪。20世纪70年代以来，西班牙的左翼民族武装团体（如加泰罗尼亚的“自由之地”，巴斯克的埃塔，加利西亚的“革命武装斗争”，安达卢西亚的2月28日武装团体和阿斯图里亚斯的AndechaObrera等等）开始变得越加活跃，并成为了西班牙政府的心头大患。而在1977-1978年赋予各地区自治权的举措并没有削弱他们的分离情绪。现在，在内战席卷西班牙的情况下，分离主义力量最强大的巴斯克和加泰罗尼亚借机宣布独立。在意识到内战各方的军队都会回击分离主义势力的情况下，他们依托于左翼分离主义的武装团体，建立了自己的国防军。超级大国谴责了上述地区的分离主义。\n西班牙的反修派的两大游击队——西共（马列）领导的革命反法西斯和爱国阵线（因为内战爆发，该游击队并未解散）、西共（重建）领导的10月1日反法西斯抵抗组织——也在内战时期加强了活动，于此同时，西班牙工人党也利用它与工会运动的联系，加强了反法西斯活动。"
const TXT_IDX_1404 := "向加泰罗尼亚与巴斯克国送去军事与人道主义援助（需要10.0百万{0}、5.0点{1}与15.0点{2}）"
const TXT_IDX_1405 := "承认加泰罗尼亚与巴斯克国的独立"
const TXT_IDX_1406 := "谴责分离主义者"
const TXT_IDX_1407 := "不闻不问"
const TXT_IDX_1408 := "巴斯克独立战争"
const TXT_IDX_1409 := "巴斯克国"
const TXT_IDX_1410 := "政府军"
const TXT_IDX_1411 := "加泰罗尼亚独立战争"
const TXT_IDX_1412 := "加泰罗尼亚"
const TXT_IDX_1413 := "我们向巴斯克国与加泰罗尼亚政府送去了人道主义与军事援助。在我们的支持下，他们得以阻止国民政府军队的前进，并取得立足之地。超级大国谴责我们干预西班牙内政。"
const TXT_IDX_1414 := "中国外交部称：“中国支持各地民族的自决权。因此，我们承认巴斯克国与加泰罗尼亚的独立。”超级大国谴责我们的声明，称其“搅乱世界局势”。西班牙国民政府则已对分离主义者发起进攻。"
const TXT_IDX_1415 := "中国外交部称：“我们不承认西班牙领土的分离主义政权，并支持该国的统一与领土完整。”西班牙国民政府则已对分离主义者发起进攻。"
const TXT_IDX_1416 := "西班牙国民政府已对分离主义者发起进攻。"
const TXT_OPT3 := "清除两地顽固的民族主义者，将左翼游击队联合起来组成革命统一阵线"
const TXT_OPT3_DIS := "这太激进了！"
const TXT_OPT4 := "左翼卡洛斯派，人民联合王国！"
const TXT_OPT4_DIS := "君主社会主义？你在搞笑吗？"
const TXT_R3 := "我们的特工联系到所有反修派组织和左翼游击队，在帮助巴斯克政权内部的共产主义者发起了一场政变，设法清除了一批最顽固的民族主义者后，成功将他们串联了起来，成立了反法西斯革命统一阵线。阵线依托于西共（马列）、西共（重建）和西班牙工人党等组织和他们控制的工会，将各个游击队串联起来，在国民政府的控制区发起了一场大起义。于此同时，统一阵线在我们的帮助下与共和政府达成了结盟协议，双方确立了反法西斯的同盟。"
const TXT_R4 := "我们收到一则有趣的消息，因为内战，一个持有左翼卡洛斯主义的武装团体——卡洛斯主义行动小组——也依托于左翼卡洛斯党和加泰罗尼亚与巴斯克的左翼在近期重建了。考虑到他们与加泰罗尼亚和巴斯克地区的左翼分离主义的亲近关系，支持他们与左翼分离主义联合是完全可能的！在我们的帮助下，分离主义者们意识到：搞布朗基主义是不可能带来民族的解放的，只有团结在雨果·卡洛斯殿下周围建设各民族平等的自治社会主义才能真正带来解放！\n显然，卡洛斯派们要同时面对来自长枪党和共和政府的压力，祝他们好运……"
const TXT_R3_SIDE1 := "共和政府-统一阵线"
const TXT_R4_SIDE1 := "卡洛斯派"
const TXT_R4_SIDE2 := "长枪党-共和政府"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_776 := "军事实力必须高于{0}点......"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"

## 地图归属：巴斯克四省 / 加泰罗尼亚四省（map_regions.json owner=230 的对应省）。
## 原作 Event426.cs:71-72 仅置 allcountries[86].parts[0/1]，由 MapChangesScript.ShowParts
## 切 country_basks.png / katalonia.png 覆盖层。Godot 地图无覆盖层，等价实现为
## 把对应地块转移到巴斯克国/加泰罗尼亚（9000+ 虚拟 gwcode，与 WorldFactory 偏移一致）。
const BASQUE_REGION_IDS := [625, 626, 2521, 3415]
const CATALONIA_REGION_IDS := [629, 637, 2500, 2501]

func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _raw(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s


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


func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	GameManager.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var budget_reserve := d[W.I_BUDGET] + (d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0)
	var agents := d[W.I_AGENTS] if d.size() > W.I_AGENTS else 0
	var army := d[W.I_ARMY] if d.size() > W.I_ARMY else 0
	if budget_reserve >= 100 and agents >= 50 and army >= 150:
		_enable(event_def.options[0], _fmt(TXT_OPT0_EN, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594]))
	elif budget_reserve < 100:
		_disable(event_def.options[0], _fmt(TXT_IDX_566, [10]))
	elif agents < 50:
		_disable(event_def.options[0], _fmt(TXT_IDX_567, [5]))
	else:
		_disable(event_def.options[0], _fmt(TXT_IDX_776, [15]))
	_enable(event_def.options[1], TXT_OPT1)
	_enable(event_def.options[2], TXT_OPT2)
	var political_line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	if political_line <= 1 and army >= 150 and budget_reserve >= 100 and agents >= 150:
		_enable(event_def.options[3], TXT_OPT3)
	else:
		_disable(event_def.options[3], TXT_OPT3_DIS)
	var mod3_active := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	if political_line != 0 and not mod3_active and army >= 150 and budget_reserve >= 100 and agents >= 150:
		_enable(event_def.options[4], TXT_OPT4)
	else:
		_disable(event_def.options[4], TXT_OPT4_DIS)
	_enable(event_def.options[5], TXT_OPT5)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var spain := ws.get_country_by_legacy_index(86)
	var basque := ws.get_country_by_legacy_index(109)
	var catalonia := ws.get_country_by_legacy_index(110)
	if opt != 3 and opt != 4:
		if basque != null:
			basque.government = 0
			basque.sub_government = 10
		if spain != null:
			if spain.parts.size() < 2:
				spain.parts.resize(2)
			spain.parts[0] = true
			spain.parts[1] = true
		if catalonia != null:
			catalonia.government = 2
			catalonia.sub_government = 15
		if basque != null:
			basque.social_stability = 1000
			basque.stability = 1000
		if catalonia != null:
			catalonia.stability = 1000
			catalonia.social_stability = 1000
		# 地图上让巴斯克/加泰罗尼亚四省从西班牙(230)转移出去。
		GameManager.set_map_region_owner(BASQUE_REGION_IDS, basque.gwcode if basque != null and basque.gwcode > 0 else 9109)
		GameManager.set_map_region_owner(CATALONIA_REGION_IDS, catalonia.gwcode if catalonia != null and catalonia.gwcode > 0 else 9110)
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -50)
		_add(W.I_ARMY, -200)
		_add_relation(EmpireData.USA, -250)
		_add_relation(EmpireData.USSR, -250)
		if basque != null:
			basque.set_tag("对华贸易", true)
		if catalonia != null:
			catalonia.set_tag("对华贸易", true)
		_start_war(31, TXT_ATT31, TXT_DEF31, 500, 500, -1, -1, TXT_WAR31, 999)
		_start_war(32, TXT_ATT32, TXT_DEF31, 500, 500, -1, -1, TXT_WAR32, 999)
		context["result_text"] = TXT_R0
		return
	if opt == 1:
		_add_relation(EmpireData.USA, -150)
		_add_relation(EmpireData.USSR, -150)
		_start_war(31, TXT_ATT31, TXT_DEF31, 300, 700, -1, -1, TXT_WAR31, 999)
		_start_war(32, TXT_ATT32, TXT_DEF31, 300, 700, -1, -1, TXT_WAR32, 999)
		context["result_text"] = TXT_R1
		return
	if opt == 2:
		_add_relation(EmpireData.USA, 150)
		_add_relation(EmpireData.USSR, 150)
		_start_war(31, TXT_ATT31, TXT_DEF31, 300, 700, -1, -1, TXT_WAR31, 999)
		_start_war(32, TXT_ATT32, TXT_DEF31, 300, 700, -1, -1, TXT_WAR32, 999)
		context["result_text"] = TXT_R2
		return
	if opt == 3:
		if ws.wars.size() > 30 and ws.wars[30] != null:
			ws.wars[30].side1 = TXT_R3_SIDE1
			ws.wars[30].infl1 += 150
			ws.wars[30].infl2 -= 150
		_add(W.I_ARMY, -150)
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		context["result_text"] = TXT_R3
		return
	if opt == 4:
		if ws.wars.size() > 30 and ws.wars[30] != null:
			ws.wars[30].side1 = TXT_R4_SIDE1
			ws.wars[30].side2 = TXT_R4_SIDE2
			ws.wars[30].infl1 = 50
			ws.wars[30].infl2 = 950
		_add(W.I_ARMY, -150)
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		context["result_text"] = TXT_R4
		return
	_start_war(31, TXT_ATT31, TXT_DEF31, 300, 700, -1, -1, TXT_WAR31, 999)
	_start_war(32, TXT_ATT32, TXT_DEF31, 300, 700, -1, -1, TXT_WAR32, 999)
	context["result_text"] = TXT_R5
