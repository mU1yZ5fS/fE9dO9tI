extends "res://数据脚本/event_script_base.gd"

## 原作 Event121.cs：新喇嘛（3 选项）。
## 触发：由 Decision(GlobalScript.cs:21) 手动触发（西藏自治路线），原版无自动条件；
## 故 trigger_conditions 为空，本脚本按原版复刻选项显隐与结果效果。

const TXT_OPT0_DIS := "event.script.event_121_new_lama.c0"
const TXT_OPT1_DIS := "event.script.event_121_new_lama.c1"
const TXT_OPT2_DIS := "event.script.event_121_new_lama.c2"
const TXT_R0 := "event.script.event_121_new_lama.c3"
const TXT_R1 := "event.script.event_121_new_lama.c4"
const TXT_R2_BEFORE := "event.script.event_121_new_lama.c5"
const TXT_R2_AFTER := "event.script.event_121_new_lama.c6"

func prepare(event_def: EventDef, world: WorldState) -> void:
	_bind_world()
	if event_def == null or world == null or event_def.options.size() < 3:
		return
	var tibet := world.get_country_by_legacy_index(69)
	var soviet := world.get_country_by_legacy_index(7)
	var china := world.get_country_by_legacy_index(1)
	var opt := event_def.options
	var num := 0
	if tibet != null and tibet.special_ending == 33:
		_enable(opt[0], event_def.options[0].text)
	else:
		_disable(opt[0], tr(TXT_OPT0_DIS))
		num += 1
	if world.diplomatic_reputation <= 400 and not _modifier_active(6) and not _modifier_active(3):
		_enable(opt[1], event_def.options[1].text)
	else:
		_disable(opt[1], tr(TXT_OPT1_DIS))
		num += 1
	if (soviet != null and soviet.has_tag("对华贸易")) or (china != null and china.has_tag("sev")) or num >= 2:
		_enable(opt[2], event_def.options[2].text)
	else:
		_disable(opt[2], tr(TXT_OPT2_DIS))




func _modifier_active(index: int) -> bool:
	return ws.modifiers.size() > index and ws.modifiers[index] != null and ws.modifiers[index].is_active


func _set_modifier_active(index: int, active: bool) -> void:
	if ws.modifiers.size() > index and ws.modifiers[index] != null:
		ws.modifiers[index].is_active = active



func execute(context: Dictionary) -> void:
	if not _bind_world():
		return
	var tibet := ws.get_country_by_legacy_index(69)
	var opt := int(context.get("option_index", -1))
	match opt:
		0:
			if tibet != null:
				tibet.special_ending = 0
			_set_modifier_active(18, true)
			context["result_text"] = tr(TXT_R0)
		1:
			_add(W.I_AGENTS, -50)
			_add(W.I_WAR_SUPPORT, -250)
			_add(W.I_INFLUENCE, 15)
			_add_relation(EmpireData.USA, 500)
			_add_power(EmpireData.USA, 25)
			_set_modifier_active(19, true)
			if tibet != null:
				tibet.special_ending = 1
			context["result_text"] = tr(TXT_R1)
		2:
			if d.year < 1982:
				_add_power(EmpireData.USSR, 25)
				_add(W.I_LIVING, 25)
				context["result_text"] = tr(TXT_R2_BEFORE)
			else:
				_add_power(EmpireData.USSR, 50)
				_add(W.I_INFLUENCE, 5)
				context["result_text"] = tr(TXT_R2_AFTER)
			_add(W.I_ARMY, -50)
			_add(W.I_WAR_SUPPORT, -50)
			_add(W.I_AGENTS, 25)
			_add_relation(EmpireData.USA, -250)
			_add_relation(EmpireData.USSR, 500)
			_set_modifier_active(20, true)
			if tibet != null:
				tibet.special_ending = 2




# ══════════════════════════════════════════════════════════
# 自动迁移的事件定义 —— 源： 场景/事件界面/events/event_121_new_lama.tres
# 文案不在本文件，见 资产/本地化/events_zh_CN.csv
# ══════════════════════════════════════════════════════════
const META := {
	"id": "event_121",
	"num": 121,
	"priority": 12100,
	"notify": false,
	"display_script": "res://数据脚本/事件效果/event_121_new_lama.gd",
	"options": [{"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}, {"fx": [{"t": "CUSTOM_SCRIPT"}]}],
}
