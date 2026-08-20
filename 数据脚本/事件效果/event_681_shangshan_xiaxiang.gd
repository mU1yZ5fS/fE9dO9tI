extends "res://数据脚本/event_script_base.gd"

## 原作 Event681.cs：广阔天地，大有作为（上山下乡政策审决，五选项）。
## 触发：TimeScript.cs:10409-10415 —— (月>=12 且 年>=1978 或 年>=1979)。
## 差异：
##  - 5 个选项的文案/显隐按原版 VariantsOfEvents 动态改写（prepare）。
##  - 结果后的 old_modify_desc[15] 拼接是修正说明文案，Godot 由
##    ModifierCatalog 静态维护（modifier_catalog.gd EFFECT_ZH[15]），跳过。
##  - r2/r3/r4 的 {0}{1} 插领导人姓名（r0/r1 无占位符）。

const TXT_R0 := "考虑到目前中国仍将长期处于“欠发展且仍需长期发展”的特殊阶段，我们不能简单地废除这一政策：毕竟，国家还没有足够多的岗位吸纳如此巨量的待业人口；且农村也需要持之以恒地投入人才并加强建设。而“上山下乡”恰是其中相对成本最低的方案——况且，只要我们能够容忍其低下的附加收益，那它也不足以成为问题——毕竟，我们只是以一个小问题弥补了更多大问题而已！当然，延续这种保守主义态度只会让那些求变者感到不满：党员不满于我们事实上趋于停滞的农村政策，农村知青们也为国家缺乏对其劳动成果的回馈而趋于冷漠与失望。不论如何，属于“上山下乡”政策的黄金时代都已经结束了。"

const TXT_R1 := "您的决定不过是给逐渐衰退的“上山下乡”政策加速宣判死刑。自进入70年代以后，我国便开始允许知识青年以招工、考试、病退、顶职、独生子女、身边无人、工农兵学员等各种各样名目繁多的名义逐步返回城市。而这只是第一步。此后便是事实上终止向农村输入知青的行动与传达党中央对“上山下乡”政策善后的一系列指示：其中包括允许知青返城就业或进行学业深造，帮助部分知青在乡村完成落户，乃至对知青的工龄优待（下乡期间履历可折算为工龄）等。不论如何，属于“上山下乡”政策的历史都已经结束了。而它的影响将以日后的一系列新问题的形式表现出来——一代人的教育断层，上千万人口的就业问题，空前的人口流动规模，乃至我国农村的发展本身……"

const TXT_R2 := "{0}{1}同志在充分了解“上山下乡”政策实行情况与期间存在的各种问题后，便下定决心对中国农村进行彻底整顿——“恰恰是国家太长时间无所作为，才导致知青们在广阔天地内难有所为。现在，是时候纠正疏忽朝前看，拿出共产党人的气魄与速度了！”。{0}{1}同志就在他亲自撰写的《将迎来大转变的十年内》如此总结，并拉开其农村改造愿景的开端。国家特别设立了“农村、农业与农民发展规划”与相关机制，计划在未来十年内完成下述任务：彻底翻新基础设施；全面更新农机设备；实现乡村建设“五通一平”（即通给水、通排水、通电、通路、通讯与平整土地）；并同时建立稳固的乡村教育、医疗、卫生与社保体系，努力实现城乡基本公共服务均等化。而农业也将依照斯大林时代的苏联发展思路进行设计：预计将动用巨额资金建设农民培训学校、种质培育基地、物流运输网络与国家支持下的农产品采购市场。每名下乡知青也将在同时获得社会保障、荣誉称号与成为“斯达汉诺夫式”劳动模范的机会，其劳动生活也将同在城市内无异——所有的一切都建立通过大规模投资农村以实现城乡完全平等的设想基础上。这同时也足以保留“上山下乡”政策内鼓励的劳动教育与城乡交流成分，并在一定范围内将其发扬光大。当然，天上可不会掉馅饼：如此规模的农村建设可少不了真金白银……"

