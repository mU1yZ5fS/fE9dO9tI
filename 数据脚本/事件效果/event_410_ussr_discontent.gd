extends "res://数据脚本/event_script_base.gd"

## 原作 Event410.cs：苏联对我国内政不满（六选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1296 —— 复杂条件用 evaluate（IsAuthoritarianism 无 ExprNode）。
## 差异：politic.traits[0]→trait_personality；data[139/140] raw index。

const TXT_TITLE := [
	"苏联对我国内政不满",
]

const TXT_DESC := [
	"这天，《真理报》发表了题为《{1}》的社论，并借此批判中国内政。该文并没有点名批评我国领导人，但特别提及了我国国内存在“反社会主义势力反攻倒算”，“群众不信任群众的党”等现象。苏联官方报纸上的这些言论可被看作是一个信号：显然，苏联领导人要求我们调转航向。否则，就得做好应对一切手段的准备。可我们对此该怎么做呢？",
]

const TXT_OPT0 := [
	"我们已经无路可退！",
]

const TXT_OPT1 := [
	"军事实力必须高于{0}点......",
]

const TXT_OPT2 := [
	"",
]

const TXT_OPT3 := [
	"巧妇难为无米之炊，我们手头得有{0}百万才能干活......",
]

const TXT_OPT4 := [
	"中国的国际影响力应高于{0}......",
]

const TXT_R := [
	"对此，苏联驻我国大使热烈祝贺我们回归了“马克思列宁主义正道”，并成功战胜了“党内试图发动政变，实现资本主义复辟的走资派”。",
	"我们决定绕开莫斯科，在中苏边界举行单方面军事演习。这让苏联政治局大惊失色，他们媒体对中华人民共和国的污蔑也就此打住。但安稳日子将持续多久呢？",
	"今天，我国官方报纸《人民日报》发表了题为《走有中国特色的社会主义道路》一文，该文称：早在三国时期，中国便已经有了自己的马克思与社会主义理论。文章以这样一段话总结全文：“今天的中国特色社会主义可谓是我国民族传统、人民智慧与马克思主义理论的完美结合。中国不能不走这样的社会主义道路！”尽管这篇文章在党内引起了巨大争议，但莫斯科还是停止了对中华人民共和国的污蔑。但安稳日子将持续多久呢？",
	"我们对世界共产主义运动的资助成功堵住了莫斯科的嘴，他们媒体对中华人民共和国的污蔑也就此打住。",
	"苏联赞许我们的和平姿态，但我们为此牺牲了些许国际影响力。",
	"我国在莫斯科发展的下线送来最新消息：如果中国方面仍不思悔改，苏联将准备与中国断交。",
]

const TXT_R_APPEND := []

func _fmt(s: String, args: Array) -> String:
	for i in args.size():
		s = s.replace("{" + str(i) + ":F1}", str(args[i]))
		s = s.replace("{" + str(i) + "}", str(args[i]))
	return s

const TXT_IDX_1244 := "苏联对我国内政不满"
const TXT_IDX_1246 := "有中国特色的新资本主义"
const TXT_IDX_1247 := "现实还是神话？——论中国的资本主义复辟"
const TXT_IDX_1245 := "这天，《真理报》发表了题为《{1}》的社论，并借此批判中国内政。该文并没有点名批评我国领导人，但特别提及了我国国内存在“反社会主义势力反攻倒算”，“群众不信任群众的党”等现象。苏联官方报纸上的这些言论可被看作是一个信号：显然，苏联领导人要求我们调转航向。否则，就得做好应对一切手段的准备。可我们对此该怎么做呢？"
const TXT_IDX_1249 := "实施社会主义改革"
const TXT_IDX_592 := "预算"
const TXT_IDX_593 := "特工网络"
const TXT_IDX_594 := "军事实力"
const TXT_IDX_1214 := "中国国际影响力"
const TXT_IDX_1250 := "对苏修势力施压（{2}：-35.0；苏联影响力：-3.0；与苏联的关系：-15.0）"
const TXT_IDX_776 := "军事实力必须高于{0}点......"
const TXT_IDX_1251 := "将我们的资本主义装裱为社会主义（与苏联的关系：-30.0；党内团结：-45.0）"
const TXT_IDX_1252 := "贿赂莫斯科，并对世界各地共产党提供财政支持（{0}：-15.0；美国影响力：-2.0；苏联影响力：+2.0；与苏联的关系：+10.0）"
const TXT_IDX_566 := "巧妇难为无米之炊，我们手头得有{0}百万才能干活......"
const TXT_IDX_1253 := "做出友好合作姿态（中国影响力：-5.0；苏联影响力：+5.0；与苏联的关系：+10.0）"
const TXT_IDX_620 := "中国的国际影响力应高于{0}......"
const TXT_IDX_1254 := "他们拿我们没办法的！"
const TXT_IDX_1255 := "对此，苏联驻我国大使热烈祝贺我们回归了“马克思列宁主义正道”，并成功战胜了“党内试图发动政变，实现资本主义复辟的走资派”。"
const TXT_IDX_1256 := "我们决定绕开莫斯科，在中苏边界举行单方面军事演习。这让苏联政治局大惊失色，他们媒体对中华人民共和国的污蔑也就此打住。但安稳日子将持续多久呢？"
const TXT_IDX_1257 := "今天，我国官方报纸《人民日报》发表了题为《走有中国特色的社会主义道路》一文，该文称：早在三国时期，中国便已经有了自己的马克思与社会主义理论。文章以这样一段话总结全文：“今天的中国特色社会主义可谓是我国民族传统、人民智慧与马克思主义理论的完美结合。中国不能不走这样的社会主义道路！”尽管这篇文章在党内引起了巨大争议，但莫斯科还是停止了对中华人民共和国的污蔑。但安稳日子将持续多久呢？"
const TXT_IDX_1258 := "我们对世界共产主义运动的资助成功堵住了莫斯科的嘴，他们媒体对中华人民共和国的污蔑也就此打住。"
const TXT_IDX_1259 := "苏联赞许我们的和平姿态，但我们为此牺牲了些许国际影响力。"
const TXT_IDX_1260 := "我国在莫斯科发展的下线送来最新消息：如果中国方面仍不思悔改，苏联将准备与中国断交。"

