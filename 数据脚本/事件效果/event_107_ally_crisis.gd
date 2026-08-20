extends "res://数据脚本/event_script_base.gd"

## 原作 Event107.cs：盟友危机（联盟成员叛离，五选项）。
## 触发：TimeScript.cs:10985-10990 —— data[120] > 0 && c1.econ && !active。
## 差异：
##  - data[120] 为目标国家原版序号，结果显示后置 -1（原版 ResultsOfEvents 末尾）。
##  - 国家名取 Godot display_name()（原版 .name）；|| → \n；
##    usalliance→美国盟友、sovalliance→苏联盟友、proprc→亲中、
##    Gosstroy→government、SubGosstroy→sub_government、soc_stab→social_stability。


const TXT_DESC_BASE := "众所周知，我们的集团是最民主、最平等的……这就产生了后果。"
const TXT_DESC_TAIL := "最近一直在奉行越来越独立于我们政策，想进行一些改革的不忠势力正在其政治体系中获得权力。"
const TXT_DESC_US := "但更糟糕的是他们与美国和西方的外交调情！如果这种情况继续下去，那么我们就有失去盟友的危险，所以我们需要做些什么，但是怎么办？我们不想表现得像苏联修正主义者在捷克斯洛伐克做的那样。或者……？"
const TXT_DESC_SU := "但更糟糕的是他们与苏联的外交调情！如果这种情况继续下去，那么我们就有失去盟友的危险，所以我们需要做些什么，但是怎么办？我们不想表现得像苏联修正主义者在捷克斯洛伐克做的那样。或者……？"
const TXT_DESC_OKB := "\n这一切都是在我们盟国政府即将宣布中立政策的背景下发生的，这意味着一件事：他们想离开我们的军事同盟"
const TXT_DESC_ECON := "\n而这一切发生的背景是，我们的盟友政府正狂热地切断与我们的所有贸易关系，宣布调整其经济方向，这意味着一件事：他们想离开我们的经济联盟。"

const TXT_OPT0_DIS := "我们的军队没有足够的力量和权威"
const TXT_OPT1_OKB := "组织一场亲中派政变（需要10特工网络，需要3百万预算）"
const TXT_OPT1_NOT_OKB := "组织一场亲中派政变（需要20特工网络，需要3百万预算）"
const TXT_OPT1_DIS := "我们的情报机构对此无能为力"

const TXT_R0_A := "在演习的掩护下，我们的部队进入了这个国家，迅速解除了他们的武装，逮捕了政府并镇压了不满情绪。新政府得到了财政援助以巩固他们的忠诚，"
const TXT_R0_B := "。再次回到我们身边，但我们的外交声誉仍有许多不足之处。"
const TXT_R1_A := "通过幕后阴谋、秘密暗杀和动员忠于我们的政客和军队，我们成功地组织了一场有利于那些准备继续与我们合作的人的政变。新政府得到了财政援助以巩固忠诚。"
const TXT_R1_B := "再次与我们同在，但其他国家怀疑并表达了他们的不满"
const TXT_R2_A := "我们决定不采取激进的措施，而是安抚这个国家，同时在经济上把它与我们联系在一起。这有助于迫使独立的支持者放弃草率的计划，与中国的友谊支持者获得了额外的力量。"
const TXT_R2_B := "再次与我们在一起，我们设法避免了任何外交问题，但只是独立的支持者没有消失。"
const TXT_R3_A := "我们决定不采取激进的措施，而只要求该国领导人保证在我们集团的成员资格，同时保持奉行独立外交政策的能力。经过长时间的谈判和犹豫，他们终于同意了。"
const TXT_R3_B := "仍然在我们的联盟中，但正在积极与其他国家建立新的联系，这可能在未来会适得其反。"
const TXT_R4 := "结果，在没有遭到我方任何抵抗的情况下，该国决定离开我们的集团，并已在建立新的与别国的联系。至少比社会帝国主义好!"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var target := _target_country(world)
	var tname := target.display_name() if target != null else "盟国"
	var desc := TXT_DESC_BASE + tname + TXT_DESC_TAIL
	if target != null and target.has_tag("美国盟友"):
		desc += TXT_DESC_US
	elif target != null and target.has_tag("苏联盟友"):
		desc += TXT_DESC_SU
	elif target != null and target.has_tag("okb"):
		desc += TXT_DESC_OKB
	elif target != null and target.has_tag("econ"):
		desc += TXT_DESC_ECON
	event_def.description = desc

	var data := world.数值表
	var army := data[W.I_ARMY] if data.size() > W.I_ARMY else 0
	var agents := data[W.I_AGENTS] if data.size() > W.I_AGENTS else 0
	var okb := target != null and target.has_tag("okb")
	var opt := event_def.options
	if army >= 200 and okb:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	if agents >= 100 and okb:
		_enable(opt[1], TXT_OPT1_OKB)
	elif agents >= 200 and not okb:
		_enable(opt[1], TXT_OPT1_NOT_OKB)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	_enable(opt[2], event_def.options[2].text)
	if agents >= 50:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT1_DIS)
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var target := _target_country(ws)
	var tname := target.display_name() if target != null else "盟国"
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_ARMY, -200)
			_add(W.I_BUDGET, -30)
			if target != null:
				target.social_stability = 1000
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("okb") or c.has_tag("econ"):
					c.social_stability -= 50
			if target != null and target.has_tag("美国盟友"):
				_add_relation(EmpireData.USA, -150)
				target.set_tag("美国盟友", false)
				_add(W.I_DIPLO, 30)
			elif target != null and target.has_tag("苏联盟友"):
				_add_relation(EmpireData.USSR, -150)
				target.set_tag("苏联盟友", false)
				_add(W.I_DIPLO, -30)
			if target != null:
				target.set_tag("亲中", true)
			context["result_text"] = TXT_R0_A + tname + TXT_R0_B
		1:
			if target != null:
				target.social_stability = 1000
				if target.has_tag("okb"):
					_add(W.I_AGENTS, -100)
					_add(W.I_BUDGET, -30)
				else:
					_add(W.I_AGENTS, -200)
					_add(W.I_BUDGET, -60)
					target.set_tag("亲中", true)
				if target.has_tag("美国盟友"):
					_add_relation(EmpireData.USA, -100)
					target.set_tag("美国盟友", false)
					_add(W.I_DIPLO, 10)
				elif target.has_tag("苏联盟友"):
					_add_relation(EmpireData.USSR, -100)
					target.set_tag("苏联盟友", false)
					_add(W.I_DIPLO, -10)
			context["result_text"] = TXT_R1_A + tname + TXT_R1_B
		2:
			_add(W.I_BUDGET, -100)
			ws.influence_prc += 10
			if target != null:
				target.social_stability = 1000
				if target.has_tag("美国盟友") and target.government != 0 and target.government != 3:
					target.government = 2
					target.sub_government = 15
				elif target.has_tag("苏联盟友") and target.government != 0 and target.government != 1:
					target.government = 2
					target.sub_government = 15
			context["result_text"] = TXT_R2_A + tname + TXT_R2_B
		3:
			ws.influence_prc -= 10
			if target != null:
				if target.has_tag("美国盟友"):
					_add_power(EmpireData.USA, 30)
					target.set_tag("美国盟友", false)
					_add(W.I_DIPLO, -30)
					_add_relation(EmpireData.USA, 50)
					if target.government != 0 and target.government != 3:
						target.government = 1
						target.sub_government = 15
				elif target.has_tag("苏联盟友"):
					_add_power(EmpireData.USSR, 30)
					target.set_tag("苏联盟友", false)
					_add(W.I_DIPLO, 30)
					_add_relation(EmpireData.USSR, 50)
					if target.government != 0 and target.government != 1:
						target.government = 2
						target.sub_government = 15
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -10)
			if target != null:
				target.social_stability = 500
			context["result_text"] = TXT_R3_A + tname + TXT_R3_B
		4:
			ws.influence_prc -= 20
			if target != null:
				if target.has_tag("美国盟友"):
					_add_power(EmpireData.USA, 50)
					if target.government != 0 and target.government != 3:
						target.government = 3
						target.sub_government = 12
				elif target.has_tag("苏联盟友"):
					_add_power(EmpireData.USSR, 50)
					if target.government != 0 and target.government != 1:
						target.government = 1
						target.sub_government = 1
				target.set_tag("亲中", false)
				if target.has_tag("okb"):
					target.social_stability = 1000
					target.set_tag("okb", false)
				elif target.has_tag("econ"):
					target.social_stability = 0
					target.set_tag("econ", false)
			context["result_text"] = TXT_R4
	# 原版 ResultsOfEvents 末尾无条件 data[120] = -1
	if d.size() > 120:
		d[120] = -1


func _target_country(world: WorldState) -> CountryData:
	if world == null or world.数值表.size() <= 120:
		return null
	var idx := world.数值表[120]
	if idx <= 0:
		return null
	return world.get_country_by_legacy_index(idx)



