## 原作 Event296.cs：宣讲到头（“宣讲二号”名册，三选项）。
## 触发：全目录搜索无 this_num_event = 296 / Reset(296)；链外 REST 段，原版无自动条件。
## 差异：inflCh→influence_china；原版 string.Format 未使用占位符。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT1_DIS := "这对我们来说毫无意义"
const TXT_OPT2_DIS := "涉足密室政治对我们而言毫无益处"
const TXT_R0 := "虽说对辛多纳的调查仍未得出最终定论，可有关“深层政府”名册的消息还是不胫而走，很快便转化为一场大规模政治丑闻。现任总统亚历山德罗·佩尔蒂尼对这一事件的不妥协态度，意大利激进主义者的推波助澜与意大利共产党的落井下石（很显然，他们找到了足以解释自己为何在民主政治内“表现不佳”的完美替罪羊）更为清算“宣讲二号”提供了强大助力：考虑到在名册内榜上有名的议会政客基本上来自于天主教民主党、意大利社会党等传统建制派政治团体。巨头们不得不低调行事，并在各自党魁的回击下为自身清白做辩驳（贝蒂诺·克拉克西就曾将“名单”视为司法部门偏听偏信，炮制罪证的典型案例；其动机无非是藐视国家宪法，借机扩权并拔除自身不乐见的政客们）。当然，这种辩白的效果得取决于当前的政治环境如何——事实上，忽略现任意大利总理的眼色谈论政治洗牌是不可能的，而稳坐这把交椅的领袖当然知道怎么做才会对意大利最好……"
const TXT_R1 := "考虑到该名册同黑手党要员辛多纳的不可分关系，且“宣讲二号”作为地下结社的性质使其天然亲近密室政治。我们可说，名册暴露这一事件本身便是对意大利传统建制派精英的威胁。而这恰是撬动局势的大好机会——只需要一点小钱与眼线，有关意大利“地下王国”的消息便迅速落入了该国的进步派大嘴巴处：几乎是在辛多纳得出新进展的同时，《团结报》、《宣言报》与《浓缩精华》等杂志迅速公开了“宣讲二号”头目利西奥·盖利与其涉足各界的狐朋狗友们：其中不仅包括传媒大亨西尔维奥·贝卢斯科尼、著名银行家罗伯托·卡尔维与前任情报部长维托·米切利等分量十足的巨鳄。更涉及天主教民主党与意大利社会党的多位政治家。仅目前搜集到的名单便涉及119名高级军官、22名警察、59名议员、1名宪法法官、8名报纸编辑、4名出版人、22名记者、128名上市公司经理、外交官和企业家。而这只是一个开始。对利西奥·盖利的施压又得出了相当多的重要信息。根据有关人士透露：实际上同“宣讲二号”的秘密集团存在联系者多达2400余人。而这一集团的真正核心当属政坛常青树朱利奥·安德烈奥蒂——他出于确保天主教民主党霸权的需要建立了此类地下网络，并至此同犯罪世界与国际反共情报网络建立了密切联系。从利西奥·盖利女儿处发现的意大利政治备忘录更震撼了该国政坛：这份冠名为“复兴民主”的文件计划以大规模产业私有化，建立美国式两党体制，发展黄色工会与终止政治性罢工，乃至控制大众传媒等手段将意大利改造为寡头统治下，以舆论与制宪权为核心行使权力的软威权主义国家。相关信息的公开与接连不断的舆论运动大大打击了天主教民主党的公信力，多位著名政客不得不自请隐退，该党党势就此不断走低。我们希望这将为意大利政治民主化创造良好开端。"
const TXT_R2 := "考虑到该名册同黑手党要员辛多纳的不可分关系，且“宣讲二号”作为地下结社的性质使其天然亲近密室政治。我们可说，名册暴露这一事件本身便是对意大利传统建制派精英的威胁。出于维持政局稳定，并浑水摸鱼，为我国牟利的需要。我们决定以此为契机，并帮那些在名册上榜上有名的意大利的政治精英们“金盆洗手”——当然，所有的服务都已预先标好了价码。考虑到辛多纳案目前仍处于调查取证阶段，相关档案仍处于整理与汇集状态，动用假文件替换并销毁原始材料可说是轻而易举。如此做法自能让该国传统政客们稳坐江山，并让试图以辛多纳案借题发挥的所谓“进步派”媒体们无话可说。作为回报，意大利“深层政府”同我国企业达成了数项技术转让协议，在国内工程招标上为中方开后门的同时向我们开放了该国安全领域的诸多秘密——其中自包括意大利情报网络中最珍贵的部分……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var china := world.get_country_by_legacy_index(1)
	var italy := world.get_country_by_legacy_index(85)
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if not world.is_authoritarian(china):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if italy != null and italy.influence_china <= 0 and not world.is_socialism(china, true) \
			and italy.has_tag("对华贸易"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if italy != null and italy.influence_china <= 0:
				_add(182, 1)
			else:
				_add(176, 1)
				_add(182, 1)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -50)
			_add(175, -1)
			_add(182, 2)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, 30)
			_add(W.I_AGENTS, -50)
			_add(W.I_INDUSTRY, 10)
			_add(W.I_SERVICES, 10)
			_add(176, -1)
			_add(182, 2)
			context["result_text"] = TXT_R2




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	PoliticianSystem.copy_leader_appearance(ws.leader, p)

