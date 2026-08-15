extends "res://数据脚本/event_script_base.gd"

## 原作 Event493.cs：我们需要石油？（石油会战，五选项）。
## 触发：ReqEventForDLC02.cs:1529-1531 ——
##   ((年>=1978 月>=10 日>=8) || (年>=1978 月>=11) || 年>=1979)。
## 差异：
##  - data[8]+data[36] → 预算+外汇（W.I_BUDGET + W.I_RESERVE）；
##  - data[69] 国债 → W.I_LOAN；OilProd 未建模，跳过（modifier_catalog.gd:1037）；
##  - result2 标题切换 → context["result_title"]。

const TXT_TITLE := "我们需要石油？"
const TXT_TITLE_DAQING := "大庆：王进喜的遗产"

const TXT_DESC := "随着我国工业的飞速发展，另一项问题开始浮出水面：我国的石油储量越显尴尬。工业的运转需要石油的润滑，一旦石油储备见底，我们所遇到的危机可能就不只是工厂停工了。为此，我们的委员会出台了一些方案。我们可以采购更新更好的开采工具，也可以发动“石油会战”来鼓舞我们的石油工人。或者直接买外国人的会更好？无论如何，决定权在您的手上！"

const TXT_OPT0 := "采购最新的开采设备"
const TXT_OPT0_DIS := "可惜我们没有这么多钱"
const TXT_OPT1 := "在中宣部和各级党委的鼓动下，号召工人"
const TXT_OPT2 := "设备号召两手抓，这是社会主义建设所必要的！"
const TXT_OPT2_DIS_POOR := "我们没有钱"
const TXT_OPT2_DIS_FAITH := "越奉献越成功……道理很好听，可惜没人信了"
const TXT_OPT3 := "呼吁外国的帮助"
const TXT_OPT3_DIS := "想法很好，但没人愿意帮一个恶霸"
const TXT_OPT4 := "没有这个必要"

const TXT_R0 := "我们和美国以及苏联的石油开采公司达成了协议。最终，我们得以凭借一笔优惠的价格的到了一批优质的钻头和钻井平台。凭借他们，我们一定能克服石油短缺的问题。"

const TXT_R1_BEST := "大庆精神是我国石油职工学习和运用毛泽东思想，继承和发扬中国共产党、中国工人阶级、中国人民解放军的优良传统，在60年代波澜壮阔的石油大会战中，逐步培育和形成的，并在火热生动的油田生产建设实践中不断丰富、创新和发展。而今天，这一精神又有了用武之地。在中宣部的鼓舞下，一笔资金被投入石油生产领域。这将被用来奖励超额完成目标的石油工人。最终，这场“新石油会战”以超额300%的极高水平完成了任务。我们又一次战胜了自己的记录！"

const TXT_R1_OK := "大庆精神是我国石油职工学习和运用毛泽东思想，继承和发扬中国共产党、中国工人阶级、中国人民解放军的优良传统，在60年代波澜壮阔的石油大会战中，逐步培育和形成的，并在火热生动的油田生产建设实践中不断丰富、创新和发展。而今天，这一精神……似乎还能算有点“用武之地”——即使有中宣部的鼓舞，石油工人的热情并不特别高涨……最终，这场“新石油会战”以超额143%的水平完成了任务，并不是特别出色，但也够解决当前工业的燃眉之急。"

const TXT_R2 := "大庆精神是我国石油职工学习和运用毛泽东思想，继承和发扬中国共产党、中国工人阶级、中国人民解放军的优良传统，在60年代波澜壮阔的石油大会战中，逐步培育和形成的，并在火热生动的油田生产建设实践中不断丰富、创新和发展。而今天，这一精神又有了用武之地。在我们的鼓舞下，一笔资金被投入石油生产领域。这将被用来采购更好的开采机械和奖励超额完成目标的石油工人。最终，这场“新石油会战”以超额400%的极高水平完成了任务。我们又一次战胜了自己的记录！这是无产阶级的胜利！"

const TXT_R3 := "我们的呼吁的到了外国友人的帮助，很快，我们便得到了足够的石油。当然代价也是显而易见的的。我们不得不偿还一笔债务。"

const TXT_R4 := "挖不如买，买不如省，大不了就苦一苦工业，反正骂名也不是我背！"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var budget := world.数值表[W.I_BUDGET] if world.数值表.size() > W.I_BUDGET else 0
	var reserve := world.数值表[W.I_RESERVE] if world.数值表.size() > W.I_RESERVE else 0
	var money := budget + reserve
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var ussr_rel := 0
	var usa_rel := 0
	if world.empires.size() > EmpireData.USSR and world.empires[EmpireData.USSR] != null:
		ussr_rel = world.empires[EmpireData.USSR].relations
	if world.empires.size() > EmpireData.USA and world.empires[EmpireData.USA] != null:
		usa_rel = world.empires[EmpireData.USA].relations
	var opt := event_def.options
	if money >= 80:
		_enable(opt[0], TXT_OPT0)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], TXT_OPT1)
	if money >= 50 and mod3:
		_enable(opt[2], TXT_OPT2)
	elif money < 50:
		_disable(opt[2], TXT_OPT2_DIS_POOR)
	else:
		_disable(opt[2], TXT_OPT2_DIS_FAITH)
	if ussr_rel >= 500 or usa_rel >= 500:
		_enable(opt[3], TXT_OPT3)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], TXT_OPT4)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	context["result_title"] = TXT_TITLE
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -80)
			# OilProd += 500f：项目未建模，跳过（modifier_catalog.gd:1037）
			context["result_text"] = TXT_R0
		1:
			var people := d[W.I_PEOPLE_SUPPORT] if d.size() > W.I_PEOPLE_SUPPORT else 0
			var living := d[W.I_LIVING] if d.size() > W.I_LIVING else 0
			var mod3 := ws.modifiers.size() > 3 and ws.modifiers[3] != null and ws.modifiers[3].is_active
			if (people >= 700 and living >= 600) or (people >= 500 and living >= 400 and mod3):
				_add(W.I_BUDGET, -5)
				_add(W.I_LIVING, -60)
				# OilProd += 600f：项目未建模，跳过
				context["result_text"] = TXT_R1_BEST
			else:
				_add(W.I_BUDGET, -5)
				_add(W.I_LIVING, -50)
				# OilProd += 400f：项目未建模，跳过
				context["result_text"] = TXT_R1_OK
		2:
			context["result_title"] = TXT_TITLE_DAQING
			_add(W.I_BUDGET, -50)
			_add(W.I_LIVING, -50)
			# OilProd += 1000f：项目未建模，跳过
			context["result_text"] = TXT_R2
		3:
			_add(W.I_LOAN, 50)
			if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null \
					and ws.empires[EmpireData.USA].relations >= 500:
				_add_relation(EmpireData.USA, -50)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].relations >= 500:
				_add_relation(EmpireData.USSR, -50)
			# OilProd += 400f：项目未建模，跳过
			context["result_text"] = TXT_R3
		4:
			context["result_text"] = TXT_R4


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