const TXT_R3 := "显然，你的“急中生智”出乎了在场所有人的预料，并给“上山下乡”政策开了条史无前例的新路。接下来便是几家欢喜几家愁：也就在国家逐渐终止下派知青，默许知青返城并逐步启动知青善后计划的同时；农村迎来了一批又一批头顶高帽，背后有人的“牛鬼蛇神”。这些家伙或是党内斗争的失败者，或是来自民间的不知好歹挑战者。不论如何，现在的他们已亲如一家。这些人此后都将在公安干将的特别过问下，同身边质朴的农民同志们相互学习，并在下放劳动与无休止的忏悔内度过余生。此后各地农村也为管理此类特殊人群，以苏联的秘密行政区与试验设计局为原型，修建了将监狱与公安局二合一的简陋装配房（由于其关押“牛鬼蛇神”的特质，人们通常将其称之为大型牛棚），并基本形成独立的建制与官僚班底。通过将最有害的人民公敌隔离在社会之外与引入劳动改造，我们得以安全地处置国内的诸多不稳定因素。这只会让多数满意：人民共和国有了有效的专政机器，知青们能摆脱“上山下乡”政策的系列问题，农村也得到了源源不断的劳动力支持建设。当然，我们的新思维并非全无反对之声：流窜在外的“牛鬼蛇神”已开始将{0}{1}同志的新政同古代中国的流刑相提并论，并围绕在超级大国身旁唧唧喳喳。非法出版物已开始借用苏联知名流亡者索尔仁尼琴的书籍概念，给我国冠以“牛棚群岛”的大名……"

const TXT_R4 := "{0}{1}同志在充分了解“上山下乡”政策实行情况与期间存在的各种问题后，便下定决心对中国农村进行彻底整顿，首先便是彻底清算建国29年以来的农业发展路线——原本只是旨在解决知青问题的工作会议就这样突然变了性质：从土地改革到组织合作化运动，乃至人民公社实践均遭重新审视与批判，相关政策也被要求立即暂停。为更全面的改革计划让步——“恰恰是国家太长时间无所作为，才导致知青们在广阔天地内难有所为。现在，是时候纠正疏忽朝前看，拿出早该有的气魄与速度了！”。{0}{1}同志就在他亲自组织的农村工作特别会议上如此总结。可就执行情况来说，该政策不过是简单废除了“上山下乡”，并开了深度研究农村问题的盖子。国家在逐渐终止下派知青，默许知青返城并逐步启动知青善后计划的同时组织了调研委员会，启动了组织改革队伍并剔除保守派的计划，试图在逐渐摒弃旧思维的情况下走出条新路——或许，我国未来的许多变化都将自此而始……"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null \
		and world.modifiers[3].is_active
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var press := data[W.I_PRESS_POLICY] if data.size() > W.I_PRESS_POLICY else 0
	var budget_reserve := 0
	if data.size() > W.I_BUDGET and data.size() > W.I_RESERVE:
		budget_reserve = data[W.I_BUDGET] + data[W.I_RESERVE]
	var opt := event_def.options
	_enable(opt[0], "为什么要破坏仍行之有效的东西？")
	if not mod3 and line > 0:
		_enable(opt[1], "近代的苦日子早过去了！孩子们，也该回城了，该回去读书了！")
	else:
		_disable(opt[1], "动摇毛主席的劳动教育路线？我们决不同意！")
	if mod3 and line <= 2 and budget_reserve >= 180:
		_enable(opt[2], "实践表明，“上山下乡”政策还远远不够。为建设社会主义新农村，我们必须竭尽所能！")
	elif not mod3 or line > 2:
		_disable(opt[2], "路线错了，补救越多越反动！")
	else:
		_disable(opt[2], "囊中羞涩，余力不足，国家现在正困难，得节俭度日")
	if press == 16 and line < 4:
		_enable(opt[3], "“上山下乡”政策当然有其可取之处，尤其是其中算“政治账”的部分……")
	else:
		_disable(opt[3], "你疯了吗？！这么做和封建帝王有什么区别？！")
	if not mod3:
		_enable(opt[4], "“上山下乡”是唯意志论的表现，我们得用新思维取而代之！")
	else:
		_disable(opt[4], "毛主席经验在前，我们没必要重新发明轮子！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var leader_name := _leader_name()
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -20)
			_add(W.I_PEOPLE_SUPPORT, -20)
			_add(W.I_THOUGHT_FREEDOM, 80)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_BUDGET, -30)
			_add(W.I_AGRICULTURE, -20)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -180)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -50)
			_add(W.I_AGRICULTURE, 50)
			context["result_text"] = TXT_R2.replace("{0}{1}", leader_name)
		3:
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_THOUGHT_FREEDOM, -20)
			_add(W.I_DIPLO, 100)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			context["result_text"] = TXT_R3.replace("{0}{1}", leader_name)
		4:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			context["result_text"] = TXT_R4.replace("{0}{1}", leader_name)
	# 原版此后的 old_modify_desc[15] 拼接：修正说明文案，Godot 由
	# ModifierCatalog 静态维护，不在事件脚本中改写（见本文件头注）。




func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
