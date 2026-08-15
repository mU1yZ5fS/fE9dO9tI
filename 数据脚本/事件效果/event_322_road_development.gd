extends "res://数据脚本/event_script_base.gd"

## 原作 Event322.cs：道路发展（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:544-547 —— 生活水平>=600 且 日>=9 月>=1 年>=1980。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 193-202。

const TXT_TITLE := "道路发展"
const TXT_DESC := "近年来，我国人民拥有的汽车数量一直稳步攀升。当然，这是好事，因为这标志着我国人民生活水平的提高。但另一方面，我国城市塞不塞得下那么多车还是个问题。对许多省份来说，它们只有土路和铁路，而发达地区的高速公路也常常出现交通堵塞。根据工程师们传达的信息，我们迫切需要发展道路基础设施——修建新的公路和扩建旧的公路。但是我们有足够的资源来实现这一目标吗？"
const TXT_OPT0 := "我们还有别的要紧事得处理。"
const TXT_OPT1 := "开始建设"
const TXT_OPT1_DIS := "我们没有资源。"
const TXT_OPT2 := "我们能借鉴一番德国高速公路的经验吗？"
const TXT_OPT2_DIS := "不要和资产阶级扯上关系！"
const TXT_R0 := "道路是该修建，但我们没有那么多闲钱和工业产能。"
const TXT_R1 := "我们的工业将资源投入到了混凝土和沥青的生产中。很快，大规模的道路工程便开始在全国各地展开。崭新的交通系统用宽阔的公路连接了所有的城市，并且至少也有一条铺好的公路通往每个村庄。人民很高兴，工业资源的供给也变得更容易了。"
const TXT_R2 := "我们的工程师被派去西德学习他们建造高速公路的经验。很快，两国专家便回到中国开始工作。是的，这需要更多的资源，但现在，我国道路已成为全世界的模范——因为其是在世界上最好的基础上建造的，也只使用了现代技术。中德关系已变得更加友好，德国工程师和投资者业已想要参与我们的其他项目中去。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world.数值表
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data[W.I_BUDGET] + data[W.I_RESERVE]
	_enable(opt[0], TXT_OPT0)
	if br >= 70 and data[W.I_INDUSTRY] >= 500:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data[W.I_DIPLO] <= 700 and br >= 70:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_LIVING, -50)
			context["result_text"] = TXT_R0
		1:
			_add(W.I_BUDGET, -70)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_LIVING, 50)
			ws.influence_prc += 5
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, -50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_LIVING, 50)
			_add_relation(0, 50)
			_add_power(0, 5)
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
