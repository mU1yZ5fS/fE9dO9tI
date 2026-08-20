extends "res://数据脚本/event_script_base.gd"

## 原作 Event504.cs：整个波兰都在摇滚！（4选项）。
## 触发来源见 .tres 与脚本头。文本逐字对齐原版（去空格/||换行/剥 color）。
## 选项显隐由 prepare 动态改写；result_text 由本脚本动态生成。

const TXT_OPT1_DIS := "我们不可能为修正主义吹哨"
const TXT_OPT2_DIS := "我很反修，让走资派滚"
const TXT_OPT3_DIS := "苏联不会就眼睁睁看着的"
const TXT_R0_A := "很快，新的总统选举发生，亚历山大·克瓦希涅夫斯基率领的“民主左派联盟”打着反对紧缩和腐败的工会领导层，以及自由意志社会主义的口号赢得了选举，但是一上台，该政府立即开始大规模私有化，聘请芝加哥经济学派，实行“休克疗法”….食物价格开始以1000%的速度飙升。"
const TXT_R0_B := "\n莫斯科对发生的事情表示欢迎。克瓦希涅夫斯基正在试图向莫斯科宣誓表示自我为“社会主义开放与活力的橱窗”-而与此同时，戈尔巴乔夫计划将波兰作为寻访东欧的第一站，他称呼发生在哪里的事情是“未来走向民主和平的新社会主义世界的前兆”。"
const TXT_R0_C := "\n莫斯科对发生的事情感到担忧。也许很快，我们要看到第三次“华沙之春”的发生…但目前为止，克瓦希涅夫斯基正在试图向莫斯科宣誓表示自我为“社会主义开放与活力的橱窗”-这能阻止即将到来的干预吗？"
const TXT_R1_A := "我方外交部官方支持克瓦希涅夫斯基的崛起。“在当代波兰剧烈变化的历史进程中，在人生的崎岖坎坷的旅途中，克瓦希涅夫斯基始终朝气蓬勃、锐意进取，始终站在为国家为民族兴盛而奋斗的前沿。”-这是我们的报纸上对他的描述。\n很快，新的总统选举发生，亚历山大·克瓦希涅夫斯基率领的“民主左派联盟”打着反对紧缩和腐败的工会领导层，以及自由意志社会主义的口号赢得了选举，但是一上台，该政府立即开始大规模私有化，聘请芝加哥经济学派，实行“休克疗法”….食物价格开始以1000%的速度飙升。"
const TXT_R1_B := "\n莫斯科对发生的事情表示欢迎。克瓦希涅夫斯基正在试图向莫斯科宣誓表示自我为“社会主义开放与活力的橱窗”-而与此同时，戈尔巴乔夫计划将波兰作为寻访东欧的第一站，他称呼发生在哪里的事情是“未来走向民主和平的新社会主义世界的前兆”。"
const TXT_R1_C := "\n莫斯科对发生的事情感到担忧。也许很快，我们要看到第三次“华沙之春”的发生…但目前为止，克瓦希涅夫斯基正在试图向莫斯科宣誓表示自我为“社会主义开放与活力的橱窗”-这能阻止即将到来的干预吗？"
const TXT_R2_A := "我们慷慨地向波兰提供了一揽子计划：财政援助以及直接干预稳定政府的尝试，这巨额的援助数量本身为我们提供了一个很好的参考…\n在我们的帮助下，拉科夫斯基灵活的通过独立候选人以及来自若干小党，例如“民主派联盟”的成员的支持下维持住了一个少数派政府，然而，波兰统一工人党的解体以及团结工会的示微将会持续困扰波兰政局…"
const TXT_R3_A := "面对这种情况，我们决定动员我们的特勤，在波兰扶持一个能稳定政局的可靠力量。在克瓦希涅夫斯基前往安抚第二次格但斯克大罢工的时候，我们为这位“工人阶级的英雄”安排了一辆隧道里的油罐车。与此同时，我们的特工帮助了依然潜藏在半非法状态下的“波兰独立联邦“的崛起…\n多亏了我们的帮助，一个右翼主导的政府已经在波兰出现，莱谢克.莫克斯基，这位反共历史学家以及秘密的波兰人民共和国内务部探员，现在开始将自己的政府粉饰为“左翼爱国政权“，策略性的招募了一些”党之基石“的成员，组成了新内阁。新政府毫无掩饰自己的专制倾向，首先就是宣布了宵禁的执行并且开始大幅度扩充执法队伍。在经济领域，保守主义的市场化-主要基于我们的经验开始。\n苏联对此颇有微词，但是自顾不暇…"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if ws.数值表[56] > 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if ws.数值表[56] != 0:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if ws.empires[1].current_leader == 6 and ws.数值表[56] >= 3:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var c2 := ws.get_country_by_legacy_index(2)
	match opt:
		0:
			context["result_text"] = TXT_R0_A
			if ws.empires[1].current_leader == 6:
				context["result_text"] += TXT_R0_B
			else:
				context["result_text"] += TXT_R0_C
			_add_power(0, 50)
			_add_power(1, -(50))
			if c2 != null: c2.government = GameConstants.Government.LIBERAL
			if c2 != null: c2.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		1:
			context["result_text"] = TXT_R1_A
			if ws.empires[1].current_leader == 6:
				context["result_text"] += TXT_R1_B
			else:
				context["result_text"] += TXT_R1_C
			if ws.empires[1].current_leader == 6:
				_add_relation(1, 80)
			else:
				_add_relation(1, -(80))
			_add_relation(0, 80)
			_add_power(0, 50)
			_add_power(1, -(50))
			if c2 != null: c2.government = GameConstants.Government.LIBERAL
			if c2 != null: c2.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		2:
			context["result_text"] = TXT_R2_A
			_add_relation(0, 100)
			_add_relation(1, -(100))
			_add(8, -(200))
			ws.influence_prc += 20
			_add_power(0, 30)
			_add_power(1, -(50))
			if c2 != null: c2.government = GameConstants.Government.REFORMIST
			if c2 != null: c2.sub_government = GameConstants.SubGovernment.PRAGMATIST
		3:
			context["result_text"] = TXT_R3_A
			_add_relation(0, 150)
			_add_relation(1, -(150))
			ws.influence_prc += 40
			_add(9, -(100))
			_add_power(0, 40)
			_add_power(1, -(80))
			if c2 != null: c2.government = GameConstants.Government.AUTHORITARIAN
			if c2 != null: c2.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN

