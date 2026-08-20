extends "res://数据脚本/event_script_base.gd"

## 原作 Event75.cs：伊拉克核问题（以色列“歌剧”行动，四选项）。
## 触发：TimeScript.cs:10556-10562 ——
##   (月>=8 且 年>=1981 或 年>=1982) 且 (data[117]!=9 || c8.Vyshi || c8.Gosstroy!=0)
##   且 c14.dev==0 && c14.puppetOf<0 && c14.SubGosstroy==10。
## 选项显隐（prepare 动态改写，原版 SetActive(false) 等价）：
##   原版 summa_3_2 = 执政联盟支持率（data[15]>7 才计算），Godot 用 factions 复算。
## 差异：选项0/2/3 的按钮文案与可用条件逐字保留；result2 的 {0}{1} 插领导人姓名。

const TXT_R0 := "空袭结束后，萨达姆·侯赛因在伊拉克部长会议的紧急会议上发表了精彩的讲话，他在会上说：“今天在反应堆受到的打击对我们来说不是突然的。当然，这是痛苦的，因为它是革命的伟大成果之一，我们长期以来在政治上、科学上、经济上都非常关心。这不是因为他们害怕伊拉克的原子弹，正如特拉维夫帮派的领导人所说，但是因为他们害怕科学、社会、经济、政治、平衡和紧凑的发展，而这正是为了建设一个新的伊拉克……我们没有国际性的一面，所以我们会推迟所有的借口，因为打击是针对我们的…你知道为什么会发生战争——不仅仅是为了给伊拉克核反应堆一个打击，而且为了阻止伊拉克的崛起……你也明白为什么战争会继续……”我们全力支持萨达姆，谴责“来自以色列的美国雇佣兵的强盗袭击”，并建议向伊拉克提供经济和军事援助，侯赛因愉快地接受了这一提议。尽管伊拉克继续奉行多向外交政策，但在不减少与苏联和美国的合作的情况下，开始转向我们的方向……美国在中东的盟友非常愤怒，但美国自己却表现得异常平静……"

const TXT_R1 := "空袭结束后，萨达姆·侯赛因在伊拉克部长会议的紧急会议上发表了精彩的讲话，他在会上说：“今天在反应堆受到的打击对我们来说不是突然的。当然，这是痛苦的，因为它是革命的伟大成果之一，我们长期以来在政治上、科学上、经济上都非常关心。这不是因为他们害怕伊拉克的原子弹，正如特拉维夫帮派的领导人所说，但是因为他们害怕科学、社会、经济、政治、平衡和紧凑的发展，而这正是为了建设一个新的伊拉克……”伊拉克呼吁联合国谴责以色列的行动，萨达姆得到了苏联和美国两个超级大国的支持。安全理事会要求以色列支付赔偿金，并在未来避免此类行动。在以色列，许多反对派成员，在西蒙·佩雷斯的领导下批评政府的决定。然而，国防部长阿里埃勒·沙龙对这些批评作出了坚定的回应：“我们军事政策的一个组成部分是坚决阻止敌国获得核武器。因此，我们必须将这种威胁消灭在萌芽状态。”根据我们的数据，伊拉克增加了在苏联和美国购买武器的数量，采取了对其军队进行定性再装备的方法。"

const TXT_R2 := "空袭结束后，萨达姆·侯赛因在伊拉克部长会议的紧急会议上发表了精彩的讲话，他在会上说：“今天在反应堆受到的打击对我们来说不是突然的。”当然，这是痛苦的，因为它是革命的伟大成果之一，我们长期以来在政治上、科学上、经济上都非常关心。这并不是因为他们害怕伊拉克的原子弹，正如特拉维夫帮派领导人所说，而是因为他们害怕科学、社会、经济、政治、平衡和紧凑的发展，而这正是为了建设一个新的伊拉克……我们没有国际关系，所以我们会无视所有的借口，因为这次打击是针对我们的。”{0}{1}对于决定提供帮助伊拉克恢复其核计划的提议，萨达姆欣然同意。在以七月革命（图瓦伊萨沙漠）命名的核中心，中国工人出现了，很快，CNP-200核反应堆就被运到了那里（而“摩萨德”特工试图炸毁我们运输船的企图被阻止了）。据我们的科学家称，核武器方面的工作正在全面展开，到1988年，伊拉克将拥有3枚原子弹，到1995年将有5枚。以色列非常愤怒，指责“汉民族沙文主义者”“追求世界霸权”，但苏联和美国还没有对此作出回应……\n然而，一切伊拉克拥有核武器的计划最终被打断了。12月1日以色列进行了第二次空袭，彻底摧毁了反应堆。萨达姆无能为力，只能在伊拉克的核计划恢复元气之前紧紧地靠拢我们的外交立场。"

