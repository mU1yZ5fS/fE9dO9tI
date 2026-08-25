extends "res://数据脚本/event_script_base.gd"

## 原作 Event487.cs：帝国鹰的回归（西德极右翼，四选项，opt3 恒禁用）。 ## 触发：ReqEventForDLC02.cs:1504-1506 —— ##   ((年>=1980 月>=9 日>=26) (年>=1980 月>=10) 年>=1981)。 ## 差异： ##  - data.war_support 战争支持 → W.I_WAR_SUPPORT；data.political_line 政治路线 → W.I_POLITICAL_LINE； ##  - result1 的领袖姓名拼接 → _leader_name()（names1+names2 → name_display）。



const TXT_OPT1_DIS := "event.script.event_487_return_of_imperial_eagle.c0"
const TXT_OPT2_DIS := "event.script.event_487_return_of_imperial_eagle.c1"
const TXT_OPT3_DIS := "event.script.event_487_return_of_imperial_eagle.c2"

const TXT_R0 := "event.script.event_487_return_of_imperial_eagle.c3"

const TXT_R1_PRE := "event.script.event_487_return_of_imperial_eagle.c4"

const TXT_R1_POST := "event.script.event_487_return_of_imperial_eagle.c5"

const TXT_R2 := "event.script.event_487_return_of_imperial_eagle.c6"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var war_support := world.war_support if world.size() > W.I_WAR_SUPPORT else 0
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var res395 := int(world.completed_event_ids.get("event_395", -1))
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	if war_support >= 700 and not mod3 and line != 4:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if res395 == 0:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_disable(opt[3], tr(TXT_OPT3_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			ws.influence_prc += 5
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			context["result_text"] = tr(TXT_R1_PRE) + _leader_name() + tr(TXT_R1_POST)
		2:
			_add(W.I_DIPLO, 50)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			_add(W.I_ARMY, -100)
			ws.influence_prc += 5
			_add_relation(EmpireData.USA, -150)
			_add_relation(EmpireData.USSR, -150)
			context["result_text"] = tr(TXT_R2)
		3:
			context["result_text"] = tr(TXT_R0)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_487_return_of_imperial_eagle.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_487",
	"num": 487,
	"priority": 48700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_487_return_of_imperial_eagle.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1980.9.26"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
