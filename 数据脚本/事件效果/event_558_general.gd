extends "res://数据脚本/event_script_base.gd"

## 原作 Event558.cs：将军（苏联利加乔夫上台，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:1244-1246 —— 复杂条件见 evaluate()。

const TXT_OPT0_DIS := "event.script.event_558_general.c0"
const TXT_OPT2_DIS := "event.script.event_558_general.c1"
const TXT_R0 := "event.script.event_558_general.c2"
const TXT_R1 := "event.script.event_558_general.c3"
const TXT_R2_A := "event.script.event_558_general.c4"
const TXT_R2_TAIL := "event.script.event_558_general.c5"
const TXT_R3 := "event.script.event_558_general.c6"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world
	if dd.size() <= W.I_YEAR:
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	var ussr := world.empires[EmpireData.USSR]
	var c7 := world.get_country_by_legacy_index(7)
	if ussr.current_leader != 6:
		return false
	if c7 == null or c7.sub_government == GameConstants.SubGovernment.PRAGMATIST:
		return false
	if ussr.leaders.size() <= 6 or ussr.leaders[6] == null or ussr.leaders[6].support >= 0:
		return false
	var y := dd.year
	var mo := dd.month
	if (y >= 1985 and mo >= 5) or y >= 1986:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	if d.diplomatic_reputation <= 900 and d.diplomatic_reputation >= 500:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if d.political_line != 0 and d.political_line != 4:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c7 := ws.get_country_by_legacy_index(7)
	var ussr := ws.empires[EmpireData.USSR]
	ussr.current_leader = 8
	if ussr.power < 0:
		ussr.power = 0
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_relation(EmpireData.USSR, 150)
			_add_relation(EmpireData.USA, -50)
			_add(W.I_DIPLO, 10)
			context["result_text"] = tr(TXT_R0)
		1:
			_add_relation(EmpireData.USSR, -150)
			_add_relation(EmpireData.USA, 50)
			_add(W.I_DIPLO, 10)
			_add_power(EmpireData.USSR, -10)
			ws.set_flag("relres", false)
			if c7 != null:
				c7.set_tag("对华贸易", false)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_relation(EmpireData.USSR, 250)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_DIPLO, 20)
			_add_power(EmpireData.USSR, 10)
			_add_power(EmpireData.USA, -20)
			_add(W.I_BUDGET, -40)
			_add(W.I_INDUSTRY, 40)
			_add(W.I_AGRICULTURE, 40)
			ws.influence_prc += 10
			ws.set_flag("relres", true)
			if c7 != null:
				c7.set_tag("对华贸易", true)
			context["result_text"] = tr(TXT_R2_A) + _leader_name() + tr(TXT_R2_TAIL)
		3:
			context["result_text"] = tr(TXT_R3)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_558_general.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_558",
	"num": 558,
	"priority": 55800,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_558_general.gd",
	"trigger_script": "res://数据脚本/事件效果/event_558_general.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
