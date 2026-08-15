extends "res://数据脚本/event_script_base.gd"

## 原作 Event313.cs：教育质量的下降（3选项）。
## 触发：全目录搜索无 this_num_event = 313 / Reset(313) / StartEvent(313)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 116-125。

const TXT_TITLE := "教育质量的下降"
const TXT_DESC := "同志，地方当局发出的信息如雪花般飞来，教育质量和识字率愈发下降。在很大程度上，这要归咎于教育系统的混乱，这种混乱自所谓的“文化大革命”以来就一直存在着。这个问题相当严重，从长远来看会对我们的发展产生负面影响。我们的专家提供了几种解决方案：1.全面推行教育改革，部分去意识形态化，这将对教育质量产生积极的影响，但可能会产生与党的总路线不同的意见。2.为学校和大学的重建注入大量资金，提高教师的工资。3.或者，如果我们没有足够的资金或政治意愿进行改革，我们尊敬的领导人可以就教育的重要性发表鼓舞人心的演讲，但这不会对局势产生任何影响。"
const TXT_OPT0 := "为教育的重要性做一次演讲"
const TXT_OPT1 := "为此拨付更多预算"
const TXT_OPT1_DIS := "我们没有足够的预算"
const TXT_OPT2 := "进行大规模的教育改革"
const TXT_OPT2_DIS := "我们绝对没有那么多钱。"
const TXT_R0 := "在党的会议上，你发表了关于教育在国家建设中的重要性的讲话。的确，讲话归讲话，到头来只有一些学生开始睡得更少，花些时间在读书上......"
const TXT_R1 := "我国教育状况并非尽善尽美，因此我们决定划拨额外的资金。新学校和新大学的建设、现有学校的现代化都已经开始，教师工资也已提高。这将使教育状况的长期改善成为可能。"
const TXT_R2 := "根据党的决定，整个教育系统进行了大规模改革，价值存疑的科目的课时被削减，其余的课程也被改为更接轨现代科学成果的课程。同时，对确切科学领域的去意识形态化也在系统进行。依照预期，在几年内，我们便将感受到改革带来的强烈积极影响。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data[W.I_BUDGET] + data[W.I_RESERVE]
	_enable(opt[0], TXT_OPT0)
	if br >= 50:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data[W.I_INFLUENCE] > 10:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_SCIENCE, -200)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_CORRUPTION, -5)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -70)
			_add(W.I_SCIENCE, 300)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_CORRUPTION, -5)
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
