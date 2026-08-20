extends "res://数据脚本/event_script_base.gd"

## 原作 Event324.cs：中国的地铁？（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:554-557 —— 日>=1 月>=10 年>=1979。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 213-222。

const TXT_OPT1_DIS := "我们的资源不允许这么做。"
const TXT_OPT2_DIS := "修正主义者不会伸出援手！"
const TXT_R0 := "是的，地铁是很重要，但我们现在有更重要的任务。就比如城市化。"
const TXT_R1 := "不久，新的地铁线路开始建设。这是我们首次在没有外国专家和技术的情况下建设地铁，但最终，地铁让我们减轻了道路的交通负荷，并增加了市民的流动性。"
const TXT_R2 := "苏联专家参与了我国地铁的建设。正因如此，我国地铁已经成为世界上最先进的地铁系统之一，这大大提高了市民的流动性，减少了道路的交通负荷。与苏联的关系也得到了显著改善。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data[W.I_BUDGET] + data[W.I_RESERVE]
	_enable(opt[0], event_def.options[0].text)
	if br >= 70 and data[W.I_INDUSTRY] > 60:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if br >= 70 and data[W.I_INDUSTRY] > 30 and data[W.I_USSR_RELATIONS] > 600:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -150)
			ws.influence_prc -= 5
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -60)
			_add(W.I_LIVING, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			ws.influence_prc += 5
			context["result_text"] = TXT_R1
		2:
			_add(W.I_LIVING, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add_relation(1, 60)
			_add_power(1, 5)
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



