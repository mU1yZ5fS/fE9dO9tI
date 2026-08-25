## 原作 Event299.cs：“总崩溃”（意大利第二共和国大选，三选项）。
## 触发：由 Event298 结果链手动触发（原版 load_scene_after_click + number_event=299），无自动条件。
## 差异：Gosstroy/SubGosstroy→government/sub_government；spec→special；inflCh/inflNATO→influence_china/influence_nato；
##  IsSocialism/IsAuthoritarianism 用 ws.is_socialism/ws.is_authoritarian；d.italian_radical_left_power/d.italy_power_176/d.italy_power_177 用 raw index。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT0_DIS := "event.script.event_299_italy_total_collapse.c0"
const TXT_OPT1_DIS := "event.script.event_299_italy_total_collapse.c1"
const TXT_OPT0_DIS_A := "event.script.event_299_italy_total_collapse.c2"
const TXT_OPT0_DIS_B := "event.script.event_299_italy_total_collapse.c3"
const TXT_OPT1_DIS_A := "event.script.event_299_italy_total_collapse.c4"
const TXT_OPT1_DIS_B := "event.script.event_299_italy_total_collapse.c5"
const TXT_R_COLLAPSE := "event.script.event_299_italy_total_collapse.c6"
const TXT_R_LEFT := "event.script.event_299_italy_total_collapse.c7"
const TXT_R_RIGHT := "event.script.event_299_italy_total_collapse.c8"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var line := world.political_line if world.size() > W.I_POLITICAL_LINE else 1
	var d176 := world.italy_power_176 if world.size() > 176 else 0
	var d177 := world.italy_power_177 if world.size() > 177 else 0
	var diplo := world.diplomatic_reputation if world.size() > W.I_DIPLO else 0
	var war := world.war_support if world.size() > W.I_WAR_SUPPORT else 0
	var opt := event_def.options
	if line >= 2 and line <= 3 and d176 > 0:
		_enable(opt[0], event_def.options[0].text)
	elif d176 <= 0:
		_disable(opt[0], tr(TXT_OPT0_DIS_A))
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS_B))
	if diplo >= 800 and war > 300 and line <= 3 and d177 > 0:
		_enable(opt[1], event_def.options[1].text)
	elif d177 <= 0:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	_enable(opt[2], event_def.options[2].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	var usa_power := ws.empires[EmpireData.USA].power if ws.empires.size() > EmpireData.USA \
			and ws.empires[EmpireData.USA] != null else 0
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
			and ws.empires[EmpireData.USSR].power < usa_power:
		_add(177, 1)
	if _c45_is_socialist():
		_add(176, 1)
	if _c84_is_socialist():
		_add(176, 1)
	var c84 := ws.get_country_by_legacy_index(84)
	if c84 != null and c84.sub_government == GameConstants.SubGovernment.RIGHT_AUTHORITARIAN:
		_add(177, 1)
	if c84 != null and c84.sub_government == GameConstants.SubGovernment.NEO_FASCIST:
		_add(177, 2)
	var c20 := ws.get_country_by_legacy_index(20)
	if c20 != null and c20.special == 1:
		_add(177, 1)
	if c20 != null and c20.parts.size() > 0 and c20.parts[0]:
		_add(177, 1)
	if _c86_is_socialist():
		_add(176, 1)
	if _c87_is_socialist():
		_add(176, 1)
	if _c86_is_authoritarian():
		_add(177, 1)
	if _c87_is_authoritarian():
		_add(177, 1)
	if _c21_is_socialist():
		_add(176, 2)
	if _c21_is_authoritarian():
		_add(177, 3)
	if _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
		_add(176, -1)
	if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null \
			and ws.empires.size() > EmpireData.USA and ws.empires[EmpireData.USA] != null \
			and ws.empires[EmpireData.USSR].power >= ws.empires[EmpireData.USA].power:
		_add(176, 1)
	var italy := ws.get_country_by_legacy_index(85)
	if italy != null and italy.level_of_development <= 60 and italy.level_of_development >= 20:
		_add(176, 2)
	var d134 := d.italian_radical_left_power if d.size() > 134 else 0
	if d134 < 60 and d134 >= 20:
		_add(176, 1)
	elif d134 < 100 and d134 >= 60:
		_add(176, -3)
	elif d134 >= 100:
		_add(176, -999)
	if d.size() > 177 and d.italy_power_177 > 1:
		_add(176, -1)
	if opt == 0:
		_add(176, 3)
		_add(181, 2)
	elif opt == 1:
		_add(177, 2)
	if d.size() > 177 and d.size() > 176 and d.italy_power_177 < 0 and d.italy_power_176 < 0:
		if italy != null:
			italy.government = GameConstants.Government.LIBERAL
			italy.sub_government = GameConstants.SubGovernment.NEOLIBERAL
		context["result_text"] = tr(TXT_R_COLLAPSE)
	elif d.size() > 177 and d.size() > 176 and d.italy_power_177 < d.italy_power_176:
		if italy != null:
			italy.government = GameConstants.Government.REFORMIST
			italy.sub_government = GameConstants.SubGovernment.LEFT_CONSERVATIVE
			italy.influence_china = 1
		context["result_text"] = tr(TXT_R_LEFT)
	else:
		if italy != null:
			italy.influence_nato = 1
		context["result_text"] = tr(TXT_R_RIGHT)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)






