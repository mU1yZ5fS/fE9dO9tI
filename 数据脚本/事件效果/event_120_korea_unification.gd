extends "res://数据脚本/event_script_base.gd"

## 原作 Event120.cs：韩朝统一，不再分离（朝鲜半岛统一后领导人选择，4/6 选项动态）。
## 触发：全目录 grep 仅见 GlobalScript.cs:20 决策 StartEvent(120)，原版无自动条件
##   （决策/其他事件链手动触发），故 trigger_conditions=[]。
## 差异：
##  - allcountries[10].parts[0] 动态分支（6/4 选项）由 prepare 改写文本与 enable_condition；
##  - numberOfSpecialEnding→CountryData.special_ending；cw→内战中；
##  - JoinAllOurAlliances(true)/JoinOurEconomicAlliance(true) 按玩家联盟标签近似映射；
##  - 原版按钮销毁（parts[0] 分支隐藏 opt4/opt5）以置空文本+禁用来近似。

const TXT_DESC_SIX := "在我们的帮助下，韩国被内部左翼分子推翻，并与朝鲜和平统一，但是按照协定，朝鲜半岛将会进行一场宪政大会，在这场大会上的获胜者将会统领朝鲜。由于我们为半岛的社会主义事业做的巨大贡献，我们在这场大会上拥有举足轻重的话语权，我们可以决定谁来统领朝鲜半岛。这次大会我们有六个人选。第一个是北朝鲜内部主管意识形态方面的黄长烨。第二个是南韩的左翼温和政治家金哲。第三个则是金日成接班人之一的金英柱。第四个是南韩著名劳工运动者和工人诗人朴劳解。第五个是来自南韩的反对主体思想的马克思主义理论家蔡万洙。第六个人是南韩马克思主义经济学教授尹素英。"
const TXT_DESC_UNIFIED := "在我们的帮助下，朝鲜半岛最终取得了统一。起先苏联并不愿介入这场新冲突，朝鲜也缺乏其他强力盟友，但无所谓，我们会出手，朝鲜只有，也只能是依靠我们，才能得以取胜。与此同时，通过战争统一的朝鲜民主主义人民共和国，在社会的各个领域都充溢着我国派出的专家、顾问与军事参谋，我们也因而在这里取得了举足轻重的话语权。得益于此，我们将有权决定新生统一朝鲜未来的发展道路。共有四位领导人可供选择——其中两位是金日成的儿子：金日成指定的接班人金正日，和被我们捏住把柄的金平日；而另外两位则来自南方：一是所谓“南朝鲜主体思想派”的领导人金荣焕，一是视主体思想为反无产阶级理论的反美左翼工会主义者权永吉。"
const TXT_OPT1 := "没有文化大革命，非极左派主导"
const TXT_OPT2 := "支持金哲的进步派系"
const TXT_OPT3 := "没有文化大革命，非极左/保守派主导"
const TXT_OPT4 := "支持金英柱的正统派"
const TXT_OPT5 := "没有文化大革命，非改革/自由派主导"
const TXT_OPT6 := "支持朴劳解的半岛式社会主义"
const TXT_OPT7 := "极左/保守派主导"
const TXT_OPT8 := "支持蔡万洙的正统列宁主义"
const TXT_OPT9 := "有文化大革命，极左/保守派主导"
const TXT_OPT10 := "支持尹素英的马克思主义新实验"
const TXT_OPT11 := "没有文化大革命，非极左/保守派主导"
const TXT_R0 := "黄长烨支持主体思想，但是认为苏东集团的市场化改革和党内民主是社会主义的出路。在我们的帮助下，黄长烨将会带领朝鲜实行类似卡达尔匈牙利的经济体制。"
const TXT_R1 := "金哲是韩国被解散的政党统一社会党的党首，统一社会党曾加入过社会党国际，而金哲本人也一直支持和传播民主社会主义。在我们的帮助下，朝鲜将会实现民主与社会主义的统一，摆脱主体思想的束缚。"
const TXT_R2 := "金英柱虽然也支持主体思想，与黄长烨不同，金英柱支持计划经济的同时强调自立更生，他将会继续进行先军政策和反美主义并继续神话金日成家族。"
const TXT_R3 := "朴劳解将与左翼学生运动中的制宪会议派（CA）进行合作，制宪会议派比较支持列宁主义和民族解放的结合。在我们的帮助下，朝鲜开始探索本土式社会主义的道路。"
const TXT_R4 := "蔡万洙支持斯大林主义，反对苏联修正主义，比较认可朝鲜的建设成果但对主体思想持负面态度。在我们的帮助下，蔡万洙将彻底实行列宁主义。"
const TXT_R5 := "尹素英支持阿尔都塞主义，并认为国家资本主义是一种官僚主义，因此应当实行工人自治与类似新经济政策的经济制度。"
const TXT_P0_OPT0 := "金正日-子承父业"
const TXT_P0_OPT1 := "金平日-提线木偶"
const TXT_P0_OPT2 := "金永焕-粉饰的主体思想"
const TXT_P0_OPT3 := "权永吉-主体思想的落幕"
const TXT_P0_OPT1_DIS := "所需特工网络和预算不足：{0}"
const TXT_P0_OPT3_DIS := "没有毛主义，没有文化大革命，特工网络不足：{0}"
const TXT_DEAD_EXIT := "\n按D退出该界面"
const TXT_P0_R0 := "金正日，作为金日成长期以来指定的继承人，被任命为统一朝鲜的国家领导人，而他的父亲仍然是劳动党的领导人，这是顺理成章的事情，朝鲜政治也不太可能因此发生任何重大变化。毕竟我们不需要变化，不是吗？"
const TXT_P0_R1 := "金平日，金正日的弟弟，因为年轻时懒惰酗酒而失宠于父亲。但现在，在我们的影响下，我们可以将他扶植为统一朝鲜的首脑，这样，他实际上将成为我们的直接傀儡。没有了我们，被重重丑闻缠身，他能成何气候？！"
const TXT_P0_R2 := "金永焕长期以来一直是韩国所谓的“主体思想派”的领袖，是一个受南北共同认可的优秀候选人：一个积极分子、一个马克思主义者、一个勤学好问且具有创造性的工人权利活动家。他将是一个值得被所有人接受的候选人。"
const TXT_P0_R3 := "在作为一名记者的同时，权永吉也是一位反美、反殖民、反威权的左翼工会领袖。只有在这样一位通于体谅、八面玲珑的政治家领导下，南北撕裂带来的伤痕才得以弥合。同时，由于他与南方工会运动以及马克思主义人民民主运动的各方都有联系，这使得我们可以在尽可能短的时间内平息南朝鲜的反抗与不满情绪。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 6:
		return
	var korea := world.get_country_by_legacy_index(10)
	var parts0 := korea != null and korea.parts.size() > 0 and korea.parts[0]
	var opt := event_def.options
	if parts0:
		event_def.description = TXT_DESC_UNIFIED
		_enable(opt[0], TXT_P0_OPT0)
		if _res_at_least(world, W.I_AGENTS, 250) and _res_sum_at_least(world, W.I_BUDGET, W.I_RESERVE, 250):
			_enable(opt[1], TXT_P0_OPT1)
		else:
			_disable(opt[1], TXT_P0_OPT1_DIS.format([25]))
		_enable(opt[2], TXT_P0_OPT2)
		if _res_at_least(world, W.I_AGENTS, 50) and not _mod_active(world, GameConstants.Modifier.MAOIST_BULWARK) and not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION):
			_enable(opt[3], TXT_P0_OPT3)
		else:
			_disable(opt[3], TXT_P0_OPT3_DIS.format([5]))
		_disable(opt[4], "")
		_disable(opt[5], "")
	else:
		event_def.description = TXT_DESC_SIX
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) != 0:
			_enable(opt[0], event_def.options[0].text)
		else:
			_disable(opt[0], TXT_OPT1)
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) > 1:
			_enable(opt[1], TXT_OPT1)
		else:
			_disable(opt[1], TXT_OPT3)
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) < 3:
			_enable(opt[2], TXT_OPT2)
		else:
			_disable(opt[2], TXT_OPT5)
		if _data_value(world, W.I_POLITICAL_LINE) < 2:
			_enable(opt[3], TXT_OPT3)
		else:
			_disable(opt[3], TXT_OPT7)
		if _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) < 3:
			_enable(opt[4], TXT_OPT4)
		else:
			_disable(opt[4], TXT_OPT9)
		if not _mod_active(world, GameConstants.Modifier.CULTURAL_REVOLUTION) and _data_value(world, W.I_POLITICAL_LINE) > 1:
			_enable(opt[5], TXT_OPT5)
		else:
			_disable(opt[5], TXT_OPT11)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var korea := ws.get_country_by_legacy_index(10)
	var parts0 := korea != null and korea.parts.size() > 0 and korea.parts[0]
	var opt := int(context.get("option_index", -1))
	if parts0:
		match opt:
			0:
				context["result_text"] = TXT_P0_R0
				_set_special(korea, 0)
			1:
				context["result_text"] = TXT_P0_R1
				_add(W.I_AGENTS, -250)
				_add(W.I_BUDGET, -250)
				_add(W.I_INFLUENCE, 5)
				_set_special(korea, 1)
				_join_our_alliances(korea)
			2:
				context["result_text"] = TXT_P0_R2
				_add(W.I_DIPLO, 50)
				_set_special(korea, 2)
			3:
				context["result_text"] = TXT_P0_R3
				_add(W.I_DIPLO, -50)
				_add(W.I_AGENTS, -50)
				_set_special(korea, 3)
				_join_economic_alliance(korea)
	else:
		_add(W.I_AGENTS, -100)
		_add(W.I_BUDGET, -100)
		ws.influence_prc += 10
		if korea != null:
			_set_parts0(korea)
			korea.special_ending = opt
			_join_our_alliances(korea)
			korea.内战中 = true
		match opt:
			0:
				context["result_text"] = TXT_R0
				if korea != null:
					korea.government = GameConstants.Government.REFORMIST
					korea.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
			1:
				context["result_text"] = TXT_R1
				if korea != null:
					korea.government = GameConstants.Government.REFORMIST
					korea.sub_government = GameConstants.SubGovernment.DEMOCRATIC_SOCIALIST
			2:
				context["result_text"] = TXT_R2
				if korea != null:
					korea.government = GameConstants.Government.AUTHORITARIAN
					korea.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
			3:
				context["result_text"] = TXT_R3
				if korea != null:
					korea.government = GameConstants.Government.SOCIALIST
					korea.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			4:
				context["result_text"] = TXT_R4
				if korea != null:
					korea.government = GameConstants.Government.SOCIALIST
					korea.sub_government = GameConstants.SubGovernment.MARXIST_LENINIST
			5:
				context["result_text"] = TXT_R5
				if korea != null:
					korea.government = GameConstants.Government.REFORMIST
					korea.sub_government = GameConstants.SubGovernment.TITOIST


