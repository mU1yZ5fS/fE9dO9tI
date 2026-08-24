extends "res://数据脚本/event_script_base.gd"

## 原作 Event319.cs：农业机械化（4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:519-522 —— 日>=14 月>=7 年>=1980。
## 差异：选项显隐 prepare 动态改写；science[3]→techs.unlocked[3]；old_modify_desc[15] 拼接为修正说明文案，Godot 由 ModifierCatalog 静态维护，跳过。

const TXT_OPT1_DIS := "event.script.event_319_agricultural_mechanization.c0"
const TXT_OPT2_DIS := "event.script.event_319_agricultural_mechanization.c1"
const TXT_OPT3_DIS := "event.script.event_319_agricultural_mechanization.c2"
const TXT_R0 := "event.script.event_319_agricultural_mechanization.c3"
const TXT_R1 := "event.script.event_319_agricultural_mechanization.c4"
const TXT_R2 := "event.script.event_319_agricultural_mechanization.c5"
const TXT_R3 := "event.script.event_319_agricultural_mechanization.c6"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data.budget + data.reserve
	_enable(opt[0], event_def.options[0].text)
	if br >= 50 and data.industry >= 500:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if br >= 50 and data.ussr_relations >= 500:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if br >= 50 and data.diplomatic_reputation >= 500:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			if not _tech_unlocked(3):
				_add(W.I_INDUSTRY, -50)
				_add(W.I_AGRICULTURE, 50)
				ws.techs.unlocked[3] = true
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGRICULTURE, 50)
			_add_relation(1, 50)
			_add_power(1, 5)
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_BUDGET, -50)
			_add(W.I_AGRICULTURE, 50)
			_add_relation(0, 50)
			_add_power(0, 5)
			context["result_text"] = tr(TXT_R3)

	


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



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_319_agricultural_mechanization.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_319",
	"num": 319,
	"priority": 31900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_319_agricultural_mechanization.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1980.7.14"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
