extends "res://数据脚本/event_script_base.gd"

## 原作 Event598.cs：卡盖拉是我们的！（乌坦战争，三选项）。
## 触发：ReqEventForDLC02.cs:844-846 —— DATE_AFTER 1978.11.2；fire_only_once 承担 !event_done[598]。
## 差异：SovietSupportAttacker→ussr_side=0；TickTime(15)→fortnight_max=15。

const TXT_TITLE := "卡盖拉是我们的！"
const TXT_DESC := "乌干达——非洲的明珠，是个美丽的国家，在这片美丽的土地上，生活着同样美丽的人民。但是，自独立以来，没有哪个国家像它一样，如此愧对自己美丽的国土和美丽的人民。1971年，亲坦桑尼亚的乌干达总统米尔顿·奥博特被伊迪·阿明少将发动政变赶下了台。阿明的统治无疑是混乱的。尽管由于他在政变之初宣布的恢复自由选举、释放政治犯、将布干达国王穆特萨二世的遗体运回乌干达安葬等举措使这场政变在最初赢得了广泛欢迎，但仅仅不到一个月的时间，这张假面便被撕了个稀碎。刚逃出狼穴的乌干达就这样又踏入了虎窝之中。伴随着阿明的登台而来的，是对作为前政府的部族根基的兰戈人与阿乔利人的清洗，对卡夸人（阿明的部族）等西尼罗河同乡与外国人（主要是苏丹人与刚果人）的大力提拔，和对反对派的屠杀。东非共同体也在该国与其他成员的冲突下而解散。1972年驱逐4万印度人并将他们的财产分配给自己部下的行动更是摧毁了乌干达的商业支柱，各行各业的生产都陷入萎缩，生活必需品普遍短缺。|在这样的高压统治下，乌干达人民的反抗当然不可能少。1971年，年轻的马克思主义者约韦里·穆塞韦尼流亡坦桑尼亚后在莫解阵支持下成立了救国阵线，并在乌干达国内数个地点建立了游击根据地，其他各路反阿明武装也在坦桑尼亚的支持下整装待发。1972年9月，奥博特的“人民军”从坦桑尼亚对乌干达发起了“闹剧”般的进攻，在未攻占任何一个据点的情况下便折损了三分之一的成员。而坦桑尼亚对行动的支持致使乌干达轰炸了姆万扎与布科巴地区，双方一度剑拔弩张。最后，在西亚德·巴雷的斡旋下，两国签署《摩加迪沙协定》结束了冲突，坦桑尼亚也被迫承认阿明政府的合法性，中断了对“颠覆活动”的支持。|八年时间一晃而过，阿明的统治成功使乌干达沦为战争、国家煽动的暴力、饥荒、军事独裁、经济衰退、货币贬值、侵犯人权、践踏宪法和普遍绝望——这所有一切的代名词的新殖民主义统治下的非洲普遍危机中最典型、也是最引人注目的地区之一。为了转移愈来愈烈的国内矛盾，内外交困的阿明政府只得将矛头再次对准转坦桑尼亚。在边境制造了数场摩擦后，1978年10月，乌干达以“自卫反击”为借口向坦桑尼亚发动入侵，宣布吞并卡盖拉地区，并在当地进行了大屠杀。作为回应，11月2日，坦桑尼亚对乌干达宣战。|值得注意的是，非洲统一组织也跟随乌干达谴责坦桑尼亚挑起了这场冲突。作为坦桑尼亚的坚定盟友，无论于情于理我们都应该帮助该国解决掉这个麻烦，但是，或许我们也该不那么死脑筋，听听非洲统一组织的意见，在这场战争中押宝于乌干达，来个两头下注？"
const TXT_OPT0 := "我们可不会搞背叛同志这一套，当然得支持坦桑尼亚"
const TXT_OPT0_DIS := "乌干达和坦桑尼亚？极权主义者狗咬狗罢了……"
const TXT_OPT1 := "听取非统组织观点，秘密支持阿明教育一下尼雷尔"
const TXT_OPT2 := "在战争中作壁上观，呼吁双方保持冷静"
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
	var d := world.数值表
	var line := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 3
	var opt := event_def.options
	if line < 4:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)
	if line > 2:
		_enable(opt[2], TXT_OPT2)
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



func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta

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

