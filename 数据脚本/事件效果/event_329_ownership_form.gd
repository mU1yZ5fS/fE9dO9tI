extends "res://数据脚本/event_script_base.gd"

## 原作 Event329.cs：所有权形式问题（3选项）。
## 触发：全目录搜索无 this_num_event = 329 / Reset(329) / StartEvent(329)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 258-265。

const TXT_TITLE := "所有权形式问题"
const TXT_DESC := "在下一次党的代表大会上，所有权形式的问题出现了。国家的局势已稳定下来，我们可以开始在这方面着手推行改革。但一方面，为什么我们要改变行之有效的东西？此外，这还会大大破坏国家的稳定。不过我们可以推进国有化，这意味着左派的壮大，国家也将掌握更多的资源，反之亦然——私有化，但这将大大动摇人民对我们的支持......"
const TXT_OPT0 := "无需改变。"
const TXT_OPT1 := "推进国有化和巩固国有制是最重要的。"
const TXT_OPT2 := "推进私有化。"
const TXT_R0 := "我们不需要改革，一切照样运转。"
const TXT_R1 := "我们推进了国有化，本土企业家乃至于外国人都成了打击对象。尽管私营企业的前所有者正千方百计地攻击着我们，但这让我们有了获取大量资金的可能，尤其是在经济领域。突然之间，这让党在民众之中更具人气了，但对那些认为私有财产不可侵犯的企业来说，我国的吸引力下降了。"
const TXT_R2 := "为了稳定的发展，我们需要私有化。无利可图的国有资产将通过拍卖方式转移到私人手中。这样我们就有可能获得额外的资金，并减轻国家在某些消费品生产方面的负担。但这也导致了物价上涨、市场欺诈行为和部分人的不满情绪也愈演愈烈。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PEOPLE_SUPPORT, 70)
			_add(W.I_BUDGET, 150)
			_add(W.I_INDUSTRY, 70)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PEOPLE_SUPPORT, -30)
			_add(W.I_THOUGHT_FREEDOM, 150)
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
