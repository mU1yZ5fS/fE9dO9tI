extends "res://数据脚本/event_script_base.gd"

## 原作 Event598.cs：卡盖拉是我们的！（乌坦战争，三选项）。
## 触发：ReqEventForDLC02.cs:844-846 —— DATE_AFTER 1978.11.2；fire_only_once 承担 !event_done[598]。
## 差异：SovietSupportAttacker→ussr_side = GameConstants.WarSide.SIDE1；TickTime(15)→fortnight_max=15。

const TXT_OPT0_DIS := "乌干达和坦桑尼亚？极权主义者狗咬狗罢了……"
const TXT_OPT2_DIS := "我说了，我们不可能搞背叛同志这一套"
const TXT_R0 := "作为坦桑尼亚的老朋友，我们自然应当坚定站在坦桑尼亚的一边。我们谴责乌干达的侵略行为，并派出军事顾问协助坦桑尼亚人民国防军。而坦桑尼亚也对军队进行了大幅扩编，还动员了救国阵线、拯救乌干达运动（主要由阿乔利人与特索人组成）与由大卫·奥伊特-奥乔克指挥的奥博特派武装“特种部队”（kikosimaalum）等乌干达反阿明武装团体参与战争。11月2日，坦桑尼亚总统尼雷尔向全国发表讲话，号召全国军民团结一致，保卫国土，进行反击。8日，迫于国际社会的压力，阿明提出有条件撤军：要求坦桑尼亚保证不再入侵乌干达，不支持乌干达的流亡者，遭到尼雷尔总统的拒绝。11月12日，尼雷尔总统宣布发动反攻。利比亚试图调停这场战争，但是在坦桑尼亚驳回调停之后便开始支持乌干达并为乌干达派出空军和装甲部队协助作战。沙特阿拉伯公开支持乌干达。出于担心阿明的倒台会导致巴勒斯坦解放组织被驱逐出乌干达，法塔赫也向该国派出了志愿军。非洲统一组织最初谴责坦桑尼亚，但随即就转向中立，呼吁双方停战。美国虽然公开制裁乌干达，但是部分美国军事承包商和CIA等正在秘密与乌干达合作，苏联、东德和朝鲜则是两头下注，莫桑比克解放阵线派出一个旅协助坦桑尼亚作战，赞比亚、安哥拉人民解放运动、阿尔及利亚和埃塞俄比亚支持坦桑尼亚。"
const TXT_WAR_NAME := "乌坦战争"
const TXT_WAR_SIDE1 := "乌干达"
const TXT_WAR_SIDE2 := "坦桑尼亚"
const TXT_R1 := "作为坦桑尼亚的老朋友，按理来说，我们应当坚定站在坦桑尼亚的一边，然而，既然非洲统一组织与利比亚都谴责坦桑尼亚，那么，还是两头下注更稳妥一点。我们谴责乌干达的侵略行为，但与此同时，我们的特勤人员开始秘密和阿明政权合作，并通过扎伊尔向乌干达秘密提供武器。而坦桑尼亚也对军队进行了大幅扩编，还动员了救国阵线、拯救乌干达运动（主要由阿乔利人与特索人组成）与由大卫·奥伊特-奥乔克指挥的奥博特派武装“特种部队”（kikosimaalum）等乌干达反阿明武装团体参与战争。11月2日，坦桑尼亚总统尼雷尔向全国发表讲话，号召全国军民团结一致，保卫国土，进行反击。8日，迫于国际社会的压力，阿明提出有条件撤军：要求坦桑尼亚保证不再入侵乌干达，不支持乌干达的流亡者，遭到尼雷尔总统的拒绝。11月12日，尼雷尔总统宣布发动反攻。利比亚试图调停这场战争，但是在坦桑尼亚驳回调停之后便开始支持乌干达并为乌干达派出空军和装甲部队协助作战。沙特阿拉伯公开支持乌干达。出于担心阿明的倒台会导致巴勒斯坦解放组织被驱逐出乌干达，法塔赫也向该国派出了志愿军。非洲统一组织最初谴责坦桑尼亚，但随即就转向中立，呼吁双方停战。美国虽然公开制裁乌干达，但是部分美国军事承包商和CIA等正在秘密与乌干达合作，苏联、东德和朝鲜则是两头下注，莫桑比克解放阵线派出一个旅协助坦桑尼亚作战，赞比亚、安哥拉人民解放运动、阿尔及利亚和埃塞俄比亚支持坦桑尼亚。"
const TXT_R2 := "我们选择在战争中持中立立场，不向任何一方提供支持。在一次与该国政府举行的照会上，我们的驻坦桑尼亚大使表示“中方对乌干达的军事行动感到遗憾，我们强烈呼吁坦乌双方以和平稳定大局为重，保持冷静克制，回到以和平方式政治解决轨道，避免采取使紧张局势进一步升级的行动”。尼雷尔不满我们的这种举动，但那又能怎么样？\n当然，这种和稀泥式的调和主义呼吁并不能改变战争现状，毕竟已经快被国内矛盾压垮的阿明可不会轻易放弃这个能延长自己政治寿命的机会，而被入侵的坦桑尼亚更不可能主动跟侵略者握手言和。坦桑尼亚开始对军队进行了大幅扩编，还动员了救国阵线、拯救乌干达运动（主要由阿乔利人与特索人组成）与由大卫·奥伊特-奥乔克指挥的奥博特派武装“特种部队”（kikosimaalum）等乌干达反阿明武装团体参与战争。11月2日，坦桑尼亚总统尼雷尔向全国发表讲话，号召全国军民团结一致，保卫国土，进行反击。8日，迫于国际社会的压力，阿明提出有条件撤军：要求坦桑尼亚保证不再入侵乌干达，不支持乌干达的流亡者，遭到尼雷尔总统的拒绝。11月12日，尼雷尔总统宣布发动反攻。利比亚试图调停这场战争，但是在坦桑尼亚驳回调停之后便开始支持乌干达并为乌干达派出空军和装甲部队协助作战。沙特阿拉伯公开支持乌干达。出于担心阿明的倒台会导致巴勒斯坦解放组织被驱逐出乌干达，法塔赫也向该国派出了志愿军。非洲统一组织最初谴责坦桑尼亚，但随即就转向中立，呼吁双方停战。美国虽然公开制裁乌干达，但是部分美国军事承包商和CIA等正在秘密与乌干达合作，苏联、东德和朝鲜则是两头下注，莫桑比克解放阵线派出一个旅协助坦桑尼亚作战，赞比亚、安哥拉人民解放运动、阿尔及利亚和埃塞俄比亚支持坦桑尼亚。"


