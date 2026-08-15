extends "res://数据脚本/event_script_base.gd"

## 原作 Event427.cs：西班牙的政变？（四选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1394-1396 —— DATE_AFTER + resultOfEvents[425]==1 + event_done[425]。
## 差异：Gosstroy→government；SubGosstroy→sub_government；spec→special。

const TXT_TITLE := "西班牙的政变？"
const TXT_DESC := "苏亚雷斯政府的声望在过去数年间颓势尽显。社会经济领域内仍有不少问题亟待解决，而各政治力量在1977至1978年就建立民主体制所达成的共识，也很快让位于普遍的不信任。\n在这一背景下，有人产生了为西班牙寻找一位“民族自己的戴高乐”的想法，他们呼唤一位超越党派纷争的军政强人领导该国走出危机。而在包括国王在内的不少人看来，阿方索·阿曼达便是新戴高乐的合适候选。\n在苏亚雷斯于1981年辞职，而议会拒绝提名其候选人利奥波德·卡尔沃·索特洛的情况下。西班牙越加向法国的剧本看齐。\n而对民主统治不满的军方则正准备发动一场旨在夺权的抗议。其中，阿曼达便与军方内更右翼的立场就此问题进行协商：其中便包括因组织“银河行动”而被逮捕，但又被释放的军警头子特赫罗，以及瓦伦西亚一地的指挥官詹姆·米兰斯。\n然而，三位军官甚至在没有意识到各自观点不同的情况下，便建立了三头同盟：其中，阿曼达认为民主转型大潮是历史所趋，并允许国内所有的政治力量参与政府构建，为此甚至可以允许左派；特赫罗则支持复兴已经被政客、军方、甚至是国王自己抛弃的传统军事独裁制与正统长枪党主义；米兰斯则是亲君主派的代表，坚信苏亚雷斯与民主派正篡夺君主的权力，因此有必要建立真正的君主专制体制。\n不过，政变的结果依然不明朗，但我们可以尽力协助某位密谋者的行动，把他推上西班牙新任“考迪罗”的权力之巅......"
const TXT_OPT0_EN := "支持特赫罗（需要10.0百万{0}与25.0点{1}）"
const TXT_OPT1_EN := "支持米兰斯（需要10.0百万{0}与25.0点{1}）"
const TXT_OPT2_EN := "支持阿曼达（需要10.0百万{0}与25.0点{1}）"
const TXT_OPT3 := "我们不干涉"
const TXT_R0 := "对卡尔沃·索特洛的第二轮投票将在马德里时间18时举行。也就在18时22分，一群由特赫罗中将率领的国民卫队宪兵闯入国会会议室。特赫罗手持武器，并要求在场人员：“全都给我安静！全都给我趴在地上！”除了卡里略、苏亚雷斯与马纳多将军外的人都照做了。\n于此同时，米兰斯将坦克开上瓦伦西亚街道，并宣布国家进入紧急状态。坦克对准了瓦伦西亚的政府大楼。\n原应在得到国王批示，胜利返回议会并接任首相的阿曼达那却出了问题。国王与他的随从开始阻止阿曼达进入国会宫。当他出现在国会宫后，阿曼达便与特赫罗就未来政府的组织形式发生了冲突。特赫罗要求他的随从们逮捕阿曼达，并向议会代表宣布解散议会，所有权力均收归西班牙军政府。就在此时，米兰斯向马德里地区的部队下达了攻入皇宫的命令。国王被要求签署一份罪己诏并立即离开该国。\n由于军队训练有素，首都很快便被军方拿下，并引入了国家紧急状态。左翼政党与民主党派的代表们在被驱逐出国会宫后立即被捕。特赫罗则在军政府会议上，提议将已经被废黜的胡安国王之父给推上西班牙王座。就像佛朗哥推选胡安·卡洛斯那样。佛朗哥主义的胜利已经到来，而西班牙也将等待数年的稳定......"
const TXT_R1 := "对卡尔沃·索特洛的第二轮投票将在马德里时间18时举行。也就在18时22分，一群由特赫罗中将率领的国民卫队宪兵闯入国会会议室。特赫罗手持武器，并要求在场人员：“全都给我安静！全都给我趴在地上！”除了卡里略、苏亚雷斯与马纳多将军外的人都照做了。\n于此同时，米兰斯将坦克开上瓦伦西亚街道，并宣布国家进入紧急状态。坦克对准了瓦伦西亚的政府大楼。\n原应在得到国王批示，胜利返回议会并接任首相的阿曼达那却出了问题。国王与他的随从开始阻止阿曼达进入国会宫。当他出现在国会宫后，阿曼达便与特赫罗就未来政府的组织形式发生了冲突。\n而米兰斯则以为政变被二人有意拖延。于是他联系了自己在马德里的同事，并宣布阿曼达与特赫罗已经“背叛国王并意图与议会议员妥协。甚至试图以复辟共和制度为要价，交换自己的代表入阁”。作为政变合伙人的米兰斯，迅速对其发起了一场反政变，从而将自己的前盟友纷纷踢出游戏。国王指示米兰斯抓捕政变参与者，这就是一切的终局。议会也在不久后被军方解放。米兰斯则向议员们宣布：“介于目前的政治局势，全国必须紧密团结在法律与秩序的捍卫者——国王陛下一边。”在军方的压力下，议会任命米兰斯为西班牙首相。"
const TXT_R2 := "对卡尔沃·索特洛的第二轮投票将在马德里时间18时举行。也就在18时22分，一群由特赫罗中将率领的国民卫队宪兵闯入国会会议室。特赫罗手持武器，并要求在场人员：“全都给我安静！全都给我趴在地上！”除了卡里略、苏亚雷斯与马纳多将军外的人都照做了。\n于此同时，米兰斯将坦克开上瓦伦西亚街道，并宣布国家进入紧急状态。坦克对准了瓦伦西亚的政府大楼。\n原应在得到国王批示，胜利返回议会并接任首相的阿曼达那却出了问题。国王与他的随从开始阻止阿曼达进入国会宫。当他出现在国会宫后，阿曼达便与特赫罗就未来政府的组织形式发生了冲突。阿曼达要求他的随从们逮捕特赫罗，并向议员们表示：“反民主政变已被自己扑灭”。代表们纷纷向他们的解放者致以掌声，以绝对多数任命阿曼达为西班牙首相。从而让阿曼达领导该国政府，“西班牙版戴高乐”的剧本就这样落幕了。"
const TXT_R3 := "对卡尔沃·索特洛的第二轮投票将在马德里时间18时举行。也就在18时22分，一群由特赫罗中将率领的国民卫队宪兵闯入国会会议室。特赫罗手持武器，并要求在场人员：“全都给我安静！全都给我趴在地上！”除了卡里略、苏亚雷斯与马纳多将军外的人都照做了。\n于此同时，米兰斯将坦克开上瓦伦西亚街道，并宣布国家进入紧急状态。坦克对准了瓦伦西亚的政府大楼。\n原应在得到国王批示，胜利返回议会并接任首相的阿曼达那却出了问题。国王与他的随从开始阻止阿曼达进入国会宫。当他出现在国会宫后，阿曼达便与特赫罗就未来政府的组织形式发生了冲突。\n政变在一开始便成为了一场灾难，并近乎走向失败。在午夜时分，穿着一身军装的国王在电视机前声明反对政变，并要求政变者缴械投降。\n旨在使恢复君主专制的政变就此失败，其主要参与者纷纷被捕。次日，数千人在该国首都举行了支持民主制的集会。议会同意任命卡尔沃·索特洛为首相。"
const TXT_IDX_1421 := "西班牙的政变？"
const TXT_IDX_1422 := "苏亚雷斯政府的声望在过去数年间颓势尽显。社会经济领域内仍有不少问题亟待解决，而各政治力量在1977至1978年就建立民主体制所达成的共识，也很快让位于普遍的不信任。\n在这一背景下，有人产生了为西班牙寻找一位“民族自己的戴高乐”的想法，他们呼唤一位超越党派纷争的军政强人领导该国走出危机。而在包括国王在内的不少人看来，阿方索·阿曼达便是新戴高乐的合适候选。\n在苏亚雷斯于1981年辞职，而议会拒绝提名其候选人利奥波德·卡尔沃·索特洛的情况下。西班牙越加向法国的剧本看齐。\n而对民主统治不满的军方则正准备发动一场旨在夺权的抗议。其中，阿曼达便与军方内更右翼的立场就此问题进行协商：其中便包括因组织“银河行动”而被逮捕，但又被释放的军警头子特赫罗，以及瓦伦西亚一地的指挥官詹姆·米兰斯。\n然而，三位军官甚至在没有意识到各自观点不同的情况下，便建立了三头同盟：其中，阿曼达认为民主转型大潮是历史所趋，并允许国内所有的政治力量参与政府构建，为此甚至可以允许左派；特赫罗则支持复兴已经被政客、军方、甚至是国王自己抛弃的传统军事独裁制与正统长枪党主义；米兰斯则是亲君主派的代表，坚信苏亚雷斯与民主派正篡夺君主的权力，因此有必要建立真正的君主专制体制。\n不过，政变的结果依然不明朗，但我们可以尽力协助某位密谋者的行动，把他推上西班牙新任“考迪罗”的权力之巅......"
const TXT_IDX_1423 := "支持特赫罗（需要10.0百万{0}与25.0点{1}）"
const TXT_IDX_1424 := "支持米兰斯（需要10.0百万{0}与25.0点{1}）"
const TXT_IDX_1425 := "支持阿曼达（需要10.0百万{0}与25.0点{1}）"
const TXT_IDX_1426 := "我们不干涉"
const TXT_IDX_1427 := "对卡尔沃·索特洛的第二轮投票将在马德里时间18时举行。也就在18时22分，一群由特赫罗中将率领的国民卫队宪兵闯入国会会议室。特赫罗手持武器，并要求在场人员：“全都给我安静！全都给我趴在地上！”除了卡里略、苏亚雷斯与马纳多将军外的人都照做了。\n于此同时，米兰斯将坦克开上瓦伦西亚街道，并宣布国家进入紧急状态。坦克对准了瓦伦西亚的政府大楼。\n原应在得到国王批示，胜利返回议会并接任首相的阿曼达那却出了问题。国王与他的随从开始阻止阿曼达进入国会宫。当他出现在国会宫后，阿曼达便与特赫罗就未来政府的组织形式发生了冲突。特赫罗要求他的随从们逮捕阿曼达，并向议会代表宣布解散议会，所有权力均收归西班牙军政府。就在此时，米兰斯向马德里地区的部队下达了攻入皇宫的命令。国王被要求签署一份罪己诏并立即离开该国。\n由于军队训练有素，首都很快便被军方拿下，并引入了国家紧急状态。左翼政党与民主党派的代表们在被驱逐出国会宫后立即被捕。特赫罗则在军政府会议上，提议将已经被废黜的胡安国王之父给推上西班牙王座。就像佛朗哥推选胡安·卡洛斯那样。佛朗哥主义的胜利已经到来，而西班牙也将等待数年的稳定......"
const TXT_IDX_1428 := "对卡尔沃·索特洛的第二轮投票将在马德里时间18时举行。也就在18时22分，一群由特赫罗中将率领的国民卫队宪兵闯入国会会议室。特赫罗手持武器，并要求在场人员：“全都给我安静！全都给我趴在地上！”除了卡里略、苏亚雷斯与马纳多将军外的人都照做了。\n于此同时，米兰斯将坦克开上瓦伦西亚街道，并宣布国家进入紧急状态。坦克对准了瓦伦西亚的政府大楼。\n原应在得到国王批示，胜利返回议会并接任首相的阿曼达那却出了问题。国王与他的随从开始阻止阿曼达进入国会宫。当他出现在国会宫后，阿曼达便与特赫罗就未来政府的组织形式发生了冲突。\n而米兰斯则以为政变被二人有意拖延。于是他联系了自己在马德里的同事，并宣布阿曼达与特赫罗已经“背叛国王并意图与议会议员妥协。甚至试图以复辟共和制度为要价，交换自己的代表入阁”。作为政变合伙人的米兰斯，迅速对其发起了一场反政变，从而将自己的前盟友纷纷踢出游戏。国王指示米兰斯抓捕政变参与者，这就是一切的终局。议会也在不久后被军方解放。米兰斯则向议员们宣布：“介于目前的政治局势，全国必须紧密团结在法律与秩序的捍卫者——国王陛下一边。”在军方的压力下，议会任命米兰斯为西班牙首相。"
const TXT_IDX_1429 := "对卡尔沃·索特洛的第二轮投票将在马德里时间18时举行。也就在18时22分，一群由特赫罗中将率领的国民卫队宪兵闯入国会会议室。特赫罗手持武器，并要求在场人员：“全都给我安静！全都给我趴在地上！”除了卡里略、苏亚雷斯与马纳多将军外的人都照做了。\n于此同时，米兰斯将坦克开上瓦伦西亚街道，并宣布国家进入紧急状态。坦克对准了瓦伦西亚的政府大楼。\n原应在得到国王批示，胜利返回议会并接任首相的阿曼达那却出了问题。国王与他的随从开始阻止阿曼达进入国会宫。当他出现在国会宫后，阿曼达便与特赫罗就未来政府的组织形式发生了冲突。阿曼达要求他的随从们逮捕特赫罗，并向议员们表示：“反民主政变已被自己扑灭”。代表们纷纷向他们的解放者致以掌声，以绝对多数任命阿曼达为西班牙首相。从而让阿曼达领导该国政府，“西班牙版戴高乐”的剧本就这样落幕了。"
const TXT_IDX_1430 := "对卡尔沃·索特洛的第二轮投票将在马德里时间18时举行。也就在18时22分，一群由特赫罗中将率领的国民卫队宪兵闯入国会会议室。特赫罗手持武器，并要求在场人员：“全都给我安静！全都给我趴在地上！”除了卡里略、苏亚雷斯与马纳多将军外的人都照做了。\n于此同时，米兰斯将坦克开上瓦伦西亚街道，并宣布国家进入紧急状态。坦克对准了瓦伦西亚的政府大楼。\n原应在得到国王批示，胜利返回议会并接任首相的阿曼达那却出了问题。国王与他的随从开始阻止阿曼达进入国会宫。当他出现在国会宫后，阿曼达便与特赫罗就未来政府的组织形式发生了冲突。\n政变在一开始便成为了一场灾难，并近乎走向失败。在午夜时分，穿着一身军装的国王在电视机前声明反对政变，并要求政变者缴械投降。\n旨在使恢复君主专制的政变就此失败，其主要参与者纷纷被捕。次日，数千人在该国首都举行了支持民主制的集会。议会同意任命卡尔沃·索特洛为首相。"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_567 := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_IDX_776 := "军事实力必须高于{0}点......"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"

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
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var d := world.数值表
	var budget_reserve := d[W.I_BUDGET] + (d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0)
	var agents := d[W.I_AGENTS] if d.size() > W.I_AGENTS else 0
	if budget_reserve >= 100 and agents >= 250:
		_enable(event_def.options[0], _fmt(TXT_OPT0_EN, [TXT_IDX_592, TXT_IDX_593]))
		_enable(event_def.options[1], _fmt(TXT_OPT1_EN, [TXT_IDX_592, TXT_IDX_593]))
		_enable(event_def.options[2], _fmt(TXT_OPT2_EN, [TXT_IDX_592, TXT_IDX_593]))
	elif budget_reserve < 100:
		_disable(event_def.options[0], _fmt(TXT_IDX_566, [10]))
		_disable(event_def.options[1], _fmt(TXT_IDX_566, [10]))
		_disable(event_def.options[2], _fmt(TXT_IDX_566, [10]))
	else:
		_disable(event_def.options[0], _fmt(TXT_IDX_567, [25]))
		_disable(event_def.options[1], _fmt(TXT_IDX_567, [25]))
		_disable(event_def.options[2], _fmt(TXT_IDX_567, [25]))
	_enable(event_def.options[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var spain := ws.get_country_by_legacy_index(86)
	var portugal := ws.get_country_by_legacy_index(87)
	if opt == 0:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		if spain != null:
			spain.government = 0
			spain.sub_government = 9
		if portugal != null:
			portugal.special -= 5
		context["result_text"] = TXT_R0
		return
	if opt == 1:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		if spain != null:
			spain.government = 0
			spain.sub_government = 7
		if portugal != null:
			portugal.special -= 5
		context["result_text"] = TXT_R1
		return
	if opt == 2:
		_add(W.I_BUDGET, -100)
		_add(W.I_AGENTS, -250)
		if spain != null:
			spain.government = 2
			spain.sub_government = 15
		if portugal != null:
			portugal.special -= 5
		context["result_text"] = TXT_R2
		return
	if portugal != null:
		portugal.special += 5
	context["result_text"] = TXT_R3
