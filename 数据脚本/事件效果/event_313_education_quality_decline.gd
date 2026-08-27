extends "res://数据脚本/event_script_base.gd"

## 原作 Event313.cs：教育质量的下降（3选项）。
## 触发：全目录搜索无 this_num_event = 313 / Reset(313) / StartEvent(313)；链外 REST 段，原版无自动条件（决策/其他事件链手动触发）。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 116-125。

const TXT_OPT1_DIS := "event.script.event_313_education_quality_decline.c0"
const TXT_OPT2_DIS := "event.script.event_313_education_quality_decline.c1"
const TXT_R0 := "event.script.event_313_education_quality_decline.c2"
const TXT_R1 := "event.script.event_313_education_quality_decline.c3"
const TXT_R2 := "event.script.event_313_education_quality_decline.c4"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	if data.size() <= W.I_RESERVE:
		return
	var opt := event_def.options
	var br := data.budget + data.reserve
	_enable(opt[0], event_def.options[0].text)
	if br >= 50:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if data.influence_prc > 10:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_SCIENCE, -200)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -30)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_CORRUPTION, -5)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -70)
			_add(W.I_SCIENCE, 300)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_PARTY_SUPPORT, 150)
			_add(W.I_CORRUPTION, -5)
			context["result_text"] = tr(TXT_R2)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_313_education_quality_decline.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_313",
	"num": 313,
	"priority": 31300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_313_education_quality_decline.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
