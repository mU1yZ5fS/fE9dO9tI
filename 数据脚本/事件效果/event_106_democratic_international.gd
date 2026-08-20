extends "res://数据脚本/event_script_base.gd"

## 原作 Event106.cs：民主国际（贾姆巴反共大会，三选项）。
## 触发：TimeScript.cs:10878-10884 ——
##   (月>=6 且 年>=1985 或 年>=1986) && !c7.isNATO && c51.isNATO
##   （is_gkchp/IndOpp 端口建模说明 → 视为恒真，沿用既有约定）。
## 差异：选项1 按 data[9]>=100 动态显隐；国家循环字段映射
##   sovalliance→苏联盟友、Vyshi→亲美、dev→development、stab→stability。

const TXT_R0 := "结果，民主国际成立了。很难说这是否有助于反共分子的行动，但这一事件意义重大，有助于美国影响力的增长，所以美国积极支持这一行动。"

const TXT_R1 := "我们设法在安哥拉和边境国家的特工人员之间紧急建立合作关系，并秘密说服苏联和亲苏的安哥拉当局进行合作，我们得以在贾巴组织了一系列恐怖袭击。不幸的是，安盟领导人乔纳斯·萨文比和美国傀儡师没有受伤，但我们设法消除了尼加拉瓜叛军的非正式领导人阿道夫·卡莱罗，著名的穆斯林圣战者代表阿卜杜勒·拉希姆·瓦尔达克和苗族运动领袖帕考赫。除了联合阵线的垮台，许多世界反共知名人士的去世严重打击了美国的影响力，也帮助了苏联。这就是为什么所有的主要指控都是针对他的，然而，美国人怀疑某些事情上我们的参与。"

const TXT_R2 := "我们支持民主国际的形成，并支持它随时准备在世界各地抗击苏联的侵略。参与者对此有不同的看法，但总体上做出了积极的反应，从中受益最多的美国人也是如此。我们的利益还不清楚，但苏联的影响力肯定已经下降了。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	_enable(opt[0], "我们不关心此事")
	var agents := world.数值表[W.I_AGENTS] if world.数值表.size() > W.I_AGENTS else 0
	if agents >= 100:
		_enable(opt[1], "安排一次恐怖袭击并扰乱会议")
	else:
		_disable(opt[1], "我们的情报机构对此无能为力")
	_enable(opt[2], "支持民主国际的形成")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_power(EmpireData.USA, 20)
			_add_power(EmpireData.USSR, -10)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -100)
			_add_power(EmpireData.USSR, 20)
			_add_power(EmpireData.USA, -30)
			ws.influence_prc += 10
			_add_relation(EmpireData.USSR, 200)
			_add_relation(EmpireData.USA, -100)
			context["result_text"] = TXT_R1
		2:
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, -120)
			_add_power(EmpireData.USA, 30)
			_add_power(EmpireData.USSR, -20)
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("okb") or c.has_tag("econ"):
					c.social_stability += 50
					if c.has_tag("苏联盟友"):
						c.set_tag("苏联盟友", false)
						_add(W.I_AGENTS, -30)
						_add(W.I_BUDGET, -50)
				elif c.development > 100 and c.stability > 100 and c.has_tag("亲苏"):
					c.stability -= 150
					c.development -= 50
				elif (c.development > 50 or c.stability > 50) and c.has_tag("亲美"):
					c.stability += 150
					c.development -= 100
			context["result_text"] = TXT_R2


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






