extends "res://数据脚本/event_script_base.gd"

## 原作 Event316.cs：与日本和解？（2选项）。
## 触发：全目录搜索无 this_num_event = 316 / Reset(316) / StartEvent(316)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 140-145。

const TXT_TITLE := "与日本和解？"
const TXT_DESC := "在我国接受日本模式后，一些党员提出了与日本达成政治和解并进一步推进贸易一体化的想法，这将增强我们在亚洲的影响力。当然，日本现在是美国的傀儡，但这有那么重要吗？毕竟，他们是亚洲人，不是西方帝国主义者......"
const TXT_OPT0 := "和解不可接受。"
const TXT_OPT1 := "设立大使馆。"
const TXT_R0 := "没错，我们是采用了他们的方法，但别忘了这个国家的过去和现在。他们给我国和全亚洲犯下了罄竹难书的罪行，但由于他们背靠美国，他们得以逍遥法外。除非日本幡然醒悟，否则不会有和解可言！"
const TXT_R1 := "我们从前有过冲突，但我国至少应该与邻国保持非负面关系，因为我们的国家安全是第一位的。克服分歧的愿望将增加我们的声望。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_INFLUENCE, 30)
			_add_power(0, -50)
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
