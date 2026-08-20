extends "res://数据脚本/event_script_base.gd"

## 原作 Event490.cs：让多瑙河倒流？（罗马尼亚反齐奥塞斯库政变，三选项）。
## 触发：TimeScript.cs:10628-10635 ——
##   ((年>=1984 月>=10 日>=15) || (年>=1984 月>=11) || 年>=1985)
##   && event_done[79] && resultOfEvents[79]>2 && !c5.isNATO
##   （result>2 = 结果3 或 4，.tres 用 ANY(==3, ==4) 表达）。
## 差异：
##  - 描述按 resultOfEvents[79]==3 分支拼接（prepare）。
##  - OilProd 已建模（ws.oil_prod），result1 炼油技术转让 +100；result0 三路政权分支逐字保留。
##  - IsSocialism(true,1) → world.is_socialism(c1, true)；
##    result79!=3 分支用 influence_prc > empires[1].power。

const TXT_R0_OPEN := "在我方的情报协调下，政变团体清除了戈莫伊乌将军和波帕将军两位叛徒，并获得了内政部部队参谋长杜米特鲁·彭丘克上校和负责秘密警察部门的行动工作的平古列斯库上校等人的支持。在齐奥塞斯库访问西德时，忠于政变者的部队迅速发起行动，控制了广播电视机构，并占领了国防部、安全局、机场和中央委员会大楼，期间还发生了交火。"

const TXT_MINERS := "此前联系的工人也组织了武装矿工民兵进入布加勒斯特帮助政变方。"

const TXT_A1 := "在我方情报部门协助政变者们控制住局势后，政变团体将因齐奥塞斯库边缘化而丧失中央委员席位的党内要员组成的“特邀代表”和中央委员们从全国空运至布加勒斯特，一场罗共中央特别全会迅速召开。格奥尔基·阿波斯托尔在会上严厉批判现政府“漠视党内民主，大搞家族政治，疯狂挥霍资产，生育政策及其不负责任，经济政策不当，紧缩政策伤害人民感情，资产阶级民族主义肆虐且同帝国主义者合作，使得罗马尼亚陷入了严重的修正主义泥潭。”他提议全会解除齐奥塞斯库及其亲信的一切职务。这一提议得到了大部分与会者的支持。最终，大会以多数票罢免了不愿退休的齐奥塞斯库，并将其开除出党，回国后送入法庭审判。他的妻子埃列娜、长子尼库、密友扬·丁卡与埃米尔·博布、以及现任总理康斯坦丁·德斯克列斯库等亲信也被驱逐出党，他们一起被控“参与腐败、建构裙带关系、破坏罗马尼亚经济并将人民拽入贫困深渊”。他们均被法庭判处有罪，最高可处有期徒刑20年。格奥尔基·阿波斯托尔则被一致选举为罗共中央委员会新任总书记，亚历山德鲁·伯尔勒迪亚努被任命为总理。大会后，新任领导人向人民承诺将在一年内结束紧缩政策。我们为罗马尼亚提供了一批经济援助，他们正在向好的一面发展。"

const TXT_A2 := "在我方情报部门协助政变者们控制住局势后，政变团体将因齐奥塞斯库边缘化而丧失中央委员席位的党内要员组成的“特邀代表”和中央委员们从全国空运至布加勒斯特，一场罗共中央特别全会迅速召开。扬·伊利埃斯库在会上严厉批判现政府“漠视党内民主，大搞家族政治，疯狂挥霍资产，生育政策及其不负责任，经济政策不当，紧缩政策伤害人民感情，资产阶级民族主义肆虐且作风专横，使得罗马尼亚陷入了严重的短缺经济和新斯大林主义泥潭。”他提议全会解除齐奥塞斯库及其亲信的一切职务。这一提议得到了大部分与会者的支持。最终，大会以多数票罢免了不愿退休的齐奥塞斯库，并将其开除出党，回国后送入法庭审判。他的妻子埃列娜、长子尼库、密友扬·丁卡与埃米尔·博布、以及现任总理康斯坦丁·德斯克列斯库等亲信也被驱逐出党，他们一起被控“参与腐败、建构裙带关系、破坏罗马尼亚经济并将人民拽入贫困深渊”。他们均被法庭判处有罪，最高可处有期徒刑20年。扬·伊利埃斯库则被一致选举为罗共中央委员会新任总书记，伊利耶·维尔德茨则重回总理之位。大会后，新任领导人向人民承诺将在一年内结束紧缩政策。我们为罗马尼亚提供了一批经济援助，他们正在向好的一面发展。"

