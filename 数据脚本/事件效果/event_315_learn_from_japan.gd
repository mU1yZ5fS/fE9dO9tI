extends "res://数据脚本/event_script_base.gd"

## 原作 Event315.cs：以日为师（2选项）。
## 触发：全目录搜索无 this_num_event = 315 / Reset(315) / StartEvent(315)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 134-139。

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

	

