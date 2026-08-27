extends "res://数据脚本/event_script_base.gd"

## 原作 Event326.cs：1978年宪法（5选项）。
## 触发：ReqEventsDLC02/ReqEventForDLC02.cs:564-567 —— 日>=5 月>=3 年>=1978。
## 差异：描述/选项显隐 prepare 动态改写；party_number→factions.support；old_modify_texts/desc 为修正说明文案跳过。

const TXT_DESC_BASE := "event.script.event_326_constitution_1978.c0"
const TXT_DESC_FOUR := "event.script.event_326_constitution_1978.c1"
const TXT_DESC_THREE := "event.script.event_326_constitution_1978.c2"
const TXT_OPT0_DIS := "event.script.event_326_constitution_1978.c3"
const TXT_OPT1_DIS := "event.script.event_326_constitution_1978.c4"
const TXT_OPT2_DIS := "event.script.event_326_constitution_1978.c5"
const TXT_OPT3_DIS := "event.script.event_326_constitution_1978.c6"
const TXT_R0 := "event.script.event_326_constitution_1978.c7"
const TXT_R1 := "event.script.event_326_constitution_1978.c8"
const TXT_R2 := "event.script.event_326_constitution_1978.c9"
const TXT_R3 := "event.script.event_326_constitution_1978.c10"
const TXT_R4 := "event.script.event_326_constitution_1978.c11"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 5:
		return
	var data := world
	if data.size() <= W.I_POLITICAL_LINE:
		return
	var mod3 := world.modifiers.size() > 3 and world.modifiers[3] != null and world.modifiers[3].is_active
	var mod6 := world.modifiers.size() > 6 and world.modifiers[6] != null and world.modifiers[6].is_active
	if mod3:
		event_def.description = tr(TXT_DESC_BASE) + tr(TXT_DESC_FOUR)
	else:
		event_def.description = tr(TXT_DESC_BASE) + tr(TXT_DESC_THREE)
	var line := data.political_line
	var opt := event_def.options
	if line <= 1 and mod3 and mod6:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
	if line == 1 or line == 2:
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
	if line == 2 or line == 3:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))
	if line == 4:
		_enable(opt[3], event_def.options[3].text)
	else:
		_disable(opt[3], tr(TXT_OPT3_DIS))
	_enable(opt[4], event_def.options[4].text)

func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add_faction_support(0, 50)
			_add(W.I_DIPLO, 50)
			ws.influence_prc += 1
			_set_mod_active(28, true)
			for p in ws.politicians:
				if p == null:
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 1000
					p.power += 500
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.power -= 200
				if p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty = 300
					p.power -= 300
				if p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
					p.loyalty = 0
					p.power -= 400
				if p.trait_personality == GameConstants.PoliticianPersonality.LIBERAL:
					p.loyalty = 0
					p.power -= 500
			if d.press_policy < 18:
				d.press_policy += 1
			_set_data(W.I_PARTY_SYSTEM, 6)
			if d.econ_system > 11:
				_set_data(W.I_ECON_SYSTEM, 11)
			if d.religion_policy > 25:
				_set_data(W.I_RELIGION, 24)
			_add(W.I_PARTY_SUPPORT, -100)
			_add(W.I_PEOPLE_SUPPORT, 100)
			_add(W.I_THOUGHT_FREEDOM, -100)
			_add(W.I_CORRUPTION, -5)
			_add(W.I_BUDGET, 2)
			_add(W.I_AGENTS, 2)
			context["result_text"] = tr(TXT_R0)
		1:
			_add_faction_support(1, 50)
			_add_faction_support(2, 50)
			_add(W.I_PEOPLE_SUPPORT, 25)
			_add(W.I_THOUGHT_FREEDOM, 15)
			if d.press_policy > 18:
				d.press_policy -= 1
			else:
				d.press_policy += 1
			_set_mod_active(28, false)
			if d.party_system > GameConstants.PartySystem.NEW_DEMOCRACY:
				_set_data(W.I_PARTY_SYSTEM, 7)
			_set_mod_active(29, true)
			context["result_text"] = tr(TXT_R1)
		2:
			_add_faction_support(2, 50)
			_add_faction_support(3, 50)
			_add(W.I_THOUGHT_FREEDOM, 15)
			if d.press_policy < 18:
				d.press_policy += 1
			if d.econ_system < 15:
				d.econ_system += 1
			_add(W.I_DIPLO, -100)
			_set_mod_active(28, false)
			_set_mod_active(30, true)
			if d.reform_stage < 2:
				_set_data(W.I_REFORM_STAGE, 2)
			if d.econ_system == 11:
				_set_data(W.I_ECON_SYSTEM, 12)
			elif d.econ_system < 13:
				_set_data(W.I_ECON_SYSTEM, 13)
			context["result_text"] = tr(TXT_R2)
		3:
			_add_faction_support(4, 50)
			if d.econ_system < 15:
				d.econ_system += 1
			if d.party_system < GameConstants.PartySystem.PEOPLE_DEMOCRACY:
				d.party_system += 1
			_add(W.I_DIPLO, -250)
			_add(W.I_THOUGHT_FREEDOM, 50)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_PARTY_SUPPORT, -50)
			_set_mod_active(28, false)
			_set_mod_active(31, true)
			if d.reform_stage < 2:
				_set_data(W.I_REFORM_STAGE, 2)
			if d.econ_system < 14:
				_set_data(W.I_ECON_SYSTEM, 14)
			if d.press_policy < 17:
				_set_data(W.I_PRESS_POLICY, 17)
			context["result_text"] = tr(TXT_R3)
		4:
			_add(W.I_PARTY_SUPPORT, 50)
			context["result_text"] = tr(TXT_R4)

	


func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)

func _set_mod_active(idx: int, value: bool) -> void:
	if ws.modifiers.size() > idx and ws.modifiers[idx] != null:
		ws.modifiers[idx].is_active = value



func _add_faction_support(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].support += delta

func _add_faction_ideology(idx: int, delta: int) -> void:
	if ws.factions.size() > idx and ws.factions[idx] != null:
		ws.factions[idx].ideology += delta

## ── 原版 display-only 文案（跳过执行，仅保留供逐字校验） ──
## 无产阶级宪法
## 极左派+3，极左派力量+3，党内支持度-0.5，人民支持度+1.5，思想自由化-1.5，腐败-0.2，预算+0.3，特工网络+0.3
## 75宪法
## 极左派、保守派+1，极左派、保守派力量+1，党内支持度-0.2，人民支持度+0.2，思想自由化-0.2，腐败-0.2，特工网络+0.2



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_326_constitution_1978.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_326",
	"num": 326,
	"priority": 32600,
	"notify": false,
	"nodesc": true,
	"display_script": "res://数据脚本/事件效果/event_326_constitution_1978.gd",
	"trigger": [{"t": "DATE_AFTER", "key": "1978.3.5"}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
