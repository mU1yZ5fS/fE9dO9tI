extends "res://数据脚本/event_script_base.gd"

## 原作 Event319.cs：农业机械化（4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:519-522 —— 日>=14 月>=7 年>=1980。
## 差异：选项显隐 prepare 动态改写；science[3]→techs.unlocked[3]；old_modify_desc[15] 拼接为修正说明文案，Godot 由 ModifierCatalog 静态维护，跳过。

const TXT_TITLE := "农业机械化"
const TXT_DESC := "我国农业虽然独立自主了几十年，但机械化程度仍然极低，这对我国的发展产生了消极影响——农业领域需要大量的农村工人，但这些工人本可以参加工业领域的生产。一方面，我们可以自力更生，但这需要工业与工程师充分发挥其能力。但是，或许在苏联或其他国家购买外国器械来得更加值当？"
const TXT_OPT0 := "我们还有别的要紧事得处理。"
const TXT_OPT1 := "开始自力更生。"
const TXT_OPT1_DIS := "我们没有足够的资源"
const TXT_OPT2 := "从苏联购买设备。"
const TXT_OPT2_DIS := "绝不与社会帝国主义者做交易！"
const TXT_OPT3 := "从西方购买设备。"
const TXT_OPT3_DIS := "绝不与资产阶级国家做交易！"
const TXT_R0 := "农业机械化不是重点，我们还有其他事干。无产阶级流入城市将引发城市的贫困......我们想要这样么？"
const TXT_R1 := "我们要自力更生实现机械化。是的，这需要下一番利器，但我们仍必须争取独立于虎狼环伺的外部世界。我们如今自己生产的农业机械是在借鉴苏联样品的实践与特点的基础上发展的，但今后，我们要依托国内技术来发展农业机械。这不仅能推动农业发展，也能促进工业发展，工程师们已在思考如何将军事装备中的解决方案应用到实际中去。"
const TXT_R2 := "我们的代表团去了苏联，在那里，尽管过去有些不愉快，但我们仍能通过谈判向苏联购买农业机械，其中便包括先进的拖拉机T-40和YUMZ-6。如今，我国村庄得到了更大的发展，亩产指标也上升了。与苏联的关系也有所改善。"
const TXT_R3 := "一些在美国购买农机的合同得以签订，尤其是一批约翰迪尔4440型号的最新拖拉机，这是世界上最先进的拖拉机型号之一。我们的农民也用上了高质量的建筑设备，故障报告极为罕见，进而促成了创纪录的收成。这一交易也改善了我们在国际市场上的形象，一些外国公司已表示有兴趣向我们出售他们的农业机械。"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world.数值表
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data[W.I_BUDGET] + data[W.I_RESERVE]
	_enable(opt[0], TXT_OPT0)
	if br >= 50 and data[W.I_INDUSTRY] >= 500:
		_enable(opt[1], TXT_OPT1)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if br >= 50 and data[W.I_USSR_RELATIONS] >= 500:
		_enable(opt[2], TXT_OPT2)
	else:
		_disable(opt[2], TXT_OPT2_DIS)
	if br >= 50 and data[W.I_DIPLO] >= 500:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			if not _tech_unlocked(3):
				_add(W.I_INDUSTRY, -50)
				_add(W.I_AGRICULTURE, 50)
				ws.techs.unlocked[3] = true
			context["result_text"] = TXT_R1
		2:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGRICULTURE, 50)
			_add_relation(1, 50)
			_add_power(1, 5)
			context["result_text"] = TXT_R2
		3:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGRICULTURE, 50)
			_add_relation(0, 50)
			_add_power(0, 5)
			context["result_text"] = TXT_R3

	
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

func _tech_unlocked(idx: int) -> bool:
	return ws.techs != null and ws.techs.unlocked.size() > idx and ws.techs.unlocked[idx]

## ── 原版 display-only 文案（跳过执行，仅保留供逐字校验） ──
## 根据农业发展情况获得效果
## |“上山下乡”政策及其后果|农业+0.1，科技点-1，思想自由化+0.4
## |社会转型阵痛|生活水平-0.1，思想自由化+0.2
## |社会主义新农村|预算-0.7，人民支持度+0.4，农业+0.4，工业+0.2，服务业+0.2，生活水平+0.4
## |“牛棚”群岛|预算+0.1，农业+0.1，特勤网络-0.2，思想自由化-0.2，外交声誉+0.4，科技点-1，与美国关系-1，与苏联关系-1
## |人心思变|农业-0.1，思想自由化+0.3
## |乡村建设理论|预算-0.6，农业+0.2，生活水平+0.2，思想自由化-0.4
## |长期乡建合同|预算+0.2，农业+0.3，工业+0.1，服务业+0.1，生活水平+0.1，思想自由化+1.2，外交声誉-0.2，与美关系+0.2，美国国际影响力+0.1，中国国际影响力-0.1
## |“新”新村运动|预算-0.4，农业+0.3，服务业+0.1，生活水平+0.1，特勤网络+0.1，思想自由化-0.1
## |新乔治主义社会|预算+0.3，农业+0.5，工业-0.4，服务业-0.2，生活水平-0.1，思想自由化+0.2
## |社会主义新农村|预算-0.7，人民支持度+0.4，农业+0.4，工业+0.2，服务业+0.2，生活水平+0.4
## |水稻共和国|预算+1，农业+0.3，工业+0.2，生活水平-0.6，人民支持度-1.0，思想自由化+1.0，与美关系+0.2，与苏关系+0.2，国际影响力-0.1
## |缓慢推进集体化的公社：|农业+0.1，工业+0.1，生活水平+0.2，预算+0.1
## |家庭联产承包责任制：|预算+0.4，腐败+0.3|若福利投资低于20，则农业-0.2，生活水平-0.2，服务业-0.2|若福利投资高于20，则农业+0.2，生活水平+0.2，服务业+0.2
## |私人农场：|农业-0.4，生活水平-0.4，预算+1.0，服务业+0.2，腐败+0.4，寡头+4
## |快速推进集体化的公社：|农业+0.4，工业+0.4，生活水平+0.4，预算+0.2
## |农业机械化：|农业+0.6，工业+0.4
## |普及化肥与杀虫剂：|农业+0.3，生活水平+0.4
## |转基因技术：|农业+0.2，工业+0.2，生活水平+0.5，预算+0.3
