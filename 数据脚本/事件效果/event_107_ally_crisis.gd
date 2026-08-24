extends "res://数据脚本/event_script_base.gd"

## 原作 Event107.cs：盟友危机（联盟成员叛离，五选项）。 ## 触发：TimeScript.cs:10985-10990 —— data.ally_crisis_target > 0 && c1.econ && !active。 ## 差异： ##  - data.ally_crisis_target 为目标国家原版序号，结果显示后置 -1（原版 ResultsOfEvents 末尾）。 ##  - 国家名取 Godot display_name()（原版 .name）； → \n； ##    usalliance→美国盟友、sovalliance→苏联盟友、proprc→亲中、 ##    Gosstroy→government、SubGosstroy→sub_government、soc_stab→social_stability。


const TXT_DESC_BASE := "event.script.event_107_ally_crisis.c0"
const TXT_DESC_TAIL := "event.script.event_107_ally_crisis.c1"
const TXT_DESC_US := "event.script.event_107_ally_crisis.c2"
const TXT_DESC_SU := "event.script.event_107_ally_crisis.c3"
const TXT_DESC_OKB := "event.script.event_107_ally_crisis.c4"
const TXT_DESC_ECON := "event.script.event_107_ally_crisis.c5"

const TXT_OPT0_DIS := "event.script.event_107_ally_crisis.c6"
const TXT_OPT1_OKB := "event.script.event_107_ally_crisis.c7"
const TXT_OPT1_NOT_OKB := "event.script.event_107_ally_crisis.c8"
const TXT_OPT1_DIS := "event.script.event_107_ally_crisis.c9"

const TXT_R0_A := "event.script.event_107_ally_crisis.c10"
const TXT_R0_B := "event.script.event_107_ally_crisis.c11"
const TXT_R1_A := "event.script.event_107_ally_crisis.c12"
const TXT_R1_B := "event.script.event_107_ally_crisis.c13"
const TXT_R2_A := "event.script.event_107_ally_crisis.c14"
const TXT_R2_B := "event.script.event_107_ally_crisis.c15"
const TXT_R3_A := "event.script.event_107_ally_crisis.c16"
const TXT_R3_B := "event.script.event_107_ally_crisis.c17"
const TXT_R4 := "event.script.event_107_ally_crisis.c18"


