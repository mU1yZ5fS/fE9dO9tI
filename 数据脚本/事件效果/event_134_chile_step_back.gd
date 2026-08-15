extends "res://数据脚本/event_script_base.gd"

## 原作 Event134.cs：进一步，退两步（3 选项）。
## 触发：原版未发现自动触发条件（trigger_conditions 为空），疑由未逆向的选举/地图系统手动触发。

const TXT_TITLE := "进一步，退两步"
const TXT_DESC := "皮诺切特将军领导的智利军政府正在逐步瓦解。国内，左翼激进分子分子对其展开游击斗争，反对派民主联盟（AD）与人民民主运动（PDM）正逐步扩张影响力；国外，苏联与古巴源源不断向反对派提供援助，甚至美国也因为军政府的法西斯化立场停止支持皮诺切特，施压皮诺切特迫使其退出政坛，从而恢复文官统治；1979年的经济危机更是加剧了民众的贫困，激发了人民对皮诺切特的反对情绪。这种情况下，皮诺切特和他的首席理论家海梅·古兹曼决定逐步放开体制：军政府将在1990年还政于文官政府、恢复国家议会活动、举行多党制议会选举与总统选举。据我方情报部门报告，现在只有仓促成立的四个亲军方政党，两个中左翼，两个中右翼，被允许参加选举。皮诺切特本人和御用反对派安东尼奥·扎莫拉诺提名为总统候选人。但现在反对派的声势不同往日，形势也许有所变化......"
const TXT_OPT0 := "刺杀皮诺切特（马列主义）"
const TXT_OPT1 := "促使权力由皮诺切特向温和的埃尔南·布奇过渡（自由主义）"
const TXT_OPT2 := "保持距离"
const TXT_PROPRC_YES := "新政府决心和我们做朋友。"
const TXT_PROPRC_NO := "新政府不想和我们做朋友。"
const TXT_OPT0_DIS := "智利的地下武装力量还不够强大！"
const TXT_OPT1_DIS := "军方对皮诺切特的不满程度尚不足以同意这样做。"
const TXT_R0 := "因为加入了反对军政府的斗争，中国得以同反对派重新建立联系，并同亲苏的曼努埃尔·罗德里格斯爱国阵线（PFMR）实现了整个地下武装的大串联；在苏联和中国的帮助下，持亲苏立场的智共领导人路易斯·科瓦兰秘密回国领导游击队；民主联盟（AD）对皮诺切特的反对活动削减了他的影响力；人民民主运动（PDM）激进化。在PFMR的一次武装行动中，他们击毙了圣地亚哥卫戍司令乌尔苏亚将军和军政府首席理论家古兹曼议员，并且将奥伊金斯的国旗拔下并插在安第斯山上。在中国情报部门的协助下，代号为“二十世纪行动”的暗杀皮诺切特计划被精心制定出来，袭击地点定在名为拉斯阿丘帕拉斯的斜坡，一条穿过山脉的狭窄通路。游击队员假扮成神学院学生，在附近的一座民房埋伏下来。当皮诺切特的车队进入伏击区，游击队员展开了猛烈的进攻。由于地形限制，皮诺切特的警卫员无法通过无线电与附近的军警部队沟通。一枚苏制榴弹发射器击中了皮诺切特的座驾，引起爆炸并烧毁，这个独夫民贼就此一命呜呼。他的暴亡成为了打响武装起义的发令枪，使军队和宪兵措手不及。起初是民众冲击行政大楼，然后反对党也加入了叛乱。政权垮台之后，智利政权移交给了由科瓦兰、左翼基督教民主党人拉多米尔·托米克、社会党人克洛多米罗·阿尔梅达担任集体主席的过渡国民政府。该政府恢复了1925年宪法，并叫停了新自由主义改革。在第一次多党选举中，共产党（霍查主义）、共产党（卡斯特罗主义）、共产党（莫斯科派）与基民党（托米克）赢得了大致相当的席位，组成了联合政府。"
const TXT_R1 := "皮诺切特的军内同僚，伙同与在野的民主联盟（AD）利用了国际社会的压力与民众的不满，成功说服皮诺切特解除总统职位退出政坛，同时保留智利军队总司令的职位。皮诺切特的平民“门生”埃尔南·布奇被拥立为智利的新总统。布奇的经济方针是，以出口为导向的稳健发展来为财政创造良好条件，并优化调整出口部门的产业结构。通过政府削减开支、货币定期贬值、鼓励国内储蓄、吸引外国投资与资本回流的经济政策，智利的通胀率逐渐回落到12%，为同期拉丁美洲的最低水平。通过以出让国有企业股份换取私人投资者购买公共债务，以及对养老金与医疗保健的私有化，智利的债务负担减轻了逾40亿美元。自皮诺切特军事政变后民众的普遍贫困由此开始得到逐渐改善。与此同时，审查与管制得到逐渐削弱，基督教民主党（CDP）与社会主义者的合法组织民主党（PDC）得到承认，其党员开始就职一些政府岗位。"
const TXT_R2 := "根据智利1980年宪法，奥古斯托·皮诺切特还将继续行使共和国总统职能为期8年，并在此期间维持军官政府。在皮诺切特的授意下，民族革兴党（RN）和独立民主联盟（UDI）宣告成立，对于民主联盟（AD）的一些限制也宣告解除。1987年12月，《事业》杂志刊登了爱德华多·哈米耶联合基督教人文学院撰写的调查报告，该报告收集了1980年对政府信任案的全民公投当天圣地亚哥大区第981号投票点所作的观察样本，并下结论称在该次公投中发现了无数起选民欺诈案件：被手动投“信任”的无效选票、重复投票、在编选票数量与选票总数不符、重新计票时监督员缺席导致舞弊，等等。无论如何，反对派正静待1988年的到来。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var ev133 := int(world.completed_event_ids.get("event_133", 0))
	var ussr_rel := 0
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null:
		ussr_rel = world.empires[EmpireData.USSR].relations
	if ev133 == 1 and (world.get_flag("relres") or ussr_rel >= 800):
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if ev133 < 2:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], TXT_OPT2)


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
	var chile := ws.get_country_by_legacy_index(74)
	if chile == null:
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			chile.level_of_instability -= 5
			chile.level_of_development += 10
			chile.government = 1
			chile.sub_government = 2
			chile.set_tag("亲中", true)
			_leave_alliances(chile)
			# iron_and_blood 成就 Set(91) 端口无成就系统，跳过
			context["result_text"] = TXT_R0 + _proprc_suffix(chile)
		1:
			_add(W.I_BUDGET, -25)
			_add(W.I_AGENTS, -25)
			chile.level_of_instability -= 15
			chile.sub_government = 6
			chile.set_tag("亲中", true)
			_leave_alliances(chile)
			context["result_text"] = TXT_R1 + _proprc_suffix(chile)
		_:
			chile.level_of_instability -= 20
			chile.level_of_development -= 5
			context["result_text"] = TXT_R2 + _proprc_suffix(chile)
	chile.next_election_year = 1989
	chile.next_election_month = 12
	chile.next_election_day = 14

