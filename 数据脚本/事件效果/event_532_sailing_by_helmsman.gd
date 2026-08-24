extends "res://数据脚本/event_script_base.gd"

## 原作 Event532.cs：大海航行靠舵手（日本共产主义抵抗者同盟合并，2选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:287-289 ——
##   event_done[524] && resultOfEvents[524]==0 && c44.puppetOf<0
##   && c44.prcpower>=100 && c44.SubGosstroy==6 && (1982.1 或 1983+)。

const TXT_OPT0_DIS := "event.script.event_532_sailing_by_helmsman.c0"
const TXT_R0 := "event.script.event_532_sailing_by_helmsman.c1"
const TXT_R1 := "event.script.event_532_sailing_by_helmsman.c2"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 2:
		return
	if d.political_line < 2:
		_enable(event_def.options[0], event_def.options[0].text)
	else:
		_disable(event_def.options[0], tr(TXT_OPT0_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c44 := ws.get_country_by_legacy_index(44)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_PARTY_SUPPORT, 80)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_DIPLO, 5)
			_add_relation(EmpireData.USA, -50)
			if c44 != null:
				c44.prc_power += 10
			ws.influence_prc += 10
			context["result_text"] = tr(TXT_R0)
		1:
			ws.influence_prc -= 10
			context["result_text"] = tr(TXT_R1)



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_532_sailing_by_helmsman.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_532",
	"num": 532,
	"priority": 53200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_532_sailing_by_helmsman.gd",
	"trigger": [{"t": "COUNTRY_FIELD_AT_MOST", "key": "puppet_of", "v": -1, "target": "44"}, {"t": "PREV_EVENT_DONE", "ref": "event_524"}, {"t": "PREV_EVENT_RESULT_IS", "ref": "event_524"}, {"t": "COUNTRY_FIELD_AT_LEAST", "key": "prc_power", "v": 100, "target": "44"}, {"t": "COUNTRY_FIELD_EQUALS", "key": "sub_government", "v": 6, "target": "44"}, {"t": "ANY", "c": [{"t": "DATE_AFTER", "key": "1982.1.1"}, {"t": "DATE_AFTER", "key": "1983.1.1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
