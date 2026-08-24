extends "res://数据脚本/event_script_base.gd"

## 原作 Event324.cs：中国的地铁？（3选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:554-557 —— 日>=1 月>=10 年>=1979。
## 差异：选项显隐 prepare 动态改写；文本来自 Events_text_en 索引 213-222。

const TXT_OPT1_DIS := "event.script.event_324_china_metro.c0"
const TXT_OPT2_DIS := "event.script.event_324_china_metro.c1"
const TXT_R0 := "event.script.event_324_china_metro.c2"
const TXT_R1 := "event.script.event_324_china_metro.c3"
const TXT_R2 := "event.script.event_324_china_metro.c4"

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
	if br >= 70 and data.industry > 60:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if br >= 70 and data.industry > 30 and data.ussr_relations > 600:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PARTY_SUPPORT, -150)
			ws.influence_prc -= 5
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -60)
			_add(W.I_LIVING, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			ws.influence_prc += 5
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_LIVING, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add_relation(1, 60)
			_add_power(1, 5)
			context["result_text"] = tr(TXT_R2)

	




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_324_china_metro.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_324",
	"num": 324,
	"priority": 32400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_324_china_metro.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1979.10.1"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
