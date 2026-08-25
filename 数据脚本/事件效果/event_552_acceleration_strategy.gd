extends "res://数据脚本/event_script_base.gd"

## 原作 Event552.cs：加速发展战略？（苏联改革，5选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:62-64 —— 复杂条件见 evaluate()。
## 差异：SOV_PRC_PartiesConnection→I_COMMUNICATIONS；relres→ws.set_flag。

const TXT_OPT0_DIS := "event.script.event_552_acceleration_strategy.c0"
const TXT_OPT1_DIS := "event.script.event_552_acceleration_strategy.c1"
const TXT_OPT2_DIS := "event.script.event_552_acceleration_strategy.c2"
const TXT_OPT3_DIS := "event.script.event_552_acceleration_strategy.c3"
const TXT_R0 := "event.script.event_552_acceleration_strategy.c4"
const TXT_R1_A := "event.script.event_552_acceleration_strategy.c5"
const TXT_R1_B := "event.script.event_552_acceleration_strategy.c6"
const TXT_R2 := "event.script.event_552_acceleration_strategy.c7"
const TXT_R3_A := "event.script.event_552_acceleration_strategy.c8"
const TXT_R3_TAIL := "event.script.acceleration_strategy.txt_r3_tail"
const TXT_R4 := "event.script.event_552_acceleration_strategy.c9"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world
	if dd.size() <= W.I_DAY:
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null:
		return false
	var ussr := world.empires[EmpireData.USSR]
	if ussr.current_leader != 6 or ussr.power > 100:
		return false
	if world.get_flag("IndOpp"):
		return false
	var y := dd.year
	var mo := dd.month
	var day := dd.day
	if (y >= 1985 and mo >= 4 and day >= 1) or (y >= 1985 and mo >= 5) or y >= 1986:
		return true
	return false


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var opt := event_def.options
	var num := _count_proprc([21, 85, 86, 87, 92])
	var num2 := _count_proprc([2, 3, 4, 6, 5])
	var c1 := world.get_country_by_legacy_index(1)
	var c51 := world.get_country_by_legacy_index(51)
	var ussr := ws.empires[EmpireData.USSR]
	var cond_base := ussr != null and ws.influence_prc >= ussr.power and ws.influence_prc >= 750
	if d.industry >= 1000 and d.agriculture >= 1000 and d.services >= 1000 and cond_base:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if num >= 3 and c1 != null and c1.has_tag("econ") and cond_base:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if c51 != null and c51.has_tag("对华贸易") and c51.development == 1 and d.political_line >= 3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if num >= 3 and num2 >= 3 and c1 != null and c1.has_tag("econ") and cond_base:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c0 := ws.get_country_by_legacy_index(0)
	var c7 := ws.get_country_by_legacy_index(7)
	var ussr := ws.empires[EmpireData.USSR]
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			ws.set_flag("relres", true)
			if c7 != null:
				c7.set_tag("对华贸易", true)
			_add_relation(EmpireData.USSR, 200)
			_add_relation(EmpireData.USA, -100)
			_add(W.I_COMMUNICATIONS, 250)
			_add(W.I_BUDGET, 150)
			_add(W.I_AGENTS, -150)
			_add(W.I_SCIENCE, -8000)
			_add(W.I_INDUSTRY, -100)
			_add(W.I_SERVICES, -100)
			_add(W.I_THOUGHT_FREEDOM, 50)
			ws.influence_prc += 30
			_add_power(EmpireData.USSR, 50)
			ussr.money -= 150
			if ussr.leaders.size() > 6 and ussr.leaders[6] != null:
				ussr.leaders[6].support += 2
			context["result_text"] = tr(TXT_R0)
		1:
			var text := _leader_name() + tr(TXT_R1_A)
			if c0 != null and not c0.has_tag("eu") and not c0.has_tag("nato"):
				ws.influence_prc += 20
			else:
				text = _leader_name() + tr(TXT_R1_B)
				ws.influence_prc += 10
				_add_power(EmpireData.USA, 30)
			ws.set_flag("relres", false)
			if c7 != null:
				c7.set_tag("对华贸易", false)
				c7.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
			_add(W.I_COMMUNICATIONS, -50)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 20
			_add_relation(EmpireData.USSR, -250)
			_add_relation(EmpireData.USA, 50)
			_add_power(EmpireData.USSR, -200)
			_add_power(EmpireData.USA, 10)
			ussr.money -= 150
			ws.empires[EmpireData.USA].money += 150
			if ussr.leaders.size() > 6 and ussr.leaders[6] != null:
				ussr.leaders[6].support -= 1
			context["result_text"] = text
		2:
			ws.set_flag("relres", true)
			if c7 != null:
				c7.set_tag("对华贸易", true)
				c7.set_tag("亲苏", false)
				c7.government = GameConstants.Government.REFORMIST
				c7.sub_government = GameConstants.SubGovernment.PRAGMATIST
			_add_relation(EmpireData.USSR, 100)
			_add_relation(EmpireData.USA, 150)
			_add(W.I_COMMUNICATIONS, 250)
			_add(W.I_BUDGET, 50)
			_add(W.I_AGENTS, -150)
			_add(W.I_SCIENCE, -4000)
			_add(W.I_INDUSTRY, -50)
			_add(W.I_SERVICES, -50)
			_add(W.I_THOUGHT_FREEDOM, 100)
			ws.influence_prc += 20
			_add_power(EmpireData.USA, 100)
			ussr.money -= 150
			ws.empires[EmpireData.USA].money += 100
			if ussr.leaders.size() > 6 and ussr.leaders[6] != null:
				ussr.leaders[6].support += 1
			context["result_text"] = tr(TXT_R2)
		3:
			ws.set_flag("relres", true)
			if c7 != null:
				c7.set_tag("对华贸易", true)
				c7.set_tag("亲苏", false)
				c7.government = GameConstants.Government.REFORMIST
				c7.sub_government = GameConstants.SubGovernment.RENEWAL_SOCIALIST
			_add_relation(EmpireData.USSR, 100)
			_add_relation(EmpireData.USA, -250)
			_add(W.I_COMMUNICATIONS, 250)
			_add(W.I_BUDGET, -450)
			_add(W.I_AGENTS, -350)
			_add(W.I_ARMY, -250)
			_add(W.I_SCIENCE, -12000)
			_add(W.I_INDUSTRY, -200)
			_add(W.I_AGRICULTURE, -100)
			_add(W.I_SERVICES, -150)
			_add(W.I_THOUGHT_FREEDOM, 100)
			ws.influence_prc += 100
			ussr.money += 150
			context["result_text"] = tr(TXT_R3_A) + _leader_name() + tr(TXT_R3_TAIL)
		4:
			ussr.money -= 150
			if ussr.leaders.size() > 6 and ussr.leaders[6] != null:
				ussr.leaders[6].support += 1
			context["result_text"] = tr(TXT_R4)


func _count_proprc(indices: Array) -> int:
	var n := 0
	for idx in indices:
		var c := ws.get_country_by_legacy_index(int(idx))
		if c != null and c.has_tag("亲中"):
			n += 1
	return n


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_552_acceleration_strategy.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_552",
	"num": 552,
	"priority": 55200,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_552_acceleration_strategy.gd",
	"trigger_script": "res://数据脚本/事件效果/event_552_acceleration_strategy.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
