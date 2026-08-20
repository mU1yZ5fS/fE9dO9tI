extends "res://数据脚本/event_script_base.gd"

## 原作 Event684.cs：新跃进？（引进外资与十年规划，四选项）。
## 触发：TimeScript.cs:10325-10330 ——
##   (月>=12 且 年>=1977 或 年>=1978) && (resultOfEvents[25]!=2 || resultOfEvents[26]!=2)
##   → .tres 用 NOT(ALL(25==2, 26==2)) 等价表达。
## 差异：
##  - 选项1 原版按 empires[1].relations>=500 销毁按钮，prepare 动态改写。
##  - 结果文本 {0}{1}（原版 names1+names2 无空格拼接）插 ws.leader.name_display。
##  - party_ideology 三个分支是三个独立 if（20→faction1、1→faction2、2→faction3），逐字保留。

const TXT_R0 := "我们的倡议很快便正中不少国家下怀：考虑到目前冷战局势处于低潮，超级大国间趋于缓和，美苏均无围堵中国的精力与闲情；而在经济方面，西方国家刚刚从经济萧条中走出，空闲资金较多，急需扩大海外市场，为引资提供了动机。这一切使得1978年出访的中国代表团所到之处，西方官员和商人都表现了愿意同中国发展经济合作的强烈意向。在和法国总统德斯坦会谈时，法国驻华大使对谷牧说，听说你们要搞120个大项目，我们法国很愿意有所贡献，给我们10个行不行？在西德，巴符州州长说可以贷款50亿美元给中国，马上可以签字，北威州表示100亿美元也问题不大。如此局势自然让我国领导人被胜利冲昏头脑，并促使国内基本形成加大引进技术的基本观点：在日后国务院务虚会上，{0}{1}同志再次强调要比原来设想更快的速度实现四个现代化（即10年规划要修改调整，中国有条件加快现代化速度，在引进问题上要思想再解放一点，胆子再大一点，办法再多一点，步子再快一点）随后，国家计委推翻了1977年支出65亿美元外汇，基建投资400亿美元的计划；转而初步汇总了个850亿美元的计划，其中400亿美元准备向外国借款；并将1978年至1985年引进规模由原来的65亿美元增加到180亿美元。计划本身自然出现了急于求成倾向。1978年全年78亿美元协议金额中，有一半左右金额是在12月20日到年底的短短10天里抢签的合同。这么多大项目同时引进，对国家财力是很大负担，对整个国民经济也是很大冲击。而投资所造成的产业发展不平衡、对技术的囫囵吞枣式引进与消化缓慢，乃至变现能力不足等问题也将在此后暴露出来：热血上头的无效投资与随之背上的债务将成为日后经济改革所无法绕开的主题……"

const TXT_R1 := "考虑到目前冷战局势处于低潮，超级大国间趋于缓和，美苏均无围堵中国的精力与闲情；而在经济方面，绝大多数国家也正因石油危机导致的生产成本提高而遭受萧条，急需出口创汇、资金变现与偿还新一轮周期的国际货币基金组织贷款。这一切使得1978年出访的中国代表团所到之处，东欧官员和商人都表现了愿意同中国发展经济合作的强烈意向。我们通过罗马尼亚总统齐奥塞斯库与波兰、匈牙利等国牵线搭桥，商谈合作与技术转让方案。甚至取得了意料之外的收获：一方面，东德方面的官员表示将通过第三方渠道联系西德，建立跨国现金流（他们称在西德，巴符州州长说可以贷款50亿美元给中国，马上可以签字，北威州表示100亿美元也问题不大）；另一方面，我们甚至得到了苏联领导层的青睐：该国的“经济沙皇”柯西金直截了当地表示很愿意有所贡献，并要求拿下其中的六分之一。如此局势自然让我国领导人被胜利冲昏头脑，并促使国内基本形成加大引进技术的基本观点：在日后国务院务虚会上，{0}{1}同志再次强调要比原来设想更快的速度实现四个现代化（即10年规划要修改调整，中国有条件加快现代化速度，在引进问题上要思想再解放一点，胆子再大一点，办法再多一点，步子再快一点）随后，国家计委推翻了1977年支出65亿美元外汇，基建投资400亿美元的计划；转而初步汇总了个850亿美元的计划，其中400亿美元准备向外国借款；并将1978年至1985年引进规模由原来的65亿美元增加到180亿美元。计划本身自然出现了急于求成倾向。1978年全年78亿美元协议金额中，有一半左右金额是在12月20日到年底的短短10天里抢签的合同。这么多大项目同时引进，对国家财力是很大负担，对整个国民经济也是很大冲击。而投资所造成的产业发展不平衡、对技术的囫囵吞枣式引进与消化缓慢，乃至变现能力不足等问题也将在此后暴露出来：热血上头的无效投资与随之背上的债务将成为日后经济改革所无法绕开的主题……"

