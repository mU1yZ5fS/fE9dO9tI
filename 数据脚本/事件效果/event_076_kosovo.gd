extends "res://数据脚本/event_script_base.gd"

## 原作 Event76.cs：落井下石！（科索沃骚动，四选项）。
## 触发：TimeScript.cs:10596-10602 ——
##   (月>=3 且 年>=1981 或 年>=1982) && !c15.Torg && data[60]==0。
## 选项显隐（prepare 动态改写）：
##   原版 summa_3_2 阈值 66 → Godot factions 复算（见 event_075 同款辅助）。
## 差异：
##  - 原版 result1 失败分支的 data[8]++ 为局部指针自增（未写回，死代码），跳过。
##  - 原版 result3 的 dlc[3] 分支：项目惯例 dlc[3] 视为恒真
##    （world_factory.gd:1462 注释），故采用中文长文本分支，
##    不再取 new_events_text[900] 的 else 分支。
##  - data[86]（科索沃状态）直访 d[86]。

const TXT_R0 := "中华人民共和国外交部发布公报，正式向科索沃示威者表示支持，因为“抗议者享有合法的民主权利”。这引起了南斯拉夫的强烈愤慨，南斯拉夫指责中国干涉其内政，它领导下的不结盟运动指责中国为“毛主义霸权”。苏联和美国忽视了这一点，主要是因为南斯拉夫社会主义联邦共和国不在任何一个集团中的“独立”立场。科索沃进入紧急状态，部分南斯拉夫人民军进入，到4月3日，该省所有抗议活动都已被镇压，并恢复了秩序。南斯拉夫当局发现了阿尔巴尼亚介入的证据。对分离主义者的大规模清洗开始了。"

const TXT_R1_BASE := "我们在地拉那的大使照会恩维尔·霍查与拉米兹·阿利雅（西古里米领导人）两位同志，并向他们表达了中方的合作意愿。"

const TXT_R1_OK := "他们同意我们的帮助。在阿尔巴尼亚，中国国安部的一批员工已经抵达，很快与西古里米建立了合作关系。结果，尽管南斯拉夫人民军成功地镇压了叛乱，但他们并不能完全平定该省。我们可以在那里再次发动暴乱。"

const TXT_R1_FAIL := "不幸的是，他们拒绝我们的帮助，声称我们的特工在南欧力量太弱。叛乱很快被镇压下去，南斯拉夫国家安全局揭露并挫败了三条主要的西古里米情报网络，取缔了一个非法的“斯派—霍查派共产党”，对阿尔巴尼亚在南斯拉夫的情报部门造成了沉重打击。"

const TXT_R2 := "科索沃进入紧急状态，部分南斯拉夫人民军进入，到4月3日，该省所有抗议活动都已被镇压，恢复了秩序。"

const TXT_R3 := "在政治局内部会议上，决定了利用南斯拉夫问题，为科索沃分离主义者提供全面协助。我们决定将驻贝尔格莱德使馆作为“中转站”。科索沃分离主义者在得到我们提供的武器和资金后，开始对部分南人民军和民兵进行武装抵抗。普里什蒂纳爆发了最残酷的巷战，南斯拉夫军队积极地使用炮兵和航空兵，结果导致城市被毁。“普里什蒂纳在燃烧”的新闻传遍全球，严重打击了南斯拉夫联邦的国际威望，尽管叛军在六月份最终被镇压下去，却需要大量资金重建这个地区，而南斯拉夫拿不出这笔钱。\n1981年4月，在南斯拉夫联邦主席团和联邦宪法秩序保护委员会的一次会议上，拉扎尔·科利舍夫斯基说：“我们必须充分认识到这一论题的荒谬和极端反动性质——即塞尔维亚越弱，科索沃越强（或我们的任何其他共和国）。以及另一论题——科索沃在塞尔维亚的自治权越小，塞尔维亚越强大。这也可以说是关于——塞尔维亚越弱，南斯拉夫越强这一论题。”民族主义者开始加强他们在这个国家的地位…"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 3 and party < 8) or (coal > 66 and party > 7)
	var albania := world.get_country_by_legacy_index(20)
	var opt := event_def.options
	if policy_left:
		_enable(opt[0], "我们会在外交上支持科索沃分离主义者，但仅此而已")
	else:
		_disable(opt[0], "那不是我们的问题")
	if policy_left and albania != null and albania.has_tag("亲中"):
		_enable(opt[1], "向阿尔巴尼亚提供援助，帮助其将科索沃从南斯拉夫分离出来（需要5特工网络，需要5百万预算）")
	else:
		_disable(opt[1], "为什么要帮助阿尔巴尼亚？")
	_enable(opt[2], "不干涉")
	if data.size() > W.I_AGENTS and data[W.I_AGENTS] >= 100:
		_enable(opt[3], "我们将提供特勤和经济援助来帮助科索沃分离主义者（需要10特工网络，10百万预算）。")
	else:
		_disable(opt[3], "我们对南斯拉夫事务不感兴趣")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, 20)
			context["result_text"] = TXT_R0
		1:
			var text := TXT_R1_BASE
			if d.size() > W.I_BUDGET and d.size() > W.I_RESERVE and d.size() > W.I_AGENTS \
					and d[W.I_BUDGET] + d[W.I_RESERVE] >= 50 and d[W.I_AGENTS] >= 50:
				text += TXT_R1_OK
				_add_power(EmpireData.USA, 10)
				if d.size() > 86:
					d[86] -= 2
				_add(W.I_BUDGET, -50)
				_add(W.I_AGENTS, -50)
			else:
				text += TXT_R1_FAIL
				# 原版死代码：int ptr = data[8]; ptr = data[8] + 1;（局部自增未写回），跳过
			context["result_text"] = text
		2:
			context["result_text"] = TXT_R2
		3:
			# dlc[3] 恒真（项目惯例 world_factory.gd:1462）
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			if d.size() > 86:
				d[86] -= 4
			_add_power(EmpireData.USA, 20)
			context["result_text"] = TXT_R3


## 原版 summa_3_2 复算（同 event_075）。
func _coalition_percent(world: WorldState) -> int:
	var data := world.数值表
	if data.size() <= W.I_PARTY_SYSTEM or data[W.I_PARTY_SYSTEM] <= 7:
		return 0
	if world.factions.size() < 5:
		return 0
	var num := world.factions[1].support
	var total := 0
	for i in world.factions.size():
		var f := world.factions[i]
		if f == null:
			continue
		total += f.support
		if i != 1 and f.is_ally and f.is_enabled:
			num += f.support
	if total <= 0:
		return 0
	@warning_ignore("integer_division")
	return num * 100 / total


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


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta
