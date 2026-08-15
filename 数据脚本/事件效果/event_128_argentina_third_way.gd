extends "res://数据脚本/event_script_base.gd"

## 原作 Event128.cs：第三道路（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_TITLE := "第三道路"
const TXT_DESC := "经济困难促使阿根廷当局在1975年春天采取了一系列严厉的反通胀措施，但物价飞涨与工资冻结引发了布宜诺斯艾利斯的大规模抗议活动。同年，阿根廷被划分为五个军管区，军管区司令被赋予了充分自主权来重拳镇压骚乱。在军警的残酷镇压与严刑重典之下，一些革命性组织：如极左翼的“蒙东内罗斯”游击队和受何塞·洛佩兹·雷加包庇的阿根廷反共联盟（AAA）处决小队，使用爆炸和绑架手段制造恐怖事件，使政治暴力步步升级。顷刻之间，军方逮捕了总统伊莎贝尔·庇隆夫人，控制了所有的电视台和广播电台，切断了政府与外界的一切联系。随后，军方发布了第一封官方消息：国家政权目前处于军方控制，公民须严格遵守军队、警察与宪兵的规定，上述文件由豪尔赫·拉斐尔·魏地拉上将、罗伯托·爱德华多·比奥拉海军上将及奥兰多·拉蒙·阿戈斯蒂准将签署。次日清晨，没有任何引人注目的事件发生，也没有出现抵制政变的人群，但是军政府仍然决定从家中、工作岗位与街头逮捕工人、学生、政治人物与工会活动家。目前对军政府的反抗是零星的，但是如果此时能出现一个良好的领导核心，就能够将自由派、中间派、左翼政党、左翼庇隆主义团体和工会组织团结起来，形成有组织反抗反动政权的有生力量。"
const TXT_OPT0 := "同新政府建立双边贸易关系（保持原意识形态）"
const TXT_OPT1 := "试图召集所有的反对力量反对军政府(政治体制将会改变)"
const TXT_OPT2 := "保持距离"
const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_R0 := "阿根廷军政府控制了立法机关，建立了严格的审查制度，压制了媒体自由与言论自由。1976年到1983年的这一段时期被称为肮脏战争时期。逐渐壮大的“左”翼反对派试图推翻军政府，而军政府使用“处决小队”对反对者予以镇压，其结果是，1万至3万名公民在秃鹰计划中作为确凿反对派或嫌疑反对派消失得无影无踪，甚至有儿童在父母被处决前眼睁睁地被带走。军政府任命何塞·阿尔弗雷多·马丁内斯·德霍兹为经济部长，后者开始推行被称为新自由主义路线的政策，即经济稳健化与国有资产私有化，主张国家控制关键行业的法团主义路线的计划部部长拉蒙·迪亚兹将军由于反对德霍兹被很快勒令退休。社会贫富差距正在以极恶劣的速度扩大。"
const TXT_R1 := "在我方情报网络的支持下，我们将所有工会、民主人士与左翼力量团结在了庇隆主义游击队周围，在丛林中设立了地下指挥总部。反对派统战委员会不仅在广泛的群众支持下拯救保护许多人士免遭迫害，而且在全国各地展开总罢工，阿根廷生产陷入严重瘫痪。在军政府内部的倾轧中，罗伯托·爱德华多·维奥拉在拉蒙·迪亚兹、奥兰多·拉蒙·阿戈斯蒂等将领的支持下，发动了政变，逮捕了军政府领导人豪尔赫·拉斐尔·魏德拉、海军上将埃米利奥·爱德华多·马塞等一批狂热党羽，宣布了对受迫害人士的特赦并以平等地位同反对派进行谈判。谈判达成一项协议：即军政府放弃对工会和民主党派的禁令与迫害，但同时承担起“危机结束前”无限期维持国家秩序与稳定的责任，从而有权任命总统、组建内阁，并决定举行议会选举的日期。尽管庇隆主义左派表示激烈不满，但因为民主派、左翼人士与工会对此首肯，庇隆主义者出于免于激化局面的考虑，只能同意解除武装与和平过渡的要求。作为回应，他们要求逮捕和清算阿根廷反共联盟（AAA）及头目何塞·洛佩兹·雷加本人，这得到了军政府的同意。由此，镇压与迫害得到停止，和平与秩序得到恢复，拉蒙·迪亚兹将军掌管了经济部，执行法团主义的经济路线，保持国家对关键行业的控制。军政府明白，虽然他们的统治无法永恒，但至少也能笑到最后。"

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


func _leave_alliances(c: CountryData) -> void:
	for tag in ["okb", "econ", "sev", "ovd", "nato", "eu", "soc_eu", "亲苏",
			"亲美", "亲中", "asean", "seato", "oar", "oil", "对华贸易",
			"sento", "fxseu", "nazimao", "balecon", "rim", "au", "olas"]:
		c.set_tag(tag, false)
	c.puppet_of = -1


func _proprc_suffix(c: CountryData) -> String:
	return TXT_PROPRC_YES if c.has_tag("亲中") else TXT_PROPRC_NO

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var argentina := ws.get_country_by_legacy_index(71)
	if argentina == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -5)
			_add(W.I_AGENTS, -5)
			argentina.set_tag("对华贸易", true)
			argentina.government = 0
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			argentina.government = 3
		_:
			argentina.set_tag("亲中", false)
			argentina.government = 0
	argentina.sub_government = 7
	_leave_alliances(argentina)
	argentina.next_election_year = 1983
	argentina.next_election_month = 10
	argentina.next_election_day = 30
	if argentina.government == 0:
		argentina.level_of_instability -= 30
		argentina.level_of_development -= 15
		context["result_text"] = TXT_R0
	elif argentina.government == 3:
		argentina.level_of_instability -= 15
		argentina.set_tag("亲美", false)
		_add_power(EmpireData.USA, -5)
		context["result_text"] = TXT_R1

