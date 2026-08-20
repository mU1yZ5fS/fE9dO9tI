extends "res://数据脚本/event_script_base.gd"

## 原作 Event348.cs：地下城市。选项0原版按 budget+reserve>=80 且 industry>=500 动态启用/销毁。原版无自动条件（决策/其他事件链手动触发）。




const TXT_R0 := "当然，世界或许风平浪静，但我们必须时刻备战。北京的防空洞将被扩建，所有主要城市附近也将建立起类似的系统。我们的目标是从帝国主义的核打击中拯救数千万人！"
const TXT_R1 := "防空洞是必需的。但是进一步的建设需要太多的资源，其必要性有些值得怀疑。因此，把防空洞留给军方吧，但再去扩建它就没什么意义了。"
const TXT_R2 := "防空洞系统被移交给了民事当局。不久，在这配套设备最为齐全的地方，小型企业以及各种休闲场所纷纷落户。关于改善其中一些建筑的讨论也已经开始，以便在防空洞中建造住宅公寓。当然，我们近代史上最好的博物馆之一即将开放！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _dyn_ok(world):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], "没有这么做的资源。")


func _dyn_ok(w: WorldState) -> bool:
	@warning_ignore("shadowed_variable_base_class")
	var d := w
	return d.size() > W.I_BUDGET and d.size() > W.I_RESERVE and d.size() > W.I_INDUSTRY and d.budget + d.reserve >= 80 and d.industry >= 500

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -70)
			_add(W.I_ARMY, 100)
			context["result_text"] = TXT_R0
		1:
			context["result_text"] = TXT_R1
		2:
			_add(W.I_PEOPLE_SUPPORT, 30)
			_add(W.I_THOUGHT_FREEDOM, 10)
			context["result_text"] = TXT_R2





func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = true
