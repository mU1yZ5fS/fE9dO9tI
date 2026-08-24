extends "res://数据脚本/event_script_base.gd"

## 原作 Event696.cs：人民刚果的文化大革命（三选项）。
## 触发：TimeScript.cs:10992-10998 —— 日>=15 且 月>=3 且 年>=1977
##   （或月>=4 年>=1977 / 年>=1978）。
## 差异：
##  - 选项显隐 prepare 动态改写（data56 政治路线 + modifies[6]/[3]）。
##  - c52=刚果（布）；prosov→亲苏、proprc→亲中、Torg→对华贸易；
##    empires[1].leaders[4].support++ → 苏联领导人表第4槽支持度+1。



const TXT_OPT0_DIS := "event.script.event_696_congo_cultural_revolution.c0"
const TXT_OPT1_DIS_0 := "event.script.event_696_congo_cultural_revolution.c1"
const TXT_OPT1_DIS_OTHER := "event.script.event_696_congo_cultural_revolution.c2"

const TXT_R0 := "event.script.event_696_congo_cultural_revolution.c3"

const TXT_R1 := "event.script.event_696_congo_cultural_revolution.c4"

const TXT_R2 := "event.script.event_696_congo_cultural_revolution.c5"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var data := world
	var line := data.political_line if data.size() > W.I_POLITICAL_LINE else 3
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var opt := event_def.options
	if line <= 1 and mod6 and mod3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 0 and line < 4:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_0))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_OTHER))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var congo := ws.get_country_by_legacy_index(52)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -30)
			if congo != null:
				congo.government = GameConstants.Government.AUTHORITARIAN
				congo.sub_government = GameConstants.SubGovernment.LEFT_RADICAL
				congo.set_tag("对华贸易", true)
				congo.set_tag("亲中", true)
			_add_relation(EmpireData.USA, -75)
			_add_relation(EmpireData.USSR, -75)
			ws.influence_prc += 20
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -50)
			if congo != null:
				congo.government = GameConstants.Government.SOCIALIST
				congo.sub_government = GameConstants.SubGovernment.SOVIET_STYLE
				congo.set_tag("对华贸易", false)
				congo.set_tag("亲苏", true)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
					and ws.empires[EmpireData.USSR].leaders.size() > 4 \
					and ws.empires[EmpireData.USSR].leaders[4] != null:
				ws.empires[EmpireData.USSR].leaders[4].support += 1
			context["result_text"] = tr(TXT_R1)
		2:
			context["result_text"] = tr(TXT_R2)






# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_696_congo_cultural_revolution.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_696",
	"num": 696,
	"priority": 69600,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_696_congo_cultural_revolution.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.3.15"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
