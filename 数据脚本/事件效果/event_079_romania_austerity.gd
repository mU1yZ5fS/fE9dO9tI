extends "res://数据脚本/event_script_base.gd"

## 原作 Event79.cs：紧缩政策（罗马尼亚债务危机，五选项）。
## 触发：TimeScript.cs:10620-10626 —— data.year>=1982。
## 差异：
##  - 选项显隐 prepare 动态改写（原版 SetActive(false) 等价）。
##  - science[16]/science[25] → ws.techs.unlocked 下标（tech_state.gd）。
##  - OilProd 已建模（ws.oil_prod），result0 炼油技术转让 +100。
##  - result2：原版 ResultsOfEvents 没有 result_num==2 分支（可点但无文案无效果），
##    逐字保留该行为（result_text 空串）。

const TXT_R0 := "我方利用与罗马尼亚的良好关系，主动向齐奥塞斯库总统提出，帮助罗马尼亚重新谈判欠下的债务条款，进行债务重组，以延长还款期限，降低利率，甚至直接免除一部分债务。与此同时，我们还以远低于市场利率的条件为其提供了一笔新的贷款，专门用于稳定其经济。我方承诺购买罗马尼亚的特色商品和工业制成品，并为其提供优惠的市场准入条件，直接为其创造外汇收入，刺激国内生产。我们还向罗马尼亚提供了一批粮食支援和轻工业制成品，缓解其民生供应问题。齐奥塞斯库感谢了我们的帮助，他利用进口机会扩大了与我们的贸易。作为交换，他向我们转让了引进自西方的炼油技术、汽车工业技术以及IAR-93“鹰”式攻击机的全套图纸和技术资料等科技成果。最终，罗马尼亚大幅放松了紧缩政策，并在外交上越发靠近我们的立场。根据我们的估计，在这样的速度下他在80年代末可以还清债务，并且不会对经济和生活质量产生严重影响。齐奥塞斯库的家族成员及其亲密战友“知识分子集团”在党内的地位正越发稳固，围绕齐奥塞斯库夫妇的个人崇拜正不断加强……"

const TXT_R1 := "我方利用与罗马尼亚的良好关系，主动向齐奥塞斯库总统提出，帮助罗马尼亚重新谈判欠下的债务条款，进行债务重组，以延长还款期限，降低利率，甚至直接免除一部分债务。与此同时，我们还以远低于市场利率的条件为其提供了一笔新的贷款，专门用于稳定其经济。我方承诺购买罗马尼亚的特色商品和工业制成品，并为其提供优惠的市场准入条件，直接为其创造外汇收入，刺激国内生产。我们还向罗马尼亚提供了一批粮食支援和轻工业制成品，缓解其民生供应问题。齐奥塞斯库感谢了我们的帮助，他利用进口机会扩大了与我们的贸易。在{0}{1}同志的亲自通电话劝说下，齐奥塞斯库决定改进罗马尼亚的经济模式，引入我国先进的计算机技术，开展集约化，加强职业技术培养，将国内的企业改组为产-研联合体，以技术革新带动经济转型。齐奥塞斯库的支持者，经济学家和控制论专家马尼亚·曼内斯库被重新任命为总理，他将扩大对高新技术的投资，带领罗马尼亚开展电子化和自动化，建设有控制论特色的社会主义。自动化的采纳也让诟病颇多的770法案被逐步取消，取而代之的是经济补贴等鼓励生育的新方法。齐奥塞斯库感谢了我们的帮助，他利用进口机会扩大了与我们的贸易。作为交换，他向我们转让了引进自西方的炼油技术、汽车工业技术以及IAR-93“鹰”式攻击机的全套图纸和技术资料等科技成果。最终，罗马尼亚大幅放松了紧缩政策，并在外交上越发靠近我们的立场。根据我们的估计，在这样的速度下他在80年代末可以还清债务，并且不会对经济和生活质量产生严重影响。技术官僚在罗马尼亚党内的地位和作用正在上升。"

