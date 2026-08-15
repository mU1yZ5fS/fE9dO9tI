extends "res://数据脚本/event_script_base.gd"

## 原作 Event324.cs：中国的地铁？（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:554-557 —— 日>=1 月>=10 年>=1979。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 213-222。

const TXT_TITLE := "中国的地铁？"
const TXT_DESC := "香港地铁系统于今日开通。在我国，目前只有一条地铁线路运行，在中苏分裂前，我国就开始和苏联专家一起建造该线路，之后在法国专家的帮助下落成，运行状态也令人满意。在这种情况下，我们应当在其他城市建设地铁吗？这一壮举将提高国家的声望，并大大改善城市通勤情况，但与此同时，它将需要大量的投资，没有外国专家，我们将无法建设现代地铁系统。"
const TXT_OPT0 := "我们还有别的要紧事得处理"
const TXT_OPT1 := "让我们自个开建吧。"
const TXT_OPT1_DIS := "我们的资源不允许这么做。"
const TXT_OPT2 := "找找苏联专家。"
const TXT_OPT2_DIS := "修正主义者不会伸出援手！"
const TXT_R0 := "是的，地铁是很重要，但我们现在有更重要的任务。就比如城市化。"
const TXT_R1 := "不久，新的地铁线路开始建设。这是我们首次在没有外国专家和技术的情况下建设地铁，但最终，地铁让我们减轻了道路的交通负荷，并增加了市民的流动性。"
const TXT_R2 := "苏联专家参与了我国地铁的建设。正因如此，我国地铁已经成为世界上最先进的地铁系统之一，这大大提高了市民的流动性，减少了道路的交通负荷。与苏联的关系也得到了显著改善。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data[W.I_BUDGET] + data[W.I_RESERVE]
	_enable(opt[0], TXT_OPT0)
	if br >= 70 and data[W.I_INDUSTRY] > 60:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if br >= 70 and data[W.I_INDUSTRY] > 30 and data[W.I_USSR_RELATIONS] > 600:
		_enable(opt[2], TXT_OPT2)
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

func _add(index: int, delta: int) -> void:
	if d.size() > index:
		d[index] += delta

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta
