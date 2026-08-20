extends "res://数据脚本/event_script_base.gd"

## 原作 Event122.cs：维吾尔领导人（3 选项）。
## 触发：由 Decision(GlobalScript.cs:23) 手动触发（维吾儿自治路线），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻选项显隐与结果效果。

const TXT_OPT0_DIS := "已与苏联恢复关系"
const TXT_OPT2_DIS := "与美国签署友好合作条约或国家结构形式为联省自治或自治联盟"
const TXT_R0 := "在赛福鼎·艾则孜得以完全恢复名誉后，他先是被任命为重新组建的苏中友好委员会与中巴友好委员会的主席，然后，在通过对其忠诚度的考验后，他被指示组建新的维吾尔自治政府。作为他职位职责的一部分，他在基于苏联中亚模式的基础上建构了维吾尔斯坦——一个世俗的国家，属于宗教的地方只有家与清真寺、一个高素质的国家，拥有许许多多的科学机构、奉行国际主义，同时仍维持维吾尔文化的非反动部分。汉语成了必修语言，用维吾尔语教学的维吾尔族学校也多了起来，俄语则成为了首选外语。总的来说，新政府走上了一条世俗化与启蒙化的道路，掀起了一种普遍的文化热潮。"
const TXT_R1 := "维吾尔共和国重建后，包尔汉成为了这一角色——一个忠诚的亲华执政者的最佳人选。在他的领导下，维吾尔宪法得以制定，维吾尔政府的权力则被限制在最低限度，新政府把保护维吾尔族文化作为优先事项——清真寺与圣地得以重建，野生动物也得到了保护，所有维吾尔族人也将熟习汉语、熟知中华民族数千年来的光辉成就及伟大遗产。与此同时，他的政府引用了一些关于维吾尔族政治移民的反苏论点，特别是关于修正主义的苏联政府对突厥人族群的镇压与“强行分裂突厥民族”的行为，这让我们的苏联邻国感到担忧不已。"
const TXT_R2 := "艾尔肯·阿力普提肯受邀参加维吾尔共和国的政府会议，这着实让国际社会感到意外。他最温和的同志也加入了他的阵营，此前，他们与北京当局签署了一项反对分裂势力与分裂主义的协议。在新政府于维吾尔地区掌握全权后，他们便迅速开始重振甚至培植起“被压抑”的维吾尔文化，特别是将书籍、报纸、媒体、广告全部改为维吾尔语，汉语学校也被维吾尔语学校取代。与此同时，政府也证明了其世俗性，没有沉迷于伊斯兰教，这让中国中央当局的焦虑有所缓解。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var usa := world.get_country_by_legacy_index(51)
	var opt := event_def.options
	if world.get_flag("relres"):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)
	if (usa != null and usa.has_tag("对华贸易")) or world.数值表[W.I_TERRITORY] >= 22:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)




func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var east_turkestan := ws.get_country_by_legacy_index(70)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if east_turkestan != null:
				east_turkestan.special_ending = 0
			_set_modifier_active(21, true)
			_add(W.I_ARMY, -50)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, 500)
			_add_power(EmpireData.USSR, 15)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -25)
			_add(W.I_BUDGET, -25)
			if east_turkestan != null:
				east_turkestan.special_ending = 1
			_set_modifier_active(22, true)
			_add_relation(EmpireData.USSR, -250)
			_add(W.I_INFLUENCE, 5)
			_add_power(EmpireData.USSR, -25)
			if d[W.I_RELIGION] < 27:
				_add(W.I_RELIGION, 2)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, -50)
			_add(W.I_AGENTS, -25)
			_add(W.I_ARMY, -250)
			_add(W.I_INFLUENCE, 5)
			_add_relation(EmpireData.USA, 500)
			_add_power(EmpireData.USA, 50)
			if east_turkestan != null:
				east_turkestan.special_ending = 2
			_set_modifier_active(23, true)
			context["result_text"] = TXT_R2

