extends "res://数据脚本/event_script_base.gd"

## 原作 Event93.cs：民主的故乡——第一幕（希腊大选，三选项）。
## 触发：TimeScript.cs:10766-10772 —— (月>=11 且 年>=1977 或 年>=1978)。
## 差异：选项0/1 原版按 data[9]>=40 销毁按钮，prepare 动态改写。

const TXT_R0 := "我们的特勤部门帮助泛希腊社会主义运动、希腊共产党和希腊共产党（国内派）等左翼政党开展竞选活动，并且积极地阻碍新民主党的竞选活动。他们成功组建左派联盟，包括泛希腊社会主义运动、希腊共产党和其他左翼政党。最终，左派联盟赢得了大选，组建了希腊历史上第一个社会主义政府。在我们和苏联的支持下，希腊完成了正式退出北约的程序，加入欧共体的进程也停止了。新政府承认了民族抵抗运动和本都希腊人的种族灭绝。同时，废除了希腊宪兵队和城市警察，将他们合并成了希腊警察。"

const TXT_R1 := "我们的特勤部门帮助新民主党开展竞选活动，并且积极地阻碍泛希腊社会主义运动的竞选活动。新民主党成功与一些小型右翼政党组建联盟，他们一起走向了胜利。新政府希望开展进一步的经济改革，意在确保希腊欧共体成员的资格，以及恢复该国在北约中的活动。"

const TXT_R2 := "结果，新民主党失去了49个席位，以微弱优势赢得了选举；泛希腊社会主义运动新增81个席位，成为了议会第二大党。新政府打算进行进一步的经济改革，以确保希腊加入欧共体，并恢复该国在北约的活动。"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	var agents := data[W.I_AGENTS] if data.size() > W.I_AGENTS else 0
	var opt := event_def.options
	if agents >= 40:
		_enable(opt[0], "帮助组建左翼联盟")
	else:
		_disable(opt[0], "我们没有足够的力量")
	if agents >= 40:
		_enable(opt[1], "支持新民主党")
	else:
		_disable(opt[1], "我们没有足够的力量")
	_enable(opt[2], "保持距离")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var greece := ws.get_country_by_legacy_index(45)
	var cyprus := ws.get_country_by_legacy_index(87)
	var cyprus2 := ws.get_country_by_legacy_index(94)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, 50)
			if greece != null:
				greece.government = 2
				greece.sub_government = 3
				greece.set_tag("亲美", false)
				greece.set_tag("nato", false)
				if cyprus2 == null or not cyprus2.内战中:
					greece.set_tag("对华贸易", true)
				greece.内战中 = true
			if cyprus != null:
				cyprus.special -= 5
			_add_power(EmpireData.USA, -50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_DIPLO, -10)
			_add_relation(EmpireData.USA, 80)
			_add_power(EmpireData.USA, 20)
			if cyprus != null:
				cyprus.special += 5
			context["result_text"] = TXT_R1
		2:
			_add_power(EmpireData.USA, 20)
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






