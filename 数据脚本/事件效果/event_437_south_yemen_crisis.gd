extends "res://数据脚本/event_script_base.gd"

## 原作 Event437.cs：南也门事变？（2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:522-524 —— 日>=26 月>=6 年>=1978（.tres ExprNode 表达）。
## 差异：选项显隐 prepare 动态改写；proprc→亲中、prosov→亲苏、Torg→对华贸易；
##   Gosstroy/SubGosstroy→government/sub_government。



const TXT_OPT0_DIS := "我们无从下手......"

const TXT_R0 := "多亏了我们在索马里的部署，让我们有了力量支持鲁巴伊。在我们的警告以及特工小组的协助下，鲁巴伊得以逮捕部分亲苏的修正主义分子。残余的亲苏分子发觉了鲁巴伊的行动，匆匆拉起一支叛军，但很快被政府军和民兵粉碎。苏联军事基地内的驻军在我们和索马里的军事力量的联合封锁下，无法介入政变，最后整个军事基地都被南也门扣押。阿里·纳赛尔和伊斯梅尔最终被俘，他们被中央委员会设立的特别法庭判处叛国罪和反革命罪，死刑立即执行。亲苏分子完全被清洗，鲁巴伊稳固了他的领导地位。在“统一政治组织——民族阵线”的特别全国代表大会上，该组织被改组为也门共产党，党章加入了毛主义和反对修正主义的词条。会上，总书记萨利姆·鲁巴伊·阿里宣布将加强与中国的合作，这引起了苏联的不满。但鲁巴伊并未提出要驱逐苏联军事基地，因此苏联的不满也仅仅停留在牢骚层面。"
const TXT_R1 := "1978年6月24日，伊斯梅尔一派策划了加什米遇刺案，企图嫁祸于鲁巴伊。这一事件加速了双方的武力摊牌。1978年6月26日召开的“统一政治组织——民族阵线”中央委员会非常会议上，两派因政见分歧而发生了流血冲突，伊斯梅尔和总理阿里·纳赛尔·穆罕默德在苏联、德意志民主共和国和古巴的支持下发动推翻鲁巴伊的武装政变，动用飞机轰炸鲁巴伊所在的总统府，派军舰封锁了海面，苏联和古巴的军事力量直接介入了冲突。鲁巴伊指挥警卫营进行抵抗，激战16小时。总统府被攻陷后，鲁巴伊失败被俘，被中央委员会设立的“特别法庭”判处死刑，并立即执行。政变后，伊斯梅尔又清洗了残余的鲁巴伊派。在的“统一政治组织——民族阵线”的特别全国代表大会上，该组织被改组为也门社会党，伊斯梅尔当选为该党总书记。会上，伊斯梅尔强调今后将努力“扩大和加强与以苏联为首的社会主义阵营的友好合作关系”。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var data := world.数值表
	var somalia := world.get_country_by_legacy_index(42)
	var ethiopia := world.get_country_by_legacy_index(41)
	var opt := event_def.options
	var ethiopia_ok := false
	if ethiopia != null and ethiopia.parts.size() > 1:
		ethiopia_ok = (ethiopia.parts[1] or ethiopia.parts[0]) and ethiopia.has_tag("亲中") and ethiopia.government == GameConstants.Government.SOCIALIST
	var cond := (somalia != null and somalia.has_tag("亲中")) or ethiopia_ok
	cond = cond and data[W.I_BUDGET] + data[W.I_RESERVE] >= 50 \
			and data[W.I_AGENTS] >= 50 and data[W.I_INFLUENCE] >= 100
	if cond:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var south_yemen := ws.get_country_by_legacy_index(24)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_INFLUENCE, 50)
			_add_relation(EmpireData.USSR, -150)
			if south_yemen != null:
				south_yemen.sub_government = GameConstants.SubGovernment.MAOIST
				south_yemen.set_tag("亲中", true)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_INFLUENCE, -10)
			if south_yemen != null:
				south_yemen.set_tag("亲苏", true)
				south_yemen.set_tag("对华贸易", false)
			context["result_text"] = TXT_R1




func _disable_blank(opt: EventOption) -> void:
	opt.text = ""
	opt.disabled_text = ""
	var n := ExprNode.new()
	n.type = ExprNode.Type.RESOURCE_AT_LEAST
	n.key = "party_system"
	n.value = 99999.0
	opt.enable_condition = n








func _modifier_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active


func _join_alliances(c: CountryData) -> void:
	var china := ws.get_country_by_legacy_index(1)
	if china == null:
		return
	if china.has_tag("econ"):
		c.set_tag("econ", true)
	elif china.has_tag("sev"):
		c.set_tag("sev", true)
