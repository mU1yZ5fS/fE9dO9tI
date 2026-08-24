extends "res://数据脚本/event_script_base.gd"

## 原作 Event533.cs：打入主义的再实践？（日本托派打入日共，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:292-294 ——
##   event_done[523] && resultOfEvents[523]==0 && !modifies[3].active
##   && c44.puppetOf<0 && c44.SubGosstroy==6 && (1982.6 或 1983+)。

const TXT_OPT0_DIS_TROT := "event.script.event_533_entryism_again.c0"
const TXT_OPT0_DIS_POWER := "event.script.event_533_entryism_again.c1"
const TXT_OPT0_DIS_OTHER := "event.script.event_533_entryism_again.c2"
const TXT_R0 := "event.script.event_533_entryism_again.c3"
const TXT_R1 := "event.script.event_533_entryism_again.c4"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	var opt := event_def.options
	var c44 := world.get_country_by_legacy_index(44)
	if d.political_line == 0 and c44 != null and c44.prc_power >= 120 and not ws.modifiers[3].is_active:
		_enable(opt[0], event_def.options[0].text)
	elif ws.modifiers[3].is_active:
		_disable(opt[0], tr(TXT_OPT0_DIS_TROT))
	elif c44 == null or c44.prc_power < 120:
		_disable(opt[0], tr(TXT_OPT0_DIS_POWER))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_OTHER))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -150)
			_add(W.I_AGENTS, -150)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_DIPLO, 10)
			ws.influence_prc += 30
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_533_entryism_again.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_533",
	"num": 533,
	"priority": 53300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_533_entryism_again.gd",
	"trigger": [{"t": "COUNTRY_FIELD_AT_MOST", "key": "puppet_of", "v": -1, "target": "44"}, {"t": "MODIFIER_INACTIVE", "key": "3"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_523"}, {"t": "PREV_EVENT_DONE", "ref": "event_523"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 6, "target": "44"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1982.6.1"}, {"t": "DATE_AFTER", "key": "1983.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