func prepare(event_def: EventDef, world: WorldState) -> void:

	if event_def == null or world == null or event_def.options.size() < 3:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var line := d.political_line if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line < 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)
	if line > 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)



func execute(context: Dictionary) -> void:

	if not _bind_world():
		return
	var tanzania := _country(122)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_start_war(53, TXT_WAR_NAME, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 400, 600, -1, 0, 15)
			if tanzania != null:
				_set_part(tanzania, 0, true)
			_add(W.I_ARMY, -80)
		1:
			context["result_text"] = TXT_R1
			_start_war(53, TXT_WAR_NAME, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 450, 550, -1, 0, 15)
			if tanzania != null:
				_set_part(tanzania, 0, true)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USSR, 100)
		2:
			context["result_text"] = TXT_R2
			_start_war(53, TXT_WAR_NAME, TXT_WAR_SIDE1, TXT_WAR_SIDE2, 550, 450, -1, 0, 15)
			if tanzania != null:
				_set_part(tanzania, 0, true)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
			_add_relation(EmpireData.USA, 50)
			_add(W.I_DIPLO, -50)






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
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	var war := _get_war(war_id)
	if war != null:
		war.name_war = war_name
		war.fortnight_max = tick_time

func _free_puppets(overlord: int) -> void:
	if ws == null:
		return
	for c in ws.countries:
		if c != null and c.puppet_of == overlord:
			c.puppet_of = GameConstants.LegacySlot.NONE


