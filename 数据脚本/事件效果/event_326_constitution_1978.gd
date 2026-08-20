extends "res://数据脚本/event_script_base.gd"

## 原作 Event326.cs：1978年宪法（5选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:564-567 —— 日>=5 月>=3 年>=1978。
## 差异：描述/选项显隐 prepare 动态改写；party_number→factions.support；old_modify_texts/desc 为修正说明文案跳过。

const TXT_DESC_BASE := "毛主席逝世了，因此，我们的国家需要选定一条通往未来的道路。显然，这应当反映在宪法中。来自多个党派不同代表的数百份提案已经送达，但若是从总体上来看，"
const TXT_DESC_FOUR := "我们有四个选择，分别来自极左派、保守派和温和派、改革派和其他温和派以及自由派。当然，通过任何版本的宪法都会让提出宪法草案的派别一时风头无二。极左派想要开始继续毛和文化大革命的事业，提出了一系列在其他人眼里相当“疯狂”的提案。保守派主张维持现行制度，但要进行渐进的社会主义改革。改革派支持一定程度的经济自由化和私营企业的扩张。至于自由派......自不必说，是回归资本主义。那么，中国将往何处去？"
const TXT_DESC_THREE := "我们有三个选择，分别来自保守派与温和派、改革派与其他温和派以及自由派。当然，通过任何版本的宪法都会让提出宪法草案的派别一时风头无二。保守派主张维持现行制度，但要进行渐进的社会主义改革。改革派支持一定程度的经济自由化和私营企业的扩张。至于自由派......自不必说，是回归资本主义。那么，中国将往何处去？"
const TXT_OPT0_DIS := "极左派"
const TXT_OPT1_DIS := "温和派"
const TXT_OPT2_DIS := "改革派"
const TXT_OPT3_DIS := "自由派"
const TXT_R0 := "考虑到宪法问题不过是国家问题在不同领域内的呈现，“修宪”一词的内涵也就不言而喻。因此，我们决定基于“坚决保障无产阶级专政，坚决对资产阶级实行全面专政”的基调为法律做定义：既然卡尔·马克思已精到地用“打碎”一词为国家机器判处死缓，那作为国家伴生物的律法、执法与司法机器又怎能独善其身？酝酿中的《1978年宪法》很快便成为汇集“文化大革命”时期各类激进思潮的词典，并在高度肯定“群众首倡精神”的同时为自身宣读了悼词：新宪法在援引《1975版宪法》引言，肯定继续革命理论与坚持无产阶级专政的同时精准提出了“资产阶级法权奠基国家与法，而共产主义社会将以社会良善对其摒弃”的观点。从而为我国社会主义之路指明方向。紧接着便是解决作为妥协产物的老宪法内遗留的一系列历史问题：其中最瞩目的当属对过往“砸烂公检法”运动中积极经验的肯定，且落实了谢富治同志总结的“枫桥经验”。我们在审判机关和检察机关内引入了替代选举与群众陪审，允许了人民卫队与群众法庭可在《公安六条》的框架中在地方主持执法、司法事务的替代参与形式。启动了以无产阶级自治组织取代旧有公检法机关的政治革命议程。过去自上而下的“摊派抓人”制度也被群众自我净化、自己揪出坏人为主，公检法人员协助群众办案，同群众组织形成结合制的方案取代。旨在实现议行合一的革命委员会模式也得到进一步巩固，我们开始以引入活水的名义清理“三结合”时为“老干部”与军头安置的政治配额。该组织本身也逐渐同我们巩固与扩大社会主义全民所有制的经济方针相配合——意味着革命委员会将在充当我国各地行政事务办公室的同时成为落实“大寨模式”、“鞍钢宪法”与“教育革命”等管理方案的前线。我们在强调大鸣、大放、大辩论、大字报的社会主义革命形式的同时将“劳动尊严”的概念写入我国公民的基本权利中，将就业岗位配额、最低工资保障与工人参与管理等原则同罢工权与政治自由等量齐观。相关条款很快便会落入到我国人民的生动实践中去：出于立足人民群众生活与将传统的法律规范升格为阶级内道德自觉的需要；我们的新宪法在结构上甚至比往日的《1975年宪法》更为精炼，除却原则性描述与表示坚定无产阶级领导权的祈使句外毫无繁琐条文。以达到人人皆可学法用法，充分自决的水平。这部法律注定会成为国际社会中的异类：有关其“助长无政府状态”，“是人治与法治，成文法与习惯法间二人转”的争议不断。党内保守派对此也意见颇多，可我们确实迈出了试图突破传统体系的一大步……"
const TXT_R1 := "保守派和温和派的宪法草案获得通过。现在我国正式宣布保护工人权利并实行无产阶级民主：委员会的权力再次扩大，工党成立，国家机关和党政机关分离。许多方面，这部宪法与苏联1924年的列宁主义宪法相似，因为该党仍然是国家的先锋队和统治者，并使苏维埃、特殊服务和各部委服从于自己。当然，我们根据实际情况做了些改编，也提及了毛主席。"
const TXT_R2 := "温和派和改革派的宪法草案获得通过。是的，我们的国家确实需要变革，我们如今的道路是通过渐进的改革与变革走向社会主义的徐行之路。“中国没有过资本主义，我们应该经历它，但当然得是在共产党的严格监督下进行。”企业家的权利与普遍的公民自由权利范围立即得到了扩大。当然，苏维埃的力量已不如往昔，但我们仍在向社会主义前进。"
const TXT_R3 := "自由派的宪法草案获得通过。这让很多党员和公民感到震惊不已。现在，中国共产党不是官方的唯一政党，甚至不是执政党。我们只是参加资产阶级民主选举的政党之一。私人财产权范围也显著扩大。当然，这还只是宪法，但其中的条款很可能很快就会落实到实践中去......"
const TXT_R4 := "目前党在团结上便已问题重重。每个派系都想争权夺利，不愿谈判。通过任何一版宪法都将大大加强某一派系的力量，这将导致另一场党内分裂与派系战争。我们可不想这么做。让我们等风平浪静之后再说吧。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world.数值表
	if data.size() <= W.I_POLITICAL_LINE:
		return
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	if mod3:
		event_def.description = TXT_DESC_BASE + TXT_DESC_FOUR
	else:
		event_def.description = TXT_DESC_BASE + TXT_DESC_THREE
	var line := data[W.I_POLITICAL_LINE]
	var opt := event_def.options
	if line <= 1 and mod3 and mod6:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if line == 1 or line == 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if line == 2 or line == 3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if line == 4:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], event_def.options[4].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_faction_support(0, 50)
			_add(W.I_DIPLO, 50)
			ws.influence_prc += 1
			_set_mod_active(28, true)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == 0:
					p.loyalty += 1000
					p.power += 500
				if p.trait_personality == 20:
					p.power -= 200
				if p.trait_personality == 1:
					p.loyalty = 300
					p.power -= 300
				if p.trait_personality == 2:
					p.loyalty = 0
					p.power -= 400
				if p.trait_personality == 3:
					p.loyalty = 0
					p.power -= 500
			if d[W.I_PRESS_POLICY] < 18:
				d[W.I_PRESS_POLICY] += 1
			_set_data(W.I_PARTY_SYSTEM, 6)
			if d[W.I_ECON_SYSTEM] > 11:
				_set_data(W.I_ECON_SYSTEM, 11)
			if d[W.I_RELIGION] > 25:
				_set_data(W.I_RELIGION, 24)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -100)
			_add(W.I_CORRUPTION, -5)
			_add(W.I_BUDGET, 2)
			_add(W.I_AGENTS, 2)
			context["result_text"] = TXT_R0
		1:
			_add_faction_support(1, 50)
			_add_faction_support(2, 50)
			_add(W.I_PEOPLE_SUPPORT, 25)
			_add(W.I_THOUGHT_FREEDOM, 15)
			if d[W.I_PRESS_POLICY] > 18:
				d[W.I_PRESS_POLICY] -= 1
			else:
				d[W.I_PRESS_POLICY] += 1
			_set_mod_active(28, false)
			if d[W.I_PARTY_SYSTEM] > 7:
				_set_data(W.I_PARTY_SYSTEM, 7)
			_set_mod_active(29, true)
			context["result_text"] = TXT_R1
		2:
			_add_faction_support(2, 50)
			_add_faction_support(3, 50)
			_add(W.I_THOUGHT_FREEDOM, 15)
			if d[W.I_PRESS_POLICY] < 18:
				d[W.I_PRESS_POLICY] += 1
			if d[W.I_ECON_SYSTEM] < 15:
				d[W.I_ECON_SYSTEM] += 1
			_add(W.I_DIPLO, -100)
			_set_mod_active(28, false)
			_set_mod_active(30, true)
			if d[W.I_REFORM_STAGE] < 2:
				_set_data(W.I_REFORM_STAGE, 2)
			if d[W.I_ECON_SYSTEM] == 11:
				_set_data(W.I_ECON_SYSTEM, 12)
			elif d[W.I_ECON_SYSTEM] < 13:
				_set_data(W.I_ECON_SYSTEM, 13)
			context["result_text"] = TXT_R2
		3:
			_add_faction_support(4, 50)
			if d[W.I_ECON_SYSTEM] < 15:
				d[W.I_ECON_SYSTEM] += 1
			if d[W.I_PARTY_SYSTEM] < 8:
				d[W.I_PARTY_SYSTEM] += 1
			_add(W.I_DIPLO, -250)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_PARTY_SUPPORT, -50)
			_set_mod_active(28, false)
			_set_mod_active(31, true)
			if d[W.I_REFORM_STAGE] < 2:
				_set_data(W.I_REFORM_STAGE, 2)
			if d[W.I_ECON_SYSTEM] < 14:
				_set_data(W.I_ECON_SYSTEM, 14)
			if d[W.I_PRESS_POLICY] < 17:
				_set_data(W.I_PRESS_POLICY, 17)
			context["result_text"] = TXT_R3
		4:
			_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = TXT_R4

	
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


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value

func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value



func _add_faction_support(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].support += delta

func _add_faction_ideology(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].ideology += delta

## ── 原版 display-only 文案（跳过执行，仅保留供逐字校验） ──
## 无产阶级宪法
## 极左派+3，极左派力量+3，党内支持度-0.5，人民支持度+1.5，思想自由化-1.5，腐败-0.2，预算+0.3，特工网络+0.3
## 75宪法
## 极左派、保守派+1，极左派、保守派力量+1，党内支持度-0.2，人民支持度+0.2，思想自由化-0.2，腐败-0.2，特工网络+0.2
