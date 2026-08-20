extends "res://数据脚本/event_script_base.gd"

## 原作 Event317.cs：忘却过去？（2选项）。
## 触发：全目录搜索无 this_num_event = 317 / Reset(317) / StartEvent(317)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：文本来自 Events_text_en 索引 146-151。

const TXT_R0 := "不，不会有和解。受害者的亲属还活着，他们不会理解我们的。而日本人自己亦无悔改之意，仍在参拜这些刽子手。"
const TXT_R1 := "是时候原谅日本的过去了。毕竟，已是时过境迁了。怪罪战后出生的现代日本人对战争负有责任是愚蠢的。确实，日本领导层仍在参拜靖国神社，但大家都门清，这是对其他亚洲国家谴责的反应。两国会达成进一步的和解。"

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			_add(W.I_PEOPLE_SUPPORT, -50)
			_add(W.I_DIPLO, -50)
			_add(W.I_MANPOWER, -50)
			_add_power(0, -30)
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



