extends "res://数据脚本/event_script_base.gd"

## 原作 Event110.cs：自动化的缓慢进展（四选项）。
## 触发：TimeScript.cs:10966-10972 —— 年>=1980 && !modifies[12].active
##   && science[15] && data[16]<=11。
## 差异：relres → global flag；modifies[17] → modifiers[17].is_active。

const TXT_R0 := "社会主义经济继续稳定运行。至少目前如此......"

const TXT_R1 := "光荣的主席万岁!光荣的中国共产党万岁!这一天将作为“重大突破”的日子载入中国史册。我们敬爱的领袖宣布我们国家开始过渡到全面自动化和计算机化的规划和生产的重大变革,并宣布建立一个自动化经济管理中心，他们的工作即将开始。新项目的名称为IECS——跨部门电子控制系统。现在，在这个国家关于匆忙引入这些措施的激烈讨论已经爆发，一些党内政客宣称改革具有“反马克思主义性质”。然而，这个项目启动了，没有什么能阻止这个国家不可避免的变化，对吗?"

const TXT_R2 := "光荣的主席万岁!光荣的中国共产党万岁!这一天将作为“重大突破”的日子载入中国史册。我们敬爱的领袖宣布我们国家开始过渡到全面自动化和计算机化的规划和生产的重大变革,并宣布建立一个自动化经济管理中心，他们的工作即将开始。新项目的名称为IECS——跨部门电子控制系统。此外，由于我们同苏联人民的密切友谊，我们要求苏联提供有条件的援助，现在由阿纳托利·基托夫院士率领的代表团已经抵达中国。现在，在这个国家关于匆忙引入这些措施的激烈讨论已经爆发，一些党内政客宣称改革具有“反马克思主义性质”。然而，这个项目启动了，没有什么能阻止这个国家不可避免的变化，对吗?"

const TXT_R3 := "光荣的主席万岁!光荣的中国共产党万岁!这一天将作为“重大突破”的日子载入中国史册。我们敬爱的领袖宣布我们国家开始过渡到全面自动化和计算机化的规划和生产的重大变革,并宣布建立一个自动化经济管理中心，他们的工作即将开始。新项目的名称为IECS——跨部门电子控制系统。此外，由于我们与西方国家的友好关系，我们能够邀请由斯塔福德·比尔(StaffordBeer)领导的欧洲数学科学家代表团，他之前因开发智利的“赛博协同”(Cybersyn)工程而闻名。现在，在这个国家关于匆忙引入这些措施的激烈讨论已经爆发，一些党内政客宣称改革具有“反马克思主义性质”。然而，这个项目启动了，没有什么能阻止这个国家不可避免的变化，对吗?"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	var dip := data[W.I_DIPLO] if data.size() > W.I_DIPLO else 0
	var china := world.get_country_by_legacy_index(1)
	var ussr_rel := world.empires[EmpireData.USSR].relations if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null else 0
	var usa_rel := world.empires[EmpireData.USA].relations if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null else 0
	var mod17 := world.modifiers.size() > 17 and world.modifiers[17] != null and world.modifiers[17].is_active
	var opt := event_def.options
	_enable(opt[0], "让我们再等几年……或者更久……")
	_enable(opt[1], "宣布一门关于生产自动化的课题，并设立一个委员会来实施它(需要10百万预算)")
	if ussr_rel >= 500 and world.get_flag("relres") and china != null and china.has_tag("sev"):
		_enable(opt[2], "开始自动化和邀请苏联科学家")
	else:
		_disable(opt[2], "苏维埃不会帮助我们")
	if usa_rel >= 600 and dip <= 800 and china != null \
			and not china.has_tag("sev") and not china.has_tag("okb") and not mod17:
		_enable(opt[3], "我们准备工作了，西方专家会帮助我们的！")
	else:
		_disable(opt[3], "向西方求助？你是认真的吗？")


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add(W.I_PARTY_SUPPORT, -600)
			if d.size() > 118:
				d[118] = 1
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -80)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 120)
			_add(W.I_PARTY_SUPPORT, -600)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, 100)
			if d.size() > 118:
				d[118] = 1
			if d.size() > 73:
				d[73] += 300
			context["result_text"] = TXT_R2
		3:
			_add(W.I_BUDGET, -80)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add(W.I_PARTY_SUPPORT, -600)
			_add_relation(EmpireData.USA, 50)
			if d.size() > 118:
				d[118] = 1
			if d.size() > 73:
				d[73] += 300
			context["result_text"] = TXT_R3


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