func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var target := _target_country(world)
	var tname := target.display_name() if target != null else "盟国"
	var desc := tr(TXT_DESC_BASE) + tname + tr(TXT_DESC_TAIL)
	if target != null and target.has_tag("美国盟友"):
		desc += tr(TXT_DESC_US)
	elif target != null and target.has_tag("苏联盟友"):
		desc += tr(TXT_DESC_SU)
	elif target != null and target.has_tag("okb"):
		desc += tr(TXT_DESC_OKB)
	elif target != null and target.has_tag("econ"):
		desc += tr(TXT_DESC_ECON)
	event_def.description = desc

	var data := world
	var army := data.army if data.size() > W.I_ARMY else 0
	var agents := data.agents if data.size() > W.I_AGENTS else 0
	var okb := target != null and target.has_tag("okb")
	var opt := event_def.options
	if army >= 200 and okb:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if agents >= 100 and okb:
		_enable(opt[1], tr(TXT_OPT1_OKB))
	elif agents >= 200 and not okb:
		_enable(opt[1], tr(TXT_OPT1_NOT_OKB))
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	_enable(opt[2], event_def.options[2].text)
	if agents >= 50:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT1_DIS))
	_enable(opt[4], event_def.options[4].text)


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var target := _target_country(ws)
	var tname := target.display_name() if target != null else "盟国"
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_ARMY, -200)
			_add(W.I_BUDGET, -30)
			if target != null:
				target.social_stability = 1000
			for c in ws.countries:
				if c == null:
					continue
				if c.has_tag("okb") or c.has_tag("econ"):
					c.social_stability -= 50
			if target != null and target.has_tag("美国盟友"):
				_add_relation(EmpireData.USA, -150)
				target.set_tag("美国盟友", false)
				_add(W.I_DIPLO, 30)
			elif target != null and target.has_tag("苏联盟友"):
				_add_relation(EmpireData.USSR, -150)
				target.set_tag("苏联盟友", false)
				_add(W.I_DIPLO, -30)
			if target != null:
				target.set_tag("亲中", true)
			context["result_text"] = tr(TXT_R0_A) + tname + tr(TXT_R0_B)
		1:
			if target != null:
				target.social_stability = 1000
				if target.has_tag("okb"):
					_add(W.I_AGENTS, -100)
					_add(W.I_BUDGET, -30)
				else:
					_add(W.I_AGENTS, -200)
					_add(W.I_BUDGET, -60)
					target.set_tag("亲中", true)
				if target.has_tag("美国盟友"):
					_add_relation(EmpireData.USA, -100)
					target.set_tag("美国盟友", false)
					_add(W.I_DIPLO, 10)
				elif target.has_tag("苏联盟友"):
					_add_relation(EmpireData.USSR, -100)
					target.set_tag("苏联盟友", false)
					_add(W.I_DIPLO, -10)
			context["result_text"] = tr(TXT_R1_A) + tname + tr(TXT_R1_B)
		2:
			_add(W.I_BUDGET, -100)
			ws.influence_prc += 10
			if target != null:
				target.social_stability = 1000
				if target.has_tag("美国盟友") and target.government != GameConstants.Government.AUTHORITARIAN and target.government != GameConstants.Government.LIBERAL:
					target.government = GameConstants.Government.REFORMIST
					target.sub_government = GameConstants.SubGovernment.PRAGMATIST
				elif target.has_tag("苏联盟友") and target.government != GameConstants.Government.AUTHORITARIAN and target.government != GameConstants.Government.SOCIALIST:
					target.government = GameConstants.Government.REFORMIST
					target.sub_government = GameConstants.SubGovernment.PRAGMATIST
			context["result_text"] = tr(TXT_R2_A) + tname + tr(TXT_R2_B)
		3:
			ws.influence_prc -= 10
			if target != null:
				if target.has_tag("美国盟友"):
					_add_power(EmpireData.USA, 30)
					target.set_tag("美国盟友", false)
					_add(W.I_DIPLO, -30)
					_add_relation(EmpireData.USA, 50)
					if target.government != GameConstants.Government.AUTHORITARIAN and target.government != GameConstants.Government.LIBERAL:
						target.government = GameConstants.Government.SOCIALIST
						target.sub_government = GameConstants.SubGovernment.PRAGMATIST
				elif target.has_tag("苏联盟友"):
					_add_power(EmpireData.USSR, 30)
					target.set_tag("苏联盟友", false)
					_add(W.I_DIPLO, 30)
					_add_relation(EmpireData.USSR, 50)
					if target.government != GameConstants.Government.AUTHORITARIAN and target.government != GameConstants.Government.SOCIALIST:
						target.government = GameConstants.Government.REFORMIST
						target.sub_government = GameConstants.SubGovernment.PRAGMATIST
			_add(W.I_AGENTS, -50)
			_add(W.I_BUDGET, -10)
			if target != null:
				target.social_stability = 500
			context["result_text"] = tr(TXT_R3_A) + tname + tr(TXT_R3_B)
		4:
			ws.influence_prc -= 20
			if target != null:
				if target.has_tag("美国盟友"):
					_add_power(EmpireData.USA, 50)
					if target.government != GameConstants.Government.AUTHORITARIAN and target.government != GameConstants.Government.LIBERAL:
						target.government = GameConstants.Government.LIBERAL
						target.sub_government = GameConstants.SubGovernment.NEOLIBERAL
				elif target.has_tag("苏联盟友"):
					_add_power(EmpireData.USSR, 50)
					if target.government != GameConstants.Government.AUTHORITARIAN and target.government != GameConstants.Government.SOCIALIST:
						target.government = GameConstants.Government.SOCIALIST
						target.sub_government = GameConstants.SubGovernment.STATE_SOCIALIST
				target.set_tag("亲中", false)
				if target.has_tag("okb"):
					target.social_stability = 1000
					target.set_tag("okb", false)
				elif target.has_tag("econ"):
					target.social_stability = 0
					target.set_tag("econ", false)
			context["result_text"] = tr(TXT_R4)
	# 原版 ResultsOfEvents 末尾无条件 data.ally_crisis_target = -1
	if d.size() > 120:
		d.ally_crisis_target = -1


func _target_country(world: WorldState) -> CountryData:
	if world == null or world.size() <= 120:
		return null
	var idx := world.ally_crisis_target
	if idx <= 0:
		return null
	return world.get_country_by_legacy_index(idx)






# ══════════════════════════════════════════════════════════ # 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_107_ally_crisis.tres # 文案不在本文件，见 资产/本地化/events_zh_CN.csv # ══════════════════════════════════════════════════════════
const META := {
	"id": "event_107",
	"num": 107,
	"priority": 11400,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_107_ally_crisis.gd",
	"trigger": [{"t": "ALL", "c": [{"t": "RESOURCE_AT_LEAST", "key": "data_120", "v": 1}, {"t": "COUNTRY_HAS_TAG", "key": "econ", "target": "1"}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
