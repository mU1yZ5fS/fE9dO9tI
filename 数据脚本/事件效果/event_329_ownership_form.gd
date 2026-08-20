extends "res://数据脚本/event_script_base.gd"

## 原作 Event329.cs：所有权形式问题（3选项）。
## 触发：全目录搜索无 this_num_event = 329 / Reset(329) / StartEvent(329)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 258-265。

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



