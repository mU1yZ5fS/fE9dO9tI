extends "res://数据脚本/event_script_base.gd"

## 原作 Event931.cs：民主的故乡——第二幕（希腊第三次议会选举）。
## 触发：TimeScript.cs:10773-10779 ——
##   ((日>=18 且 月>=10 且 年>=1981) || (月>=11 且 年>=1981) || 年>=1982)。
## 差异：resultOfEvents[93] 分支决定 1/3 选项（prepare 动态替换）；其余逐字保留。

static var _opts_full: Array[EventOption] = []


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	if _opts_full.is_empty():
		for o in event_def.options:
			_opts_full.append(o)
	var result93: int = world.completed_event_ids.get("event_093", -1)
	if result93 != 0:
		event_def.description = "希腊即将迎来后军政府时代的第三次议会选举。主要反对党新民主党面临严重的内部冲突。于此同时，希腊社会的左倾让左翼有望在此次大选中获胜。在左翼方面，泛希腊社会主义运动和希腊共产党都希望退出北约和欧共体，而新民主党则希望继续推进进入欧共体的进程，并深化与北约的合作。如果左翼在此次大选中获得胜利，希腊将有望退出北约并终止加入欧共体的进程。选举的结果将影响希腊和欧洲的局势。"
		var arr: Array[EventOption] = []
		for o in _opts_full:
			arr.append(o)
		event_def.options = arr
		var agents := world.数值表[W.I_AGENTS] if world.数值表.size() > W.I_AGENTS else 0
		if agents >= 40:
			_enable(arr[0], "支持泛希腊社会主义运动")
		else:
			_disable(arr[0], "我们没有足够的力量")
		if agents >= 40:
			_enable(arr[1], "支持新民主党")
		else:
			_disable(arr[1], "我们没有足够的力量")
		_enable(arr[2], "保持距离")
	else:
		event_def.description = "希腊即将迎来后军政府时代的第三次议会选举。主要反对党新民主党面临严重的内部冲突。希腊左翼政府实行的社会主义改革在国内很受欢迎。左翼政府通过的宪法修正案使得总统完全失去了权力，希腊彻底成为了议会制共和国。泛希腊社会主义运动、希腊共产党等左翼政党在国内巩固了他们的影响力。可以说，此次大选让右翼党派已经无力与左翼抗衡了。"
		var arr: Array[EventOption] = []
		arr.append(_opts_full[0])
		event_def.options = arr
		_enable(arr[0], "我们只需等待！")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var result93: int = ws.completed_event_ids.get("event_093", -1)
	var greece := ws.get_country_by_legacy_index(45)
	var cyprus := ws.get_country_by_legacy_index(87)
	var cyprus2 := ws.get_country_by_legacy_index(94)
	var opt := int(context.get("option_index", -1))
	if result93 != 0:
		match opt:
			0:
				_add(W.I_DIPLO, 10)
				_add_relation(EmpireData.USA, -50)
				_add_relation(EmpireData.USSR, 50)
				if greece != null:
					greece.government = 2
					greece.sub_government = 3
					greece.set_tag("亲美", false)
					if cyprus2 == null or not cyprus2.内战中:
						greece.set_tag("对华贸易", true)
				if cyprus != null:
					cyprus.special -= 5
				_add_power(EmpireData.USA, -50)
				context["result_text"] = "我们的特勤部门帮助泛希腊社会主义运动开展竞选活动，并且积极地阻碍新民主党的竞选活动。他们成功赢得了大选，组建了希腊历史上第一个社会主义政府。在我们和苏联的支持下，希腊新政府设法排除了亲欧共体势力的影响，终止了加入欧共体的进程，但是因为反对意见过大，希腊最终未能退出北约。帕潘德里欧政府承认了民族抵抗运动和本都希腊人的种族灭绝。并开始着手建立国家卫生系统和废除希腊宪兵队与城市警察，将他们合并为一个单一的警察机构。"
			1:
				_add(W.I_DIPLO, -10)
				_add_relation(EmpireData.USA, 80)
				_add_power(EmpireData.USA, 20)
				if greece != null:
					greece.set_tag("eu", true)
					if cyprus2 == null or not cyprus2.内战中:
						greece.set_tag("对华贸易", true)
				if cyprus != null:
					cyprus.special += 5
				context["result_text"] = "我们的特勤部门帮助新民主党解决了党内问题，开展竞选活动，并且积极地阻碍泛希腊社会主义运动的竞选活动。新民主党成功赢得了选举。新政府希望开展进一步的经济改革，意在确保希腊欧共体成员的资格，以及恢复该国在北约中的活动。"
			2:
				_add_power(EmpireData.USA, 20)
				if greece != null:
					greece.set_tag("eu", true)
					greece.government = 2
					greece.sub_government = 3
				context["result_text"] = "泛希腊社会主义运动成功赢得了大选，组建了希腊历史上第一个社会主义政府。帕潘德里欧的新政府在获胜后推出了几项有趣的政策（民事婚礼合法化、新的家庭法、某些私营公司的国有化，承认民族抵抗运动和本都希腊人的种族灭绝合并希腊宪兵队和城市警察为单一警察机构等）。在新民主党的总统和党内其他派系的阻挠下，希腊未能实现退出北约和终止加入欧共体。"
	else:
		if opt == 0:
			_add(W.I_DIPLO, 10)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, 50)
			if greece != null:
				greece.government = 2
				greece.sub_government = 3
				if cyprus2 == null or not cyprus2.内战中:
					greece.set_tag("对华贸易", true)
			if cyprus != null:
				cyprus.special -= 5
			_add_power(EmpireData.USA, -50)
			context["result_text"] = "左翼联合政府赢得了希腊大选。希腊继续维持左翼联盟政府，并在外交中继续保持中立。希腊将继续维持左翼多党霸权。不过，这种泛左翼的联合政府究竟还能维持多久？"


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






