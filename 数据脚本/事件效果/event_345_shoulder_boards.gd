extends "res://数据脚本/event_script_base.gd"

## 原作 Event345.cs：肩上的那块牌子。触发：ReqEventForDLC02.cs:607-610 —— 日期>=1984.6.5。
## 差异：
##  - 原版 VariantsOfEvents 动态销毁按钮：按 data[56]（政治路线）、resultOfEvents[514]、modifies[6].active
##    决定两个按钮文案/可用性，这里在 prepare 动态 _enable/_disable 复刻；
##  - 原版 TextOfEvents 按 vietnampeace / resultOfEvents[378] / allcountries[10].puppetOf 动态拼描述；
##    vietnampeace 端口建模说明 → 用 global_flags 同名键近似（项目既有约定）；
##  - 原版对 old_modify_desc[50] 的拼接是展示文案，Godot 由修正目录统一管理，这里跳过并注释原文。

const TXT_TITLE := "肩上的那块牌子"

const TXT_DESC_BASE := "随着我国军队的进一步发展，也许是时候谈谈一个被遗忘的问题了。主席同志，作为中央军委的一员，您应该知晓我国军队与他国军队的一个显著特征：我国没有军衔的概念，至少在过去的一段时间内没有。在1955年开始，我国短暂的实行过军衔制，效法苏联设立了多个军种和军衔。但随着我国在各个方向上试图击溃苏联所代表的一切，军衔自然作为修正主义的一部分被打倒。毛泽东主席在讲话中多次强调，高级干部要注意学习马列主义，防止脱离群众,加强干部特别是高级干部的革命化建设。1964年前后，他认为，军队高级干部工资过高，和一般干部和人民群众差距太大，难以体验人民群众的疾苦，容易脱离群众，产生资产阶级思想，因此提出了军队高级干部减薪问题，以此作为防止修正主义的一项措施。\n在林彪取代彭德怀主持军委工作后，大力宣扬“突出政治”。在这种观念影响下，一些人认为，军衔制等级分明，不符合人民解放军官兵一致的原则，不利于干部和士兵打成一片，因此也不利于继承光荣传统。这种对“革命化”建设的片面理解，加之人民军队几十年战争时期没有军衔制度而取得革命的胜利，也使许多人认为实行军衔制并无必要。\n"
const TXT_DESC_VISITS := "在我国回到了世界舞台后，大量的军事代表团也曾来我国访问。他们对于我们缺少军衔这一点感到十分不解。解放军的空军大校在会见伊朗空军代表团时曾被问到“你的上级呢？”这样让人啼笑皆非的问题，险些导致外交纠纷。因此，有些同志认为我们该考虑恢复军衔了。"
const TXT_DESC_NO_VISITS := "而事实证明，我们在一定程度上是错误的。军队并非一个“一个阶级压迫另一个阶级”的小社会，而是相互协作的大学校。在战场上，任何一个地方出现的问题都会导致战术上的错误，而牺牲是不可避免但难以接受的。而我们缺乏区分度和军衔导致了我方命令的混乱，许多同志提议我们恢复军衔。"
const TXT_DESC_TAIL := "\n但仍然有不少同志认为，现行制度没有什么不好的，毕竟现行制度体现了官军平等的思想，这也是在大会上由军队上下选举所得到的结果。所以，您怎么看？"

const TXT_OPT0_EN := "我就是看不惯那两块牌牌，讨嫌！"
const TXT_OPT0_DIS := "这套理论过时啦！"
const TXT_OPT1_EN := "好吗，我觉得就该恢复军衔了！"
const TXT_OPT1_DIS := "我们的军队可不是什么资产阶级大学校"