const TXT_R2 := "{0}{1}同志亲自致电勃列日涅夫，说罗马尼亚的局势将会直接威胁该国社会主义建设的事业以及整个东方集团的稳定，因此需要动员整个社会主义阵营来解决这一问题。苏联领导人支持了我们的观点，结果举行了一场经互会的特别会议，会议决定以无息贷款、向罗马尼亚提供了优惠物资，专门用于稳定其经济，并以高价收购罗马尼亚的出口产品和罗马尼亚向经互会提供进出口优惠条件的形式，直接为其创造外汇收入，刺激其国内生产，以此协助罗马尼亚偿还债务（当然，主要的开销由我们和苏联承担）。我们还向罗马尼亚提供了一批粮食支援和轻工业制成品，缓解其民生供应问题。齐奥塞斯库感谢了我们的帮助，他利用进口机会扩大了与我们的贸易。作为交换，他向我们转让了引进自西方的炼油技术、汽车工业技术以及IAR-93“鹰”式攻击机的全套图纸和技术资料等科技成果。最终，罗马尼亚大幅放松了紧缩政策，并在外交上越发靠近社会主义阵营的立场。与此同时，在我方和苏方的劝说下，齐奥塞斯库最终在援助的打动下采纳了总理伊利耶·维尔德茨的建议，同意改进罗马尼亚的经济制度，提高其灵活性和效率，进行一定程度的权力下放，给予企业一定自主权。齐奥塞斯库感谢了我们和其他经互会成员对他的帮助，并已经宣布了旨在大幅放松紧缩政策的调整，其对经互会的参与程度重新加深了。根据我们的估计，在这样的速度下他在80年代末可以还清债务，并且不会对经济和生活质量产生严重影响。罗共温和派的“党务机构集团”成员在党内的地位和作用正在上升。"

const TXT_R3 := "在驻罗马尼亚大使馆和特勤部门的运作下，我们秘密联系到了在任内批评总统喜好在庞大而低效的项目上浪费开支而被送去“国家水务委员会主席”冷板凳的扬·伊利埃斯库、因有“通苏反齐”嫌疑而被退役转任工业建设部副部长的尼古拉·米利塔鲁将军、被齐奥塞斯库不断边缘化的前国防部长和副总理扬·约尼查将军和反对齐奥塞斯库的党内元老西尔维乌·布鲁坎等人，令人意外的是，他们此前已经纠集部分退役军官、边缘化的文官和安全部门前成员组成了几个秘密反齐异见团体。不久后，罗马尼亚驻阿根廷和乌拉圭大使格奥尔基·阿波斯托尔、前副总理和经济学家亚历山德鲁·伯尔勒迪亚努、罗马尼亚驻法大使科尔内留·曼内斯库、前大国民议会主席康斯坦丁·珀尔伏列斯库、因支持独立自主路线而多次入狱的格雷戈里·扬·勒强努、前中央书记处书记亚历山德鲁·德勒吉奇、在任内批评总统的冒进政策和个人专断而被送去领导全国合作社工作的理论家保罗·尼古列斯库-米齐尔、前副总理和经济学家格奥尔基·加斯顿-马林等党内要员已经在我们的帮助下参与进来，共同组建囊括所有反齐异见者的团体，并加大对军队和安全部门的渗透。在我们的帮助下，他们还同九谷罢工工人和罗马尼亚劳动人民自由工会的一些活动家建立了联系。一场政变正在紧锣密鼓地筹划……\n另一边，罗马尼亚政府决定削减进口与政府预算，同时扩大主要商品的出口，如石油与粮食。这导致住房，医疗与文教系统的拨款锐减，以及人民收入的降低。在人民福利被不断削减的同时，主要商品如食物，服装等均出现价格的上涨，某些地区因粮食的短缺不得不实行限量配给。尽管作为产油国，罗马尼亚的工业与民用能源供给均被严重缩减，前者导致了工业的退化，而后者则激化了人民的不满。燃料也被严格配给，供电与供暖甚至都以低效率运转。尽管这些措施具有盈利能力，但它们已经导致罗马尼亚经济发展逐渐停滞和生活水平下降，这导致罗马尼亚人民普遍不满。谁知道这会怎样结束……"

