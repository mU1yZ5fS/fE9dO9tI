extends "res://数据脚本/event_script_base.gd"

## 原作 Event486.cs：德意志之秋（西德红军旅/K小组，三选项）。
## 触发：ReqEventForDLC02.cs:1499-1501 ——
##   ((年>=1977 月>=10 日>=17) || (年>=1977 月>=11) || 年>=1978)。
## 差异：
##  - data[56] 政治路线 → W.I_POLITICAL_LINE；proprc/Torg/econ/okb → set_tag；
##  - result1 的 data[60]==0 分支按原版 int 默认 0 处理。

const TXT_TITLE := "德意志之秋"

const TXT_DESC := "自1977年四月七日以来，西德马克思主义的极左翼城市游击队“红军旅”与“革命小组”展开了大量针对联邦德国政要与实业家的刺杀，绑架与定向爆破。受害者包括但不局限于：齐格飞·布巴克，尤尔根·庞特等联邦德国巨贾和反共政客。近日，他们又策划了一起劫机案，使得他们本就不多的支持越来越少。\n而与极左翼城市游击队一同发源于西德68运动的“K小组（K-Gruppen,意即CommunistGroups，指的是从68运动发展出的一系列毛派团体或政党）”虽然都有反修正主义的共同基础，但是他们仍在理论和社会分析上存在较大分歧，其中有部分已经倾向阿尔巴尼亚。在西德的紧张气氛下，我们是否要借势将这些分散的革命派组织整合起来？或者帮助西德当局打击这群叛匪，以获得和西德政府合作的机会？"

const TXT_OPT0 := "我们最好组成革命共产党人的大串联"
const TXT_OPT0_DIS_NOPRO := "显然，连阿尔巴尼亚都不支持我们，我们无力和他们取得联系"
const TXT_OPT0_DIS_LINE := "支持革恐分子，你疯了？"
const TXT_OPT1 := "让我们协助西德政府扫清叛匪"
const TXT_OPT1_DIS := "我们不能背叛革命者！"
const TXT_OPT2 := "可是西德太远啦……"

const TXT_R0 := "我们在西德的特工决定帮他们一把。在一个夜黑风高的夜晚，我们的特勤用一捆烈性炸药打破了斯图加特监狱的大门，安德烈亚斯·巴德尔和古德伦·恩斯林等红军旅高级成员得到了自由。作为交换，“红军旅”将被改编为新生的革命团体的附属组织。在我们和阿尔巴尼亚的大力推动下，德国共产党/马克思列宁主义、德国共产党（重建组织）、共产主义者联盟、德国共产主义工人联盟、德共重建工人联盟和西德共产主义者联盟等组织在汉堡正式宣布合并为德国马列主义革命党。新的党组织确定了以维利·迪克胡特主席为核心的中央委员会。《人民日报》在第二天发文庆祝西德人民在摆脱美帝国主义枷锁的斗争有了新的主心骨。“红军旅”和“革命小组”被改组为由马列主义革命党领导的“德意志人民武装力量”，他们向我们保证将减少革命恐怖活动，转向人民战争理论，以积极谋求在学生和工人之间发展潜在的成员和同情者。地拉那也宣布支持西德人民团结起来的斗争。\n在革命派共产党人联合起来的情况下，基民盟/基社盟开始动员支持者施压施密特政府，而社民党-自民党政府不得不在国内外的压力下宣布组织跨党派的大危机委员会，西德进入了事实上的紧急状态。社会法西斯主义者又一次对革命派举起了屠刀……"

const TXT_R1 := "我们将西德革命者的名单交给了西德政府，大危机委员会被允许用来指挥抓捕左翼组织的领导人，政府很快组织了一场特别行动，对各路极左翼“叛匪”进行“从重、从快、从严”的打击。作为交换，西德向我们提供了一批经济援助，并将派遣专家支援我国经济建设。西德K小组和阿尔巴尼亚谴责我们的背叛行为，同我们断绝了关系。"

const TXT_R2 := "我们没有对西德的问题作出任何回应，这天夜里，“红军旅”的三位领导人在监狱里自尽身亡，他们的后继者将继续斗争。而K小组也在继续发展着——德共/马列转向了霍查主义；另一部分组织则组成了毛派的德国马列党；K小组中的部分人员转向了环境运动以及和平运动，参与组织了绿党。\n施密特政府召集了跨党派的大危机委员会，国家实施了为期45天的“禁止接触法”，狱中的红军旅成员不得接触外部信息，以免狱内外的成员取得联系从而共同采取行动。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var line := world.数值表[W.I_POLITICAL_LINE] if world.数值表.size() > W.I_POLITICAL_LINE else 1
	var albania := world.get_country_by_legacy_index(20)
	var albania_pro := albania != null and albania.has_tag("亲中")
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	if line <= 1 and albania_pro:
		_enable(opt[0], TXT_OPT0)
	elif not albania_pro:
		_disable(opt[0], TXT_OPT0_DIS_NOPRO)
	else:
		_disable(opt[0], TXT_OPT0_DIS_LINE)
	if line > 2 and not mod3:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var west_germany := ws.get_country_by_legacy_index(17)
	var albania := ws.get_country_by_legacy_index(20)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			_add(W.I_AGENTS, -50)
			ws.influence_prc += 10
			_add_relation(EmpireData.USA, -80)
			_add_power(EmpireData.USA, -20)
			_add_power(EmpireData.USSR, 50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -30)
			ws.influence_prc += 5
			_add_power(EmpireData.USA, 50)
			_add_power(EmpireData.USSR, -20)
			ws.influence_prc -= 20
			if west_germany != null:
				west_germany.set_tag("对华贸易", true)
			# data[60]：原版中阿决裂状态（无常量），raw index + 注释。
			if d.size() > 60 and d[60] == 0:
				if albania != null:
					albania.set_tag("亲中", false)
					albania.set_tag("econ", false)
					albania.set_tag("对华贸易", false)
					albania.set_tag("okb", false)
			_add_relation(EmpireData.USA, 50)
			_add(W.I_BUDGET, 50)
			_add(W.I_SCIENCE, 200)
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2


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