func _mod_active(idx: int) -> bool:
	var w: WorldState = ws
	return w != null and w.modifiers.size() > idx and w.modifiers[idx] != null and w.modifiers[idx].is_active


func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value


func _leader_name() -> String:
	if ws.leader != null and ws.leader.name_display != "":
		return ws.leader.name_display
	return "华国锋"


func _find_politician(name1: int, name2: int) -> int:
	for i in ws.politicians.size():
		var p := ws.politicians[i]
		if p != null and p.name_first == name1 and p.name_last == name2:
			return i
	return -1


func _set_leader_from(p: PoliticianData) -> void:
	if ws.leader == null or p == null:
		return
	ws.leader.name_display = p.name_display
	ws.leader.name_first = p.name_first
	ws.leader.name_last = p.name_last
	ws.leader.trait_personality = p.trait_personality
	ws.leader.trait_background = p.trait_background
	ws.leader.trait_alignment = p.trait_alignment
	ws.leader.trait_special = p.trait_special
	ws.leader.age = p.age
	PoliticianSystem.copy_leader_appearance(ws.leader, p)


func _c45_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(45)
	return c != null and (c.government == GameConstants.Government.REFORMIST or ws.is_socialism(c, true))


func _c84_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(84)
	return c != null and (c.government == GameConstants.Government.REFORMIST or ws.is_socialism(c, true))


func _c86_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(86)
	return c != null and (c.government == GameConstants.Government.REFORMIST or ws.is_socialism(c, true))


func _c87_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(87)
	return c != null and (c.government == GameConstants.Government.REFORMIST or ws.is_socialism(c, true))


func _c21_is_socialist() -> bool:
	var c := ws.get_country_by_legacy_index(21)
	return c != null and (c.government == GameConstants.Government.REFORMIST or ws.is_socialism(c, true))


func _c86_is_authoritarian() -> bool:
	var c := ws.get_country_by_legacy_index(86)
	return c != null and ws.is_authoritarian(c)


func _c87_is_authoritarian() -> bool:
	var c := ws.get_country_by_legacy_index(87)
	return c != null and ws.is_authoritarian(c)


func _c21_is_authoritarian() -> bool:
	var c := ws.get_country_by_legacy_index(21)
	return c != null and ws.is_authoritarian(c)




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_299_italy_total_collapse.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_299",
	"num": 299,
	"priority": 29900,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_299_italy_total_collapse.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
