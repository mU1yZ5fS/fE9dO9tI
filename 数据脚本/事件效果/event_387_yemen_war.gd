extends "res://数据脚本/event_script_base.gd"

## 原作 Event387.cs：两个也门间的战争？（四选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。

const TXT_DESC_PROPRC := "北也门与南也门曾在1972年爆发了一场冲突。最终，对抗以双方签署《开罗合约》结束，并在合约中表达了两国实现统一的愿望。然而，在接下来的数年内，两国均没有为统一采取决定性的行动。\n而现在，北也门政府正控诉其南方邻居正支持名为“民族民主阵线”的革命组织。而在双方的边界上，时常能够听到枪声，看起来这场冲突将发展为一场全面战争。既然南也门已经加强了与我们的合作，那么一个由南方主导统一的也门对我们是有利的。另外，自20世纪60年代以来，苏联便已经在南也门这里派驻部队，并建立了海军基地，如果战争爆发，苏联人显然会帮助南也门。"
const TXT_DIS_AGENTS := "巧妇难为无米之炊，我们手头得有{0}支特工网络才能干活......"
const TXT_DIS_ARMY := "军事实力必须高于{0}点......"
const TXT_DIS_BETRAY_N := "背叛盟友？你疯了吗？！"
const TXT_DIS_BETRAY_S := "我们忙活这么久，不能让MSS的血白流了"
const TXT_DIS_TALK := "没人愿意坐下来谈"
const TXT_R0 := "在南也门迅速派兵占领了边界数个战略要地后。北也门部队得以遏制敌人的空中攻势，并设法对其发动反攻。北也门军队已经开入了南也门的领土。\n看起来冲突已经升级到了箭在弦上，不得不发的程度。"
const TXT_R1 := "在南也门迅速派兵占领了边界数个战略要地后。得到了南方支持的左翼叛军开始在北也门境内发起反政府起义。南也门入侵三天之后，数量较少的南军已经完全建立了空军优势，从而迫使北方陆军在战争中处于劣势。\n看起来冲突已经升级到了箭在弦上，不得不发的程度。"
const TXT_R2 := "在我们的支持下，北也门总统加什米和南也门最高人民委员会主席鲁巴伊决定坐下来，就也门的未来进行商讨。经过我们的指导，双方决定了成立阿拉伯也门民主联邦的计划。北也门与南也门保持一段时间的联邦制政府，行政中心在萨那，但首都在亚丁。双方就成立也门人民革命党也达成了协议，原北也门和南也门的政府官员各占一半。北也门和南也门继续发行自己的货币，但将协调各项资源。两国的和平与统一得到了世界的认可。"
const TXT_R3 := "在南也门迅速派兵占领了边界数个战略要地后。边界战争以各方在阿拉伯联盟的调解下，于科威特签署合约告终。合约重申了两国呼吁实现统一的愿望。\n这场战争再度表明了北也门在军事技术上显著落后于南方，毕竟南方在战争进行过程中建立了绝对的空中优势。"
const TXT_NAME_YEMEN := "统一也门"
const TXT_WAR_NAME := "也门内战"
const TXT_WAR_ATT := "北也门"
const TXT_WAR_DEF := "南也门"


const TXT_LABEL_BUDGET := "预算"
const TXT_LABEL_AGENTS := "特工网络"
const TXT_LABEL_ARMY := "军事实力"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var south := world.get_country_by_legacy_index(24)
	var north := world.get_country_by_legacy_index(25)
	if south != null and south.has_tag("亲中"):
		event_def.description = TXT_DESC_PROPRC
	var opt := event_def.options
	_prepare_yemen(opt[0], event_def.options[0].text, south != null and south.has_tag("亲中"), TXT_DIS_BETRAY_N)
	_prepare_yemen(opt[1], event_def.options[1].text, north != null and north.has_tag("亲中"), TXT_DIS_BETRAY_S)
	if north != null and north.has_tag("亲中") and south != null and south.has_tag("亲中"):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_DIS_TALK)
	_enable(opt[3], event_def.options[3].text)


func _prepare_yemen(opt: EventOption, text: String, is_proprc: bool, dis_betray: String) -> void:
	if _d(W.I_AGENTS) >= 50 and _d(W.I_ARMY) >= 100:
		if not is_proprc:
			_enable(opt, text.format([TXT_LABEL_BUDGET, TXT_LABEL_AGENTS, TXT_LABEL_ARMY]))
		else:
			_disable(opt, dis_betray)
	elif _d(W.I_AGENTS) < 50:
		_disable(opt, TXT_DIS_AGENTS.format([5]))
	else:
		_disable(opt, TXT_DIS_ARMY.format([10]))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var south := ws.get_country_by_legacy_index(24)
	var north := ws.get_country_by_legacy_index(25)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
			_add(143, 1)  # 原版 data[143]
			_start_war_387(600, 400)
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_DIPLO, 10)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
		1:
			context["result_text"] = TXT_R1
			_add(143, 1)  # 原版 data[143]
			_start_war_387(400, 600)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, 10)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -100)
		2:
			context["result_text"] = TXT_R2
			if north != null:
				_leave_alliances(north)
			if south != null:
				if south.parts.size() < 1:
					south.parts.resize(1)
				south.parts[0] = true
				south.set_tag("亲中", true)
				south.government = 1
				south.sub_government = 1
				south.set_tag("对华贸易", true)
				south.name = TXT_NAME_YEMEN
				south.chinese_name = TXT_NAME_YEMEN
			_add(W.I_BUDGET, -30)
			_add(W.I_AGENTS, -40)
			ws.influence_prc += 20
		_:
			context["result_text"] = TXT_R3


func _start_war_387(infl1: int, infl2: int) -> void:
	GameManager.start_war(21, TXT_WAR_ATT, TXT_WAR_DEF, infl1, infl2, 0, 1)
	if ws.wars.size() > 21 and ws.wars[21] != null:
		ws.wars[21].name_war = TXT_WAR_NAME
		ws.wars[21].fortnight_max = 20



func _d(index: int) -> int:
	if d.size() > index:
		return d[index]
	return 0





