extends "res://数据脚本/event_script_base.gd"

## 原作 Event325.cs：高铁？（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:559-562 —— 日>=23 月>=6 年>=1982。
## 差异：选项显隐 prepare 动态改写；modifies[35].active→_set_mod_active(35,true)；文本来自 Events_text_en 索引 223-232。

const TXT_TITLE := "高铁？"
const TXT_DESC := "我们的管理层被要求用高铁线路连接大城市。这将大大改善我国部分地区之间的沟通交流便利度，但同样需要大量资源......我们用得着么？"
const TXT_OPT0 := "我们还有别的事。"
const TXT_OPT1 := "我们将在北京和上海之间修建一条高铁线路。"
const TXT_OPT1_DIS := "你明白这条线路就是为了作秀的吧？"
const TXT_OPT2 := "开始一个连接所有主要城市的高铁项目。"
const TXT_OPT2_DIS := "这没有意义。"
const TXT_R0 := "以高铁连接城市的计划已经取消。老样子，我们还有其他领域需要资源。日本的例子也表明高铁没那么有效——事实上，如果早些时候从一个城市到另一个城市需要五个小时，那么现在坐高铁只需要两个小时，但由于高铁班列减少了，你到头来还是要等五个小时。所以高铁没有任何意义。"
const TXT_R1 := "不久，北京和上海之间的第一条（也是唯一一条）高铁线路建成并庄严投入运营。在电视直播中，我们的领导人登上了一列火车，几小时后就到达了上海。当然，这个广告效果是惊人的，但并不是每个人都喜欢这种作秀的资源投资。"
const TXT_R2 := "一项建设高速铁路的新计划被采纳，很快，各大城市之间的新高铁线路便纷纷开通。当然，一些经济学家会抱怨这是浪费钱，但人民是高兴的，他们的生活水平大大提高了，甚至连日本的工程师也开始了解起我国的高铁系统。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data[W.I_BUDGET] + data[W.I_RESERVE]
	_enable(opt[0], TXT_OPT0)
	if br >= 40 and data[W.I_INDUSTRY] > 60:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if br >= 110 and data[W.I_INDUSTRY] > 80:
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
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_INFLUENCE, 5)
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_INFLUENCE, 5)
			_add(W.I_BUDGET, -100)
			_set_mod_active(35, true)
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

func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value

func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)

func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta
