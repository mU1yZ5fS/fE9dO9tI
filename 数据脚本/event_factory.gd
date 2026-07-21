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
# 事件迁移 —— Event1（全国人大选举 / NPC Elections）
# ========================================================================

static func create_event_1() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "npc_elections"
	ev.title = "Elections, Elections, Candidates are..."
	ev.description = ("It is the day of the national elections in the NPC. And since we occupy a dominant position "
			+ "in Chinese politics, we can intervene a little in their conduct, so that everything will remain same. "
			+ "Or just rely on the Chinese people's faith in us.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：不干涉
	ev.options.append(option(
		"Do not interfere and wait for results",
		"The election proceeds naturally. The results depend on people support and party dynamics.",
		[set_flag("election_free")],
		null, ""
	))

	# 选项1：驱赶公务员投票 — 需 data[1] > 500
	ev.options.append(option(
		"Drive civil servants to the vote",
		"With the promise of bonuses, payouts and threats of layoffs and downgrades, we managed to get "
		+ "the civil servants to come to the polls and vote for our party. But people will long remember such an open scam.",
		[add_resource("people_support", -100), add_resource("party_support", 50)],
		res_at_least("party_support", 500),
		"The party blocks such brazen intervention"
	))

	# 选项2：伪造结果 — 需 data[9] >= 50
	ev.options.append(option(
		"Falsify results",
		"The special services did a great job getting places for us. Only they are very tired.",
		[add_resource("agents", -100), add_empire_power(EmpireData.USSR, 150)],
		res_at_least("agents", 50),
		"The intelligence services do not have enough strength"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event3（毛泽东逝世 / Death of Mao）
# ========================================================================

static func create_event_3() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "death_of_mao"
	ev.title = "Death of helmsman"
	ev.description = ("A terrible thing happened. After 2 transferred heart attacks on September 9 at 0 h. 10 min. "
			+ "On the 83rd year of life, the great leader and teacher of the Chinese people, Chairman Mao Zedong, "
			+ "passed away. As long as all the people and the party are grieving, we need to convene the funeral "
			+ "commission and decide how we are conduct the chairman in his last journey.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：火化并建纪念碑
	ev.options.append(option(
		"Cremate Mao according to his wishes and build a memorial",
		"After Mao's death was announced, his body was placed in the House of People's Congregations for a week "
		+ "so that everyone could say goodbye to the chairman, mourning was declared throughout the country. "
		+ "Many Chinese people have come to pay their last honors to their great leader and teacher. After the "
		+ "deadline, Mao's body was cremated, according to his wish, and the urn with ashes after three minutes "
		+ "of silence and Hua Guofeng's farewell speech in Tiananmen Square was walled up in a monument specially "
		+ "built on the same square.",
		[add_resource("people_support", 20), set_flag("mao_cremated")],
		null, ""
	))

	# 选项1：建陵墓保存遗体
	ev.options.append(option(
		"Build Mausoleum on Tiananmen Square for Mao",
		"After Mao's death was announced, his body was placed in the House of People's Congregations for a week... "
		+ "After the deadline, Mao's body was taken to the hospital and embalmed by a specially developed technique. "
		+ "After three minutes of silence and Hua Guofeng's farewell speech on Tiananmen Square, the chairman rested "
		+ "in a mausoleum built on the same square by a special order of Guofeng.",
		[add_resource("people_support", 50), add_resource("party_support", 40),
		add_resource("money", -10), set_flag("mao_mausoleum")],

		null, ""
	))

	# 选项2：让治丧委员会决定
	ev.options.append(option(
		"Let the funeral commission decide",
		"Guofeng decided not to participate directly in the organization of the funeral, which did not go unnoticed... "
		+ "After the deadline, Mao's body was taken to the hospital and embalmed by a specially developed technique. "
		+ "After three minutes of silence and Hua Guofeng's farewell speech on Tiananmen Square, the chairman rested "
		+ "in a mausoleum built on the same square by a special order of the funeral commission.",
		[add_resource("people_support", 50), add_resource("party_support", -40),
		set_flag("mao_mausoleum")],

		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event4（党内阴谋 / Conspiracy at Congress）
# ========================================================================

static func create_event_4() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "congress_conspiracy"
	ev.title = "Conspiracy"
	ev.description = ("According to the recently received information, several senior party members who are "
			+ "dissatisfied with your rule have agreed to remove you at the next congress of the Central Committee. "
			+ "You need to urgently do something if you do not want to repeat the fate of the revisionist Khrushchev in 1964.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：在大会上展开论战（始终可选）
	ev.options.append(option(
		"Start polemic at the congress",
		"Before the conspirators managed to voice their accusations, you attacked them with criticism and counter "
		+ "accusations. Most of those present at the congress supported you and the conspirators had to retreat.",
		[add_resource("party_support", 50), set_flag("congress_polemic_win")],
		null, ""
	))

	# 选项1：逮捕阴谋者 — 需特工≥100
	ev.options.append(option(
		"Arrest conspirators!",
		"Even before the start of the congress, the secret service agents loyal to you, overwhelmed the conspirators "
		+ "who had arrived and sent them to the detention facilities. At the congress, you criticized them in absentia, "
		+ "which was supported by the delegates. But it's not so easy to get rid of high party members...",
		[add_resource("people_support", -50), add_resource("agents", -100),
		add_resource("party_support", 50)],

		res_at_least("agents", 100),
		"Special services will not support us"
	))

	# 选项2：召唤忠诚军官 — 需军队≥100
	ev.options.append(option(
		"Call loyal officers!",
		"Even before the start of the congress, the officers loyal to you overwhelmed the conspirators who had "
		+ "arrived and, at gunpoint, took them to military jails. At the congress, in the presence of armed "
		+ "soldiers, you criticized them in absentia, which was supported by the delegates.",
		[add_resource("people_support", -80), add_resource("army", -100),
		add_resource("party_support", 50)],

		res_at_least("army", 100),
		"Army will not support us"
	))

	# 选项3：诉诸人民 — 需人民支持≥700
	ev.options.append(option(
		"Appeal to the people!",
		"Even before the start of the congress, you appealed through the media to the people with a call to "
		+ "support you and protect the conquests of your power. The people loyal to you went to mass demonstrations "
		+ "in your support and began to storm the departments under your opponent's control.",
		[add_resource("people_support", -200), add_resource("living_standard", -70),
		add_resource("party_support", 50)],

		res_at_least("people_support", 700),
		"People do not need another Cultural Revolution"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event6（低生活水平 / Low Standard of Living）
# ========================================================================

static func create_event_6() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "low_living_standard"
	ev.title = "Low standard of living"
	ev.description = ("Your policy has led to a catastrophic decline in the standard of living in the country, "
			+ "people live in abominable conditions and the vast majority lack the ability to purchase even basic "
			+ "necessities. Of course, this leads to numerous protests where people demand to deal with this "
			+ "situation. Given the fact that the soldiers are also unhappy with the terrible conditions of "
			+ "detention, we can not count on the army.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：紧急拨款社会项目
	ev.options.append(option(
		"Urgently allocate money for social programs",
		"Large funds from the budget were urgently allocated to social programs, housing development and to "
		+ "help the poor. Social problems are gradually beginning to be solved and people are satisfied.",
		[add_resource("people_support", 50), add_resource("money", -100),
		set_resource("living_standard", 300)],

		null, ""
	))

	# 选项1：请求外国援助 — 需 USA或USSR关系好
	ev.options.append(option(
		"Request foreign humanitarian assistance",
		"We requested foreign humanitarian assistance, which was provided. Volunteers from different countries "
		+ "and from the UN distribute food, as well as develop housing for people on free terms. However, such "
		+ "actions showed both our people and the world community that we cannot cope with such things on our "
		+ "own, which greatly undermines our prestige.",
		[set_resource("living_standard", 300)],
		any_of([empire_rel_at_least(EmpireData.USA, 500), empire_rel_at_least(EmpireData.USSR, 500)]),
		"We can't ask for help"
	))

	# 选项2：强制企业承担社会责任 — 需发展度≥13
	ev.options.append(option(
		"Call on business by carrot and stick policy to solve social problems",
		"Through the development of labor laws, government orders, benefits and banal coercion, we managed to "
		+ "force our businessmen to provide social support to the people, improve working conditions and housing "
		+ "conditions. However, they are not particularly happy to share their wealth with the people.",
		[add_resource("party_support", -500), set_resource("living_standard", 300)],
		res_at_least("development", 13),
		"We can't call on business, we don't have it"
	))

	# 选项3：党派和官员慈善 — 需党派支持≥500
	ev.options.append(option(
		"Arrange charity at the expense of the party and officials",
		"Speaking at the extraordinary party congress, you explained to the top the brunt of the situation "
		+ "and decided to allocate funds for social needs of the party and voluntarily-forcedly attracted party "
		+ "members and officials to participate in charity events. This, of course, raised the standard of "
		+ "living, but the party was not satisfied.",
		[add_resource("people_support", 100), set_resource("living_standard", 300),
		set_resource("party_support", 0)],

		res_at_least("party_support", 500),
		"Party does not want to share"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event7（对美外交危机 / Diplomatic Crisis with USA）
# ========================================================================

static func create_event_7() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "diplomatic_crisis_usa"
	ev.title = "Diplomatic crisis"
	ev.description = ("Our relations with the USA have reached a critically low level. Their propaganda already "
			+ "accuses China of all possible and impossible crimes, and our intelligence reports on the turmoil "
			+ "in the Pentagon and activity at American bases in Southeast Asia. We urgently need to somehow "
			+ "correct the situation if we don't want the Third World War.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：自费组织缓和 — 需 军事≠30 或 外交≤950
	ev.options.append(option(
		"Organize detente at our expense",
		"We urgently organized a magnificent meeting of the foreign ministers of China and the USA, and the "
		+ "American delegation was invited to a luxurious tour of China, where various festivals and events "
		+ "are being prepared, showing our peacefulness. The detente succeeded, the tension subsided.",
		[set_empire_relation(EmpireData.USA, 400), add_resource("money", -100)],
		null, ""
	))

	# 选项1：放弃部分外交立场 — 需影响力≥50
	ev.options.append(option(
		"Pass a part of foreign policy positions as a sign of goodwill",
		"We have abandoned some foreign policy claims, reduced the support of loyal opposition in other countries "
		+ "and, in general, reduced the degree of interventionism of Chinese politics. This was positively "
		+ "perceived by the Ministry of Foreign Affairs of the USA, tensions decreased. Like our influence.",
		[set_empire_relation(EmpireData.USA, 400), add_resource("army", -50),
		add_resource("agents", -50)],

		res_at_least("political", 50),  # influencePRC >= 50
		"Our influence is too weak, so we cannot limit it"
	))

	# 选项2：发射核弹 — 条件复杂（data[56]==0 && data[15]<8 或 议会多数或AI模式）
	ev.options.append(option(
		"Launch nukes into imperialists!",
		"Tension grows. This leads to a nuclear confrontation.",
		[],  # 效果由 CUSTOM_SCRIPT 处理（game over）
		null,
		"Nobody wants a nuclear war"
	))

	# 选项3：不在乎
	ev.options.append(option(
		"Don't care at all",
		"Tension grows.",
		[set_modifier_active("17", true), add_resource("army", -50),
		add_resource("agents", -50)],

		null, ""
	))

	# 选项4：贿赂美国参议员（DLC6）— 条件复杂
	ev.options.append(option(
		"Bribe U.S. senators to keep the issue quiet",
		"We urgently organized a magnificent meeting of the foreign ministers of China and the USA... "
		+ "The detente succeeded, the tension subsided.",
		[set_empire_relation(EmpireData.USA, 400)],
		mod_active("17"),
		"Need specific conditions"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event8（对苏外交危机 / Diplomatic Crisis with USSR）
# ========================================================================

static func create_event_8() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "diplomatic_crisis_ussr"
	ev.title = "Diplomatic crisis"
	ev.description = ("Our relations with the USSR have reached a critically low level. Their propaganda already "
			+ "accuses China of all possible and impossible crimes, and our intelligence reports on the turmoil "
			+ "in the General Staff of the USSR and the movement of Soviet troops on the border. We urgently "
			+ "need to somehow correct the situation if we don't want the Third World War.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：自费组织缓和
	ev.options.append(option(
		"Organize detente at our expense",
		"We urgently organized a magnificent meeting of the foreign ministers of China and the USSR, and the "
		+ "Soviet delegation was invited to a luxurious tour of China, where various festivals and events "
		+ "are being prepared, showing our peacefulness. The detente succeeded, the tension subsided.",
		[set_empire_relation(EmpireData.USSR, 400), add_resource("money", -100)],
		null, ""
	))

	# 选项1：放弃部分外交立场
	ev.options.append(option(
		"Pass a part of foreign policy positions as a sign of goodwill",
		"We have abandoned some foreign policy claims, reduced the support of loyal opposition in other countries "
		+ "and, in general, reduced the degree of interventionism of Chinese politics. This was positively "
		+ "perceived by the Ministry of Foreign Affairs of the USSR, tensions decreased. Like our influence.",
		[set_empire_relation(EmpireData.USSR, 400), add_resource("army", -50),
		add_resource("agents", -50)],

		null, ""
	))

	# 选项2：不在乎
	ev.options.append(option(
		"Don't care at all",
		"Tension grows. This may lead to war.",
		[],
		null, ""
	))

	# 选项3：启动核对抗程序
	ev.options.append(option(
		"Launch nukes into imperialists!",
		"Tension grows.",
		[set_modifier_active("16", true), add_resource("army", -50),
		add_resource("agents", -50)],

		null,
		"Nobody wants a nuclear war"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event9（西藏分离主义 / Separatism in Tibet）
# ========================================================================

static func create_event_9() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "tibet_separatism"
	ev.title = "Separatism in Tibet"
	ev.description = ("Encouraged by liberals and nationalists, residents of the Tibet Autonomous Region took "
			+ "to mass demonstrations for independence and secession from the PRC, which gradually develop into "
			+ "unrest. People demand \"liberation\" from \"the occupation of 1950\" and the majority of ethnic "
			+ "Tibetans support them. However, some are just satisfied with the requirements of greater autonomy "
			+ "than we can take advantage of.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：允许独立
	ev.options.append(option(
		"Allow independence",
		"Tibet Autonomous Region officially declared its independence within the borders of 1950. "
		+ "This will be a big blow for us and a great opportunity for the USSR and the USA.",
		[add_resource("people_support", -200), add_resource("party_support", -200),
		add_resource("money", -50), add_resource("manpower", -50)],

		null, ""
	))

	# 选项1：扩大自治权
	ev.options.append(option(
		"Expand autonomy",
		"We have further expanded the powers of local authorities and the rights of Tibetan autonomy. "
		+ "It seems that the majority of the population is satisfied, but it gives the radicals more "
		+ "opportunities to promote separatism, and other national outskirts are thinking about greater independence.",
		[add_resource("party_support", -200), add_resource("manpower", -20)],
		null, ""
	))

	# 选项2：军事镇压
	ev.options.append(option(
		"Send in the PLA to restore order",
		"The loyal parts of the PLA entered Tibet and quickly restored order. But the nationalists "
		+ "and the opposition will not forget this.",
		[add_resource("people_support", -100), add_resource("army", -100),
		add_resource("diplo", 50), add_resource("manpower", 30)],

		null, ""
	))

	# 选项3：组织公投 — 需特工≥50 且 金钱≥40
	ev.options.append(option(
		"Organize a referendum",
		"We organized a referendum in which the majority, of course, voted to preserve the status of Tibet. "
		+ "Dissatisfied nationalists and other radicals took to the streets, claiming falsification, but "
		+ "without past support these protests no longer pose a serious threat.",
		[add_resource("people_support", -20), add_resource("agents", -50),
		add_resource("money", -40), add_resource("manpower", 20)],

		all_of([res_at_least("agents", 50), res_at_least("money", 40)]),
		"Need agents: 50 and money: 40"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event10（新疆分离主义 / Separatism in Xinjiang）
# ========================================================================

static func create_event_10() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "xinjiang_separatism"
	ev.title = "Separatism in Xinjiang"
	ev.description = ("Encouraged by liberals and nationalists, residents of the Xinjiang Uygur Autonomous Region "
			+ "took to mass demonstrations for independence and secession from the PRC, which gradually develop "
			+ "into unrest. People demand \"liberation\" from \"the occupation of 1949\" and the majority of "
			+ "ethnic Uighurs support them. However, there is a counterweight to them from the Hanzu, and some "
			+ "of the Uighurs are just satisfied with the requirements of greater autonomy than we can take "
			+ "advantage of.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	# 选项0：允许独立
	ev.options.append(option(
		"Allow independence",
		"Xinjiang Uygur Autonomous Region officially declared its independence. This will be a big blow "
		+ "for us and a great opportunity for the USSR and the USA.",
		[add_resource("people_support", -200), add_resource("party_support", -200),
		add_resource("money", -50), add_resource("manpower", -50)],

		null, ""
	))

	# 选项1：扩大自治权
	ev.options.append(option(
		"Expand autonomy",
		"We have further expanded the powers of local authorities and the rights of Xinjiang autonomy. "
		+ "It seems that the majority of the population is satisfied, but it gives the radicals more "
		+ "opportunities to promote separatism.",
		[add_resource("party_support", -200), add_resource("manpower", -20)],
		null, ""
	))

	# 选项2：军事镇压
	ev.options.append(option(
		"Send in the PLA to restore order",
		"The loyal parts of the PLA entered Xinjiang and quickly restored order. But the nationalists "
		+ "and the opposition will not forget this.",
		[add_resource("people_support", -100), add_resource("army", -100),
		add_resource("diplo", 50), add_resource("manpower", 30)],

		null, ""
	))

	# 选项3：组织公投 — 需特工≥50 且 金钱≥40
	ev.options.append(option(
		"Organize a referendum",
		"We organized a referendum in which the majority, of course, voted to preserve the status of "
		+ "Xinjiang. Dissatisfied nationalists and other radicals took to the streets, claiming "
		+ "falsification, but without past support these protests no longer pose a serious threat.",
		[add_resource("people_support", -20), add_resource("agents", -50),
		add_resource("money", -40), add_resource("manpower", 20)],

		all_of([res_at_least("agents", 50), res_at_least("money", 40)]),
		"Need agents: 50 and money: 40"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event11（工业衰退 / Industry Decline）
# ========================================================================

static func create_event_11() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "industry_decline"
	ev.title = "The decline of industry"
	ev.description = ("Our industry is in an unprecedented decline - some of the plants are idle, "
			+ "some are about to close and everyone is working on outdated equipment.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	ev.options.append(option(
		"Urgently allocate money for development",
		"Large funds from the budget were urgently allocated for the modernization of the industry, "
		+ "the purchase of imported technologies and the involvement of specialists in this area. "
		+ "The problem starts to be solved",
		[set_resource("industry", 100), add_resource("money", -100)],
		null, ""
	))

	ev.options.append(option(
		"Attract foreign investment",
		"Our campaign to attract foreign investment was a great success! Foreigners themselves now "
		+ "build and modernize our plants without a single yuan from our budget. True, for this it "
		+ "was necessary to reduce the minimum wage, production safety requirements and other "
		+ "requirements of labor legislation, but nothing, the people will suffer.",
		[set_resource("industry", 100), add_resource("living_standard", -50),
		add_empire_relation(EmpireData.USA, -50)],
		all_of([empire_rel_at_least(EmpireData.USA, 600), any_of([res_at_least("development", 13), has_flag("sez")])]),
		"Investors will not go to us"
	))

	ev.options.append(option(
		"Request help from the USSR",
		"The Soviet Union agreed how in the old days to help us with the modernization of industry. "
		+ "However, he doesn't particularly like distributing specialists and machines for nothing, "
		+ "and we've got some dependence on the USSR.",
		[set_resource("industry", 100), add_empire_power(EmpireData.USSR, 10),
		add_empire_relation(EmpireData.USSR, -50), add_empire_relation(EmpireData.USA, -100)],
		empire_rel_at_least(EmpireData.USSR, 700),
		"We don't need handouts from revisionists!"
	))

	ev.options.append(option(
		"Foster development at the expense of agriculture",
		"By the method of redistributing budget funds and revenues from enterprises, we were able "
		+ "to direct the power of agriculture to the development of industry. This helped the "
		+ "industry, but agriculture suffered a big blow.",
		[set_resource("industry", 100), add_resource("food", -100)],  # food = data[13] agriculture
		res_at_least("food", 500),
		"Position in agriculture is not much better"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event12（农业衰退 / Agriculture Decline）
# ========================================================================

static func create_event_12() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "agriculture_decline"
	ev.title = "The decline of agriculture"
	ev.description = ("Our agriculture is in unprecedented decline - there was no such disorder "
			+ "even in times of great leap forward!")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	ev.options.append(option(
		"Urgently allocate money for development",
		"Large funds from the budget were urgently allocated for the modernization of the agriculture...",
		[set_resource("food", 100), add_resource("money", -100)],
		null, ""
	))

	ev.options.append(option(
		"Attract foreign investment",
		"Our campaign to attract foreign investment was a great success! Foreigners themselves now "
		+ "build and modernize our farms without a single yuan from our budget...",
		[set_resource("food", 100), add_resource("living_standard", -50),
		add_empire_relation(EmpireData.USA, -50)],
		all_of([empire_rel_at_least(EmpireData.USA, 600), any_of([res_at_least("development", 13), has_flag("sez")])]),
		"Investors will not go to us"
	))

	ev.options.append(option(
		"Request help from the USSR",
		"The Soviet Union agreed how in the old days to help us with the rise of agriculture...",
		[set_resource("food", 100), add_empire_power(EmpireData.USSR, 10),
		add_empire_relation(EmpireData.USSR, -50), add_empire_relation(EmpireData.USA, -100)],
		empire_rel_at_least(EmpireData.USSR, 700),
		"We don't need handouts from revisionists!"
	))

	ev.options.append(option(
		"Foster development at the expense of industry",
		"By the method of redistributing budget funds, we were able to direct the power of industry "
		+ "to the development of agriculture. This helped the agriculture, but industry suffered a big blow.",
		[set_resource("food", 100), add_resource("industry", -100)],
		res_at_least("industry", 500),
		"Position in industry is not much better"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event13（服务业衰退 / Service Sector Decline）
# ========================================================================

static func create_event_13() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "service_decline"
	ev.title = "The decline of service sector"
	ev.description = ("Our service sector is in terrible decline - most of the stores and "
			+ "establishments do not work, and the quality of service in the working ones is simply terrible.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	ev.options.append(option(
		"Urgently allocate money for development",
		"Large funds from the budget were urgently allocated for the modernization of the service sector...",
		[add_resource("money", -100)],
		null, ""
	))

	ev.options.append(option(
		"Attract foreign investment",
		"Our campaign to attract foreign investment was a great success! Foreigners themselves now "
		+ "build and modernize our shops and restaurants...",
		[add_resource("living_standard", -50), add_empire_relation(EmpireData.USA, -50)],
		all_of([empire_rel_at_least(EmpireData.USA, 600), any_of([res_at_least("development", 13), has_flag("sez")])]),
		"Investors will not go to us"
	))

	ev.options.append(option(
		"Request help from the USSR",
		"The Soviet Union agreed how in the old days to help us with the development of the service sector...",
		[add_empire_power(EmpireData.USSR, 10),
		add_empire_relation(EmpireData.USSR, -50), add_empire_relation(EmpireData.USA, -100)],
		empire_rel_at_least(EmpireData.USSR, 700),
		"We don't need handouts from revisionists!"
	))

	ev.options.append(option(
		"Foster development at the expense of agriculture and industry",
		"By the method of redistributing budget funds, we were able to direct the power of industry "
		+ "and agriculture to the development of services sector. This helped the services sector, "
		+ "but industry and agriculture suffered a big blow.",
		[add_resource("food", -100), add_resource("industry", -100)],
		any_of([res_at_least("industry", 500), res_at_least("food", 500)]),
		"Position in agriculture and industry is not much better"
	))

	return ev


# ========================================================================
# 事件迁移 —— Event14（财政危机 / Budget Crisis）
# ========================================================================

static func create_event_14() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "budget_crisis"
	ev.title = "We have no money, but you hang in there!"
	ev.description = ("There is too little money in our budget and reserve fund. If it continues "
			+ "like this, we soon will not be able to maintain the normal work of our state.")
	ev.fire_only_once = true
	ev.mtth_base = 0.0

	ev.options.append(option(
		"Raise taxes and cut social programs",
		"Taxes and fees were raised, and social programs for the population were reduced. "
		+ "It helped, of course, to replenish the budget, but the people are not happy.",
		[add_resource("people_support", -100), add_resource("money", 100),
		add_resource("living_standard", -300)],
		all_of([res_at_least("development", 13), res_at_least("living_standard", 500)]),
		"Need development >= 13 and living standard >= 500"
	))

	ev.options.append(option(
		"Raise taxes on luxury and for the super rich",
		"Taxes on luxury and super-wealth were raised, which made it possible to replenish the "
		+ "budget without hurting the common people.",
		[add_resource("money", 100), add_resource("party_support", -500),
		add_empire_relation(EmpireData.USA, -50)],
		res_at_least("development", 14),
		"We have no oligarchs"
	))

	ev.options.append(option(
		"Take a foreign loan",
		"A foreign loan was taken, which helped replenish the budget, but had a negative impact "
		+ "on our influence. Yes, and you still have to pay it...",
		[add_resource("money", 100)],
		any_of([empire_rel_at_least(EmpireData.USA, 500),
				all_of([empire_rel_at_least(EmpireData.USSR, 500), res_at_least("political", 50)])]),
		"Nobody wants to give us credit"
	))

	ev.options.append(option(
		"Conduct rapid privatization of state-owned enterprises",
		"Many state-owned enterprises were sold into private hands, which of course hit the "
		+ "standard of living and disrupted the mechanism of our economy, but it helped replenish the budget.",
		[add_resource("living_standard", -100), add_resource("money", 100),
		add_resource("industry", -50), add_resource("food", -50)],
		null, ""
	))

	return ev


# ========================================================================
# 事件迁移 —— Event15（柬越战争 / Cambodian-Vietnamese War）
# ========================================================================

static func create_event_15() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "cambodian_vietnam_war"
	ev.title = "Cambodian-Vietnamese war"
	ev.description = ("For several years, ruling in Democratic Kampuchea, the Red Khmers of Pol Pot "
			+ "pursued an openly aggressive policy towards neighboring Vietnam, often attacking border "
			+ "villages and killing civilians en masse. And it seems that Vietnam's patience has come "
			+ "to an end - quite recently the Vietnamese army launched a full-scale invasion of Cambodia "
			+ "to overthrow the Pol Pot regime...")
	ev.fire_only_once = true
	ev.mtth_base = 0.0
	# 原作 TimeScript：1976.12+ 或 1977 年
	ev.trigger_conditions = [date_after("1976.12")] as Array[ExprNode]

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
		[add_resource("agents", -30),
		start_war(1, 450, 550, -1, 1, "Kampuchea", "Vietnam")],
		res_at_least("agents", 30),
		"We can't remove Pol Pot"
	))

	ev.options.append(option(
		"Help the Khmer Rouge",
		"We sent help to our old ally, Pol Pot, but it is not known whether this is enough for him...",
		[add_resource("army", -50), add_resource("money", -10),
		add_empire_relation(EmpireData.USSR, -50),
		start_war(1, 400, 600, -1, 1, "Kampuchea", "Vietnam")],
		null, ""
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

	ev.options.append(option(
		"Long live the peace!",
		"Another war ended. The outcome depends on the specific conflict.",
		[],
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
# 批量迁移辅助
# ========================================================================

## 扫描原版事件脚本目录，为每个 C# Event 文件生成对应的 .tres
## 注意：此函数需要已实现的迁移映射表。
## 当前仅作框架 — 具体事件按 create_event_XXX 逐个实现。
static func batch_migrate(output_dir: String = "res://场景/事件界面/events/") -> void:
	# 已迁移的事件列表
	var migrated := [
		{"func": create_event_1, "filename": "event_001_elections.tres"},
		{"func": create_event_3, "filename": "event_003_death_of_mao.tres"},
		{"func": create_event_4, "filename": "event_004_conspiracy.tres"},
		{"func": create_event_6, "filename": "event_006_low_living.tres"},
		{"func": create_event_7, "filename": "event_007_diplo_crisis_usa.tres"},
		{"func": create_event_8, "filename": "event_008_diplo_crisis_ussr.tres"},
		{"func": create_event_9, "filename": "event_009_tibet_separatism.tres"},
		{"func": create_event_10, "filename": "event_010_xinjiang_separatism.tres"},
		{"func": create_event_11, "filename": "event_011_industry_decline.tres"},
		{"func": create_event_12, "filename": "event_012_agriculture_decline.tres"},
		{"func": create_event_13, "filename": "event_013_service_decline.tres"},
		{"func": create_event_14, "filename": "event_014_budget_crisis.tres"},
		{"func": create_event_15, "filename": "event_015_cambodian_vn_war.tres"},
		{"func": create_event_16, "filename": "event_016_thailand_elections.tres"},
		{"func": create_event_17, "filename": "event_017_thailand_instability.tres"},
		{"func": create_event_18, "filename": "event_018_war_is_over.tres"},
		{"func": create_event_19, "filename": "event_019_five_no_hua.tres"},
		{"func": create_event_20, "filename": "event_020_criticize_deng.tres"},
		{"func": create_event_21, "filename": "event_021_wenhuibao_article.tres"},
		{"func": create_event_22, "filename": "event_022_tiananmen_incident.tres"},
		{"func": create_event_23, "filename": "event_023_tangshan_earthquake.tres"},
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