const TXT_R2 := "1973年1月5日，国家计委提交《关于增加设备进口、扩大经济交流的请示报告》，对前一阶段和今后的对外引进项目做出总结和统一规划，建议今后3～5年内引进43亿美元的成套设备。这被通称为“43方案”，是继“156项”后的第二次大规模引进计划，也是打破“文革”时期经济被孤立局面的一个重大步骤。以后在此方案基础上又陆续追加了一批项目，计划进口总额达到51.4亿美元。我们决定以此为基础重新审视《十年规划》：通过严选引进项目，控制外汇支出与贷款规模。我们得以将西方国家相对先进的一系列生产技术（如农业机械、化肥生产、彩电与钢铁生产）以较快速度与较低成本的方式引进国内。基础工业与农业生产也就此实现进一步巩固。"

const TXT_R3 := "《十年规划纲要》最终没能通过全国人大审核，转而被“调整、改革、整顿、提高”的系列方针所取代：显然是对60年代“调整、巩固、充实、提高”八字原则的致敬。在此背景下，国内开始了对各地物流、工厂、农矿、贸易等领域的整理：重点解决生产指标、物资供应与劳动纪律问题。为此，{0}{1}同志甚至开始要求效法75年整顿的邓小平系列方案，要求相关负责人充分发挥彼时处理经济问题时的各自经验——解决缺乏能力的、无法完成指标的、乃至在改组问题上畏手畏脚的。新经济体制事实上也就成为了一场变相的党内国内整风运动。不过，通过加强宏观调控与确保各类经济单位效率的方法确实卓有成效。我们得以借机处理“文革”时期冒出的一批地方副业，并建立对他们的基本管理体制，形成了一定程度的规模效应。下一步预计是实现全行业的集中制原则。中国经济仍在照常运行，波澜不惊。接下来会发生什么？等着瞧罢！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options[1]
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null \
			and world.empires[EmpireData.USSR].relations >= 500:
		opt.text = "钞票不会说谎，也许我们能将此作为与社会主义阵营复交的契机"
		opt.disabled_text = ""
		opt.enable_condition = null
	else:
		opt.text = "苏联可不会任我国与东欧诸国眉来眼去！"
		opt.disabled_text = opt.text
		opt.enable_condition = _never_node()


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var leader_name := _leader_name()
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, -40)
			_add(W.I_BUDGET, -100)
			_add(W.I_LOAN, 250)
			_add(W.I_INDUSTRY, 100)
			_add(W.I_SERVICES, 100)
			_add(W.I_LIVING, 70)
			_add(W.I_CORRUPTION, 50)
			_add(W.I_SCIENCE, 4000)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add_relation(EmpireData.USA, 100)
			_add_power(EmpireData.USA, 50)
			_adjust_politicians()
			context["result_text"] = TXT_R0.replace("{0}{1}", leader_name)
		1:
			_add(W.I_DIPLO, 10)
			_add(W.I_BUDGET, -100)
			_add(W.I_LOAN, 250)
			_add(W.I_INDUSTRY, 100)
			_add(W.I_SERVICES, 100)
			_add(W.I_LIVING, 70)
			_add(W.I_CORRUPTION, 50)
			_add(W.I_SCIENCE, 4000)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add_relation(EmpireData.USSR, 100)
			_add_power(EmpireData.USSR, 50)
			_adjust_politicians()
			context["result_text"] = TXT_R1.replace("{0}{1}", leader_name)
		2:
			_add(W.I_DIPLO, -10)
			_add(W.I_BUDGET, -20)
			_add(W.I_LOAN, 50)
			_add(W.I_INDUSTRY, 50)
			_add(W.I_AGRICULTURE, 70)
			_add(W.I_SCIENCE, 2000)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USA, 10)
			context["result_text"] = TXT_R2
		3:
			_add(W.I_AGRICULTURE, 30)
			_add(W.I_INDUSTRY, 20)
			_add(W.I_PARTY_SUPPORT, 50)
			if d.size() > W.I_ECON_SYSTEM and d[W.I_ECON_SYSTEM] == 11:
				d[W.I_ECON_SYSTEM] = 12
			if ws.factions.size() > 3:
				var personality := ws.leader.trait_personality if ws.leader != null else -1
				if personality == 20:
					ws.factions[1].ideology += 30
				elif personality == 1:
					ws.factions[2].ideology += 30
				if personality == 2:
					ws.factions[3].ideology += 30
			context["result_text"] = TXT_R3.replace("{0}{1}", leader_name)


## Event684.cs result0/1 共同政治家循环：
## traits[0]==leader.traits[0] → power-=200；else if traits[0]==2 → power+=200。
func _adjust_politicians() -> void:
	var leader_personality: int = ws.leader.trait_personality if ws.leader != null else -1
	for p in ws.politicians:
		if p == null or PoliticianSystem.is_vacant_politician(p):
			continue
		if p.trait_personality == leader_personality:
			p.power -= 200
		elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
			p.power += 200








func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _never_node() -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	return n
