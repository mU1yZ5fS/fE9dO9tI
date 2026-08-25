extends "res://数据脚本/event_script_base.gd"

## 原作 Event633.cs：永恒的春天（危地马拉内战转折，四选项）。
## 触发：ReqEventsDLC02.cs:976-979 —— IsAuthoritarianism(149) && DATE_AFTER 1982.3.23。
##   IsAuthoritarianism 无单一 ExprNode → trigger_script evaluate。
## 差异：原版按 data.political_line/对美关系 Destroy(button[i])；Godot _disable 同义；
##   美国总统 now_leader==0(里根)/否则(卡特) 用 empires[0].current_leader 分支。

const TXT_OPT0_DIS := "event.script.event_633_eternal_spring.c0"
const TXT_OPT1_DIS := "event.script.event_633_eternal_spring.c1"
const TXT_OPT2_DIS := "event.script.event_633_eternal_spring.c2"
const TXT_MASSACRE := "event.script.event_633_eternal_spring.c3"
const TXT_MASSACRE_REAGAN := "event.script.eternal_spring.txt_massacre_reagan"
const TXT_MASSACRE_CARTER := "event.script.eternal_spring.txt_massacre_carter"
const TXT_R0_END := "event.script.event_633_eternal_spring.c4"
const TXT_R1_BASE := "event.script.event_633_eternal_spring.c5"
const TXT_R2_A := "event.script.event_633_eternal_spring.c6"
const TXT_R2_B := "event.script.event_633_eternal_spring.c7"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null or event_def.options.size() < 4:
		return
	var line := _res(W.I_POLITICAL_LINE)
	var usa_rel := ws.empires[0].relations if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var opt := event_def.options
	if line < 2:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 0:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line > 2 and usa_rel >= 500:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var guatemala := ws.get_country_by_legacy_index(149)
	var usa_leader := ws.empires[0].current_leader if ws.empires.size() > 0 and ws.empires[0] != null else 0
	var president_tail := tr(TXT_MASSACRE_REAGAN) if usa_leader == 0 else tr(TXT_MASSACRE_CARTER)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_MASSACRE) + "\n" + president_tail + "\n" + tr(TXT_R0_END)
			if guatemala != null:
				guatemala.level_of_instability += 50
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			_add(W.I_ARMY, -50)
			ws.influence_prc += 5
			_add_power(EmpireData.USA, -5)
			_add_relation(EmpireData.USA, -50)
		1:
			context["result_text"] = tr(TXT_R1_BASE) + "\n" + president_tail
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if guatemala != null:
				guatemala.level_of_instability -= 50
			_add_power(EmpireData.USA, 5)
			ws.influence_prc -= 5
		2:
			context["result_text"] = tr(TXT_R2_A) + _leader_name() + tr(TXT_R2_B) + "\n" + president_tail
			_add(W.I_BUDGET, -20)
			if guatemala != null:
				guatemala.set_tag("对华贸易", true)
			_add_power(EmpireData.USA, 5)
			_add_relation(EmpireData.USA, 80)
		3:
			context["result_text"] = tr(TXT_MASSACRE) + "\n" + president_tail
			_add_power(EmpireData.USA, 5)


func evaluate(world: WorldState) -> bool:
	if world == null or world.date == null or world.date.to_int() < 19820323:
		return false
	var guatemala := world.get_country_by_legacy_index(149)
	return guatemala != null and world.is_authoritarian(guatemala)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_633_eternal_spring.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_633",
	"num": 633,
	"priority": 63300,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_633_eternal_spring.gd",
	"trigger_script": "res://数据脚本/事件效果/event_633_eternal_spring.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
