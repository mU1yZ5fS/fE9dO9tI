extends "res://数据脚本/event_script_base.gd"

## 原作 Event240.cs：革命无罪，造反另说（十一届全会评定文革遗产，4 选项）。
## 触发：TimeScript.cs:10206-10212 ——
##   ((日>=12 且 月>=8 且 年>=1977) 或 (月>=9 且 年>=1977) 或 年>=1978)
##   且 data.gang_of_four_path==3 且 !event_done[240]。
## 差异：
##  - 选项1 原版按 data.gang_of_four_path==3 决定按钮文案（真=“不偏不倚…”，假=销毁按钮换“文革已经得罪了所有人啦”），
##    本版用 enable_condition + disabled_text 等价建模。
##  - party_change[] 仅 UI 摆动数值，Godot 建模说明，跳过。
##  - 原版逐 if/else-if 忠诚链与 >0/<3 边界逐字保留。

const TXT_R0 := "event.script.event_240_cultural_revolution_verdict.c0"

const TXT_R1 := "event.script.event_240_cultural_revolution_verdict.c1"

const TXT_R2 := "event.script.event_240_cultural_revolution_verdict.c2"

const TXT_R3 := "event.script.event_240_cultural_revolution_verdict.c3"


func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			_add(W.I_PEOPLE_SUPPORT, 20)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add_relation(EmpireData.USA, -50)
			_add_relation(EmpireData.USSR, -50)
			_set_modifier_off(3)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 100
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty += 80
				elif p.trait_personality == GameConstants.PoliticianPersonality.REFORMIST:
					p.loyalty -= 100
				elif p.trait_personality == GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty += 50
			_set_data(W.I_POST_MAO_COURSE, 1)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_PEOPLE_SUPPORT, -100)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_add(W.I_DIPLO, 100)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty += 100
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty += 80
				elif p.trait_personality > GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 200
					p.power -= 100
			_set_data(W.I_POST_MAO_COURSE, 2)
			context["result_text"] = tr(TXT_R1)
		2:
			_add(W.I_DIPLO, -10)
			_add(W.I_PEOPLE_SUPPORT, 50)
			_add(W.I_THOUGHT_FREEDOM, 80)
			_set_modifier_off(3)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 20
				elif p.trait_personality < GameConstants.PoliticianPersonality.LIBERAL:
					p.loyalty += 100
			_set_data(W.I_POST_MAO_COURSE, 3)
			context["result_text"] = tr(TXT_R2)
		3:
			_add(W.I_PEOPLE_SUPPORT, 80)
			_add(W.I_PARTY_SUPPORT, -50)
			_add(W.I_THOUGHT_FREEDOM, 100)
			_set_modifier_off(3)
			for p in ws.politicians:
				if p == null or PoliticianSystem.is_vacant_politician(p):
					continue
				if p.trait_personality == GameConstants.PoliticianPersonality.FAR_LEFT:
					p.loyalty -= 100
				if p.trait_personality == GameConstants.PoliticianPersonality.CONSERVATIVE:
					p.loyalty -= 50
				elif p.trait_personality > GameConstants.PoliticianPersonality.MODERATE:
					p.loyalty += 100
			_set_data(W.I_POST_MAO_COURSE, 4)
			context["result_text"] = tr(TXT_R3)




func _set_data(index: int, value: int) -> void:
	if d.size() > index:
		d.set_data_by_index(index, value)




func _set_modifier_off(index: int) -> void:
	if index >= 0 and index < ws.modifiers.size() and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = false



# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_240_cultural_revolution_verdict.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_240",
	"num": 240,
	"priority": 2400,
	"notify": false,
	"trigger": [{"t": "ALL", "c": [{"t": "DATE_AFTER", "key": "1977.8.12"}, {"t": "RESOURCE_EQUALS", "key": "gang_of_four_path", "v": 3}]}],
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"disabled": true, "cond": {"t": "RESOURCE_EQUALS", "key": "gang_of_four_path", "v": 3}, "fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