const TXT_R4 := "为此，罗马尼亚政府决定削减进口与政府预算，同时扩大主要商品的出口，如石油与粮食。这导致住房，医疗与文教系统的拨款锐减，以及人民收入的降低。在人民福利被不断削减的同时，主要商品如食物，服装等均出现价格的上涨，某些地区因粮食的短缺不得不实行限量配给。尽管作为产油国，罗马尼亚的工业与民用能源供给均被严重缩减，前者导致了工业的退化，而后者则激化了人民的不满。燃料也被严格配给，供电与供暖甚至都以低效率运转。尽管这些措施具有盈利能力，但它们已经导致罗马尼亚经济发展逐渐停滞和生活水平下降，这导致罗马尼亚人民普遍不满。谁知道这会怎样结束……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 1
	var party := data.party_system if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 3 and party < 8) or (coal > 66 and party > 7)
	var china := world.get_country_by_legacy_index(1)
	var done503: bool = world.completed_event_ids.has("event_503")
	var result503: int = world.completed_event_ids.get("event_503", -1)
	var opt := event_def.options
	if policy_left:
		_enable(opt[0], "向我们的老朋友提供援助，这是国际主义精神！")
	else:
		_disable(opt[0], "罗马尼亚不值得我们做这么多")
	if policy_left and world.influence_prc >= 400 and _tech(world, 16):
		_enable(opt[1], "向我们的老朋友提供援助的同时，建议齐奥塞斯库同志适当改变政策，用科技革命为罗马尼亚经济注入新动力")
	else:
		_disable(opt[1], "没有必要这么做")
	if world.influence_prc >= 300 and china != null and china.has_tag("sev"):
		_enable(opt[2], "我们将发扬社会主义大家庭的团结精神，号召社会主义阵营共同帮助罗马尼亚")
	else:
		_disable(opt[2], "社会主义阵营不会听我们的")
	if world.influence_prc >= 500 and _tech(world, 25) and (not done503 or result503 != 0):
		_enable(opt[3], "不能让齐奥塞斯库胡作非为下去了，开始联系罗马尼亚党内异见分子")
	else:
		_disable(opt[3], "我们不能这么对待好朋友！")
	_enable(opt[4], "让他独立自主地还债，这不是我们的问题")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var romania := ws.get_country_by_legacy_index(5)
	var opt := int(context.get("option_index", -1))
	var leader_name := _leader_name()
	match opt:
		0:
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USSR, -50)
			_add(W.I_BUDGET, -300)
			ws.influence_prc += 10
			if romania != null:
				romania.set_tag("对华贸易", true)
				romania.set_tag("亲中", true)
				romania.government = GameConstants.Government.AUTHORITARIAN
				romania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			_add(W.I_SCIENCE, 200)
			ws.oil_prod += 100.0  # Event79.cs result0：炼油技术转让
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -150)
			_add_power(EmpireData.USSR, 30)
			ws.influence_prc += 30
			if romania != null:
				romania.set_tag("对华贸易", true)
			_add(W.I_SCIENCE, 200)
			_ussr_leader_add(4, 1)
			context["result_text"] = TXT_R1.replace("{0}{1}", leader_name)
		2:
			# 原版 Event79.cs result2：号召经互会共同援助罗马尼亚（含文案与效果）。
			_add(W.I_BUDGET, -150)
			_add_power(EmpireData.USSR, 30)
			ws.influence_prc += 30
			if romania != null:
				romania.set_tag("对华贸易", true)
			_add(W.I_SCIENCE, 200)
			_ussr_leader_add(4, 1)
			context["result_text"] = TXT_R2.replace("{0}{1}", leader_name)
		3:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_ARMY, -150)
			if romania != null:
				romania.government = GameConstants.Government.AUTHORITARIAN
				romania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = TXT_R3
		4:
			if romania != null:
				romania.government = GameConstants.Government.AUTHORITARIAN
				romania.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			context["result_text"] = TXT_R4


func _coalition_percent(world: WorldState) -> int:
	var data := world
	if data.size() <= W.I_PARTY_SYSTEM or data.party_system <= 7:
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


func _tech(world: WorldState, index: int) -> bool:
	return world.techs != null and world.techs.unlocked.size() > index and world.techs.unlocked[index]




func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
