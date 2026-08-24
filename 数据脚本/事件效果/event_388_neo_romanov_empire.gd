extends "res://数据脚本/event_script_base.gd"

## 原作 Event388.cs：新罗曼诺夫帝国（苏联吞并东欧/蒙古，三选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - 描述随机票数 prepare 用 randi_range 复现；
##  - 原版 iron_and_blood 成就 Set(142) 已接 Achievements；
##  - ingamewars[22].usa_place → WarData.usa_side（c51 对华贸易时置 0）。

const TXT_DESC_FMT := "event.script.event_388_neo_romanov_empire.c0"
const TXT_OPT2_RELRES := "event.script.event_388_neo_romanov_empire.c1"
const TXT_OPT2_NORELRES := "event.script.event_388_neo_romanov_empire.c2"
const TXT_DIS_INFLUENCE := "event.script.event_388_neo_romanov_empire.c3"
const TXT_DIS_ARMY := "event.script.event_388_neo_romanov_empire.c4"
const TXT_DIS_WAR := "event.script.event_388_neo_romanov_empire.c5"
const TXT_DIS_ISLANDS := "event.script.event_388_neo_romanov_empire.c6"
const TXT_DIS_FACTION := "event.script.event_388_neo_romanov_empire.c7"
const TXT_R0 := "event.script.event_388_neo_romanov_empire.c8"
const TXT_R1 := "event.script.event_388_neo_romanov_empire.c9"
const TXT_R2_FMT := "event.script.event_388_neo_romanov_empire.c10"
const TXT_RELRES := "event.script.event_388_neo_romanov_empire.c11"
const TXT_WAR_NAME := "event.script.event_388_neo_romanov_empire.c12"
const TXT_WAR_ATT := "event.script.event_388_neo_romanov_empire.c13"
const TXT_WAR_DEF := "event.script.event_388_neo_romanov_empire.c14"


const TXT_LABEL_BUDGET := "event.script.event_388_neo_romanov_empire.c15"
const TXT_LABEL_AGENTS := "event.script.event_388_neo_romanov_empire.c16"
const TXT_LABEL_ARMY := "event.script.event_388_neo_romanov_empire.c17"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	event_def.description = tr(TXT_DESC_FMT).format(["\n", randi_range(80, 94), randi_range(80, 94)])
	var opt := event_def.options
	_enable(opt[0], event_def.options[0].text)
	_enable(opt[1], event_def.options[1].text)
	var relres: bool = world.get_flag("relres")
	var war22 := world.wars[22] if world.wars.size() > 22 else null
	if relres and world.influence_prc >= 750 and _d(W.I_ARMY) >= 750 			and game.is_faction_leading(0) 			and (war22 == null or not war22.is_going) and _d(133) == 0:  # 原版 data.soviet_reorganization_war_state
		_enable(opt[2], tr(TXT_OPT2_RELRES).format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif not relres and world.influence_prc >= 950 and _d(W.I_ARMY) >= 750:
		_enable(opt[2], tr(TXT_OPT2_NORELRES).format([tr(TXT_LABEL_BUDGET), tr(TXT_LABEL_AGENTS), tr(TXT_LABEL_ARMY)]))
	elif world.influence_prc < 750:
		_disable(opt[2], tr(TXT_DIS_INFLUENCE).format([95]))
	elif _d(W.I_ARMY) < 750:
		_disable(opt[2], tr(TXT_DIS_ARMY).format([75]))
	elif war22 != null and war22.is_going:
		_disable(opt[2], tr(TXT_DIS_WAR))
	elif _d(133) != 0:  # 原版 data.soviet_reorganization_war_state
		_disable(opt[2], tr(TXT_DIS_ISLANDS))
	else:
		_disable(opt[2], tr(TXT_DIS_FACTION))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	for i in [2, 6, 9]:
		var c := ws.get_country_by_legacy_index(i)
		if c != null:
			c.set_tag("亲苏", false)
			c.set_tag("对华贸易", false)
			c.set_tag("ovd", false)
			c.set_tag("sev", false)
	_add_power(EmpireData.USSR, 150)
	var ussr := ws.get_country_by_legacy_index(7)
	if ussr != null:
		if ussr.parts.size() < 3:
			ussr.parts.resize(3)
		if ussr.parts[0]:
			ussr.parts[2] = true
			ussr.parts[0] = false
		else:
			ussr.parts[1] = true
	for c in ws.countries:
		if c != null and c.puppet_of == 7:
			c.government = GameConstants.Government.AUTHORITARIAN
			c.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
	if ussr != null:
		ussr.government = GameConstants.Government.AUTHORITARIAN
		ussr.sub_government = GameConstants.SubGovernment.LEFT_NATIONALIST
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			context["result_text"] = tr(TXT_R0)
		1:
			context["result_text"] = tr(TXT_R1)
			_add_relation(EmpireData.USSR, -500)
			_add_relation(EmpireData.USA, 100)
			_add(W.I_DIPLO, -50)
		_:
			context["result_text"] = tr(TXT_R2_FMT).format(["\n", tr(TXT_RELRES) if ws.get_flag("relres") else ""])
			ws.set_flag("relres", false)
			if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null:
				ws.empires[EmpireData.USSR].relations = 0
			# 原作 Event388.cs:122：iron_and_blood → achievements.Set(142)
			Achievements.set_achievement(142)
			_start_war_388()
			var usa388 := ws.get_country_by_legacy_index(51)
			if ws.wars.size() > 22 and ws.wars[22] != null and usa388 != null and usa388.has_tag("对华贸易"):
				ws.wars[22].usa_side = GameConstants.WarSide.SIDE1
			_add(W.I_PARTY_SUPPORT, 300)
			_add(W.I_ARMY, -750)


func _start_war_388() -> void:
	game.start_war(22, tr(TXT_WAR_ATT), tr(TXT_WAR_DEF), 250, 750, -1, -1)
	if ws.wars.size() > 22 and ws.wars[22] != null:
		ws.wars[22].name_war = tr(TXT_WAR_NAME)
		ws.wars[22].fortnight_max = 500




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0










# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_388_neo_romanov_empire.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_388",
	"num": 388,
	"priority": 202,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_388_neo_romanov_empire.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1985.6.1"}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "ovd", "target": "ROOT"}]}, {"t": "NOT", "c": [{"t": "COUNTRY_HAS_TAG", "key": "sev", "target": "ROOT"}]}, {"t": "EMPIRE_LEADER_IS", "key": "1", "v": 4}, {"t": "RESOURCE_AT_LEAST", "key": "soviet_influence", "v": 250}, {"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "9"}, {"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "4"}, {"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "5"}, {"t": "COUNTRY_HAS_TAG", "key": "亲苏", "target": "6"}, {"t": "NOT", "c": [{"t": "WAR_ACTIVE", "v": 22}]}, {"t": "RESOURCE_EQUALS", "key": "data_133"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
