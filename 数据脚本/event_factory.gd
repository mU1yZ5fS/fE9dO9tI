# ============================================================================
# EventFactory — 事件工厂（编程方式构建事件定义）
# ============================================================================
# 【已冻结 · 2026-08】不再扩展、不再用于生产事件。
# 实际事件创作路径（唯一权威源）：
#   1. 简单事件 → 手写 .tres（场景/事件界面/events/，EventDef + EffectNode 声明式）
#   2. 复杂事件 → 手写 .tres 中挂 CUSTOM_SCRIPT → 事件效果脚本（数据脚本/事件效果/，
#      继承 event_script_base.gd，逐字复刻原版 C# 逻辑）
# 74 个 .tres 中 64 个（86%）走 CUSTOM_SCRIPT；ExprNode/EffectNode 枚举仅服务少数
# 简单事件与既有资源。新需求禁止向 ExprNode/EffectNode/EventFactory 追加枚举或函数；
# 引擎 evaluate()/execute() 的现有分支继续兜底旧 .tres（枚举整数不可前插，只可追加）。
#
# 本文件保留用途：
#   - 迁移示例参考（create_event_120 等，展示 ExprNode/EffectNode 用法）
#   - 若确需重新生成 .tres，可手工调用单个 create_event_XXX。
#
# 使用方式（历史）：
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
# ========================================================================
# 事件迁移 —— 示例：Event300（中苏同盟破裂后的东欧选择）
# ========================================================================

static func create_event_300() -> EventDef:
	var ev := EventDef.new()
	ev.event_id = "sino_soviet_split_eastern_europe"
	ev.title = "东方抉择"
	ev.description = "中苏同盟已经名存实亡。东欧的社会主义国家必须在两个老大哥之间做出选择。"
	ev.fire_only_once = true

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
	# 事件 014-020 已改为手写 .tres（唯一权威源），不经生成器。
	# 事件 five_no（原 Event19 五不准）已按 Event19.cs 逐字复刻，不经生成器。
	var migrated := [
		{"func": create_event_21, "filename": "event_021_wenhuibao_article.tres"},
		{"func": create_event_22, "filename": "event_022_tiananmen_incident.tres"},
		{"func": create_event_23, "filename": "event_023_tangshan_earthquake.tres"},
		{"func": create_event_24, "filename": "event_024_post_mao_course.tres"},
		{"func": create_event_25, "filename": "event_025_gang_of_four.tres"},
		{"func": create_event_26, "filename": "event_026_weak_alliance.tres"},
		{"func": create_event_120, "filename": "event_korea_unification.tres"},
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