func _set_special(c: CountryData, value: int) -> void:
	if c != null:
		c.special_ending = value


func _set_parts0(c: CountryData) -> void:
	if c == null:
		return
	if c.parts.size() == 0:
		c.parts.resize(1)
	c.parts[0] = true


## JoinAllOurAlliances(true)：复制玩家主要联盟标签（同 Event713 约定）。
func _join_our_alliances(c: CountryData) -> void:
	if c == null:
		return
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("okb"):
		c.set_tag("okb", true)
	elif player.has_tag("ovd"):
		c.set_tag("ovd", true)
	elif player.has_tag("seato"):
		c.set_tag("seato", true)
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)
	elif player.has_tag("asean"):
		c.set_tag("asean", true)


## JoinOurEconomicAlliance(true)：仅经济联盟（同 Event650 约定）。
func _join_economic_alliance(c: CountryData) -> void:
	if c == null:
		return
	var player := ws.get_country_by_legacy_index(1)
	if player == null:
		return
	if player.has_tag("econ"):
		c.set_tag("econ", true)
	elif player.has_tag("sev"):
		c.set_tag("sev", true)


func _res_at_least(world: WorldState, index: int, threshold: int) -> bool:
	return world.size() > index and world.get_data_by_index(index) >= threshold


func _res_sum_at_least(world: WorldState, a: int, b: int, threshold: int) -> bool:
	var sum := 0
	if world.size() > a:
		sum += world.get_data_by_index(a)
	if world.size() > b:
		sum += world.get_data_by_index(b)
	return sum >= threshold


func _data_value(world: WorldState, index: int) -> int:
	if world.size() > index:
		return world.get_data_by_index(index)
	return 0


func _mod_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null and world.modifiers[index].is_active



