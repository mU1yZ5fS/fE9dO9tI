extends "res://数据脚本/event_script_base.gd"

## 原作 Event583.cs：从今打碎暴虐的锁链（中非科林巴，四选项）。
## 触发：ReqEventForDLC02.cs:824-827 —— c65.puppetOf==21
##   && ((日>=3 且 月>=3 且 年>=1982) || (月>=4 且 年>=1982) || 年>=1983)。
##   .tres = ALL(DATE_AFTER 1982.3.3, COUNTRY_FIELD_EQUALS target=65 key=puppet_of value=21)。
## 差异：
##  - 描述按 resultOfEvents[582] 动态拼接（缺省按原版 int 默认 0）；
##  - science[24] → ws.techs.unlocked[24]；Torg → 对华贸易；proprc → 亲中；puppetOf → puppet_of。

const TXT_TITLE := "从今打碎暴虐的锁链"

const TXT_DESC_A := "在戴维·达科重新成为总统后，中非的政治和经济改革进行得并不成功。1981年9月1日，安德烈·科林巴将军发动了一场不流血政变，推翻了达科总统。随后成立的民族复兴军事委员会作为新的统治机构暂停了宪法，并限制了政党活动。科林巴的军政府继续维持亲法政策，并承诺一段时间后举行选举，同时消除政府的腐败，但在接下来的几年里，腐败加剧：科林巴政府的许多成员，是与他同民族的亚科马族，他们在中非共和国经济的公共部门、私营和半国营部门获得了许多有利可图的职位，这导致了中非共和国所谓的“南方人”（亚科马族）和“北方人”（格巴亚族）之间的关系紧张，军政府也不断推迟着选举计划。\n在这一情况下，中非也并不缺乏反对派。前总理、民粹主义者昂热-费利克斯·帕塔塞于1978年在巴黎成立了中左翼的反对党“中非人民解放运动”，帕塔塞曾反对博卡萨政权，并认为达科重建共和国后的选举不公正（他在那次选举位列第二），而现在，他也反对科林巴的腐败军政府，如今，该组织已经争取了弗朗索瓦·博齐泽将军等少数中非现政权军官的支持，正在准备政变计划。阿贝尔·贡巴领导的乌班吉爱国阵线/劳动党也仍在积极反对中非现政权，为实现民族解放、摆脱新殖民主义统治也采取了许多斗争，"
const TXT_DESC_WEAK := "不过，该组织是否有足够力量掌权仍待商榷。"
const TXT_DESC_STRONG := "并已经渗透了国家机器。"
const TXT_DESC_TAIL := "\n现在正是我们干预中非的时候！"

const TXT_OPT0 := "让我们支持帕塔塞的政变计划"
const TXT_OPT0_DIS := "我们不能把手伸那么远！"
const TXT_OPT1 := "反对派团结起来！让我们串联反对派共抗法帝走狗"
const TXT_OPT1_DIS := "我们无能为力了"
const TXT_OPT2 := "让我们提醒一下科林巴总统帕塔塞的政变计划"
const TXT_OPT2_DIS := "我们做不到那个！"
const TXT_OPT3 := "这地方没什么好干预的"

