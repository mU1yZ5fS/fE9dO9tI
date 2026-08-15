extends "res://数据脚本/event_script_base.gd"

## 原作 Event109.cs：索马里的黄金时代（巴雷政变风波，三选项）。
## 触发：TimeScript.cs:10959-10965 ——
##   !c42.parts[0] && !c42.parts[2]（端口未建模→恒真）&& !wars[15].is_going
##   && ((日>=9 且 月>=4 且 年>=1978) || (月>=5 且 年>=1978) || 年>=1979)。
## 差异：选项0/1 按 agents/influence 动态显隐；<color> 标签去除；
##   EstablishGovernment(ProChina) → set_tag("亲中", true)。

const TXT_R0 := "我们在南也门的大使馆内接见了索马里的反对派，由我们牵头组建了拯救索马里民主与解放阵线。这是一个由索马里爱国运动，索马里劳动党，索马里解放阵线和索马里革命社会主义党内的左翼反对派组成的泛左翼反对派组织。我们慷慨的为他们提供了足够的援助和军事支持，同时在亚的斯亚贝巴组建了办公室，万事俱备只欠东风。\n四月九日清晨，首都南部的阿夫戈伊村爆发了枪战，首都郊区传出了小型武器射击和爆炸声。一场兵变在哈尔格萨爆发了，在激烈的战斗中，巴雷被一枚炮弹炸断了双腿。在痛苦中，这位索马里大救星离开了他所致力于塑造的国家。新政府宣布取缔索马里革命社会主义党，新的索马里统一社会党则被建立起来了。该党致力于先完成军政府未完成的民族民主革命，并在此基础上完成进一步的去部族化和社会主义革命。"

const TXT_R1 := "我们向摩加迪沙广播的“非洲革命之声”中捏造了这样一条新闻：有一个不存在的索马里民主革命运动接受了苏联支持，并谋求推翻巴雷政府。而在我们和巴雷的秘密电报中提到，如果愿意驱逐苏联外交官和军港，中国并不介意为索马里提供苏联撤离带来的空缺。迫切渴望援助的巴雷欣然接纳。\n四月九日清晨，南部的阿夫戈伊村爆发了枪战，首都郊区传出了小型武器射击和爆炸声。政变最初计划在哈尔格萨发动，但得到了通知和援助的巴雷事先知道了这一企图，并在政变发动前就将其挫败，并在首都安置了忠于自己的部队。他在摩加迪沙的群众大会上讲到“我国四处都是敌人，美国和苏联的帝国主义者无时无刻不想奴役我们，只有中华人民共和国愿意成为索马里的忠实战友。”他公开和苏联决裂的决定得到了我们的支持，在《人民日报》《解放军报》和《工人日报》上，我们高度赞扬了反对帝国主义压迫的西亚德·巴雷将军，并加大了我们同他的合作。\n大约有24名军官、2,000名士兵和65名雇佣兵参与了这场政变，而他们悉数被处死。"

const TXT_R2 := "清晨，摩加迪沙南部的阿夫戈伊村爆发了枪战，首都郊区传出了小型武器射击和爆炸声。政变最初计划在哈尔格萨发动，但巴雷很可能事先知道了这一企图，并在政变发动前就将其挫败，并在首都安置了忠于自己的部队。\n但反对派并未就此打住，他们只是在等一个机会……\n大约有24名军官、2,000名士兵和65名雇佣兵参与了这场政变。他们悉数被处死。\n索马里，这一非洲的隐士国度，他将继续过着默默无闻的日子。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var agents := data[W.I_AGENTS] if data.size() > W.I_AGENTS else 0
	var opt := event_def.options
	if agents >= 50 and world.influence_prc >= 200:
		_enable(opt[0], "尽全力支持他们的政变")
	else:
		_disable(opt[0], "我们不能帮助索马里")
	if agents >= 80 and world.influence_prc >= 200:
		_enable(opt[1], "通过给苏联泼脏水，换取巴雷的谅解")
	else:
		_disable(opt[1], "我们可没有余力关注这件事")
	_enable(opt[2], "什么都不做")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var somalia := ws.get_country_by_legacy_index(42)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -80)
			_add_power(EmpireData.USSR, 5)
			ws.influence_prc += 5
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USSR, 50)
			_add_relation(EmpireData.USA, -50)
			if somalia != null:
				somalia.set_tag("亲中", true)
				somalia.set_tag("对华贸易", true)
				somalia.government = 1
				somalia.sub_government = 1
			context["result_text"] = TXT_R0
		1:
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			_add(W.I_BUDGET, -50)
			_add_relation(EmpireData.USSR, -70)
			_add_relation(EmpireData.USA, -70)
			ws.influence_prc += 20
			_add(W.I_DIPLO, 30)
			if somalia != null:
				somalia.set_tag("亲中", true)
				somalia.set_tag("对华贸易", true)
				somalia.government = 0
				somalia.sub_government = 10
			context["result_text"] = TXT_R1
		2:
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


func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta
