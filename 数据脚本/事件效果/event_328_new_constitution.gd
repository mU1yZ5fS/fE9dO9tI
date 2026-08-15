extends "res://数据脚本/event_script_base.gd"

## 原作 Event328.cs：新宪法（3选项）。
## 触发：全目录搜索无 this_num_event = 328 / Reset(328) / StartEvent(328)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：party_number→factions[i].support；文本来自 Events_text_en 索引 251-258。

const TXT_TITLE := "新宪法"
const TXT_DESC := "过去，在1978年，我党之内发生了严重的分裂，派系之间根本没有团结可言。现在的情况稍微好转了一些，也许我们应当在此时制定宪法，让它更具妥协色彩？附有条件的左派计划根据毛的训诫，进一步建设社会主义，并考虑到已经发生的一些变化。而按照惯例，右边是改革派的道路，苏联曾以此批判毛本人。"
const TXT_OPT0 := "同意左派计划。"
const TXT_OPT1 := "同意右派计划。"
const TXT_OPT2 := "我们不需改变。"
const TXT_R0 := "我国是亚洲革命的发源地，我们不能背离为我们的未来而奋斗的先辈们的思想！我们将展现通过任何形式实现社会主义与繁荣的愿望，哪怕是现在，我国的主要任务也是维护国家稳定与人民的高生活水平。"
const TXT_R1 := "我们受够了这场革命！让我们再次成为一个冷静的大国，融入国际社会，发展对外贸易，共同繁荣！但是，我们当然不能允许疯狂的资本主义让我们的公民陷入恐惧，就像在美国那样，因此，我们必须建立一个庞大的社会保护和援助体系。"
const TXT_R2 := "所有权形式问题"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_faction_support(0, 50)
			_add_faction_support(1, 50)
			_add_faction_support(2, 25)
			context["result_text"] = TXT_R0
		1:
			_add_faction_support(2, 25)
			_add_faction_support(3, 50)
			_add_faction_support(4, 50)
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

func _add_faction_support(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].support += delta

func _add_faction_ideology(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].ideology += delta
