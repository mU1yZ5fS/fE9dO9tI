extends "res://数据脚本/event_script_base.gd"

## 原作 Event424.cs：银河行动（二选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1379-1381 —— DATE_AFTER。
## 差异：based→有驻军基地；TickTime 缺省 999→fortnight_max=999；
##  - AttackerInfluence(300).DefenderInfluence(700)→infl1=300,infl2=700。

const TXT_DESC_BASE := "在军队、民警，乃至情报部门的大多数营房内；在军官的总部、俱乐部，乃至军事学校内。佛朗哥的肖像依然随处可见，最近则又在旁边加上了国王的肖像。然而，这些地方并没有见到首相苏亚雷斯的相关形象。毕竟，军队认为他是将西班牙共产党合法化，试图为分离主义地区赋予自治权，并企图削弱国王权力的叛徒。因此，军方感觉自己芒刺在背。\n根据我国情报部门的消息，一群军官已在银河咖啡馆密谋组织军事政变。他们准备在长枪党人齐聚马德里，纪念佛朗哥之死的11月中旬起事。其目标是孤立苏亚雷斯，并建立依托于国王的新政府。但他们真的能让西班牙从民主之路上拉回去吗？还是说改革已经一改到底，无法回头？依然很难回答这一问题.....\n{1}\n{2}"
const TXT_OPT0_EN := "帮助分离主义者消灭国王，为局势火上浇油（需要10.0百万{0}与15.0点{1}）"
const TXT_OPT0_NO_CONTACT := "我们还没有与分离主义者建立联系....."
const TXT_R0 := "马德里机场的突发事件！西班牙王室的飞机在准备助跑起飞时，被一枚制导导弹所击毁。西班牙公众被这一事件所震惊，他们不敢相信民主化与自由化的象征最终竟成为恐怖分子的牺牲品。“埃塔”的成员宣布对此次事件负责，并声称国王之死不过是为“西班牙对少数民族实行数百年暴政”的赎罪罢了。\n对于军方来说，这一事件则彻底触怒了他们的底线。他们可以容忍对共产党与社会党的合法化，可以容忍对天主教的攻势，但绝不能在国王问题上妥协。毕竟国王是佛朗哥统领亲自任命的接班人。于是，他们采纳了西班牙军事政变的优良传统，迅速在数个省份发起了对苏亚雷斯民主政府的叛乱。在过去数年反对民主政体的佛朗哥主义组织“堡垒”则成为了叛乱的主力军，并为之贡献了大量支持者。他们在安东尼奥·特赫罗、布拉斯·皮纳尔与詹姆·米兰斯·德·博施的指挥下，在萨拉戈萨建立了所谓“国民政府”。\n苏亚雷斯首相仍是一位积极的长枪党宣传家。因此他动用了自己的老本行，将此次事件称之为“反民主极右翼叛乱”，并呼吁所有的主要民主政党保卫他们赢得的自由。在前者的邀请下，囊括了工人社会党与共产党的“民族团结政府”诞生了。然而此时，只有一小部分军队加入了民主政府。因此，苏亚雷斯不得不呼吁其控制区内的城市完全动员起来，以对抗叛军行动。\n超级大国则坚守代表雅尔塔-波兹坦精神的《赫尔辛基协定》，坚称“西班牙的事情不过是西班牙的内政而已”。然而，每个国家显然都会根据自己的同情为某方加分。"
const TXT_R1 := "苏亚雷斯首相得知了有关政变阴谋的相关消息。然而，他决定收敛锋芒，避免进一步触怒军方。在由200人构成的阴谋集团中，只有2位军官因蓄谋政变被捕。其中一位是因发表激进反民主言论而闻名的国民卫队中将特赫罗。\n民主阵营依然在长枪党可能对自己做出反应的背景下得到了稳固。"
const TXT_WAR_NAME := "第二次西班牙内战"
const TXT_WAR_ATT := "共和政府"
const TXT_WAR_DEF := "长枪党"
const TXT_BASED_1 := "以及，多亏了我们与巴斯克和加泰罗尼亚分离主义分子的联系，我们得知左翼民族主义团体（巴斯克的“埃塔”组织与加泰罗尼亚的“自由之地”）正策划一场惊天刺杀——这次，他们打算消灭西班牙国王！分离主义者想要趁胡安·卡洛斯前往墨西哥时，将他的专机击落。"
const TXT_BASED_2 := "如果这两件事都成功了，西班牙会发生什么呢？"
const TXT_IDX_1376 := "银河行动"
const TXT_IDX_1377 := "在军队、民警，乃至情报部门的大多数营房内；在军官的总部、俱乐部，乃至军事学校内。佛朗哥的肖像依然随处可见，最近则又在旁边加上了国王的肖像。然而，这些地方并没有见到首相苏亚雷斯的相关形象。毕竟，军队认为他是将西班牙共产党合法化，试图为分离主义地区赋予自治权，并企图削弱国王权力的叛徒。因此，军方感觉自己芒刺在背。\n根据我国情报部门的消息，一群军官已在银河咖啡馆密谋组织军事政变。他们准备在长枪党人齐聚马德里，纪念佛朗哥之死的11月中旬起事。其目标是孤立苏亚雷斯，并建立依托于国王的新政府。但他们真的能让西班牙从民主之路上拉回去吗？还是说改革已经一改到底，无法回头？依然很难回答这一问题.....\n{1}\n{2}"
const TXT_IDX_1378 := "帮助分离主义者消灭国王，为局势火上浇油（需要10.0百万{0}与15.0点{1}）"
const TXT_IDX_1379 := "我们还没有与分离主义者建立联系....."
const TXT_IDX_1380 := "观察局势"
const TXT_IDX_1381 := "马德里机场的突发事件！西班牙王室的飞机在准备助跑起飞时，被一枚制导导弹所击毁。西班牙公众被这一事件所震惊，他们不敢相信民主化与自由化的象征最终竟成为恐怖分子的牺牲品。“埃塔”的成员宣布对此次事件负责，并声称国王之死不过是为“西班牙对少数民族实行数百年暴政”的赎罪罢了。\n对于军方来说，这一事件则彻底触怒了他们的底线。他们可以容忍对共产党与社会党的合法化，可以容忍对天主教的攻势，但绝不能在国王问题上妥协。毕竟国王是佛朗哥统领亲自任命的接班人。于是，他们采纳了西班牙军事政变的优良传统，迅速在数个省份发起了对苏亚雷斯民主政府的叛乱。在过去数年反对民主政体的佛朗哥主义组织“堡垒”则成为了叛乱的主力军，并为之贡献了大量支持者。他们在安东尼奥·特赫罗、布拉斯·皮纳尔与詹姆·米兰斯·德·博施的指挥下，在萨拉戈萨建立了所谓“国民政府”。\n苏亚雷斯首相仍是一位积极的长枪党宣传家。因此他动用了自己的老本行，将此次事件称之为“反民主极右翼叛乱”，并呼吁所有的主要民主政党保卫他们赢得的自由。在前者的邀请下，囊括了工人社会党与共产党的“民族团结政府”诞生了。然而此时，只有一小部分军队加入了民主政府。因此，苏亚雷斯不得不呼吁其控制区内的城市完全动员起来，以对抗叛军行动。\n超级大国则坚守代表雅尔塔-波兹坦精神的《赫尔辛基协定》，坚称“西班牙的事情不过是西班牙的内政而已”。然而，每个国家显然都会根据自己的同情为某方加分。"
const TXT_IDX_1382 := "第二次西班牙内战"
const TXT_IDX_1383 := "共和政府"
const TXT_IDX_1384 := "长枪党"
const TXT_IDX_1385 := "苏亚雷斯首相得知了有关政变阴谋的相关消息。然而，他决定收敛锋芒，避免进一步触怒军方。在由200人构成的阴谋集团中，只有2位军官因蓄谋政变被捕。其中一位是因发表激进反民主言论而闻名的国民卫队中将特赫罗。\n民主阵营依然在长枪党可能对自己做出反应的背景下得到了稳固。"
const TXT_IDX_1386 := "以及，多亏了我们与巴斯克和加泰罗尼亚分离主义分子的联系，我们得知左翼民族主义团体（巴斯克的“埃塔”组织与加泰罗尼亚的“自由之地”）正策划一场惊天刺杀——这次，他们打算消灭西班牙国王！分离主义者想要趁胡安·卡洛斯前往墨西哥时，将他的专机击落。"
const TXT_IDX_1387 := "如果这两件事都成功了，西班牙会发生什么呢？"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_776 := "军事实力必须高于{0}点......"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"



