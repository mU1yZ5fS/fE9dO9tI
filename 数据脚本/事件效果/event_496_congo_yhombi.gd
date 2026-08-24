extends "res://数据脚本/event_script_base.gd"

## 原作 Event496.cs：恩古瓦比的大会？——第一幕（刚果两派斗争，四选项）。
## 触发：TimeScript.cs:10999-11007 —— (月>=2 且 年>=1979 或 年>=1980)
##   && event_done[696] && resultOfEvents[696]==2。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线 + modifies[3]）。
##  - LeaveAlliances() 逐项清标签；puppetOf=21 → puppet_of = GameConstants.LegacySlot.FRANCE（法国）。



const TXT_OPT0_DIS := "event.script.event_496_congo_yhombi.c0"
const TXT_OPT1_DIS := "event.script.event_496_congo_yhombi.c1"
const TXT_OPT2_DIS := "event.script.event_496_congo_yhombi.c2"

const TXT_R0 := "event.script.event_496_congo_yhombi.c3"

const TXT_R1 := "event.script.event_496_congo_yhombi.c4"

const TXT_R2 := "event.script.event_496_congo_yhombi.c5"

const TXT_R3 := "event.script.event_496_congo_yhombi.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 2
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	if line >= 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 2 and not mod3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line < 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var congo := ws.get_country_by_legacy_index(52)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = GameConstants.Government.REFORMIST
				congo.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(congo)
				congo.set_tag("亲中", true)
				congo.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, -50)
			ws.influence_prc += 20
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = GameConstants.Government.REFORMIST
				congo.sub_government = GameConstants.SubGovernment.PRAGMATIST
				_leave_alliances(congo)
				congo.puppet_of = GameConstants.LegacySlot.FRANCE
				congo.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, -50)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.set_tag("对华贸易", true)
			ws.influence_prc += 20
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R3)


## Country.LeaveAlliances() 逐项映射（同 Event587 约定）。



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_496_congo_yhombi.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_496",
	"num": 496,
	"priority": 49600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_496_congo_yhombi.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1979.2.1"}, {"t": "PREV_EVENT_DONE", "ref": "event_696"}, {"t": "PREV_EVENT_RESULT_IS", "v": 2, "ref": "event_696"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
