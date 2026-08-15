extends "res://数据脚本/event_script_base.gd"

## 原作 Event349.cs：地下城市（第二版）。选项0原版按 budget+reserve>=80 且 industry>=500 动态启用/销毁。触发：ReqEventForDLC02.cs:617-620 —— 日期>=1979.6.24。

const TXT_TITLE := "地下城市"

const TXT_DESC := "在过去10年里，北京附近建起了一个巨大的防空洞系统，在与美国或苏联发生核战争的情况下，此处可以为数十万人提供避难所。近年来，国际局势逐渐改善，因此人们便开始怀疑起这一防空洞系统的必要性。我们是否应当把它们转交给民政当局？"

const TXT_OPT0 := "我们需要扩建北京的防空洞，并在其他城市建设类似的设施。"
const TXT_OPT1 := "把防空洞留给军队，但停止无意义的建设。"
const TXT_OPT2 := "最好将其转为民用。"

const TXT_R0 := "当然，世界或许风平浪静，但我们必须时刻备战。北京的防空洞将被扩建，所有主要城市附近也将建立起类似的系统。我们的目标是从帝国主义的核打击中拯救数千万人！"
const TXT_R1 := "防空洞是必需的。但是进一步的建设需要太多的资源，其必要性有些值得怀疑。因此，把防空洞留给军方吧，但再去扩建它就没什么意义了。"
const TXT_R2 := "防空洞系统被移交给了民事当局。不久，在这配套设备最为齐全的地方，小型企业以及各种休闲场所纷纷落户。关于改善其中一些建筑的讨论也已经开始，以便在防空洞中建造住宅公寓。当然，我们近代史上最好的博物馆之一即将开放！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _dyn_ok(world):
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], "没有这么做的资源。")


func _dyn_ok(w: WorldState) -> bool:
	var d := w.数值表
	return d.size() > W.I_BUDGET and d.size() > W.I_RESERVE and d.size() > W.I_INDUSTRY and d[W.I_BUDGET] + d[W.I_RESERVE] >= 80 and d[W.I_INDUSTRY] >= 500

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -70)
			_add(W.I_ARMY, 100)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_AGENTS, 50)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_THOUGHT_FREEDOM, 25)
			_add(W.I_ARMY, -150)
			_add(W.I_PARTY_SUPPORT, -150)
			_add(W.I_DIPLO, -50)
			_add(W.I_BUDGET, 50)
			_add_relation(0, 150)
			_add_relation(1, 150)
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


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d[index] = value


func _add_relation(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].relations = clampi(ws.empires[empire_index].relations + delta, 0, 1000)


func _add_power(empire_index: int, delta: int) -> void:
	if ws.empires.size() > empire_index and ws.empires[empire_index] != null:
		ws.empires[empire_index].power += delta


func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
