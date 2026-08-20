extends "res://数据脚本/event_script_base.gd"

## 原作 Event330.cs：对葡谈判（3选项）。
## 触发：全目录搜索无 this_num_event = 330 / Reset(330) / StartEvent(330)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 266-273。

const TXT_R0 := "今天，我国与葡萄牙进行了谈判。双方没有产生任何争议，签订了友好协议，贸易协议的范围也得以扩大。"
const TXT_R1 := "在与葡萄牙的谈判中，我国与其达成了一项大规模的贸易协定，这实际上使中国成为葡萄牙的主要贸易伙伴。现在，大量的外汇将流入我们的预算，哪怕美国对失去对另一个北约国家的控制权很是不高兴。"
const TXT_R2 := "葡萄牙代表团面临着澳门问题的严峻挑战。他们被告知，若是不交还这座城市，就什么也别想得到。不能说整个代表团都接受了这一主张，但是，他们还是签署了关于逐步交还澳门的决定。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, 10)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, 50)
			_add(W.I_INFLUENCE, 70)
			_add_power(0, -70)
			_add_relation(0, -70)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, -30)
			_add(W.I_INFLUENCE, 70)
			_add_power(0, -110)
			_add_relation(0, -110)
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