const TXT_R0 := "我们联络了帕塔塞，表示愿意向他提供支持，他欣然接受。很快，中非人民解放运动发动了政变，帕塔塞指控科林巴犯了叛国罪，并在广播公告中宣布中非权力更迭。由于我们与苏丹的较好关系，我们涂着棕色迷彩的中共中央警卫团得以经苏丹抵达中非并空降班吉，与博齐泽将军进行里应外合，成功推翻了军政府，并将科林巴逮捕。新成立的中非人民解放运动领导的民族团结临时政府宣布将结束法帝国主义在中非肆意妄为的历史，扩大与我们的合作，为了彰显自身恢复民主化的功劳，新政府合法化了乌班吉爱国阵线/劳动党。"
const TXT_R1 := "在我们的施压和调解下，两派力量就推翻军政府达成了共识。通过发动总罢工和组建武装民兵，乌班吉爱国阵线/劳动党的军人地下党员在班吉发动了政变，并在广播公告中宣布中非权力更迭。通过发动总罢工和组建武装民兵，爱国阵线/劳动党的力量和军政府的部队在班吉直接进行了巷战。与此同时，中非人民解放运动也发动了政变，帕塔塞指控科林巴犯了叛国罪。博齐泽将军也里应外合，最终，军政府成功被推翻，科林巴也被逮捕。阿贝尔·贡巴宣告了中非人民共和国的成立。克劳德-理查德·古昂加被选为民族团结政府主席，阿贝尔·贡巴被选为总统并继续作为乌班吉爱国阵线/劳动党的领导人，希莱尔·科塔林博拉被选为政府总理，被称为“卢蒙巴的缪斯”的安德蕾·玛德琳·布鲁安被选为副总理，负责妇女革命工作，昂热-费利克斯·帕塔塞则被选为人民议会主席。新政府宣布将在马克思主义和泛非主义的道路上建设新中非，结束法帝国主义在中非肆意妄为的历史，扩大与我们的合作。"
const TXT_R2 := "我们向班吉打了一通电话，告诉科林巴总统应该警惕政变。科林巴随即加强了布防，并在军队中逮捕了一群不忠的军官。而发现情况有变的帕塔塞选择终止计划，秘密离开了中非。科林巴将军感谢我们的支持，并宣布与我们签订了一系列合作协定。四天后，帕塔塞在乔装打扮后前往法国驻班吉大使馆寻求庇护。在科林巴政府与法国进行激烈谈判后，帕塔塞被允许流亡多哥；而博齐泽将军带着100名士兵逃往该国北部，然后前往法国避难。乌班吉爱国阵线/劳动党的力量并不足以撼动政权。1982年8月，阿贝尔·贡巴等一批爱国阵线的成员被指控参与阴谋并被捕。他们未经审判便被关押。1983年4月21日，司法部长西尔维斯特·扬戈将军，匆忙安排了一场闹剧般的审判，让贡巴和恩吉姆翁古在特别法庭受审，以平息国际社会的舆论压力。1983年4月，特别法庭在证据不足的情况下作出判决，判处乌班吉爱国阵线/劳动党两位领导人每人5年监禁，罪名是与外国人士保持联系并试图建立革命组织。被监禁的贡巴，比以往任何时候都更像是反对独裁的象征。而此时，政权更加专制，来自不同国家的数百名民主人士，通过“支持中非所有政治犯委员会”，要求释放被关押的政治犯。这些行动都未能撼动政权，看来，科林巴仍将稳坐钓鱼台一段时间。"
const TXT_R3 := "中非人民解放运动发动了政变，帕塔塞指控科林巴犯了叛国罪，并在广播公告中宣布中非权力更迭。虽然帕塔塞获得了弗朗索瓦·博齐泽将军等少数军官的帮助，但政变没有成功，被科林巴击退了。四天后，帕塔塞在乔装打扮后前往法国驻班吉大使馆寻求庇护。在科林巴政府与法国进行激烈谈判后，帕塔塞被允许流亡多哥；而博齐泽将军带着100名士兵逃往该国北部，然后前往法国避难。乌班吉爱国阵线/劳动党的力量并不足以撼动政权。1982年8月，阿贝尔·贡巴等一批爱国阵线的成员被指控参与阴谋并被捕。他们未经审判便被关押。1983年4月21日，司法部长西尔维斯特·扬戈将军，匆忙安排了一场闹剧般的审判，让贡巴和恩吉姆翁古在特别法庭受审，以平息国际社会的舆论压力。1983年4月，特别法庭在证据不足的情况下作出判决，判处乌班吉爱国阵线/劳动党两位领导人每人5年监禁，罪名是与外国人士保持联系并试图建立革命组织。被监禁的贡巴，比以往任何时候都更像是反对独裁的象征。而此时，政权更加专制，来自不同国家的数百名民主人士，通过“支持中非所有政治犯委员会”，要求释放被关押的政治犯。这些行动都未能撼动政权，看来，科林巴仍将稳坐钓鱼台一段时间。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var r582 := int(world.completed_event_ids.get("event_582", 0))
	var desc := TXT_DESC_A
	if r582 != 1:
		desc += TXT_DESC_WEAK
	else:
		desc += TXT_DESC_STRONG
	desc += TXT_DESC_TAIL
	event_def.description = desc
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 3
	var c53 := world.get_country_by_legacy_index(53)
	var c52 := world.get_country_by_legacy_index(52)
	var opt := event_def.options
	if line <= 2 and world.influence_prc >= 500 and _tech(24) and c53 != null and c53.has_tag("对华贸易"):
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line <= 1 and world.influence_prc >= 500 and r582 == 1 and world.is_socialism(c52, true):
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line > 1:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	_enable(opt[3], TXT_OPT3)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c65 := ws.get_country_by_legacy_index(65)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			if c65 != null:
				c65.government = 2
				c65.sub_government = 3
				_leave_alliances(c65)
				c65.set_tag("亲中", true)
				c65.set_tag("对华贸易", true)
			ws.influence_prc += 40
			_add(W.I_DIPLO, 15)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			if c65 != null:
				c65.government = 1
				c65.sub_government = 1
				_leave_alliances(c65)
				c65.set_tag("亲中", true)
				c65.set_tag("对华贸易", true)
				c65.chinese_name = "中非人民共和国"
			ws.influence_prc += 40
			_add(W.I_DIPLO, 15)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_AGENTS, -50)
			if c65 != null:
				c65.government = 0
				c65.sub_government = 7
				_leave_alliances(c65)
				c65.set_tag("对华贸易", true)
				c65.puppet_of = 21
			context["result_text"] = TXT_R2
		3:
			context["result_text"] = TXT_R3


func _tech(idx: int) -> bool:
	return ws.techs != null and ws.techs.unlocked.size() > idx and ws.techs.unlocked[idx]
