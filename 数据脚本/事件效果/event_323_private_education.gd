extends "res://数据脚本/event_script_base.gd"

## 原作 Event323.cs：私立教育（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:549-552 —— 经济体制>=13 且 IsFactionLeadeng(4) 且 日>=12 月>=9 年>=1982。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 203-212。

const TXT_OPT1_DIS := "event.script.event_323_private_education.c0"
const TXT_OPT2_DIS := "event.script.event_323_private_education.c1"
const TXT_R0 := "event.script.event_323_private_education.c2"
const TXT_R1 := "event.script.event_323_private_education.c3"
const TXT_R2 := "event.script.event_323_private_education.c4"

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
	if br >= 70 and data.econ_system > 13:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if data.diplomatic_reputation >= 700 and data.econ_system > 13 and game.is_faction_leading(4):
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, 25)
			_add(W.I_SCIENCE, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_LIVING, -15)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, 80)
			_add(W.I_SCIENCE, 200)
			_add(W.I_THOUGHT_FREEDOM, 200)
			_add(W.I_LIVING, -250)
			context["result_text"] = tr(TXT_R2)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_323_private_education.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_323",
	"num": 323,
	"priority": 32300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_323_private_education.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1982.9.12"}, {"t": "RESOURCE_AT_LEAST", "key": "economy_system", "v": 13}, {"t": "IS_FACTION_LEADER", "v": 4}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
