extends "res://数据脚本/event_script_base.gd"

## 原作 Event551.cs：过河拆桥？（蒙古问题，4选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:57-59 —— 复杂条件见 evaluate()。
## 差异：ILoveSuckCocks→_china_parts_change()；SOV_PRC_PartiesConnection→I_COMMUNICATIONS。

const TXT_OPT0_DIS := "event.script.event_551_mongolia_break.c0"
const TXT_OPT1_DIS := "event.script.event_551_mongolia_break.c1"
const TXT_OPT2_DIS := "event.script.event_551_mongolia_break.c2"
const TXT_R0 := "event.script.event_551_mongolia_break.c3"
const TXT_R1 := "event.script.event_551_mongolia_break.c4"
const TXT_R2 := "event.script.event_551_mongolia_break.c5"
const TXT_R3 := "event.script.event_551_mongolia_break.c6"


func evaluate(world: WorldState) -> bool:
	if world == null:
		return false
	var dd := world
	if dd.size() <= W.I_TERRITORY:
		return false
	var c9 := world.get_country_by_legacy_index(9)
	return dd.mongolia_china_route == 1 and world.decisions.completed[19] and dd.territory_policy == 20 			and c9 != null and c9.puppet_of < 0


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 4:
		return
	var opt := event_def.options
	var line := d.political_line
	if line == 4:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line > 1:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line < 4:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var c1 := ws.get_country_by_legacy_index(1)
	var c9 := ws.get_country_by_legacy_index(9)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_set_data(130, 0)  # 原 data.mongolia_china_route
			_china_parts_change(c1)
			if c9 != null:
				c9.government = GameConstants.Government.SOCIALIST
				c9.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				_leave_alliances(c9)
				c9.set_tag("亲中", true)
				_join_alliances(c9)
			_add(W.I_POPULATION, -20)
			_add(W.I_BUDGET, 50)
			_add(W.I_INDUSTRY, 10)
			_add(W.I_AGRICULTURE, 10)
			_add(W.I_SERVICES, 10)
			_add(W.I_PARTY_SUPPORT, -150)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 150)
			ws.influence_prc -= 20
			_add_relation(EmpireData.USSR, 500)
			_add_power(EmpireData.USSR, 100)
			_add(W.I_DIPLO, -100)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_BUDGET, -80)
			_add(W.I_INDUSTRY, -50)
			_add(W.I_AGRICULTURE, -50)
			_add(W.I_SERVICES, -50)
			_add(W.I_CORRUPTION, 20)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, -150)
			_add(W.I_THOUGHT_FREEDOM, 250)
			ws.influence_prc -= 5
			_add_relation(EmpireData.USSR, 500)
			_add(W.I_DIPLO, -100)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_BUDGET, -100)
			_add(W.I_AGENTS, -80)
			_add(W.I_CORRUPTION, 20)
			_add(W.I_PARTY_SUPPORT, 100)
			_add(W.I_PEOPLE_SUPPORT, -20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			ws.influence_prc -= 5
			_add_relation(EmpireData.USA, -100)
			_add_relation(EmpireData.USSR, -200)
			_add(W.I_DIPLO, 50)
			context["result_text"] = tr(TXT_R2)
		3:
			_set_data(W.I_TERRITORY, 21)
			_add(W.I_PARTY_SUPPORT, 20)
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			ws.influence_prc -= 5
			_add_relation(EmpireData.USA, 100)
			_add_relation(EmpireData.USSR, 100)
			_add(W.I_DIPLO, -20)
			context["result_text"] = tr(TXT_R3)


func _china_parts_change(c1: CountryData) -> void:
	if c1 == null:
		return
	if c1.parts.size() < 16:
		c1.parts.resize(16)
	var c19 := ws.get_country_by_legacy_index(19)
	var c33 := ws.get_country_by_legacy_index(33)
	var is_gk := ws.get_flag("is_gkchp")
	if ws.get_flag("IndOpp"):
		_clear_parts(c1)
		c1.parts[15] = true
	elif c19 != null and c33 != null and c19.puppet_of == GameConstants.LegacySlot.CHINA and c19.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST 			and c33.puppet_of == GameConstants.LegacySlot.CHINA and c33.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_parts(c1)
		c1.parts[14] = true
	elif c33 != null and c33.puppet_of == GameConstants.LegacySlot.CHINA and c33.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_parts(c1)
		c1.parts[13] = true
	elif c19 != null and c19.puppet_of == GameConstants.LegacySlot.CHINA and c19.sub_government == GameConstants.SubGovernment.FEUDAL_SOCIALIST:
		_clear_parts(c1)
		c1.parts[12] = true
	elif is_gk:
		_clear_parts(c1)
		c1.parts[11] = true
	elif d.mongolia_china_route == 1 and d.arunachal_status >= 2 and (d.taiwan_status == 2 or ws.decisions.completed[7]):
		_clear_parts_range(c1)
		c1.parts[0] = true
	elif d.mongolia_china_route == 1 and (d.arunachal_status == 2 or d.arunachal_status == 3):
		_clear_parts_range(c1)
		c1.parts[2] = true
	elif d.arunachal_status >= 2 and (d.taiwan_status == 2 or ws.decisions.completed[7]):
		_clear_parts_range(c1)
		c1.parts[6] = true


func _clear_parts(c1: CountryData) -> void:
	for i in c1.parts.size():
		c1.parts[i] = false


func _clear_parts_range(c1: CountryData) -> void:
	for i in 12:
		if i < 7 or i > 9:
			if i < c1.parts.size():
				c1.parts[i] = false



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_551_mongolia_break.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_551",
	"num": 551,
	"priority": 55100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_551_mongolia_break.gd",
	"trigger_script": "res://数据脚本/事件效果/event_551_mongolia_break.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
