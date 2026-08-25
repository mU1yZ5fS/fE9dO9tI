## 原作 Event297.cs：人民的福祉是最高的法律（意大利北约“短剑”线，四选项）。
## 触发：全目录搜索无 this_num_event = 297 / Reset(297)；链外 REST 段，原版无自动条件。
## 差异：allcountries[51]=美国（world_factory 行 51），[87]=葡萄牙；原版即如此；
##  now_leader→current_leader；inflCh→influence_china；isNATO/isEU/isSocEU 映射为 nato/eu/soc_eu。
extends "res://数据脚本/event_script_base.gd"

const TXT_OPT0_DIS := "event.script.event_297_italy_people_welfare.c0"
const TXT_OPT1_DIS := "event.script.event_297_italy_people_welfare.c1"
const TXT_OPT2_DIS := "event.script.event_297_italy_people_welfare.c2"
const TXT_OPT1_DIS_A := "event.script.event_297_italy_people_welfare.c3"
const TXT_OPT1_DIS_B := "event.script.event_297_italy_people_welfare.c4"
const TXT_OPT2_DIS_A := "event.script.event_297_italy_people_welfare.c5"
const TXT_OPT2_DIS_B := "event.script.event_297_italy_people_welfare.c6"
const TXT_R0_A := "event.script.event_297_italy_people_welfare.c7"
const TXT_R0_B := "event.script.event_297_italy_people_welfare.c8"
const TXT_R1_A := "event.script.event_297_italy_people_welfare.c9"
const TXT_R1_B := "event.script.event_297_italy_people_welfare.c10"
const TXT_R2 := "event.script.event_297_italy_people_welfare.c11"
const TXT_R3 := "event.script.event_297_italy_people_welfare.c12"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var usa := world.get_country_by_legacy_index(51)
	var italy := world.get_country_by_legacy_index(85)
	var usa_free := usa != null and not usa.has_tag("对华贸易") and not usa.has_tag("asean")
	var relres := world.get_flag("relres")
	var italy_radical := italy != null and (italy.内战中 or italy.政变中)
	var opt := event_def.options
	if usa_free:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if usa_free and relres:
		_enable(opt[1], event_def.options[1].text)
	elif not relres:
		_disable(opt[1], tr(TXT_OPT1_DIS_A))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS_B))
	if usa_free and italy_radical:
		_enable(opt[2], event_def.options[2].text)
	elif not italy_radical:
		_disable(opt[2], tr(TXT_OPT2_DIS_A))
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS_B))
	_enable(opt[3], event_def.options[3].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	var usa := ws.empires[EmpireData.USA] if ws.empires.size() > EmpireData.USA else null
	var ussr := ws.empires[EmpireData.USSR] if ws.empires.size() > EmpireData.USSR else null
	var usa_hard := usa != null and (usa.current_leader == 2 or usa.current_leader == 0) \
			and ussr != null and usa.power > ussr.power + ws.influence_prc
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if usa_hard:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, 10)
				ws.influence_prc -= 5
				_set_data(182, 0)
				_add(175, -999)
				if italy != null:
					italy.government = GameConstants.Government.AUTHORITARIAN
					italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					italy.influence_china = 0
					italy.set_tag("亲美", true)
					italy.set_tag("对华贸易", false)
					italy.set_tag("soc_eu", false)
				if portugal != null:
					portugal.special -= 5
				context["result_text"] = tr(TXT_R0_A)
			else:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, -50)
				ws.influence_prc += 20
				_add(179, 2)
				_add(175, -999)
				if italy != null:
					italy.set_tag("亲美", false)
					italy.set_tag("nato", false)
					italy.set_tag("eu", false)
				if portugal != null:
					portugal.special -= 5
				context["result_text"] = tr(TXT_R0_B)
		1:
			if usa_hard:
				_add(W.I_BUDGET, -150)
				_add(W.I_AGENTS, -150)
				_add_relation(EmpireData.USA, -250)
				_add_power(EmpireData.USA, 10)
				ws.influence_prc -= 5
				_set_data(182, 0)
				_add(175, -999)
				if italy != null:
					italy.government = GameConstants.Government.AUTHORITARIAN
					italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
					italy.set_tag("亲美", true)
					italy.set_tag("对华贸易", false)
					italy.influence_china = 0
					italy.set_tag("soc_eu", false)
				if portugal != null:
					portugal.special -= 5
				context["result_text"] = tr(TXT_R1_A)
			else:
				_add(W.I_BUDGET, -80)
				_add(W.I_AGENTS, -80)
				_add_relation(EmpireData.USA, -250)
				_add_relation(EmpireData.USSR, 150)
				_add_power(EmpireData.USA, -50)
				_add_power(EmpireData.USSR, 20)
				ws.influence_prc += 10
				_add(178, 2)
				_add(175, -999)
				if italy != null:
					italy.set_tag("亲美", false)
					italy.set_tag("nato", false)
					italy.set_tag("eu", false)
				if portugal != null:
					portugal.special -= 5
				context["result_text"] = tr(TXT_R1_B)
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -100)
			ws.influence_prc += 20
			_add_power(EmpireData.USA, -50)
			_add_relation(EmpireData.USA, -250)
			_add(134, 100)
			_add(W.I_SERVICES, 10)
			if italy != null:
				if italy.level_of_development > 25:
					italy.level_of_development = 25
				italy.government = GameConstants.Government.AUTHORITARIAN
				italy.sub_government = GameConstants.SubGovernment.CONSTITUTIONAL_AUTHORITARIAN
				italy.set_tag("亲美", true)
				italy.set_tag("对华贸易", false)
				italy.influence_china = 0
				italy.set_tag("soc_eu", false)
			if portugal != null:
				portugal.special -= 5
			context["result_text"] = tr(TXT_R2)
		3:
			_set_data(183, 3)
			context["result_text"] = tr(TXT_R3)




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




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_297_italy_people_welfare.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_297",
	"num": 297,
	"priority": 29700,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_297_italy_people_welfare.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
