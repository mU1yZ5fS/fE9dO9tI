extends "res://数据脚本/event_script_base.gd"

## 原作 Event315.cs：以日为师（2选项）。
## 触发：全目录搜索无 this_num_event = 315 / Reset(315) / StartEvent(315)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 134-139。

const TXT_TITLE := "以日为师"
const TXT_DESC := "二战后，日本表现出惊人的经济增长，每年约10%，成为世界上第二大名义经济强国，超过法国、意大利、加拿大、英国、苏联，仅次于美国。在西方，他们甚至称其为“日本经济奇迹”。但许多自由派坚持认为，这样的成功是由大企业和国家结合这种非市场方式造成的。左派指责日本领导层压低工作条件，让工人过度劳累，并在日本创造了一种法团文化。但是我们可以考虑他们在我们国家的经历，再考虑到我们的具体情况......"
const TXT_OPT0 := "不，我国绝不借鉴资产阶级经济学家的经验！"
const TXT_OPT1 := "好，在经历了过去几十年的某些问题之后，我们的经济需要新的生产发展方法。"
const TXT_R0 := "日本是个残酷剥削着工人的国家，而且完完全全处于境外的美帝国主义者操纵之下！不要忘记他们过去的罪行，他们甚至毫不悔改。我们不能接受他们的方法！"
const TXT_R1 := "日本的方法很有趣......它们可能对我们的经济有用，这也能将加强我们与东部邻国的关系......"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 5)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_LIVING, -300)
			_add(W.I_BUDGET, 50)
			_add(W.I_AGRICULTURE, 25)
			_add(W.I_INDUSTRY, 25)
			context["result_text"] = TXT_R1

	
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
