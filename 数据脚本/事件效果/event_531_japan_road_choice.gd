extends "res://数据脚本/event_script_base.gd"

## 原作 Event531.cs：变则善，常变则至善（日本保革伯仲链，3选项）。 ## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:282-284 —— ##   event_done[527] event_done[528] && !event_done[530] && c44.puppetOf<0 ##   && c44.SubGosstroy==8 && (1981.6 或 1982+)。 ## 差异：resultOfEvents 缺省按原版 int 默认 0 处理。

const TXT_OPT0_DIS := "event.script.event_531_japan_road_choice.c0"
const TXT_OPT1_DIS := "event.script.event_531_japan_road_choice.c1"
const TXT_R0 := "event.script.event_531_japan_road_choice.c2"
const TXT_R1 := "event.script.event_531_japan_road_choice.c3"
const TXT_R2 := "event.script.event_531_japan_road_choice.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var opt := event_def.options
	var line := d.political_line
	var r526 := int(ws.completed_event_ids.get("event_526", 0))
	var r525 := int(ws.completed_event_ids.get("event_525", 0))
	var r522 := int(ws.completed_event_ids.get("event_522", 0))
	var r524 := int(ws.completed_event_ids.get("event_524", 0))
	if (line == 2 or line == 1) and (r526 == 0 or r525 == 0):
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line < 2 and r522 == 1 and r526 == 1 and r524 == 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_PARTY_SUPPORT, 80)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, 5)
			ws.influence_prc += 10
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_PARTY_SUPPORT, 80)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, 5)
			ws.influence_prc += 10
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)



# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_531_japan_road_choice.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_531",
	"num": 531,
	"priority": 53100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_531_japan_road_choice.gd",
	"trigger": [{"t": "PREV_EVENT_NOT_DONE", "ref": "event_530"}, {"t": "ALL", "c": [{"t": "PREV_EVENT_DONE", "ref": "event_527"}, {"t": "PREV_EVENT_DONE", "ref": "event_528"}]}, {"t": "COUNTRY_FIELD_AT_MOST", "key": "puppet_of", "v": -1, "target": "44"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 8, "target": "44"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1981.6.1"}, {"t": "DATE_AFTER", "key": "1982.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
