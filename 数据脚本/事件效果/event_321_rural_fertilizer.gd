extends "res://数据脚本/event_script_base.gd"

## 原作 Event321.cs：农村需要化肥（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:539-542 —— 日>=6 月>=3 年>=1982。
## 差异：选项显隐 prepare 动态改写；science[6]→techs.unlocked[6]；old_modify_desc[15] 拼接为修正说明文案跳过。

const TXT_OPT1_DIS := "我们没有足够的资源。"
const TXT_OPT2_DIS := "他们不卖"
const TXT_R0 := "我们有更重要的任务，而化肥业的发展也可能让人民被化学废料毒害......"
const TXT_R1 := "我们的科学家很快研制出了世界上最新的化肥。我们的农民也很积极地开始使用化肥。现在我们已经可以谈论关于提高产量和满足需求了，让我们看看这将如何影响人们的长期健康。"
const TXT_R2 := "我们的贸易代表团购买了国外最新的化肥样品，此后中国农业的发展可谓是一日千里。世界上也有越来越多的国家想和我们进行贸易。"

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
	if br >= 50 and data[W.I_INDUSTRY] >= 500:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], TXT_OPT1_DIS)
	if data[W.I_DIPLO] >= 700 and br >= 50:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], TXT_OPT2_DIS)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = TXT_R0
		1:
			if not _tech_unlocked(6):
				_add(W.I_BUDGET, -50)
				_add(W.I_INDUSTRY, -50)
				_add(W.I_AGRICULTURE, 75)
				ws.techs.unlocked[6] = true
			context["result_text"] = TXT_R1
		2:
			_add(W.I_DIPLO, 100)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGRICULTURE, 50)
			context["result_text"] = TXT_R2

	


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
