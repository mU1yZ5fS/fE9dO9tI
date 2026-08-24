extends "res://数据脚本/event_script_base.gd"

## 原作 Event550.cs：朝花夕拾（民族区域自治改革，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:52-54 —— data.territory_policy != 20。
## 差异：描述由 prepare 动态拼领袖姓名。

const TXT_DESC := "event.script.event_550_ethnic_federalism.c0"
const TXT_OPT0_DIS := "event.script.event_550_ethnic_federalism.c1"
const TXT_OPT1_DIS := "event.script.event_550_ethnic_federalism.c2"
const TXT_OPT2_DIS_FAR := "event.script.event_550_ethnic_federalism.c3"
const TXT_OPT2_DIS_LIE := "event.script.event_550_ethnic_federalism.c4"
const TXT_OPT3_DIS := "event.script.event_550_ethnic_federalism.c5"
const TXT_R0 := "event.script.event_550_ethnic_federalism.c6"
const TXT_R1 := "event.script.event_550_ethnic_federalism.c7"
const TXT_R2 := "event.script.event_550_ethnic_federalism.c8"
const TXT_R3 := "event.script.event_550_ethnic_federalism.c9"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null:
		return
	event_def.description = _leader_name() + tr(TXT_DESC)
	if event_def.options.size() < 4:
		return
	var opt := event_def.options
	var line := d.political_line
	if line >= 1:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line != 2 and line != 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line < 4 and d.territory_policy == 21:
		_enable(opt[2], event_def.options[2].text)
	elif d.territory_policy != 21:
		_disable(opt[2], tr(TXT_OPT2_DIS_FAR))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_LIE))
	if line < 4:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_BUDGET, -80)
			_add(W.I_INDUSTRY, -150)
			_add(W.I_AGRICULTURE, -150)
			_add(W.I_SERVICES, -150)
			_add(W.I_CORRUPTION, 30)
			_add(W.I_LIVING, -100)
			_add(W.I_PARTY_SUPPORT, 20)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 150)
			_add_relation(EmpireData.USA, 200)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, -30)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -150)
			_add(W.I_INDUSTRY, -250)
			_add(W.I_AGRICULTURE, -250)
			_add(W.I_SERVICES, -250)
			_add(W.I_CORRUPTION, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 250)
			_add_relation(EmpireData.USA, 150)
			_add_relation(EmpireData.USSR, 250)
			_add(W.I_DIPLO, 10)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 60)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_add(W.I_MANPOWER, 150)
			_add(W.I_DIPLO, 20)
			ws.influence_prc += 5
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, -20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_set_data(W.I_TERRITORY, 20)
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -100)
			_add(W.I_WAR_SUPPORT, 400)
			_add(W.I_MANPOWER, -100)
			_add(W.I_DIPLO, 100)
			ws.influence_prc -= 5
			context["result_text"] = tr(TXT_R3)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_550_ethnic_federalism.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_550",
	"nodesc": true,
	"num": 550,
	"priority": 55000,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_550_ethnic_federalism.gd",
	"trigger": [{"t": "RESOURCE_NOT_EQUALS", "key": "territorial_policy", "v": 20}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