const TXT_R0 := "最终，我国决定继续保持过去的设计。毕竟时间和实践已经证明了我们的正确性。过去没有军衔，也一样打胜仗。这种制度不符合我军的优良传统，它是一种资产阶级法权，等级表面化，助长了个人名位思想和等级观念。不利于我军的革命化建设，不利于同志之间、上下级之间和军民之间的团结。同时增加了各级党委和政治机关不少繁琐事务。\n我军是中国共产党和毛主席缔造，领导的人民军队。官兵一致，上下一致，军民一致是我军固有的优良传统。我们的干部和战士，都是亲密的战友和阶级兄弟。我们军队和人民血肉相连，鱼水相亲。在过去长期的革命战争中，我军是没有军衔制度的。全国胜利以后，在1955年才开始实行。十年的实践证明，实行军衔制度，与我军的光荣传统是不相符合的，与官兵之间，上下级之间，军民之间的亲密关系也是不相适应的。我军的建设，最根本的是以毛泽东思想为指针，加强政治思想工作，提高全体指战员的阶级觉悟，培养优良作风，提高军事素质，使我军更加无产阶级化，更加战斗化。因此，取消军衔制度是完全正确的、完全必要的。取消军衔制度，有利于官兵之间、上下级之间、军民之间的团结，有利于进一步发扬我军的光荣传统。就像毛泽东主席曾经说过的那样：“取消！搞掉那块牌牌！”"
const TXT_R1 := "我们最终决定恢复过去的军衔制，事实上早在1979年9月，总政治部最早提出恢复军衔制，该部在全军干部工作会上提交《恢复军衔制度的初步方案》。经过会议讨论，军队拟改革和完善六项制度，其中第五项就是军衔制度。该次会议结束后，总政治部于同年11月向中央军委呈报《关于加强干部队伍建设若干问题的请示报告》，正式以文字形式提出“恢复军衔制”的建议。但当时我们并没有多加考虑，事实证明我们非常有必要这么做：据一位退伍军人的回忆录所述，某次在公路上几支不同部队挤在了一起，谁也不愿让其他人先过，导致行军速度极慢、秩序也非常混乱，这时一名师长就爬到了一辆坦克上，大声喊自己是师长，让卡车靠左，坦克靠右，战士从中间走。但他佩戴的红领章、红帽徽与其他人都一样，没有人相信他的话，依然还是挤成一团，费了很多时间各部才得以通过。这是在行军还算好，如果遇到敌人偷袭呢？没有一个军衔高的出来指挥，大家还是会各自作战，后果不堪设想。\n"
const TXT_R1_NORMAL := "和1955年的规划相比，我国不再设有一级上将以上的职位。在人民大会堂，主席同志亲自为30位解放军各阶层的官员授予了军衔。"
const TXT_R1_SPECIAL := "英明的领袖就要做出英明的决策，华国锋同志决定彻底恢复1955年的军衔制度。并追授给我们永远的导师毛泽东主席为大元帅，而华国锋同志和其余30多位同志一起在人民大会堂内参加了军衔制恢复以来第一次的授衔仪式。华国锋同志则被授予了元帅军衔，这是他应得的！"

# 原版 old_modify_desc[50] 展示文案（跳过运行时覆盖，仅保留原文供溯源）：
# |没有军衔的军队：|人民支持度+0.3，军力+0.2，干涉点数+0.2
# |恢复军衔：|军力+0.5，干涉点数+0.2，腐败+0.2，资金-0.1


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	event_def.title = TXT_TITLE
	var korea := world.get_country_by_legacy_index(10)
	var desc := TXT_DESC_BASE
	var res378 := int(world.completed_event_ids.get("event_378", 0))
	if world.get_flag("vietnam_peace") and res378 != 2 and (korea == null or korea.puppet_of != 1):
		desc += TXT_DESC_VISITS
	else:
		desc += TXT_DESC_NO_VISITS
	desc += TXT_DESC_TAIL
	event_def.description = desc

	var opt := event_def.options
	@warning_ignore("shadowed_variable_base_class")
	var d := world.数值表
	var pol := d[W.I_POLITICAL_LINE] if d.size() > W.I_POLITICAL_LINE else 0
	var res514 := int(world.completed_event_ids.get("event_514", 0))
	if (pol <= 2 and res514 != 1) or res514 == 2:
		_enable(opt[0], TXT_OPT0_EN)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	var mod6 := _modifier_active(world, 6)
	if (pol >= 2 and res514 != 2) or res514 == 1 or not mod6:
		_enable(opt[1], TXT_OPT1_EN)
	else:
		_disable(opt[1], TXT_OPT1_DIS)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			for p in ws.politicians:
				if p.trait_personality == 0:
					p.power += 25
					p.loyalty += 50
			_add(W.I_MANPOWER, 15)
			_add(W.I_DIPLO, 25)
			context["result_text"] = TXT_R0
		1:
			var text := TXT_R1
			var china := ws.get_country_by_legacy_index(1)
			if china != null and china.sub_government != 19:
				text += TXT_R1_NORMAL
			else:
				text += TXT_R1_SPECIAL
			for p in ws.politicians:
				if p.trait_personality == 0:
					p.power -= 25
					p.loyalty -= 50
			_add_relation(0, 25)
			_add(W.I_MANPOWER, 15)
			context["result_text"] = text


func _modifier_active(world: WorldState, index: int) -> bool:
	return world.modifiers.size() > index and world.modifiers[index] != null and world.modifiers[index].is_active


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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)
