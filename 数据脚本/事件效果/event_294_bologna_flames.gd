## 原作 Event294.cs：博洛尼亚烈火（博洛尼亚惨案，四选项）。
## 触发：全目录搜索无 this_num_event = 294 / Reset(294)；链外 REST 段，原版无自动条件。
## 差异：result0/1 原版 string.Format 但未使用 {0}{1}，按无占位符逐字处理。
extends "res://数据脚本/event_script_base.gd"

const TXT_TITLE := "博洛尼亚烈火"
const TXT_DESC := "8月2日上午10时25分，博洛尼亚中央车站的候车室内发生剧烈爆炸，近乎震撼全城：此次事件不仅导致车站主体建筑基本被毁与一列在安科纳与基亚索间往返的专列受损；更造成85人遇害，200余人受伤。随着各方势力纷纷入局，对于本次事故的调查很快便从“车站内老式设备损坏论”转向“恐怖组织袭击论”。毕竟，火车站不可能自备装有51磅炸药、11磅TNT与B炸药、以及40磅硝酸甘油的“大锅炉”。考虑到本次袭击的无差别屠杀风格：以意大利共产党控制的《团结报》为代表的媒体直截了当地将凶手归于“新法西斯主义者”与新右翼活动家们（毕竟，以“红色旅”为代表的左翼恐怖分子们更热心于对国家官员和企业主的定点清除；且博洛尼亚长期作为左翼活动据点的历史事实让其成为了右翼势力的眼中钉，肉中刺。堪称最佳示威对象），并呼吁立即将凶手绳之以法。现任总统亚历山德罗·佩尔蒂尼亦对此表示高度重视，称“绝不能对有史以来最猖獗犯罪活动的始作俑者置之不理”。虽说幕后真凶仍藏于阴影之下，扑朔迷离难以瞥见。可在民意裹挟之下，司法部门也不得不亮出其惩罚之剑：后者很快将目标指向极右翼恐怖组织，同时亦是无依无靠的“革命武装核心”活动家们，并准备对其展开特别逮捕行动。考虑到这一政治热点仍在不断发酵，我们自可以浑水摸鱼，将局势引导向最有利于我们的方向。"
const TXT_OPT0 := "向意大利人民表示慰问，并呼吁当局查明真凶，还受害者公道。"
const TXT_OPT1 := "介入意大利局势，暗示极右翼应当为此次事件负全责"
const TXT_OPT1_DIS := "政治议题工具化不符合民主社会的原则"
const TXT_OPT2 := "介入意大利局势，竭尽所能为嫌疑人们洗清冤屈"
const TXT_OPT2_DIS := "我们为什么要帮潜在的杀人犯洗手？"
const TXT_OPT3 := "向意大利人民表示慰问"
const TXT_R0 := "我国外交部向意大利当局表示慰问，并为惨案受害者们送去了人道主义援助——当然，事情可不会到此为止。相当数量的资金被用于打点媒体（主要是《团结报》、《浓缩精华》与《宣言》等持社会进步立场，在博洛尼亚事件中要求彻查并对极右翼恐怖主义采取措施的传媒）与援助博洛尼亚本地的司法部门。以此倒逼意大利当局深入调查，并将矛头指向最可能同此次事件瓜葛的恐怖主义活动家们。这一挤压政策很快便收获了成效——当局调查结果表明，极右翼恐怖团体“革命武装核心”的成员积极参与了此案，并借此迅速逮捕了相关人员。该组织亦被卡宾枪骑兵彻底查封。博洛尼亚事件至此迅速结案。然而，在暂无详细证据，仅基于有罪推定并下达逮捕并结束调查的如此草率的做法不由得引人思考——仿佛一切的一切都只是“革命武装核心”的独狼式袭击而已，而意大利国家体制完全不须为此次事件负责……"
const TXT_R1 := "我们决定以博洛尼亚惨案为契机，全面插手意大利国内政局——不论是事件受害者，博洛尼亚地方当局及司法部门，还是以《团结报》、《浓缩精华》与《宣言》等持社会进步立场，在博洛尼亚事件中要求彻查并对极右翼恐怖主义采取措施的传媒，都得到了相当分量的“人道主义援助”：这些赞助足以使其在弥合伤痕的同时迅速发起并长久维持一场规模空前的宣传运动。在我国外勤人员的“特别关照”下，上述势力力推的舆论共识很快便取得了成效——意大利当局不得不屈服于汹涌民意，竭尽所能寻找最为理想的“替罪羊”。调查很快便指向了该国的主要极右翼恐怖团体“革命武装核心”，相关人员被迅速逮捕，该组织亦被卡宾枪骑兵彻底查封。然而，事情并未到此为止：借案情侦办这一敏感时期，我们特意为意大利当局送上了份“惊喜”——渗入另一极右翼恐怖组织“新秩序”政治运动的特洛伊木马成功在罗马引爆了一枚烈性炸药，至此让该国极右翼运动成为众矢之的。考虑到政治暴力有愈演愈烈之风险，意大利当局不得不选择积极清理该国所有成气候的极右翼恐怖运动倾向，并实施严苛的连坐制度——这直接导致了该国极右翼建制派的代表与作为“新秩序”政治运动母体的意大利社会运动惨遭打击，后者至此分裂为持更温和立场，并同天主教民主党内右翼靠拢的民族保守主义者与主张直接通过恐怖运动颠覆该国的运动家群体。“合法阶级调和”的路线至此终结了……与此同时，通过对意大利国家的深入调查亦让我国情报人员摸到了些许蛛丝马迹——即意大利第一共和国运转的根本逻辑——“恐怖主义越猖獗，国家机器越强大，在这种意义上双方实现共生”……"
const TXT_R2 := "意大利政界的裙带关系并非秘密——只需要点小钱，不论是企业还是黑手党，亦或是境外势力代言人，皆可在该国境内畅通无阻。该国各级机构内的反共情绪更是在长期霸占内务部的“铁腕权臣”弗朗切斯科·科西加控制下逐年走高，事实上形成了极左恐惧症。而来自局外人的视角足以让当局者将局势看得更为“清楚”——只需要稍稍向深耕国家机关的要员们暗示同自己共事的军情体制究竟能多么“无法无天”，并罗列其在70年代多次独走的历史经验，那让政府官员与司法部门们寻找替代信源不过是时间问题。我国情报人员的工作很快便达到四两拨千斤的成效：不仅促使政治大鳄，对安全事务有相当发言权的科西加放弃了“黑色恐怖分子更倾向于采取大规模恐怖袭击”的假设，转而将嫌疑转向“红色旅”，乃至巴勒斯坦地区的左翼武装团体上。意大利安全部门更将《团结报》掀起，更得到进步派传媒巨头《浓缩精华》附和的“右翼恐怖分子主谋”论打上了意图以“宣传阴谋论形式扰乱调查方向”，“加剧国内政治对立”并最终以不当竞争形式为意大利共产党谋求政治资本等帽子，至此为激进右翼洗清了指控。在“红色旅”与“革命武装核心”两大恐怖组织均宣称自己“无辜”的政治声明被广而告之的背景下，如此局势只会让调查举步维艰：警方只能抛弃民意与媒体影响，在缺乏出发点与线索的情况下重新搜寻真相——事实上意味着调查的长期停滞乃至冻结。这便为为该国的恐怖组织们做了表率：既然国家对如此规模的袭击行动都无动于衷，那接下来自是广阔天地，大有可为。而意大利国家对于“恐怖活动”的实质纵容，乃至安全部门对于相关信息的深入操纵，事实上将国民注意力转移到恐惧极端主义势力本身的做法亦让我国情报人员摸到了些许蛛丝马迹——即意大利第一共和国运转的根本逻辑——“恐怖主义越猖獗，国家机器越强大，在这种意义上双方实现共生”……"
const TXT_R3 := "我们决定向意大利人民表示慰问，并对该国国内政治暴力愈演愈烈的局势表示高度关切——此后当局调查结果表明，极右翼恐怖团体“革命武装核心”的成员积极参与了此案，并借此迅速逮捕了相关人员。博洛尼亚事件就这样草草结束了。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	var diplo := world.数值表[W.I_DIPLO] if world.数值表.size() > W.I_DIPLO else 0
	var war := world.数值表[W.I_WAR_SUPPORT] if world.数值表.size() > W.I_WAR_SUPPORT else 0
	var opt := event_def.options
	_enable(opt[0], TXT_OPT0)
	if line < 3:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line <= 3 and diplo >= 900 and war > 300:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -30)
			_add(182, 1)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -40)
			_add(W.I_AGENTS, -60)
			_add(176, 1)
			_add(177, -999)
			_add(182, 2)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -80)
			if italy != null:
				italy.level_of_development -= 5
			_add(134, 10)
			_add(177, 1)
			_add(182, 2)
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _mod_active(idx: int) -> bool:
	var w := ws if ws != null else GameManager.world
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
	ws.leader.face_type = p.face_type
	if p.face_parts.size() >= 8:
		ws.leader.face_parts = p.face_parts.duplicate()
	ws.leader.jacket = p.jacket

