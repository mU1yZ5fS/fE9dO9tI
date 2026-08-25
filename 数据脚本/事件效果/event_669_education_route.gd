extends "res://数据脚本/event_script_base.gd"

## 原作 Event669.cs：如切如磋，如琢如磨（教育路线大论战，四选项）。
## 触发：ReqEventsDLC02.cs:324-326 —— DATE_AFTER 1977.10.12。
## 差异：leader.name_1==2 && name_2==2 → ws.leader.name_display=="华国锋"；
##   结果尾 old_modify_desc[2] 由 ModifierCatalog 静态维护，按 event_668 约定跳过。

const TXT_OPT0_DIS := "event.script.event_669_education_route.c0"
const TXT_OPT1_DIS_A := "event.script.event_669_education_route.c1"
const TXT_OPT1_DIS_B := "event.script.event_669_education_route.c2"
const TXT_OPT2_DIS := "event.script.event_669_education_route.c3"
const TXT_OPT3_DIS := "event.script.event_669_education_route.c4"
const TXT_R0 := "event.script.event_669_education_route.c5"
const TXT_R1 := "event.script.event_669_education_route.c6"
const TXT_R2 := "event.script.event_669_education_route.c7"
const TXT_R3 := "event.script.event_669_education_route.c8"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var opt := event_def.options
	if line == 0:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 0 and line < 3:
		_enable(opt[1], event_def.options[1].text)
	elif line == 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	if line > 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	# 原版 leader.name_1==2 && name_2==2（华国锋）→ name_display 等价
	if line <= 1 and _leader_name() == "华国锋":
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, 100)
		1:
			context["result_text"] = tr(TXT_R1)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 50)
		2:
			context["result_text"] = tr(TXT_R2)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 150)
		3:
			context["result_text"] = tr(TXT_R3)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, 150)
			_add(W.I_THOUGHT_FREEDOM, -200)
			_add(W.I_AGENTS, -100)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_669_education_route.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_669",
	"num": 669,
	"priority": 66900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_669_education_route.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1977.10.12"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