func _raw(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0






func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s





func _start_war(war_id: int, side1: String, side2: String, infl1: int, infl2: int,
		usa_side: int, ussr_side: int, war_name: String, fortnight: int) -> void:
	game.start_war(war_id, side1, side2, infl1, infl2, usa_side, ussr_side)
	if ws.wars.size() > war_id and ws.wars[war_id] != null:
		ws.wars[war_id].name_war = war_name
		ws.wars[war_id].fortnight_max = fortnight

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	@warning_ignore("shadowed_variable_base_class")
	var d := world
	var spain := world.get_country_by_legacy_index(86)
	var budget_reserve := d.budget + (d.reserve if d.size() > W.I_RESERVE else 0)
	var agents := d.agents if d.size() > W.I_AGENTS else 0
	var based := spain != null and spain.有驻军基地
	if based:
		event_def.description = TXT_DESC_BASE.replace("{1}", TXT_BASED_1).replace("{2}", TXT_BASED_2)
	else:
		event_def.description = TXT_DESC_BASE.replace("{1}", "").replace("{2}", "")
	if budget_reserve >= 100 and agents >= 150 and based:
		_enable(event_def.options[0], _fmt(TXT_OPT0_EN, [TXT_IDX_592, TXT_IDX_593]))
	elif not based:
		_disable(event_def.options[0], TXT_OPT0_NO_CONTACT)
	elif budget_reserve < 100:
		_disable(event_def.options[0], _fmt(TXT_IDX_566, [10]))
	else:
		_disable(event_def.options[0], _fmt(TXT_IDX_567, [15]))
	_enable(event_def.options[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var _spain := ws.get_country_by_legacy_index(86)
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -150)
		_start_war(30, TXT_WAR_ATT, TXT_WAR_DEF, 300, 700, -1, -1, TXT_WAR_NAME, 999)
		var portugal := ws.get_country_by_legacy_index(87)
		if portugal != null:
			portugal.special -= 10
		context["result_text"] = TXT_R0
		return
	context["result_text"] = TXT_R1