const TXT_A3 := "在我方情报部门、克格勃和格鲁乌协助政变者们控制住局势后，政变团体将因齐奥塞斯库边缘化而丧失中央委员席位的党内要员组成的“特邀代表”和中央委员们从全国空运至布加勒斯特，一场罗共中央特别全会迅速召开。尼古拉·米利塔鲁在会上严厉批判现政府“漠视党内民主，大搞家族政治，疯狂挥霍资产，生育政策及其不负责任，经济政策不当，紧缩政策伤害人民感情，资产阶级民族主义肆虐且同帝国主义者合作，使得罗马尼亚孤立于社会主义大家庭。”他提议全会解除齐奥塞斯库及其亲信的一切职务。这一提议得到了大部分与会者的支持。最终，大会以多数票罢免了不愿退休的齐奥塞斯库，并将其开除出党，回国后送入法庭审判。他的妻子埃列娜、长子尼库、密友扬·丁卡与埃米尔·博布、以及现任总理康斯坦丁·德斯克列斯库等亲信也被驱逐出党，他们一起被控“参与腐败、建构裙带关系、破坏罗马尼亚经济并将人民拽入贫困深渊”。他们均被法庭判处有罪，最高可处有期徒刑20年。尼古拉·米利塔鲁则被一致选举为罗共中央委员会新任总书记，扬·伊利埃斯库被任命为总理，早年支持基希涅夫斯基-康斯坦丁内斯库集团且反对赫鲁晓夫撤军的党内元老康斯坦丁·珀尔伏列斯库被推举为新总统，他的高龄和缺乏实权使其注定只能成为米利塔鲁的合法性象征。大会后，新任领导人向人民承诺将在1年内结束紧缩政策。我们和苏联为罗马尼亚提供了一批经济援助，他们正在向好的一面发展。"

const TXT_R1 := "我们的大使馆将所知的政变成员名单交给了齐奥塞斯库同志，他感谢了我们的帮助。总统决定推迟访问西德的计划，坐镇布加勒斯特亲自部署和指挥对反革命阴谋集团的搜捕行动。扬·伊利埃斯库、尼古拉·米利塔鲁、扬·约尼查将军、亚诺什·法泽卡什、西尔维乌·布鲁坎、斯特凡·科斯蒂亚尔和尼古拉·拉杜等参与者都被抓捕入狱，密谋团体遭受重创。与此同时，我方利用与罗马尼亚的良好关系，主动向齐奥塞斯库总统提出，帮助罗马尼亚重新谈判欠下的债务条款，进行债务重组，以延长还款期限，降低利率，甚至直接免除一部分债务。与此同时，我们还以远低于市场利率的条件为其提供了一笔新的贷款，专门用于稳定其经济。我方承诺购买罗马尼亚的特色商品和工业制成品，并为其提供优惠的市场准入条件，直接为其创造外汇收入，刺激国内生产。我们还向罗马尼亚提供了一批粮食支援和轻工业制成品，缓解其民生供应问题。齐奥塞斯库感谢了我们的帮助，他利用进口机会扩大了与我们的贸易。作为交换，他向我们转让了引进自西方的炼油技术、汽车工业技术以及IAR-93“鹰”式攻击机的全套图纸和技术资料等科技成果。最终，罗马尼亚大幅放松了紧缩政策，并在外交上越发靠近我们的立场。\n尽管清洗了党内反对派，但齐奥塞斯库对党内越发缺乏信任和安全感，其家族成员和亲密战友“知识分子集团”在党内的地位不断提高，围绕齐奥塞斯库夫妇的个人崇拜正进一步加强，安全局对社会的监控程度也上升了……"

