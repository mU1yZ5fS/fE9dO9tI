# ============================================================================
# EventFactory — 事件工厂（编程方式构建事件定义）
# ============================================================================
# 两个用途：
#   1. 迁移脚本：批量解析原版 C# 事件源码 → 创建 EventDef，保存为 .tres
#   2. 运行时生成：在代码中动态构建事件（无对应 .tres 时）
#
# 使用方式：
#   # 迁移单个事件
#   var ev := EventFactory.create_event_120()
#   ResourceSaver.save(ev, "res://场景/事件界面/events/event_korea_unification.tres")
#
#   # 批量迁移
#   EventFactory.batch_migrate()
#
# 设计参考：
#   - 原版 Event120.cs ~ Event456.cs 的模式归纳
#   - Godot 4.7 ResourceSaver（gdd_1477）
# ============================================================================
class_name EventFactory
extends RefCounted


# ── 表达式节点快捷构建 ──

## data[key] >= value
static func res_at_least(key: String, value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = key
	n.value = value
	return n

## data[key] <= value
static func res_at_most(key: String, value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_MOST
	n.key = key
	n.value = value
	return n

## data[key] == value
static func res_equals(key: String, value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_EQUALS
	n.key = key
	n.value = value
	return n

## data[key] != value
static func res_not_equals(key: String, value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_NOT_EQUALS
	n.key = key
	n.value = value
	return n

## sum(data[keys]) <= value
static func res_sum_at_most(keys: Array[String], value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_SUM_AT_MOST
	n.keys = keys
	n.value = value
	return n

## data[left] - data[right] <= value
static func res_difference_at_most(left: String, right: String, value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_DIFFERENCE_AT_MOST
	n.key = left
	n.target = right
	n.value = value
	return n

## allcountries[target].field == value；target 可为标签或原版数组序号。
static func country_field_equals(target: String, field_name: String, value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.COUNTRY_FIELD_EQUALS
	n.target = target
	n.key = field_name
	n.value = value
	return n

## 指定国家拥有标签；target 可为标签或原版数组序号。
static func country_has_tag(target: String, tag: String) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.COUNTRY_HAS_TAG
	n.target = target
	n.key = tag
	return n

## 指定原版战争正在进行。
static func war_active(war_id: int) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.WAR_ACTIVE
	n.value = float(war_id)
	return n

## modifies[key].active == true
static func mod_active(key: String) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.MODIFIER_ACTIVE
	n.key = key
	return n

## modifies[key].active == false
static func mod_inactive(key: String) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.MODIFIER_INACTIVE
	n.key = key
	return n

## resultOfEvents[event_id] == result_index
static func prev_result(event_id: String, result_index: int) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.PREV_EVENT_RESULT_IS
	n.ref_event_id = event_id
	n.value = float(result_index)
	return n

## event_done[event_id] == true
static func event_done(event_id: String) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.PREV_EVENT_DONE
	n.ref_event_id = event_id
	return n

## empires[index].relations >= value
static func empire_rel_at_least(index: int, value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.EMPIRE_RELATION_AT_LEAST
	n.key = str(index)
	n.value = value
	return n

## empires[index].relations <= value
static func empire_rel_at_most(index: int, value: float) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.EMPIRE_RELATION_AT_MOST
	n.key = str(index)
	n.value = value
	return n

## IsFactionLeadeng(index)
static func is_faction_leader(index: int) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.IS_FACTION_LEADER
	n.value = float(index)
	return n

## global_flags[key] == true
static func has_flag(key: String) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.HAS_FLAG
	n.key = key
	return n

## 逻辑 AND
static func all_of(conditions: Array[ExprNode]) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.ALL
	n.children = conditions
	return n

## 逻辑 OR
static func any_of(conditions: Array[ExprNode]) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.ANY
	n.children = conditions
	return n

## 逻辑 NOT
static func not_expr(child: ExprNode) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.NOT
	n.children = [child]
	return n

## 日期条件
static func date_before(date_str: String) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.DATE_BEFORE
	n.key = date_str
	return n

static func date_after(date_str: String) -> ExprNode:
	var n := ExprNode.new()
	n.type = ExprNode.Type.DATE_AFTER
	n.key = date_str
	return n


# ── 效果节点快捷构建 ──

## 给效果附加条件（效果节点仍可在 Inspector 中独立编辑）。
static func effect_if(effect: EffectNode, condition: ExprNode) -> EffectNode:
	effect.condition = condition
	return effect

## 高级事件自定义效果。
static func custom_effect(script: GDScript) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.CUSTOM_SCRIPT
	n.custom_script = script
	return n

## data[key] += delta
static func add_resource(key: String, delta: int) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.ADD_RESOURCE
	n.key = key
	n.value = float(delta)
	return n

## data[key] = value
static func set_resource(key: String, value: int) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.SET_RESOURCE
	n.key = key
	n.value = float(value)
	return n

## country.alliance = true/false
static func set_alliance(target: String, alliance: String, join: bool = true) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.JOIN_ALLIANCE if join else EffectNode.Type.LEAVE_ALLIANCE
	n.target = target
	n.key = alliance
	return n

## country 加入玩家所有联盟
static func join_all_alliances(target: String) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.JOIN_ALL_ALLIANCES
	n.target = target
	return n

## country 仅加入经济联盟
static func join_economic_alliance(target: String) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.JOIN_ECONOMIC_ALLIANCE
	n.target = target
	return n

## country.special_ending = value
static func set_country_var(target: String, var_name: String, value: int) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.SET_COUNTRY_VAR
	n.target = target
	n.key = var_name
	n.value = float(value)
	return n

## 所有政治家忠诚变化。
static func add_all_politician_loyalty(delta: int) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.ADD_ALL_POLITICIAN_LOYALTY
	n.value = float(delta)
	return n

## 指定 traits[0] 人群的忠诚变化。
static func add_politician_loyalty_by_personality(personalities: Array[int], delta: int) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.ADD_POLITICIAN_LOYALTY_BY_PERSONALITY
	var parts := PackedStringArray()
	for personality in personalities:
		parts.append(str(personality))
	n.key = ",".join(parts)
	n.value = float(delta)
	return n

## empires[index].relations += delta
static func add_empire_relation(index: int, delta: int) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.ADD_EMPIRE_RELATION
	n.key = str(index)
	n.value = float(delta)
	return n

## empires[index].power += delta
static func add_empire_power(index: int, delta: int) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.ADD_EMPIRE_POWER
	n.key = str(index)
	n.value = float(delta)
	return n

## empires[index].relations = value
static func set_empire_relation(index: int, value: int) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.SET_EMPIRE_RELATION
	n.key = str(index)
	n.value = float(value)
	return n

## 已废弃 — 请使用 add_empire_power()。保留此别名以兼容已生成的 .tres 事件。
static func set_empire_power(index: int, value: int) -> EffectNode:
	return add_empire_power(index, value)

## set_flag(flag_name)
static func set_flag(key: String) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.SET_FLAG
	n.key = key
	return n

## clear_flag(flag_name)
static func clear_flag(key: String) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.CLEAR_FLAG
	n.key = key
	return n

## set_modifier_active(key, active)
static func set_modifier_active(key: String, active: bool = true) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.SET_MODIFIER_ACTIVE
	n.key = key
	n.value = 1.0 if active else 0.0
	return n

## 开战：war_id + 可选 infl/阵营/侧名（-1 / 空 = WarDef 默认）
static func start_war(
		war_id: int,
		infl1: int = -1,
		infl2: int = -1,
		usa_side: int = -1,
		ussr_side: int = -1,
		side1: String = "",
		side2: String = ""
) -> EffectNode:
	var n := EffectNode.new()
	n.type = EffectNode.Type.START_WAR
	n.value = float(war_id)
	n.key = "%d,%d,%d,%d" % [infl1, infl2, usa_side, ussr_side]
	if side1 != "" or side2 != "":
		n.target = "%s|%s" % [side1, side2]
	return n


# ── 事件选项快捷构建 ──

static func option(text: String, result_text: String, effects: Array[EffectNode] = [],
		enable_condition: ExprNode = null, disabled_text: String = "") -> EventOption:
	var o := EventOption.new()
	o.text = text
	o.result_text = result_text
	o.effects = effects
	o.enable_condition = enable_condition
	o.disabled_text = disabled_text
	return o


# ========================================================================
# 事件迁移 —— 示例：Event120（统一朝鲜）
# ========================================================================

static func create_event_120() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "korea_unification"
	ev.title = "统一而不可分割"
	ev.description = ("朝鲜终于在我们的盟友领导下完成统一。这一切只可能依靠我们的帮助："
			+ "苏联并不真想卷入一场新的冲突，而朝鲜民主主义人民共和国也没有别的大国朋友。"
			+ "在这场战争中，我们的专家、顾问和军官不仅进入了统一后的朝鲜国家机器，"
			+ "也取得了对这个国家相当程度的控制。借助这种影响力，我们能够决定新统一朝鲜"
			+ "未来的发展道路。现在有四名候选人……")
	ev.fire_only_once = true
	ev.mtth_base = 0.0   # 由 Decision 直接触发，非 MTTH

	# 选项0：金正日 — 始终可选
	ev.options.append(option(
		"金正日 - 父亲的继承人",
		"金正日长期以来一直被塑造为金日成的继承人。在他的父亲继续担任劳动党领袖的情况下，"
		+ "让他成为统一朝鲜的国家领导人，是局势的自然延续，也不太可能给朝鲜政治带来显著变化。",
		[set_country_var("KOR", "special_ending", 0)]
	))

	# 选项1：金平日 — 需特工≥250 且 金钱≥250
	ev.options.append(option(
		"金平日 - 可控候选人",
		"金平日是金正日的弟弟，年轻时曾是有名的浪荡子，因此失去了父亲的宠信。"
		+ "现在，在我们的影响下，我们可以把他推上统一朝鲜领导人的位置。",
		[
			add_resource("agents", -250),
			add_resource("money", -250),
			add_resource("political", 5),
			set_country_var("KOR", "special_ending", 1),
			join_all_alliances("KOR"),
		],
		all_of([res_at_least("agents", 250), res_at_least("money", 250)]),
		"需要特工：250，资金：250"
	))

	# 选项2：金永焕 — 始终可选
	ev.options.append(option(
		"金永焕 - 以外部视角理解主体思想",
		"金永焕长期以来都是韩国所谓'主体思想派'的领袖，也是一个适合作为南北共同象征的人选。",
		[
			add_resource("diplo", 50),
			set_country_var("KOR", "special_ending", 2),
		]
	))

	# 选项3：权永吉 — 需特工≥50 且 无毛泽东思想 且 无文化大革命
	ev.options.append(option(
		"权永吉 - 是时候放弃主体思想了",
		"权永吉是一名记者，也是反美、反殖民、反威权左翼工会运动的领袖。"
		+ "对于一个仍需弥合南北伤痕的统一朝鲜来说，这样一位理解多方诉求的政治人物很适合。",
		[
			add_resource("diplo", -50),
			add_resource("agents", -50),
			set_country_var("KOR", "special_ending", 3),
			join_economic_alliance("KOR"),
		],
		all_of([
			res_at_least("agents", 50),
			mod_inactive("6"),   # 毛泽东思想
			mod_inactive("3"),   # 文化大革命
		]),
		"需要无毛泽东思想、无文化大革命，并拥有特工：50"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event121（五不准 / Five "no"）
# ========================================================================

static func create_event_121() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "five_no"
	ev.title = "Five \"no\""
	ev.description = ("恭喜你就任中华人民共和国国务院总理，华国锋同志。如你所知，你的前任周恩来"
			+ "因其清廉正直与行政才能，赢得了海内外人民的广泛尊敬。然而，他也是经济改革的积极推动者，"
			+ "并在党内提拔了改革派，例如他的门生邓小平。"
			+ "正因如此，1976年1月8日周恩来的逝世引起了民众的巨大悲痛，这也令毛泽东和中共领导层深感不满，"
			+ "他们对周的死反应极为冷淡。根据毛泽东的命令，发起了'五不准'运动——"
			+ "不准戴黑纱、不准送花圈、不准设灵堂、不准开追悼会、不准挂周恩来遗像——"
			+ "这到目前为止除了引发不满之外毫无作用。而你，作为新任总理，可以对这一运动的执行施加影响。")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：顺其自然 — 条件：华国锋 specialEnding == 33
	ev.options.append(option(
		"顺其自然，任其发展。",
		"作为运动的一部分，政府官员和警察拆除了临时纪念物，撕毁了赞扬周恩来成就的海报。"
		+ "持续不断的贬低周恩来并禁止公开悼念的宣传活动，"
		+ "引起了民众对毛泽东和党内高层的广泛不满，尤其是对他的妻子江青。",
		[
			set_country_var("HUA", "special_ending", 0),
			set_modifier_active("18"),
		],
		null,   # 原版检查 HUA.specialEnding==33，旧事件69不存在于新系统，暂设为始终可选
		"需要特定条件"
	))

	# 选项1：严格执行毛的命令 — 条件：外交≤400 且 无毛泽东思想 且 无文化大革命
	ev.options.append(option(
		"严格执行毛泽东的命令。",
		"作为国务院总理兼公安部长，你亲自监督了运动的严格执行。"
		+ "持续不断的宣传引起了民众对毛泽东和党内高层的广泛不满，"
		+ "尤其是对江青和继任者华国锋。",
		[
			add_resource("agents", -50),
			add_resource("war_support", -250),
			add_resource("political", 15),
			add_empire_relation(EmpireData.USA, 500),
			add_empire_power(EmpireData.USA, 25),
			set_modifier_active("19"),
			set_country_var("HUA", "special_ending", 1),
		],
		all_of([
			res_at_most("diplo", 400),
			mod_inactive("6"),   # 毛泽东思想
			mod_inactive("3"),   # 文化大革命
		]),
		"需要特定条件"
	))

	# 选项2：执行运动并批判周恩来
	ev.options.append(option(
		"严格执行运动，并在媒体上批判周恩来。",
		"作为国务院总理兼公安部长，你亲自监督了运动的严格执行，"
		+ "并负责在报纸上发表对周恩来的批判。持续不断的宣传引起了"
		+ "民众对毛泽东和党内高层的广泛不满，尤其是对江青和继任者华国锋。",
		[
			add_resource("army", -50),
			add_resource("war_support", -50),
			add_resource("agents", 25),
			add_empire_relation(EmpireData.USA, -250),
			add_empire_relation(EmpireData.USSR, 500),
			add_empire_power(EmpireData.USSR, 25),
			set_modifier_active("20"),
			set_country_var("HUA", "special_ending", 2),
		],
		null,   # 条件较复杂（德国对华贸易/美国在经互会/前两项均不可用），
		        # 先设为始终可选，由旧系统 Event121 处理精确条件
		"需要特定条件"
	))

	return ev


# ========================================================================
# 事件迁移 —— 示例：Event300（中苏同盟破裂后的东欧选择）
# ========================================================================

static func create_event_300() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "sino_soviet_split_eastern_europe"
	ev.title = "东方抉择"
	ev.description = "中苏同盟已经名存实亡。东欧的社会主义国家必须在两个老大哥之间做出选择。"
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	ev.options.append(option(
		"保持中立",
		"我们决定在这场争端中保持中立，不偏袒任何一方。",
		[set_resource("war_state", 0), set_resource("war_pressure", 5), set_alliance("KOR", "ovd", true), set_alliance("KOR", "sev", true)]
	))

	ev.options.append(option(
		"倒向美国",
		"与其在两个社会主义大国之间左右为难，不如彻底转向西方。",
		[
			add_empire_relation(1, -200),
			set_resource("war_state", 0),
			set_resource("war_pressure", 1000),
			set_alliance("KOR", "sev", true),
		],
		all_of([
			ExprNode.new()   # not IsFactionLeadeng(0) and empires[0].relations >= 800
		]),
		"需要：25"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event14（财政危机 / Budget Crisis）
# ========================================================================

static func create_event_14() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "budget_crisis"
	ev.source_event_number = 14
	ev.title = "We have no money, but you hang in there!"
	ev.description = ("There is too little money in our budget and reserve fund. If it continues "
			+ "like this, we soon will not be able to maintain the normal work of our state.")
	ev.fire_only_once = false
	ev.mtth_base = 0.0
	ev.trigger_conditions = [
		res_sum_at_most([
			"money", "budget_army", "budget_mgb", "budget_science", "budget_admin",
			"budget_envelope", "budget_propaganda", "budget_agriculture",
			"budget_industry", "budget_services", "budget_welfare", "budget_diplomacy",
		], 499),
		res_at_most("money", 299),
	] as Array[ExprNode]

	ev.options.append(option(
		"Raise taxes and cut social programs",
		"Taxes and fees were raised, and social programs for the population were reduced. "
		+ "It helped, of course, to replenish the budget, but the people are not happy.",
		[add_resource("people_support", -100), add_resource("thought_freedom", 50),
		add_resource("money", 100)],
		null, ""
	))

	ev.options.append(option(
		"Raise taxes on luxury and for the super rich",
		"Taxes on luxury and super-wealth were raised, which made it possible to replenish the "
		+ "budget without hurting the common people.",
		[add_resource("money", 100), add_resource("party_support", -100),
		add_resource("thought_freedom", 50), add_empire_relation(EmpireData.USA, -50)],
		res_at_least("development", 14),
		"We have no oligarchs"
	))

	ev.options.append(option(
		"Take a foreign loan",
		"A foreign loan was taken, which helped replenish the budget, but had a negative impact "
		+ "on our influence. Yes, and you still have to pay it...",
		[add_resource("money", 100), add_resource("loan", 100),
		add_resource("influence", -20)],
		any_of([empire_rel_at_least(EmpireData.USA, 50), empire_rel_at_least(EmpireData.USSR, 50)]),
		"Nobody wants to give us credit"
	))

	ev.options.append(option(
		"Conduct rapid privatization of state-owned enterprises",
		"Many state-owned enterprises were sold into private hands, which of course hit the "
		+ "standard of living and disrupted the mechanism of our economy, but it helped replenish the budget.",
		[add_resource("living_standard", -100), add_resource("money", 100),
		add_resource("industry", -10), add_resource("food", -10),
		add_resource("services", -10),
		effect_if(add_resource("development", 1), all_of([
			res_at_least("development", 13), res_at_most("development", 14)
		])),
		effect_if(set_resource("development", 13), res_at_most("development", 12))],
		all_of([res_at_most("development", 14), res_not_equals("political_line", 0),
			any_of([res_at_least("party_system", 8), res_not_equals("political_line", 1)])]),
		"Privatization will not work"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event15（柬越战争 / Cambodian-Vietnamese War）
# ========================================================================

static func create_event_15() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "cambodian_vietnam_war"
	ev.source_event_number = 15
	ev.title = "Cambodian-Vietnamese war"
	ev.description = ("For several years, ruling in Democratic Kampuchea, the Red Khmers of Pol Pot "
			+ "pursued an openly aggressive policy towards neighboring Vietnam, often attacking border "
			+ "villages and killing civilians en masse. And it seems that Vietnam's patience has come "
			+ "to an end - quite recently the Vietnamese army launched a full-scale invasion of Cambodia "
			+ "to overthrow the Pol Pot regime...")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	# 原作 TimeScript：1976.12+ 或 1977 年
	ev.trigger_conditions = [date_after("1976.12"), country_field_equals("23", "government", 0)] as Array[ExprNode]

	# 三选项均开战 war_id=1；infl 按 Results_text 分档；ussr_side=1
	ev.options.append(option(
		"Do not interfere",
		"We decided not to intervene in the conflict. Pol Pot and the Khmer Rouge leadership, of "
		+ "course, are very unhappy with this, but it does not seem that they will live long...",
		[add_resource("influence", -10),
		start_war(1, 300, 700, -1, 1, "Kampuchea", "Vietnam")],
		null, ""
	))

	ev.options.append(option(
		"Remove Pol Pot in favor of the trio of Hu Nim, Hou Yuon and Khieu Samphan",
		"Coming in contact with the Left Opposition within the Kampuchean army, we were able to "
		+ "organize the displacement and arrest of Pol Pot...",
		[add_resource("agents", -30), set_country_var("23", "government", 1),
		start_war(1, 450, 550, -1, 1, "Kampuchea", "Vietnam")],
		all_of([res_at_least("agents", 30), res_not_equals("political_line", 0)]),
		"We can't remove Pol Pot"
	))

	ev.options.append(option(
		"Help the Khmer Rouge",
		"We sent help to our old ally, Pol Pot, but it is not known whether this is enough for him...",
		[add_resource("army", -50), add_resource("money", -10),
		add_empire_relation(EmpireData.USSR, -50),
		start_war(1, 400, 600, -1, 1, "Kampuchea", "Vietnam")],
		res_not_equals("political_line", 4), "We cannot help the dictator!"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event16（泰国选举 / Elections in Thailand）
# ========================================================================

static func create_event_16() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "thailand_elections"
	ev.title = "Elections in Thailand"
	ev.description = ("After the fall of the military junta in 1973 and the transfer of power to the "
			+ "civilian government, Thailand entered the period of \"chaotic democracy\". The victories "
			+ "of the communist forces throughout Indochina contribute to the growth of leftist sentiments...")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	# 原作：1976.4+ 或 1977
	ev.trigger_conditions = [date_after("1976.4")] as Array[ExprNode]

	ev.options.append(option(
		"Do not interfere",
		"The election campaign of 1976 was accompanied by bloody street clashes. Killed about 30 people. "
		+ "The Seni Pramoj's Democratic Party received the largest number of votes...",
		[add_empire_power(EmpireData.USA, 5)],
		null, ""
	))

	ev.options.append(option(
		"Support the CPT and create a coalition with the left and the democrats",
		"We managed to provide substantial support for the CPT and to achieve an alliance with various "
		+ "moderately left-wing activists...",
		[add_resource("agents", -20), add_resource("money", -10)],
		any_of([res_at_least("agents", 20)]),
		"We do not have enough strength to support CPT"
	))

	ev.options.append(option(
		"To hell with the election! Send CPT more weapons for guerrilla warfare.",
		"Ignoring the elections, we sent more weapons to the guerrillas from CPT...",
		[add_resource("army", -20)],
		all_of([res_at_least("army", 20)]),
		"We can not send CPT more weapons"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event17（泰国不稳定 / Instability in Thailand）
# ========================================================================

static func create_event_17() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "thailand_instability"
	ev.title = "Instability in Thailand"
	ev.description = ("Against the background of social instability and constant confrontation between "
			+ "left and right forces, the royal family of Thailand decided in September to organize the "
			+ "return to the country of the radical right general Thanom Kittikachorn...")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	# 原作：1976.10+ 或 1977
	ev.trigger_conditions = [date_after("1976.10")] as Array[ExprNode]

	ev.options.append(option(
		"It's not our business",
		"We chose not to get involved in the internal affairs of Thailand.",
		[add_empire_power(EmpireData.USA, 5)],
		null, ""
	))

	# 选项2：支持 CPT 起义 → 泰国内战 war_id=2（Results_text）
	ev.options.append(option(
		"Send armed CPT units to help demonstrators and provoke an uprising",
		"CPT units moved to help the student demonstrators...",
		[add_resource("agents", -40), add_resource("army", -30),
		add_empire_relation(EmpireData.USA, -100),
		start_war(2, 300, 700, 1, 0, "Communists", "Loyalists")],
		all_of([res_at_least("agents", 40), res_at_least("army", 30)]),
		"We do not have enough strength to organize the uprising"
	))

	ev.options.append(option(
		"Condemn the cruelty of Thailand",
		"We issued a strong condemnation of the Thai government's actions.",
		[add_empire_relation(EmpireData.USSR, 20), add_empire_relation(EmpireData.USA, -20),
		add_empire_power(EmpireData.USA, 5), add_resource("influence", 10)],
		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event18（战争结束 / War is Over）
# 注：此事件文本动态生成，效果依赖 data[82]（当前战争索引），需 CUSTOM_SCRIPT
# ========================================================================

static func create_event_18() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "war_is_over"
	ev.title = "War is over"
	ev.description = ("After long and bloody battles, the conflict is finally over. "
			+ "The Ministry of Foreign Affairs has taken care of everything and is now ready "
			+ "to give you a quick overview of the outcome of the war.")
	# 多场战争可多次结束；由 I_WAR_RESOLVE + queue_pending 触发
	ev.fire_only_once = false
	ev.mtth_base = 0.0
	ev.show_notification = false

	ev.options.append(option(
		"Long live the peace!",
		"Another war ended. The Foreign Ministry files the outcome. Military intervention stock recovers slightly.",
		[add_resource("political", 10)],
		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event19（五不准运动 / Five "No" Campaign — 华国锋版）
# 注：此事件与 Event121（five_no）内容相同，此处提供简化版
# ========================================================================

static func create_event_19() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "five_no_hua"
	ev.title = "Five \"no\""
	ev.description = ("Congratulations on your appointment to the post of Premier of the State Council "
			+ "of the People's Republic of China, Comrade Hua Guofeng. As you know, your predecessor was "
			+ "Zhou Enlai, who gained popularity and respect among the people at home and abroad for his "
			+ "honesty and administrative talents... Rumor has it Mao Zedong himself set the campaign of "
			+ "Five \"no\" in motion... And you, as a new prime minister, can influence its execution.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	ev.trigger_conditions = [date_after("1976.2")] as Array[ExprNode]

	ev.options.append(option(
		"Let it pass, how it goes",
		"As part of the campaign, government and police officers removed improvised memorials and tore "
		+ "down posters marking Zhou Enlai's achievements. Constant propaganda aimed at denigrating Zhou "
		+ "and bans on open commemoration caused widespread discontent.",
		[add_resource("people_support", -50)],
		null, ""
	))

	ev.options.append(option(
		"Follow the strict execution of Mao's decrees",
		"You personally followed the strict execution of the campaign. Discontent of people with Mao "
		+ "Zedong and the top party, especially his wife Jiang Qing and successor Hua Guofeng.",
		[add_resource("people_support", -70), add_resource("diplo", 10)],
		null, ""
	))

	ev.options.append(option(
		"Follow the strict execution of the campaign, as well as criticize Zhou in the media.",
		"You personally followed the strict execution of the campaign and were responsible for the "
		+ "publication of criticism of Zhou Enlai in newspapers, which, however, had no effect on "
		+ "people already tired of criticism in the spirit of the Cultural Revolution.",
		[add_resource("people_support", -100), add_resource("diplo", 10)],
		null, ""
	))

	ev.options.append(option(
		"Gently sabotage the campaign",
		"Thanks to your efforts to sabotage the campaign, discontent does not go beyond reasonable limits.",
		[add_resource("people_support", -10), add_resource("party_support", -50),
		add_resource("diplo", -10)],
		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event20（批邓反击右倾翻案风 / Criticize Deng）
# ========================================================================

static func create_event_20() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "criticize_deng"
	ev.title = "Criticize Deng and fight with right!"
	ev.description = ("The death of Zhou Enlai seriously affected the position of his protege Deng Xiaoping, "
			+ "who was left without the patronage of the former prime minister. He is now under constant "
			+ "attack by the radicals headed by Mao Zedong's wife Jiang Qing... And what should we do, "
			+ "given that Hua Guofeng has never been on good terms with either Jiang Qing or Xiaoping?")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	ev.trigger_conditions = [date_after("1976.2"), event_done("five_no")] as Array[ExprNode]

	ev.options.append(option(
		"Do nothing. Jiang Qing and Xiaoping each other stand",
		"In the media controlled by Jiang Qing's group, active persecution of Deng Xiaoping and his "
		+ "ideas began. Deng was stripped of all posts, though his party card was left with him.",
		[add_resource("people_support", -20)],
		null, ""
	))

	ev.options.append(option(
		"Join Xiaoping's persecution",
		"The new Premier Hua Guofeng also joined the persecution, saying that Deng's reformist "
		+ "ideas lead China to capitalist slavery.",
		[add_resource("party_support", 80), add_resource("people_support", -20)],
		null, ""
	))

	ev.options.append(option(
		"Stand up for Xiaoping",
		"You, however, stood up for him, arguing that Xiaoping made mistakes but admitted them, "
		+ "helped China develop. This caused discontent among the party top, but it appealed to the people.",
		[add_resource("people_support", 20), add_resource("party_support", -70)],
		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event21（文汇报事件 / Mystery Article about Zhou）
# ========================================================================

static func create_event_21() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "wenhuibao_article"
	ev.title = "Mystery article about Zhou"
	ev.description = ("On March 25, 1976, the Shanghai newspaper \"Wenhuibao\" printed an article calling "
			+ "an unnamed Zhou a \"capitalist-roader\". Some read it as a posthumous strike on Zhou Enlai, "
			+ "others say it targets Zhou Rongxin... The masses do not yet know which Zhou is under attack, "
			+ "but emotions are rising — we must decide how to respond.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	ev.trigger_conditions = [date_after("1976.4")] as Array[ExprNode]

	ev.options.append(option(
		"Stay quiet, targets unclear, don't get caught in the crossfire",
		"An obscure article sparked rumors... With targets unclear and tempers hot, we chose to "
		+ "keep our heads down. Even so, word spread, and protests flared across Yangtze cities.",
		[add_resource("people_support", -50)],
		null, ""
	))

	ev.options.append(option(
		"Clamp down on the publication and speculation to avoid stirring the masses",
		"We moved hard to seize the text and choke off any speculation. The clampdown slowed "
		+ "the spread; protests still erupted, but the scale stayed contained.",
		[add_resource("party_support", -50), add_resource("people_support", -30)],
		null, ""
	))

	ev.options.append(option(
		"Turn the article against capitalist-roadings reforms",
		"You framed it as proof of the dangers of capitalist-roadings reforms and pushed it "
		+ "beyond Shanghai. The party appreciated the line; the public did not.",
		[add_resource("people_support", -80), add_resource("party_support", 50)],
		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event22（天安门事件 / Tiananmen Incident）
# ========================================================================

static func create_event_22() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "tiananmen_incident"
	ev.title = "Tiananmen incident"
	ev.description = ("Numerous attempts by the CCP to discredit the late Zhou Enlai have caused only "
			+ "discontent among the people. On April 4, on the day of the traditional holiday of remembrance "
			+ "of the departed, the citizens of Beijing carried wreaths in memory of Zhou Enlai to Tiananmen "
			+ "Square to the Monument to the people's heroes... The responsibility was placed on you and "
			+ "the mayor of Beijing, Wu De; what line will we choose?")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	ev.trigger_conditions = [date_after("1976.5")] as Array[ExprNode]

	ev.options.append(option(
		"Disperse protest with the help of the army and police",
		"Following Jiang Qing and Zhang Chunqiao's line, we first used radio appeals to separate "
		+ "mourners from provocateurs, then moved in city police and the Peking Garrison to clear "
		+ "the square. Clashes and beatings occurred, but no one was killed.",
		[add_resource("people_support", -250), add_resource("diplo", 60),
		add_resource("party_support", 100)],
		null, ""
	))

	ev.options.append(option(
		"Call all to go away and disperse the remaining",
		"At half past six in the evening, Wu De spoke over loudspeakers urging the crowd to "
		+ "disperse. Many left, some stayed. By night, city police cleared the remaining protest.",
		[add_resource("party_support", 50), add_resource("people_support", -50)],
		null, ""
	))

	ev.options.append(option(
		"Call everyone to go away and cordon off the rest until they leave",
		"Wu De spoke over loudspeakers urging the crowd to go home. Many left, but some stayed. "
		+ "By night, police cleared the square. No one was killed.",
		[add_resource("party_support", -50)],
		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event23（唐山大地震 / Tangshan Earthquake）
# ========================================================================

static func create_event_23() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "tangshan_earthquake"
	ev.title = "Tangshan earthquake"
	ev.description = ("On July 28, a magnitude 8.2 earthquake on the Richter scale occurred in the city "
			+ "of Tangshan, Hebei Province, at 03:42 local time, as a result of which the city was almost "
			+ "completely destroyed. The destruction also took place in Tianjin and in Beijing... "
			+ "According to preliminary data, from 200 to 600 thousand people died.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	ev.trigger_conditions = [date_after("1976.8")] as Array[ExprNode]

	ev.options.append(option(
		"Allocate funds from the budget for restoration (-3.0 from budget)",
		"Funds from the PRC budget were immediately allocated to carry out rescue and restoration "
		+ "work, which made it possible to mitigate the effects of the earthquake.",
		[add_resource("people_support", 30), add_resource("party_support", 50),
		add_resource("money", -30)],
		null, ""
	))

	ev.options.append(option(
		"Request foreign humanitarian assistance",
		"The world community and charitable organizations, assessing the scale of the disaster, "
		+ "agreed to provide us with assistance in the form of gratuitous loans and help of volunteers.",
		[add_resource("party_support", -50), add_resource("people_support", 50)],  # was influencePRC
		any_of([empire_rel_at_least(EmpireData.USA, 600), empire_rel_at_least(EmpireData.USSR, 600)]),
		"Foreigners will not give us help"
	))

	ev.options.append(option(
		"Allocate funds for restoration and earthquake protection system (-5.0 from budget)",
		"Funds from the PRC budget were immediately allocated... Additional funding was also provided "
		+ "for the construction of earthquake-resistant buildings in hazardous regions.",
		[add_resource("living_standard", 50), add_resource("people_support", 30),
		add_resource("party_support", 50), add_resource("money", -50)],
		null, ""
	))

	ev.options.append(option(
		"Let the provincial administration deal with it",
		"The center remained deaf to the problems of Hebei Province, which of course made it "
		+ "difficult to eliminate the consequences of the earthquake and gave rise to discontent.",
		[add_resource("living_standard", -50), add_resource("people_support", -40),
		add_resource("party_support", -50)],
		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event24（毛后路线 / Wind of change?）
# ========================================================================

static func create_event_24() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "post_mao_course"
	ev.source_event_number = 24
	ev.title = "Wind of change?"
	ev.description = ("After Mao's death, power has finally concentrated in your hands. Every faction "
			+ "of the CCP now demands a decision on China's future: conservative Maoism without the "
			+ "excesses of the Cultural Revolution, a renewed radical course, limited modernization, "
			+ "or large-scale market reform and opening to the world.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	ev.trigger_conditions = [date_after("1976.12")] as Array[ExprNode]
	var transition_script := preload("res://数据脚本/事件效果/event_024_026_political_transition.gd")

	ev.options.append(option(
		"Continue Mao's work while phasing out the Cultural Revolution",
		"You proclaimed loyalty to Mao's precepts and the Two Whatevers, while the remaining "
		+ "centres of the Cultural Revolution began to be dismantled.",
		[custom_effect(transition_script)]
	))
	ev.options.append(option(
		"Continue the Cultural Revolution without its former excesses",
		"Relying on loyal radicals, you renewed the struggle against revisionism and attempted "
		+ "to rekindle the Cultural Revolution under tighter control.",
		[custom_effect(transition_script)],
		res_equals("gang_of_four_path", 3),
		"The Cultural Revolution has already exhausted its political base"
	))
	ev.options.append(option(
		"End the Cultural Revolution and reorganize the economy",
		"You declared that the Cultural Revolution had fulfilled its tasks and promised an "
		+ "economic modernization programme, without yet defining its exact form.",
		[custom_effect(transition_script)],
		res_not_equals("gang_of_four_path", 3), ""
	))
	ev.options.append(option(
		"End the Cultural Revolution and begin large-scale market reforms",
		"The remnants of the Cultural Revolution were dismantled and veteran reformers were "
		+ "promoted to prepare China for market reform and entry into the world economy.",
		[custom_effect(transition_script)],
		res_not_equals("gang_of_four_path", 3), ""
	))
	return ev


# ========================================================================
# 事件迁移 —— Event25（粉碎四人帮 / Gang of four）
# ========================================================================

static func create_event_25() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "gang_of_four"
	ev.source_event_number = 25
	ev.title = "Gang of four"
	ev.description = ("After Mao's death, the struggle inside the CCP has flared up again. Jiang Qing, "
			+ "Wang Hongwen, Zhang Chunqiao and Yao Wenyuan remain the strongest radical bloc and the "
			+ "most immediate threat to your government. Crushing them requires military and reformist "
			+ "support, while compromise risks giving the radicals the power they seek.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	ev.trigger_conditions = [date_after("1976.10")] as Array[ExprNode]
	var transition_script := preload("res://数据脚本/事件效果/event_024_026_political_transition.gd")

	ev.options.append(option(
		"Arrest all four",
		"The Politburo meeting ended with the arrest of the radical leaders. Their network in "
		+ "Beijing and Shanghai was dismantled and the press launched a campaign against the Gang of Four.",
		[custom_effect(transition_script)]
	))
	ev.options.append(option(
		"Arrest Wang Hongwen and Jiang Qing, compromise with the others",
		"Jiang Qing and Wang Hongwen were arrested, while Yao Wenyuan and Zhang Chunqiao received "
		+ "government posts in exchange for loyalty. The radical bloc survived, but was weakened.",
		[custom_effect(transition_script)]
	))
	ev.options.append(option(
		"Reach a compromise and enlist radical support",
		"You allied with the radicals against the reformers, conceding the military council and "
		+ "foreign ministry while reviving the campaign against Deng Xiaoping.",
		[custom_effect(transition_script)]
	))
	ev.options.append(option(
		"Do not interfere in the party struggle",
		"Without intervention, the struggle at the top of the party ended your rule.",
		[custom_effect(transition_script)]
	))
	return ev


# ========================================================================
# 事件迁移 —— Event26（激进派联盟破裂 / Weak alliance）
# ========================================================================

static func create_event_26() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "weak_alliance"
	ev.source_event_number = 26
	ev.title = "Weak alliance"
	ev.description = ("The compromise between Hua Guofeng and the radical left is cracking. Moderate "
			+ "party members are openly dissatisfied, while the four demand broader powers and harsher "
			+ "action against the opposition. Wang Dongxing and the 8341 Special Regiment remain loyal, "
			+ "but the radicals are now stronger than they were in October.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	ev.trigger_conditions = [
		date_after("1976.11"),
		res_equals("gang_of_four_path", 3),
	] as Array[ExprNode]
	var transition_script := preload("res://数据脚本/事件效果/event_024_026_political_transition.gd")

	ev.options.append(option(
		"Arrest all four",
		"The radical leadership and its network were arrested, although their increased influence "
		+ "made the operation more costly and violent than it would have been earlier.",
		[custom_effect(transition_script)],
		res_at_least("agents", 70), "Requires at least 70 agents"
	))
	ev.options.append(option(
		"Arrest only Wang Hongwen and Jiang Qing",
		"The two most ambitious radical leaders were removed, while their remaining partners were "
		+ "kept inside the government under a revised compromise.",
		[custom_effect(transition_script)],
		res_at_least("agents", 50), "Requires at least 50 agents"
	))
	ev.options.append(option(
		"Abandon the struggle and transfer power gradually",
		"Further concessions made Jiang Qing the new de facto leader. Hua Guofeng retained his life "
		+ "and a formal place in politics, but lost control of the state and party.",
		[custom_effect(transition_script)]
	))
	return ev


# ========================================================================
# 批量迁移辅助
# ========================================================================

## 扫描原版事件脚本目录，为每个 C# Event 文件生成对应的 .tres
## 注意：此函数需要已实现的迁移映射表。
## 当前仅作框架 — 具体事件按 create_event_XXX 逐个实现。
static func batch_migrate(output_dir: String = "res://场景/事件界面/events/") -> void:
	# 已迁移的事件列表
	# 事件 001/003/004/005/006 已改为手写 .tres（唯一权威源），不经生成器。
	# 事件 007 已改为手写 .tres（唯一权威源），不经生成器。
	# 事件 008 已改为手写 .tres（唯一权威源），不经生成器。
	# 事件 009/010 已改为手写 .tres（唯一权威源），不经生成器。
	# 事件 011/012/013 已改为手写 .tres（唯一权威源），不经生成器。
	var migrated := [
		{"func": create_event_20, "filename": "event_020_criticize_deng.tres"},
		{"func": create_event_21, "filename": "event_021_wenhuibao_article.tres"},
		{"func": create_event_22, "filename": "event_022_tiananmen_incident.tres"},
		{"func": create_event_23, "filename": "event_023_tangshan_earthquake.tres"},
		{"func": create_event_24, "filename": "event_024_post_mao_course.tres"},
		{"func": create_event_25, "filename": "event_025_gang_of_four.tres"},
		{"func": create_event_26, "filename": "event_026_weak_alliance.tres"},
		{"func": create_event_120, "filename": "event_korea_unification.tres"},
		{"func": create_event_121, "filename": "event_five_no.tres"},
		{"func": create_event_300, "filename": "event_sino_soviet_split_eastern_europe.tres"},
	]

	for entry in migrated:
		var ev: EventDef = entry["func"].call()
		var path: String = output_dir + str(entry["filename"])
		var err: int = ResourceSaver.save(ev, path)
		if err == OK:
			print("EventFactory: 已生成 %s" % path)
		else:
			push_error("EventFactory: 保存失败 %s (err=%d)" % [path, err])

	print("EventFactory: 批量迁移完成，共 %d 个事件" % migrated.size())