func _leader_name() -> String:
	if ws != null and ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _office_name(pos: int) -> String:
	if ws != null and ws.politics_positions.size() > pos:
		var pi: int = ws.politics_positions[pos]
		if pi >= 0 and pi < ws.politicians.size():
			var p: PoliticianData = ws.politicians[pi]
			if p != null and p.name_display != "":
				return p.name_display
	return "华国锋"


func _event_result(event_id: String) -> int:
	return ws.completed_event_ids.get(event_id, -1)


func _mod_active(index: int) -> bool:
	return index >= 0 and index < ws.modifiers.size() 		and ws.modifiers[index] != null and ws.modifiers[index].is_active


## GameState.cs:4934-5028 ChineseSubGosstroy 完整移植（同 Event713）。
func _chinese_sub_government() -> int:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return 13
	if d.size() <= W.I_TERRITORY:
		return 13
	var data := d
	var result := 13
	if china.government == GameConstants.Government.AUTHORITARIAN:
		if _event_result("event_674") == 2:
			result = 9
		elif china.has_tag("nazimao"):
			result = 22
		elif ws.completed_event_ids.has("event_912") and _event_result("event_912") == 0:
			result = 19
		elif data[W.I_PARTY_SYSTEM] == 8:
			result = 20
		elif ws.completed_event_ids.has("event_503") and _event_result("event_503") == 0:
			result = 10
		elif data[W.I_IDEOLOGY] <= 2 and data[W.I_ECON_SYSTEM] < 13 				and data[W.I_DIPLO] >= 700 and data[W.I_PARTY_SYSTEM] < 8 				and _mod_active(6) and _mod_active(3):
			result = 0
		elif (data[W.I_ECON_SYSTEM] >= 13 and data[W.I_WAR_SUPPORT] >= 700 and not _mod_active(6)) 				or _mod_active(38):
			result = 9
		elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_WAR_SUPPORT] >= 700 				and data[W.I_DIPLO] >= 700 and (_mod_active(6) or _mod_active(3)):
			result = 10
		elif data[W.I_ECON_SYSTEM] >= 13 and not _mod_active(6):
			result = 7
		else:
			result = 13
	elif china.government == GameConstants.Government.SOCIALIST:
		if _mod_active(49):
			result = 18
		elif _mod_active(6) and _mod_active(3) and data[W.I_PARTY_SYSTEM] <= 7 				and data[W.I_ECON_SYSTEM] <= 12 and data[W.I_RELIGION] <= 25:
			result = 17
		elif data[W.I_IDEOLOGY] == 1 and not _mod_active(6) and data[W.I_RELIGION] <= 26:
			result = 16
		elif data[W.I_ECON_SYSTEM] < 13 and data[W.I_PRESS_POLICY] >= 17 				and data[W.I_IDEOLOGY] == 1 and data[W.I_RELIGION] <= 26:
			result = 2
		else:
			result = 1
	elif china.government == GameConstants.Government.REFORMIST:
		if _mod_active(40):
			result = 8
		elif data[W.I_IDEOLOGY] >= 2 and data[W.I_ECON_SYSTEM] >= 13 				and data[W.I_DIPLO] <= 700 and data[W.I_PARTY_SYSTEM] >= 8 				and data[W.I_PRESS_POLICY] >= 18 and not china.has_tag("ovd"):
			result = 14
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] >= 12 				and data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 300 				and data[W.I_TERRITORY] > 21 and data[W.I_WAR_SUPPORT] >= 700:
			result = 11
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 14 				and data[W.I_DIPLO] >= 500 and data[W.I_ECON_SYSTEM] > 11 				and data[W.I_WAR_SUPPORT] >= 400:
			result = 8
		elif data[W.I_IDEOLOGY] <= 3 and data[W.I_ECON_SYSTEM] <= 13 				and data[W.I_PRESS_POLICY] > 17:
			result = 3
		elif data[W.I_PARTY_SYSTEM] <= 8 				and (data[W.I_ECON_SYSTEM] == 13 or data[W.I_ECON_SYSTEM] == 12) 				and data[W.I_WAR_SUPPORT] < 700 and not _mod_active(3) 				and data[W.I_PRESS_POLICY] >= 17:
			result = 21
		else:
			result = 15
	elif china.government != GameConstants.Government.LIBERAL:
		result = 13
	elif data[W.I_ECON_SYSTEM] <= 13 and data[W.I_DIPLO] >= 500:
		result = 4
	elif (data[W.I_PARTY_SYSTEM] <= 8 and data[W.I_PRESS_POLICY] <= 18) 			or data[W.I_WAR_SUPPORT] >= 700:
		result = 12
	elif data[W.I_ECON_SYSTEM] > 13 and data[W.I_DIPLO] < 700:
		result = 6
	else:
		result = 5
	return result


func _tech(idx: int) -> bool:
	return ws != null and ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _mod(idx: int) -> bool:
	return ws != null and idx >= 0 and idx < ws.modifiers.size() and ws.modifiers[idx].is_active


func _empire_rel(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].relations
	return 0


func _empire_power(idx: int) -> int:
	if ws != null and idx >= 0 and idx < ws.empires.size() and ws.empires[idx] != null:
		return ws.empires[idx].power
	return 0


func _cf(idx: int, field: String) -> int:
	var c := ws.get_country_by_legacy_index(idx)
	if c == null:
		return 0
	match field:
		"Gosstroy": return c.government
		"SubGosstroy": return c.sub_government
		"dev": return c.development
		"spec": return c.special
		"soc_stab": return c.social_stability
		"stab": return c.stab
		"puppetOf": return c.puppet_of
		"prcpower": return c.prc_power
		"prcinfl": return c.prc_influence
	return 0


func _tag(idx: int, tag: String) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag(tag)
