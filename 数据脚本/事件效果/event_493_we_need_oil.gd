extends "res://数据脚本/event_script_base.gd"

## 原作 Event493.cs：我们需要石油？（石油会战，五选项）。
## 触发：ReqEventForDLC02.cs:1529-1531 ——
##   ((年>=1978 月>=10 日>=8) || (年>=1978 月>=11) || 年>=1979)。
## 差异：
##  - data[8]+data[36] → 预算+外汇（W.I_BUDGET + W.I_RESERVE）；
##  - data[69] 国债 → W.I_LOAN；OilProd 已建模（ws.oil_prod）按分支 +500/600/400/1000/400；
##  - result2 标题切换 → context["result_title"]。

const TXT_TITLE := "我们需要石油？"
const TXT_TITLE_DAQING := "大庆：王进喜的遗产"


const TXT_OPT0_DIS := "可惜我们没有这么多钱"
const TXT_OPT2_DIS_POOR := "我们没有钱"
const TXT_OPT2_DIS_FAITH := "越奉献越成功……道理很好听，可惜没人信了"
const TXT_OPT3_DIS := "想法很好，但没人愿意帮一个恶霸"

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
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], TXT_OPT0_DIS)
	_enable(opt[1], event_def.options[1].text)
	if money >= 50 and mod3:
		_enable(opt[2], event_def.options[2].text)
	elif money < 50:
		_disable(opt[2], TXT_OPT2_DIS_POOR)
	else:
		_disable(opt[2], TXT_OPT2_DIS_FAITH)
	if ussr_rel >= 500 or usa_rel >= 500:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], TXT_OPT3_DIS)
	_enable(opt[4], event_def.options[4].text)


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
			ws.oil_prod += 500.0  # Event493.cs result0
			context["result_text"] = TXT_R0
		1:
			var people := d[W.I_PEOPLE_SUPPORT] if d.size() > W.I_PEOPLE_SUPPORT else 0
			var living := d[W.I_LIVING] if d.size() > W.I_LIVING else 0
			var mod3 := ws.modifiers.size() > 3 and ws.modifiers[3] != null and ws.modifiers[3].is_active
			if (people >= 700 and living >= 600) or (people >= 500 and living >= 400 and mod3):
				_add(W.I_BUDGET, -5)
				_add(W.I_LIVING, -60)
				ws.oil_prod += 600.0  # Event493.cs result1 大庆超额300%
				context["result_text"] = TXT_R1_BEST
			else:
				_add(W.I_BUDGET, -5)
				_add(W.I_LIVING, -50)
				ws.oil_prod += 400.0  # Event493.cs result1 大庆超额143%
				context["result_text"] = TXT_R1_OK
		2:
			context["result_title"] = TXT_TITLE_DAQING
			_add(W.I_BUDGET, -50)
			_add(W.I_LIVING, -50)
			ws.oil_prod += 1000.0  # Event493.cs result2 大庆超额400%
			context["result_text"] = TXT_R2
		3:
			_add(W.I_LOAN, 50)
			if ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null \
					and ws.empires[EmpireData.USA].relations >= 500:
				_add_relation(EmpireData.USA, -50)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].relations >= 500:
				_add_relation(EmpireData.USSR, -50)
			ws.oil_prod += 400.0  # Event493.cs result3
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