const TXT_R3 := "我们完全赞同以色列对核反应堆“塔木兹”的空袭，并谴责萨达姆·侯赛因在军国主义、大阿拉伯沙文主义和镇压库尔德少数民族问题上的做法。这在党和人民中引起了严重的误解，经过多年对以色列政策的批评，他们没有想到以色列会得到如此公开的支持。作为回应，伊拉克部长会议发表了一份公报，指责中国“支持特拉维夫的犹太复国主义帮派”，并决定断绝外交关系。我们的大使馆被强行驱逐出巴格达，伊拉克增加了在苏联和美国购买武器的数量，并对其军队进行了定性的重新装备。看起来一场新的战争将在中东爆发…"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	var data := world.数值表
	var line := data[W.I_POLITICAL_LINE] if data.size() > W.I_POLITICAL_LINE else 1
	var party := data[W.I_PARTY_SYSTEM] if data.size() > W.I_PARTY_SYSTEM else 8
	var coal := _coalition_percent(world)
	var policy_left := (line < 3 and party < 8) or (coal > 66 and party > 7)
	var policy_right := (line > 2 and party < 8) or (coal > 66 and party > 7)
	var done36: bool = world.completed_event_ids.has("iraqi_coalition")
	var result36: int = world.completed_event_ids.get("iraqi_coalition", -1)
	var opt := event_def.options
	if opt.size() < 4:
		return
	# 选项0
	if policy_left and done36 and result36 != 3:
		_enable(opt[0], "我们将谴责空袭，并与侯赛因扩大合作（需要8百万预算）")
	elif done36 and result36 == 3:
		_disable(opt[0], "他不是我们的朋友")
	else:
		_disable(opt[0], "萨达姆·侯赛因——一个独裁者和沙文主义者。我们不需要支持他！")
	# 选项1：恒定可用
	_enable(opt[1], "谁在乎？让萨达姆自己给自己擦屁股…")
	# 选项2
	var industry: int = data[W.I_INDUSTRY] if data.size() > W.I_INDUSTRY else 0
	var stage: int = data[W.I_REFORM_STAGE] if data.size() > W.I_REFORM_STAGE else -1
	if industry >= 600 and stage == 0 and done36 and result36 != 3 and policy_left:
		_enable(opt[2], "我们将帮助伊拉克恢复其核计划。让帝国主义战栗吧！（需要15百万元，10特工）")
	elif done36 and result36 == 3:
		_disable(opt[2], "他不是我们的朋友")
	else:
		_disable(opt[2], "给伊拉克核武器？！你想发动第三次世界大战吗？")
	# 选项3
	if policy_right:
		_enable(opt[3], "我们将称许空袭，并谴责侯赛因的军国主义和沙文主义")
	else:
		_disable(opt[3], "我们不能为犹太复国主义者的所作所为辩护！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var iraq := ws.get_country_by_legacy_index(14)
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_BUDGET, -80)
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			if iraq != null:
				iraq.set_tag("对华贸易", true)
			context["result_text"] = TXT_R0
		1:
			_add_power(EmpireData.USA, 10)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PARTY_SUPPORT, 50)
			_add_power(EmpireData.USSR, -10)
			_add(W.I_DIPLO, 80)
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -100)
			if iraq != null:
				iraq.set_tag("亲苏", false)
				iraq.set_tag("对华贸易", true)
				iraq.set_tag("亲中", true)
			context["result_text"] = TXT_R2.replace("{0}{1}", _leader_name())
		3:
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_DIPLO, -40)
			ws.influence_prc -= 20
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, 50)
			if iraq != null:
				iraq.set_tag("对华贸易", false)
			context["result_text"] = TXT_R3


## 原版 summa_3_2：data[15]>7 时，保守派 + 结盟且启用的小党，占总席位百分比。
func _coalition_percent(world: WorldState) -> int:
	var data := world.数值表
	if data.size() <= W.I_PARTY_SYSTEM or data[W.I_PARTY_SYSTEM] <= 7:
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








func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"