## 原文字符串附录（供自检）
## 我们已经无路可退！

func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var china := world.get_country_by_legacy_index(1)
	var c7 := world.get_country_by_legacy_index(7)
	if china == null or c7 == null:
		return false
	if not china.has_tag("sev"):
		return false
	if c7.special > 0:
		return false
	if not (china.government == 3 or (world.is_authoritarian(china) and _raw_in(world, 52) == 37)):
		return false
	return true

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var d := world.数值表
	var opt := event_def.options
	var pick := 0 if (randi() % 2 == 0) else 1
	event_def.description = _fmt(TXT_IDX_1245, [TXT_IDX_1246 if pick == 0 else TXT_IDX_1247])
	if 11 < world.modifiers.size() and world.modifiers[11] != null and world.modifiers[11].is_active:
		_disable(opt[0], TXT_IDX_1249)
	else:
		_enable(opt[0], TXT_IDX_1249)
	if d[W.I_ARMY] >= 350:
		_enable(opt[1], _fmt(TXT_IDX_1250, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214]))
	else:
		_disable(opt[1], _fmt(TXT_IDX_776, ["35"]))
	_enable(opt[2], _fmt(TXT_IDX_1251, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214]))
	if d[W.I_BUDGET] + (d[W.I_RESERVE] if d.size() > W.I_RESERVE else 0) >= 150:
		_enable(opt[3], _fmt(TXT_IDX_1252, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214]))
	else:
		_disable(opt[3], _fmt(TXT_IDX_566, ["15"]))
	if world.influence_prc >= 50:
		_enable(opt[4], _fmt(TXT_IDX_1253, [TXT_IDX_592, TXT_IDX_593, TXT_IDX_594, TXT_IDX_1214]))
	else:
		_disable(opt[4], _fmt(TXT_IDX_620, ["5"]))
	_enable(opt[5], TXT_IDX_1254)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c7 := ws.get_country_by_legacy_index(7)
	if opt == 0:
		if _raw(16) > 12:
			_add(16, -1)
		if _raw(15) > 6:
			_add(15, -1)
		_add_power(EmpireData.USSR, 25)
		_add_relation(EmpireData.USSR, 100)
		_loyalty_sov()
		if c7 != null:
			c7.special = 7
		context["result_text"] = TXT_R[0]
	elif opt == 1:
		_add(W.I_ARMY, -350)
		_add_relation(EmpireData.USSR, -150)
		_add_power(EmpireData.USSR, -30)
		if c7 != null:
			c7.special = 7
		context["result_text"] = TXT_R[1]
	elif opt == 2:
		_add(W.I_PARTY_SUPPORT, -450)
		_add_relation(EmpireData.USSR, -300)
		_loyalty_sov()
		if c7 != null:
			c7.special = 7
		context["result_text"] = TXT_R[2]
	elif opt == 3:
		_add(W.I_BUDGET, -150)
		_add_power(EmpireData.USSR, 20)
		_add_power(EmpireData.USA, -20)
		_add_relation(EmpireData.USSR, 100)
		if c7 != null:
			c7.special = 7
		context["result_text"] = TXT_R[3]
	elif opt == 4:
		ws.influence_prc -= 50
		_add_power(EmpireData.USSR, 50)
		_add_relation(EmpireData.USSR, 100)
		if c7 != null:
			c7.special = 7
		context["result_text"] = TXT_R[4]
	else:
		if c7 != null:
			c7.special = 7
		_add(140, 1)
		_add(139, 5)
		context["result_text"] = TXT_R[5]

func _raw(i: int) -> int:
	if d.size() > i:
		return d[i]
	return 0

func _raw_in(world: WorldState, i: int) -> int:
	if world.数值表.size() > i:
		return world.数值表[i]
	return 0

func _loyalty_sov() -> void:
	for p in ws.politicians:
		if p == null:
			continue
		if p.trait_personality == 0:
			p.loyalty += 300
		elif p.trait_personality == 1:
			p.loyalty += 100
		elif p.trait_personality > 1:
			p.loyalty -= 500