const TXT_R2 := "参与行动的主要部队驻扎在布加勒斯特，作为政变参与者之一的利奥特·科隆·扬·苏切亚维中校已成功控制了蒂尔戈维泰镇的军火库。但是，政变者指望的部队被当局派去收割玉米，使得行动不得不中止。科斯蒂亚尔被捕并关押在阿尔盖什区的住宅，以及米利塔鲁和约尼查在中央委员会大楼接受政治局成员埃米尔·博布和国家安全局局长图多尔·波斯特尔尼库的审讯。通过审讯，两位将军意识到博布和波斯特尔尼库对他们的计划知之甚少，最终仅被警告不得再见面便获释。米利塔鲁认为，这一行动的失败绝非偶然，而是戈莫伊乌将军和波帕将军背叛的结果。\n密谋团体似乎并没有被消灭，齐奥塞斯库的统治目前依旧安好，谁知道未来会如何……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var result79: int = world.completed_event_ids.get("event_079", -1)
	var desc := "长期执掌罗马尼亚大权的齐奥塞斯库以挥霍巨额外债的方式将政府拉入紧缩政策泥潭。该国生活标准也就此跳水：人们一边过着食物凭粮票供应，限制用电、用气和用油的好日子；一边则享受更多工作日。全国正以“节衣缩食”与“多子多福”两大政策为纲。于此同时，齐奥塞斯库仍然没有放弃旧的经济和政治路线，照常建设大型项目，其家族成员的权势和“知识分子集团”的地位正不断垄断党内权力，大兴个人崇拜。然而，并不是所有党员都认可当局的现行政策。另一方面，苏联也对罗马尼亚在苏东阵营中的独立地位感到不满，甚至还存在格鲁乌扶持亲苏军官密谋政变的传言。对此，齐奥塞斯库夫妇则只是拴紧螺丝，积极打压，试图让其彻底出局。\n据了解，"
	if result79 == 3:
		desc += "我们之前组织的罗共秘密团体已经准备好行动了，"
	else:
		desc += "罗共异见党员已经组织了一个阴谋团体，其成员包含在任内批评总统喜好在庞大而低效的项目上浪费开支而被送去“国家水务委员会主席”冷板凳的扬·伊利埃斯库、因有“通苏反齐”嫌疑而被退役转任工业建设部副部长的尼古拉·米利塔鲁将军、被齐奥塞斯库转入预备役的前国防部长、前副总理扬·约尼查将军、民族主义批评者亚诺什·法泽卡什、反对齐奥塞斯库的党内元老西尔维乌·布鲁坎、斯特凡·科斯蒂亚尔少将和海军上校尼古拉·拉杜等人，"
	desc += "他们计划于齐奥塞斯库访问西德期间发动政变，对国家进行拨乱反正。\n我们是否要做些什么？"
	event_def.description = desc
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var opt := event_def.options
	if world.influence_prc >= 600 and _tech(world, 25):
		_enable(opt[0], "是时候了，让多瑙河倒流吧！")
	else:
		_disable(opt[0], "齐奥塞斯库是不可动摇的，多瑙河也不可能倒流！")
	if line < 4 and world.influence_prc >= 300:
		_enable(opt[1], "多瑙河永远不会倒流，我们自然也不会背叛这位东欧朋友，支持齐奥塞斯库同志！")
	else:
		_disable(opt[1], "我们不会支持这个独裁者")
	_enable(opt[2], "不要干预罗马尼亚内政，让一切顺其自然")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var romania := ws.get_country_by_legacy_index(5)
	var result79: int = ws.completed_event_ids.get("event_079", -1)
	match opt:
		0:
			_add(W.I_BUDGET, -200)
			_add(W.I_AGENTS, -200)
			var text := TXT_R0_OPEN
			var china := ws.get_country_by_legacy_index(1)
			var mod6 := _mod_active(6)
			var china_sev := china != null and china.has_tag("sev")
			if result79 == 3 and china != null and ws.is_socialism(china, true) \
					and mod6 and not china_sev:
				text += TXT_MINERS + TXT_A1
				if romania != null:
					romania.government = 1
					romania.sub_government = 2
					romania.set_tag("对华贸易", true)
					romania.set_tag("亲苏", false)
					romania.set_tag("亲中", true)
				_add_relation(EmpireData.USSR, -100)
				ws.influence_prc += 20
				context["result_text"] = text
				return
			var ussr_power := ws.empires[EmpireData.USSR].power if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null else 0
			if ((result79 == 3 and china != null and china.government == 2) \
					or (result79 != 3 and ws.influence_prc > ussr_power)) and not china_sev:
				if result79 == 3:
					text += TXT_MINERS
				text += TXT_A2
				if romania != null:
					romania.government = 2
					romania.sub_government = 21
					romania.set_tag("对华贸易", true)
					romania.set_tag("亲苏", false)
					romania.set_tag("亲中", true)
				_add_relation(EmpireData.USSR, -100)
				ws.influence_prc += 20
				_ussr_leader_add(6, 1)
				context["result_text"] = text
				return
			text += TXT_A3
			if romania != null:
				romania.government = 1
				romania.sub_government = 16
				romania.set_tag("对华贸易", true)
				romania.set_tag("亲苏", true)
				romania.set_tag("亲中", false)
				romania.set_tag("balecon", false)
			_add_relation(EmpireData.USSR, 100)
			_add_power(EmpireData.USSR, 20)
			_ussr_leader_add(4, 1)
			context["result_text"] = text
		1:
			_add(W.I_DIPLO, 10)
			_add(W.I_BUDGET, -300)
			_add(W.I_AGENTS, -100)
			if romania != null:
				romania.set_tag("对华贸易", true)
				romania.set_tag("亲中", true)
			_add(W.I_SCIENCE, 200)
			ws.oil_prod += 100.0  # Event490.cs result1：炼油技术转让
			context["result_text"] = TXT_R1
		2:
			context["result_text"] = TXT_R2


func _tech(world: WorldState, index: int) -> bool:
	return world.techs != null and world.techs.unlocked.size() > index and world.techs.unlocked[index]


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() \
		and ws.modifiers[index] != null and ws.modifiers[index].is_active


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








func _ussr_leader_add(index: int, delta: int) -> void:
	if ws.empires.size() <= EmpireData.USSR or ws.empires[EmpireData.USSR] == null:
		return
	var leaders: Array[EmpireLeader] = ws.empires[EmpireData.USSR].leaders
	if index >= 0 and index < leaders.size() and leaders[index] != null:
		leaders[index].support += delta
