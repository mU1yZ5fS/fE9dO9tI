extends "res://数据脚本/event_script_base.gd"

## 原作 Event641.cs：若列宁可见今日（苏联改革危机，三选项）。
## 触发：ReqEventsDLC02.cs:1076 —— 复合条件（ev640、苏联 now_leader==7、资源/科技/parts/三盟国），
##   无单一 ExprNode → trigger_script evaluate。
## 差异：science[26]/[22]→techs.unlocked；data.mongolia_china_route 无命名常量，按原版 raw index 读写；
##   proprc/okb→亲中/okb 标签；ingamewars[70] 建模说明 WarDef → 兜底创建后补名。

const TXT_DESC := "event.script.event_641_if_lenin_could_see.c0"
const TXT_OPT0_DIS := "event.script.event_641_if_lenin_could_see.c1"
const TXT_OPT1_DIS := "event.script.event_641_if_lenin_could_see.c2"
const TXT_R0 := "event.script.event_641_if_lenin_could_see.c3"
const TXT_R1_PRE := "event.script.event_641_if_lenin_could_see.c4"
const TXT_R1_POST := "event.script.event_641_if_lenin_could_see.c5"
const TXT_R2 := "event.script.event_641_if_lenin_could_see.c6"


func prepare(event_def: EventDef, _world: WorldState) -> void:
	_bind_world()
	if event_def == null:
		return
	event_def.description = _leader_name() + tr(TXT_DESC)
	if event_def.options.size() < 3:
		return
	var opt := event_def.options
	if _res(W.I_BUDGET) + _res(W.I_RESERVE) >= 100 and _res(W.I_LIVING) >= 800:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if _res(W.I_ARMY) >= 2000 and _res(W.I_AGENTS) >= 750 and _res(W.I_WAR_SUPPORT) >= 700 \
			and _res(W.I_MANPOWER) >= 700 and _res(W.I_DIPLO) >= 1000 \
			and _tech(26) and _tech(22) and d.size() > 130 and d.mongolia_china_route == 1 \
			and _part(1, 0) and not _part(1, 9) and not _part(1, 7) and not _part(1, 8) \
			and _pro_okb(8) and _pro_okb(12) and _pro_okb(44):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
			_add(W.I_PARTY_SUPPORT, 50)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -100)
			_add(W.I_DIPLO, 10)
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -50)
			_add(W.I_POPULATION, 2)
			_add_relation(EmpireData.USSR, -200)
			_add_power(EmpireData.USSR, -15)
			_add_relation(EmpireData.USA, -50)
			_add_power(EmpireData.USA, -15)
			ws.influence_prc += 15
		1:
			context["result_text"] = tr(TXT_R1_PRE) + _leader_name() + tr(TXT_R1_POST)
			# 原版 ingamewars[70]：雪耻之战，中国(500) vs 苏联(500)，AmericanSupportDefender、SovietSupportDefender
			game.start_war(70, "中华人民共和国", "苏联", 500, 500, 2, 2)
			if ws.wars.size() > 70 and ws.wars[70] != null:
				ws.wars[70].name_war = "雪耻之战"
			_add(W.I_PARTY_SUPPORT, 300)
			_add(W.I_PEOPLE_SUPPORT, 300)
			_add(W.I_THOUGHT_FREEDOM, -200)
			_set_data(W.I_DIPLO, 1100)
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -750)
			_add(W.I_ARMY, -2000)
			_add(W.I_POPULATION, 2)
			_add_relation(EmpireData.USSR, -500)
			_add_power(EmpireData.USSR, -15)
			_add_relation(EmpireData.USA, -500)
			_add_power(EmpireData.USA, -15)
			ws.influence_prc += 15
		2:
			context["result_text"] = tr(TXT_R2)


func evaluate(world: WorldState) -> bool:
	if world == null or not world.completed_event_ids.has("event_640"):
		return false
	if world.empires.size() <= EmpireData.USSR or world.empires[EmpireData.USSR] == null \
			or world.empires[EmpireData.USSR].current_leader != 7:
		return false
	var dd := world
	if dd.size() <= W.I_MANPOWER or dd.size() <= 130:
		return false
	if dd.war_support < 700 or dd.manpower < 700 or dd.diplomatic_reputation < 1000:
		return false
	if not _tech_on(world, 26) or not _tech_on(world, 22):
		return false
	if dd.mongolia_china_route != 1:
		return false
	if not _part_on(world, 1, 0) or _part_on(world, 1, 9) or _part_on(world, 1, 7) or _part_on(world, 1, 8):
		return false
	return _pro_okb_on(world, 8) and _pro_okb_on(world, 12) and _pro_okb_on(world, 44)


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _tech(idx: int) -> bool:
	return ws.techs != null and idx >= 0 and idx < ws.techs.unlocked.size() and ws.techs.unlocked[idx]


func _tech_on(world: WorldState, idx: int) -> bool:
	return world.techs != null and idx >= 0 and idx < world.techs.unlocked.size() and world.techs.unlocked[idx]


func _part(idx: int, part: int) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.parts.size() > part and c.parts[part]


func _part_on(world: WorldState, idx: int, part: int) -> bool:
	var c := world.get_country_by_legacy_index(idx)
	return c != null and c.parts.size() > part and c.parts[part]


func _pro_okb(idx: int) -> bool:
	var c := ws.get_country_by_legacy_index(idx)
	return c != null and c.has_tag("亲中") and c.has_tag("okb")


func _pro_okb_on(world: WorldState, idx: int) -> bool:
	var c := world.get_country_by_legacy_index(idx)
	return c != null and c.has_tag("亲中") and c.has_tag("okb")



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_641_if_lenin_could_see.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_641",
	"nodesc": true,
	"num": 641,
	"priority": 64100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_641_if_lenin_could_see.gd",
	"trigger_script": "res://数据脚本/事件效果/event_641_if_lenin_could_see.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
