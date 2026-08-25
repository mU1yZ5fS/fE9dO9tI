extends "res://数据脚本/event_script_base.gd"

## 原作 Event394.cs：1979年意大利选举（五选项）。
## 触发：全目录检索 this_num_event/Reset/event_done/resultOfEvents/StartEvent
##   均未发现本编号的自动触发调用，原版无自动条件，trigger_conditions=[]。
## 差异：
##  - VasilyisGay → ws.get_flag("VasilyisGay")；
##  - 原版 iron_and_blood 成就 Set(122) 已接 Achievements；
##  - 原版 data.italy_power_172..data.short_sword_power 为 raw index，直访并注释；
##  - 原版 allcountries[85].inflCh → influence_china。

const TXT_DESC_V := "event.script.event_394_italian_election_1979.c0"
const TXT_DESC_391_1 := "event.script.event_394_italian_election_1979.c1"
const TXT_DIS0 := "event.script.event_394_italian_election_1979.c2"
const TXT_DIS1 := "event.script.event_394_italian_election_1979.c3"
const TXT_DIS2 := "event.script.event_394_italian_election_1979.c4"
const TXT_DIS3 := "event.script.event_394_italian_election_1979.c5"
const TXT_R0 := "event.script.event_394_italian_election_1979.c6"
const TXT_R1 := "event.script.event_394_italian_election_1979.c7"
const TXT_R2 := "event.script.event_394_italian_election_1979.c8"
const TXT_R3 := "event.script.event_394_italian_election_1979.c9"
const TXT_R_V := "event.script.event_394_italian_election_1979.c10"
const TXT_R_DC := "event.script.event_394_italian_election_1979.c11"
const TXT_R_PCI := "event.script.event_394_italian_election_1979.c12"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	if ws.get_flag("VasilyisGay"):
		event_def.description = tr(TXT_DESC_V)
	elif int(world.completed_event_ids.get("event_391", 0)) == 1 			and int(world.completed_event_ids.get("event_392", 0)) != 1:
		event_def.description = tr(TXT_DESC_391_1)
	var opt := event_def.options
	if _d(W.I_POLITICAL_LINE) >= 3:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_DIS0))
	if _d(W.I_POLITICAL_LINE) >= 2 and _d(W.I_POLITICAL_LINE) <= 3:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_DIS1))
	if _d(W.I_POLITICAL_LINE) <= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_DIS2))
	if _d(W.I_DIPLO) >= 800 and _d(W.I_WAR_SUPPORT) > 300 and _d(W.I_POLITICAL_LINE) <= 3:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_DIS3))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var italy := ws.get_country_by_legacy_index(85)
	var portugal := ws.get_country_by_legacy_index(87)
	var opt := int(context.get("option_index", -1))
	if _mod_active(GameConstants.Modifier.CULTURAL_REVOLUTION):
		_add(176, -1)  # 原版 data.italy_power_176
	if italy != null and italy.has_tag("nato"):
		_add(175, 1)  # 原版 data.italy_power_175
	if ws.empires[EmpireData.USSR].power < ws.empires[EmpireData.USA].power:
		_add(175, 2)  # 原版 data.italy_power_175
	else:
		_add(176, 1)  # 原版 data.italy_power_176
	if portugal != null and portugal.government == GameConstants.Government.LIBERAL:
		_add(175, 1)  # 原版 data.italy_power_175
	if italy != null and italy.level_of_development >= 60:
		_add(175, 2)  # 原版 data.italy_power_175
	if italy != null and italy.level_of_development <= 60 and italy.level_of_development >= 20:
		_add(176, 2)  # 原版 data.italy_power_176
	if _d(134) < 60 and _d(134) >= 20:  # 原版 data.italian_radical_left_power
		_add(176, 1)  # 原版 data.italy_power_176
	elif _d(134) < 100 and _d(134) >= 60:  # 原版 data.italian_radical_left_power
		_add(176, -3)  # 原版 data.italy_power_176
	elif _d(134) >= 100:  # 原版 data.italian_radical_left_power
		_add(176, -999)  # 原版 data.italy_power_176
	if _d(177) > 1:  # 原版 data.italy_power_177
		_add(176, -1)  # 原版 data.italy_power_176
	var txt := ""
	match opt:
		0:
			txt = tr(TXT_R0)
			_add(175, 1)  # 原版 data.italy_power_175
			_add(W.I_BUDGET, -50)
			_add(W.I_AGRICULTURE, 10)
			_add(W.I_INDUSTRY, 10)
			if italy != null and italy.has_tag("对华贸易"):
				_add(W.I_AGRICULTURE, 5)
				_add(W.I_INDUSTRY, 5)
		1:
			txt = tr(TXT_R1)
			_add(176, 1)  # 原版 data.italy_power_176
			_add(180, 1)  # 原版 data.italy_power_180
			_add(181, 1)  # 原版 data.italy_power_181
			_add(W.I_BUDGET, -50)
		2:
			txt = tr(TXT_R2)
			if italy != null and (italy.内战中 or italy.政变中):
				_add(134, 10)  # 原版 data.italian_radical_left_power
			_add(182, 2)  # 原版 data.short_sword_power
			if int(ws.completed_event_ids.get("event_291", 0)) < 3:
				var r291 := int(ws.completed_event_ids.get("event_291", 0))
				_add(172 + r291, 1)  # 原版 data.italy_power_172
				if r291 == 0:
					_add(172, 1)  # 原版 data.italy_power_172
			_add(W.I_BUDGET, -50)
			_add(W.I_AGENTS, -50)
			if italy != null:
				italy.level_of_development -= 5
		3:
			txt = tr(TXT_R3)
			_add(177, 1)  # 原版 data.italy_power_177
			_add(W.I_BUDGET, -50)
		_:
			txt = ""
	if ws.get_flag("VasilyisGay"):
		# 原作 Event394.cs:179：VasilyisGay && iron_and_blood → achievements.Set(122)
		Achievements.set_achievement(122)
		txt += tr(TXT_R_V)
		_add_power(EmpireData.USA, -20)
		_add(172, 3)  # 原版 data.italy_power_172
		_add(173, 6)  # 原版 data.italy_power_173
	elif _d(175) >= _d(176):  # 原版 data.get_data_by_index(175,176)
		txt += tr(TXT_R_DC)
		_add_power(EmpireData.USA, 25)
		_add(172, 1)  # 原版 data.italy_power_172
		_add(173, 2)  # 原版 data.italy_power_173
	else:
		txt += tr(TXT_R_PCI)
		_add_power(EmpireData.USA, -10)
		_add_power(EmpireData.USSR, 10)
		if ws.empires.size() > EmpireData.USSR and ws.empires[EmpireData.USSR] != null 				and ws.empires[EmpireData.USSR].leaders.size() > 6:
			ws.empires[EmpireData.USSR].leaders[6].support += 1
		if portugal != null:
			portugal.special -= 5
		if italy != null:
			italy.influence_china = 1
	context["result_text"] = txt


func _mod_active(idx: int) -> bool:
	return ws.modifiers.size() > idx and ws.modifiers[idx] != null and ws.modifiers[idx].is_active




func _d(index: int) -> int:
	if d.size() > index:
		return d.get_data_by_index(index)
	return 0








# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_394_italian_election_1979.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_394",
	"num": 394,
	"priority": 39400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_394_italian_election_1979.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
