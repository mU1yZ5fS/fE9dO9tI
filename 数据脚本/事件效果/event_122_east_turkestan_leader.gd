extends "res://数据脚本/event_script_base.gd"

## 原作 Event122.cs：维吾尔领导人（3 选项）。
## 触发：由 Decision(GlobalScript.cs:23) 手动触发（维吾儿自治路线），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻选项显隐与结果效果。

const TXT_TITLE := "维吾尔领导人"
const TXT_DESC := "既然已经批准设立维吾尔共和国，并同意其组建自治政府，那么我们的意见也是很重要的。现在有三名候选人摆在我们面前，第一位是维吾尔族共产主义战士赛福鼎·艾则孜，他是四十年代三区革命时期的主要领导人之一，曾积极主张与苏联交好，也在“文化大革命”中遭到政治批斗。我们当然可以为其平反，因为他从未表露过分裂主义倾向。而第二位候选人，包尔汉·沙希迪，公开以穆斯林的身份进行活动，同样也是历经了三区革命磨炼的共产主义战士，但与前一位的不同之处在于，他不仅致力于维护中华苗裔，还公然反苏，狂热亲华。他显然是我们的最佳人选，但如果我们正在打击宗教思想，那么就得稍微放宽一些政策。最后，在流亡海外的维吾尔运动组织中，也有一位代表人物可以作为候选，其父曾在三区革命中参与支持亲国民党的维吾尔自治共和，其本人也曾作为自由电台的雇员，担任CIA中国区顾问。他不仅支持维吾尔的民族自决，也同样支持所有的少数民族自决。到目前为止，这位候选在分裂问题上的表态仍处于温和立场——他支持自治而非脱离，并声明只会采取和平手段。如果我们不担心美国的渗透，那么这就是一个绝佳人选，可以向全世界展示我们对人权的保护。"
const TXT_OPT0 := "赛福鼎·艾则孜"
const TXT_OPT1 := "包尔汉·沙希迪"
const TXT_OPT2 := "艾尔肯·阿力普提肯"
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
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)
	if (usa != null and usa.has_tag("对华贸易")) or world.数值表[W.I_TERRITORY] >= 22:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)


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


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1

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

